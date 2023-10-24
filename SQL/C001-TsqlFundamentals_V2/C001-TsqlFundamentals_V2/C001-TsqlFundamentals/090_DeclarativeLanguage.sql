use Test_C001
GO

--set statistics IO on;

select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid
where e.city='Seattle'

;
GO

select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid
	and e.city= 'seattle'
;

GO

with cteA as
(
	select
		e.empid,
		e.firstname,
		e.lastname
	from HR.Employees e
	where e.city= 'seattle'
) 

select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname
from 
	Sales.Orders o
	inner join cteA e
	on o.empid= e.empid
;

GO

with cteA
as
(
select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname,
	e.city
from 
	Sales.Orders o
	inner join HR.Employees e
	on o.empid= e.empid
)

select orderid,orderdate,freight,
	firstname,lastname
from Ctea e
where e.city= 'seattle'
GO

--- Temp Table

select
		e.empid,
		e.firstname,
		e.lastname
into #t
	from HR.Employees e
	where e.city= 'seattle'
;

select 
	o.orderid,o.orderdate,o.freight,
	e.firstname,e.lastname
from 
	Sales.Orders o
	inner join #T e
	on o.empid= e.empid
;

insert into #t
select
	
		e.firstname,
		e.lastname
	from HR.Employees e
	;
	GO

----- *****

-- 91 customers
SELECT C.custid, C.companyname
FROM Sales.Customers c
;


SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
order by 3 -- 832 righe
;

-- Clienti senza ordini
-- Index Scan Customers e Orders
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
	where o.orderid is null
order by 3 -- 2 righe

-- Clienti senza ordini (MODALITA' ERRATA)
-- Index Scan solo della Cutomers
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
	and o.orderid is   null
order by 3 -- 91 righe