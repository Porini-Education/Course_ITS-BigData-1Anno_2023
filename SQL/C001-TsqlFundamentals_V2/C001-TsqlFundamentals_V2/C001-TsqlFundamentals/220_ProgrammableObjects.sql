use Test_C001
GO

-- Variables
	DECLARE @Label varchar(20) = 'alfa';
	GO

	DECLARE @Label varchar(20);
	SET @Label = 'alfa';
	GO

	DECLARE @Label varchar(20) = 'charlie';

	IF @Label = 'alfa' print 'A'
	ELSE
	  IF @Label = 'bravo' print 'B'
	  ELSE
	   	IF @Label = 'charlie' print 'C'
		ELSE
		  IF @Label = 'delta' print 'D'
		  ELSE print 'altri'
	;
	GO


-- Cursors

	DECLARE @DbName sysname;
	DECLARE @DbLevel varchar(12);

	DECLARE C CURSOR FOR
	  SELECT name, cmptlevel
	  FROM sys.sysdatabases
	  ORDER BY name;

	OPEN C;

	FETCH NEXT FROM C INTO @DbName, @DbLevel;

	WHILE @@FETCH_STATUS = 0
	BEGIN 
	  print 'Database ' + @DbName + ' - Compatibility level ' + @DbLevel
	  FETCH NEXT FROM C INTO  @DbName, @DbLevel;
	END;

	CLOSE C;
	DEALLOCATE C;
	GO


-- Dynamic TSql
	exec ('Print ''Addesso è il giorno '' + convert(varchar(12), convert (date, getdate()),3)' );

	declare @g datetime= getdate()

	EXEC sys.sp_executesql
	  @stmt = N'Print ''Addesso è il giorno '' + convert(varchar(12), convert (date, @giorno),3)',
	  @params = N'@giorno AS datetime ',
	  @giorno = @g;

	GO

--- UDF

-- Scalar Function
	CREATE FUNCTION dbo.fn_BMI (@Height_METRI numeric (4,2), @Weight_KG smallint)
	 RETURNS numeric (5,2)
	 as
		 BEGIN
			Return @Weight_KG / (@Height_Metri * @Height_Metri)
		 END
	 ;
	GO

	 select dbo.fn_BMI(1.81,78) as BMI;

	 GO


-- Table Function
	Drop Function if exists dbo.fn_BMI_Tab;
	GO

	CREATE FUNCTION dbo.fn_BMI_Tab (@Height_METRI numeric (4,2), @Weight_KG smallint)
	 RETURNS TABLE
	 as

	 Return
			Select 
				convert(numeric(5,2),@Weight_KG / (@Height_Metri * @Height_Metri)) as BMI,
		
				case 
					when @Weight_KG / (@Height_Metri * @Height_Metri) < 25 then 'Normal'
					when @Weight_KG / (@Height_Metri * @Height_Metri) <= 29 then 'OverWeight'
					else 'Obese'
				end as Situation
	 ;
	GO

	Drop Function if exists dbo.fn_BMI_Tab2;
	GO

	CREATE FUNCTION dbo.fn_BMI_Tab2 (@Height_METRI numeric (4,2), @Weight_KG smallint)
	 RETURNS TABLE
	 as

	 Return
			Select 
				convert(numeric(5,2),@Weight_KG / (@Height_Metri * @Height_Metri)) as BMI
	 ;
	GO

	 select * from dbo.fn_BMI_Tab2 (1.81,78)

	 -- test perfomance
	 use Test_C001
	 go

	 --drop table if exists dbo.HeightWeight ;
	 --go

	 --create table dbo.HeightWeight 
		--(id int identity (1,1),
		--Weight_KG int,
		--Height_Metri numeric (4,2)
		--);
		--GO
		---- un milione di righe
		--insert into dbo.HeightWeight 
		--select 
		--	Weight_KG =convert(int, 100* RAND(CHECKSUM(NEWID()))),
		--	Height_Metri = 1 + convert(numeric(3,2),RAND(CHECKSUM(NEWID())))
		--	from util.fn_nums(1000000)
		--;

	drop table if exists dbo.HeightWeight ;
	 go

	 create table dbo.HeightWeight 
		(id int identity (1,1),
		Weight_KG int,
		Height_Metri numeric (4,2),
		Weight_KG2 int,
		Height_Metri2 numeric (4,2)
		);
		GO
		-- un milione di righe
		insert into dbo.HeightWeight 
		select 
			Weight_KG =convert(int, 100* RAND(CHECKSUM(NEWID()))),
			Height_Metri = 1 + convert(numeric(3,2),RAND(CHECKSUM(NEWID()))),
			Weight_KG2 =convert(int, 100* RAND(CHECKSUM(NEWID()))),
			Height_Metri2 = 1 + convert(numeric(3,2),RAND(CHECKSUM(NEWID())))
			from util.fn_nums(1000000)
		;


	select top 30 * from dbo.HeightWeight ;

	set statistics IO on;
	set statistics TIME on;

		select  
		*,
		dbo.fn_BMI(Height_Metri,Weight_KG) as BMI,
		dbo.fn_BMI(Height_Metri2,Weight_KG2) as BMI2
		from dbo.HeightWeight 
	;
	--  CPU time = 7390 ms,  elapsed time = 12548 ms.
	-- Table 'HeightWeight'. Scan count 1, logical reads 2718

		select  
		*,
		b.BMI as BMI,
		c.BMI as BMI2
		from dbo.HeightWeight a
		outer apply  dbo.fn_BMI_Tab2 (Height_Metri,Weight_KG) b

		outer apply  dbo.fn_BMI_Tab2 (Height_Metri2,Weight_KG2) c
	; 
	-- CPU time = 4188 ms,  elapsed time = 20616 ms
	-- Table 'HeightWeight'. Scan count 5, logical reads 2718


	select  
		*,
		b.BMI as BMI
		from dbo.HeightWeight a
		outer apply  dbo.fn_BMI_Tab2 (Height_Metri,Weight_KG) b

	; 


