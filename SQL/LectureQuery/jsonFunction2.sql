declare @j varchar(1000) = '[
	{
		"Nome": "Eulalia",
		"Luogo": "Cardano al Campo",
		"Eta": 25,
		"Animali": [
			{
				"Tipo": "Cane",
				"Nome": "Pedro",
				"Eta": 3
			},
			{
				"Tipo": "Cane",
				"Nome": "Alaska",
				"Eta": 11
			},
			{
				"Tipo": "Gatto",
				"Nome": "Nabu",
				"Eta": 6
			}
		]
	},
	{
		"Nome": "Kevin",
		"Eta": 21
	},
	{
		"Nome": "Franco",
		"Figlie": [
			"Silvia",
			"Sara"
		],
	"Animali": [
			{
				"Tipo": "Gatto",
				"Nome": "Spillo",
				"Eta": 3
			}]
	}
]'
;

with ctePersone
as
(
	select a.[key],b.*
	from openjson(@j) a
	cross apply openjson (a.value) 

	with
	(
		Persona varchar(20) '$.Nome',
		EtaPersona int '$.Eta',
		LuogoPersona varchar(20) '$.Luogo'
	) b 
)
,
cteAnimali
as
(
	select a.[key],d.*
	from openjson(@j) a
	cross apply openjson (a.value) b
	cross apply openjson (b.value) c
	cross apply openjson (c.value) 
	with 
	(
		NomeAnimale varchar(20) '$.Nome',
		TipoAnimale varchar(20) '$.Tipo',
		EtaAnimale int '$.Eta'

	) d
	where b.[key] = 'Animali'
)

select 
	Persona,
	LuogoPersona,
	EtaPersona,
	NomeAnimale,
	TipoAnimale,
	EtaAnimale
from ctePersone a
left outer join cteAnimali b
on a.[key]= b.[key]


/*
create table dbo.j2
(Persona varchar (50),
EtaPersona int,
LuogoPersona varchar(20),
NomeAnimale varchar(20),
TipoAnimale varchar(20),
EtaAnimale int)
;
GO
*/