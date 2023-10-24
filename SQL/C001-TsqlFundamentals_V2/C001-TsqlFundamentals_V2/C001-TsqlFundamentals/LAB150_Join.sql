-- ****** LAB JOIN

-- Utilizzare il database Test_C001

/*
esercizio 1

scrivere una query che restituisce 3 copie di ogni riga della tabella employee
con i campi empid, firstname e lastname.
Ordinare le righe per empid

Tabelle coinvolte HR.Employees e dbo.Nums

esempio prime righe output:

empid       firstname  lastname
----------- ---------- --------------------
1           Sara       Davis
1           Sara       Davis
1           Sara       Davis
2           Don        Funk
2           Don        Funk
2           Don        Funk
3           Judy       Lew
3           Judy       Lew
3           Judy       Lew
*/

/* 
esercizio 1 soluzione

		SELECT E.empid, E.firstname, E.lastname
		FROM HR.Employees AS E
		  CROSS JOIN dbo.Nums AS N 
		WHERE N.n <= 3
		ORDER BY empid;

*/


/*
esercizio 2

scrivere una query che restituisce i campi orderid,orderdate e freight
della tabella Orders e i campi firstname e lastname della tabella Employees
per i soli ordini associati agli impiegati di Seattle.
Ordinare le righe in ordine decrescente di orderid

Tabelle coinvolte HR.Employees e Sales.Orders

esempio prime righe output:

orderid     orderdate  freight               firstname  lastname
----------- ---------- --------------------- ---------- --------------------
11077       2016-05-06 8.53                  Sara       Davis
11075       2016-05-06 6.19                  Maria      Cameron
11071       2016-05-05 0.93                  Sara       Davis
11069       2016-05-04 15.67                 Sara       Davis
11068       2016-05-04 81.75                 Maria      Cameron
11067       2016-05-04 7.98                  Sara       Davis
11065       2016-05-01 12.91                 Maria      Cameron
11064       2016-05-01 30.09                 Sara       Davis
11056       2016-04-28 278.96                Maria      Cameron

*/

/* 
esercizio 2 soluzione

select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid
where e.city='Seattle'
order by o.orderid desc
;

*/


/*
esercizio 3

scrivere una query che restituisca, per ciascun impiegato, identificato da empid e lastname,
ciascun paese, identificato dal campo shipcountry, 
e ciasun anno di ordine il numero di ordini associati
e la somma del freight.

ordinarlo per valore di anno e di freight decrescente


Tabelle coinvolte HR.Employees e Sales.Orders

esempio prime righe output:

empid       firstname  shipcountry     YearOrder   Nums_orders Sum_Freight
----------- ---------- --------------- ----------- ----------- ---------------------
5           Sven       Brazil          2014        1           890.78
4           Yael       Germany         2014        9           649.89
8           Maria      USA             2014        4           519.11
1           Sara       Germany         2014        4           460.21
4           Yael       USA             2014        4           446.43
2           Don        Germany         2014        4           417.05
1           Sara       USA             2014        5           412.17

*/

/* 
esercizio 3 soluzione

select 
	e.empid, e.firstname,
	o.shipcountry,
	year(o.orderdate) as YearOrder,
	count(*) as Nums_orders,
	sum(o.freight) as Sum_Freight
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid

group by 	
	e.empid, 
	e.firstname,
	o.shipcountry,
	year(o.orderdate)
order by 
	year(o.orderdate),sum(o.freight)  desc
;

*/

/*
esercizio 4

come l'esercizio 3, ma solo per i paesi Brazil Austria e France

esempio prime righe output:

empid       firstname  shipcountry     YearOrder   Nums_orders Sum_Freight
----------- ---------- --------------- ----------- ----------- ---------------------
5           Sven       Brazil          2014        1           890.78
7           Russell    Austria         2014        1           360.63
1           Sara       Austria         2014        2           302.84
2           Don        Austria         2014        2           224.41
1           Sara       France          2014        3           191.45
9           Patricia   Austria         2014        1           146.06
3           Judy       France          2014        2           137.38
*/