set statistics IO OFF;
set statistics TIME OFF;


-- Trigger
-- creazione di un trigger DML che non consente l'update di record con CanUpd = 0
drop table if exists dbo.TestTriggerDML
GO
create table dbo.TestTriggerDML (
id int identity (1,1),
CanUpd tinyInt,
Valore int)
;
GO

insert into dbo.TestTriggerDML values
(1,100),(1,101),(1,102),
(0,200),(0,201),(0,202)
;
GO

Select * from dbo.TestTriggerDML;
GO

drop trigger if exists dbo.trg_CheckIns;
GO

create Trigger dbo.trg_CheckIns on dbo.TestTriggerDML AFTER INSERT
AS
select 'DEL', Id,Valore, CanUpd from deleted
union 
select 'INS', Id, Valore, CanUpd from inserted
;
GO

insert into dbo.TestTriggerDML values
(0,300),(0,301),(0,302)
;
GO

drop trigger if exists dbo.trg_CheckDel;
GO
create Trigger dbo.trg_CheckDel on dbo.TestTriggerDML AFTER DELETE
AS
IF (select count(*) from deleted where CanUpd = 0) > 0 
BEGIN 
	PRINT 'KO'
	RAISERROR('Eliminazione NON possibile', 0, 1) WITH NOWAIT
	ROLLBACK
END

ELSE
 BEGIN
  PRINT 'OK'
  --COMMIT
END

GO

BEGIN TRY
	delete from dbo.TestTriggerDML where Id = 5
END TRY
BEGIN CATCH
	Print 'Eliminazione non effettuata'
END CATCH
;

Select * from dbo.TestTriggerDML order by 1
GO


USE TSQLV4;

---------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------

-- Declare a variable and initialize it with a value
DECLARE @i AS INT;
SET @i = 10;
GO

-- Declare and initialize a variable in the same statement
DECLARE @i AS INT = 10;
GO

-- Store the result of a subquery in a variable
DECLARE @empname AS NVARCHAR(61);

SET @empname = (SELECT firstname + N' ' + lastname
                FROM HR.Employees
                WHERE empid = 3);

SELECT @empname AS empname;
GO

-- Using the SET command to assign one variable at a time
DECLARE @firstname AS NVARCHAR(20), @lastname AS NVARCHAR(40);

SET @firstname = (SELECT firstname
                  FROM HR.Employees
                  WHERE empid = 3);
SET @lastname = (SELECT lastname
                  FROM HR.Employees
                  WHERE empid = 3);

SELECT @firstname AS firstname, @lastname AS lastname;
GO

-- Using the SELECT command to assign multiple variables in the same statement
DECLARE @firstname AS NVARCHAR(20), @lastname AS NVARCHAR(40);

