-- Hacker News Retention Analysis

-- 1. Monthly New User Cohorts
WITH cohorts AS (
    SELECT
        user_id,
        MIN(DATE_TRUNC('month', signup_date)) AS cohort_month
    FROM users
    GROUP BY user_id
)
SELECT cohort_month, COUNT(*) AS new_users
FROM cohorts
GROUP BY cohort_month
ORDER BY cohort_month;

-- 2. Returning Users per Cohort
WITH cohorts AS (
    SELECT
        user_id,
        MIN(DATE_TRUNC('month', signup_date)) AS cohort_month
    FROM users
    GROUP BY user_id
),
activity AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', activity_date) AS active_month
    FROM user_activity
    GROUP BY user_id, active_month
)
SELECT 
    c.cohort_month,
    a.active_month,
    COUNT(DISTINCT a.user_id) AS active_users
FROM cohorts c
JOIN activity a ON c.user_id = a.user_id
GROUP BY c.cohort_month, a.active_month
ORDER BY c.cohort_month, a.active_month;

-- 3. Retention Rate Calculation
WITH cohorts AS (
    SELECT
        user_id,
        MIN(DATE_TRUNC('month', signup_date)) AS cohort_month
    FROM users
    GROUP BY user_id
),
activity AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', activity_date) AS active_month
    FROM user_activity
)
SELECT 
    c.cohort_month,
    a.active_month,
    COUNT(DISTINCT a.user_id)::decimal / COUNT(DISTINCT CASE WHEN a.active_month = c.cohort_month THEN a.user_id END) OVER (PARTITION BY c.cohort_month) AS retention_rate
FROM cohorts c
JOIN activity a ON c.user_id = a.user_id
ORDER BY c.cohort_month, a.active_month;
