# upi-fraud-detection-sql
SQL-based UPI Transaction     Fraud Detection &amp; Spending Analytics
# 🔐 UPI Transaction Intelligence
## Fraud Detection & Spending Analytics

> SQL-based analysis of 20,000 UPI transactions 
> to detect fraud patterns and uncover spending 
> behavior across India

---

## 📌 Project Overview

India's UPI network processes **17 billion 
transactions per month**. This project analyzes 
20,000 synthetic UPI transactions to:

- 🔍 Detect fraud patterns
- 📊 Analyze spending behavior  
- ⚠️ Build risk profiles for users and merchants

**Tool:** MySQL Workbench  
**Dataset:** [UPI Payment Transactions India — Kaggle](https://www.kaggle.com/datasets/maulikgajera/upi-payment-transactions-india)  
**Records:** 20,000 transactions | 2,000 users | 400 merchants

---

## 📂 Project Structure

```
Phase 1 → Database Setup & Import
Phase 2 → Data Cleaning & Validation
Phase 3 → Fraud Detection Analysis
Phase 4 → Spending Behavior Analysis
Phase 5 → Risk Profiling
Phase 6 → View Creation
```

---

## 🗄️ Database Schema

| Table | Rows | Description |
|---|---|---|
| transactions | 20,000 | Core transaction log |
| users | 2,000 | User profiles |
| merchants | 400 | Merchant details |
| fraud_labels | 20,000 | Fraud signals |

---

## 🔑 Key SQL Concepts Used

- ✅ Window Functions (RANK, DENSE_RANK, LAG)
- ✅ CTEs (Common Table Expressions)
- ✅ Multiple JOINs (3-4 tables)
- ✅ CASE WHEN (Risk Labeling)
- ✅ NULL Handling (COALESCE, IS NULL)
- ✅ Subqueries
- ✅ Date Functions
- ✅ Views

---

## 🔍 Key Findings

### Fraud Detection:
- 🚨 **Peak fraud hour: 1AM** — 6.32% fraud rate
- 🌙 **Night transactions: 69% more risky** than day
- 📱 **New device = 12.35% fraud rate** (4x higher!)
- 🏙️ **Tier 3 cities** show highest fraud (4.08%)
- 💳 **Unverified KYC** = 62% higher fraud risk

### Spending Behavior:
- 🏆 **Tier 1 users spend 2.7x more** than Tier 3
- 🍕 **Food & Dining** = highest revenue category
- 📅 **December** = peak spending month (+₹2,03,430)
- 👤 **55+ age group** = highest average transaction
- ⏰ **2PM** = peak transaction hour

### Risk Profiling:
- ⚠️ **35 High Risk transactions** identified
- 🏪 **Education merchant** = highest fraud rate (15.79%)
- 🔄 **Repeat offenders** identified via CTE analysis

---

## 💡 Business Recommendations

1. **Implement night-time step-up authentication** for transactions between 12AM-5AM
2. **Mandatory re-verification** for new device logins
3. **Enhanced monitoring** for Tier 3 city transactions
4. **KYC enforcement** — unverified users need stricter limits
5. **Education merchant** category needs immediate audit

---

## 🚀 How to Run

```sql
-- 1. Open MySQL Workbench
-- 2. Run upi_project.sql
-- 3. All queries execute in order
USE upi_fraud_project;
SELECT * FROM fraud_summary_view;
```

---

## 🔗 My Other Projects

| Project | Tool | Domain |
|---|---|---|
| [Credit Risk & Loan Performance Dashboard](https://github.com/preethivram-2k/credit-risk-loan-performance-dashboard) | Power BI | BFSI |
| [Insurance Claims Fraud Detection Dashboard](https://github.com/preethivram-2k/Insurance-Claims-Fraud-Detection-Dashboard) | Power BI | BFSI |

---

## 👤 Author

**Preethiv Ram **  
Data Analyst | BFSI Domain  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/preethivram)  
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/preethivram-2k)

---

*Dataset: [UPI Payment Transactions India](https://www.kaggle.com/datasets/maulikgajera/upi-payment-transactions-india) — Kaggle (CC0 Public Domain)*
