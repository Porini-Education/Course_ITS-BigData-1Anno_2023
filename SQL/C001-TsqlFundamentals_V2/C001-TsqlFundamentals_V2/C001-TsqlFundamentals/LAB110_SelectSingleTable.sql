-- ****** LAB SINGLE Table Query

-- Utilizzare il database Test_C001

-- use Test_C001
-- GO

/*
esercizio 1

scrivere una query che riporti gli ordini effettuati nel giugno 2015
Riportare i campi orderid, orderdate custid e empid
Ordinare le righe per orderid

Tabella coinvolta Sales.order

esempio prime righe output:
orderid     orderdate  custid      empid
----------- ---------- ----------- -----------
10555       2015-06-02 71          6
10556       2015-06-03 73          2
10557       2015-06-03 44          9
10558       2015-06-04 4           1
10559       2015-06-05 7           6
10560       2015-06-06 25          8

*/

/* 
esercizio 1 soluzione

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20150601' 
  AND orderdate < '20150701'
order by orderid
;

*/

/*
esercizio 2

scrivere una query con il numero di ordini 
effettuati da ogni customer (custid) 
in ciascun anno

Ordinare le righe per numero di ordini

Tabella coinvolta Sales.order

esempio prime righe output:

custid      OrderYear   NumOrders
----------- ----------- -----------
2           2014        1
3           2014        1
10          2014        1
11          2014        1
13          2014        1
8           2014        1
*/

/* 
esercizio 2 soluzione

SELECT  
	custid, 
	year (orderdate) as OrderYear,
	count (*) as NumOrders
FROM Sales.Orders
group by custid, 
	year (orderdate)
order by count (*)
;
*/


/*
esercizio 3

come l'esercizio 2 ma solo per i clienti  che hanno effettuato in ciascun anno
almeno 10 ordini

Tabella coinvolta Sales.order

esempio prime righe output:
custid      OrderYear   NumOrders
----------- ----------- -----------
35          2015        10
37          2015        10
51          2015        10
5           2015        10

*/


/* 
esercizio 3 soluzione

SELECT  
	custid, 
	year (orderdate) as OrderYear,
	count (*) as NumOrders
FROM Sales.Orders
group by custid, 
	year (orderdate)
having count(*) > 9
order by count (*)
;
*/

/*
esercizio 4

ritornare il numero di ordine ed il mese dell'ordine
per gli ordini effettuati l'ultimo giorno del mese
ordinare per orderid

Tabella coinvolta Sales.order

esempio prime righe output:

orderid     MonthOrder
----------- -----------
10269       7
10317       9
10343       10
10399       12
*/

/* 
esercizio 4 soluzione

SELECT  
	orderid, 
	month (orderdate) as MonthOrder

FROM Sales.Orders
where orderdate = EOMONTH(orderdate)
order by orderid
;

*/

/*
esercizio 5

calcolare il valore massimo e medio di qty degli ordini

Tabella coinvolta Sales.orderdetails

esempio prime righe output:
MaxQty MeanQty
------ -----------
130    23

*/

/* 
esercizio 5 soluzione

select max(qty) as MaxQty, AVG (qty) as MeanQty
from sales.OrderDetails
;
*/


/*
esercizio 6

recuperare i primi 7 ordini in termini di valore 
dato dal prodotto quantita (qty) e prezzo (unitprice)

ordinarli per valore decrescente

Tabella coinvolta Sales.orderdetails

esempio prime righe output:

orderid     valore
----------- ---------------------
10865       15810.00
10981       15810.00
10353       10540.00
10417       10540.00
10889       10540.00

*/

/* 
esercizio 6 soluzione

select top 7
	orderid,
	qty *unitprice as valore

from  
	sales.OrderDetails
order by 2 desc
;
*/


/*
esercizio 7

Calcolare il valore minimo, medio, massimo del campo freight degli ordini
per ciascun paese (shipcountry) ed anno di ordine (orderdate)
ordinare per anno e valore medio

Tabella coinvolta Sales.orders

esempio prime righe output:

OrderYear   min_freight           mean_freight          max_freight
----------- --------------------- --------------------- ---------------------
2014        0.12                  67.6307               890.78
2015        0.14                  79.5803               1007.64
2016        0.02                  82.2001               830.75

*/

/* 
esercizio 7 soluzione

select
	year(orderdate) as OrderYear,
	min (freight) as min_freight,
	avg (freight) as mean_freight,
	max (freight) as max_freight

from 
	sales.Orders
group by
	year(orderdate)
order by
 	year(orderdate),  avg (freight) 
;
*/

/*
esercizio 8

recuperare il nome ed il cognome degli impiegati 
e il numero di giorni dalla loro nascita ad oggi
farlo solo per gli impiegati che il 1 gennaio del 2010 
avevano meno di 30 anni

Tabella coinvolta HR.Employees

esempio prime righe output:

*/

/* 
esercizio 8 soluzione

select 
	firstname, 
	lastname,
	datediff (day,birthdate,GETDATE()) as GiorniDallaNascita,
	datediff (year,birthdate,'20100101') 
from
	hr.Employees
where 
	datediff (year,birthdate,'20100101')  < 30
*/

/*
esercizio 9

elencare empid, firstname, lastname, titkeofcourtesy e gender
degli impiegati.
valorizzare gender dal titolo di cortesia

Tabella coinvolta HR.Employees

esempio prime righe output:
empid       firstname  lastname             titleofcourtesy           gender
----------- ---------- -------------------- ------------------------- -------
1           Sara       Davis                Ms.                       Female
2           Don        Funk                 Dr.                       Unknown
3           Judy       Lew                  Ms.                       Female
4           Yael       Peled                Mrs.                      Female
5           Sven       Mortensen            Mr.                       Male
*/

/* 
esercizio 9 soluzione

SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
    WHEN 'Ms.'  THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Mr.'  THEN 'Male'
    ELSE             'Unknown'
  END AS gender
FROM HR.Employees;
*/
