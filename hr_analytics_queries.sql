-- ============================================================
--  HR ANALYTICS - SQL PROJECT
--  Author: [Your Name]
--  Tool:   Microsoft SQL Server Management Studio (SSMS)
--  Data:   Imported from CSV / Excel files
-- ============================================================
--  Data was imported directly into SSMS from the source CSV
--  and Excel files. No tables were manually created.
--
--  CONTENTS:
--  Part 1 - Data Cleaning
--  Part 2 - Data Analysis
-- ============================================================


-- ============================================================
-- PART 1: DATA CLEANING
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Preview the raw data
-- ------------------------------------------------------------

SELECT TOP 10 *
FROM hr_analytics;


-- ------------------------------------------------------------
-- 1.2 Check for duplicate records
-- ------------------------------------------------------------

SELECT
    EmployeeNumber,
    COUNT(*) AS occurrences
FROM hr_analytics
GROUP BY EmployeeNumber
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- 1.3 Check for NULL values across key columns
-- ------------------------------------------------------------

SELECT
    SUM(CASE WHEN EmployeeNumber    IS NULL THEN 1 ELSE 0 END) AS null_employee_number,
    SUM(CASE WHEN Age               IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Department        IS NULL THEN 1 ELSE 0 END) AS null_department,
    SUM(CASE WHEN JobRole           IS NULL THEN 1 ELSE 0 END) AS null_job_role,
    SUM(CASE WHEN Gender            IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN Attrition         IS NULL THEN 1 ELSE 0 END) AS null_attrition,
    SUM(CASE WHEN MonthlyIncome     IS NULL THEN 1 ELSE 0 END) AS null_monthly_income,
    SUM(CASE WHEN JobSatisfaction   IS NULL THEN 1 ELSE 0 END) AS null_job_satisfaction,
    SUM(CASE WHEN PerformanceRating IS NULL THEN 1 ELSE 0 END) AS null_performance_rating,
    SUM(CASE WHEN YearsAtCompany    IS NULL THEN 1 ELSE 0 END) AS null_years_at_company
FROM hr_analytics;


-- ------------------------------------------------------------
-- 1.4 Check for blank (empty string) values
-- ------------------------------------------------------------

SELECT COUNT(*) AS blank_department FROM hr_analytics WHERE Department = '' OR Department IS NULL;
SELECT COUNT(*) AS blank_gender     FROM hr_analytics WHERE Gender     = '' OR Gender     IS NULL;
SELECT COUNT(*) AS blank_job_role   FROM hr_analytics WHERE JobRole    = '' OR JobRole    IS NULL;


-- ------------------------------------------------------------
-- 1.5 Remove duplicate rows
-- Keep the first occurrence of each EmployeeNumber
-- ------------------------------------------------------------

WITH cte_duplicates AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeNumber
            ORDER BY EmployeeNumber
        ) AS row_num
    FROM hr_analytics
)
DELETE FROM cte_duplicates
WHERE row_num > 1;


-- ------------------------------------------------------------
-- 1.6 Trim whitespace from text columns
-- ------------------------------------------------------------

UPDATE hr_analytics SET Department     = LTRIM(RTRIM(Department));
UPDATE hr_analytics SET JobRole        = LTRIM(RTRIM(JobRole));
UPDATE hr_analytics SET Gender         = LTRIM(RTRIM(Gender));
UPDATE hr_analytics SET Attrition      = LTRIM(RTRIM(Attrition));
UPDATE hr_analytics SET OverTime       = LTRIM(RTRIM(OverTime));
UPDATE hr_analytics SET MaritalStatus  = LTRIM(RTRIM(MaritalStatus));
UPDATE hr_analytics SET BusinessTravel = LTRIM(RTRIM(BusinessTravel));


-- ------------------------------------------------------------
-- 1.7 Standardise text casing
-- ------------------------------------------------------------

