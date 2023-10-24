
-- Window Functions

--Esempio group by differenziate

create table #t
(id int identity(1,1),
regione varchar(20),
provincia char(2),
vendite int
)
;
Go

insert into #t 
values
('lombardia','BS',10),
('lombardia','BS',15),
('lombardia','MI',140),
('lombardia','MB',80),
('lombardia','MB',20),
('emilia','RE',30),
('emilia','RE',40),
('emilia','PR',90),
('emilia','BO',120),
('emilia','BO',70)
;

Select * from #t;

select distinct
       regione,
       provincia,
       sum (vendite) over (partition by regione) as VenditeRegione,
       sum (vendite) over (partition by provincia) as VenditeProvincia,
       avg (vendite) over (partition by regione) as MediaVenditeRegione,
       avg (vendite) over (partition by provincia) as MediaVenditeProvincia
from #t
;


-- Esempi completi
USE Test_C001
GO


SELECT sum (val) as Valore
  --,SUM(val) OVER() AS Totval
FROM Sales.EmpOrders
;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

---------------------------------------------------------------------
-- Ranking Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  RANK()       OVER(ORDER BY val) AS rank,
  DENSE_RANK() OVER(ORDER BY val) AS dense_rank,
  NTILE(10)    OVER(ORDER BY val) AS ntile
FROM Sales.OrderValues
ORDER BY val;
go

with ctea
as
(
select empid, orderid, qty,
ROW_NUMBER() over (partition by empid order by qty ) as rnSmall,
ROW_NUMBER() over (partition by empid order by qty desc) as rnBig
from Sales.OrderValues
)
,
cteP
as
(
select empid, qty as 'Piccolo'  from cteA a where rnSmall = 1),
cteG
as
(select empid, qty as 'Grosso' from cteA where rnBig = 1 )
select *
from cteP p inner join cteG g
on p.empid = g.empid


SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

-- Valutata prima del distinct
SELECT DISTINCT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues;

-- La group by restituisce un record per value (distinct)
SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

---------------------------------------------------------------------
-- Offset Window Functions
---------------------------------------------------------------------

-- LAG and LEAD
SELECT custid, orderid, val,
  LAG(val,2,0)  OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS prevval,
  LEAD(val,2,0) OVER(PARTITION BY custid
                 ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

-- FIRST_VALUE and LAST_VALUE
SELECT custid, orderid, val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW) AS firstval,
  LAST_VALUE(val)  OVER(PARTITION BY custid
                        ORDER BY orderdate, orderid
                        ROWS BETWEEN CURRENT ROW
                                 AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

---------------------------------------------------------------------
-- Aggregate Window Functions
---------------------------------------------------------------------

SELECT orderid, custid, val,
  SUM(val) OVER() AS totalvalue,
  SUM(val) OVER(PARTITION BY custid) AS custtotalvalue
FROM Sales.OrderValues;

SELECT orderid, custid, val,
  100. * val / SUM(val) OVER() AS pctall,
  100. * val / SUM(val) OVER(PARTITION BY custid) AS pctcust
FROM Sales.OrderValues;

SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
                ORDER BY ordermonth
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;
