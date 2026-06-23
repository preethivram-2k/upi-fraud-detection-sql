-- ============================================
-- PROJECT: UPI Transaction Intelligence
-- Fraud Detection & Spending Analytics
-- Author: Preethiv Ram 
-- Tool: MySQL Workbench
-- Date: June 2026
-- Dataset: 20,000 UPI Transactions (2024)
-- ============================================

-- ============================================
-- PHASE 1: DATABASE SETUP
-- ============================================

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS upi_fraud_project;
USE upi_fraud_project;

-- Step 2: Create Users Table
CREATE TABLE users (
    user_id VARCHAR(10) PRIMARY KEY,
    age_group VARCHAR(10),
    city VARCHAR(50),
    city_tier VARCHAR(10),
    kyc_status VARCHAR(20),
    account_age_days INT,
    linked_bank_count INT,
    avg_monthly_transactions INT,
    avg_transaction_value DECIMAL(10,2),
    preferred_app VARCHAR(20),
    preferred_device VARCHAR(20),
    user_loyalty_score DECIMAL(5,3),
    is_high_risk_user INT
);

-- Step 3: Create Merchants Table
CREATE TABLE merchants (
    merchant_id VARCHAR(10) PRIMARY KEY,
    merchant_name VARCHAR(50),
    merchant_category VARCHAR(30),
    merchant_size VARCHAR(20),
    city VARCHAR(50),
    city_tier VARCHAR(10),
    avg_daily_transactions INT,
    is_registered INT,
    rating DECIMAL(3,1)
);

-- Step 4: Create Transactions Table
-- Note: NULL allowed for 3 columns 
-- (real-world data has missing values)
CREATE TABLE transactions (
    transaction_id VARCHAR(15) PRIMARY KEY,
    user_id VARCHAR(10),
    receiver_id VARCHAR(10),
    receiver_type VARCHAR(20),
    amount DECIMAL(10,2),
    timestamp DATETIME,
    date DATE,
    hour_of_day INT,
    day_of_week VARCHAR(15),
    is_weekend INT,
    is_night_transaction INT,
    time_since_last_txn_min VARCHAR(20) NULL,
    transaction_type VARCHAR(20),
    payment_app VARCHAR(20),
    device_type VARCHAR(20),
    status VARCHAR(20),
    user_city_tier VARCHAR(10),
    user_kyc_status VARCHAR(20),
    user_avg_monthly_txn INT,
    user_avg_txn_value DECIMAL(10,2),
    user_loyalty_score DECIMAL(5,3),
    new_device_flag INT,
    ip_location_mismatch INT,
    failed_attempts_last_24h INT,
    transaction_velocity DECIMAL(10,4) NULL,
    amount_deviation_score DECIMAL(10,4) NULL,
    is_fraud INT,
    recurring_payment_flag INT,
    balance_after_transaction DECIMAL(10,2),
    transaction_frequency_score DECIMAL(5,2)
);

-- Step 5: Create Fraud Labels Table
CREATE TABLE fraud_labels (
    transaction_id VARCHAR(15) PRIMARY KEY,
    user_id VARCHAR(10),
    receiver_id VARCHAR(10),
    amount DECIMAL(10,2),
    timestamp DATETIME,
    is_fraud INT,
    new_device_flag INT,
    ip_location_mismatch INT,
    failed_attempts_last_24h INT,
    transaction_velocity DECIMAL(10,4) NULL,
    amount_deviation_score DECIMAL(10,4) NULL
);

-- Step 6: Verify Data Import
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'fraud_labels', COUNT(*) FROM fraud_labels;

-- Expected Results:
-- users        → 2000
-- merchants    → 400
-- transactions → 20000
-- fraud_labels → 20000

-- ============================================
-- PHASE 1: COMPLETE ✓
-- ============================================

-- ============================================
-- PHASE 2: DATA CLEANING & VALIDATION
-- ============================================

-- Q1: Dataset Overview
-- Purpose: Understand total size of our data
-- ============================================
SELECT 
    'transactions' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT receiver_id) AS unique_merchants
FROM transactions;

-- Q2: NULL Value Check
-- Purpose: Find which columns have missing data
-- Real world data always has NULLs — 
-- we must identify before analysis!
-- ============================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(time_since_last_txn_min) 
        AS null_time_since_last_txn,
    COUNT(*) - COUNT(transaction_velocity) 
        AS null_transaction_velocity,
    COUNT(*) - COUNT(amount_deviation_score) 
        AS null_amount_deviation_score