-- Check current distinct values before updating
SELECT DISTINCT Gender    FROM hr_analytics;
SELECT DISTINCT Attrition FROM hr_analytics;
SELECT DISTINCT OverTime  FROM hr_analytics;

-- Standardise to proper casing
UPDATE hr_analytics SET Gender    = 'Male'   WHERE LOWER(Gender)    = 'male';
UPDATE hr_analytics SET Gender    = 'Female' WHERE LOWER(Gender)    = 'female';
UPDATE hr_analytics SET Attrition = 'Yes'    WHERE LOWER(Attrition) = 'yes';
UPDATE hr_analytics SET Attrition = 'No'     WHERE LOWER(Attrition) = 'no';
UPDATE hr_analytics SET OverTime  = 'Yes'    WHERE LOWER(OverTime)  = 'yes';
UPDATE hr_analytics SET OverTime  = 'No'     WHERE LOWER(OverTime)  = 'no';


-- ------------------------------------------------------------
-- 1.8 Validate numeric ranges
-- ------------------------------------------------------------

-- Age should be between 18 and 65
SELECT COUNT(*) AS invalid_age
FROM hr_analytics
WHERE Age < 18 OR Age > 65;

-- Monthly income should be greater than 0
SELECT COUNT(*) AS invalid_income
FROM hr_analytics
WHERE MonthlyIncome <= 0;

-- Satisfaction scores should be between 1 and 4
SELECT COUNT(*) AS invalid_job_satisfaction
FROM hr_analytics
WHERE JobSatisfaction < 1 OR JobSatisfaction > 4;

-- Years at company cannot be more than total working years
SELECT COUNT(*) AS invalid_tenure
FROM hr_analytics
WHERE YearsAtCompany > TotalWorkingYears;


-- ------------------------------------------------------------
-- 1.9 Validate categorical values
-- ------------------------------------------------------------

SELECT COUNT(*) AS invalid_attrition
FROM hr_analytics
WHERE Attrition NOT IN ('Yes', 'No');

SELECT COUNT(*) AS invalid_gender
FROM hr_analytics
WHERE Gender NOT IN ('Male', 'Female');

SELECT COUNT(*) AS invalid_overtime
FROM hr_analytics
WHERE OverTime NOT IN ('Yes', 'No');

SELECT COUNT(*) AS invalid_marital_status
FROM hr_analytics
WHERE MaritalStatus NOT IN ('Single', 'Married', 'Divorced');


-- ============================================================
-- PART 2: DATA ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Overview
-- ------------------------------------------------------------

-- Total employees
SELECT COUNT(*) AS total_employees
FROM hr_analytics;

-- Employees by department
SELECT
    Department,
    COUNT(*) AS employee_count
FROM hr_analytics
GROUP BY Department
ORDER BY employee_count DESC;

-- Employees by job role
SELECT
    JobRole,
    COUNT(*) AS employee_count
FROM hr_analytics
GROUP BY JobRole
ORDER BY employee_count DESC;

-- Gender breakdown
SELECT
    Gender,
    COUNT(*) AS employee_count
FROM hr_analytics
GROUP BY Gender;


-- ------------------------------------------------------------
-- 2.2 Attrition Analysis
-- ------------------------------------------------------------

-- Overall attrition rate
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_analytics;

-- Attrition by department
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM hr_analytics
GROUP BY Department
ORDER BY employees_left DESC;

-- Attrition by job role
SELECT
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM hr_analytics
GROUP BY JobRole
ORDER BY employees_left DESC;

-- Attrition by overtime status
SELECT
    OverTime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM hr_analytics
GROUP BY OverTime;

-- Attrition by job satisfaction
SELECT
    JobSatisfaction,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
FROM hr_analytics
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;


-- ------------------------------------------------------------
-- 2.3 Salary & Compensation
-- ------------------------------------------------------------

