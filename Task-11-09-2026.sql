show databases;
create database Date11092026;
use Date11092026;
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

show databases;

use date11092026;

/*Q9 — Median Without a Percentile Function
Find the median salary for each department without using PERCENTILE_CONT, MEDIAN, or 
any built-in percentile function. Your solution must handle both odd and even row counts correctly.*/
WITH RankedSalaries AS
(
    SELECT
        department,
        salary,

        ROW_NUMBER() OVER
        (
            PARTITION BY department
            ORDER BY salary
        ) AS row_num,

        COUNT(*) OVER
        (
            PARTITION BY department
        ) AS total_count

    FROM Employees
)

SELECT
    department,
    AVG(salary) AS median_salary
FROM RankedSalaries
WHERE row_num IN
(
    FLOOR((total_count + 1) / 2),
    CEIL((total_count + 1) / 2)
)
GROUP BY department
ORDER BY department;

/*Q10 — Share of Total and Running Total
For the Sales department, return each employee's name, salary, 
their salary as a percentage of the department total, and a running total of salaries ordered from highest to lowest. 
Use window functions only. */
SELECT
    name,
    salary,

    -- Salary as a percentage of total Sales department salary
    ROUND(
        salary / SUM(salary) OVER () * 100,
        2
    ) AS salary_percentage,

    -- Running total from highest salary to lowest
    SUM(salary) OVER (
        ORDER BY salary DESC, emp_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total

FROM Employees

WHERE department = 'Sales'

ORDER BY salary DESC, emp_id;

/*Q11 — Above Department Average
Find all employees earning more than the average salary of their own department. 
Return department, name and salary. Do not use a correlated subquery. */
WITH EmployeeAverages AS
(
    SELECT
        department,
        name,
        salary,

        AVG(salary) OVER
        (
            PARTITION BY department
        ) AS department_average

    FROM Employees
)

SELECT
    department,
    name,
    salary

FROM EmployeeAverages

WHERE salary > department_average

ORDER BY department, salary DESC;

/*Q12 — First and Last Activity
For each user in the logins table, return their first login date, last login date, 
the number of calendar days between the two, and the number of days they were actually active. 
Explain in a comment why the last two numbers differ. */
WITH LoginData AS
(
    SELECT
        user_id,
        STR_TO_DATE(login_date, '%Y-%m-%d') AS login_date
    FROM UserLogins
)

SELECT
    user_id,

    MIN(login_date) AS first_login_date,

    MAX(login_date) AS last_login_date,

    DATEDIFF(
        MAX(login_date),
        MIN(login_date)
    ) AS calendar_days_between,

    COUNT(DISTINCT login_date) AS active_days

FROM LoginData

GROUP BY user_id

ORDER BY user_id;


/*Q13 — Find the Gaps
For each user, identify every gap in their login history — return the date before the gap, 
the date after it, and how many days were missed.*/
WITH LoginData AS
(
    SELECT DISTINCT
        user_id,
        STR_TO_DATE(login_date, '%Y-%m-%d') AS login_date
    FROM UserLogins
),

PreviousLogins AS
(
    SELECT
        user_id,
        login_date,

        LAG(login_date) OVER
        (
            PARTITION BY user_id
            ORDER BY login_date
        ) AS previous_login_date

    FROM LoginData
)

SELECT
    user_id,

    previous_login_date AS date_before_gap,

    login_date AS date_after_gap,

    DATEDIFF(
        login_date,
        previous_login_date
    ) - 1 AS days_missed

FROM PreviousLogins

WHERE DATEDIFF(
          login_date,
          previous_login_date
      ) > 1

ORDER BY user_id, date_before_gap;

/*Q14 — Second Highest, No Window Functions
Find the second-highest distinct salary across all employees, without using any window function, LIMIT, or OFFSET. */
SELECT MAX(salary) AS second_highest_salary
FROM Employees
WHERE salary < (
    SELECT MAX(salary)
    FROM Employees
);



