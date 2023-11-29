/*
tvf capace di mostrare le informazioni di un cliente
 1. vedo gli ordini del cliente
 2. vedo l'anagrafica del cliente
*/
--declare @tvf_tabella varchar(15) = 'customers',
--		@tvf_custid int = 73

-- STORED PROCEDURE: oggetto in cui posso salvare qualsiasi pezzo di codice

alter procedure dbo.pippo @pluto varchar(12) as
	print @pluto

	select * from sales.Customers 
	where companyname like (CONCAT(LEFT(@pluto,1),'%'))

exec dbo.pippo 'Hello World'


alter procedure sales.sp_InfoCliente  
	@tvf_custid int, 
	@tvf_tabella varchar(15) 
as
	--IF @tvf_tabella = 'Orders'
		SELECT *
		FROM sales.Orders
		WHERE custid = @tvf_custid
		order by 1 desc
	--else
		SELECT *
		FROM sales.Customers
		WHERE custid = @tvf_custid

exec sales.sp_InfoCliente 53, 'orde'

create table dbo.InsertFromProcedure 
(
id int identity(0,2),
testo nvarchar(100),
data date,
peso numeric(4,2)
)


alter procedure dbo.sp_insertvalues @testo nvarchar(100), @peso numeric(4,2) as

insert into dbo.InsertFromProcedure
					-- values ('Bravo', getdate(), 23.4)
	select 
		@testo as testo,
		DATEADD(day, -n+1, getdate()) as data,
		(@peso*n)% 99.99 as peso
	from dbo.Nums
	where n <= 1000

exec dbo.sp_insertvalues @testo = 'alfa', @peso = 31.57

truncate table InsertFromProcedure

select DATEADD(day, -98700, getdate())

select * 
from InsertFromProcedure

-- tabelle temporanee
create table #t (
id int,
testo varchar(15)
)

insert into #t values (1,'rosso')

select * 
from #t

-- int: 4B * 100.000.000

drop table #t

delete from #t
where id = 1

with ctea as
(
	select distinct id
	from #t
)

--delete 
select *
from #t
where id in (select * from ctea)

-- ho dei duplicati, li parcheggio in una tabella di appoggio
select distinct *
into #t2
from #t

truncate table #t

insert into #t 
	select * from #t2

select * from #t

-- drop table #t2

-- versione 2

delete T from 
	(select 
		*, 
		DUPLICATION_RANK = 
			ROW_NUMBER() OVER (PARTITION BY id
								ORDER BY id)
	from #t) as T
where duplication_rank > 1

select * from #t