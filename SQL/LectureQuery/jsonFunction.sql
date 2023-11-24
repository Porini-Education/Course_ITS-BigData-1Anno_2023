/*
SQL = Structured Query Language

csv = comma separated value

id,testo
1,colore
2,rosso
3,verde

-- JSON
{"chiave":"valore"}
*/

-- Esercizio da Python: indovina il numero

declare @j nvarchar(max) = '{
	"nome" : "Matteo",
	"numero da indovinare" : 5,
	"tentativi" : [
		1,
		3,
		5
	]
}'

select ISJSON(@j) as IsJson, 
	JSON_VALUE(@j, '$.nome') as Nome,
	JSON_VALUE(@j, '$."numero da indovinare"') as [numero da indovinare],
	JSON_VALUE(@j, '$.tentativi[1]') as Tenativo2,
	JSON_QUERY(@j, '$.tentativi') as TentativiList	-- Interrogazione di valori complessi


select '{
	"nome" : "Matteo",
	"numero da indovinare" : 5,
	"tentativi" : [
		1,
		3,
		5
	]
}' as J into #t

select * from #t

-- openjson

drop table #t

create table #t (J nvarchar(max))

insert into #t values ('[{
	"nome" : "Matteo",
	"guess" : 5,
	"tentativi" : [	1,	3,	5]
},{
	"nome" : "Mattia",
	"animali" : {
		"specie" : "cane",
		"nome" : "Alaska"
	}
}]')

select 
	a.J, b.value,
	JSON_VALUE(b.value, '$.nome') as nome,
	JSON_VALUE(b.value, '$.guess') as guess,
	JSON_QUERY(b.value, '$.animali') as Animali,
	JSON_VALUE(b.value, '$.animali.specie') as AnimaliSpecie
from #t a 
	cross apply openjson(a.J) b