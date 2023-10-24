
---------------------------------------------------------------------
-- Temporary Tables
---------------------------------------------------------------------
use Test_C001
go


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

-- Global Temporary Tables
CREATE TABLE ##Globals
(
  id  sysname     NOT NULL PRIMARY KEY,
  val SQL_VARIANT NOT NULL
);

-- Run from any session
INSERT INTO ##Globals(id, val) VALUES(N'i', CAST(10 AS INT));

-- Run from any session
SELECT val FROM ##Globals WHERE id = N'i';

-- Run from any session
DROP TABLE IF EXISTS ##Globals;
GO

create table #tc1  (id int, label varchar(20))
insert into #tc1 values (1, 'alfa'),(2,'bravo');
---- Table Variable

DECLARE @Poldo TABLE (id int, label varchar(20));

--select * into @Poldo from #tc
insert into @Poldo select * from #tc1

--insert into @Poldo  values (1, 'alfa'),(2,'bravo');

select * from @Poldo;
GO

-- non hanno rollback
DECLARE @Poldo TABLE (id int, label varchar(20));

begin tran
	insert into @Poldo  values (1, 'alfa'),(2,'bravo');
rollback

insert into @Poldo  values (3, 'charlie');
select * from @Poldo;

GO

-- le temporanee si
create table #Poldo2 (id int, label varchar(20));

begin tran
	insert into #Poldo  values (1, 'alfa'),(2,'bravo');
rollback

insert into #Poldo  values (3, 'charlie');

select * from #Poldo;
GO

-- Table Type

drop TYPE if exists dbo.TabellaLibri;
GO

CREATE TYPE dbo.TabellaLibri as TABLE
(
	IdBook int identity (1,1),
	Titolo varchar(200) unique,
	Autore varchar(100) ,
	Giacenza int default 0
);
GO

-- errore chiave duplicata

declare @T as dbo.TabellaLibri

insert into @T (Titolo, Autore)
values ('Finzioni', 'Borges'), ('Illusioni', 'Bach');

select * from @T;

insert into @T (Titolo, Autore)
values ('Finzioni', 'Borges');

select * from @T;

GO

---  errore gestito

declare @T as dbo.TabellaLibri

BEGIN TRY
	insert into @T (Titolo, Autore)
	values ('Finzioni', 'Borges'), ('Illusioni', 'Bach');
	select * from @T;
END TRY
BEGIN CATCH
	print 'errore' + ERROR_NUMBER()
END CATCH

BEGIN TRY
	insert into @T (Titolo, Autore)
	values ('Finzioni', 'Borges');
	select * from @T;
END TRY
BEGIN CATCH
	select 'errore ' + convert (varchar(20), ERROR_NUMBER())
	select 'Error Message : ' + ERROR_MESSAGE();

IF ERROR_NUMBER() = 2627
  BEGIN
    Select 'Valore duplicato';
 END;
END CATCH
GO


-- Esempio utilizzo Table Variable per passare più dati ad una TableFunction
drop table if exists dbo.vendite;
GO

create table dbo.vendite (quantita int , valore numeric(8,2)) ;
GO

insert into dbo.vendite values
(100,3240.4), (200, 123.4), (300, 6008)

select * from dbo.vendite
----


CREATE TYPE dbo.TVendite as TABLE
(
	Pezzi int ,
	Valore numeric(8,2)
);
GO

create function Media 
	(@T as dbo.TVendite  READONLY )
returns TABLE
as return
select avg(Pezzi) as Mp, avg(Valore) as Mv
from @T
;
GO

declare @TV as TVendite  ;
insert @TV select * from dbo.vendite;
select *  from Media (@TV)



-- DMV
SELECT
  *
FROM
  sys.dm_os_performance_counters
WHERE
  (counter_name LIKE '%Tables%')
  --and (counter_name = 'Temp Tables Creation Rate');
GO

SELECT
    DOMCC.[type],
    DOMCC.pages_kb,
    DOMCC.pages_in_use_kb,
    DOMCC.entries_count,
    DOMCC.entries_in_use_count
FROM sys.dm_os_memory_cache_counters AS DOMCC 
WHERE 
    DOMCC.[name] = N'Temporary Tables & Table Variables';
GO

-- https://sqlperformance.com/2017/05/sql-performance/sql-server-temporary-object-caching
-- https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-1230-tempdb-should-always-have-one-data-file-per-processor-core/


create table #t1 (id int);

drop table #t

---

-- Caching tempDb Table
--https://sqlperformance.com/2017/05/sql-performance/sql-server-temporary-object-caching

SELECT
    DOMCC.[type],
    DOMCC.pages_kb,
    DOMCC.pages_in_use_kb,
    DOMCC.entries_count,
    DOMCC.entries_in_use_count
FROM sys.dm_os_memory_cache_counters AS DOMCC 
WHERE 
    DOMCC.[name] = N'Temporary Tables & Table Variables';

	select * from tempdb.sys.tables --113

SELECT
   *
  FROM
    sys.dm_os_performance_counters
  WHERE
    (counter_name = 'Temp Tables Creation Rate'); --2137

	create table #pippo (id int)
