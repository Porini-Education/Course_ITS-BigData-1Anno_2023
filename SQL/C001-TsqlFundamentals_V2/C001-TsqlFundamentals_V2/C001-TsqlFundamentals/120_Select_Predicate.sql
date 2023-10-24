use Test_C001
GO


-- Predicates: IN, BETWEEN, LIKE
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid BETWEEN 10300 AND 10310;

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

---- Second character in last name is e
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%';

-- First character in last name is A, B or C
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%';

-- First character in last name is A through E
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%';

-- First character in last name is not A through E
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%';


create table #t (testo varchar(20));
insert into #t values ('alfa'), ('[alfa'),('%alfa')

select * from #t

	select * from #t where testo like '!%%'  ESCAPE '!'

-- Comparison operators: =, >, <, >=, <=, <>, !=, !>, !< 
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101';

-- Logical operators: AND, OR, NOT
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101'
  AND empid IN(1, 3, 5);

-- Arithmetic operators: +, -, *, /, %
SELECT orderid, productid, qty, unitprice, discount,
  qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

-- Operator Precedence

-- AND precedes OR
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
        custid = 1
    AND empid IN(1, 3, 5)
    OR  custid = 85
    AND empid IN(2, 4, 6);

-- Equivalent to
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE
      ( custid = 1
        AND empid IN(1, 3, 5) )
    OR
      ( custid = 85
        AND empid IN(2, 4, 6) );

-- *, / precedes +, -
SELECT 10 + 2 * 3   -- 16

SELECT (10 + 2) * 3 -- 36

---------------------------------------------------------------------
-- CASE Expression
---------------------------------------------------------------------

-- Simple
SELECT productid, productname, categoryid,
  CASE categoryid
    WHEN 1 THEN 'Beverages'
    WHEN 2 THEN 'Condiments'
    WHEN 3 THEN 'Confections'
    WHEN 4 THEN 'Dairy Products'
    WHEN 5 THEN 'Grains/Cereals'
    WHEN 6 THEN 'Meat/Poultry'
    WHEN 7 THEN 'Produce'
    WHEN 8 THEN 'Seafood'
    ELSE 'Unknown Category'
  END AS categoryname
FROM Production.Products;

-- Searched
SELECT orderid, custid, val,
  CASE 
    WHEN val < 1000.00                   THEN 'Less than 1000'
    WHEN val BETWEEN 1000.00 AND 3000.00 THEN 'Between 1000 and 3000'
    WHEN val > 3000.00                   THEN 'More than 3000'
    ELSE 'Unknown'
  END AS valuecategory
FROM Sales.OrderValues;

---IIF
	select 
		CategoryId,
		CategoryName,
		IIF (CategoryName='Beverages','Condiments', 'Other Product') as Info
	from Production.Categories	;

--- CHOOSE
	select 
		CategoryId,
		CategoryName,
		CHOOSE (CategoryId,'alfa', 'bravo','charlie') as Test
	from Production.Categories;


---------------------------------------------------------------------
-- NULLs
---------------------------------------------------------------------

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA'
   OR region IS NULL;


--- ISNULL COALESCE

--declare @a int = 0;
--select 10/@a;

declare @a int = 0;
select coalesce(@a,10/@a,0);

DECLARE
  @x AS INT = null,
  @y AS INT = null,
  @z AS INT = null;

	SELECT COALESCE(@x, @y, @z);
	SELECT ISNULL(@x, @y);

-- Fallisce (sceglie il DataType a Priorità maggiore
	SELECT COALESCE('abc', 1);

-- Funziona (Data Type del primo parametro)
	SELECT ISNULL('abc', 1);

select coalesce (null,null) -- errore

select isnull(cast(null as int),'0') -- null


--- 
create table a (id int);
insert into a values (1),(29),(0);
;

select *,10/id 
from a 
where id <> 0 and 10/id > 0;

select *,10/id 
from a 
where 10/id > 0 and id <> 0 ;

--pulizia
drop table if exists dbo.a;
GO
