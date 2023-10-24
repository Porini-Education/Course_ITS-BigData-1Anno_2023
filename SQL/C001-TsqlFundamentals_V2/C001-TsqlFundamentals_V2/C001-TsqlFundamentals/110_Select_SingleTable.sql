
use Test_C001
GO


SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

---------------------------------------------------------------------
-- The FROM Clause
---------------------------------------------------------------------

SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders;

---------------------------------------------------------------------
-- The WHERE Clause
---------------------------------------------------------------------

SELECT orderid, empid, orderdate, freight
FROM Sales.Orders
WHERE custid = 71;

---------------------------------------------------------------------
-- The GROUP BY Clause
---------------------------------------------------------------------

SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

SELECT
  empid,
  YEAR(orderdate) AS orderyear,
  SUM(freight) AS totalfreight,
  COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

/*
SELECT empid, YEAR(orderdate) AS orderyear, freight
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);
*/

SELECT 
  empid, 
  YEAR(orderdate) AS orderyear, 
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);

---------------------------------------------------------------------
-- The HAVING Clause
---------------------------------------------------------------------

SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;

---------------------------------------------------------------------
-- The SELECT Clause
---------------------------------------------------------------------

SELECT orderid orderdate
FROM Sales.Orders;

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;

/*
SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE orderyear > 2015;
*/

SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE YEAR(orderdate) > 2015;

/*
SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING numorders > 1;
*/

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;

-- Listing 2-2: Query Returning Duplicate Rows
SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

-- Listing 2-3: Query With a DISTINCT Clause
SELECT DISTINCT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

SELECT *
FROM Sales.Shippers;

/*
SELECT orderid,
  YEAR(orderdate) AS orderyear,
  orderyear + 1 AS nextyear
FROM Sales.Orders;
*/

SELECT orderid,
  YEAR(orderdate) AS orderyear,
  YEAR(orderdate) + 1 AS nextyear
FROM Sales.Orders;

---------------------------------------------------------------------
-- The ORDER BY Clause
---------------------------------------------------------------------

-- Listing 2-4: Query Demonstrating the ORDER BY Clause
SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

SELECT empid, firstname, lastname, country
FROM HR.Employees
ORDER BY hiredate;

/*
SELECT DISTINCT country
FROM HR.Employees
ORDER BY empid;
*/

---------------------------------------------------------------------
-- The TOP and OFFSET-FETCH Filters
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The TOP Filter
---------------------------------------------------------------------

-- Listing 2-5: Query Demonstrating the TOP Option
SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

-- Listing 2-6: Query Demonstrating TOP with Unique ORDER BY List
SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

SELECT TOP (5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

---------------------------------------------------------------------
-- The OFFSET-FETCH Filter
---------------------------------------------------------------------

-- OFFSET-FETCH
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

---------------------------------------------------------------------
-- A Quick Look at Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

