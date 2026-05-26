-- Select the project database
USE bank_transactions_db;

-- Overall Transaction Summary
-- Get a high-level view of transaction volume, transaction value, average transaction size, and account balance behaviour.

SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT AccountID) AS unique_accounts,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,
    ROUND(MIN(TransactionAmount), 2) AS min_transaction_amount,
    ROUND(MAX(TransactionAmount), 2) AS max_transaction_amount,
    ROUND(AVG(AccountBalance), 2) AS avg_account_balance
FROM bank_transactions;

-- Transaction Type Analysis
-- Identify which transaction types are most common and which contribute the highest total transaction value.

SELECT
    TransactionType,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions
GROUP BY TransactionType
ORDER BY transaction_count DESC;

-- Channel Usage Analysis
-- Understand which banking channels customers use most often.

SELECT
    Channel,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions
GROUP BY Channel
ORDER BY transaction_count DESC;

-- Customer Occupation Analysis
-- Compare transaction behaviour across customer occupation groups.

SELECT
    CustomerOccupation,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,
    ROUND(AVG(AccountBalance), 2) AS avg_account_balance
FROM bank_transactions
GROUP BY CustomerOccupation
ORDER BY transaction_count DESC;

-- Location Analysis
-- Identify locations with the highest transaction activity.

SELECT
    Location,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions
GROUP BY Location
ORDER BY transaction_count DESC;

-- Login Attempts vs Transaction Behaviour
-- Check whether transactions with more login attempts show different transaction amount or account balance patterns.

SELECT
    LoginAttempts,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,
    ROUND(MAX(TransactionAmount), 2) AS max_transaction_amount,
    ROUND(AVG(AccountBalance), 2) AS avg_account_balance
FROM bank_transactions
GROUP BY LoginAttempts
ORDER BY LoginAttempts;

-- Transaction Duration Analysis
-- Analyse how long transactions usually take and whether longer transaction durations may indicate unusual behaviour.

SELECT
    COUNT(*) AS total_transactions,
    ROUND(AVG(TransactionDuration), 2) AS avg_transaction_duration,
    MIN(TransactionDuration) AS min_transaction_duration,
    MAX(TransactionDuration) AS max_transaction_duration
FROM bank_transactions;

-- Group transaction durations into bands
SELECT
    CASE
        WHEN TransactionDuration < 50 THEN 'Under 50 seconds'
        WHEN TransactionDuration BETWEEN 50 AND 100 THEN '50 - 100 seconds'
        WHEN TransactionDuration BETWEEN 101 AND 200 THEN '101 - 200 seconds'
        ELSE 'Above 200 seconds'
    END AS duration_band,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions
FROM bank_transactions
GROUP BY duration_band
ORDER BY transaction_count DESC;

-- Monthly Transaction Trend
-- Summarise transaction volume and value by month for Power BI trend charts.

SELECT
    DATE_FORMAT(TransactionDate, '%Y-%m') AS transaction_month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_value,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m')
ORDER BY transaction_month;



