-- ============================================================
--  TaskFlow  |  Product Analytics
--  SQL Server 2019
--  Brand: TaskFlow — B2B Project Management SaaS
--  Period: January 2024 – June 2024
--  600 Users | 5 Tables | Core Product Metrics
-- ============================================================

-- ============================================================
-- THE DATASET — 5 TABLES
-- ============================================================
-- tf_users           — Every user: signup date, plan, country, company size, status, MRR
-- tf_subscriptions   — Every subscription: plan, start/end date, status, MRR
-- tf_sessions        — Every login session: date, duration, device, plan
-- tf_feature_usage   — Every feature used: feature name, date, usage count, plan
-- tf_support_tickets — Every support ticket: category, priority, status, resolution days

-- ============================================================
-- STEP 1 — CREATE DATABASE AND IMPORT DATA
-- ============================================================

CREATE DATABASE TaskFlow;
GO
USE TaskFlow;
GO

-- After creating the database, import each CSV:
-- Right click TaskFlow → Tasks → Import Flat File
-- Import in this order:
--   tf_users.csv
--   tf_subscriptions.csv
--   tf_sessions.csv
--   tf_feature_usage.csv
--   tf_support_tickets.csv


-- ============================================================
-- Q1 — Monthly User Signups & Growth Trend
-- [VISUALIZE IN POWER BI — Line Chart]
-- ============================================================

SELECT
    MONTH(signup_date) AS month_number,
    DATENAME(MONTH, signup_date) AS month_name,
    COUNT(user_id) AS new_signups
FROM tf_users
GROUP BY MONTH(signup_date), DATENAME(MONTH, signup_date)
ORDER BY month_number

-- Results:
-- 1  January    102
-- 2  February    88
-- 3  March      101
-- 4  April       97
-- 5  May        109
-- 6  June       103

-- Finding:
-- Signups average ~100 per month. May is strongest at 109, February
-- weakest at 88. The flat trend signals acquisition needs investment
-- to break out of the 88-109 monthly range.


-- ============================================================
-- Q2 — User Breakdown by Plan and Status
-- [VISUALIZE IN POWER BI — Donut Charts]
-- ============================================================

-- By Plan
SELECT
    [plan],
    COUNT(user_id) AS total_users,
    CAST(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER() AS DECIMAL(5,2)) AS pct_of_users
FROM tf_users
GROUP BY [plan]
ORDER BY total_users DESC

-- Results:
-- Starter      241    40.17%
-- Growth       171    28.50%
-- Enterprise    98    16.33%
-- Trial         90    15.00%

-- By Status
SELECT
    status,
    COUNT(user_id) AS total_users,
    CAST(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER() AS DECIMAL(5,2)) AS pct_of_users
FROM tf_users
GROUP BY status
ORDER BY total_users DESC

-- Results:
-- Active       428    71.33%
-- Churned      150    25.00%
-- Converted     22     3.67%

-- Finding:
-- Starter dominates at 40.17%. 71.33% of users are active.
-- 25% have churned — significantly above the healthy SaaS benchmark of 5-7%.


-- ============================================================
-- Q3 — Churn Rate Overall and By Plan
-- [VISUALIZE IN POWER BI — KPI Card + Bar Chart]
-- ============================================================

