package DAO;

import Model.BankAccount;
import java.sql.*;

public class BankAccountDAO {

    
    private static final String URL = "jdbc:mysql://localhost:3306/mbankingdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "sheishero@7539";


    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver 9.x loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ ERROR: MySQL Driver not found!");
            System.err.println("Make sure mysql-connector-j-9.5.0.jar is in the classpath");
            System.err.println("Check Maven dependencies or add JAR to project libraries");
            e.printStackTrace();
        }
    }

    
    public BankAccountDAO() {
        System.out.println("BankAccountDAO initialized with URL: " + URL);
        testConnection(); 
    }

    
    public int generateAccountNumber() {
        int accountNumber = 100000 + (int)(Math.random() * 900000); 
        
        while (getAccount(accountNumber) != null) {
            accountNumber = 100000 + (int)(Math.random() * 900000);
        }
        return accountNumber;
    } 

    
    public void createAccount(BankAccount account) {
        String sql = "INSERT INTO accounts (account_number, account_holder, balance, email, password) VALUES (?, ?, ?, ?, ?)";
        
        System.out.println("\n=== Creating New Account ===");
        System.out.println("Account #: " + account.getAccountNumber());
        System.out.println("Holder: " + account.getAccountHolder());
        System.out.println("Email: " + account.getEmail());
        System.out.println("Initial Balance: $" + account.getBalance());
        
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, account.getAccountNumber());
            stmt.setString(2, account.getAccountHolder());
            stmt.setDouble(3, account.getBalance());
            stmt.setString(4, account.getEmail());
            stmt.setString(5, account.getPassword());
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("✅ SUCCESS: Account created. Rows affected: " + rowsAffected);
            
        } catch (SQLException e) {
            System.err.println("❌ ERROR creating account: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            
            
            if (e.getMessage().contains("Duplicate entry")) {
                System.err.println("Duplicate email or account number!");
            } else if (e.getMessage().contains("Access denied")) {
                System.err.println("Database access denied. Check username/password.");
            } else if (e.getMessage().contains("Unknown database")) {
                System.err.println("Database 'mbankingdb' doesn't exist!");
                System.err.println("Run: CREATE DATABASE mbankingdb;");
            }
            
            e.printStackTrace();
        }
    }

    
    public BankAccount getAccount(int accountNumber) {
        String sql = "SELECT * FROM accounts WHERE account_number = ?";
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, accountNumber);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                BankAccount account = new BankAccount(
                    rs.getInt("account_number"),
                    rs.getString("account_holder"),
                    rs.getDouble("balance"),
                    rs.getString("email"),
                    rs.getString("password")
                );
                System.out.println("Found account #" + accountNumber + ": " + account.getAccountHolder());
                return account;
            } else {
                System.out.println("No account found with #" + accountNumber);
            }

        } catch (SQLException e) {
            System.err.println("Error getting account: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    
    public BankAccount getAccountByEmailAndPassword(String email, String password) {
        String sql = "SELECT * FROM accounts WHERE email = ? AND password = ?";
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                BankAccount account = new BankAccount(
                    rs.getInt("account_number"),
                    rs.getString("account_holder"),
                    rs.getDouble("balance"),
                    rs.getString("email"),
                    rs.getString("password")
                );
                System.out.println("Login successful for: " + email);
                return account;
            } else {
                System.out.println("Login failed for: " + email);
            }

        } catch (SQLException e) {
            System.err.println("Error during login: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM accounts WHERE email = ?";
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                boolean exists = rs.getInt(1) > 0;
                System.out.println("Email '" + email + "' exists: " + exists);
                return exists;
            }

        } catch (SQLException e) {
            System.err.println("Error checking email: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    
    public void updateBalance(BankAccount account) {
        String sql = "UPDATE accounts SET balance = ? WHERE account_number = ?";
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDouble(1, account.getBalance());
            stmt.setInt(2, account.getAccountNumber());
            
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("✅ Balance updated for account #" + account.getAccountNumber() + 
                                 " to $" + account.getBalance());
            } else {
                System.err.println("❌ No account found with #" + account.getAccountNumber());
            }

        } catch (SQLException e) {
            System.err.println("Error updating balance: " + e.getMessage());
            e.printStackTrace();
        }
    }

    
    public boolean testConnection() {
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            System.out.println("\n=== Database Connection Test ===");
            System.out.println("✅ Connection successful!");
            System.out.println("Database: " + conn.getCatalog());
            
            
            DatabaseMetaData meta = conn.getMetaData();
            System.out.println("MySQL Version: " + meta.getDatabaseProductVersion());
            System.out.println("Driver: " + meta.getDriverName() + " " + meta.getDriverVersion());
            
            
            ResultSet tables = meta.getTables(null, null, "accounts", null);
            if (tables.next()) {
                System.out.println("✅ Table 'accounts' exists");
                
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM accounts");
                if (rs.next()) {
                    System.out.println("Total accounts in database: " + rs.getInt("count"));
                }
            } else {
                System.err.println("❌ Table 'accounts' doesn't exist!");
                System.err.println("Run: CREATE TABLE accounts (...)");
            }
            
            System.out.println("=============================\n");
            return true;
            
        } catch (SQLException e) {
            System.err.println("\n=== Database Connection Test ===");
            System.err.println("❌ Connection failed!");
            System.err.println("Error: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("URL: " + URL);
            System.err.println("User: " + USER);
            
            
            if (e.getMessage().contains("Unknown database")) {
                System.err.println("\n💡 SOLUTION: Database doesn't exist. Run:");
                System.err.println("  CREATE DATABASE mbankingdb;");
            } else if (e.getMessage().contains("Access denied")) {
                System.err.println("\n💡 SOLUTION: Check MySQL username/password");
            } else if (e.getMessage().contains("Communications link failure")) {
                System.err.println("\n💡 SOLUTION: MySQL service might not be running");
                System.err.println("  Start MySQL service or check port 3306");
            }
            
            System.err.println("=============================\n");
            return false;
        }
    }
    
    
    public void getAllAccounts() {
        String sql = "SELECT * FROM accounts ORDER BY account_number";
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            System.out.println("\n=== All Accounts in Database ===");
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.println(count + ". #" + rs.getInt("account_number") + 
                                 " | " + rs.getString("account_holder") + 
                                 " | " + rs.getString("email") + 
                                 " | Balance: $" + rs.getDouble("balance"));
            }
            if (count == 0) {
                System.out.println("No accounts in database");
            }
            System.out.println("===============================\n");
            
        } catch (SQLException e) {
            System.err.println("Error getting all accounts: " + e.getMessage());
            e.printStackTrace();
        }
    }
}