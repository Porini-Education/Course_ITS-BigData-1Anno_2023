-- WINDOW FUNCTION
WITH ctea as (
SELECT 
	orderid, custid, orderdate, freight
FROM Sales.Orders
), cteb as (
SELECT 
	custid, SUM(freight) as TOT_cost
FROM Sales.Orders
group by custid
)

select *, freight/TOT_cost*100 as pct_Costo
from ctea a inner join cteb b
	on a.custid = b.custid

-- Calcolare delle proprietà aggregate senza il bisogno di aggregare

select 
	orderid, custid, orderdate, freight,
	SUM(freight) OVER ()  as Fatturato_totale,
	SUM(freight) OVER (PARTITION BY year(orderdate) )  as Fatturato_anno,
	SUM(freight) OVER (PARTITION BY custid )  as Fatturato_cliente,
	SUM(freight) OVER (ORDER BY orderid )  as Flusso_cassa,
	SUM(freight) OVER (PARTITION BY custid ORDER BY orderid )  as Flusso_cliente
from sales.Orders;

with ctea as (
select 
	orderid, custid, orderdate, freight,
	SUM(freight) OVER (PARTITION BY custid)  as Fatturato_totale
from sales.Orders
)

select distinct custid
from ctea 
where Fatturato_totale > 1000

-- RANKING FUNCTION: window function con l'opzione ORDER BY obbligatoria

select 
	orderid, custid, orderdate, freight,
	ROW_NUMBER() OVER (ORDER BY orderdate) as Row_number,
	RANK() OVER (ORDER BY orderdate) as Rank,
	DENSE_RANK() OVER (ORDER BY orderdate) as Dense_rank,
	NTILE(11) OVER (ORDER BY orderdate) as Ntile
from sales.Orders


select Ntile, count(*)
from (
		select
			NTILE(11) OVER (ORDER BY orderdate) as Ntile
		from sales.Orders
	) as T
group by Ntile

select
	count(*) as Conteggio,
	count(*) Conteggio,			-- Alias per errore	[SCONSIGLIATA]
	Conteggio = count(*)		-- viene molto comodo quando avete espressioni lunghe
from sales.Orders

-- tutti gli ordini, per ogni cliente, dal 3° al 5°
	
SELECT * from
	(SELECT
		orderid, orderdate, custid, freight, 
		ROW_NUMBER() OVER (PARTITION BY custid ORDER BY orderid) as Numero_ordine_cliente
	FROM Sales.Orders) as T
WHERE Numero_ordine_cliente in (3,4,5)