-- Average, min, max income
SELECT
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 2) AS avg_income,
    MIN(MonthlyIncome) AS min_income,
    MAX(MonthlyIncome) AS max_income
FROM hr_analytics;

-- Average income by department
SELECT
    Department,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 2) AS avg_income
FROM hr_analytics
GROUP BY Department
ORDER BY avg_income DESC;

-- Average income by job role
SELECT
    JobRole,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 2) AS avg_income
FROM hr_analytics
GROUP BY JobRole
ORDER BY avg_income DESC;

-- Average income: left vs stayed
SELECT
    Attrition,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 2) AS avg_income
FROM hr_analytics
GROUP BY Attrition;

-- Top 10 highest paid employees
SELECT TOP 10
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome
FROM hr_analytics
ORDER BY MonthlyIncome DESC;


-- ------------------------------------------------------------
-- 2.4 Performance & Satisfaction
-- ------------------------------------------------------------

-- Performance rating distribution
SELECT
    PerformanceRating,
    COUNT(*) AS employee_count
FROM hr_analytics
GROUP BY PerformanceRating
ORDER BY PerformanceRating;

-- Average satisfaction scores by department
SELECT
    Department,
    ROUND(AVG(CAST(JobSatisfaction         AS FLOAT)), 2) AS avg_job_satisfaction,
    ROUND(AVG(CAST(EnvironmentSatisfaction  AS FLOAT)), 2) AS avg_env_satisfaction,
    ROUND(AVG(CAST(WorkLifeBalance          AS FLOAT)), 2) AS avg_work_life_balance
FROM hr_analytics
GROUP BY Department
ORDER BY avg_job_satisfaction DESC;

-- High performers who still left
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    PerformanceRating,
    MonthlyIncome,
    YearsAtCompany
FROM hr_analytics
WHERE PerformanceRating >= 3
  AND Attrition = 'Yes'
ORDER BY PerformanceRating DESC;

-- Employees on overtime with poor work-life balance
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    OverTime,
    WorkLifeBalance,
    Attrition
FROM hr_analytics
WHERE OverTime = 'Yes'
  AND WorkLifeBalance = 1
ORDER BY Department;


-- ------------------------------------------------------------
-- 2.5 Tenure & Promotion
-- ------------------------------------------------------------

-- Employees not promoted in 5+ years
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    YearsAtCompany,
    YearsSinceLastPromotion,
    PerformanceRating
FROM hr_analytics
WHERE YearsSinceLastPromotion >= 5
  AND Attrition = 'No'
ORDER BY YearsSinceLastPromotion DESC;

-- Employees eligible for promotion
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    PerformanceRating,
    YearsInCurrentRole,
    YearsSinceLastPromotion
FROM hr_analytics
WHERE PerformanceRating >= 3
  AND YearsInCurrentRole >= 4
  AND Attrition = 'No'
ORDER BY YearsInCurrentRole DESC;

-- New joiners (0-2 years) who already left
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    YearsAtCompany,
    JobSatisfaction,
    MonthlyIncome
FROM hr_analytics
WHERE YearsAtCompany <= 2
  AND Attrition = 'Yes'
ORDER BY YearsAtCompany ASC;


-- ------------------------------------------------------------
-- 2.6 Subqueries & HAVING
-- ------------------------------------------------------------

-- Employees earning above the company average
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome
FROM hr_analytics
WHERE MonthlyIncome > (SELECT AVG(CAST(MonthlyIncome AS FLOAT)) FROM hr_analytics)
ORDER BY MonthlyIncome DESC;

-- Departments with more than 50 employees
SELECT
    Department,
    COUNT(*) AS employee_count
FROM hr_analytics
GROUP BY Department
HAVING COUNT(*) > 50
ORDER BY employee_count DESC;

-- Departments where more than 30 employees left
SELECT
    Department,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count
FROM hr_analytics
GROUP BY Department
HAVING SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) > 30
ORDER BY attrition_count DESC;
