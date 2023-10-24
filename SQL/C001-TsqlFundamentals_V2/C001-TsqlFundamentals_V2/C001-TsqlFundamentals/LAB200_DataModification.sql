-- ****** LAB DATA MODIFICATION

-- Utilizzare il database Test_C001

 use Test_C001
 GO

 /*
 esercizio 1
 
 creare la seguente tabella
CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

Inserire un record con questi dati

 custid:  100
 companyname: Coho Winery
 country:     USA
 region:      WA
 city:        Redmond

Inserire nella tabella tutti i record dei Customers 
della tabella Sales.Customers
che hanno effettuato degli ordini


Utilizzare la SELECT INTO per creare e popolare la tabella
dbo.Orders con tutti gli ordini della Sales.Order 
che sono stati fatti
nel 2015 e 2016

Eliminare dalla dbo.Orders tutti gli ordini
effettuati prima del 1 febbraio 2016
*/

/* 
esercizio 1 soluzione


INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  VALUES(100, 'Coho Winery', 'USA', 'WA', 'Redmond');


INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  SELECT custid, companyname, country, region, city
  FROM Sales.Customers AS C
  WHERE EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);



SELECT *
INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate >= '20150101'
  AND orderdate < '20170101';

DELETE FROM dbo.Orders
WHERE orderdate < '20160201';

*/

/*
esercizio 2
eseguire un update della tabella dbo.Customers
valorizzando alla stringa '<none>' il campo region se è NULL
*/

/*
esercizio 2 soluzione

UPDATE dbo.Customers
  SET region = '<None>'
WHERE region IS NULL;

*/


/*
esercizio 3
eliminare i record dalla tabella dbo.Order effetuati dai clienti del Brasile

Tabelle coinvolte: dbo.Orders e dbo.Customers
*/

/*
esercizio 3 soluzione

DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM  AS C
   WHERE dbo.Orders.custid = C.custid
     AND C.country = N'Brazil');

DELETE FROM O
FROM dbo.Orders AS O
  JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE country = N'Brazil';

*/

/* esercizio 4
 
 Updatare tutti gli ordini della la tabella dbo.Orders effettuati da clienti UK
 e valorizzare i campi shipcountry, shipregion, e shipcity 
 con quelli dei campi country, region, city 
 dei record dei customers corrispondneti nella tabella dbo.Customers

 */

/*
esercizio 4 soluzione

UPDATE O
  SET shipcountry = C.country,
      shipregion = C.region,
      shipcity = C.city
FROM dbo.Orders AS O
  JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = 'UK';

*/

-- cleanup
--IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
--IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers ;