-- ****** LAB CREATE TABLE

-- Utilizzare il database Test_C001

 --use Test_C001
 --GO

/*
esercizio 1

creare le tabelle
 
dbo.Articoli con
CodiceArticolo, Articolo, FamigliaArticolo, Costo, PrezzoVendita

dbo.Citta con
Citta, Provincia, Regione

dbo.Clienti con
CodiceCliente, NomeCliente, Citta

dbo.Vendite con 
IdVendita, DataVednita, CodiceCliente, CodiceArticolo, NumeroPezzi

*/

/* 
esercizio 1 soluzione


--drop table  dbo.Articoli;
--go

create table dbo.Articoli
(
CodiceArticolo varchar(12) not null,
Articolo varchar(200) not null,
FamigliaArticolo varchar(50) not null,
Costo numeric (8,2),
PrezzoVendita numeric (12,2)
);

*/


/*
esercizio 2

aggiungere alle tabelle create in precedenza i vincoli
PK, FK, Check che si ritengono opportuni

*/
