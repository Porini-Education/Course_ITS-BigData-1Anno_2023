USE Test_C001
GO


SELECT *
FROM (SELECT custid, companyname
      FROM Sales.Customers
      WHERE country = N'USA') AS USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Following fails
/*
SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;
*/
GO

-- Listing 5-1 Query with a Derived Table using Inline Aliasing Form
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
      FROM Sales.Orders) AS D
GROUP BY orderyear;

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

-- External column aliasing
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate), custid
      FROM Sales.Orders) AS D(orderyear, custid)
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

-- Yearly Count of Customers handled by Employee 3
DECLARE @empid AS INT = 3;

SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
      FROM Sales.Orders
      WHERE empid = @empid) AS D
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Nesting
---------------------------------------------------------------------

-- Listing 5-2 Query with Nested Derived Tables
SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
      FROM (SELECT YEAR(orderdate) AS orderyear, custid
            FROM Sales.Orders) AS D1
      GROUP BY orderyear) AS D2
WHERE numcusts > 70;

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------

-- Listing 5-3 Multiple Derived Tables Based on the Same Query
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
     (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT custid) AS numcusts
      FROM Sales.Orders
      GROUP BY YEAR(orderdate)) AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------

WITH USACusts AS
(
  SELECT custid, companyname
  FROM Sales.Customers
  WHERE country = N'USA'
)
SELECT * FROM USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Inline column aliasing
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

-- External column aliasing
WITH C(orderyear, custid) AS
(
  SELECT YEAR(orderdate), custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

DECLARE @empid AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Defining Multiple CTEs
---------------------------------------------------------------------

WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------

WITH YearlyCount AS
(
  SELECT YEAR(orderdate) AS orderyear,
    COUNT(DISTINCT custid) AS numcusts
  FROM Sales.Orders
  GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
  LEFT OUTER JOIN YearlyCount AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

---------------------------------------------------------------------
-- Recursive CTEs (Optional, Advanced)
---------------------------------------------------------------------

WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname
  FROM HR.Employees
  WHERE empid = 2
  
  UNION ALL
  
  SELECT C.empid, C.mgrid, C.firstname, C.lastname
  FROM EmpsCTE AS P
    INNER JOIN HR.Employees AS C
      ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;
GO

WITH NumbersCTE AS
(
    SELECT  1 AS Number
    UNION ALL
    SELECT Number + 1 FROM NumbersCTE
    WHERE Number < 2002
 )
SELECT * FROM NumbersCTE
OPTION (MAXRECURSION 2000)


---------------------------------------------------------------------
-- Views
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Views Described
---------------------------------------------------------------------

-- Creating USACusts View
DROP VIEW IF EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT custid, companyname
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- Views and ORDER BY
---------------------------------------------------------------------

-- ORDER BY in a View is not Allowed
/*
ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO
*/

-- Instead, use ORDER BY in Outer Query
SELECT custid, companyname, region
FROM Sales.USACusts
ORDER BY region;
GO

-- Do not Rely on TOP 
ALTER VIEW Sales.USACusts
AS

SELECT TOP (100) PERCENT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

-- Query USACusts
SELECT custid, companyname, region
FROM Sales.USACusts;
GO

-- DO NOT rely on OFFSET-FETCH, even if for now the engine does return rows in rder
ALTER VIEW Sales.USACusts
AS

SELECT 
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region
OFFSET 0 ROWS;
GO

-- Query USACusts
SELECT custid, companyname, region
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- View Options
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ENCRYPTION
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));
GO

ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

EXEC sp_helptext 'Sales.USACusts';
GO

---------------------------------------------------------------------
-- SCHEMABINDING
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- Try a schema change
/*
ALTER TABLE Sales.Customers DROP COLUMN address;
*/
GO

---------------------------------------------------------------------
-- CHECK OPTION
---------------------------------------------------------------------

create table dbo.TVCheck (id int, citta varchar(20));
GO
insert into dbo.TVCHECK values (1,'Milano'), (2, 'Bologna');
GO

Create view dbo.vTVCheck as
select id, citta 
from dbo.TVCheck
where citta = 'Milano'
;
GO

select * from dbo.vTVCheck;

-- consentito
insert into dbo.vTVCheck values (3,'Napoli');

select * from dbo.TVCheck; -- tabella

-- aggiungo l'opzione CHECK
Alter view dbo.vTVCheck as
select id, citta 
from dbo.TVCheck
where citta = 'Milano'
WITH CHECK OPTION
;
GO

-- Non consentito
insert into dbo.vTVCheck values (4,'Genova');

drop view dbo.vTVCheck;
drop table dbo.TVCheck;

