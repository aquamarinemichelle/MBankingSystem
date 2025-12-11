package Servlets;

import DAO.BankAccountDAO;
import Model.BankAccount;
import database.DatabaseConfig;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class WithdrawServlet extends HttpServlet {
    
    private BankAccountDAO accountDAO = new BankAccountDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BankAccount account = (BankAccount) session.getAttribute("account");
      
        if (account == null) {
            response.sendRedirect("login.jsp");
            return;
        }
       
        request.setAttribute("accountNumber", account.getAccountNumber());
        request.setAttribute("accountHolder", account.getAccountHolder());
        request.setAttribute("oldBalance", account.getBalance());
        
        try {
           
            String amountStr = request.getParameter("amount");
            double amount = Double.parseDouble(amountStr);
            
            System.out.println("Withdrawal attempt: Account #" + account.getAccountNumber() + 
                             ", Amount: R" + amount);
            
            request.setAttribute("withdrawAmount", amount);
           
            if (amount <= 0) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Withdrawal amount must be greater than zero!");
                request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
                return;
            }
            
            if (amount > 50000) { 
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Maximum withdrawal is R50,000 per transaction!");
                request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
                return;
            }
            
            if (amount > account.getBalance()) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", 
                    "Insufficient funds! Available: R" + String.format("%,.2f", account.getBalance()));
                request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
                return;
            }
       
            double oldBalance = account.getBalance();
            account.withdraw(amount);
      
            accountDAO.updateBalance(account);
     
            BankAccount updatedAccount = accountDAO.getAccount(account.getAccountNumber());
            session.setAttribute("account", updatedAccount);
           
            String transactionId = generateTransactionId();
            
            
            recordTransaction(
                account.getAccountNumber(),
                "WITHDRAWAL",
                -amount,
                null,
                "Withdrawal",
                0,
                transactionId
            );
            
            request.setAttribute("outcome", "success");
            request.setAttribute("message", "Withdrawal Successful!");
            request.setAttribute("newBalance", updatedAccount.getBalance());
            request.setAttribute("transactionId", transactionId);
            request.setAttribute("transactionDate", new java.util.Date());
            
            System.out.println("Withdrawal successful: R" + amount + " withdrawn from account #" + account.getAccountNumber());
            
            request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "Please enter a valid number!");
            request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", e.getMessage());
            request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "System error: " + e.getMessage());
            System.err.println("Error in WithdrawServlet: " + e.getMessage());
            e.printStackTrace();
            request.getRequestDispatcher("withdraw_outcome.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("withdraw.jsp");
    }
   
    private String generateTransactionId() {
        return "WDR" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }
    
    
    private void recordTransaction(int accountNumber, String type, double amount, 
                                  String toAccount, String description, 
                                  double fee, String transactionId) {
        Connection conn = null;
        try {
            
            conn = DriverManager.getConnection(
                DatabaseConfig.URL,
                DatabaseConfig.USER,
                DatabaseConfig.PASSWORD
            );
            
            String sql = "INSERT INTO transactions (account_number, transaction_type, amount, " +
                         "to_account, description, fee, transaction_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, accountNumber);
            stmt.setString(2, type);
            stmt.setDouble(3, amount);
            if (toAccount != null && !toAccount.isEmpty()) {
                stmt.setString(4, toAccount);
            } else {
                stmt.setNull(4, java.sql.Types.VARCHAR);
            }
            stmt.setString(5, description != null ? description : "");
            stmt.setDouble(6, fee);
            stmt.setString(7, transactionId);
            
            stmt.executeUpdate();
            System.out.println("Transaction recorded: " + transactionId + " for account #" + accountNumber);
            
        } catch (SQLException e) {
            System.err.println("Error recording transaction: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
}