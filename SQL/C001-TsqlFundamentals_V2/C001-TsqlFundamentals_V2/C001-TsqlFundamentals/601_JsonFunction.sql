
-- Esempi funzionalità di supporto JSON

DROP TABLE IF EXISTS #t;
create table #t (id int identity (1,1), CampoJson nvarchar(max));

-- carico un oggetto Json in una tabella per le successive prove
declare @j nvarchar(max);
set @j=
'{
"Article": "art01",
"Year": 2017,
"Dimension": {"Type":"Standard","Height": 120,"Width": 40},
"Colors": ["White", "Red", "Blue","Black"],
"FirstDate": "20171005 22:00"
}'
;
insert into #t select @j ;

select *, 
	JSON_QUERY(CampoJson, '$.Dimension')
from #t as a CROSS APPLY openjson(JSON_QUERY(CampoJson, '$.Dimension')) as b

declare @j nvarchar(max);
set @j=
'{
"Year": 2017,
"Poldo": {"Type":"Standard","citta":"milano"},
"Colors": true,
"FirstDate": "20171005 22:00"
}'
;

insert into #t select @j ;

select * from #t;

-- è un JSON ? (1= si, 0 = no)
select ISJSON (CampoJson) from #t;

-- Query sul Json
select 
	json_value (CampoJson, '$.Article') as Article,
	json_value (CampoJson, '$.Year') as Year,
	json_value (CampoJson, '$.Dimension') as Dimension,
	json_value (CampoJson, '$.Colors') as Color,
	json_value (CampoJson, '$.FirstDate') as FirstDate
from #t;

-- Query sul Json
select 
	json_query (CampoJson, '$.Article') as Article,
	json_query (CampoJson, '$.Year') as Year,
	json_query (CampoJson, '$.Dimension') as Dimension,
	json_query (CampoJson, '$.Colors') as Color,
	json_query (CampoJson, '$.FirstDate') as FirstDate
from #t;

-- path mode lax (default), [strict: invece di restituire NULL restituisce ERRORE]
select
	json_value (CampoJson, '$.Colors') as Color, -- default (lax)
	json_value (CampoJson, ' lax $.Colors') as Color -- lax ==> null
from #t;

select
	json_value (CampoJson, ' strict $.Colors') as Color --  strict ==> error
from #t;


-- navigo lungo le gerarchie Json
select 
	JSON_VALUE(CampoJson,'$.Dimension') as Dimension,  -- null perchè elemento complesso
	JSON_VALUE(CampoJson,'$.Dimension.Type') as Type,
	JSON_VALUE(CampoJson,'$.Dimension.Height') as Height,
	JSON_VALUE(CampoJson,'$.Dimension.Width') as Width
from #t ;


-- [] per leggere i valori di un array
select 
	json_query (CampoJson,'$.Colors') as Color,
	json_value (CampoJson, '$.Colors[0]') as Color0,
	json_value (CampoJson, '$.Colors[1]') as Color1,
	json_value (CampoJson, '$.Colors[2]') as Color2
from #t;

-- Table function OPENJSON
declare @J2 nvarchar(max) =
'{
"Article": "art01",
"Year": 2017,
"Dimension": {"Type":"Standard","Height": 120,"Width": 40},
"Colors": ["White", "Red", "Blue","Black"],
"FirstDate": "20171005 22:00"
}'
SELECT * FROM OPENJSON(@J2);

--Se la funzione OPENJSON() riceve in input un array restituisce un record per ogni elemento dell’array (non parsati)
declare @J3 nvarchar(max) ='[{"Id": 1, "Codice":"a"},{"Id": 2, "Codice":"b"}]'
SELECT * FROM OPENJSON(@J3);

declare @J4 varchar(100)='["alfa","bravo","charlie"]';
SELECT * FROM OPENJSON (@J4);


--Essendo una table value la OPENJSON() può essere  riapplicata a se stessa tramite apply e restituirà gli elementi di ogni json dell'array
declare @J5 nvarchar(max) ='[{"Id": 1, "Codice":"a"},{"Id": 2, "Codice":"b"}]'
SELECT * FROM OPENJSON(@J5) 
	outer apply OPENJSON(value);


-- Utilizzo clausola WITH per la definizione di datatype

-- senza clausola with
select b.* from #t a outer apply OPENJSON(a.CampoJson) b

-- con clausola with (leggo solo alcuni campi e definisco i data type)
-- Dimension è un json per cui non viene letto (va a null)
select b.* from #t a outer apply OPENJSON(a.CampoJson) 
WITH (
Articolo varchar(20) '$.Article', 
Altezza int '$.Dimension.Height',
Larghezza int '$.Dimension.Width',
Dimensione Nvarchar(max) '$.Dimension') b

