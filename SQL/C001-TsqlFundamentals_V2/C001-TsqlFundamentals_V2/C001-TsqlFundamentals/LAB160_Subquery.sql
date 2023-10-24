-- ****** LAB SUBQUERY

-- Utilizzare il database Test_C001

 use Test_C001
 GO

 /*
 esercizio 1
 Scrivere una query che restituisca tutti gli ordini della tabella Sales.Orders 
nell'ultimo giorno di ordini (tra quelli presenti nella tabella)

Tabella coinvolta Sales.order

esempio prime righe output:

orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
11077       2016-05-06 65          1
11076       2016-05-06 9           4
11075       2016-05-06 68          8
11074       2016-05-06 73          7

*/

/* 
esercizio 1 soluzione

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate =
  (SELECT MAX(O.orderdate) FROM Sales.Orders AS O);
*/

 /*
 esercizio 2
 scrivere una query che riporti tutti gli ordini (dalla  Sales.order)
 fatti dal (o dai) customer con maggior numero di ordini
 Ordinare per custid

Tabella coinvolta Sales.order

esempio prime righe output:
custid      orderid     orderdate  empid
----------- ----------- ---------- -----------
71          10324       2014-10-08 9
71          10393       2014-12-25 1
71          10398       2014-12-30 2
71          10440       2015-02-10 4
71          10452       2015-02-20 8
71          10510       2015-04-18 6

*/

/* 
esercizio 2 soluzione

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
  (SELECT TOP (1) WITH TIES O.custid
   FROM Sales.Orders AS O
   GROUP BY O.custid
   ORDER BY COUNT(*) DESC);

*/

 /*
 esercizio 3
 Scrivere la query che riporta gli impiegati
 (empid, firstname, lastname) che non hanno 
 piazzato ordini dal 1° maggio 2016

 Tabelle coinvolta Sales.order, HR.Employees

esempio prime righe output:

 empid       FirstName  lastname
----------- ---------- --------------------
3           Judy       Lew
5           Sven       Mortensen
6           Paul       Suurs
9           Patricia   Doyle

*/

/* 
esercizio 3 soluzione

SELECT empid, FirstName, lastname
FROM HR.Employees
WHERE empid NOT IN
  (SELECT O.empid
   FROM Sales.Orders AS O
   WHERE O.orderdate >= '20160501');

*/

 /*
 esercizio 4
 Scrivere la query che elenca i country che hanno 
 customers ma non Employees

  Tabelle coinvolta Sales.Customers, HR.Employees

esempio prime righe output:

country
---------------
Argentina
Austria
Belgium
Brazil
Canada

*/

/* 
esercizio 4 soluzione

SELECT DISTINCT country
FROM Sales.Customers
WHERE country NOT IN
  (SELECT E.country FROM HR.Employees AS E);

  */

 /*
 esercizio 5

Scrivere la query che restituisce dalla tabella Sales.Orders
i custid e il company name dei clienti che hanno fatto ordini
nel 2015 e non nel 2016

Tabelle coinvolte Sales.Orders, Sales.Customers

esempio prime righe output:
custid      companyname
----------- ----------------------------------------
21          Customer KIDPX
23          Customer WVFAF
33          Customer FVXPQ

*/

/* 
esercizio 6 soluzione

SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate >= '20150101'
     AND O.orderdate < '20160101')
  AND NOT EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate >= '20160101'
     AND O.orderdate < '20170101');

*/