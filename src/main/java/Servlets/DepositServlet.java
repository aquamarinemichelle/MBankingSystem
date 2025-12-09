package Servlets;

import DAO.BankAccountDAO;
import Model.BankAccount;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class DepositServlet extends HttpServlet {
    
    private BankAccountDAO accountDAO = new BankAccountDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BankAccount account = (BankAccount) session.getAttribute("account");
        
        // Check if user is logged in
        if (account == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Store account details for the outcome page
        request.setAttribute("accountNumber", account.getAccountNumber());
        request.setAttribute("accountHolder", account.getAccountHolder());
        request.setAttribute("oldBalance", account.getBalance());
        
        try {
            // Get deposit amount
            String amountStr = request.getParameter("amount");
            double amount = Double.parseDouble(amountStr);
            
            System.out.println("Deposit attempt: Account #" + account.getAccountNumber() + 
                             ", Amount: R" + amount);
            
            // Store amount for outcome page
            request.setAttribute("depositAmount", amount);
            
            // Validation
            if (amount <= 0) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Amount must be greater than zero!");
                request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
                return;
            }
            
            if (amount > 100000) { // R100,000 limit
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Maximum deposit is R100,000 per transaction!");
                request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
                return;
            }
            
            // Perform deposit
            double oldBalance = account.getBalance();
            account.deposit(amount);
            
            // Update database
            accountDAO.updateBalance(account);
            
            // Refresh account from database
            BankAccount updatedAccount = accountDAO.getAccount(account.getAccountNumber());
            session.setAttribute("account", updatedAccount);
            
            // Store success data for outcome page
            request.setAttribute("outcome", "success");
            request.setAttribute("message", "Deposit Successful!");
            request.setAttribute("newBalance", updatedAccount.getBalance());
            request.setAttribute("transactionId", generateTransactionId());
            request.setAttribute("transactionDate", new java.util.Date());
            
            System.out.println("Deposit successful: R" + amount + " deposited to account #" + account.getAccountNumber());
            
            // Redirect to outcome page
            request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "Please enter a valid number!");
            request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", e.getMessage());
            request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "System error: " + e.getMessage());
            System.err.println("Error in DepositServlet: " + e.getMessage());
            e.printStackTrace();
            request.getRequestDispatcher("deposit_outcome.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to deposit page
        response.sendRedirect("deposit.jsp");
    }
    
    // Generate a simple transaction ID
    private String generateTransactionId() {
        return "TXN" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }
}