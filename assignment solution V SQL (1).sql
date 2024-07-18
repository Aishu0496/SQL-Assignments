/* Q 1  Write an SQL query to report how many units in each category have been ordered on each day of the week. */

CREATE TABLE orders(
	order_id INTEGER UNIQUE,
	customer_id INTEGER,
	order_date TIMESTAMP,
	item_id INTEGER,
	quantity INTEGER
	) 

INSERT INTO orders
VALUES 
('1','1','2020-06-01','1','10'),
('2','1','2020-06-08','2','10'),
('3','2','2020-06-02','1','5'),
('4','3','2020-06-03','3','5'),
('5','4','2020-06-04','4','1'),
('6','4','2020-06-05','5','5'),
('7','5','2020-06-05','1','10'),
('8','5','2020-06-14','4','5'),
('9','5','2020-06-21','3','5')
	
CREATE TABLE items (
	item_id INTEGER UNIQUE,
	item_name VARCHAR(100),
	item_category VARCHAR(100)
)

INSERT INTO items
VALUES 
('1','LC Alg. Book','Book'),
('2','LC DB. Book','Book'),
('3','LC SmarthPhone','Phone'),
('4','LC Phone 2020','Phone'),
('5','LC SmartGlass','Glasses'),
('6','LC T-Shirt XL','T-shirt')
	
SELECT * FROM orders AS o;
SELECT * FROM items AS i;

SELECT
    i.item_category AS Category,
	SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 1 THEN o.quantity ELSE 0 END) AS Monday_units,
    SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 2 THEN o.quantity ELSE 0 END) AS Tuesday_units,
    SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 3 THEN o.quantity ELSE 0 END) AS Wednesday_units,
    SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 4 THEN o.quantity ELSE 0 END) AS Thursday_units,
    SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 5 THEN o.quantity ELSE 0 END) AS Friday_units,
    SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 6 THEN o.quantity ELSE 0 END) AS Saturday_units,
	SUM(CASE WHEN EXTRACT(DOW FROM o.order_date) = 7 THEN o.quantity ELSE 0 END) AS Sunday_units
FROM
    Orders o
INNER JOIN
    Items i ON o.item_id = i.item_id
GROUP BY
    i.item_category
ORDER BY
    i.item_category;
/* Q 2 Write an SQL query to find employees who earn the top three salaries in each of the departments. 
For the above tables, your SQL query should return the following rows (order of rows does not matter). */

CREATE TABLE Employee (
	Id Integer,
	Name VARCHAR(100),
	Salary INTEGER,
	DepartmentId INTEGER
)

INSERT INTO Employee
VALUES
('1','Joe','85000','1'),
('2','Henry','80000','2'),
('3','Sam','60000','2'),
('4','Max','90000','1'),
('5','Janet','69000','1'),
('6','Randy','85000','1'),
('7','Will','70000','1')

SELECT * FROM Employee AS E1;

CREATE TABLE Department (
	Id INTEGER,
	Name VARCHAR(100)
)

INSERT INTO Department
VALUES
('1','IT'),
('2','Sales')

SELECT * FROM Department AS D;

SELECT D.Name AS Department, E1.Name AS Employee, E1.Salary AS Salary
FROM Department AS D
JOIN Employee AS E1 ON D.Id = E1.DepartmentId
WHERE 3 > (SELECT COUNT(DISTINCT E2.Salary)
           FROM Employee AS E2
           WHERE E2.Salary > E1.Salary AND E2.DepartmentId = E1.DepartmentId)
ORDER BY Department, Salary;

/* Q3 Write an SQL query to compute moving average of how much customer paid 
in a 7 days window (current day + 6 days before) */

CREATE TABLE Customer (
	customer_id INTEGER,
	name VARCHAR(100),
	visited_on TIMESTAMP,
	amount INTEGER
)

INSERT INTO Customer
VALUES
('1','Jhon','2019-01-01','100'),
('2','Daniel','2019-01-02','110'),
('3','Jade','2019-01-03','120'),
('4','Khaled','2019-01-04','130'),
('5','Winston','2019-01-05','110'),
('6','Elvis','2019-01-06','140'),
('7','Anna','2019-01-07','150'),
('8','Maria','2019-01-08','80'),
('9','Jaze','2019-01-09','110'),
('1','Jhon ','2019-01-10','130'),
('3','Jade','2019-01-10','150')

SELECT * FROM Customer

SELECT visited_on,
    SUM(amount) OVER (ORDER BY visited_on ROWS 6 PRECEDING),
	ROUND(AVG(amount) OVER(ORDER BY visited_on ROWS 6 PRECEDING),2)
FROM (
	SELECT visited_on, SUM(amount) AS amount
	FROM Customer
	GROUP BY visited_on
	ORDER BY visited_on
     ) AS a
ORDER BY visited_on OFFSET 6 ROWS;

/* Q 4  Write a query to find the shortest distance between these points rounded to 2 decimals.*/

CREATE TABLE coordinates (
	x Integer,
	y Integer
)

INSERT INTO coordinates
VALUES
('-1','-1'),
('0','0'),
('-1','-2')

WITH PointPairs AS (
    SELECT
        a.x AS x1,
        a.y AS y1,
        b.x AS x2,
        b.y AS y2
    FROM coordinates a
    CROSS JOIN coordinates b
    WHERE a.x != b.x OR a.y != b.y
)
SELECT
    ROUND(SQRT(POW(CAST(x2 AS NUMERIC) - CAST(x1 AS NUMERIC), 2) + POW(CAST(y2 AS NUMERIC) - CAST(y1 AS NUMERIC), 2)), 2) AS shortest_distance
FROM PointPairs
ORDER BY shortest_distance
LIMIT 1;

/* Q5 Write an SQL query to find all numbers that appear at least three times consecutively.*/

CREATE TABLE Numbers (
	ID INTEGER,
	NUM INTEGER
)

INSERT INTO Numbers
VALUES
('1','1'),
('2','1'),
('3','1'),
('4','2'),
('5','1'),
('6','2'),
('7','2')

SELECT DISTINCT Num AS ConsecutiveNums
FROM (
    SELECT Num,
           LEAD(Num, 1) OVER (ORDER BY Id) AS NextNum,
           LAG(Num, 1) OVER (ORDER BY Id) AS PrevNum
    FROM Numbers
) AS subquery
WHERE Num = NextNum AND Num = PrevNum;