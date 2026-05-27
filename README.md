# Bank Transaction Behaviour & Risk Analysis 

## Project Overview

This project analyses bank transaction behaviour using **MySQL** and **Looker Studio**. The objective is to validate raw transaction data, explore transaction patterns, and create a rule-based risk scoring system to identify transactions that may require further review.

This project is **not a confirmed fraud detection model**. It does not use labelled fraud data and does not claim that flagged transactions are fraudulent. Instead, it uses SQL-based behavioural indicators such as high transaction value, repeated login attempts, long transaction duration, and low account balance pressure to highlight transactions that may be worth further investigation.

The final SQL output was exported into **Looker Studio** to build a dashboard showing transaction KPIs, risk score distribution, monthly transaction trends, and transactions worth further review.

## Tools Used

- MySQL
- MySQL Workbench
- SQL
- CSV Export
- Looker Studio / Google Data Studio
- GitHub

## Dataset

The dataset contains bank transaction-level records with information such as transaction amount, transaction date, transaction type, transaction channel, customer occupation, login attempts, account balance, and previous transaction date.

The raw dataset contains:

- **2,512 rows**
- **16 columns**
- **0 missing values**
- **0 duplicate Transaction IDs**

The raw CSV was imported into MySQL using the **MySQL Workbench Table Data Import Wizard**. The table structure was created using SQL, while the actual CSV import was completed through the Workbench GUI.

The raw CSV column `IP Address` was imported into the SQL table as `IPAddress` for cleaner SQL naming.

## Project Workflow

```text
Raw CSV Dataset
↓
MySQL Database Creation
↓
Table Creation
↓
CSV Import via MySQL Workbench
↓
Data Quality Checks
↓
Exploratory SQL Analysis
↓
Risk Indicator Analysis
↓
Dashboard-Ready SQL View
↓
CSV Export
↓
Looker Studio Dashboard
↓
GitHub 
```

## SQL Process

The SQL work begins with creating the main project database and table.

Database used:

```sql
bank_transactions_db
```

Main table used:

```sql
bank_transactions
```

The table stores transaction-level fields including:

```text
TransactionID
AccountID
TransactionAmount
TransactionDate
TransactionType
Location
DeviceID
IPAddress
MerchantID
Channel
CustomerAge
CustomerOccupation
TransactionDuration
LoginAttempts
AccountBalance
PreviousTransactionDate
```

After importing the CSV into MySQL, data quality checks were performed to ensure the dataset was ready for analysis.

The data quality checks included:

- Confirming total row count
- Previewing imported records
- Checking missing values
- Checking duplicate transaction IDs
- Validating numerical ranges
- Reviewing login attempt values
- Checking transaction duration ranges
- Reviewing categorical fields
- Validating transaction date ranges

Confirmed data quality results:

```text
Total transactions: 2,512
Missing values: 0
Duplicate Transaction IDs: 0
Total transaction amount: $747,555.57
Average transaction amount: $297.59
Unique accounts: 495
```

Exploratory analysis was then performed using SQL to understand transaction behaviour. This included overall transaction summaries, transaction amount analysis, transaction type breakdown, channel breakdown, customer occupation analysis, location analysis, login attempt analysis, transaction duration analysis, and monthly transaction trends.

## Risk Indicator Analysis

The project uses a rule-based scoring approach to flag transactions that may require review.

The main risk indicators are:

```text
high_login_attempt_flag
high_value_flag
long_duration_flag
low_balance_pressure_flag
```

The `high_login_attempt_flag` identifies transactions with repeated login attempts.

The `high_value_flag` identifies transactions with unusually high transaction amounts using a statistical threshold.

The `long_duration_flag` identifies transactions with unusually long transaction durations using a statistical threshold.

The `low_balance_pressure_flag` identifies transactions where the transaction amount is greater than the account balance.

The high-value and long-duration thresholds are based on:

```sql
AVG(TransactionAmount) + 2 * STDDEV(TransactionAmount)
AVG(TransactionDuration) + 2 * STDDEV(TransactionDuration)
```

This means a transaction is flagged as unusually high-value or unusually long-duration if it is significantly above the dataset average.

The final `risk_score` is calculated by adding the triggered risk flags:

```text
risk_score = high_login_attempt_flag
           + high_value_flag
           + long_duration_flag
           + low_balance_pressure_flag
```

The risk category is assigned based on the total risk score:

| Risk Score | Risk Category |
|---:|---|
| 0 | Normal |
| 1 | Low Risk |
| 2 | Medium Risk |
| 3 or more | Higher Risk |

## Dashboard-Ready SQL View

A reusable SQL view was created for dashboard reporting:

