   
/*
https://opensky-network.org/apidoc/rest.html

0	icao24	string	Unique ICAO 24-bit address of the transponder in hex string representation.
1	callsign	string	Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
2	origin_country	string	Country name inferred from the ICAO 24-bit address.
3	time_position	int	Unix timestamp (seconds) for the last position update. Can be null if no position report was received by OpenSky within the past 15s.
4	last_contact	int	Unix timestamp (seconds) for the last update in general. This field is updated for any new, valid message received from the transponder.
5	longitude	float	WGS-84 longitude in decimal degrees. Can be null.
6	latitude	float	WGS-84 latitude in decimal degrees. Can be null.
7	baro_altitude	float	Barometric altitude in meters. Can be null.
8	on_ground	boolean	Boolean value which indicates if the position was retrieved from a surface position report.
9	velocity	float	Velocity over ground in m/s. Can be null.
10	true_track	float	True track in decimal degrees clockwise from north (north=0°). Can be null.
11	vertical_rate	float	Vertical rate in m/s. A positive value indicates that the airplane is climbing, a negative value indicates that it descends. Can be null.
12	sensors	int[]	IDs of the receivers which contributed to this state vector. Is null if no filtering for sensor was used in the request.
13	geo_altitude	float	Geometric altitude in meters. Can be null.
14	squawk	string	The transponder code aka Squawk. Can be null.
15	spi	boolean	Whether flight status indicates special purpose indicator.
16	position_source	int	Origin of this state’s position: 0 = ADS-B, 1 = ASTERIX, 2 = MLAT

*/

/*
#Codice Powershell per il download del file

$Request = "https://opensky-network.org/api/states/all?lamin=45.8389&lomin=5.9962&lamax=47.8229&lomax=10.5226"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Matrimoni = Invoke-WebRequest $request
$Matrimoni.Content | Out-File "c:\temp\fights.txt"
*/
   
/*
codice Power Shell per il download

$Request = "https://opensky-network.org/api/states/all?lamin=45.8389&lomin=5.9962&lamax=47.8229&lomax=10.5226"

$Request = "https://opensky-network.org/api/states/all?lamin=36.2600&lomin=6.4730&lamax=47.2170&lomax=14.1596"

$Request = "https://opensky-network.org/api/states/all?lamin=36&lomin=5&lamax=48&lomax=10"

<#
47.216925 Lat Nord
14.159571 Lon Est
6.473083 Lon Ovest
36.254225 Lat Sud
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Voli =Invoke-WebRequest $request

#$Voli | ConvertTo-Html | Out-File "c:\temp\Voli.html"
#$voli.Content | Out-File "c:\temp\voli.txt"
*/

