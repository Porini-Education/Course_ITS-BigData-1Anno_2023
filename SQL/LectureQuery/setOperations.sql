-- SET OPERATION
/*
union
intersect
except
*/

-- gli ordini fatti nel 2014 e nel 2016

select * from sales.Orders where year(orderdate) = 2014
union all
select * from sales.Orders where year(orderdate) = 2014

-- vorrei vedere i clienti che hanno fatto ordini sia nel 2014 sia nel 2016
select custid from sales.Orders where year(orderdate) = 2014		--152
intersect															--61
select custid from sales.Orders where year(orderdate) = 2016		--270

-- vorrei vedere i clienti che hanno fatto ordini sia nel 2014 ma non nel 2015
select distinct custid from sales.Orders where year(orderdate) = 2014		--152
except															--61
select distinct custid from sales.Orders where year(orderdate) = 2015		--270

/*
-- verifica il risultato sopra
custid
13
69
*/

select * from sales.Orders where custid in (13,69)