use Test_C001
go

DROP TABLE IF EXISTS dbo.T03;
go

create table dbo.T03
(
	id int not null,
	citta varchar(20) not null,
	cap char(5)  null,
	valore numeric (10,3) null,
	periodo date 
);
GO

DROP TABLE IF EXISTS dbo.T03FK;
create table dbo.T03FK
(id int not null,
citta varchar(20) 
);
GO

--  Creazione PK (generano un indice)
ALTER TABLE dbo.T03 ADD CONSTRAINT pk_id PRIMARY KEY (id)

insert into dbo.T03  (id,citta,cap,valore,periodo)
values (1,'Milano','20100',100,'20180101');

-- questo da errore per la PK dulicata
insert into dbo.T03  (id,citta,cap,valore,periodo)
values (1,'Brescia','25100',100,'20180102');

insert into dbo.T03  (id,citta,cap,valore,periodo)
values (2,'Brescia','25100',100,'20180102');

select * from dbo.T03;

ALTER TABLE dbo.T03 ADD CONSTRAINT unq_cap UNIQUE (cap);

-- errore per unique CAP
insert into dbo.T03  (id,citta,cap,valore,periodo)
values (3,'Brescia','25100',100,'20180102');

insert into dbo.T03  (id,citta,cap,valore,periodo)
values (3,'Brescia','25101',100,'20180102');

-- pulisco i dati
truncate table dbo.T03;

-- non possibile il campo referenziato non può essere duplicato 
ALTER TABLE dbo.T03 ADD CONSTRAINT fk_citta FOREIGN KEY (citta)
REFERENCES dbo.T03FK (Citta);

ALTER TABLE dbo.T03FK ADD CONSTRAINT unq_citta UNIQUE (citta);

ALTER TABLE dbo.T03 ADD CONSTRAINT fk_citta FOREIGN KEY (citta)
REFERENCES dbo.T03FK (Citta);

insert into dbo.T03FK values (1,'Milano');
go

insert into dbo.T03 
(id,citta,cap,valore)
values (1,'Milano',20100,200);
go

insert into dbo.T03 
(id,citta,cap,valore)
values (2,'Brescia',25100,200);
go



ALTER TABLE dbo.T03 ADD CONSTRAINT def_periodo DEFAULT (getdate()) FOR periodo;

insert into dbo.T03 
(id,citta,cap,valore)
values (2,'Milano',20101,200);
go

select * from dbo.T03

ALTER TABLE dbo.T03 ADD CONSTRAINT chk_valore CHECK (valore > 0)

insert into dbo.T03 
(id,citta,cap,valore)
values (3,'Milano',20103,0);
go

insert into dbo.T03 
(id,citta,cap,valore)
values (3,'Milano',20103,10);
go

select * from dbo.T03

-- missing CAP
insert into dbo.T03 
(id,citta,cap,valore)
values (4,'Milano',null,10);
go


select * from dbo.T03 -- CAP missing

-- Non accetta un altro CAP missing
insert into dbo.T03 
(id,citta,cap,valore)
values (5,'Milano',null,11);
go

alter table dbo.T03 drop CONSTRAINT unq_cap ;

CREATE UNIQUE INDEX inc_cap ON dbo.T03 (cap) WHERE cap IS NOT NULL;

-- ora posso inserire un altro cap missing
insert into dbo.T03 
(id,citta,cap,valore)
values (5,'Milano',null,11);
go

select * from dbo.T03;

-- ma non cap duplicati
insert into dbo.T03 
(id,citta,cap,valore)
values (6,'Milano',20100,11);
go

-- Pulizia 
drop table if exists dbo.T03;

drop table if exists dbo.T03FK;
GO