-- Overall Churn Rate
SELECT
    COUNT(*) AS total_users,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned_users,
    CAST(SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_pct
FROM tf_users

-- Results:
-- total_users: 600 | churned_users: 150 | churn_rate_pct: 25.00%

-- Churn Rate by Plan
SELECT
    [plan],
    COUNT(*) AS total_users,
    SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) AS churned_users,
    CAST(SUM(CASE WHEN status = 'Churned' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_pct
FROM tf_users
GROUP BY [plan]
ORDER BY churn_rate_pct DESC

-- Results:
-- Trial         90    42    46.67%
-- Starter      241    60    24.90%
-- Enterprise    98    18    18.37%
-- Growth       171    30    17.54%

-- Finding:
-- Trial users churn at 46.67% — nearly half never engage with the product.
-- Starter at 24.90% is also high. Growth and Enterprise are the stickiest
-- plans at 17.54% and 18.37% respectively. Fixing trial onboarding is
-- the single highest priority action.


-- ============================================================
-- Q4 — Trial to Paid Conversion Rate
-- [VISUALIZE IN POWER BI — KPI Cards]
-- ============================================================

WITH trial_users AS (
    SELECT DISTINCT user_id
    FROM tf_subscriptions
    WHERE [plan] = 'Trial'
),
converted_users AS (
    SELECT DISTINCT user_id
    FROM tf_subscriptions
    WHERE status = 'Converted'
)
SELECT
    COUNT(t.user_id) AS total_trial_users,
    COUNT(c.user_id) AS converted_to_paid,
    CAST(COUNT(c.user_id) * 100.0 / COUNT(t.user_id) AS DECIMAL(5,2)) AS conversion_rate_pct
FROM trial_users t
LEFT JOIN converted_users c ON t.user_id = c.user_id

-- Results:
-- total_trial_users: 112 | converted_to_paid: 22 | conversion_rate_pct: 19.64%

-- Finding:
-- 19.64% of trial users convert to a paid plan. Industry benchmark is
-- 15-25%, so TaskFlow sits in the middle. With stronger in-trial
-- engagement this can be pushed above 25%.


-- ============================================================
-- Q5 — Feature Adoption Across the Platform
-- [VISUALIZE IN POWER BI — Bar Chart + Matrix Heatmap]
-- ============================================================

-- Total usage per feature
SELECT
    feature_name,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(usage_count) AS total_usage,
    CAST(SUM(usage_count) * 100.0 / SUM(SUM(usage_count)) OVER() AS DECIMAL(5,2)) AS usage_share_pct
FROM tf_feature_usage
GROUP BY feature_name
ORDER BY total_usage DESC

-- Results:
-- Task Management         578 users    14,265    19.14%
-- Kanban Board            502 users    12,192    16.36%
-- Calendar View           435 users    10,535    14.14%
-- Team Chat               446 users    10,416    13.98%
-- File Sharing            423 users    10,046    13.48%
-- Time Tracking           284 users     6,786     9.11%
-- Reporting & Analytics   220 users     5,372     7.21%
-- Integrations            209 users     4,904     6.58%

-- Feature usage by plan
SELECT
    [plan],
    feature_name,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(usage_count) AS total_usage
FROM tf_feature_usage
GROUP BY [plan], feature_name
ORDER BY [plan], total_usage DESC

-- Top 3 features per plan:
-- Trial:      Task Management (1,924) > Kanban Board (1,491) > Calendar View (1,062)
-- Starter:    Task Management (5,919) > Kanban Board (4,625) > Calendar View (4,100)
-- Growth:     Task Management (3,975) > Kanban Board (3,668) > File Sharing (3,659)
-- Enterprise: Task Management (2,447) > Kanban Board (2,408) > File Sharing (2,255)

-- Finding:
-- Task Management is the most used feature at 19.14% of all usage.
-- Kanban Board is second at 16.36%. Together they are the core product.
-- Integrations (6.58%) and Reporting & Analytics (7.21%) are the least
-- used — these are power features adopted mainly by paid plan users.
-- Trial users do not reach these features, missing key value moments.


-- ============================================================
-- Q6 — Session Duration and Frequency by Plan
-- [VISUALIZE IN POWER BI — Bar Charts + KPI Cards]
-- ============================================================

-- Session metrics by plan
SELECT
    [plan],
    COUNT(session_id) AS total_sessions,
    CAST(AVG(CAST(session_duration_mins AS DECIMAL(10,2))) AS DECIMAL(5,2)) AS avg_duration_mins,
    COUNT(DISTINCT user_id) AS unique_users,
    CAST(COUNT(session_id) * 1.0 / COUNT(DISTINCT user_id) AS DECIMAL(5,2)) AS avg_sessions_per_user
FROM tf_sessions
GROUP BY [plan]
ORDER BY avg_duration_mins DESC

-- Results:
-- Enterprise    3,958 sessions    55.24 mins avg    98 users    40.39 sessions/user
-- Growth        3,828 sessions    37.48 mins avg   171 users    22.39 sessions/user
-- Starter       2,904 sessions    27.57 mins avg   241 users    12.05 sessions/user
-- Trial           445 sessions    14.58 mins avg    90 users     4.94 sessions/user

-- Sessions by device
SELECT
    device,
    COUNT(session_id) AS total_sessions,
    CAST(COUNT(session_id) * 100.0 / SUM(COUNT(session_id)) OVER() AS DECIMAL(5,2)) AS pct
FROM tf_sessions
GROUP BY device
ORDER BY total_sessions DESC

-- Results:
-- Web             6,213    55.80%
-- Mobile          3,321    29.82%
-- Desktop App     1,601    14.38%

-- Finding:
-- Enterprise users spend 55.24 mins per session and log 40.39 sessions
-- per user — the most engaged segment by far. Trial users average only
-- 14.58 mins and 4.94 sessions, directly explaining the 46.67% Trial
-- churn rate. Mobile at 29.82% is a significant channel that warrants
-- investment in mobile feature parity.


-- ============================================================
-- Q7 — Total MRR and MRR by Plan
-- [VISUALIZE IN POWER BI — KPI Cards + Donut Chart]
-- ============================================================

-- Total MRR and ARPU
SELECT
    SUM(mrr) AS total_mrr,
    COUNT(user_id) AS paying_users,
    CAST(SUM(mrr) * 1.0 / COUNT(user_id) AS DECIMAL(10,2)) AS arpu
FROM tf_users
WHERE status = 'Active'
  AND mrr > 0

-- Results:
-- total_mrr: $31,320 | paying_users: 380 | arpu: $82.42

-- MRR by Plan
SELECT
    [plan],
    COUNT(user_id) AS active_users,
    SUM(mrr) AS plan_mrr,
    CAST(SUM(mrr) * 100.0 / SUM(SUM(mrr)) OVER() AS DECIMAL(5,2)) AS mrr_share_pct
FROM tf_users
WHERE status = 'Active'
  AND mrr > 0
GROUP BY [plan]
ORDER BY plan_mrr DESC

-- Results:
-- Enterprise     80 users    $15,920    50.83%
-- Growth        134 users    $10,586    33.80%
-- Starter       166 users     $4,814    15.37%

-- Finding:
-- Enterprise (80 paying users) generates 50.83% of all MRR at $15,920.
-- Starter has the most paying users (166) but only 15.37% of MRR.
-- ARPU of $82.42 across all paying users is healthy. Growing the
-- Enterprise segment is the fastest path to meaningful MRR growth.


-- ============================================================
-- Q8 — Users and MRR by Country
-- [VISUALIZE IN POWER BI — Bar Charts]
-- ============================================================

SELECT
    country,
    COUNT(user_id) AS total_users,
    SUM(mrr) AS total_mrr,
    CAST(SUM(mrr) * 1.0 / COUNT(user_id) AS DECIMAL(10,2)) AS avg_mrr_per_user
FROM tf_users
GROUP BY country
ORDER BY total_mrr DESC

-- Results:
-- United States     290 users    $15,681    $54.07 avg MRR/user
-- United Kingdom    100 users     $5,926    $59.26 avg MRR/user
-- Canada             99 users     $4,788    $48.36 avg MRR/user
-- Germany            65 users     $3,435    $52.85 avg MRR/user
-- Australia          46 users     $2,478    $53.87 avg MRR/user

-- Finding:
-- The US dominates in both users (290) and total MRR ($15,681).
-- The UK has the highest average MRR per user at $59.26, indicating
-- a stronger mix of Enterprise and Growth plans in that market.
-- Canada has the lowest average MRR per user at $48.36, pointing to
-- a higher concentration of Starter and Trial users.


-- ============================================================
-- BONUS — Support Ticket Analysis
-- [VISUALIZE IN POWER BI — Bar Chart]
-- ============================================================

SELECT
    category,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
    CAST(AVG(CASE WHEN resolution_days IS NOT NULL
        THEN CAST(resolution_days AS DECIMAL(10,2)) END) AS DECIMAL(5,2)) AS avg_resolution_days
FROM tf_support_tickets
GROUP BY category
ORDER BY total_tickets DESC

-- Results:
-- Feature Request    203    153 resolved    5.2 avg days
-- Onboarding         198    141 resolved    5.3 avg days
-- Bug Report         197    134 resolved    5.2 avg days
-- Performance        172    131 resolved    5.4 avg days
-- Billing            172    125 resolved    5.9 avg days

-- Finding:
-- Feature Request leads at 203 tickets — users are actively telling
-- TaskFlow what they need next. This is a direct product roadmap signal.
-- Onboarding is second at 198 tickets, confirming new user experience
-- has friction. Billing takes longest to resolve at 5.9 days — financial
-- queries left unresolved create churn risk.
