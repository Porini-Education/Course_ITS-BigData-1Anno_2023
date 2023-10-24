-- http://dati.comune.milano.it/dataset/ds138-popolazione-matrimoni-celebrati

/*
#Codice Powershell per il download del file

$Request = "http://dati.comune.milano.it/dataset/95c16b78-4cb7-4a5d-b1a6-f6f415aeba41/resource/5863eae2-425b-48af-9ba0-e251afda12c9/download/ds138-popolazione-matrimoni-celebrati.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Matrimoni = Invoke-WebRequest $request
$Matrimoni.Content | Out-File "c:\temp\matrimoni.txt"
*/


-- Viene scaricato un array di Json
/*
{
"Anno_evento": "2003", 
"Luogo_matrimonio": "Milano", 
"Rito": "Cattolico", 
"Residenza_marito": "Estero", 
"Residenza_moglie": "Estero", 
"Stato_civile_marito": "Celibe", 
"Stato_civile_moglie": "Nubile", 
"Cittadinanza_marito": "Canada", 
"Cittadinanza_moglie": "Canada", 
"Eta_marito": "27,00", 
"Eta_moglie": "32,00", 
"Numerosit\u00e0": "1,00"
}
*/

/*
	select translate('27,00',',','.') -- ok
	select convert (int, 27.00) -- ok
	select convert (int, '27.00') -- errore
	select convert (numeric(5,2),'27.00') -- ok
*/

SELECT *
FROM OPENROWSET (BULK 'C:\temp\matrimoni.txt', SINGLE_CLOB) as a -- Errore sul char set

SELECT *
FROM OPENROWSET (BULK 'C:\temp\matrimoni.txt', SINGLE_NCLOB) as a -- char set corretto per Unicode

SELECT b.*
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b

SELECT c.*
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
outer apply OPENJSON(b.Value) c
;

-- i valori numerici in input hanno la , come separatore ==> Errore di conversione
SELECT  c.*
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
outer apply OPENJSON(b.Value) 
WITH (
AnnoEvento int '$.Anno_evento', 
EtaMarito int '$.Eta_marito',
CittadinanzaMarito varchar(100) '$.Cittadinanza_marito',
EtaMarito int '$.Eta_moglie',
CittadinanzaMarito varchar(100) '$.Cittadinanza_moglie'
) c
;

--select convert(numeric(6,2),translate('35,00',',','.'))

-- ci sono record con eta blank vanno gestiti

SELECT top 100 --c.*
	--c.AnnoEvento,
	convert(numeric(6,2),translate(c.EtaMarito,',','.')) as EtaMarito

FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
outer apply OPENJSON(b.Value) 
WITH (
AnnoEvento int '$.Anno_evento', 
EtaMarito nvarchar(100) '$.Eta_marito',
CittadinanzaMarito varchar(100) '$.Cittadinanza_marito',
EtaMoglie nvarchar(100) '$.Eta_moglie',
CittadinanzaMarito varchar(100) '$.Cittadinanza_moglie'
) c
order by c.EtaMarito 
;
GO

--- Gestione dei dati non convertibili a numerico (perdiamo dei record)
with cteA
as
(SELECT b.*
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
)

select 
	b.AnnoEvento,
	CittadinanzaMarito,
	convert(numeric(6,2),translate(b.EtaMarito,',','.')) as EtaMarito,
	CittadinanzaMoglie,
	convert(numeric(6,2),translate(b.EtaMoglie,',','.')) as EtaMoglie
from cteA a
outer apply OPENJSON(a.Value) 
WITH (
AnnoEvento int '$.Anno_evento', 
EtaMarito nvarchar(100) '$.Eta_marito',
CittadinanzaMarito varchar(100) '$.Cittadinanza_marito',
EtaMoglie nvarchar(100) '$.Eta_moglie',
CittadinanzaMoglie varchar(100) '$.Cittadinanza_moglie'
) b
where JSON_VALUE(a.value, '$.Eta_marito') <> '' 
and JSON_VALUE(a.value, '$.Eta_moglie') <> '' 
;
GO

-- Gestione dei dati non convertibili a numerico uso dei nul
SELECT b.* into #Matrimoni
FROM OPENROWSET (BULK 'C:\Temp\matrimoni.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
GO

select * from #Matrimoni
where JSON_VALUE(value, '$.Eta_marito') is null;


UPDATE #Matrimoni 
SET 
Value = JSON_MODIFY(Value, 'strict $.Eta_marito', null)
where JSON_VALUE(value, '$.Eta_marito')= '';


UPDATE #Matrimoni 
SET 
Value = JSON_MODIFY(Value, 'strict $.Eta_moglie', null)
where JSON_VALUE(value, '$.Eta_moglie')= '';

select 
	b.AnnoEvento,
	CittadinanzaMarito,
	convert(numeric(6,2),translate(b.EtaMarito,',','.')) as EtaMarito,
	CittadinanzaMoglie,
	convert(numeric(6,2),translate(b.EtaMoglie,',','.')) as EtaMoglie

	into #Matrimoni2

from #Matrimoni a
outer apply OPENJSON(a.Value) 
WITH (
AnnoEvento int '$.Anno_evento', 
EtaMarito nvarchar(100) '$.Eta_marito',
CittadinanzaMarito varchar(100) '$.Cittadinanza_marito',
EtaMoglie nvarchar(100) '$.Eta_moglie',
CittadinanzaMoglie varchar(100) '$.Cittadinanza_moglie'
) b
where JSON_VALUE(a.value, '$.Eta_marito') <> '' 
and JSON_VALUE(a.value, '$.Eta_moglie') <> '' 

GO

select AnnoEvento, count(*) from #Matrimoni2
group by AnnoEvento
order by 1