SELECT
  @firstname = firstname,
  @lastname  = lastname
FROM HR.Employees
WHERE empid = 3;

SELECT @firstname AS firstname, @lastname AS lastname;
GO

-- SELECT doesn't fail when multiple rows qualify
DECLARE @empname AS NVARCHAR(61);

SELECT @empname = firstname + N' ' + lastname
FROM HR.Employees
WHERE mgrid = 2;

SELECT @empname AS empname;
GO

-- SET fails when multiple rows qualify
DECLARE @empname AS NVARCHAR(61);

SET @empname = (SELECT firstname + N' ' + lastname
                FROM HR.Employees
                WHERE mgrid = 2);

SELECT @empname AS empname;
GO

---------------------------------------------------------------------
-- Batches
---------------------------------------------------------------------

-- A Batch as a Unit of Parsing

-- Valid batch
PRINT 'First batch';
USE TSQLV4;
GO
-- Invalid batch
PRINT 'Second batch';
SELECT custid FROM Sales.Customers;
SELECT orderid FOM Sales.Orders;
GO
-- Valid batch
PRINT 'Third batch';
SELECT empid FROM HR.Employees;
GO

-- Batches and Variables

DECLARE @i AS INT = 10;
-- Succeeds
PRINT @i;
GO

-- Fails
PRINT @i;
GO

-- Statements That Cannot Be Combined in the same Batch

DROP VIEW IF EXISTS Sales.MyView;

CREATE VIEW Sales.MyView
AS

SELECT YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY YEAR(orderdate);
GO

-- A Batch as a Unit of Resolution

-- Create T1 with one column
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(col1 INT);
GO

-- Following fails
ALTER TABLE dbo.T1 ADD col2 INT;
SELECT col1, col2 FROM dbo.T1;
GO

-- Following succeeds
ALTER TABLE dbo.T1 ADD col2 INT;
GO
SELECT col1, col2 FROM dbo.T1;
GO

-- The GO n Option

-- Create T1 with identity column
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(col1 INT IDENTITY CONSTRAINT PK_T1 PRIMARY KEY);
GO

-- Suppress insert messages
SET NOCOUNT ON;
GO

-- Execute batch 100 times
INSERT INTO dbo.T1 DEFAULT VALUES;
GO 100

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Flow Elements
---------------------------------------------------------------------

	DECLARE @Label varchar(20) = 'charlie';

	IF @Label = 'alfa' print 'A'
	ELSE
	  IF @Label = 'bravo' print 'B'
	  ELSE
	   	IF @Label = 'charlie' print 'C'
		ELSE
		  IF @Label = 'delta' print 'D'
		  ELSE print 'altri'
	;
	GO


-- The IF ... ELSE Flow Element
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  PRINT 'Today is not the last day of the year.';
GO

-- IF ELSE IF
IF YEAR(SYSDATETIME()) <> YEAR(DATEADD(day, 1, SYSDATETIME()))
  PRINT 'Today is the last day of the year.';
ELSE
  IF MONTH(SYSDATETIME()) <> MONTH(DATEADD(day, 1, SYSDATETIME()))
    PRINT 'Today is the last day of the month but not the last day of the year.';
  ELSE 
    PRINT 'Today is not the last day of the month.';
GO

-- Statement Block
IF DAY(SYSDATETIME()) = 1
BEGIN
  PRINT 'Today is the first day of the month.';
  PRINT 'Starting first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished first-of-month-day database process.';
END;
ELSE
BEGIN
  PRINT 'Today is not the first day of the month.';
  PRINT 'Starting non-first-of-month-day process.';
  /* ... process code goes here ... */
  PRINT 'Finished non-first-of-month-day process.';
END;
GO

-- The WHILE Flow Element

	DECLARE @i AS INT = 1;
	WHILE @i <= 10
	BEGIN
	  PRINT @i;
	  SET @i = @i + 1;
	END;
	GO

-- BREAK

	DECLARE @i AS INT = 1;
	WHILE @i <= 10
	BEGIN
	  IF @i = 6 BREAK;
	  PRINT @i;
	  SET @i = @i + 1;
	END;
GO

-- CONTINUE

	DECLARE @i AS INT = 0;
	WHILE @i < 10
	BEGIN
	  SET @i = @i + 1;
	  IF @i = 6 CONTINUE;
	  PRINT @i;
	END;

GO

