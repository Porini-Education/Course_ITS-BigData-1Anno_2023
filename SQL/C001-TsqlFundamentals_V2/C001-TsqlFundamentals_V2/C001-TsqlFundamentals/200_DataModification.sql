Use Test_C001
go
---------------------------------------------------------------------
-- Inserting Data
---------------------------------------------------------------------

-- INSERT VALUES

drop table if exists dbo.T_Insert;
GO
create table dbo.T_Insert (
	Id int, 
	Label varchar(20), 
	Giorno date default getdate(), 
	Flag int null
	);

insert into dbo.T_Insert (Id,Label) values
(1,'alfa'), (2,'bravo'),(3,'charlie');

insert into dbo.T_Insert (Id,Label,Giorno,Flag) values
(4,'delta','20021105',1);

select * from dbo.T_Insert

-- INSERT SELECT
drop table if exists dbo.T_Insert2;
GO
create table dbo.T_Insert2 (
	Id int, 
	Label varchar(20), 
	Tempo datetime, 
	Id2 uniqueidentifier
	);
GO

insert into dbo.T_Insert2
select n, 'L' + convert(varchar(10),n),SYSDATETIME(), newid()
from util.fn_nums (10000)

select * from dbo.T_Insert2

-- INSERT EXEC
drop procedure if exists dbo.usp_InsertData;
GO

create procedure dbo.usp_insertdata @N int
as
	select n, 'P' + convert(varchar(10),n),SYSDATETIME(), newid()
	from util.fn_nums (@N)
	;
GO

truncate table dbo.T_insert2
GO

insert into dbo.T_Insert2
exec dbo.usp_insertdata 10
;

select * from dbo.T_Insert2

-- BULK INSERT
BULK INSERT dbo.Orders FROM 'c:\temp\orders.txt'
  WITH 
    (
       DATAFILETYPE    = 'char',
       FIELDTERMINATOR = ',',
       ROWTERMINATOR   = '\n'
    );
GO

drop table if exists dbo.T_Insert3;
GO

create table dbo.T_Insert3 
	(id smallint identity(10,1),
	Label varchar(20) check (Label LIKE '[ABC]%')
	);
GO

--create table dbo.T_Insert3 
--	(id smallint identity(0,-1),
--	Label varchar(20) check (Label LIKE '[ABC]%')
--	);
--GO

insert into dbo.T_Insert3 values 
('Alfa'),('Bravo'),('Charlie'),('Delta'), ('AlfaAlfa')
;

select * from dbo.T_Insert3; -- Nessuna inserita (transaszione)

insert into dbo.T_Insert3 values ('Alfa');
insert into dbo.T_Insert3 values ('Bravo');
insert into dbo.T_Insert3 values ('Charlie');
insert into dbo.T_Insert3 values ('Delta');
insert into dbo.T_Insert3 values ('AlfaAlfa');

select * from dbo.T_Insert3; -- Nel rollback l'identity prosegue

truncate table dbo.T_Insert3; -- truncate resetta l'Identity
GO

insert into dbo.T_Insert3 values ('Alfa');
insert into dbo.T_Insert3 values ('Bravo');
insert into dbo.T_Insert3 values ('Charlie');
insert into dbo.T_Insert3 values ('Delta');
insert into dbo.T_Insert3 values ('AlfaAlfa');

select * from dbo.T_Insert3;

select $identity from dbo.T_Insert3;


-- Inserimento esplicito di valori nel campo identity
SET IDENTITY_INSERT dbo.T_Insert3 ON;

INSERT INTO dbo.T_Insert3(id, Label) VALUES(5, 'Bravo2');
INSERT INTO dbo.T_Insert3(id, Label) VALUES(5, 'Bravo3');
INSERT INTO dbo.T_Insert3(id, Label) VALUES(5, 'Bravo4');

SET IDENTITY_INSERT dbo.T_Insert3 OFF;

select * from dbo.T_Insert3;
INSERT INTO dbo.T_Insert3(Label) VALUES('Charlie2');