/* 
esercizio 4 soluzione

select 
	e.empid, e.firstname,
	o.shipcountry,
	year(o.orderdate) as YearOrder,
	count(*) as Nums_orders,
	sum(o.freight) as Sum_Freight
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid
where
	o.shipcountry in ('Brazil','Austria','France')

group by 	
	e.empid, 
	e.firstname,
	o.shipcountry,
	year(o.orderdate)
order by 
	year(o.orderdate),sum(o.freight)  desc
;

*/

/*
esercizio 5

come l'esercizio 3, ma solo per i casi in cui il numero di oridni è maggiore di 2

esempio prime righe output:

empid       firstname  shipcountry     YearOrder   Nums_orders Sum_Freight
----------- ---------- --------------- ----------- ----------- ---------------------
4           Yael       Germany         2014        9           649.89
8           Maria      USA             2014        4           519.11
1           Sara       Germany         2014        4           460.21
4           Yael       USA             2014        4           446.43
2           Don        Germany         2014        4           417.05
1           Sara       USA             2014        5           412.17

*/

/* 
esercizio 5 soluzione

select 
	e.empid, e.firstname,
	o.shipcountry,
	year(o.orderdate) as YearOrder,
	count(*) as Nums_orders,
	sum(o.freight) as Sum_Freight
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid

group by 	
	e.empid, 
	e.firstname,
	o.shipcountry,
	year(o.orderdate)

having count(*) > 2

order by 
	year(o.orderdate),sum(o.freight)  desc
;

*/

/*
esercizio 6

calcolare, per ogni customer (identificati dal custid) 
il numero totale di ordini 
e la quantità totale come campo qty della tabella OrdersDetails
Solo per i clienti 'USA' (campo Country)
Ordinare i record per customer

Tabelle coinvolte Customers, Orders e OrderDetails

esempio prime righe output:

custid      numorders   totalqty
----------- ----------- -----------
32          11          345
36          5           122
43          2           20
45          4           181
48          8           134
*/

/* 
esercizio 6 soluzione

SELECT 
	c.custid, 
	COUNT(DISTINCT O.orderid) AS numorders, 
	SUM(OD.qty) AS totalqty
FROM 
	Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON O.custid = C.custid
  INNER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
WHERE C.country = N'USA'
GROUP BY C.custid
Order by c.custid

*/


/*
esercizio 7

restituire i clienti (custid e companyname) che non hanno fatto ordini

Ordinare i record per customer

Tabelle coinvolte Customers, Orders 

esempio prime righe output:

custid      companyname
----------- ----------------------------------------
22          Customer DTDMN
57          Customer WVAXS

*/

/*
esercizio 7 soluzione

SELECT 
	c.custid, 
	c.companyname
FROM 
	Sales.Customers AS C
left outer join 
	Sales.Orders AS O
	ON O.custid = C.custid
where o.custid is null
;

*/


/*
esercizio 8

ottenere per ogni employee il last name del suo manager (campo mgrid)

Ordinare i record per empi

Tabelle coinvolte HR.Employees

esempio prime righe output:

empid       lastname             title                          mgrid       lastname
----------- -------------------- ------------------------------ ----------- --------------------
2           Funk                 Vice President, Sales          1           Davis
3           Lew                  Sales Manager                  2           Funk
4           Peled                Sales Representative           3           Lew
5           Mortensen            Sales Manager                  2           Funk

*/

/*
esercizio 8 soluzione

SELECT  e.empid, e.lastname,
        e.title, e.mgrid, m.lastname
FROM    HR.Employees AS e
JOIN HR.Employees AS m 
ON e.mgrid=m.empid


SELECT  e. empid, e.lastname,
	  e.title, m.mgrid
FROM HR.Employees AS e
LEFT OUTER JOIN HR.Employees AS m
ON e.mgrid=m.empid;

*/

