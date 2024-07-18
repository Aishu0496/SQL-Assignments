/* Q1 Given two tables below, write a query to display the comparison result (higher/lower/same)
of the average salary of employees in a department to the company’s average salary. */

CREATE TABLE salary (
	id INTEGER,
	employee_id INTEGER,
	amount INTEGER,
	pay_date TIMESTAMP
)

INSERT INTO salary
VALUES
(1,1,9000,'2017-03-31'),
(2,2,6000,'2017-03-31'),
(3,3,10000,'2017-03-31'),
(4,1,7000,'2017-02-28'),
(5,2,6000,'2017-02-28'),
(6,3,8000,'2017-02-28')

CREATE TABLE dept(
	employee_id INTEGER,
	department_id INTEGER
)

INSERT INTO dept
VALUES
(1,1),
(2,2),
(3,2)

SELECT * FROM salary
SELECT * FROM dept

create temporary table t1 AS
(
	SELECT TO_CHAR(pay_date,'YYYY-MM') as pay_month,department_id,
	AVG(amount) OVER(PARTITION BY DATE_PART('month',pay_date),department_id) as dept_avg,
	AVG(amount) OVER(PARTITION BY DATE_PART('month',pay_date)) as comp_avg
	FROM salary as s JOIN dept as d
	USING (employee_id)
)
select * from t1

SELECT DISTINCT pay_month,department_id,
     CASE WHEN dept_avg > comp_avg THEN 'higher'
     WHEN dept_avg = comp_avg THEN 'same'
     ELSE 'lower'
     END as comparison 

FROM t1
ORDER BY pay_month DESC

/* Q2  Write an SQL query to report the students (student_id, student_name) being “quiet” in ALL exams.
A “quiet” student is the one who took at least one exam and didn’t score neither the high 
score nor the low score. */

CREATE TABLE student(
	student_id INTEGER,
	student_name VARCHAr(100)
)

INSERT INTO student
VALUES
(1,'Daniel'),
(2,'Jade'),
(3,'Stella'),
(4,'Jonathan'),
(5,'Will')

CREATE TABLE exam(
	exam_id INTEGER,
	student_id INTEGER,
	score INTEGER
)

INSERT INTO exam
VALUES
(10,1,70),
(10,2,80),
(10,3,90),
(20,1,80),
(30,1,70),
(30,3,80),
(30,4,90),
(40,1,60),
(40,2,70),
(40,4,80)

SELECT * FROM student
SELECT * FROM exam

create temporary table t2 AS(
	SELECT student_id
	FROM(
	     SELECT *,
	            MIN(score) OVER main_window as least,
	            MAX(score) OVER main_window as most
	      FROM exam
	     WINDOW main_window as (PARTITION BY exam_id)
	    ) as a
  where least = score or most = score  
)

select * from t2

SELECT DISTINCT student_id,
               student_name
FROM exam join student
USING (student_id)
WHERE student_id != ALL(SELECT student_id FROM t2)
ORDER BY student_id

/* Q3 Write a query to display the records which have 3 or
more consecutive rows and the number of people more than 100(inclusive).*/

CREATE TABLE stadium(
	id INTEGER,
	visit_date TIMESTAMP,
	people INTEGER
)

INSERT INTO stadium
VALUES
(1,'2017-01-01',10),
(2,'2017-01-02',109),
(3,'2017-01-03',150),
(4,'2017-01-04',99),
(5,'2017-01-05',145),
(6,'2017-01-06',1455),
(7,'2017-01-07',199),
(8,'2017-01-08',188)

Create temporary table t3 As (
	   Select id,visit_date,people,
	   id - ROW_NUMBER()OVER() AS dates
	  FROM stadium
	 WHERE people >= 100)

SELECT * FROM t3

SELECT t3.id,
    t3.visit_date,
t3.people
FROM t3
LEFT JOIN(
	SELECT dates,
	  COUNT(*) as total
	FROM t3
	GROUP BY dates) AS b
ON b.dates = t3.dates
WHERE b.total >2

/* Q4 Write an SQL query to find how many users visited the bank and didn’t do any transactions, 
how many visited the bank and did one transaction and so on. */

CREATE TABLE Visits(
	user_id INTEGER,
	visit_date TIMESTAMP
)

INSERT INTO Visits
VALUES
(1,'2020-01-01'),
(2,'2020-01-02'),
(12,'2020-01-01'),
(19,'2020-01-03'),
(1,'2020-01-02'),
(2,'2020-01-03'),
(1,'2020-01-04'),
(7,'2020-01-11'),
(9,'2020-01-25'),
(8,'2020-01-28')

CREATE TABLE Transactions(
	user_id INTEGER,
	transaction_date TIMESTAMP,
	amount INTEGER
)

INSERT INTO Transactions
VALUES
(1,'2020-01-02',120),
(2,'2020-01-03',22),
(7,'2020-01-11',232),
(1,'2020-01-04',7),
(9,'2020-01-25',33),
(9,'2020-01-25',66),
(8,'2020-01-28',1),
(9,'2020-01-25',99)

SELECT * FROM Visits AS v;
SELECT * FROM Transactions AS t;

with recursive
    a as (
        select v.user_id, v.visit_date, count(amount) trans_counts
        from Visits v
        left join Transactions t
        on v.user_id = t.user_id and v.visit_date = t.transaction_date
        group by v.user_id, v.visit_date),
    b as (
        select 0 as transactions_count
        union all
        select transactions_count + 1 
        from b 
        where transactions_count <
            (select max(trans_counts) from a))

select transactions_count, count(a.trans_counts) visits_count
from b
left join a
on b.transactions_count = a.trans_counts
group by transactions_count
ORDER BY transactions_count;

/* Q5  Write an SQL query to generate a report of period_state for each continuous interval
of days in the period from 2019–01–01 to 2019–12–31. */

CREATE TABLE Failed (
	fail_date TIMESTAMP
)

INSERT INTO Failed
VALUES
('2018-12-28'),
('2018-12-29'),
('2019-01-04'),
('2019-01-05')

CREATE TABLE Succeeded (
	success_date TIMESTAMP
)

INSERT INTO Succeeded
VALUES
('2018-12-30'),
('2018-12-31'),
('2019-01-01'),
('2019-01-02'),
('2019-01-03'),
('2019-01-06')

SELECT 'Succeeded' AS period_state, MIN(success_date) AS start_date, MAX(success_date) AS end_date
FROM (
    SELECT success_date, ROW_NUMBER() OVER (ORDER BY success_date) AS row_num
    FROM Succeeded
    WHERE success_date BETWEEN '2019-01-01' AND '2019-12-31'
) t
GROUP BY DATE_PART('doy', success_date) - row_num

UNION

SELECT 'Failed' AS period_state, MIN(fail_date) AS start_date, MAX(fail_date) AS end_date
FROM (
    SELECT fail_date, ROW_NUMBER() OVER (ORDER BY fail_date) AS row_num
    FROM Failed
    WHERE fail_date BETWEEN '2019-01-01' AND '2019-12-31'
) t
GROUP BY DATE_PART('doy', fail_date) - row_num

ORDER BY start_date;