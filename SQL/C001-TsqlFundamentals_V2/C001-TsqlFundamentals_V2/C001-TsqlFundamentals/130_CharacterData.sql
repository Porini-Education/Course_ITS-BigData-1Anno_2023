use Test_C001
go


-- Working with Character Data


-- Concatenation
SELECT empid, firstname + N' ' + lastname AS fullname
FROM HR.Employees;

-- Listing 2-7: Query Demonstrating String Concatenation
SELECT custid, country, region, city,
  country + N',' + region + N',' + city AS location
FROM Sales.Customers;

-- convert NULL to empty string
SELECT custid, country, region, city,
  country + COALESCE( N',' + region, N'') + N',' + city AS location
FROM Sales.Customers;

-- using the CONCAT function
SELECT custid, country, region, city,
  CONCAT(country, N',' + region, N',' + city) AS location
FROM Sales.Customers;




-- Functions
SELECT SUBSTRING('abcde', 1, 3); -- 'abc'

SELECT RIGHT('abcde', 3); -- 'cde'

SELECT LEN('abcde'); -- 5
SELECT DATALENGTH('abcde'); -- 5

SELECT LEN(N'abcde'); -- 5
SELECT DATALENGTH(N'abcde'); -- 10

SELECT CHARINDEX('r','Franco Pigoli'); -- 7

SELECT PATINDEX('%[0-9]%', 'abcd123efgh'); -- 5

SELECT REPLACE('1-a 2-b', '-', ':'); -- '1:a 2:b'

-- numero di volte in cui appare il carattere e
SELECT empid, lastname,
  LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numoccur
FROM HR.Employees;

SELECT REPLICATE('abc', 3); -- 'abcabcabc'

SELECT ProductID,
  RIGHT(REPLICATE('0', 9) + CAST(ProductID AS VARCHAR(10)),
        10) AS strProductID
FROM Production.Products;

SELECT STUFF('parigi', 3, 2, 'xx'); -- 'pa34gi' -> stuff('expression', start, len, 'replace')

SELECT STUFF('123456789', 2, 5, 'abc'); -- '1abc789' Eliminati 5 caratteri


SELECT UPPER('Poldo'); 

SELECT LOWER('Poldo'); 

SELECT RTRIM(LTRIM('   abc   ')); -- 'abc'

SELECT FORMAT(1759, '0000000000'); -- '0000001759'


declare @dt date = '20180502';
select FORMAT (@dt , 'MM-dd-yyyy');


-- COMPRESS
SELECT COMPRESS(N'This is my cv. Imagine it was much longer.');

-- DECOMPRESS
SELECT DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'));

SELECT
  CAST(
    DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'))
      AS NVARCHAR(MAX));


--create table #Tcomp (id int, nota varchar(max)) ;
--insert into #Tcomp values (1,'alfa alfa'), (2,'alfa alfa'), (3,'beta');
--GO

--with cte1 as (select * from #


-- STRING_SPLIT
SELECT CAST(value AS INT) AS myvalue
FROM STRING_SPLIT('10248,10249,10250', ',') AS S;


-- STRING_AGG  (da Sql2017)

	DECLARE @Ingredienti TABLE (id int, ingrediente varchar(40));
	insert into @Ingredienti  values 
	(1, 'Pasta'),(2,'Sale'), (3,'Aglio'),(4,'Olio'), (5,'Peperoncino'),(6,'Vino');

	select STRING_AGG (cast(t.ingrediente as varchar(max)) , ',') from @Ingredienti t ;

	---- prima si utilizzava XML
	--	select stuff((select ',' + ingrediente as [text()] 
 --       from @Ingredienti for xml path(")),1,1,") 

select STUFF( (SELECT  ',' + i.ingrediente FROM  @Ingredienti i FOR XML PATH('')),1,1,'') 
 


-- esempio per creazione Json (aggiungo i tag associati ai libri)
drop table if exists #Books;
GO
create table #Books (idBook int, Title varchar(20));
insert into #Books values (1,'Libro1'), (2, 'Libro2'),(3,'Libro3');

select * from #Books

drop table if exists #Tags;
GO
create table #Tags (idBook int, Tag varchar(20));
insert into #Tags values 
(1,'Romanzo'), (1,'Storia'),
(2,'Romanzo'),(2,'Avventura'),(2,'Viaggi'),
(3,'Biografia');

select * from #Tags;

-- Creo il Jason
select b.IdBook, Title, 
	'{'+ STRING_AGG ('"'+ t.Tag +'"', ',') + '}'  as Tags
	from #Books b
	left outer join #Tags t
	on b.IdBook= t.IdBook
	group by b.IdBook, b.Title
;


--- TRIM (Da Sql2017)

	--- rimuove i blank davanti e dietro
	SELECT '*' + TRIM( '     pasta e ceci    ') + '*' AS Result;

	-- prima si usava RTRIM + LTRIM
	SELECT '*' + RTRIM(LTRIM( '     pasta e ceci    ')) +'*' AS Result; 


--- CONCAT_WS (Da Sql2017)
--- concatena inserendo il separatore indicato
select Concat_WS('-',address,city,PostalCode) as Indirizzo from Sales.Customers

--- TRANSLATE (da Sql2017)
SELECT TRANSLATE ('[137.4, 72.3]' , '[,]', '( )') AS Point


--- COLLATION

SELECT * FROM sys.fn_helpcollations();

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'davis';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS = N'davis';

---- COLLATION DB e TempDB differenti

-- Reset
DROP database IF EXISTS  DbChina;
GO

--- Collation dell'Istanza
select SERVERPROPERTY('COLLATION') AS COLLATION;

-- Creazione Database con collation Cinese
create database DbChina COLLATE Chinese_Simplified_Pinyin_100_CI_AS;

select [name] As Db, collation_name from sys.databases where [name]= 'DbChina';

use DbChina
GO

-- Tabella del Database
CREATE TABLE T1 (T1_txt nvarchar(max)) ;  
GO  

-- Tabella del TempDB
CREATE TABLE #T2 (T2_txt nvarchar(max)) ;  
GO 

-- La join da errore
SELECT 
	T1_txt, T2_txt  
FROM 
	T1   
JOIN #T2   
ON 
	T1.T1_txt = #T2.T2_txt;


-- La join funziona
SELECT 
	T1_txt, T2_txt  
FROM 
	T1   
JOIN #T2   
ON 
	T1.T1_txt COLLATE Latin1_General_CI_AS = #T2.T2_txt;

-- Tabella del TempDB con la collation del database
CREATE TABLE #T3 (T3_txt nvarchar(max) COLLATE DATABASE_DEFAULT) ;  
GO 

-- La join funziona
SELECT 
	T1_txt, T3_txt  
FROM 
	T1   
JOIN #T3   
ON 
	T1.T1_txt = #T3.T3_txt;

--pulizia 

use Test_C001;
go

drop database if exists DbChina;