select * from dbo.T_Insert3; -- l'identity riprende dall'ultimo valore inserito automaticamente

	SELECT
	  SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	  @@identity AS [@@identity],
	  IDENT_CURRENT('dbo.T_insert3') AS [IDENT_CURRENT];
	GO

	-- sessione 1 e sessione 2 
	-- il valore viene assegnato all'inizio della transazione
	Begin Tran
	INSERT INTO dbo.T_Insert3(Label) VALUES('Charlie100');

	select @@IDENTITY, SCOPE_IDENTITY()
	Commit
	select @@IDENTITY, SCOPE_IDENTITY()

	
drop table if exists dbo.T_Insert4;
GO
select identity (int,1,1) IDNew, Label 
into dbo.T_Insert4 
from dbo.T_Insert3
;
GO

select * from dbo.T_Insert4;
GO


-----    SEQUENCES

DROP SEQUENCE IF EXISTS dbo.Seq01;

CREATE SEQUENCE dbo.Seq01 AS INT
  MINVALUE 1
  CYCLE
 ;

DROP SEQUENCE IF EXISTS dbo.Seq02;

CREATE SEQUENCE dbo.Seq02 AS INT
  MINVALUE 100
  INCREMENT BY 10
 ;

SELECT NEXT VALUE FOR dbo.Seq01;
GO
SELECT NEXT VALUE FOR dbo.Seq01;
GO
SELECT NEXT VALUE FOR dbo.Seq02;
GO
SELECT NEXT VALUE FOR dbo.Seq02;
GO

/*
ALTER SEQUENCE dbo.Seq01
  RESTART WITH <constant>
  INCREMENT BY <constant>
  MINVALUE <constant> | NO MINVALUE
  MAXVALUE <constant> | NO MAXVALUE
  CYCLE | NO CYCLE
  CACHE <constant> | NO CACHE;
*/

DROP SEQUENCE IF EXISTS dbo.Seq;
GO
CREATE SEQUENCE dbo.Seq
	  START WITH 5
	  INCREMENT BY 1
	  MINVALUE 0
	  MAXVALUE 10
	  NO CYCLE
	  NO CACHE
	  ;

SELECT NEXT VALUE FOR dbo.Seq; --5
SELECT NEXT VALUE FOR dbo.Seq;
SELECT NEXT VALUE FOR dbo.Seq;
SELECT NEXT VALUE FOR dbo.Seq;
SELECT NEXT VALUE FOR dbo.Seq;
SELECT NEXT VALUE FOR dbo.Seq; --10
SELECT NEXT VALUE FOR dbo.Seq; -- errore

ALTER SEQUENCE dbo.Seq
  RESTART WITH 8
  CYCLE
  ;
  GO
SELECT NEXT VALUE FOR dbo.Seq; --8
SELECT NEXT VALUE FOR dbo.Seq;
SELECT NEXT VALUE FOR dbo.Seq; --10
SELECT NEXT VALUE FOR dbo.Seq; -- 0 è ripartita la sequenza


---  utilizzo di sequence e clausola over
DROP SEQUENCE IF EXISTS dbo.Seq01;

CREATE SEQUENCE dbo.Seq01 AS INT
  MINVALUE 1
  INCREMENT BY 1
  CYCLE
 ;

drop table if exists dbo.Luogo;
go
create table dbo.Luogo (Citta varchar(50), Regione varchar(50));
GO
insert into dbo.Luogo values 
('Milano', 'Lombardia'),
('Torino', 'Piemonte'), 
('Brescia','Lombardia'),
('Como', 'Lombardia'),
('Bologna', 'Emilia'),
('Asti','Piemonte')
;
GO

select 
	next value for dbo.Seq01
	over ( order by Citta) as Id,
Citta, Regione
from dbo.Luogo
order by Regione

---- DELETE


--- UPDATE


-- Contatore Sequence Custom
DROP TABLE IF EXISTS dbo.Contatore;

