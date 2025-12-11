package Servlets;

import Model.BankAccount;
import database.DatabaseConfig;
import java.io.IOException;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class ViewStatementServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== ViewStatementServlet called ===");
        
        HttpSession session = request.getSession();
        BankAccount account = (BankAccount) session.getAttribute("account");
        
        if (account == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int accountNumber = account.getAccountNumber();
        System.out.println("Processing statement for account #" + accountNumber);
        
      
        request.setAttribute("accountNumber", accountNumber);
        request.setAttribute("accountHolder", account.getAccountHolder());
        request.setAttribute("currentBalance", account.getBalance());
        
       
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String typeFilter = request.getParameter("typeFilter");
        
       
        Calendar cal = Calendar.getInstance();
        String defaultEndDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
        cal.add(Calendar.DAY_OF_MONTH, -30);
        String defaultStartDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
        
        if (startDate == null || startDate.isEmpty()) startDate = defaultStartDate;
        if (endDate == null || endDate.isEmpty()) endDate = defaultEndDate;
        if (typeFilter == null) typeFilter = "ALL";
        
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("typeFilter", typeFilter);
        
        Connection conn = null;
        try {
         
            conn = DriverManager.getConnection(
                DatabaseConfig.URL,
                DatabaseConfig.USER,
                DatabaseConfig.PASSWORD
            );
            
            System.out.println("Database connection successful");
            
            List<Map<String, Object>> transactions = new ArrayList<>();
            
          
            StringBuilder sql = new StringBuilder(
                "SELECT * FROM transactions WHERE account_number = ? "
            );
            
           
            sql.append("AND DATE(transaction_date) >= ? AND DATE(transaction_date) <= ? ");
            
            
            if (!"ALL".equals(typeFilter)) {
                if ("TRANSFER".equals(typeFilter)) {
                    sql.append("AND (transaction_type = 'TRANSFER_DEBIT' OR transaction_type = 'TRANSFER_CREDIT') ");
                } else {
                    sql.append("AND transaction_type = ? ");
                }
            }
            
            sql.append("ORDER BY transaction_date DESC LIMIT 100");
            
            System.out.println("SQL: " + sql.toString());
            
            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            stmt.setInt(1, accountNumber);
            stmt.setString(2, startDate);
            stmt.setString(3, endDate);
            
            if (!"ALL".equals(typeFilter) && !"TRANSFER".equals(typeFilter)) {
                stmt.setString(4, typeFilter);
            }
            
            ResultSet rs = stmt.executeQuery();
            
         
            int count = 0;
            while (rs.next()) {
                count++;
                Map<String, Object> transaction = new HashMap<>();
                
               
                String dbType = rs.getString("transaction_type");
                String displayType;
                
              
                if (dbType.startsWith("TRANSFER_")) {
                    displayType = "TRANSFER";
                } else {
                    displayType = dbType;
                }
                
                transaction.put("type", displayType);
                transaction.put("amount", rs.getDouble("amount"));
                transaction.put("toAccount", rs.getString("to_account"));
                transaction.put("description", rs.getString("description"));
                transaction.put("fee", rs.getDouble("fee"));
                transaction.put("date", rs.getTimestamp("transaction_date"));
                transaction.put("transactionId", rs.getString("transaction_id"));
                

                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM yyyy HH:mm");
                transaction.put("formattedDate", sdf.format(rs.getTimestamp("transaction_date")));
                
                transactions.add(transaction);
                System.out.println("Found transaction: " + displayType + " - R" + rs.getDouble("amount"));
            }
            
            System.out.println("Total transactions found: " + count);
            
            if (count == 0) {
                System.out.println("No transactions found in database for account #" + accountNumber);
                
               
                try {
                    Statement checkStmt = conn.createStatement();
                    ResultSet tableCheck = checkStmt.executeQuery("SHOW TABLES LIKE 'transactions'");
                    if (!tableCheck.next()) {
                        System.out.println("ERROR: 'transactions' table doesn't exist!");
                        request.setAttribute("error", "Transactions table not found. Please run the SQL to create it.");
                    }
                    tableCheck.close();
                } catch (SQLException e) {
                    System.err.println("Error checking table: " + e.getMessage());
                }
            }
            
            request.setAttribute("transactions", transactions);
            
         
            Map<String, Object> summary = new HashMap<>();
            double totalDeposits = 0;
            double totalWithdrawals = 0;
            double totalTransfers = 0;
            double totalFees = 0;
            
            for (Map<String, Object> txn : transactions) {
                String type = (String) txn.get("type");
                double amount = (Double) txn.get("amount");
                double fee = (Double) txn.get("fee");
                
                switch (type) {
                    case "DEPOSIT":
                        totalDeposits += amount;
                        break;
                    case "WITHDRAWAL":
                        totalWithdrawals += Math.abs(amount); 
                        break;
                    case "TRANSFER":
                        if (amount < 0) { 
                            totalTransfers += Math.abs(amount);
                        }
                        break;
                }
                totalFees += fee;
            }
            
            summary.put("totalDeposits", totalDeposits);
            summary.put("totalWithdrawals", totalWithdrawals);
            summary.put("totalTransfers", totalTransfers);
            summary.put("totalFees", totalFees);
            summary.put("transactionCount", transactions.size());
            
            request.setAttribute("summary", summary);
            
            rs.close();
            stmt.close();
            
        } catch (SQLException e) {
            System.err.println("Database error in ViewStatementServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            
   
            try {
                if (conn != null) {
                    Statement checkStmt = conn.createStatement();
                    ResultSet rs = checkStmt.executeQuery("SHOW TABLES LIKE 'transactions'");
                    if (!rs.next()) {
                        request.setAttribute("error", "ERROR: The 'transactions' table doesn't exist! Please create it with: CREATE TABLE transactions (id INT AUTO_INCREMENT PRIMARY KEY, account_number INT, transaction_type VARCHAR(50), amount DECIMAL(15,2), to_account VARCHAR(20), description VARCHAR(255), fee DECIMAL(10,2), transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, transaction_id VARCHAR(100))");
                    }
                    rs.close();
                }
            } catch (Exception ex) {
                System.err.println("Error checking table: " + ex.getMessage());
            }
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
        
      
        request.getRequestDispatcher("statement.jsp").forward(request, response);
    }
}