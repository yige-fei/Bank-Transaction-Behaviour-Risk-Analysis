-- Bank Transaction Behaviour & Risk Analysis
-- Purpose: Create a Power BI-ready view with transaction data, risk indicators, and risk score.

USE bank_transactions_db;

-- Create Risk Analysis View
-- Create a reusable SQL view that Power BI can connect to directly.
-- This avoids rebuilding risk logic manually inside Power BI.

CREATE OR REPLACE VIEW vw_transaction_risk_analysis AS

WITH risk_thresholds AS (
    SELECT
        AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount) AS high_value_threshold,
        AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration) AS long_duration_threshold
    FROM bank_transactions
),

risk_flags AS (
    SELECT
        bt.TransactionID,
        bt.AccountID,
        bt.TransactionAmount,
        bt.TransactionDate,
        YEAR(bt.TransactionDate) AS transaction_year,
        MONTH(bt.TransactionDate) AS transaction_month,
        DATE_FORMAT(bt.TransactionDate, '%Y-%m') AS transaction_year_month,
        bt.TransactionType,
        bt.Location,
        bt.DeviceID,
        bt.IPAddress,
        bt.MerchantID,
        bt.Channel,
        bt.CustomerAge,
        bt.CustomerOccupation,
        bt.TransactionDuration,
        bt.LoginAttempts,
        bt.AccountBalance,
        bt.PreviousTransactionDate,

        ROUND(bt.TransactionAmount / NULLIF(bt.AccountBalance, 0), 2) AS transaction_to_balance_ratio,

        CASE 
            WHEN bt.LoginAttempts >= 3 THEN 1 
            ELSE 0
        END AS high_login_attempt_flag,

        CASE 
            WHEN bt.TransactionAmount > rt.high_value_threshold THEN 1 
            ELSE 0
        END AS high_value_flag,

        CASE 
            WHEN bt.TransactionDuration > rt.long_duration_threshold THEN 1 
            ELSE 0
        END AS long_duration_flag,

        CASE 
            WHEN bt.TransactionAmount > bt.AccountBalance THEN 1 
            ELSE 0
        END AS low_balance_pressure_flag

    FROM bank_transactions bt
    CROSS JOIN risk_thresholds rt
),

risk_scored AS (
    SELECT
        *,
        (
            high_login_attempt_flag
            + high_value_flag
            + long_duration_flag
            + low_balance_pressure_flag
        ) AS risk_score
    FROM risk_flags
)

SELECT
    *,
    CASE
        WHEN risk_score = 0 THEN 'Normal'
        WHEN risk_score = 1 THEN 'Low Risk'
        WHEN risk_score = 2 THEN 'Medium Risk'
        ELSE 'Higher Risk'
    END AS risk_category

FROM risk_scored;


-- Validate View Output
-- Check that the Power BI view contains all 2,512 transactions.

SELECT
    COUNT(*) AS total_rows
FROM vw_transaction_risk_analysis;


-- Preview View
-- Preview the final Power BI-ready dataset.

SELECT *
FROM vw_transaction_risk_analysis
LIMIT 20;


-- Risk Category Distribution
-- Confirm that the view produces the same risk distribution as the earlier risk indicator analysis.

SELECT
    risk_score,
    risk_category,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vw_transaction_risk_analysis), 2) AS percentage_of_transactions
FROM vw_transaction_risk_analysis
GROUP BY risk_score, risk_category
ORDER BY risk_score DESC;