CREATE TABLE dbo.Contatore
(
  id int primary key
);
INSERT INTO dbo.Contatore VALUES( 0);
GO

-- utilizzo
DECLARE @nextid AS INT;

UPDATE dbo.Contatore
  SET @nextid = id = id + 1
;

SELECT @nextid;


-- DELETE non rimuove il numero di pagine da un HEAP

-- Clusterd Index
drop table if exists dbo.DeleteRecordTable;
go

CREATE TABLE dbo.DeleteRecordTable 
	(Id int identity(1,1)  CONSTRAINT PK_Id PRIMARY KEY,
	Codice varchar (12),
	Label1 char (500),
	label2 char (500)
	);
go

-- 7000 record, 1000 pagine
-- 7 record per pagina
insert into dbo.DeleteRecordTable
select 
'A' + format (n,'000000'),
'TestoLabel1',
'TestoLabel2'
from util.fn_nums(7000)
;


select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- 1000 DataPages

DBCC TRACEON(3604); 
DBCC IND('Test_C001','dbo.DeleteRecordTable',-1) WITH NO_INFOMSGS; 


set statistics io on;
set statistics time on;

select * from DeleteRecordTable where Codice= 'A000010' -- 1005 pagine lette

--elimino 200 record random

with cteA
as
(
select top 200 id
from dbo.DeleteRecordTable d
order by 
		checksum(newid())
)
delete from cteA
;

select count (*) from dbo.DeleteRecordTable; --6800

select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- sempre 1000 DataPages
select * from DeleteRecordTable where Codice= 'A000010' -- 1005 pagine lette

	--alter index pk_id on dbo.DeleteRecordTable rebuild ;
	--select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; --973 data page


-- elimino la prima metà di record
delete from dbo.DeleteRecordTable where id < 3500

select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- 502 DataPages
select * from DeleteRecordTable where Codice= 'A000010' -- 507 pagine lette

alter index pk_id on dbo.DeleteRecordTable rebuild ;
select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; --484 data page

--- HEAP
drop table if exists dbo.DeleteRecordTable;
go

CREATE TABLE dbo.DeleteRecordTable 
	(Id int identity(1,1) ,
	Codice varchar (12),
	Label1 char (500),
	label2 char (500)
	);
go

-- 7000 record, 1000 pagine
-- 7 record per pagina
insert into dbo.DeleteRecordTable
select 
'A' + format (n,'000000'),
'TestoLabel1',
'TestoLabel2'
from util.fn_nums(7000)
;


select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- 1000 DataPages

DBCC TRACEON(3604); 
DBCC IND('Test_C001','dbo.DeleteRecordTable',-1) WITH NO_INFOMSGS; 

set statistics io on;
set statistics time on;

select * from DeleteRecordTable where Codice= 'A000010' -- 1000 pagine lette

--elimino 200 record random

with cteA
as
(
select top 200 id
from dbo.DeleteRecordTable d
order by 
		checksum(newid())
)
delete from cteA
;

select count (*) from dbo.DeleteRecordTable; --6800

select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- sempre 1000 DataPages
select * from DeleteRecordTable where Codice= 'A000010' -- 1000 pagine lette


-- elimino la prima metà di record
delete from dbo.DeleteRecordTable where id < 3500

select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- sempre 1000 DataPages

select * from DeleteRecordTable where Codice= 'A000010' -- 1000 pagine lette

DBCC TRACEON(3604); 
DBCC IND('Test_C001','dbo.DeleteRecordTable',-1) WITH NO_INFOMSGS; 

DBCC PAGE('Test_C001',3,240304,3) WITH TABLERESULTS;  -- Vuota ma allocata

alter table dbo.DeleteRecordTable rebuild;

select * from util.vw_Info_Table where object_name='DeleteRecordTable' ; -- sempre 486 DataPages

select * from DeleteRecordTable where Codice= 'A000010' -- 486 pagine lette


--------------

USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT         NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE        NOT NULL
    CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
  empid     INT         NOT NULL,
  custid    VARCHAR(10) NOT NULL
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  VALUES(10001, '20160212', 3, 'A');

INSERT INTO dbo.Orders(orderid, empid, custid)
  VALUES(10002, 5, 'B');

INSERT INTO dbo.Orders
  (orderid, orderdate, empid, custid)
VALUES
  (10003, '20160213', 4, 'B'),
  (10004, '20160214', 1, 'A'),
  (10005, '20160213', 1, 'C'),
  (10006, '20160215', 3, 'C');

SELECT *
FROM ( VALUES
         (10003, '20160213', 4, 'B'),
         (10004, '20160214', 1, 'A'),
         (10005, '20160213', 1, 'C'),
         (10006, '20160215', 3, 'C') )
     AS O(orderid, orderdate, empid, custid);

---------------------------------------------------------------------
-- INSERT SELECT
---------------------------------------------------------------------

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  SELECT orderid, orderdate, empid, custid
  FROM Sales.Orders
  WHERE shipcountry = N'UK';

---------------------------------------------------------------------
-- INSERT EXEC
---------------------------------------------------------------------

DROP PROC IF EXISTS Sales.GetOrders;
GO

CREATE PROC Sales.GetOrders
  @country AS NVARCHAR(40)
AS

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = @country;
GO

EXEC Sales.GetOrders @country = N'France';

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  EXEC Sales.GetOrders @country = N'France';

---------------------------------------------------------------------
-- SELECT INTO
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders;

SELECT orderid, orderdate, empid, custid
INTO dbo.Orders
FROM Sales.Orders;

-- SELECT INTO with Set Operations
DROP TABLE IF EXISTS dbo.Locations;

SELECT country, region, city
INTO dbo.Locations
FROM Sales.Customers

EXCEPT

SELECT country, region, city
FROM HR.Employees;
GO

---------------------------------------------------------------------
-- BULK INSERT
---------------------------------------------------------------------

BULK INSERT dbo.Orders FROM 'c:\temp\orders.txt'
  WITH 
    (
       DATAFILETYPE    = 'char',
       FIELDTERMINATOR = ',',
       ROWTERMINATOR   = '\n'
    );
GO

---------------------------------------------------------------------
-- The IDENTITY Property and Sequence Object
---------------------------------------------------------------------

---------------------------------------------------------------------
-- IDENTITY
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL IDENTITY(1, 1)
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
    CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%')
);
GO

INSERT INTO dbo.T1(datacol) VALUES('AAAAA'),('CCCCC'),('BBBBB');

SELECT * FROM dbo.T1;

SELECT $identity FROM dbo.T1; 

-- Using SCOPE_IDENTITY
DECLARE @new_key AS INT;

INSERT INTO dbo.T1(datacol) VALUES('AAAAA');

SET @new_key = SCOPE_IDENTITY();

SELECT @new_key AS new_key

-- Run from another connection
SELECT
  SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
  @@identity AS [@@identity],
  IDENT_CURRENT(N'dbo.T1') AS [IDENT_CURRENT];
GO

-- Run insert statements
INSERT INTO dbo.T1(datacol) VALUES('12345');
GO
INSERT INTO dbo.T1(datacol) VALUES('EEEEE');
GO

SELECT * FROM dbo.T1;

-- Using IDENTITY_INSERT 
SET IDENTITY_INSERT dbo.T1 ON;
INSERT INTO dbo.T1(keycol, datacol) VALUES(5, 'FFFFF');
SET IDENTITY_INSERT dbo.T1 OFF;

INSERT INTO dbo.T1(datacol) VALUES('GGGGG');

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Sequence Object
---------------------------------------------------------------------

-- create sequence and request value
DROP SEQUENCE IF EXISTS dbo.SeqOrderIDs;

CREATE SEQUENCE dbo.SeqOrderIDs AS INT
  MINVALUE 1
  CYCLE;

