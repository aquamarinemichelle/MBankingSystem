package Servlets;

import DAO.BankAccountDAO;
import Model.BankAccount;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class LoginServlet extends HttpServlet {
    
    private BankAccountDAO accountDAO = new BankAccountDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("\n=== LoginServlet.doPost() called ===");
        
       
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        System.out.println("Login attempt for email: " + email);
        System.out.println("Password provided: " + (password != null ? "[PROVIDED]" : "null"));
        
       if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Email is required!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Password is required!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        
        email = email.trim();
        password = password.trim();
        
        try {
            
            BankAccount account = accountDAO.getAccountByEmailAndPassword(email, password);
            
            if (account != null) {
                
                System.out.println("✅ Login successful for: " + email);
                System.out.println("Account #: " + account.getAccountNumber());
                System.out.println("Account Holder: " + account.getAccountHolder());
                System.out.println("Balance: $" + account.getBalance());
                
               
                HttpSession session = request.getSession();
                session.setAttribute("account", account);
                session.setAttribute("accountNumber", account.getAccountNumber());
                session.setAttribute("accountHolder", account.getAccountHolder());
                session.setAttribute("email", account.getEmail());
                session.setAttribute("balance", account.getBalance());
                
               
                session.setMaxInactiveInterval(30 * 60);
                
               
                accountDAO.getAllAccounts();
                
                
                response.sendRedirect("dashboard.jsp");
                
            } else {
                
                System.out.println("❌ Login failed for: " + email);
                request.setAttribute("errorMessage", "Invalid email or password!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            System.err.println("❌ ERROR in LoginServlet:");
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error during login. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
       
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("account") != null) {
            
            response.sendRedirect("dashboard.jsp");
        } else {
            
            response.sendRedirect("login.jsp");
        }
    }
}