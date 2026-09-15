show databases;
create database Date10092026;
use Date10092026;
show schemas;

/*--------TABLE UserLogins -------*/
CREATE TABLE UserLogins (user_id INTEGER, login_date TEXT);
INSERT INTO UserLogins VALUES
(1,'2024-03-01'),(1,'2024-03-02'),(1,'2024-03-03'),(1,'2024-03-05'),(1,'2024-03-06'),
(2,'2024-03-01'),(2,'2024-03-02'),(2,'2024-03-03'),(2,'2024-03-04'),(2,'2024-03-05'),
(2,'2024-03-09'),(3,'2024-03-04'),(4,'2024-03-01'),(4,'2024-03-03'),(4,'2024-03-05'),
(4,'2024-03-07');

select * from UserLogins;

/*--------TABLE Employees -------*/
CREATE TABLE Employees (
  emp_id INTEGER PRIMARY KEY, name TEXT, department TEXT,
  salary INTEGER, manager_id INTEGER
);
INSERT INTO Employees VALUES
(1,'Arjun','Sales',120000,NULL),
(2,'Priya','Sales',110000,1),
(3,'Rahul','Sales',110000,1),
(4,'Kiran','Sales',95000,2),
(5,'Divya','Sales',80000,2),
(6,'Sneha','Engineering',150000,NULL),
(7,'Vikram','Engineering',140000,6),
(8,'Meera','Engineering',130000,6),
(9,'Ravi','Engineering',130000,7),
(10,'Tara','Engineering',100000,7),
(11,'Aman','Marketing',90000,NULL),
(12,'Zoya','Marketing',85000,11),
(13,'Farhan','Marketing',75000,11),
(14,'Nikita','Marketing',70000,12),
-- circular chain for Q7: 15 -> 16 -> 15
(15,'Loop A','Ops',60000,16),
(16,'Loop B','Ops',60000,15);

select * from Employees;

/*--------TABLE Clickstream -------*/
CREATE TABLE Clickstream (user_id INTEGER, event_time TEXT);
INSERT INTO Clickstream VALUES
(1,'2024-05-01 09:00:00'),(1,'2024-05-01 09:05:00'),(1,'2024-05-01 09:20:00'),
(1,'2024-05-01 10:15:00'),(1,'2024-05-01 10:25:00'),(1,'2024-05-01 14:00:00'),
(2,'2024-05-01 11:00:00'),(2,'2024-05-01 11:10:00'),(2,'2024-05-01 11:35:00'),
(2,'2024-05-01 13:00:00'),(3,'2024-05-01 08:00:00');

select * from Clickstream;

/*--------TABLE Scores -------*/
CREATE TABLE Scores (student_id INTEGER, subject TEXT, score INTEGER);
INSERT INTO Scores VALUES
(1,'Math',88),(1,'Science',92),(1,'English',75),
(2,'Math',67),(2,'Science',80),
(3,'Math',95),(3,'English',89),
(4,'Science',70),(4,'English',65);

select * from Scores;

/*--------TABLE Contacts -------*/
CREATE TABLE Contacts (id INTEGER PRIMARY KEY, email TEXT, created_at TEXT);
INSERT INTO Contacts VALUES
(1,'a@x.com','2024-01-05 10:00:00'),
(2,'b@x.com','2024-01-06 09:00:00'),
(3,'a@x.com','2024-02-11 12:30:00'),
(4,'c@x.com','2024-01-07 08:15:00'),
(5,'a@x.com','2024-03-02 16:45:00'),
(6,'b@x.com','2024-02-20 11:20:00'),
(7,'d@x.com','2024-01-09 07:00:00');

select * from Scores;

/*--------TABLE DailySales -------*/
CREATE TABLE DailySales (sale_date TEXT, sales INTEGER);
INSERT INTO DailySales VALUES
('2024-04-01',100),
('2024-04-02',300),
('2024-04-03',200),
('2024-04-04',500),
('2024-04-05',400),
('2024-04-06',700),
('2024-04-07',600);

select * from DailySales;

/*--------TABLE Transactions -------*/
CREATE TABLE Transactions (
  txn_id INTEGER PRIMARY KEY, account_id INTEGER,
  txn_time TEXT, amount REAL
);
INSERT INTO Transactions VALUES
(1,101,'2024-06-01 10:00:00',1000.00),
(2,101,'2024-06-01 10:00:30',1005.00),   -- pair with 1: 30s, 0.5% diff
(3,101,'2024-06-01 10:05:00',1000.00),   -- too far in time
(4,102,'2024-06-01 12:00:00',500.00),
(5,102,'2024-06-01 12:00:45',700.00),    -- within 60s but 40% diff
(6,103,'2024-06-01 14:00:00',2000.00),
(7,103,'2024-06-01 14:00:20',2010.00),   -- pair with 6: 20s, 0.5% diff
(8,103,'2024-06-01 14:00:50',2015.00);   -- pairs with 7 (30s, 0.25%) and 6 (50s, 0.75%)