/*
ALTER SEQUENCE dbo.SeqOrderIDs
  RESTART WITH <constant>
  INCREMENT BY <constant>
  MINVALUE <constant> | NO MINVALUE
  MAXVALUE <constant> | NO MAXVALUE
  CYCLE | NO CYCLE
  CACHE <constant> | NO CACHE;
*/

ALTER SEQUENCE dbo.SeqOrderIDs
  NO CYCLE;

-- use
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;
GO

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);
GO

DECLARE @neworderid AS INT = NEXT VALUE FOR dbo.SeqOrderIDs;
INSERT INTO dbo.T1(keycol, datacol) VALUES(@neworderid, 'a');

SELECT * FROM dbo.T1;
GO


INSERT INTO dbo.T1(keycol, datacol)
  VALUES(NEXT VALUE FOR dbo.SeqOrderIDs, 'b');

SELECT * FROM dbo.T1;
GO

UPDATE dbo.T1
  SET keycol = NEXT VALUE FOR dbo.SeqOrderIDs;

SELECT * FROM dbo.T1;
GO

-- info
SELECT current_value
FROM sys.sequences
WHERE OBJECT_ID = OBJECT_ID(N'dbo.SeqOrderIDs');

-- order
INSERT INTO dbo.T1(keycol, datacol)
  SELECT
    NEXT VALUE FOR dbo.SeqOrderIDs OVER(ORDER BY hiredate),
    LEFT(firstname, 1) + LEFT(lastname, 1)
  FROM HR.Employees;

SELECT * FROM dbo.T1;
GO

ALTER TABLE dbo.T1
  ADD CONSTRAINT DFT_T1_keycol
    DEFAULT (NEXT VALUE FOR dbo.SeqOrderIDs)
    FOR keycol;

INSERT INTO dbo.T1(datacol) VALUES('c');

SELECT * FROM dbo.T1;
GO

-- range
DECLARE @first AS SQL_VARIANT;

EXEC sys.sp_sequence_get_range
  @sequence_name     = N'dbo.SeqOrderIDs',
  @range_size        = 1000000,
  @range_first_value = @first OUTPUT ;

SELECT @first;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1;
DROP SEQUENCE IF EXISTS dbo.SeqOrderIDs;
GO

---------------------------------------------------------------------
-- Deleting Data
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid       INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES dbo.Customers(custid)
);
GO

INSERT INTO dbo.Customers SELECT * FROM Sales.Customers;
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

---------------------------------------------------------------------
-- DELETE Statement
---------------------------------------------------------------------

DELETE FROM dbo.Orders
WHERE orderdate < '20150101';
GO

---------------------------------------------------------------------
-- TRUNCATE
---------------------------------------------------------------------

-- Code to create the table T1 (partitioned) if you want to run the examples that follow
DROP TABLE IF EXISTS dbo.T1;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'PS1') DROP PARTITION SCHEME PS1;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'PF1') DROP PARTITION FUNCTION PF1;

CREATE PARTITION FUNCTION PF1 (INT) AS RANGE LEFT FOR VALUES (10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120);
CREATE PARTITION SCHEME PS1 AS PARTITION PF1 ALL TO ([PRIMARY]);

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol INT NOT NULL
) ON PS1(keycol);
GO

-- TRUNCATE statement examples
TRUNCATE TABLE dbo.T1;
GO

TRUNCATE TABLE dbo.T1 WITH ( PARTITIONS(1, 3, 5, 7 TO 10) );
GO

-- Cleanup
DROP TABLE IF EXISTS dbo.T1;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'PS1') DROP PARTITION SCHEME PS1;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'PF1') DROP PARTITION FUNCTION PF1;

---------------------------------------------------------------------
-- DELETE Based on Join
---------------------------------------------------------------------

-- Using a join
DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'USA';

-- Using a subquery
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM dbo.Customers AS C
   WHERE Orders.custid = C.custid
     AND C.country = N'USA');

-- cleanup
DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

---------------------------------------------------------------------
-- Updating Data
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

