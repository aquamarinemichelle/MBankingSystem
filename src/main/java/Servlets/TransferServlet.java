package Servlets;

import DAO.BankAccountDAO;
import Model.BankAccount;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class TransferServlet extends HttpServlet {
    
    private BankAccountDAO accountDAO = new BankAccountDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        BankAccount fromAccount = (BankAccount) session.getAttribute("account");
        
      
        if (fromAccount == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        
        request.setAttribute("fromAccountNumber", fromAccount.getAccountNumber());
        request.setAttribute("fromAccountHolder", fromAccount.getAccountHolder());
        request.setAttribute("oldBalance", fromAccount.getBalance());
        
        try {
           
            String toAccountStr = request.getParameter("toAccount");
            String amountStr = request.getParameter("amount");
            String description = request.getParameter("description");
            
            int toAccountNumber = Integer.parseInt(toAccountStr);
            double amount = Double.parseDouble(amountStr);
            
            System.out.println("Transfer attempt: From #" + fromAccount.getAccountNumber() + 
                             " to #" + toAccountNumber + ", Amount: R" + amount);
            
            
            request.setAttribute("toAccountNumber", toAccountNumber);
            request.setAttribute("transferAmount", amount);
            request.setAttribute("description", description);
            
            
            if (amount <= 0) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Transfer amount must be greater than zero!");
                request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
                return;
            }
            
            if (amount > 100000) { 
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Maximum transfer is R100,000 per transaction!");
                request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
                return;
            }
            
            if (toAccountNumber == fromAccount.getAccountNumber()) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Cannot transfer to your own account!");
                request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
                return;
            }
            
           
            BankAccount toAccount = accountDAO.getAccount(toAccountNumber);
            if (toAccount == null) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", "Recipient account #" + toAccountNumber + " not found!");
                request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("toAccountHolder", toAccount.getAccountHolder());
            
            
            double fee = amount > 1000 ? 10 : 0;
            double totalDebit = amount + fee;
            
           
            if (fromAccount.getBalance() < totalDebit) {
                request.setAttribute("outcome", "error");
                request.setAttribute("message", 
                    "Insufficient funds! Required: R" + String.format("%,.2f", totalDebit) + 
                    " (including R" + fee + " fee). Available: R" + 
                    String.format("%,.2f", fromAccount.getBalance()));
                request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
                return;
            }
            
            
            double oldBalance = fromAccount.getBalance();
            
            
            fromAccount.withdraw(totalDebit);
            accountDAO.updateBalance(fromAccount);
            
            
            toAccount.deposit(amount);
            accountDAO.updateBalance(toAccount);
            
            
            BankAccount updatedAccount = accountDAO.getAccount(fromAccount.getAccountNumber());
            session.setAttribute("account", updatedAccount);
            
            
            request.setAttribute("outcome", "success");
            request.setAttribute("message", "Transfer Successful!");
            request.setAttribute("newBalance", updatedAccount.getBalance());
            request.setAttribute("fee", fee);
            request.setAttribute("totalDebit", totalDebit);
            request.setAttribute("transactionId", generateTransactionId());
            request.setAttribute("transactionDate", new java.util.Date());
            
            System.out.println("Transfer successful: R" + amount + " from #" + 
                             fromAccount.getAccountNumber() + " to #" + toAccountNumber);
            if (fee > 0) {
                System.out.println("Fee charged: R" + fee);
            }
            
            request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "Please enter valid account number and amount!");
            request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", e.getMessage());
            request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("outcome", "error");
            request.setAttribute("message", "System error: " + e.getMessage());
            System.err.println("Error in TransferServlet: " + e.getMessage());
            e.printStackTrace();
            request.getRequestDispatcher("transfer_outcome.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("transfer.jsp");
    }
    
    private String generateTransactionId() {
        return "TRF" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }
}