select * from Transactions;

show tables;

/*Q1 — Gaps and Islands
Given a table of (user_id, login_date), find the longest streak of consecutive days each user was active. 
Return user_id, streak start date, streak end date, and streak length. 
-- Q1: Longest consecutive login streak for each user */
WITH LoginData AS
(
    SELECT
        user_id,
        STR_TO_DATE(login_date, '%Y-%m-%d') AS login_date
    FROM UserLogins
),
NumberedLogins AS
(
    SELECT
        user_id,
        login_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY login_date
        ) AS row_num
    FROM LoginData
),
Islands AS
(
    SELECT
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL row_num DAY) AS group_date
    FROM NumberedLogins
),
Streaks AS
(
    SELECT
        user_id,
        MIN(login_date) AS streak_start_date,
        MAX(login_date) AS streak_end_date,
        COUNT(*) AS streak_length
    FROM Islands
    GROUP BY user_id, group_date
),
RankedStreaks AS
(
    SELECT
        user_id,
        streak_start_date,
        streak_end_date,
        streak_length,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY streak_length DESC, streak_start_date
        ) AS rn
    FROM Streaks
)
SELECT
    user_id,
    streak_start_date,
    streak_end_date,
    streak_length
FROM RankedStreaks
WHERE rn = 1
ORDER BY user_id;

/*Q2 — Nth Highest Per Group
Find the 3rd highest salary in each department using only window functions. 
Do not use LIMIT, TOP, or a correlated subquery with LIMIT. 
Handle tied salaries correctly and explain in a comment which ranking function you chose and why.*/
WITH RankedEmployees AS
(
    SELECT
        emp_id,
        name,
        department,
        salary,

              DENSE_RANK() OVER
        (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_rank

    FROM Employees
)

SELECT
    emp_id,
    name,
    department,
    salary
FROM RankedEmployees
WHERE salary_rank = 3
ORDER BY department, emp_id;

/*Q3 — Session Reconstruction
Given a clickstream table (user_id, event_time), group events into sessions 
where a new session begins after 30 or more minutes of inactivity. 
Return session start, session end, and duration for each user session.*/
WITH EventData AS
(
    SELECT
        user_id,
        STR_TO_DATE(event_time, '%Y-%m-%d %H:%i:%s') AS event_time
    FROM Clickstream
),
PreviousEvents AS
(
    SELECT
        user_id,
        event_time,
        LAG(event_time) OVER
        (
            PARTITION BY user_id
            ORDER BY event_time
        ) AS previous_event_time
    FROM EventData
),
SessionStarts AS
(
    SELECT
        user_id,
        event_time,
        CASE
            WHEN previous_event_time IS NULL THEN 1
            WHEN TIMESTAMPDIFF(MINUTE, previous_event_time, event_time) >= 30 THEN 1
            ELSE 0
        END AS new_session
    FROM PreviousEvents
),
SessionNumbers AS
(
    SELECT
        user_id,
        event_time,
        SUM(new_session) OVER
        (
            PARTITION BY user_id
            ORDER BY event_time
        ) AS session_id
    FROM SessionStarts
)
SELECT
    user_id,
    MIN(event_time) AS session_start,
    MAX(event_time) AS session_end,
    TIMEDIFF(MAX(event_time), MIN(event_time)) AS duration
FROM SessionNumbers
GROUP BY user_id, session_id
ORDER BY user_id, session_start;

/*Q4 — Pivoting Without PIVOT
Transform a table of (student_id, subject, score) into one row per student with a column per subject,
 using only CASE and GROUP BY. Do not use the PIVOT operator. 
 Ensure students missing a subject show 0 rather than NULL.*/
SELECT
    student_id,

    COALESCE(
        MAX(CASE
            WHEN subject = 'Math' THEN score
        END), 0
    ) AS Math,

    COALESCE(
        MAX(CASE
            WHEN subject = 'Science' THEN score
        END), 0
    ) AS Science,

    COALESCE(
        MAX(CASE
            WHEN subject = 'English' THEN score
        END), 0
    ) AS English

FROM Scores
GROUP BY student_id
ORDER BY student_id;

/*Q5 — Deduplicate Keeping Latest
Given a table with duplicate email rows and a created_at timestamp, 
delete all but the most recent row per email. 
Write this as a single DELETE statement — no temporary tables, no multiple steps.*/
DELETE FROM Contacts
WHERE id IN
(
    SELECT id
    FROM
    (
        SELECT
            id,
            ROW_NUMBER() OVER
            (
                PARTITION BY email
                ORDER BY created_at DESC, id DESC
            ) AS row_num
        FROM Contacts
    ) AS RankedContacts
    WHERE row_num > 1
);

/*Q6 — Running Median
Compute the running median of a sales column ordered by date, 
without using any built-in median or percentile function.*/
WITH SalesData AS
(
    SELECT
        STR_TO_DATE(sale_date, '%Y-%m-%d') AS sale_date,
        sales
    FROM DailySales
),
RunningData AS
(
    SELECT
        d1.sale_date,
        d2.sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY d1.sale_date
            ORDER BY d2.sales
        ) AS row_num,

        COUNT(*) OVER
        (
            PARTITION BY d1.sale_date
        ) AS total_count

    FROM SalesData d1
    JOIN SalesData d2
        ON d2.sale_date <= d1.sale_date
)
SELECT
    sale_date,
    AVG(sales) AS running_median