---------------------------------------------------------------------
-- UPDATE Statement
---------------------------------------------------------------------

-- Code to create tables T1 and T2 if you want to run the examples that follow
DROP TABLE IF EXISTS dbo.T1, dbo.T2;

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  col3 INT NOT NULL,
  col4 VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T2
(
  keycol INT NOT NULL
    CONSTRAINT PK_T2 PRIMARY KEY,
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  col3 INT NOT NULL,
  col4 VARCHAR(10) NOT NULL
);
GO

-- UPDATE examples
UPDATE dbo.OrderDetails
  SET discount = discount + 0.05
WHERE productid = 51;

-- Compund assignment operators
UPDATE dbo.OrderDetails
  SET discount += 0.05
WHERE productid = 51;
GO

UPDATE dbo.T1
  SET col1 = col1 + 10, col2 = col1 + 10;
GO

UPDATE dbo.T1
  SET col1 = col2, col2 = col1;
GO

---------------------------------------------------------------------
-- UPDATE Based on Join
---------------------------------------------------------------------

-- Listing 8-1?Update Based on Join
UPDATE OD
  SET discount += 0.05
FROM dbo.OrderDetails AS OD
  INNER JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE O.custid = 1;

UPDATE dbo.OrderDetails
  SET discount += 0.05
WHERE EXISTS
  (SELECT * FROM dbo.Orders AS O
   WHERE O.orderid = OrderDetails.orderid
     AND custid = 1);
GO

UPDATE T1
  SET col1 = T2.col1,
      col2 = T2.col2,
      col3 = T2.col3
FROM dbo.T1 JOIN dbo.T2
  ON T2.keycol = T1.keycol
WHERE T2.col4 = 'ABC';
GO

