use Test_C001
GO


	SET LANGUAGE us_english;
	select convert(date,'02-10-2010')
	-- restituisce 10 febbraio
	SET LANGUAGE italian;
	select convert(date,'02-10-2010')
	-- restituisce 2 ottobre

	SET LANGUAGE us_english;
	select convert(date,'20101002')
	-- restituisce 2 ottobre
	SET LANGUAGE italian;
	select convert(date,'20101002')
	-- restituisce 2 ottobre

	SET LANGUAGE us_english;
	select convert(datetime,'20101002')
	-- restituisce 2 ottobre
	SET LANGUAGE italian;
	select convert(datetime,'20101002')
	-- restituisce 2 ottobre

	
	SET LANGUAGE us_english;
	SET DATEFORMAT 'dmy'
	select convert(date,'02-10-2010')
	-- restituisce 2 ottobre


SET LANGUAGE us_english;
select convert(datetime,'2010-10-02')
-- restituisce 2 ottobre
SET LANGUAGE italian;
select convert(datetime,'2010-10-02')
-- restituisce 10 febbraio

SET LANGUAGE us_english;
select convert(date,'2010-10-02')
-- restituisce 2 ottobre
SET LANGUAGE italian;
select convert(date,'2010-10-02')
-- restituisce 2 ottobre



	--- ***** FUNZIONI
SELECT
  GETDATE()           AS [GETDATE],
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP],
  GETUTCDATE()        AS [GETUTCDATE],
  SYSDATETIME()       AS [SYSDATETIME],
  SYSUTCDATETIME()    AS [SYSUTCDATETIME],
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT
  CAST(SYSDATETIME() AS DATE) AS [current_date],
  CAST(SYSDATETIME() AS TIME) AS [current_time];

	select convert(datetime,'20101002'); -- 2010-10-02 00:00:00.000
	select convert(varchar(30),convert(datetime,'20101002'),9); -- Oct  2 2010 12:00:00:000AM

	select convert(datetime,'17:15:00'); -- 1900-01-01 17:15:00.000
	select convert(varchar(30),convert(datetime,'17:15:00'),9); -- Jan  1 1900  5:15:00:000PM

	SELECT CONVERT(DATE, '02/12/2016', 101);
SELECT CONVERT(DATE, '02/12/2016', 103);

SELECT PARSE('02/12/2016' AS DATE USING 'en-US');
SELECT PARSE('02/12/2016' AS DATE USING 'en-GB');

	select * from sys.time_zone_info

	select getdate(); -- DateTime locale
	select switchoffset(getdate(), '+02:00')  -- DateTimeOffset + 2 ore
	select convert(datetime,switchoffset(getdate(), '+02:00')) -- Date Time + 2 0re


	select getdate() AT TIME ZONE ('Pacific Standard Time') -- DateTimeOffeset al fuso Pacifico


	select TODATETIMEOFFSET(getdate(), '+02:00')
	select convert(datetime,TODATETIMEOFFSET(getdate(), '+02:00'))

	select datepart(month,'20180203');
	select datename(month,'20180203');


	select EOMONTH (getdate())


-- ISDATE
SELECT ISDATE('20160212');
SELECT ISDATE('20160230');

-- fromparts
SELECT
  DATEFROMPARTS(2016, 02, 12),
  DATETIME2FROMPARTS(2016, 02, 12, 13, 30, 5, 1, 7),
  DATETIMEFROMPARTS(2016, 02, 12, 13, 30, 5, 997),
  DATETIMEOFFSETFROMPARTS(2016, 02, 12, 13, 30, 5, 1, -8, 0, 7),
  SMALLDATETIMEFROMPARTS(2016, 02, 12, 13, 30),
  TIMEFROMPARTS(13, 30, 5, 1, 7);

-- EOMONTH
SELECT EOMONTH(SYSDATETIME());

-- orders placed on last day of month
SELECT orderid, orderdate, custid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);