FROM RunningData
WHERE row_num IN
(
    FLOOR((total_count + 1) / 2),
    CEIL((total_count + 1) / 2)
)
GROUP BY sale_date
ORDER BY sale_date;

/*Q7 — Recursive Hierarchy
Given an employees table with emp_id, manager_id, 
write a recursive CTE returning the total number of direct and indirect reports for every manager. 
Flag any circular reporting chains.*/
WITH RECURSIVE EmployeeHierarchy AS
(
    -- Start with every employee
    SELECT
        emp_id AS manager_id,
        emp_id AS report_id,
        CAST(emp_id AS CHAR(1000)) AS employee_path,
        0 AS is_cycle
    FROM Employees

    UNION ALL

      SELECT
        h.manager_id,
        e.emp_id AS report_id,

        CONCAT(
            h.employee_path,
            ',',
            e.emp_id
        ) AS employee_path,

        CASE
            WHEN FIND_IN_SET(
                CAST(e.emp_id AS CHAR),
                h.employee_path
            ) > 0
            THEN 1
            ELSE 0
        END AS is_cycle

    FROM EmployeeHierarchy h
    JOIN Employees e
        ON e.manager_id = h.report_id

    WHERE h.is_cycle = 0
),
ReportSummary AS
(
    SELECT
        manager_id,

        COUNT(
            DISTINCT CASE
                WHEN report_id <> manager_id
                THEN report_id
            END
        ) AS total_reports,

        MAX(is_cycle) AS has_cycle

    FROM EmployeeHierarchy
    GROUP BY manager_id
)
SELECT
    e.emp_id AS manager_id,
    e.name AS manager_name,
    COALESCE(r.total_reports, 0) AS total_reports,

    CASE
        WHEN COALESCE(r.has_cycle, 0) = 1
        THEN 'YES'
        ELSE 'NO'
    END AS circular_reporting

FROM Employees e
LEFT JOIN ReportSummary r
    ON e.emp_id = r.manager_id

WHERE EXISTS
(
    SELECT 1
    FROM Employees x
    WHERE x.manager_id = e.emp_id
)

ORDER BY e.emp_id;

/*Q8 — Self-Join Anomaly Detection
Find all pairs of transactions on the same account occurring within 60 seconds of each other 
where the amounts differ by less than 1%. Your solution must avoid a Cartesian blow-up on large tables
 — explain your approach in a comment.*/
SELECT
    t1.txn_id AS txn_id_1,
    t2.txn_id AS txn_id_2,
    t1.account_id,
    t1.txn_time AS txn_time_1,
    t2.txn_time AS txn_time_2,
    t1.amount AS amount_1,
    t2.amount AS amount_2,

    ROUND(
        ABS(t1.amount - t2.amount) / t1.amount * 100,
        2
    ) AS amount_difference_percent

FROM Transactions t1
JOIN Transactions t2
    ON t1.account_id = t2.account_id
    AND t2.txn_time > t1.txn_time
    AND t2.txn_time <= DATE_ADD(
        t1.txn_time,
        INTERVAL 60 SECOND
    )
    
WHERE ABS(t1.amount - t2.amount) / t1.amount < 0.01

ORDER BY t1.account_id, t1.txn_id, t2.txn_id;







