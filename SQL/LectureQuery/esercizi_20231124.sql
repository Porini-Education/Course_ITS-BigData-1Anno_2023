-- select * from hr.Employees
-- manager | impiegato

-- self join: sto utilizzando due volte la stessa tabella
select
	M.lastname, M.firstname,
	E.lastname, E.firstname
from hr.Employees E
	inner join hr.Employees M
		on M.empid = E.mgrid

-- Primo e ultimo ordine
-- Per ogni cliente voglio mostrare il primo e l'ultimo ordine

with ctea as (
	select 
		orderid, custid, orderdate, 
		rank() over (partition by custid order by orderdate) as Rank_crescente,
		rank() over (partition by custid order by orderdate desc) as Rank_decrescente
	from
		sales.Orders
	)

select *
from ctea
where rank_crescente = 1 or rank_decrescente = 1

-- versione 2: vogliamo calcolare da quanti giorni è nostro cliente
--				nella stessa riga mostrare il primo e l'ultimo ordine

with ctea as (
	select 
		orderid, custid, orderdate, 
		rank() over (partition by custid order by orderdate) as Rank_crescente
	from
		sales.Orders
),
cteb as (
	select 
		orderid, custid, orderdate, 
		rank() over (partition by custid order by orderdate desc) as Rank_decrescente
	from
		sales.Orders
)

select a.custid, 
	a.orderdate as Data_inizio, 
	b.orderdate as Data_fine,
	DATEDIFF(DAY, a.orderdate, b.orderdate) as Differenza
from ctea a inner join cteb b
	on a.custid = b.custid and a.Rank_crescente = b.Rank_decrescente
where 
	a.Rank_crescente = 1

-- top 3 clienti per anno, in base al numero di ordini fatti nell'anno
-- costruire un podio: 
-- 3
-- 1
-- 2

select 
	orderid, custid, orderdate, year(orderdate) as Anno,
	count(orderid) over (partition by custid, year(orderdate)) as Ordini_totali_clienti
from sales.Orders
order by custid, Anno

-- idea di Simone, Mikola e Lorenzo:

create function sales.Top3CustByYear (@Year int) returns table as 
return
	SELECT TOP 3
		custid, year(orderdate) as Anno,
		count(orderid) as Ordini_totali_clienti
	FROM 
		Sales.Orders
	WHERE year(orderdate) = @Year
	GROUP BY custid, year(orderdate)
	ORDER BY Ordini_totali_clienti desc




create view sales.v_Top3CustByYear as
	select TOP 100 PERCENT
		a.*, 
		row_number() over (partition by a.anno order by ordini_totali_clienti desc) as posizione
	from 
		(select year(orderdate) as Anno 
		from sales.Orders group by year(orderdate)
		) as T
	 cross apply 
		sales.Top3CustByYear(T.Anno) a
	order by a.Anno, case row_number() over (partition by a.Anno order by ordini_totali_clienti desc)
				when 3 then 1
				when 1 then 2
				when 2 then 3
			end


SELECT * FROM sales.v_Top3CustByYear	-- LIMITE: i dati non sono comunque ordinati



create function sales.tvf_TopNCustByYear (@Year int, @topn int) returns table as 
return
	SELECT TOP (@topn)
		custid, year(orderdate) as Anno,
		count(orderid) as Ordini_totali_clienti
	FROM 
		Sales.Orders
	WHERE year(orderdate) = @Year
	GROUP BY custid, year(orderdate)
	ORDER BY Ordini_totali_clienti desc

select * 
from sales.tvf_TopNCustByYear (2015, 7)