CREATE DATABASE mbankingdb;
CREATE TABLE accounts (
    account_number INT PRIMARY KEY,
    account_holder VARCHAR(100),
    balance DOUBLE
);
ALTER TABLE accounts ADD COLUMN email VARCHAR(100) NOT NULL;
ALTER TABLE accounts ADD COLUMN password VARCHAR(255) NOT NULL;
ALTER TABLE accounts ADD UNIQUE (email);
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_number INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    to_account VARCHAR(20),
    description VARCHAR(255),
    fee DECIMAL(10,2) DEFAULT 0.00,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY (account_number) REFERENCES accounts(account_number)
);