CREATE DATABASE mbankingdb;
CREATE TABLE accounts (
    account_number INT PRIMARY KEY,
    account_holder VARCHAR(100),
    balance DOUBLE
);
ALTER TABLE accounts ADD COLUMN email VARCHAR(100) NOT NULL;
ALTER TABLE accounts ADD COLUMN password VARCHAR(255) NOT NULL;
ALTER TABLE accounts ADD UNIQUE (email);