-- con la clausola AS JSON l'elemento Dimension viene letto correttamente
select b.* from #t a outer apply OPENJSON(a.CampoJson) 
WITH (
Articolo varchar(20) '$.Article', 
Altezza int '$.Dimension.Height',
Larghezza int '$.Dimension.Width',
Dimensione Nvarchar(max) '$.Dimension' AS JSON) b

-- verticalizzo l'array
select b.value as Colore from #t a
outer apply OPENJSON(JSON_QUERY(a.CampoJson, '$.Colors')) b

-- caricamento di un file json esterno
/*
[
  {"year":2001,"make":"ACURA","model":"CL"},
  {"year":2001,"make":"ACURA","model":"EL"},
  {"year":2001,"make":"ACURA","model":"INTEGRA"},
  {"year":2001,"make":"ACURA","model":"MDX"},
  {"year":2001,"make":"ACURA","model":"NSX"},
  {"year":2001,"make":"ACURA","model":"RL"},
  {"year":2001,"make":"ACURA","model":"TL"}
]
*/

SELECT b.*
FROM OPENROWSET (BULK 'C:\Temp\JsonFile.json', SINGLE_CLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b

SELECT c.*
FROM OPENROWSET (BULK 'C:\Temp\JsonFile.json', SINGLE_CLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
outer apply OPENJSON(b.Value) 
WITH (
Anno int '$.year', 
Produttore varchar(20) '$.make',
Modello varchar(20) '$.model'
) c


-- Modifica valori Json

--situazione attuale
select * from #t;

select 
	json_value (CampoJson, '$.Dimension.Height') as Altezza,
	json_value (CampoJson, '$.Dimension.Size') as Size  -- NON esiste
from #t

select * from #t


UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Article.poldo',JSON_QUERY('{}'));

UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Article.id2', 1);

UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Article.poldo.id', 'aiuto');

UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, 'strict $.Article', null);

		UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Article', JSON_QUERY('{"id":10}') ) ;

		select * from #t
-- modifico il valore Height
UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Citta', 'Milano')
where id= 2;

-- creo una nuova coppia chiave-valore
UPDATE #t SET CampoJson = JSON_MODIFY(CampoJson, '$.Dimension.Size', 'XL');

-- verifico le modifiche/inserimenti
select 
	json_value (CampoJson, '$.Dimension.Height') as Altezza,
	json_value (CampoJson, '$.Dimension.Size') as Size
from #t

-- Modifico più valori (JSON_MODIFY annidate)
UPDATE #t
	SET CampoJson = JSON_MODIFY(JSON_MODIFY(CampoJson, '$.Dimension.Height', 12000), '$.Year', 2015) 

select * from #t



-- Modifico elemento lista vengono inseriti i caratteri di escape
UPDATE #t
	SET CampoJson = JSON_MODIFY(CampoJson, '$.Colors', '["Yellow", "Red"]') 

select * from #t;
select JSON_QUERY(CampoJson, '$.Colors') from #t;  -- non è un json corretto restituisce null
 
-- Modifico elemento lista con JSON_QUERY non vengono inseriti i caratteri di escape :-)
UPDATE #t
	SET CampoJson = JSON_MODIFY(CampoJson, '$.Colors', JSON_QUERY('["Pink", "Blue"]')) 

select * from #t;
select JSON_QUERY(CampoJson, '$.Colors') from #t;  -- json corretto

-- Per eliminare un elemento lo si updata a null
UPDATE #t
	SET CampoJson = JSON_MODIFY(CampoJson, '$.Dimension.Type', null)

	select * from #t;

--- Per assegnare un valore Null si utilizza Strict (non viene eliminato)
UPDATE #t
	SET CampoJson = JSON_MODIFY(CampoJson, 'strict $.Year', null)

-- Rinomino la chiave Article in Articolo (Elimino il vecchio e creo il nuovo elemento)
UPDATE #t 
SET CampoJson =  JSON_MODIFY(JSON_MODIFY(CampoJson,'$.Articolo',JSON_VALUE(CampoJson,'$.Article')),'$.Article', NULL)

select * from #t;


---- Output da Tabella Sql a File Json
create table #Jo
(Area varchar(10), Anno int, Cliente varchar(10), Qta int, Valore int)
;

insert into #Jo values
('Nord',2016,'Alfa',1200, 6403), ('Nord',2016,'Beta',2800,6700),
('Nord',2017,'Alfa',4200, 16403), ('Nord',2017,'Beta',6800,15700),
('Sud',2016,'Alfa',2200, 18900), ('Sud',2016,'Beta',800,1400),('Sud',2016,'Gamma',400,1670),
('Sud',2017,'Alfa',2400, 20900), ('Sud',2017,'Beta',906,1700)
;