-- Using a WHILE loop to populate a table of numbers
SET NOCOUNT ON;
DROP TABLE IF EXISTS dbo.Numbers;
CREATE TABLE dbo.Numbers(n INT NOT NULL PRIMARY KEY);
GO

DECLARE @i AS INT = 1;
WHILE @i <= 1000
BEGIN
  INSERT INTO dbo.Numbers(n) VALUES(@i);
  SET @i = @i + 1;
END;
GO

---------------------------------------------------------------------
-- Cursors
---------------------------------------------------------------------

-- Example: Running Aggregations
SET NOCOUNT ON;

DECLARE @Result AS TABLE
(
  custid     INT,
  ordermonth DATE,
  qty        INT, 
  runqty     INT,
  PRIMARY KEY(custid, ordermonth)
);

DECLARE
  @custid     AS INT,
  @prvcustid  AS INT,
  @ordermonth AS DATE,
  @qty        AS INT,
  @runqty     AS INT;

DECLARE C CURSOR FAST_FORWARD /* read only, forward only */ FOR
  SELECT custid, ordermonth, qty
  FROM Sales.CustOrders
  ORDER BY custid, ordermonth;

OPEN C;

FETCH NEXT FROM C INTO @custid, @ordermonth, @qty;

SELECT @prvcustid = @custid, @runqty = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @custid <> @prvcustid
    SELECT @prvcustid = @custid, @runqty = 0;

  SET @runqty = @runqty + @qty;

  INSERT INTO @Result VALUES(@custid, @ordermonth, @qty, @runqty);
  
  FETCH NEXT FROM C INTO @custid, @ordermonth, @qty;
END;

CLOSE C;

DEALLOCATE C;

SELECT 
  custid,
  CONVERT(VARCHAR(7), ordermonth, 121) AS ordermonth,
  qty,
  runqty
FROM @Result
ORDER BY custid, ordermonth;
GO

-- Using a window aggregate function
SELECT custid, ordermonth, qty,
  SUM(qty) OVER(PARTITION BY custid
                ORDER BY ordermonth
                ROWS UNBOUNDED PRECEDING) AS runqty
FROM Sales.CustOrders
ORDER BY custid, ordermonth;

---------------------------------------------------------------------
-- Temporary Tables
---------------------------------------------------------------------

-- Local Temporary Tables

DROP TABLE IF EXISTS #MyOrderTotalsByYear;
GO

CREATE TABLE #MyOrderTotalsByYear
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO #MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM dbo.#MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN dbo.#MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;
GO

-- Try accessing the table from another session
SELECT orderyear, qty FROM dbo.#MyOrderTotalsByYear;

-- cleanup from the original session
DROP TABLE IF EXISTS #MyOrderTotalsByYear;


drop procedure if exists dbo.P0  
go

drop procedure if exists dbo.P1 
go

drop procedure if exists dbo.P2  
go

		create procedure dbo.P0  
		as
		create table #T0 (id int)

			insert into #T0 values (10)

			select @@NESTLEVEL as Level , 'T', id from #T;
			select @@NESTLEVEL as Level, 'T0', id from #T0

		GO

		create procedure dbo.P2  
		as
		create table #T2 (id int)

			insert into #T2 values (200)

			select 'T1', id from #T1
			select 'T2', id from #T2;

		GO

		create procedure dbo.P1 
		as
			create table #T1 (id int)

			insert into #T1 values (100)

			select 'T1', id from #T1

			exec dbo.P2;

			select 'T1', id from #T1
			select 'T2', id from #T2;
		GO



		select @@NESTLEVEL  -- 0

		create table #T (id int);
		insert into #T values (99);

		exec dbo.P0

		select * from #T;
		select * from #T0;


		exec dbo.P1;






-- Global Temporary Tables
CREATE TABLE ##Globals
(
  id  sysname     NOT NULL PRIMARY KEY,
  val SQL_VARIANT NOT NULL
);

-- Run from any session
INSERT INTO ##Globals(id, val) VALUES(N'i', CAST(10 AS INT));

-- Run from any session
SELECT * FROM ##Globals WHERE id = N'i';

-- Run from any session
DROP TABLE IF EXISTS ##Globals;
GO