/* ESEMPIO 1: inserimento in Sql Server e successiva attività in TSQL

    Deve esistere un database ed una tabella in cui inserire i dati letti dalla web app

        create table dbo.tmpVoli 
        (id int identity(1,1),
        volo nvarchar(max)
        );
        GO

    o una store procedure in grado di consumarli

   select	json_value (a.volo,'$.time') as EpocTime,
		DateAdd(ss, convert(bigint,json_value (a.volo,'$.time')), '19700101') as DataTempo,
		c.*
     from dbo.tmpVoli a
     cross apply openjson (json_query(a.volo,'$.states')) b
     cross apply openjson ('{"aereo":' + b.value +'}')
     with
     (
     icao24 varchar(12) '$.aereo[0]',
     callsign varchar(12) '$.aereo[1]',
     origin_country varchar(12) '$.aereo[2]',
     time_position bigint '$.aereo[3]',
     last_contact bigint '$.aereo[4]',
     longitude numeric(7,4) '$.aereo[5]',
     latitude numeric(7,4) '$.aereo[6]',
     baro_altitude numeric(12,2) '$.aereo[7]',
     on_ground varchar(5) '$.aereo[8]',
     velocity numeric(7,2) '$.aereo[9]',
     true_track numeric(6,2) '$.aereo[10]',
     vertical_rate numeric(6,2) '$.aereo[11]',
     sensors varchar(12) '$.aereo[12]',
     geo_altitude numeric(12,2) '$.aereo[13]',
     squawk varchar(200) '$.aereo[14]',
     spi varchar(5) '$.aereo[15]',
     position_source int '$.aereo[16]'
     ) c


     
alter procedure opensky.InsertFlightData (@fd nvarchar(max))
as

select @fd as volo into #tmpFD;

insert into opensky.FlightData

select	json_value (a.volo,'$.time') as EpocTime,
		DateAdd(ss, convert(bigint,json_value (a.volo,'$.time')), '19700101') as DataTempo,
		DateAdd(ss,last_contact,'19700101') as LastContact,
		c.*
 from #tmpFD a
 cross apply openjson (json_query(a.volo,'$.states')) b
 cross apply openjson ('{"aereo":' + b.value +'}')
 with
 (
 icao24 varchar(12) '$.aereo[0]',
 callsign varchar(12) '$.aereo[1]',
 origin_country varchar(12) '$.aereo[2]',
 time_position bigint '$.aereo[3]',
 last_contact bigint '$.aereo[4]',
 longitude numeric(7,4) '$.aereo[5]',
 latitude numeric(7,4) '$.aereo[6]',
 baro_altitude numeric(12,2) '$.aereo[7]',
 on_ground varchar(5) '$.aereo[8]',
 velocity numeric(7,2) '$.aereo[9]',
 true_track numeric(6,2) '$.aereo[10]',
 vertical_rate numeric(6,2) '$.aereo[11]',
 sensors varchar(12) '$.aereo[12]',
 geo_altitude numeric(12,2) '$.aereo[13]',
 squawk varchar(200) '$.aereo[14]',
 spi varchar(5) '$.aereo[15]',
 position_source int '$.aereo[16]'
 ) c
 ;
  go
  */

    create table #tmpVoli 
        (id int identity(1,1),
        volo nvarchar(max)
        );
        GO

   select	json_value (a.bulkcolumn,'$.time') as EpocTime,
		DateAdd(ss, convert(bigint,json_value (a.bulkcolumn,'$.time')), '19700101') as DataTempo,
		DateAdd(ss,last_contact,'19700101') as LastContact,
		c.*
     from OPENROWSET (BULK 'C:\Temp\voli.txt', SINGLE_NCLOB) a
     cross apply openjson (json_query(a.bulkcolumn,'$.states')) b
     cross apply openjson ('{"aereo":' + b.value +'}')
     with
     (
     icao24 varchar(12) '$.aereo[0]',
     callsign varchar(12) '$.aereo[1]',
     origin_country varchar(12) '$.aereo[2]',
     time_position bigint '$.aereo[3]',
     last_contact bigint '$.aereo[4]',
     longitude numeric(7,4) '$.aereo[5]',
     latitude numeric(7,4) '$.aereo[6]',
     baro_altitude numeric(12,2) '$.aereo[7]',
     on_ground varchar(5) '$.aereo[8]',
     velocity numeric(7,2) '$.aereo[9]',
     true_track numeric(6,2) '$.aereo[10]',
     vertical_rate numeric(6,2) '$.aereo[11]',
     sensors varchar(12) '$.aereo[12]',
     geo_altitude numeric(12,2) '$.aereo[13]',
     squawk varchar(200) '$.aereo[14]',
     spi varchar(5) '$.aereo[15]',
     position_source int '$.aereo[16]'
     ) c
;

/*
 Utilizzo di PowerShell per esecuzione Store Procedure

 #Inserimento nella tabella

 $Voli=Get-Content "c:\temp\voli.txt"

Invoke-Sqlcmd -Query "insert into test.dbo.tmpVoli values ('$Voli') " -ServerInstance "localhost"
Invoke-Sqlcmd -Query "exec test.opensky.LoadFlight " -ServerInstance "localhost"
#Invoke-Sqlcmd -Query "insert into opensky.tmpVoli values ('$Voli') " -ServerInstance "PoriniEducationSqlServer.database.windows.net" -Username "sky" -Password "TangoSierra360" -Database "EducationData"


#Chiamata Store Procedure

        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = "Data Source=localhost;Initial Catalog=test;Integrated Security=true"
        
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 120
       
        $JVoli = $voli.Content | ConvertTo-Json
        $cmd.CommandText = "EXEC opensky.InsertFlightData2 $Voli"

         try
        {
            $scon.Open()
            $cmd.ExecuteNonQuery() | Out-Null
        }
        catch [Exception]
        {
            Write-Warning $_.Exception.Message
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }

*/

