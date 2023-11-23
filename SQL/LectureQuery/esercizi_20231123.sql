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
*/

select
	ROW_NUMBER() OVER (ORDER BY (select 1) )
from sys.all_columns		--11 102


(1,2,3)