-- Table Variables
DECLARE @MyOrderTotalsByYear TABLE
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT Cur.orderyear, Cur.qty AS curyearqty, Prv.qty AS prvyearqty
FROM @MyOrderTotalsByYear AS Cur
  LEFT OUTER JOIN @MyOrderTotalsByYear AS Prv
    ON Cur.orderyear = Prv.orderyear + 1

GO

select * from @MyOrderTotalsByYear  -- da errore


	CREATE TABLE #Poldo (id INT);
	DECLARE @Poldo TABLE (id INT);

		begin tran
	insert into #Poldo values (1);
	insert into @Poldo values (10);

	select * from #Poldo;
	select * from @Poldo;


		rollback

	select * from #Poldo;
   select * from @Poldo;

drop table IF EXISTS #Poldo 

-- with the LAG function
SELECT
  YEAR(O.orderdate) AS orderyear,
  SUM(OD.qty) AS curyearqty,
  LAG(SUM(OD.qty)) OVER(ORDER BY YEAR(orderdate)) AS prvyearqty
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
GROUP BY YEAR(orderdate);
GO



-- Table Types
DROP TYPE IF EXISTS dbo.OrderTotalsByYear;

CREATE TYPE dbo.OrderTotalsByYear AS TABLE
(
  orderyear INT NOT NULL PRIMARY KEY,
  qty       INT NOT NULL
);
GO

-- Use table type
DECLARE @MyOrderTotalsByYear AS dbo.OrderTotalsByYear;

INSERT INTO @MyOrderTotalsByYear(orderyear, qty)
  SELECT
    YEAR(O.orderdate) AS orderyear,
    SUM(OD.qty) AS qty
  FROM Sales.Orders AS O
    INNER JOIN Sales.OrderDetails AS OD
      ON OD.orderid = O.orderid
  GROUP BY YEAR(orderdate);

SELECT orderyear, qty FROM @MyOrderTotalsByYear;
GO


DROP TYPE IF EXISTS dbo.Elenco;
GO

CREATE TYPE dbo.Elenco AS TABLE
(
  Valori varchar(20) NOT  NULL );
GO

drop procedure if exists dbo.GetElenco;
GO

create procedure dbo.GetElenco (@T as dbo.Elenco READONLY)
as
select * from @T
;
GO

DECLARE @T as dbo.Elenco
insert into @T VALUES('A'),('B'),('C'),('D');

exec dbo.GetElenco @T;




---------------------------------------------------------------------
-- Dynamic SQL
---------------------------------------------------------------------

-- The EXEC Command

-- Simple example of EXEC
DECLARE @sql AS VARCHAR(100);
SET @sql = 'PRINT ''This message was printed by a dynamic SQL batch.'';';
EXEC(@sql);
GO

-- The sp_executesql Stored Procedure

-- Simple example using sp_executesql
DECLARE @sql AS NVARCHAR(100);

SET @sql = N'SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderid = @orderid;';

EXEC sys.sp_executesql
  @stmt = @sql,
  @params = N'@orderid AS INT',
  @orderid = 10248;
GO

---------------------------------------------------------------------
-- Using PIVOT with Dynamic SQL (Advanced, Optional)
---------------------------------------------------------------------

-- Static PIVOT
SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN([2014],[2015],[2016])) AS P;

-- Dynamic PIVOT
DECLARE
  @sql       AS NVARCHAR(1000),
  @orderyear AS INT,
  @first     AS INT;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT DISTINCT(YEAR(orderdate)) AS orderyear
  FROM Sales.Orders
  ORDER BY orderyear;

SET @first = 1;

SET @sql = N'SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN(';

OPEN C;

FETCH NEXT FROM C INTO @orderyear;

WHILE @@fetch_status = 0
BEGIN
  IF @first = 0
    SET @sql += N','
  ELSE
    SET @first = 0;

  SET @sql += QUOTENAME(@orderyear);

  FETCH NEXT FROM C INTO @orderyear;
END;

CLOSE C;

DEALLOCATE C;

SET @sql += N')) AS P;';

EXEC sys.sp_executesql @stmt = @sql;
GO

---------------------------------------------------------------------
-- Routines
---------------------------------------------------------------------

---------------------------------------------------------------------
-- User Defined Functions
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetAge;
GO

CREATE FUNCTION dbo.GetAge
(
  @birthdate AS DATE,
  @eventdate AS DATE
)
RETURNS INT
AS
BEGIN
  RETURN
    DATEDIFF(year, @birthdate, @eventdate)
    - CASE WHEN 100 * MONTH(@eventdate) + DAY(@eventdate)
              < 100 * MONTH(@birthdate) + DAY(@birthdate)
           THEN 1 ELSE 0
      END;
