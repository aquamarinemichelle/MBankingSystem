
package Model;


public class BankAccount {
    private int accountNumber;
    private String accountHolder;
    private double balance;
    private String email;
    private String password;

    public BankAccount() {

    }

    public BankAccount(int accountNumber, String accountHolder, double balance, 
                       String email, String password) {
        this.accountNumber = accountNumber;
        this.accountHolder = accountHolder;
        this.balance = balance;
        this.email = email;
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(int accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getAccountHolder() {
        return accountHolder;
    }

    public void setAccountHolder(String accountHolder) {
        this.accountHolder = accountHolder;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        } else {
            throw new IllegalArgumentException("Deposit amount must be positive.");
        }
    }

    public void withdraw(double amount) {
        if (amount > 0) {
            if (balance >= amount) {
                balance -= amount;
            } else {
                throw new IllegalArgumentException("Insufficient funds.");
            }
        } else {
            throw new IllegalArgumentException("Withdrawal amount must be positive.");
        }
    }

    @Override
public String toString() {
    return "BankAccount{" +
            "accountNumber=" + accountNumber +
            ", accountHolder='" + accountHolder + '\'' +
            ", balance=" + balance +
            ", email='" + email + '\'' +
            '}';
}
}
