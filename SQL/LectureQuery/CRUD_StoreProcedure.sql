/*
create table dbo.Prodotti
(
	Id int identity(1,1),
	Codice int not null,
	Tipologia varchar(1000) not null,
	Valore numeric (7,2) not null
);
GO

create procedure dbo.InsertProduct @j varchar(max)
as
	insert into dbo.prodotti
				(Codice,Tipologia,Valore)
	select 
		json_value (@j,'$.codice'),
		json_value (@j,'$.tipologia'),
		json_value (@j,'$.valore')
	;
GO

create procedure dbo.UpdateProduct @j varchar(max)
as
	update dbo.Prodotti
	set 
		Tipologia = JSON_VALUE (@j, '$.tipologia'),
		Valore = JSON_VALUE (@j, '$.valore')
	where 
		Codice = JSON_VALUE (@j, '$.codice')
	;

create procedure dbo.DeleteProduct @j varchar(max)
as
	delete from dbo.Prodotti
	where Codice = JSON_VALUE(@j,'$.codice')
	;
GO

create procedure dbo.InsertUpdateDeleteProduct @j varchar(max)
as

IF ISJSON(@j) = 1
BEGIN

	IF JSON_VALUE(@j,'$.tipologia') is null  --- To delete
	BEGIN
		exec dbo.DeleteProduct @j
	END

	ELSE -- To insert or Update
	BEGIN
		declare @esiste int =  (select count(*) as n 
								from dbo.Prodotti
								where Codice = JSON_VALUE(@j,'$.codice') 
								)
		IF @esiste = 0 
			BEGIN
				exec dbo.InsertProduct @j
			END
		ELSE
			BEGIN
				exec dbo.UpdateProduct @j
			END
	END
END
ELSE
print 'NON è un JSON'
;
GO

*/

declare @j varchar(200) = '{"codice":345,"tipologia":"calze bianche","valore":66.00}';
--declare @j varchar(200) = '{"codice"34,"tipologia":"auto","valore":996.00}';
--declare @j varchar(200) = '{"codice":34}';
exec dbo.InsertUpdateDeleteProduct @j ;
GO

select * from dbo.Prodotti
