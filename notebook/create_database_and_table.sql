CREATE DATABASE IF NOT EXISTS bank_transactions_db;

USE bank_transactions_db;

DROP TABLE IF EXISTS bank_transactions;

CREATE TABLE bank_transactions (
    TransactionID VARCHAR(50),
    AccountID VARCHAR(50),
    TransactionAmount DECIMAL(12,2),
    TransactionDate DATETIME,
    TransactionType VARCHAR(20),
    Location VARCHAR(100),
    DeviceID VARCHAR(50),
    IPAddress VARCHAR(50),
    MerchantID VARCHAR(50),
    Channel VARCHAR(50),
    CustomerAge INT,
    CustomerOccupation VARCHAR(100),
    TransactionDuration INT,
    LoginAttempts INT,
    AccountBalance DECIMAL(12,2),
    PreviousTransactionDate DATETIME
);

DESCRIBE bank_transactions;