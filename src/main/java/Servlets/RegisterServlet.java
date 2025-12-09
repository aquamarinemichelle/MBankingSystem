package Servlets;

import DAO.BankAccountDAO;
import Model.BankAccount;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet {

    private BankAccountDAO accountDAO = new BankAccountDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("\n=== RegisterServlet.doPost() called ===");
        
       
        String accountHolder = request.getParameter("accountHolder");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        System.out.println("Form Data Received:");
        System.out.println("  Account Holder: " + accountHolder);
        System.out.println("  Email: " + email);
        System.out.println("  Password: " + (password != null ? "[PROVIDED]" : "null"));
        System.out.println("  Confirm Password: " + (confirmPassword != null ? "[PROVIDED]" : "null"));

       
        if (accountHolder == null || accountHolder.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Full name is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Email address is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Password is required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
       
        if (!email.contains("@") || !email.contains(".")) {
            request.setAttribute("errorMessage", "Please enter a valid email address!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

       
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
    
        if (password.length() < 6) {
            request.setAttribute("errorMessage", "Password must be at least 6 characters!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

       
        System.out.println("Checking if email exists: " + email);
        if (accountDAO.emailExists(email)) {
            request.setAttribute("errorMessage", "Email already registered. Please use a different email.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

       
        System.out.println("Generating account number...");
        int accountNumber = accountDAO.generateAccountNumber();
        System.out.println("Generated Account #: " + accountNumber);

        
        System.out.println("Creating BankAccount object...");
        BankAccount account = new BankAccount(accountNumber, accountHolder.trim(), 0.0, email.trim(), password);

       
        try {
            System.out.println("Attempting to save to database...");
            accountDAO.createAccount(account);
            
           
            accountDAO.getAllAccounts();
            
           
            request.setAttribute("successMessage", 
                "Successfully registered! Account #" + accountNumber + 
                " created. You can now login.");
            
          
            request.setAttribute("accountNumber", String.valueOf(accountNumber));
            
            System.out.println("Registration successful for account #" + accountNumber);
            
        } catch (Exception e) {
            System.err.println("❌ ERROR in RegisterServlet:");
            e.printStackTrace();
            request.setAttribute("errorMessage", 
                "Error creating account: " + e.getMessage() + 
                ". Please try again or contact support.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        
        System.out.println("Forwarding to login.jsp...");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.sendRedirect("register.jsp");
    }
}