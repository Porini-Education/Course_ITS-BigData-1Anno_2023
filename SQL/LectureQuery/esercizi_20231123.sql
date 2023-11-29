/*
Interrogazione a estrazione 
325 -> 3+2+5 = 10
Mario Monti dichiara che è più probabile la sua interrogazione
poichè si trova al centro del registro. E' vero?

Tabella a disposizione:
	dbo.Nums

Libro con 500 pagine
*/
WITH 
cteN1 as	-- tabella delle dedice e delle unità
	(select n-1 as n1 from dbo.Nums where n <= 10),
cteN2 as	-- tabella delle centinaia
	(select n-1 as n2 from dbo.Nums where n <= 6),
cteLibro as
  ( select c.n2 as centinaia, d.n1 as decine, u.n1 as unità
	from cteN1 u cross join cteN1 d cross join cteN2 c),
cteEst as
  ( select *, centinaia + decine + unità as NumRegistro
	from cteLibro)

select NumRegistro, count(*) as FrequenzaEstrazione
from cteEst
where NumRegistro <> 0
group by NumRegistro
order by NumRegistro desc

/*
scrivere una QUERY che calcoli la tabella dei numeri
	select * from dbo.nums
Strumenti a disposizione:
 - NON voglio creare una tabella da riempire
 - NON posso prendere nessuna tabella come punto di partenza
 - CTE
 - Window Function
 - SET OPERATIONS
*/

WITH 
 cteA as (SELECT 1 AS N UNION ALL SELECT 1)						--2
,cteB as (select 1 as N from cteA a cross join cteA b)			--4
,cteC as (select 1 as N from cteB a cross join cteB b)			--16
,cteD as (select 1 as N from cteC a cross join cteC b)			--256
,cteE as (select 1 as N from cteD a cross join cteD b)			--65536
,cteF as (select 1 as N from cteE a cross join cteE b)			--4294967296

select top 100000 
	ROW_NUMBER() OVER (ORDER BY N ) as N
from cteF