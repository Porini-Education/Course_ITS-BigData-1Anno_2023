/*
This is a complete example on how to use the MERGE statement.
The example is using an on-prem version of SQL Server but it can be moved on cloud.
*/

-- only if we are on prem or on a Managed Instance
use tempdb;
go

-- Let's be sure that the environment is free
BEGIN TRY
	drop table dbo.Storici;
	drop table dbo.Aggiornamenti;
END TRY
BEGIN CATCH

END CATCH;

-- Let's start with the creation of the resources

-- Historical table
create table dbo.Storici (Data date, Codice varchar(12), valore int);
GO

insert into dbo.Storici values ('20120101','A',10), ('20120101','B',20),('20120201','A',11);

select * from dbo.Storici;


-- Updates table
create table dbo.Aggiornamenti (Data date, Codice varchar(12), valore int);
GO

insert into dbo.Aggiornamenti values 
('20120101','A',9),('20120201','A',11),  --- update an existing record
('20120301','B',23) -- create a new record

-- The record ('20120101','B',20) is missing so it will be deleted

select * from dbo.Aggiornamenti;

-- Let's use the MERGE
MERGE into dbo.Storici as S
	 using
		dbo.Aggiornamenti as A
		ON S.Data = A.Data AND S.Codice = A.Codice

-- First option, if a match occur based on the previous boolean condition
	when MATCHED then UPDATE
		SET S.valore = A.valore

-- Second option, if a match doesn't occur
	when NOT MATCHED then INSERT (Data,Codice,Valore) VALUES
		(a.Data,a.Codice,a.Valore)

-- Third option, if a record is available in the source but not in the update we can delete it
	when NOT MATCHED BY SOURCE then DELETE
-- The semicolumn is mandatory in the MERGE statement
;
	 
-- Let's check the result
select * from dbo.Storici;
	