FROM transactions;

-- Q2B: Empty String Check
-- Purpose: VARCHAR columns have empty strings
-- instead of NULL — identifying actual 
-- missing data!
-- ============================================
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN time_since_last_txn_min = '' 
        THEN 1 ELSE 0 END) AS empty_time_since_txn,
    SUM(CASE WHEN transaction_velocity = 0 
        THEN 1 ELSE 0 END) AS zero_velocity
FROM transactions;


-- ============================================
-- Q3: Duplicate Transaction Check
-- Purpose: Ensure no transaction is counted twice
-- In fraud detection, duplicates = big problem!
-- ============================================
SELECT 
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;
-- ============================================
-- Q4: Overall Fraud Rate
-- Purpose: What % of transactions are fraud?
-- This is our KEY metric — baseline for all 
-- fraud analysis!
-- ============================================
SELECT
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud,
    SUM(CASE WHEN is_fraud = 0 THEN 1 ELSE 0 END) 
        AS total_genuine,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) 
        AS fraud_rate_percentage
FROM transactions;

-- ============================================
-- Q5: Transaction Type Distribution
-- Purpose: Understand what types of UPI 
-- transactions exist in our dataset
-- P2P, P2M, Bill Payment, EMI, etc.
-- ============================================
SELECT
    transaction_type,
    COUNT(*) AS total_count,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM transactions), 2) 
        AS percentage
FROM transactions
GROUP BY transaction_type
ORDER BY total_count DESC;

-- ============================================
-- Q6: Transaction Status Check
-- Purpose: How many transactions succeeded 
-- vs failed vs pending?
-- Important for data quality validation!
-- ============================================
SELECT
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM transactions), 2) 
        AS percentage
FROM transactions
GROUP BY status
ORDER BY count DESC;

-- ============================================
-- Q7: Amount Statistics
-- Purpose: Understand transaction amount range
-- Min, Max, Average — basic data profiling
-- ============================================
SELECT
    ROUND(MIN(amount), 2) AS min_amount,
    ROUND(MAX(amount), 2) AS max_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions;

-- ============================================
-- Q8: Date Range Check
-- Purpose: Confirm data covers full year 2024
-- Time range validation = data completeness!
-- ============================================
SELECT
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    COUNT(DISTINCT date) AS total_days
FROM transactions;

-- ============================================
-- PHASE 2: DATA CLEANING & VALIDATION 
-- COMPLETE ✓
-- Key Findings:
-- → NULL values exist in 3 columns (expected)
-- → No duplicates found
-- → Fraud rate ~3.8%
-- → Data covers full year Jan-Dec 2024
-- ============================================

-- ============================================
-- PHASE 3: FRAUD DETECTION ANALYSIS
-- ============================================

-- Q9: Fraud by Transaction Type
-- Purpose: Which transaction type has 
-- highest fraud? P2P or P2M or EMI?
-- Uses: GROUP BY, COUNT, ROUND, Subquery
-- ============================================
SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY transaction_type
ORDER BY fraud_rate DESC;

-- ============================================
-- Q10: Fraud by City Tier
-- Purpose: Tier 1 vs Tier 2 vs Tier 3 —
-- which city tier has more fraud?
-- Uses: GROUP BY, SUM, ROUND
-- ============================================
SELECT
    user_city_tier,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY user_city_tier
ORDER BY fraud_rate DESC;

-- ============================================
-- Q11: Fraud by Hour of Day
-- Purpose: What time do fraudsters strike?
-- Night transactions more risky?
-- Uses: GROUP BY, ORDER BY, SUM
-- ============================================
SELECT
    hour_of_day,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY hour_of_day
ORDER BY fraud_rate DESC
LIMIT 10;

-- ============================================
-- Q12: Night vs Day Fraud Comparison
-- Purpose: Is night transaction more 
-- dangerous than day transaction?
-- Uses: CASE WHEN, GROUP BY, SUM
-- ============================================
SELECT
    CASE WHEN is_night_transaction = 1 
        THEN 'Night' 
        ELSE 'Day' 
    END AS time_of_day,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY is_night_transaction
ORDER BY fraud_rate DESC;


