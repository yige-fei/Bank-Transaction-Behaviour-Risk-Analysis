-- Select the project database
USE bank_transactions_db;

-- Risk Threshold Summary
-- Calculate the statistical thresholds used later in the risk analysis. 
-- High-value and long-duration transactions are defined as values above: Average + 2 * Standard Deviation.

SELECT
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,
    ROUND(STDDEV(TransactionAmount), 2) AS stddev_transaction_amount,
    ROUND(AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount), 2) AS high_value_threshold,

    ROUND(AVG(TransactionDuration), 2) AS avg_transaction_duration,
    ROUND(STDDEV(TransactionDuration), 2) AS stddev_transaction_duration,
    ROUND(AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration), 2) AS long_duration_threshold
FROM bank_transactions;


-- High Login Attempt Transactions
-- Identify transactions with multiple login attempts. 
-- Multiple login attempts may suggest authentication friction, account access issues, or unusual behaviour.

SELECT
    TransactionID,
    AccountID,
    TransactionAmount,
    TransactionDate,
    TransactionType,
    Channel,
    Location,
    LoginAttempts,
    AccountBalance
FROM bank_transactions
WHERE LoginAttempts >= 3
ORDER BY LoginAttempts DESC, TransactionAmount DESC;


-- High Value Transactions
-- Identify transactions that are significantly higher than normal based on the statistical threshold:
-- Average Transaction Amount + 2 * Standard Deviation.

WITH transaction_thresholds AS (
    SELECT
        AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount) AS high_value_threshold
    FROM bank_transactions
)

SELECT
    bt.TransactionID,
    bt.AccountID,
    bt.TransactionAmount,
    bt.TransactionDate,
    bt.TransactionType,
    bt.Channel,
    bt.Location,
    bt.AccountBalance
FROM bank_transactions bt
CROSS JOIN transaction_thresholds tt
WHERE bt.TransactionAmount > tt.high_value_threshold
ORDER BY bt.TransactionAmount DESC;


-- Long Duration Transactions
-- Identify unusually long transactions. Long transaction duration may suggest delays, friction, 
-- manual intervention, or abnormal transaction behaviour.

WITH duration_thresholds AS (
    SELECT
        AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration) AS long_duration_threshold
    FROM bank_transactions
)

SELECT
    bt.TransactionID,
    bt.AccountID,
    bt.TransactionAmount,
    bt.TransactionDate,
    bt.TransactionType,
    bt.Channel,
    bt.Location,
    bt.TransactionDuration,
    bt.LoginAttempts
FROM bank_transactions bt
CROSS JOIN duration_thresholds dt
WHERE bt.TransactionDuration > dt.long_duration_threshold
ORDER BY bt.TransactionDuration DESC;


-- High Transaction Amount vs Low Account Balance
-- Identify transactions where the transaction amount is greater than the account balance.
-- This may suggest balance pressure or unusual financial behaviour. NULLIF is used to avoid division-by-zero errors.

SELECT
    TransactionID,
    AccountID,
    TransactionAmount,
    AccountBalance,
    ROUND(TransactionAmount / NULLIF(AccountBalance, 0), 2) AS transaction_to_balance_ratio,
    TransactionDate,
    TransactionType,
    Channel,
    Location
FROM bank_transactions
WHERE TransactionAmount > AccountBalance
ORDER BY transaction_to_balance_ratio DESC;


-- Combined Risk Indicator Flag
-- Create simple rule-based risk flags for each transaction.
-- Risk indicators used:
-- 1. High login attempts
-- 2. High transaction value
-- 3. Long transaction duration
-- 4. Transaction amount greater than account balance

WITH risk_thresholds AS (
    SELECT
        AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount) AS high_value_threshold,
        AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration) AS long_duration_threshold
    FROM bank_transactions
),

risk_summary AS (
    SELECT
        bt.TransactionID,
        bt.AccountID,
        bt.TransactionAmount,
        bt.AccountBalance,
        bt.TransactionDuration,
        bt.LoginAttempts,
        bt.TransactionType,
        bt.Channel,
        bt.Location,

        (
            CASE WHEN bt.LoginAttempts >= 3 THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionAmount > rt.high_value_threshold THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionDuration > rt.long_duration_threshold THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionAmount > bt.AccountBalance THEN 1 ELSE 0 END
        ) AS risk_score

    FROM bank_transactions bt
    CROSS JOIN risk_thresholds rt
)

SELECT *
FROM risk_summary
WHERE risk_score > 0
ORDER BY risk_score DESC, TransactionAmount DESC;


-- Risk Score Summary
-- Purpose: Assign each transaction a basic risk score based on the number of risk indicators triggered.
-- Risk score interpretation:
-- 0 = No risk indicators triggered
-- 1 = One risk indicator triggered
-- 2 = Two risk indicators triggered
-- 3+ = Multiple risk indicators triggered, worth closer review

WITH risk_thresholds AS (
    SELECT
        AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount) AS high_value_threshold,
        AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration) AS long_duration_threshold
    FROM bank_transactions
)

SELECT
    bt.TransactionID,
    bt.AccountID,
    bt.TransactionAmount,
    bt.AccountBalance,
    bt.TransactionDuration,
    bt.LoginAttempts,
    bt.TransactionType,
    bt.Channel,
    bt.Location,

    (
        CASE WHEN bt.LoginAttempts >= 3 THEN 1 ELSE 0 END
        +
        CASE WHEN bt.TransactionAmount > rt.high_value_threshold THEN 1 ELSE 0 END
        +
        CASE WHEN bt.TransactionDuration > rt.long_duration_threshold THEN 1 ELSE 0 END
        +
        CASE WHEN bt.TransactionAmount > bt.AccountBalance THEN 1 ELSE 0 END
    ) AS risk_score

FROM bank_transactions bt
CROSS JOIN risk_thresholds rt
ORDER BY risk_score DESC, bt.TransactionAmount DESC;


-- Risk Score Distribution
-- Count how many transactions fall into each risk score group.
-- Clean summary output for Power BI and README.

WITH risk_thresholds AS (
    SELECT
        AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount) AS high_value_threshold,
        AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration) AS long_duration_threshold
    FROM bank_transactions
),

risk_summary AS (
    SELECT
        bt.TransactionID,

        (
            CASE WHEN bt.LoginAttempts >= 3 THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionAmount > rt.high_value_threshold THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionDuration > rt.long_duration_threshold THEN 1 ELSE 0 END
            +
            CASE WHEN bt.TransactionAmount > bt.AccountBalance THEN 1 ELSE 0 END
        ) AS risk_score

    FROM bank_transactions bt
    CROSS JOIN risk_thresholds rt
)

SELECT
    risk_score,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions), 2) AS percentage_of_transactions
FROM risk_summary
GROUP BY risk_score
ORDER BY risk_score DESC;