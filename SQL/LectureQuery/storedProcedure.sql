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


create procedure dbo.sp_insertvalues @testo nvarchar(100), @peso numeric(4,2) as

insert into dbo.InsertFromProcedure
					-- values ('Bravo', getdate(), 23.4)
	select 
		@testo as testo,
		DATEADD(day, -n+1, getdate()) as data,
		(@peso*n)% 99.99 as peso
	from dbo.Nums

exec dbo.sp_insertvalues 'alfa', 31.57