-- ============================================
-- Q13: Top 10 Highest Fraud Transactions
-- Purpose: Find biggest fraud amounts
-- Uses: WHERE filter, ORDER BY, LIMIT
-- ============================================
SELECT
    transaction_id,
    user_id,
    amount,
    transaction_type,
    payment_app,
    timestamp
FROM transactions
WHERE is_fraud = 1
ORDER BY amount DESC
LIMIT 10;

-- ============================================
-- Q14: Fraud by Payment App
-- Purpose: Which app has most fraud?
-- GPay vs PhonePe vs Paytm?
-- Uses: GROUP BY, SUM, ORDER BY
-- ============================================
SELECT
    payment_app,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY payment_app
ORDER BY fraud_rate DESC;

-- ============================================
-- Q15: KYC Status vs Fraud
-- Purpose: Are unverified users more 
-- likely to commit fraud?
-- Uses: GROUP BY, SUM, ROUND
-- ============================================
SELECT
    user_kyc_status,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY user_kyc_status
ORDER BY fraud_rate DESC;

-- ============================================
-- Q16: New Device Flag vs Fraud
-- Purpose: New device use pannа —
-- fraud probability increases?
-- Uses: CASE WHEN, GROUP BY
-- ============================================
SELECT
    CASE WHEN new_device_flag = 1 
        THEN 'New Device' 
        ELSE 'Trusted Device' 
    END AS device_status,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_count,
    ROUND(SUM(is_fraud) * 100.0 / 
        COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY new_device_flag
ORDER BY fraud_rate DESC;

-- ============================================
-- PHASE 3: FRAUD DETECTION ANALYSIS
-- COMPLETE ✓
-- ============================================

-- ============================================
-- PHASE 4: SPENDING BEHAVIOR ANALYSIS
-- ============================================

-- Q17: Average Spend by City Tier
-- Purpose: Tier 1 users spend more than 
-- Tier 3? City tier vs spending pattern!
-- Why: Banks use this for credit limit 
-- decisions and loan eligibility!
-- Uses: AVG, GROUP BY, ROUND
-- ============================================
SELECT
    user_city_tier,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount), 2) AS avg_spend,
    ROUND(MIN(amount), 2) AS min_spend,
    ROUND(MAX(amount), 2) AS max_spend,
    ROUND(SUM(amount), 2) AS total_spend
FROM transactions
GROUP BY user_city_tier
ORDER BY avg_spend DESC;

-- ============================================
-- Q18: Weekend vs Weekday Spending
-- Purpose: Do Indians spend more on 
-- weekends or weekdays?
-- Why: Merchant analytics — when to run 
-- offers and promotions!
-- Uses: CASE WHEN, AVG, GROUP BY
-- ============================================
SELECT
    CASE WHEN is_weekend = 1 
        THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount), 2) AS avg_spend,
    ROUND(SUM(amount), 2) AS total_spend
FROM transactions
GROUP BY is_weekend
ORDER BY avg_spend DESC;

-- ============================================
-- Q19: Peak Spending Hours
-- Purpose: What time do Indians spend most?
-- Why: Payment apps use this for 
-- cashback offers timing!
-- Uses: GROUP BY, COUNT, ORDER BY
-- ============================================
SELECT
    hour_of_day,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(SUM(amount), 2) AS total_spend
FROM transactions
WHERE is_fraud = 0
GROUP BY hour_of_day
ORDER BY total_transactions DESC
LIMIT 10;

-- ============================================
-- Q20: Monthly Spending Trend
-- Purpose: Which month has highest UPI spend?
-- Festive season (Oct-Nov) more spending?
-- Why: Seasonal business planning!
-- Uses: DATE functions, GROUP BY, SUM
-- ============================================
SELECT
    MONTH(date) AS month_number,
    MONTHNAME(date) AS month_name,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_spend,
    ROUND(AVG(amount), 2) AS avg_spend
FROM transactions
WHERE is_fraud = 0
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY month_number;


-- ============================================
-- Q21: Top Merchant Categories by Revenue
-- Purpose: Which category earns most?
-- Food? Electronics? Insurance?
-- Why: Merchant partnership decisions!
-- Uses: JOIN (transactions + merchants)
-- ============================================
SELECT
    m.merchant_category,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_revenue,
    ROUND(AVG(t.amount), 2) AS avg_transaction