END;
GO

-- Test function
SELECT
  empid, firstname, lastname, birthdate,
  dbo.GetAge(birthdate, '20160212') AS age
FROM HR.Employees;

---------------------------------------------------------------------
-- Stored Procedures
---------------------------------------------------------------------

-- Using a Stored Procedure
DROP PROC IF EXISTS Sales.GetCustomerOrders;
GO

CREATE PROC Sales.GetCustomerOrders
  @custid   AS INT,
  @fromdate AS DATETIME = '19000101',
  @todate   AS DATETIME = '99991231',
  @numrows  AS INT OUTPUT
AS
SET NOCOUNT ON;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE custid = @custid
  AND orderdate >= @fromdate
  AND orderdate < @todate;

SET @numrows = @@rowcount;
GO

DECLARE @rc AS INT;

EXEC Sales.GetCustomerOrders
  @custid   = 1, -- Also try with 100
  @fromdate = '20150101',
  @todate   = '20160101',
  @numrows  = @rc OUTPUT;

SELECT @rc AS numrows;
GO

---------------------------------------------------------------------
-- Triggers
---------------------------------------------------------------------

-- Example for a DML audit trigger
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T1_Audit
(
  audit_lsn  INT          NOT NULL IDENTITY PRIMARY KEY,
  dt         DATETIME2(3) NOT NULL DEFAULT(SYSDATETIME()),
  login_name sysname      NOT NULL DEFAULT(ORIGINAL_LOGIN()),
  keycol     INT          NOT NULL,
  datacol    VARCHAR(10)  NOT NULL
);
GO

CREATE TRIGGER trg_T1_insert_audit ON dbo.T1 AFTER INSERT
AS
SET NOCOUNT ON;

INSERT INTO dbo.T1_Audit(keycol, datacol)
  SELECT keycol, datacol FROM inserted;
GO

INSERT INTO dbo.T1(keycol, datacol) VALUES(10, 'a');
INSERT INTO dbo.T1(keycol, datacol) VALUES(30, 'x');
INSERT INTO dbo.T1(keycol, datacol) VALUES(20, 'g');

SELECT audit_lsn, dt, login_name, keycol, datacol
FROM dbo.T1_Audit;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

-- Example for a DDL audit trigger

-- Creation Script for AuditDDLEvents Table and trg_audit_ddl_events Trigger
DROP TABLE IF EXISTS dbo.AuditDDLEvents;

CREATE TABLE dbo.AuditDDLEvents
(
  audit_lsn        INT          NOT NULL IDENTITY,
  posttime         DATETIME2(3) NOT NULL,
  eventtype        sysname      NOT NULL,
  loginname        sysname      NOT NULL,
  schemaname       sysname      NOT NULL,
  objectname       sysname      NOT NULL,
  targetobjectname sysname      NULL,
  eventdata        XML          NOT NULL,
  CONSTRAINT PK_AuditDDLEvents PRIMARY KEY(audit_lsn)
);
GO

CREATE TRIGGER trg_audit_ddl_events
  ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
SET NOCOUNT ON;

DECLARE @eventdata AS XML = EVENTDATA();

INSERT INTO dbo.AuditDDLEvents(
  posttime, eventtype, loginname, schemaname, 
  objectname, targetobjectname, eventdata)
  VALUES(
    @eventdata.value('(/EVENT_INSTANCE/PostTime)[1]',         'VARCHAR(23)'),
    @eventdata.value('(/EVENT_INSTANCE/EventType)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/LoginName)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/SchemaName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/ObjectName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname'),
    @eventdata);
GO

-- Test trigger trg_audit_ddl_events
CREATE TABLE dbo.T1(col1 INT NOT NULL PRIMARY KEY);
ALTER TABLE dbo.T1 ADD col2 INT NULL;
ALTER TABLE dbo.T1 ALTER COLUMN col2 INT NOT NULL;
CREATE NONCLUSTERED INDEX idx1 ON dbo.T1(col2);
GO

SELECT * FROM dbo.AuditDDLEvents;
GO

-- Cleanup
DROP TRIGGER IF EXISTS trg_audit_ddl_events ON DATABASE;
DROP TABLE IF EXISTS dbo.AuditDDLEvents;
GO

