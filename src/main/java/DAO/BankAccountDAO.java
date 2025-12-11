package DAO;

import Model.BankAccount;
import database.DatabaseConfig;
import java.sql.*;

public class BankAccountDAO {

   private static final String URL = DatabaseConfig.URL;
    private static final String USER = DatabaseConfig.USER;
    private static final String PASSWORD = DatabaseConfig.PASSWORD;

    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found!");
            e.printStackTrace();
        }
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
        
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, account.getAccountNumber());
            stmt.setString(2, account.getAccountHolder());
            stmt.setDouble(3, account.getBalance());
            stmt.setString(4, account.getEmail());
            stmt.setString(5, account.getPassword());
            
            stmt.executeUpdate();
            System.out.println("Account created: #" + account.getAccountNumber());
            
        } catch (SQLException e) {
            handleSQLException("createAccount", e);
        }
    }

    
    public BankAccount getAccount(int accountNumber) {
        String sql = "SELECT * FROM accounts WHERE account_number = ?";
        
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, accountNumber);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new BankAccount(
                    rs.getInt("account_number"),
                    rs.getString("account_holder"),
                    rs.getDouble("balance"),
                    rs.getString("email"),
                    rs.getString("password")
                );
            }
        } catch (SQLException e) {
            handleSQLException("getAccount", e);
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
                return new BankAccount(
                    rs.getInt("account_number"),
                    rs.getString("account_holder"),
                    rs.getDouble("balance"),
                    rs.getString("email"),
                    rs.getString("password")
                );
            }
        } catch (SQLException e) {
            handleSQLException("getAccountByEmailAndPassword", e);
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
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            handleSQLException("emailExists", e);
        }
        return false;
    }

   
    public void updateBalance(BankAccount account) {
        String sql = "UPDATE accounts SET balance = ? WHERE account_number = ?";
        
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDouble(1, account.getBalance());
            stmt.setInt(2, account.getAccountNumber());
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            handleSQLException("updateBalance", e);
        }
    }

    
    public boolean transfer(int fromAccountNumber, int toAccountNumber, double amount) {
        Connection conn = null;
        
        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            conn.setAutoCommit(false);
            
            
            BankAccount fromAccount = getAccountInTransaction(conn, fromAccountNumber);
            BankAccount toAccount = getAccountInTransaction(conn, toAccountNumber);
            
            if (fromAccount == null || toAccount == null) {
                throw new SQLException("One or both accounts not found");
            }
            
            
            validateTransfer(fromAccount, amount);
            
            
            fromAccount.withdraw(amount);
            toAccount.deposit(amount);
            
            
            updateBalanceInTransaction(conn, fromAccount);
            updateBalanceInTransaction(conn, toAccount);
            
            conn.commit();
            System.out.println("Transfer successful: R" + amount + 
                             " from #" + fromAccountNumber + " to #" + toAccountNumber);
            return true;
            
        } catch (Exception e) {
            rollbackTransaction(conn);
            System.err.println("Transfer failed: " + e.getMessage());
            return false;
        } finally {
            closeConnection(conn);
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
                                 " | Balance: R" + rs.getDouble("balance"));
            }
            
            if (count == 0) {
                System.out.println("No accounts in database");
            }
            
            System.out.println("===============================\n");
            
        } catch (SQLException e) {
            handleSQLException("getAllAccounts", e);
        }
    }

    
    private BankAccount getAccountInTransaction(Connection conn, int accountNumber) throws SQLException {
        String sql = "SELECT * FROM accounts WHERE account_number = ? FOR UPDATE";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountNumber);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return new BankAccount(
                    rs.getInt("account_number"),
                    rs.getString("account_holder"),
                    rs.getDouble("balance"),
                    rs.getString("email"),
                    rs.getString("password")
                );
            }
        }
        return null;
    }

    
    private void validateTransfer(BankAccount fromAccount, double amount) throws SQLException {
        if (amount <= 0) {
            throw new SQLException("Transfer amount must be positive");
        }
        if (fromAccount.getBalance() < amount) {
            throw new SQLException("Insufficient funds");
        }
    }

    private void updateBalanceInTransaction(Connection conn, BankAccount account) throws SQLException {
        String sql = "UPDATE accounts SET balance = ? WHERE account_number = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, account.getBalance());
            stmt.setInt(2, account.getAccountNumber());
            stmt.executeUpdate();
        }
    }

    private void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                System.err.println("Error rolling back transaction: " + e.getMessage());
            }
        }
    }

    
    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    
    public boolean testConnection() {
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            System.out.println("✅ Database connection successful");
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            return false;
        }
    }

    
    private void handleSQLException(String method, SQLException e) {
        System.err.println("SQL Error in " + method + ": " + e.getMessage());
        System.err.println("SQL State: " + e.getSQLState() + ", Error Code: " + e.getErrorCode());
        e.printStackTrace();
    }
}