FROM transactions t
JOIN merchants m 
    ON t.receiver_id = m.merchant_id
WHERE t.is_fraud = 0
GROUP BY m.merchant_category
ORDER BY total_revenue DESC;

-- ============================================
-- Q22: Top 10 Users by Spending
-- Purpose: Who are our highest spenders?
-- Why: Premium customer identification 
-- for credit card offers!
-- Uses: JOIN (transactions + users), 
--       Window Function RANK
-- ============================================
SELECT
    t.user_id,
    u.city,
    u.city_tier,
    u.age_group,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_spend,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) 
        AS spend_rank
FROM transactions t
JOIN users u 
    ON t.user_id = u.user_id
WHERE t.is_fraud = 0
GROUP BY t.user_id, u.city, u.city_tier, u.age_group
ORDER BY total_spend DESC
LIMIT 10;

-- ============================================
-- Q23: Spending by Age Group
-- Purpose: Which age group spends most?
-- 18-25 vs 26-35 vs 36-50 vs 50+?
-- Why: Targeted marketing decisions!
-- Uses: JOIN (transactions + users),
--       GROUP BY, AVG
-- ============================================
SELECT
    u.age_group,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(AVG(t.amount), 2) AS avg_spend,
    ROUND(SUM(t.amount), 2) AS total_spend
FROM transactions t
JOIN users u 
    ON t.user_id = u.user_id
WHERE t.is_fraud = 0
GROUP BY u.age_group
ORDER BY avg_spend DESC;

-- ============================================
-- Q24: LAG — Month over Month Spending Change
-- Purpose: Is spending growing month by month?
-- Why: Business growth tracking!
-- Uses: CTE + LAG Window Function
-- ============================================
WITH monthly_spend AS (
    SELECT
        MONTH(date) AS month_number,
        MONTHNAME(date) AS month_name,
        ROUND(SUM(amount), 2) AS total_spend
    FROM transactions
    WHERE is_fraud = 0
    GROUP BY MONTH(date), MONTHNAME(date)
)
SELECT
    month_name,
    total_spend,
    LAG(total_spend) OVER 
        (ORDER BY month_number) AS prev_month_spend,
    ROUND(total_spend - LAG(total_spend) OVER 
        (ORDER BY month_number), 2) AS spend_change
FROM monthly_spend
ORDER BY month_number;

-- ============================================
-- PHASE 4: SPENDING BEHAVIOR ANALYSIS
-- COMPLETE ✓
-- ============================================

-- ============================================
-- PHASE 5: RISK PROFILING
-- ============================================

-- Q25: High Risk User Identification
-- Purpose: Find users with multiple fraud 
-- transactions — repeat offenders!
-- Why: Banks blacklist these users!
-- Uses: JOIN, GROUP BY, HAVING, CTE
-- ============================================
WITH fraud_users AS (
    SELECT
        user_id,
        COUNT(*) AS fraud_count,
        ROUND(SUM(amount), 2) AS total_fraud_amount
    FROM transactions
    WHERE is_fraud = 1
    GROUP BY user_id
    HAVING COUNT(*) > 1
)
SELECT
    f.user_id,
    u.city,
    u.city_tier,
    u.age_group,
    u.kyc_status,
    f.fraud_count,
    f.total_fraud_amount
FROM fraud_users f
JOIN users u ON f.user_id = u.user_id
ORDER BY f.fraud_count DESC
LIMIT 10;

-- ============================================
-- Q26: Risk Score Labeling
-- Purpose: Label every transaction as
-- High Risk / Medium Risk / Low Risk
-- Why: Banks use risk scores for 
-- real-time fraud prevention!
-- Uses: CASE WHEN (multiple conditions)
-- ============================================
SELECT
    transaction_id,
    user_id,
    amount,
    new_device_flag,
    ip_location_mismatch,
    failed_attempts_last_24h,
    is_night_transaction,
    CASE
        WHEN new_device_flag = 1 
            AND ip_location_mismatch = 1 THEN 'High Risk'
        WHEN new_device_flag = 1 
            OR ip_location_mismatch = 1 
            OR failed_attempts_last_24h > 2 THEN 'Medium Risk'
        WHEN is_night_transaction = 1 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_label
FROM transactions
WHERE is_fraud = 0
ORDER BY risk_label
LIMIT 20;