select * from #Jo;

--L’opzione for Json AUTO genera un file json 
--la cui struttura è un array di json (uno per record) per record con un elemento per ogni campo.

select * from #Jo for Json AUTO

-- L'opzione JSON PATH permette di configurare l'output

-- root inserisce un livello padre sotto il quale si trova l'array dei json relativi ai record)
select * from #Jo for Json PATH, root ('Dati') 

-- con la notazione "punto" si crea la struttura del json di output
select 
	Cliente [Cliente.Name],
	Area [Cliente.Area],
	Anno [Cliente.Anno],
	Qta [Cliente.Quantita]
from #Jo
FOR JSON PATH , root ('Clienti')


select 
	Cliente [Clienti.Name],
	Area [Clienti.Area],
	Anno [Clienti.Vendite.Anno],
	Qta [Clienti.Vendite.Quantita],
	Valore [Clienti.Vendite.Importo]  

from #Jo
FOR JSON PATH , root ('Clienti')


-- Indicizzazione 
/*
Dati di test:
 https://raw.githubusercontent.com/arthurkao/vehicle-make-model-data/master/json_data.json
19.972 record
{"year":2001,"make":"ACURA","model":"CL"},
{"year":2001,"make":"ACURA","model":"EL"},
{"year":2001,"make":"ACURA","model":"INTEGRA"},
{"year":2001,"make":"ACURA","model":"MDX"},
{"year":2001,"make":"AM GENERAL","model":"HUMMER"}
….


#Codice Powershell per il download del file

$Request = " https://raw.githubusercontent.com/arthurkao/vehicle-make-model-data/master/json_data.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ModelliAuto = Invoke-WebRequest $request
$ModelliAuto.Content | Out-File "c:\temp\ModelliAuto.txt"

-- inserimento manuale (copia incolla per valorizzare la variabile
declare @j nvarchar(max) =
'[
  {"year":2001,"make":"ACURA","model":"CL"},
  {"year":2001,"make":"ACURA","model":"EL"},
  {"year":2001,"make":"ACURA","model":"INTEGRA"},
  {"year":2001,"make":"ACURA","model":"MDX"},
  ....
  ....
    {"year":2016,"make":"VOLVO","model":"XC90"}
]'
;

create table JsonTable (id int identity (1,1), jtext nvarchar(max));
insert into JsonTable
*/

create table JsonTable (id int identity (1,1), jtext nvarchar(max));
GO

insert into JsonTable
SELECT b.value
FROM OPENROWSET (BULK 'C:\Temp\ModelliAuto.txt', SINGLE_NCLOB) as a 
CROSS APPLY OPENJSON(BulkColumn) b
GO

select * from JsonTable
GO

set statistics time on
set statistics IO on

-- ricerca senza indici, senza campo calcolato
  select id, jtext from JsonTable
  where JSON_VALUE(jtext, '$.model') = 'HUMMER'

  -- Table 'JsonTable'. Scan count 1, logical reads 334
   --CPU time = 516 ms,  elapsed time = 527 ms.

  -- Creo un campo calcolato
alter table JsonTable add Model as JSON_VALUE(jtext, '$.model');

--ricerca senza indici sul campo calcolato
select id, jtext from JsonTable
where Model = 'HUMMER'

-- Indicizzo il campo calcolato
  create index inc_Model on JsonTable (Model)

-- ricerca con indice sul campo calcolato
select id, jtext from JsonTable
where Model = 'HUMMER'
;
-- Table 'JsonTable'. Scan count 1, logical reads 3
-- CPU time = 0 ms,  elapsed time = 0 ms.


-- utilizzo di Full text Search
	create unique clustered index ic_Json on JsonTable (id);

	--drop FULLTEXT CATALOG jFullTextCatalog;
	CREATE FULLTEXT CATALOG jFullTextCatalog;
 
	CREATE FULLTEXT INDEX ON JsonTable (jtext)
	KEY INDEX ic_Json
	ON jFullTextCatalog;

-- ricerco i record per cui model è HUMMER
-- l'opzione 'TRUE' garantisce l'ordine dei termini di ricerca
-- senza TRUE vengono estratti anche i record con make = HUMMER
 SELECT 
	id,  
	JSON_VALUE(jtext, '$.model') AS Model,jtext
 FROM 
	JsonTable
 WHERE 
	CONTAINS(jtext, 'NEAR((model,HUMMER),1,TRUE)')
	;

--https://medium.com/microsoftazure/get-correctly-formatted-deep-nested-json-files-at-scale-directly-from-azure-sql-server-c1e112dc3c37

