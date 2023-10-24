
-- ****** LAB SET

-- Utilizzare il database Test_C001

--use Test_C001
--go

/*
esercizio 1

scrivere una query che restituisce i primi 10 numeri
senza usare tabelle preesistenti

Ordinare le righe per valore

Tabelle coinvolte nessuna

esempio prime righe output:

n
-----------
1
2
3
4
*/

/* 
esercizio 1 soluzione

SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3
UNION ALL SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6
UNION ALL SELECT 7
UNION ALL SELECT 8
UNION ALL SELECT 9
UNION ALL SELECT 10
;

--SELECT n
--FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Nums(n);

*/

/*
esercizio 2

recuperare l'elenco dei custid che hanno effettuato ordini in 
luglio 2014, ma non in agosto 2014

Tabelle coinvolte Sales.Orders

esempio prime righe output:

custid
-----------
7
13
14
20

*/

/* 
esercizio 2 soluzione

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140701' AND orderdate < '20140801'

EXCEPT

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140801' AND orderdate < '20140901';

*/

/*
esercizio 3

recuperare l'elenco dei custid che hanno effettuato ordini sia in 
luglio 2014, che in agosto 2014 che in agosto 2015

Tabelle coinvolte Sales.Orders

esempio prime righe output:
custid
-----------
61
87

*/

/* 
esercizio 3 soluzione

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140701' AND orderdate < '20140801'

INTERSECT

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140801' AND orderdate < '20140901'

INTERSECT

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20150801' AND orderdate < '20150901';

*/

/*
esercizio 4

recuperare l'elenco dei custid che hanno effettuato ordini sia in 
luglio 2014, che in agosto 2014 ma non in agosto 2015

Tabelle coinvolte Sales.Orders

esempio prime righe output:
custid
-----------
65
85
*/

/* 
esercizio 4 soluzione

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140701' AND orderdate < '20140801'

INTERSECT

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20140801' AND orderdate < '20140901'

EXCEPT

SELECT custid
FROM Sales.Orders
WHERE orderdate >= '20150801' AND orderdate < '20150901';

*/
