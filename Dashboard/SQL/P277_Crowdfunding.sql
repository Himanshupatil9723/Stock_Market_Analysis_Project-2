SELECT
  FROM_UNIXTIME(created_at) AS created_at_datetime
FROM projects;

SET SQL_SAFE_UPDATES = 0;

-- Epoch Time Conversion Of Created_At date

ALTER TABLE projects
ADD created_at_datetime DATETIME;

UPDATE projects
SET created_at_datetime = FROM_UNIXTIME(created_at);

select created_at_datetime from projects;

-- Epoch Time Conversion Of Launched_At date

ALTER TABLE projects
ADD launched_at_datetime DATETIME;

UPDATE projects
SET launched_at_datetime = FROM_UNIXTIME(launched_at);

select launched_at_datetime from projects;

-- Epoch Time Conversion Of Updated_At date

ALTER TABLE projects
ADD updated_at_datetime DATETIME;

UPDATE projects
SET updated_at_datetime = FROM_UNIXTIME(updated_at);

select updated_at_datetime from projects;

-- New Table For Calendar 

CREATE TABLE Calendar (
  ID INT PRIMARY KEY AUTO_INCREMENT,
  created_at_datetime DATE NOT NULL,
  Year INT NOT NULL,
  MonthNo INT NOT NULL,
  MonthFullName VARCHAR(255) NOT NULL,
  Quarter VARCHAR(5) NOT NULL,
  YearMonth VARCHAR(10) NOT NULL,
  WeekDayNo INT NOT NULL,
  WeekDayName VARCHAR(255) NOT NULL,
  FinancialMonth VARCHAR(5) NOT NULL,
  FinancialQuarter VARCHAR(5) NOT NULL
);

-- Populate the Calendar Table with data from the projects table

INSERT INTO Calendar (created_at_datetime, Year, MonthNo, MonthFullName, Quarter, YearMonth, WeekDayNo, WeekDayName, FinancialMonth, FinancialQuarter)
SELECT
    created_at_datetime,
    YEAR(created_at_datetime) AS Year,
    MONTH(created_at_datetime) AS MonthNo,
    MONTHNAME(created_at_datetime) AS MonthFullName,
    CONCAT('Q', CAST((MONTH(created_at_datetime) - 1) / 3 + 1 AS SIGNED)) AS Quarter,
    DATE_FORMAT(created_at_datetime, '%Y-%m') AS YearMonth,
    DAYOFWEEK(created_at_datetime) AS WeekDayNo,
    DAYNAME(created_at_datetime) AS WeekDayName,
    CASE 
        WHEN MONTH(created_at_datetime) IN (4, 5, 6) THEN CONCAT('FM', CAST(MONTH(created_at_datetime) - 3 AS SIGNED))
        WHEN MONTH(created_at_datetime) IN (7, 8, 9) THEN CONCAT('FM', CAST(MONTH(created_at_datetime) - 6 AS SIGNED))
        WHEN MONTH(created_at_datetime) IN (10, 11, 12) THEN CONCAT('FM', CAST(MONTH(created_at_datetime) - 9 AS SIGNED))
        ELSE CONCAT('FM', CAST(MONTH(created_at_datetime) + 3 AS SIGNED))
    END AS FinancialMonth,
    CONCAT('FQ', CAST((MONTH(created_at_datetime) - 1) / 3 + 1 AS SIGNED)) AS FinancialQuarter
FROM projects;

select * from Calendar;

select * from projects;

-- Adding Year, Month, Day in the same table projects : 
ALTER TABLE projects
ADD COLUMN project_year INT,
ADD COLUMN project_month INT,
ADD COLUMN project_day INT;

UPDATE projects
SET
    project_year = YEAR(created_at_datetime),
    project_month = MONTH(created_at_datetime),
    project_day = DAY(created_at_datetime);

-- Convert the Goal amount into USD using the Static USD Rate  
  
ALTER TABLE projects
ADD COLUMN goal_usd float;

UPDATE projects
SET goal_usd = goal * static_usd_rate;

select goal_usd from projects;

-- Projects Overview KPI :
     
-- 1. Total Number of Projects based on outcome 

select count(ProjectID) from projects;

-- 2. Total Number of Projects based on Locations

select count(ProjectID) as Total_Count, country from projects group by country;

-- 3. Total Number of Projects based on  Category

select count(ProjectID) as Total_Count, C.name from projects P join category C on P.category_id=C.id group by c.name;

-- 4. Total Number of Projects created by Year , Quarter , Month

-- Year Wise Project :
SELECT
    count(projectID),
    YEAR(created_at_datetime) AS ProjectYear
    FROM
    projects
GROUP BY ProjectYear;

-- Quaterwise project
SELECT
    count(projectID),
    CONCAT('Q', QUARTER(created_at_datetime)) AS ProjectQuarter
    FROM
    projects
GROUP BY
  ProjectQuarter;

-- Month & Yearwise Total Project :  
SELECT
    count(projectID),
    YEAR(created_at_datetime) AS ProjectYear,
    MONTH(created_at_datetime) AS ProjectMonth
FROM
    projects
GROUP BY
    ProjectYear,
    ProjectMonth
ORDER BY
	ProjectYear ASC;
    
-- Successful Projects

-- 1. Amount Raised 
select sum(pledged) from projects where state = "Successful";

-- 2. Number of Backers
select sum(backers_count) from projects where state = "Successful";

-- 3. Avg NUmber of Days for successful projects

SELECT
    AVG(DATEDIFF(FROM_UNIXTIME(successful_at), created_at_datetime)) AS AvgDaysForSuccessfulProjects
FROM
    projects
WHERE
    state = 'successful' AND successful_at IS NOT NULL;

-- Top Successful Projects

-- 1. Based on Number of Backers
select projectID,backers_count from projects where state="successful" order by backers_count desc limit 10;

-- 2. Based on Amount Raised.
select projectID,pledged from projects where state="successful" order by pledged desc limit 10;

-- Percentage of Successful Projects overall
SELECT
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS PercentageSuccessfulProjects,
    (COUNT(CASE WHEN state = 'failed' THEN 1 END) / COUNT(*)) * 100 AS PercentageFailedProjects
FROM
    projects;
    
-- Percentage of Successful Projects  by Category

SELECT
    c.name as category,
    (COUNT(CASE WHEN p.state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS PercentageSuccessfulProjects
FROM
    projects p join category c on
							p.category_id = c.id
GROUP BY
    c.name
ORDER BY
	PercentageSuccessfulProjects desc;
    
-- Percentage of Successful Projects by Year , Month etc

SELECT
    YEAR(created_at_datetime) AS ProjectYear,
    MONTH(created_at_datetime) AS ProjectMonth,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS PercentageSuccessfulProjects
FROM
    projects
GROUP BY
    ProjectYear, ProjectMonth
ORDER BY
    ProjectYear, ProjectMonth;
    
-- Percentage of Successful projects by Goal Range ( decide the range as per your need )

SELECT
    GoalRange,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*)) * 100 AS PercentageSuccessfulProjects
FROM (
    SELECT
        CASE
            WHEN goal >= 0 AND goal < 1000 THEN '0-999'
            WHEN goal >= 1000 AND goal < 5000 THEN '1000-4999'
            WHEN goal >= 5000 AND goal < 10000 THEN '5000-9999'
            -- Add more ranges as needed
            ELSE 'Others'
        END AS GoalRange,
        state
    FROM
        projects
) AS GoalRanges
GROUP BY
    GoalRange
ORDER BY
    GoalRange;