-- Notice that you can insert a row through the view
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
 VALUES(
  N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

-- But when you query the view, you won't see it
SELECT custid, companyname, country
FROM Sales.USACusts
WHERE companyname = N'Customer ABCDE';

-- You can see it in the table, though
SELECT custid, companyname, country
FROM Sales.Customers
WHERE companyname = N'Customer ABCDE';
GO

-- Add CHECK OPTION to the View
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
WITH CHECK OPTION;
GO

-- Notice that you can't insert a row through the view
/*
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
 VALUES(
  N'Customer FGHIJ', N'Contact FGHIJ', N'Title FGHIJ', N'Address FGHIJ',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');
*/
GO

-- Cleanup
DELETE FROM Sales.Customers
WHERE custid > 91;

DROP VIEW IF EXISTS Sales.USACusts;
GO

---------------------------------------------------------------------
-- Inline User Defined Functions
---------------------------------------------------------------------

-- Creating GetCustOrders function
USE TSQLV4;
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders
  (@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid, custid, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
    shipregion, shippostalcode, shipcountry
  FROM Sales.Orders
  WHERE custid = @cid;
GO

-- Test Function
SELECT orderid, custid
FROM dbo.GetCustOrders(2) AS O;

SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.GetCustOrders(1) AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;
GO

-- Cleanup
DROP FUNCTION IF EXISTS dbo.GetCustOrders;
GO

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS APPLY HR.Employees AS E;

-- 3 most recent orders for each customer
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- With OFFSET-FETCH
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC
     OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

-- 3 most recent orders for each customer, preserve customers
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.Orders AS O
     WHERE O.custid = C.custid
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- Creation Script for the Function TopOrders
DROP FUNCTION IF EXISTS dbo.TopOrders;
GO
CREATE FUNCTION dbo.TopOrders
  (@custid AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate 
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

SELECT
  C.custid, C.companyname,
  A.orderid, A.empid, A.orderdate, A.requireddate 
FROM Sales.Customers AS C
  CROSS APPLY dbo.TopOrders(C.custid, 2) AS A;
  

  select * from dbo.TopOrders (21,4)

DROP FUNCTION IF EXISTS dbo.fnSplitString;
Go


CREATE FUNCTION dbo.fnSplitString
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata NVARCHAR(MAX) 
) 
BEGIN 
    DECLARE @start INT, @end INT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        VALUES(SUBSTRING(@string, @start, @end - @start)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
        
    END 
    RETURN 
END
GO

select * from [dbo].[fnSplitString] ('alfa,bravo,charlie',',');

drop table if exists #testSplit;

create table #testSplit (id int, testo varchar(50));

insert into #testSplit values 
(1,'alfa,bravo,charlie'),
(2,'delta,echo'),
(3,'foxtrot,golf'),
(4,'hotel'),
(5,'')
;

select * from  #testSplit

select a.id, b.splitdata
from  #testSplit a
outer apply dbo.fnSplitString (a.testo,',') b
order by a.id, b.splitdata
;


select a.id, b.splitdata
from  #testSplit a
cross apply dbo.fnSplitString (a.testo,',') b
order by a.id, b.splitdata
;


-- da 2016
select * from string_split ('alfa,bravo,charlie',',');

select a.id, b.value
from  #testSplit a
outer apply string_split  (a.testo,',') b
order by a.id, b.value
;

select a.id, b.value
from  #testSplit a
cross apply string_split  (a.testo,',') b
order by a.id, b.value
;

/* union all 
create table #a (id int, label varchar(10));

insert into #a values (1,'alfa'),(1,'alfa'),(2,'beta');

select * from #a;

DECLARE @a table(  
    id int NOT NULL,  
    label varchar(10)); 
	insert into @a values ('100','zz')


select * from @a
union
select * from #a
:

-- */



--set statistics io on;
--set statistics time  on;

select 

	dbo.fn_test1(freight) as v1, 
	dbo.fn_test1(shipperid) as v2,
		dbo.fn_test1(freight) as v3, 
	dbo.fn_test1(shipperid) as v4,
	*

from  Sales.Orders
;
go


select 

	b.NuovoValore as v1, 
	c.NuovoValore as v2,
		d.NuovoValore as v3, 
	e.NuovoValore as v4,
	*

from  Sales.Orders a
	cross apply dbo.fn_test2(freight) b
	cross apply  dbo.fn_test2(shipperid) c
		cross apply dbo.fn_test2(freight) d
	cross apply  dbo.fn_test2(shipperid) e
;
go




create function dbo.fn_test1 (@Valore numeric (8,3))

RETURNS numeric(8,3)
AS
BEGIN
	
	declare @a numeric (8,3);

set @a = @Valore * 10;

return @a
END
;
GO


alter FUNCTION dbo.fn_test2(@Valore numeric (8,3))
  RETURNS TABLE
AS
RETURN
  SELECT @Valore * 10 as NuovoValore
  ;
GO


select dbo.fn_test1 (8)

select * from dbo.fn_test2 (8)


--select top 20 givenname, surname, centimeters, kilograms from [dbo].[People50a]


alter function bmi (@peso numeric(5,1), @altezza int)
RETURNS TABLE
AS
RETURN
select 
	@altezza as Altezza, 
	@peso as Peso,
	@peso/((@altezza/100.)*(@altezza/100.)) as BMI
;

--select * from bmi(80,180)

select 
	givenname, 
	surname, 
	centimeters,	
	kilograms,
	b.bmi ,
	kilograms/((centimeters/100.)*(centimeters/100.)) as BMI2
	from [dbo].[People50a] a
	OUTER APPLY bmi(a.kilograms,a.centimeters) b