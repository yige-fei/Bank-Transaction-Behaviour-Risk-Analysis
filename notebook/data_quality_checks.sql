-- Select the project database
USE bank_transactions_db;

-- Basic Import Validation

-- Check total number of imported rows
-- Expected result: 2,512 rows
SELECT 
    COUNT(*) AS total_rows
FROM bank_transactions;

-- Preview first 10 rows to confirm data loaded correctly
SELECT *
FROM bank_transactions
LIMIT 10;

-- Check for Missing Values
SELECT
    SUM(CASE WHEN TransactionID IS NULL OR TRIM(TransactionID) = '' THEN 1 ELSE 0 END) AS missing_transaction_id,
    SUM(CASE WHEN AccountID IS NULL OR TRIM(AccountID) = '' THEN 1 ELSE 0 END) AS missing_account_id,
    SUM(CASE WHEN TransactionAmount IS NULL THEN 1 ELSE 0 END) AS missing_transaction_amount,
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) AS missing_transaction_date,
    SUM(CASE WHEN TransactionType IS NULL OR TRIM(TransactionType) = '' THEN 1 ELSE 0 END) AS missing_transaction_type,
    SUM(CASE WHEN Location IS NULL OR TRIM(Location) = '' THEN 1 ELSE 0 END) AS missing_location,
    SUM(CASE WHEN DeviceID IS NULL OR TRIM(DeviceID) = '' THEN 1 ELSE 0 END) AS missing_device_id,
    SUM(CASE WHEN IPAddress IS NULL OR TRIM(IPAddress) = '' THEN 1 ELSE 0 END) AS missing_ip_address,
    SUM(CASE WHEN MerchantID IS NULL OR TRIM(MerchantID) = '' THEN 1 ELSE 0 END) AS missing_merchant_id,
    SUM(CASE WHEN Channel IS NULL OR TRIM(Channel) = '' THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN CustomerAge IS NULL THEN 1 ELSE 0 END) AS missing_customer_age,
    SUM(CASE WHEN CustomerOccupation IS NULL OR TRIM(CustomerOccupation) = '' THEN 1 ELSE 0 END) AS missing_customer_occupation,
    SUM(CASE WHEN TransactionDuration IS NULL THEN 1 ELSE 0 END) AS missing_transaction_duration,
    SUM(CASE WHEN LoginAttempts IS NULL THEN 1 ELSE 0 END) AS missing_login_attempts,
    SUM(CASE WHEN AccountBalance IS NULL THEN 1 ELSE 0 END) AS missing_account_balance,
    SUM(CASE WHEN PreviousTransactionDate IS NULL THEN 1 ELSE 0 END) AS missing_previous_transaction_date
FROM bank_transactions;

-- Check for Duplicate Transactions
SELECT 
    TransactionID,
    COUNT(*) AS duplicate_count
FROM bank_transactions
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- Check Numeric Ranges

-- Check transaction amount range
-- Helps identify unusually low, high, or invalid transaction values
SELECT
    MIN(TransactionAmount) AS min_transaction_amount,
    MAX(TransactionAmount) AS max_transaction_amount,
    AVG(TransactionAmount) AS avg_transaction_amount
FROM bank_transactions;

-- Check customer age range
-- Helps confirm that customer age values are realistic
SELECT
    MIN(CustomerAge) AS min_customer_age,
    MAX(CustomerAge) AS max_customer_age,
    AVG(CustomerAge) AS avg_customer_age
FROM bank_transactions;

-- Check account balance range
-- Helps identify unusually low or high account balance values
SELECT
    MIN(AccountBalance) AS min_account_balance,
    MAX(AccountBalance) AS max_account_balance,
    AVG(AccountBalance) AS avg_account_balance
FROM bank_transactions;

-- Check transaction duration range
-- Help identify unusually long or short transaction sessions
SELECT
    MIN(TransactionDuration) AS min_transaction_duration,
    MAX(TransactionDuration) AS max_transaction_duration,
    AVG(TransactionDuration) AS avg_transaction_duration
FROM bank_transactions;

-- Check login attempts range
-- Useful for identifying possible abnormal login behaviour
SELECT
    MIN(LoginAttempts) AS min_login_attempts,
    MAX(LoginAttempts) AS max_login_attempts,
    AVG(LoginAttempts) AS avg_login_attempts
FROM bank_transactions;

-- Check login attempts distribution
-- Shows how many transactions had each number of login attempts
SELECT
    LoginAttempts,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions
FROM bank_transactions
GROUP BY LoginAttempts
ORDER BY LoginAttempts;

-- Check transaction duration distribution by range
-- Groups transaction durations into readable bands for easier review
SELECT
    CASE
        WHEN TransactionDuration < 50 THEN 'Under 50 seconds'
        WHEN TransactionDuration BETWEEN 50 AND 99 THEN '50 - 99 seconds'
        WHEN TransactionDuration BETWEEN 100 AND 199 THEN '100 - 199 seconds'
        WHEN TransactionDuration BETWEEN 200 AND 299 THEN '200 - 299 seconds'
        ELSE '300 seconds and above'
    END AS duration_range,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions
FROM bank_transactions
GROUP BY duration_range
ORDER BY transaction_count DESC;

-- Check Category Values

-- Check available transaction types
-- This shows the distribution of transaction types in the dataset
SELECT
    TransactionType,
    COUNT(*) AS transaction_count
FROM bank_transactions
GROUP BY TransactionType
ORDER BY transaction_count DESC;

-- Check available transaction channels
-- This shows whether customers transact through ATM, branch, online, or other channels
SELECT
    Channel,
    COUNT(*) AS transaction_count
FROM bank_transactions
GROUP BY Channel
ORDER BY transaction_count DESC;

-- Check customer occupation groups
-- This helps understand the customer segment distribution
SELECT
    CustomerOccupation,
    COUNT(*) AS transaction_count
FROM bank_transactions
GROUP BY CustomerOccupation
ORDER BY transaction_count DESC;

-- Check customer occupation groups
-- Shows the transaction distribution across customer segments
SELECT
    CustomerOccupation,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions
FROM bank_transactions
GROUP BY CustomerOccupation
ORDER BY transaction_count DESC;

-- Check Date Range

-- Check earliest and latest transaction dates
-- Confirms the time period covered by the transaction dataset
SELECT
    MIN(TransactionDate) AS earliest_transaction_date,
    MAX(TransactionDate) AS latest_transaction_date
FROM bank_transactions;

-- Check earliest and latest previous transaction dates
-- Validate whether previous transaction dates are within a reasonable range
SELECT
    MIN(PreviousTransactionDate) AS earliest_previous_transaction_date,
    MAX(PreviousTransactionDate) AS latest_previous_transaction_date
FROM bank_transactions;