-- ============================================
-- Q27: Risk Label Summary
-- Purpose: How many High/Medium/Low risk
-- transactions exist?
-- Why: Overall risk distribution understand!
-- Uses: CASE WHEN + GROUP BY (subquery)
-- ============================================
SELECT
    risk_label,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT
        CASE
            WHEN new_device_flag = 1 
                AND ip_location_mismatch = 1 THEN 'High Risk'
            WHEN new_device_flag = 1 
                OR ip_location_mismatch = 1 
                OR failed_attempts_last_24h > 2 THEN 'Medium Risk'
            WHEN is_night_transaction = 1 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_label
    FROM transactions
    WHERE is_fraud = 0
) AS risk_table
GROUP BY risk_label
ORDER BY transaction_count DESC;

-- ============================================
-- Q28: Merchant Risk Analysis
-- Purpose: Which merchants have highest
-- fraud rate? Risky merchants identify!
-- Why: Banks block suspicious merchants!
-- Uses: JOIN + Window DENSE_RANK
-- ============================================
SELECT
    m.merchant_category,
    m.merchant_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.is_fraud) AS fraud_count,
    ROUND(SUM(t.is_fraud) * 100.0 / 
        COUNT(t.transaction_id), 2) AS fraud_rate,
    DENSE_RANK() OVER 
        (ORDER BY SUM(t.is_fraud) DESC) AS fraud_rank
FROM transactions t
JOIN merchants m ON t.receiver_id = m.merchant_id
GROUP BY m.merchant_category, m.merchant_name
ORDER BY fraud_count DESC
LIMIT 15;

-- ============================================
-- Q29: Combined Risk Profile
-- Purpose: Full fraud profile —
-- all 4 tables joined together!
-- Why: Complete picture of high risk users!
-- Uses: Multiple JOINs + CTE + CASE WHEN
-- ============================================
WITH high_risk_txn AS (
    SELECT
        t.transaction_id,
        t.user_id,
        t.receiver_id,
        t.amount,
        t.is_fraud,
        t.new_device_flag,
        t.ip_location_mismatch,
        t.is_night_transaction,
        CASE
            WHEN t.new_device_flag = 1 
                AND t.ip_location_mismatch = 1 
                THEN 'High Risk'
            WHEN t.new_device_flag = 1 
                OR t.ip_location_mismatch = 1 
                THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_label
    FROM transactions t
)
SELECT
    h.transaction_id,
    h.user_id,
    u.city,
    u.age_group,
    m.merchant_category,
    h.amount,
    h.risk_label,
    h.is_fraud
FROM high_risk_txn h
JOIN users u ON h.user_id = u.user_id
JOIN merchants m ON h.receiver_id = m.merchant_id
WHERE h.risk_label = 'High Risk'
ORDER BY h.amount DESC
LIMIT 15;

-- ============================================
-- PHASE 5: RISK PROFILING COMPLETE ✓
-- ============================================

-- ============================================
-- PHASE 6: VIEW CREATION
-- ============================================

-- Creating Fraud Summary View
-- Purpose: Reusable fraud analysis summary
-- Recruiter impact: Shows database design skill!
-- Uses: CREATE VIEW, JOIN, GROUP BY, CASE WHEN
-- ============================================
CREATE VIEW fraud_summary_view AS
SELECT
    t.user_id,
    u.city,
    u.city_tier,
    u.age_group,
    u.kyc_status,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.is_fraud) AS total_frauds,
    ROUND(SUM(t.is_fraud) * 100.0 / 
        COUNT(t.transaction_id), 2) AS fraud_rate,
    ROUND(SUM(t.amount), 2) AS total_spend,
    CASE
        WHEN SUM(t.is_fraud) >= 3 THEN 'High Risk User'
        WHEN SUM(t.is_fraud) >= 1 THEN 'Medium Risk User'
        ELSE 'Low Risk User'
    END AS user_risk_category
FROM transactions t
JOIN users u ON t.user_id = u.user_id
GROUP BY 
    t.user_id, u.city, u.city_tier, 
    u.age_group, u.kyc_status;

-- ============================================
-- Test the VIEW — just one line!
-- ============================================
SELECT * FROM fraud_summary_view
WHERE user_risk_category = 'High Risk User'
ORDER BY total_frauds DESC
LIMIT 10;

-- ============================================
-- PHASE 6: VIEW COMPLETE ✓
-- ============================================