```sql
vw_transaction_risk_analysis
```

This view combines the original transaction data with additional fields needed for reporting, including:

- Transaction year
- Transaction month
- Transaction year-month
- Transaction-to-balance ratio
- Risk flags
- Risk score
- Risk category

The dashboard-ready view was exported into:

```text
transaction_risk_analysis_export.csv
```

This processed CSV was then used as the data source for the Looker Studio dashboard.

## Final Risk Category Results

The final SQL risk category distribution was:

| Risk Category | Number of Transactions |
|---|---:|
| Normal | 2,089 |
| Low Risk | 371 |
| Medium Risk | 50 |
| Higher Risk | 2 |

This means the project identified:

```text
50 Medium Risk transactions
2 Higher Risk transactions
52 total transactions worth further review
```

These are not confirmed fraud cases. They are transactions flagged by rule-based indicators for potential review.

## Looker Studio Dashboard

The final dashboard was created using **Looker Studio**.

The dashboard uses the processed SQL export file:

```text
transaction_risk_analysis_export.csv
```

rather than the original raw CSV.

Dashboard title:

```text
Bank Transaction Behaviour & Risk Analysis Dashboard
```

The dashboard includes:

- Total Transactions KPI
- Total Transaction Amount KPI
- Average Transaction Amount KPI
- Medium Risk Transactions KPI
- Higher Risk Transactions KPI
- Risk Category Distribution chart
- Risk Score Distribution chart
- Monthly Transaction Trend chart
- Transactions Worth Further Review table
- Risk score explanation text box

Final dashboard KPI values:

| KPI | Value |
|---|---:|
| Total Transactions | 2,512 |
| Total Transaction Amount | $747,555.57 |
| Average Transaction Amount | $297.59 |
| Medium Risk Transactions | 50 |
| Higher Risk Transactions | 2 |

The dashboard also includes a transaction review table filtered to show only Medium Risk and Higher Risk transactions. This table displays 52 transactions worth further review.

## Dashboard Insights

The dashboard shows that most transactions are classified as normal, while a smaller group triggered one or more rule-based risk indicators.

Most transactions had a risk score of 0, meaning they did not trigger any risk indicators. A total of 371 transactions triggered one risk indicator and were classified as Low Risk. Another 50 transactions triggered two risk indicators and were classified as Medium Risk. Finally, 2 transactions triggered three or more risk indicators and were classified as Higher Risk.

Overall, the analysis identified 52 transactions worth further review. These transactions should not be interpreted as confirmed fraud, but they may require additional review based on transaction behaviour.

## Business Value

This project demonstrates how SQL can be used to build a practical transaction monitoring workflow. It shows how raw transaction data can be validated, analysed, transformed into risk indicators, and prepared for dashboard reporting.

Potential business use cases include:

- Monitoring transaction behaviour
- Identifying transactions that may require manual review
- Highlighting repeated login attempts
- Detecting unusually high transaction values
- Identifying low balance pressure
- Creating dashboard-ready reporting views
- Supporting financial operations and risk review teams

## Key Skills Demonstrated

This project demonstrates skills in:

- SQL database creation
- SQL table design
- Data import workflow using MySQL Workbench
- Data quality validation
- Exploratory data analysis using SQL
- Rule-based risk scoring
- Common Table Expressions
- SQL views
- Dashboard-ready data preparation
- Looker Studio dashboard design
- Finance-style reporting

## Limitations

This project is rule-based and does not use a supervised machine learning model. It does not contain confirmed fraud labels, so the flagged transactions cannot be classified as confirmed fraud.

The risk thresholds are based only on the available dataset, and flagged transactions would require further business review before any conclusion can be made.

## Future Improvements

Future improvements could include:

- Adding confirmed fraud labels if available
- Building a supervised fraud detection model
- Adding customer-level risk aggregation
- Analysing transaction velocity
- Adding merchant-level risk analysis
- Identifying geographic risk patterns
- Connecting MySQL directly to a BI tool
- Adding more dashboard filters such as channel, risk category, transaction type, and customer occupation

## Final Summary

This project uses MySQL and Looker Studio to analyse 2,512 bank transactions and build a rule-based transaction risk dashboard.

SQL was used to validate the dataset, explore transaction behaviour, create risk indicators, calculate risk scores, and build a dashboard-ready reporting view. The processed SQL output was exported into Looker Studio, where KPI cards, trend charts, risk distribution charts, and a transaction review table were created.

The final analysis identified 50 Medium Risk transactions and 2 Higher Risk transactions. These 52 transactions are not confirmed fraud cases, but they were flagged by rule-based indicators as transactions worth further review.
