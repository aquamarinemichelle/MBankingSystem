-- Drop tables if they exist (for fresh start)
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;

-- Create accounts table
CREATE TABLE accounts (
    account_number INTEGER PRIMARY KEY,
    account_holder VARCHAR(255) NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create transactions table
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    account_number INTEGER NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    to_account VARCHAR(20),
    description TEXT,
    fee DECIMAL(10,2) DEFAULT 0.00,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    FOREIGN KEY (account_number) REFERENCES accounts(account_number) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_transactions_account_number ON transactions(account_number);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_accounts_email ON accounts(email);

-- Add constraints
ALTER TABLE accounts ADD CONSTRAINT check_balance_positive CHECK (balance >= 0);
ALTER TABLE transactions ADD CONSTRAINT check_amount_range CHECK (amount >= -1000000 AND amount <= 1000000);

-- Insert sample data (optional)
INSERT INTO accounts (account_number, account_holder, balance, email, password)
VALUES
    (100001, 'John Doe', 5000.00, 'john@example.com', 'password123'),
    (100002, 'Jane Smith', 10000.00, 'jane@example.com', 'password456')
ON CONFLICT (account_number) DO NOTHING;

-- Verify setup
SELECT 'Database Setup Complete' as status;
SELECT 'accounts' as table_name, COUNT(*) as records FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;