UPDATE dbo.T1
  SET col1 = (SELECT col1
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
              
      col2 = (SELECT col2
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol),
      
      col3 = (SELECT col3
              FROM dbo.T2
              WHERE T2.keycol = T1.keycol)
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');
GO

/*
UPDATE dbo.T1

  SET (col1, col2, col3) =

      (SELECT col1, col2, col3
       FROM dbo.T2
       WHERE T2.keycol = T1.keycol)
       
WHERE EXISTS
  (SELECT *
   FROM dbo.T2
   WHERE T2.keycol = T1.keycol
     AND T2.col4 = 'ABC');
*/     
GO

-- Cleanup
DROP TABLE IF EXISTS dbo.T1, dbo.T2;
        
---------------------------------------------------------------------
-- Assignment UPDATE
---------------------------------------------------------------------

-- Custom Sequence
DROP TABLE IF EXISTS dbo.MySequences;

CREATE TABLE dbo.MySequences
(
  id VARCHAR(10) NOT NULL
    CONSTRAINT PK_Sequences PRIMARY KEY(id),
  val INT NOT NULL
);
INSERT INTO dbo.MySequences VALUES('SEQ1', 0);
GO

DECLARE @nextval AS INT;

UPDATE dbo.MySequences
  SET @nextval = val += 1
WHERE id = 'SEQ1';

SELECT @nextval;

-- cleanup
DROP TABLE IF EXISTS dbo.MySequences;

---------------------------------------------------------------------
-- Merging Data
---------------------------------------------------------------------

-- Listing 8-2?Code that Creates and Populates Customers and CustomersStage
DROP TABLE IF EXISTS dbo.Customers, dbo.CustomersStage;
GO

CREATE TABLE dbo.Customers
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES
  (1, 'cust 1', '(111) 111-1111', 'address 1'),
  (2, 'cust 2', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (4, 'cust 4', '(444) 444-4444', 'address 4'),
  (5, 'cust 5', '(555) 555-5555', 'address 5');

CREATE TABLE dbo.CustomersStage
(
  custid      INT         NOT NULL,
  companyname VARCHAR(25) NOT NULL,
  phone       VARCHAR(20) NOT NULL,
  address     VARCHAR(50) NOT NULL,
  CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);

INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
  (2, 'AAAAA', '(222) 222-2222', 'address 2'),
  (3, 'cust 3', '(333) 333-3333', 'address 3'),
  (5, 'BBBBB', 'CCCCC', 'DDDDD'),
  (6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
  (7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

-- Query tables
SELECT * FROM dbo.Customers;

SELECT * FROM dbo.CustomersStage;

-- MERGE Example 1: Update existing, add missing
MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, 'xxxxx', SRC.address);

-- Query table
SELECT * FROM dbo.Customers; 

-- MERGE Example 2: Update existing, add missing, delete missing in source
MERGE dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

-- Query table
SELECT * FROM dbo.Customers; 

-- MERGE Example 3: Update existing that changed, add missing
MERGE dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED AND 
       (   TGT.companyname <> SRC.companyname
        OR TGT.phone       <> SRC.phone
        OR TGT.address     <> SRC.address) THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address);

---------------------------------------------------------------------
-- Modifying Data through Table Expressions
---------------------------------------------------------------------

UPDATE OD
  SET discount += 0.05
FROM dbo.OrderDetails AS OD
  INNER JOIN dbo.Orders AS O
    ON OD.orderid = O.orderid
WHERE O.custid = 1;

-- CTE
WITH C AS
(
  SELECT custid, OD.orderid,
    productid, discount, discount + 0.05 AS newdiscount
  FROM dbo.OrderDetails AS OD
    INNER JOIN dbo.Orders AS O
      ON OD.orderid = O.orderid
  WHERE O.custid = 1
)
UPDATE C
  SET discount = newdiscount;

-- Derived Table
UPDATE D
  SET discount = newdiscount
FROM ( SELECT custid, OD.orderid,
         productid, discount, discount + 0.05 AS newdiscount
       FROM dbo.OrderDetails AS OD
         INNER JOIN dbo.Orders AS O
           ON OD.orderid = O.orderid
       WHERE O.custid = 1 ) AS D;

-- Update with row numbers
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT NOT NULL IDENTITY PRIMARY KEY, col1 INT, col2 INT);
GO

INSERT INTO dbo.T1(col1) VALUES(20),(10),(30);

SELECT * FROM dbo.T1;
GO

UPDATE dbo.T1
  SET col2 = ROW_NUMBER() OVER(ORDER BY col1);

/*
Msg 4108, Level 15, State 1, Line 672
Windowed functions can only appear in the SELECT or ORDER BY clauses.
*/
GO
  
	WITH C AS
	(
	  SELECT col1, col2, ROW_NUMBER() OVER(ORDER BY col1) AS rownum
	  FROM dbo.T1
	)
	UPDATE C
	  SET col2 = rownum;

SELECT col1, col2 FROM dbo.T1;

---------------------------------------------------------------------
-- Modifications with TOP and OFFSET-FETCH
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

DELETE TOP(50) FROM dbo.Orders;

UPDATE TOP(50) dbo.Orders
  SET freight += 10.00;

-- TOP

	WITH C AS
	(
	  SELECT TOP (50) *
	  FROM dbo.Orders
	  ORDER BY orderid
	)
	DELETE FROM C;

WITH C AS
(
  SELECT TOP (50) *
  FROM dbo.Orders
  ORDER BY orderid DESC
)
UPDATE C
  SET freight += 10.00;

-- OFFSET-FETCH
WITH C AS
(
  SELECT *
  FROM dbo.Orders
  ORDER BY orderid
  OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY
)
DELETE FROM C;

WITH C AS
(
  SELECT *
  FROM dbo.Orders
  ORDER BY orderid DESC
  OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY
)
UPDATE C
  SET freight += 10.00;

---------------------------------------------------------------------
-- OUTPUT
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.T1;
GO

	CREATE TABLE dbo.T1
	(
	  keycol  INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_T1 PRIMARY KEY,
	  datacol NVARCHAR(40) NOT NULL
	);

	INSERT INTO dbo.T1(datacol)
		OUTPUT inserted.keycol, inserted.datacol
		SELECT data
		FROM Employees
		WHERE country = N'USA';
	GO

select * from dbo.T1

DECLARE @NewRows TABLE(keycol INT, datacol NVARCHAR(40));

INSERT INTO dbo.T1(datacol)
--OUTPUT inserted.keycol, inserted.datacol
-------INTO @NewRows(keycol, datacol)
    SELECT lastname
    FROM HR.Employees
    WHERE country = N'UK';

SELECT * FROM @NewRows;

---------------------------------------------------------------------
-- DELETE with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

DELETE FROM dbo.Orders
  OUTPUT
    deleted.orderid,
    deleted.orderdate,
    deleted.empid,
    deleted.custid
WHERE orderdate < '20160101';

select * from Orders

create table #Eliminati (orderid int);
GO

DELETE FROM dbo.Orders
  OUTPUT
    deleted.orderid
into #Eliminati
WHERE orderdate < '20160101';

select * from #Eliminati;

---------------------------------------------------------------------
-- UPDATE with OUTPUT
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.OrderDetails;

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

select * from dbo.OrderDetails


UPDATE dbo.OrderDetails
  SET discount += 0.05
OUTPUT
  inserted.orderid,
  inserted.productid,
  deleted.discount AS olddiscount,
  inserted.discount AS newdiscount
WHERE productid = 51;

---------------------------------------------------------------------
-- MERGE with OUTPUT
---------------------------------------------------------------------

-- First, run Listing 8-2 to recreate Customers and CustomersStage

MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
  ON TGT.custid = SRC.custid
WHEN MATCHED THEN
  UPDATE SET
    TGT.companyname = SRC.companyname,
    TGT.phone = SRC.phone,
    TGT.address = SRC.address
WHEN NOT MATCHED THEN 
  INSERT (custid, companyname, phone, address)
  VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
OUTPUT $action AS theaction, inserted.custid,
  deleted.companyname AS oldcompanyname,
  inserted.companyname AS newcompanyname,
  deleted.phone AS oldphone,
  inserted.phone AS newphone,
  deleted.address AS oldaddress,
  inserted.address AS newaddress;

---------------------------------------------------------------------
-- Nested DML
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.ProductsAudit, dbo.Products;

CREATE TABLE dbo.Products
(
  productid    INT          NOT NULL,
  productname  NVARCHAR(40) NOT NULL,
  supplierid   INT          NOT NULL,
  categoryid   INT          NOT NULL,
  unitprice    MONEY        NOT NULL
    CONSTRAINT DFT_Products_unitprice DEFAULT(0),
  discontinued BIT          NOT NULL 
    CONSTRAINT DFT_Products_discontinued DEFAULT(0),
  CONSTRAINT PK_Products PRIMARY KEY(productid),
  CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

INSERT INTO dbo.Products SELECT * FROM Production.Products;

CREATE TABLE dbo.ProductsAudit
(
  LSN INT NOT NULL IDENTITY PRIMARY KEY,
  TS DATETIME2 NOT NULL DEFAULT(SYSDATETIME()),
  productid INT NOT NULL,
  colname SYSNAME NOT NULL,
  oldval SQL_VARIANT NOT NULL,
  newval SQL_VARIANT NOT NULL
);

	INSERT INTO dbo.ProductsAudit(productid, colname, oldval, newval)
	  SELECT productid, N'unitprice', oldval, newval
	  FROM (UPDATE dbo.Products
			  SET unitprice *= 1.15
			OUTPUT 
			  inserted.productid,
			  deleted.unitprice AS oldval,
			  inserted.unitprice AS newval
			WHERE supplierid = 1) AS D
	  WHERE oldval < 20.0 AND newval >= 20.0;

SELECT * FROM dbo.ProductsAudit;

-- cleanup
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.ProductsAudit, dbo.Products,
  dbo.Orders, dbo.Customers, dbo.T1, dbo.MySequences, dbo.CustomersStage;
