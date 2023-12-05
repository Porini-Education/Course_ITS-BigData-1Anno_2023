with ctea
as
(
SELECT 
	Cittadinanza_marito,
	Cittadinanza_moglie,
	try_convert(numeric(5,2),replace(b.Eta_marito,',','.')) as Eta_marito,
	try_convert(numeric(5,2),replace(b.Eta_moglie,',','.')) as Eta_moglie
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a
cross apply openjson(a.BulkColumn) 
with
(
Cittadinanza_marito varchar(50) '$.Cittadinanza_marito',
Cittadinanza_moglie varchar(50) '$.Cittadinanza_moglie',
Eta_marito varchar(10) '$.Eta_marito',
Eta_moglie varchar(10) '$.Eta_moglie'
) b

--where Eta_moglie <> '' and Eta_marito <> ''
--order by Eta_moglie
)

select 
	Cittadinanza_marito,
	avg(Eta_marito) as MediaEtaMarito, 
	avg(Eta_moglie) as MediEtaMoglie,
	avg(Eta_marito-Eta_moglie) as DifferenzaEta,
	stdev (Eta_marito-Eta_moglie) as STDDifferenzaEta,
	count(*) as NumeroMatrimoni
from cteA
group by Cittadinanza_marito
having count(*) >=20
order by DifferenzaEta 
;
