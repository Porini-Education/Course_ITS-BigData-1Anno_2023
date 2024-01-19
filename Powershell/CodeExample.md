# First examples of Powershell code

``` PS
# ************************************************** #
#
# Esempi corso Powershell - 01
#
#
#
#
# ************************************************** #

#region -- DOCUMENTAZIONE **************

https://github.com/PowerShell/PowerShell/releases

$PSVersionTable.PSVersion  #versione Powershell

#endregion

#region -- VARIABLES **************

#ogni variabile è un oggetto


    $null -eq $var #non definita è null

#non è necesssario dichiarare il data type: viene definito sulla base del valore assegnato

    $var = 5
    $var.GetType().FullName
    $var | Get-Member #metodi dell'oggetto


    $var = "text"
    $var.GetType().FullName
    $var | Get-Member


    #possibile indicare espressamente i datatype
    [int]$var = "5"
    $var.GetType().FullName

    # il data type deriva dal primo elemento
    1 + "10"
    "10" + 1

    "Alfa" +1
    1 + "Alfa"

     $var10 = 99
     $var10 + "bravo"
    "$var10" + "bravo"
    '$var10' + "bravo"
    "$var10 bravo"
    "$var10 + bravo"

    #region -- NUMBERS **************

    $var += 1
    $var
    $var++
    $var

    $var = 12.789 #rimane int
    $var

    $var1 = 12.789
    $var1

    $var1++
    $var1

    #conversione a int
    [int]$var1 = $var1  #arrotonda non tronca (differenza rispetto a TSQL)
    $var1

    # tramite Powershell si può accedere a tutti i metodi delle classi .Net

    [System.Math]::Ceiling(10.1) # adjusts the value to 11            
    [System.Math]::Ceiling(10.8) # adjusts the value to 11            
    [System.Math]::Floor(10.1) # adjusts the value to 10            
    [System.Math]::Floor(10.8) # adjusts the value to 10

    #endregion

    #region -- STRINGS **************
    $string = "Quando talor frattanto"

    # A variable is an object with methods and properties
    $string | Get-Member

    $string.ToUpper()
    $string.ToLower()
    $string.Contains("Quando")
    $string.Contains("Quindi")
    $string.Length
    $string.Substring(0,3)
    $string.Split(' ')


    # double quote and single quote
    Write-Host 'My variable contains: $string'
    Write-Host "My variable contains: $string"  # doppie virgolette presentatno il valore della variabile
    Write-Host "Today is $((Get-Date).DayOfWeek) and my variable contains $($string.Length) chars"


    # here-string: blocchi di testo multi linea sono definite con il carattere @ all'inizio ed alla fine
    #utilizzabile come script block per metaprogrammazione
    $testo = 
    @"
    Ognuno sta solo sul cuore della terra
    trafitto da un raggio di sole:
    ed è subito sera.
    Poesia di {0} letta di {1}
"@  #non ci devono essere blank davanti al @ finale

    $testo
    $testo.Replace("{1}", (Get-Date).DayOfWeek)
    $testo -f 'Salvatore Quasimodo',(Get-Date).DayOfWeek   #sostituzione di placeholder

    #endregion

 #region -- DATE TIME **************       
$now = (Get-Date)  # date time attuale

$now.GetType().FullName
$now.Month

Get-Date -Format "dddd MM/dd/yyyy HH:mm K"  # es: lunedì 06/27/2022 13:57 +02:00 K = UTC
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"  # es: lunedì 06/27/2022 13:57:45  HH ==> 0re 00-24
Get-Date -Format "dddd MM/dd/yyyy hh:mm:ss tt"  # es: lunedì 06/27/2022 13:57:45  hh ==> ore 00-12
Get-Date -Format "yyyyMMMdd"  # es: 2022giu27


# assegnazione di una date time
Get-Date -Year 2022 -Month 12 -Day 31
(Get-Date -Year 2022 -Month 12 -Day 31).DayOfYear

Get-Date -Year 2022 -Month 12 -Day 31 -Hour 15 -Minute 55


get-date -DisplayHint Date  # restituisco solo date 

(get-date).IsDaylightSavingTime()  # E' attiva l'ora legale

Get-TimeZone
Get-Date -Date "2022-11-01T00:00:00"
Get-Date -Date "2022-11-01"

#Input date con formati custom
$timeinfo = '12 07 2012 18 02'
$template = 'HH mm yyyy dd MM'
[DateTime]::ParseExact($timeinfo, $template, $null)

(Get-Date).AddDays(2).AddHours(1)  

[DateTime]$StartDate ='2020-12-13'
[DateTime]$EndDate ='2020-12-16'

$diff= NEW-TIMESPAN –Start $StartDate –End $EndDate  #differenza tra date
$diff.Days

#endregion

#endregion

#region -- COMANDI **************  

# cmd-let nella forma verbo-nome

Get-Command   # elenco  cmd-let presenti nei moduli installati
Get-InstalledModule  #elenco dei moduli installati

Get-Command | Select-Object -First 5 | Format-List *

# Comandi con un certo nome
Get-Command -Name dir
Get-Command -Noun DNS*
Get-Command -Name *inv* -Module sq*

# comandi con un certo verbo
Get-Command -Verb get

Get-Alias # elenco Alias
Get-Verb  # elenco dei verbi "ufficiali"

Get-Command | Select-Object -First 1 | Get-Member 

$comandi = Get-Command | Where-Object {$_.Module -like '*excel*' }

$c = Get-Command -Name get-childitem
$c.ModuleName

#meta programmazione (esecuzione di stringhe)
$strCmd = @" 
Get-ChildItem c:\temp 
"@

Invoke-Expression $strCmd

#Multiline statement 
New-Item -Path c:\temp -Name "testfile1.txt" -ItemType "file" -Value "Alfa Bravo" -Force


# with backtick
# backtick ==> alt 96 `
New-Item -Path c:\temp `
    -Name "testfile1.txt" `
    -ItemType "file" `
    -Value "Alfa Bravo Charlie" `
    -Force

# splatting
$params = @{
    Path = "c:\temp"
    Name = "testfile1.txt"
    ItemType = "file"
    Value = "Alfa Bravo Charlie Delta"
    Force = $true
}
New-Item  @params


#endregion

#region -- HELP **************
update-help  #da fare come primo step e periodicamente

get-help Get-ChildItem

get-help Get-ChildItem # -Full -Examples -ShowWindow 

get-help get-help -ShowWindow



get-help about_comment_based_help -full 
get-help about_functions -ShowWindow

#endregion

#region -- ARRAY **************

get-help about_array #| Out-File c:\temp\Array.txt


$array = "1", "2", "3"  # valori separati dalla , vengono considerati elementi di un array
$array
$array.Count
$array.GetType().FullName
$array[1]


$B = 5..8  #utilizzo del range
$B.Count


$array = @()  # array vuoto creato di tipo SYSTEM.OBJECT[]  @(..) array operator crea un array anche con zero elementi
$array.Count  # numero di elementi

  

$array += "alfa"
$array += "bravo"
$array += "charlie"
$array
$array.GetType().FullName

$array[1] 
$array[1].GetType().FullName


$array += 100  #aggiunta di un elemento
$array[3]
$array[3].GetType().FullName # ogni elemento ha il suo data type


[int32[]]$ia = 1500,2230,3350,4000  #tipizzo l'array per contenere solo interi  (altri datatype STRING[], LONG[], or INT32[]) 
$ia += 'zulu' # ==> errore


[Diagnostics.Process[]]$zz = Get-Process  #si può tipizzare con ogni type .NET Framework ()
$zz

# riferimento agli elementi
$an = @(1,2,3,4,5,6,7,8,9,10)

$an[0..4]   # mi riferisco agli elementi di un intervallo (0 primo elemento)
$an[-1..-4] # con numeri negativi conto dall'ultimo  (-1 ultimo elemento)
$an[1..-1]  # cicla
$an[0,2+4..6] # con il + si concatenano gli elementi 0,2,4,5,6



$testo= "alfa bravo charlie"
$array = $testo.Split(" ") # creo array da stringa
$array

$array[0]
$array.Count

$array -join ", "  # restituisco stringa da array



# recupero valori distinti

$Animali = 
"Animal,Snack,Color
Horse,Quiche,Chartreuse
Cat,Doritos,Red
Cat,Pringles,Yellow
Dog,Doritos,Yellow
Dog,Doritos,Yellow
Rabbit,Pretzels,Green
Rabbit,Popcorn,Green
Marmoset,Cheeseburgers,Black
Dog,Doritos,White
Dog,Doritos,White
Dog,Doritos,White" | ConvertFrom-Csv

$Animali
$Animali.Count
$Animali[1] | Get-Member
$Animali[2].Color


$Animali | Select-Object -Unique -Property Animal  #restituisce valori distinti per una proprieta
$Animali | Get-Unique -AsString #restituisce valori distinti su tutte le proprieta


$Animali | Get-Member #propieta del contenuto dell'array
,$Animali | Get-Member  #Proprieta dell'array

# Matrici
$am = @('alfa','bravo','charlie')
$am.Rank # numero di dimensioni

#finta matrice
$am = @(
      @(0,1),
      @("b", "c")
    )

$am.Rank
$am

#vera matrice utilizzo oggetto .Net Framework

    [int[,]]$rank2 = [int[,]]::new(5,5)
    $rank2.rank


$am = @('alfa','bravo','charlie')
$am.Clear()  #resetta i valori, non riduce il numero di dimensioni
$am.Count
$am[2] ='papa'
$am[0],$am[1],$am[2]

 ,$am | Get-Member


 # assegnazione valori agli elementi
 $a = @('alfa','bravo','charlie')
 $a[0] = 1
 $a.SetValue(500,1)
 $a

 #eliminazione elementi
 $a = @('alfa','bravo','charlie','delta')
 $a[1]= $null  # elimina l'elemendo, ma non riduce le dimensione - veloce
 $a.Count 
 $a[1]= 'pippo'
 $a

# per ridimensionare si crea un nuovo array
$a = @('alfa','bravo','charlie','delta','echo','fox-trot','golf')
$a = $a[0,1 + 3..($a.length - 1)] #elino il 2 elemento
$a
$a.Count

# combinazione di array
    $x = 1,3
    $y = 5,9,11
    $z = $x + $y
    $z



$a = $null  #eliminazione array


#endregion

#region -- HASH TABLE (dictionary) **************  
get-help about_Hash_Tables #| Out-File c:\temp\Hash_Tables.txt

# oggetti di tipo System.Collections.Hashtable
# utilizzati per costruzione oggetti custom (classi)

$hash01 = @{}  #inizia con @ e le coppie chiave valori sono all'interno di {} separate da ;
$hash01
$hash01.Count

$hash01 = @{Number = 1; Shape = "Square"; Color = "Blue"}  # non ordinata (intrensicamente), la chiave non è tra ""
$hash01
$hash01.Count


$hash01 = [ordered]@{Number = 1; Shape = "Square"; Color = "Blue"}  # ordinata
$hash01
$hash01.Count

$hash01.Keys
$hash01.Values

$hash01.Color  # il valore è restituito indicando il nome della chiave


#Aggiunta di coppie chiave-valore
$hash01.Valore= 100 # metodo 1
$hash01.Add("Classe","Alta") # metodo 2
$hash01 = $hash01 + @{Codice="Alfa101"} # metodo 3

$hash01


# rimozione d una coppia chiave-valore
$hash01.Remove("Classe")
$hash01


# metodi Contains, Clear, Clone, CopyTo ...
$hash01.Contains('Color')   ==> True

$hash01.Clear()
$hash01
$hash01.Count

# i valori possono essere oggetti .Net e array
    $p = @{"PowerShell" = (get-process PowerShell);"Notepad" = (get-process notepad)}
    $p.PowerShell
    $p.PowerShell.Count
    $p.PowerShell[0]

# i valori possono essere un hash table
$p = @{Codice="Alfa";Valore=100}
$p = $p + @{"h1"= @{a=1; b=2; c=3}}
$p
$p.Count
$p.h1.Count
$p.h1.a


# creazione di un hashtable da una stringa (o da una here-string) tramite ConvertFrom-StringData
$testo = @"
frase1 = abbiamo sognato il mondo
frase2 = l'abbiamo sognato ubiquo
"@

$a= ConvertFrom-StringData $testo
$a

# Hashtable per creare oggetti custom

#definisco le proprietà
$rectangle = [PSCustomObject]@{
    Height = ""
    Width = ""
}

$rectangle.Height= 10
$rectangle

#definisco un metodo e lo aggiungo all'oggetto
$scriptBlock = {
    
    try {
        $this.Height * $this.Width
    }
    catch {
        Write-Error "Please insert values for Width and Height."
    }

}

$rectangle | Add-Member -Name "Area" -MemberType ScriptMethod -Value $scriptBlock

$rectangle | Get-Member

$rectangle.Width = 2
$rectangle.Height = 3
$rectangle.Area()

#endregion

#region --,COMPARISON OPERATOR **************  

-eq --> equal
-ne --> not equal
-gt --> greater than
-ge --> equal or greater than
-lt --> less than
-le --> equal or less than
-contains
-notcontains
-match
-notmatch
-like
-notlike
-is
-isnot
-in
-notin

$a = 'fatti non foste'
$a.Contains('non')

$a= 'alfa','bravo','charlie'
$a.contains('bravo')
'charlie' -in $a

#endregion

#region -- FILE & FOLDER **************

# creazione
New-Item -Path 'c:\temp'  -Name 'test2' -ItemType 'directory'  

New-Item -Path c:\temp -Name "testfile1.txt" -ItemType "file" -Value "Alfa Bravo Charlie"


# copia
(Get-childitem c:\temp -File | Where-Object {$_.Length -lt 2000} )[1] | Copy-Item -Destination C:\Temp\test

cd 'C:\Temp'
Get-Item "*.txt" | Select-Object -First 2 | Copy-Item -Destination C:\Temp\test

# eliminazione
Remove-Item -Path C:\Temp\test -Force -Recurse # -InformationAction SilentlyContinue -Confirm:$false  

# output

cd c:\temp

Write-Output "Alfa Bravo" > .\text1.txt
Write-Output "Zulu Papa" >> .\text1.txt
notepad.exe .\text1.txt

"Messagge 1" | Out-File text2.txt
"Messagge 2" | Out-File -Append text2.txt
notepad.exe .\text2.txt

# Lettura del contenuto del file testo
$fileContent = Get-Content .\text1.txt
$fileContent


# esecuzione di un file
New-Item -Path c:\temp -Name "pgm01.ps1" -ItemType "file" -Value "get-childitem c:\temp"  #creo file comandi di esempio

Invoke-Expression C:\Temp\pgm01.ps1  # oppure "C:\Temp\pgm01.ps1" | Invoke-Expression 


#endregion

#region -- Output - Input **************

# Output to CSV
Get-ChildItem -File| Select Name, Length
Get-ChildItem -File | Select Name, Length| Export-Csv -Path c:\temp\dir.csv -NoTypeInformation

notepad c:\temp\dir.csv

# Reading from CSV
Get-Content c:\temp\dir.csv

$table = Import-Csv -Path c:\temp\dir.csv
$table
$table.Count


# conversioni
$dati | ConvertTo-Csv -Delimiter ','

$dati = 
"Animal,Snack,Color
Horse,Quiche,Chartreuse
Cat,Doritos,Red
Cat,Pringles,Yellow
Dog,Doritos,Yellow
Dog,Doritos,Yellow
Rabbit,Pretzels,Green
Rabbit,Popcorn,Green
Marmoset,Cheeseburgers,Black
Dog,Doritos,White
Dog,Doritos,White
Dog,Doritos,White" | ConvertFrom-Csv

$dati[0]


$dati = Read-SqlTableData -DatabaseName test_c001 -ServerInstance carafa -TableName orders -SchemaName sales


$dati | ConvertTo-Csv -Delimiter ',' -NoTypeInformation | Out-File -FilePath C:\temp\dati.txt
notepad.exe C:\temp\dati.txt

# occhio alla data in formato Json  si può rileggerla con ConvertFrom-Json
$dati | Select-Object -Property orderid,custid,empid,orderdate,requireddate,shippeddate,shipperid,freight | ConvertTo-Json | Out-File -FilePath C:\temp\dati.json
notepad.exe C:\temp\dati.json


$dati | Select-Object -Property orderid,custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry |
 ConvertTo-Html | Out-File -FilePath C:\temp\dati.html
notepad.exe C:\temp\dati.html


$dati | Export-Excel -Path c:\temp\sales.xlsx -WorksheetName ordini

$ex = Open-ExcelPackage -Path 'c:\temp\sales.xlsx'
Close-ExcelPackage $ex -Show



#endregion

#region -- PIPELINE **************

#endregion

#region -- IF **************

$a = 1
if($a -gt 2) {
    Write-Host "A is greater than 2"
}
else {
    Write-Host "A is less or equal to 2"
}


# SWITCH statement
$a = "Parvma"
switch ($a) {
    "Milano" { Write-Host "Regione Lombardia" }
    "Napoli" { Write-Host "Regione Campania" }
    "Roma" {Write-Host "Regione Lazio"}
    Default { Write-Host "None of the above"}
}

#endregion

#region -- LOOP **************
get-help about_Foreach #| Out-File c:\temp\ForEach.txt

# Get top 5 running services, sorted by name
$fs = Get-ChildItem c:\temp |  Sort-Object Name | Select-Object -First 10
$fs

$i= 1
$fs[$i].Name

# for
for ($i = 0; $i -lt $fs.Count; $i++) {
    Write-Host "File name: $($fs[$i].Name)"    # ****** Approfondire
}

for ($i = 0; $i -lt 1; $i++) {
    $nome = 
    Write-Host "File name: $fs[1].Name"    
}

# Do while
$i = 0
do {
    Write-Host "File name: $($fs[$i].Name)"
    $i++
} while ($i -lt $fs.Count)

# Do until
$i = 0
do {
    Write-Host "File name: $($fs[$i].Name)"
    $i++
} until ($i -eq $fs.Count)

# ForEach - readability
foreach($f in $fs) {
    Write-Host "File name: $f.Name"
}

# ForEach-Object - less verbose
$fs | % { Write-Host "File name: $_.Name" }


#---

$numbers = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
$numbers | ForEach-Object {
    Write-Host $_
}


Get-ChildItem c:\temp -File  -Filter * | Foreach-Object {
    Write-Host $_.Name $_.CreationTime
    Write-Host 
}


Get-ChildItem -Path "C:\Temp" | ForEach-Object {
    $ItemPath = $_.FullName
    $ItemSize = $_.Length
    Write-Host "$ItemPath is $ItemSize bytes"
}


(0..9).Where{ $_ % 2 }  #restituisce dove true (dispari)




#endregion

#region -- SQL SERVER **************

$Request = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json"

$Dati =Invoke-WebRequest $request

$valori = $Dati.Content | ConvertFrom-Json | Select-Object -First 50
$valori2 = $valori | Select-Object -First 50
$valori[33]
$valori2.Count

#-SqlCredential $cred 
Write-DbaDbTableData -SqlInstance carafa -Database Test  -InputObject $valori2 -Table dbo.covid -AutoCreateTable -Truncate


Read-SqlTableData -DatabaseName test -ServerInstance carafa -TableName covid -SchemaName dbo

$q ="SELECT * FROM [dbo].[covid] where denominazione_regione = '{0}' " -f 'Liguria' 
Invoke-Sqlcmd -Query $q -ServerInstance "Carafa" -Database "test" #-Username "EducationDataOwner" -Password "xxxxxxx"

#endregion

#region -- EXCEL **************

# export to Excel
    $Request = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json"

    $Dati =Invoke-WebRequest $request

    $DatiRegione = $Dati.Content | ConvertFrom-Json
    $DatiRegione.Count

    $DatiRegione | Select-Object -First 10 | Export-Excel -Path c:\temp\CovidRegione.xlsx -WorksheetName regione -Show -ClearSheet


# import from excel
Import-Excel -path  c:\temp\CovidRegione.xlsx -AsDate "Data"

# write cells
    $excel = New-Object -ComObject excel.application 
    $excel.DisplayAlerts = $False

    $r = 1
    $numeroCitta = 10

    $workbook = $excel.Workbooks.Add()

    $foglio = $workbook.Worksheets.Item(1)
    $foglio.Name = "Citta" 
    $foglio.Cells.Item($r,1)  = 'Citta'


    while($r -le $numeroCitta){
        $r = $r+1
        $foglio.Cells.Item($r,1) = "Citta $r"
        }

    $excel.visible = $false

    $workbook.SaveAs('c:\temp\citta.xlsx')
    $excel.Quit()

#endregion

#region -- REST **************

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$Request = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json"

$Dati =Invoke-WebRequest $request
$Dati.Content | Out-File "c:\temp\covid.txt"
notepad.exe "c:\temp\covid.txt"

$DatiRegione = $Dati.Content | ConvertFrom-Json
$DatiRegione.Count

# download immagini
$request = 'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY'
$j =Invoke-WebRequest $request | ConvertFrom-Json 
Start-BitsTransfer $j.url  'c:\temp\nasa.jpg' -Priority High

#endregion

#region -- AZURE **************

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Connect-AzAccount

New-AzResourceGroup -Name usr-b51_00 -Location 'northeurope'

New-AzStorageAccount -ResourceGroupName usr-b51_00 -Name poriniedu00 -Location westus -SkuName Standard_GRS

$StorageAcc = Get-AzStorageAccount -ResourceGroupName usr-b51_00 -Name poriniedu00

$ctx = $StorageAcc.Context

$container = New-AzStorageContainer -Name valori -Permission blob -Context $ctx

#Caricamento file
$PathToUpLoad ="C:\Temp";
$FileToUpload1= "voli.txt";
$FilePathToUpload1 = $PathToUpLoad + "\" + $FileToUpload1;

Set-AzStorageBlobContent -context $ctx -File $FilePathToUpload1 -Container $container.Name -Blob $FileToUpload1 


# ******** creazione resurce group
$rg = New-AzResourceGroup -Name fp01 -Location northeurope

# ******** creazione virtual sql server

    #credenziali
    [string]$userName = "SqlEducationUser"
    [string]$userPassword = "SierraZulu2022"
    [securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

    [pscredential]$cred = New-Object System.Management.Automation.PSCredential ($userName,$secStringPassword)


    $sqlServer = New-AzSqlServer -ServerName poriniedu99 -SqlAdministratorCredentials $cred -Location northeurope -ResourceGroupName $rg.ResourceGroupName

    # apertura firewall
    $startIp = '0.0.0.0' 
    $endIp = '255.255.255.255'

    $serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $rg.ResourceGroupName -ServerName $sqlServer.ServerName -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

# ******** creazione azure sql database

    $dataBase = New-AzSqlDatabase -DatabaseName db1 -ServerName $sqlServer.ServerName -ResourceGroupName $rg.ResourceGroupName -RequestedServiceObjectiveName s0
    
# ******** valorizzazione Tags
    $tags = @{owner="Franco Pigoli";scopo="test"}
    New-AzTag -ResourceId $sqlServer.ResourceId -Tag $tags


# esecuzione script su Azure VM
$stringa = "New-Item -Path 'c:\'  -Name 'test2' -ItemType 'directory'"

$remotecommand = Invoke-AzVMRunCommand -ResourceGroupName test-win11-frapi -Name win11-00 -CommandId RunPowerShellScript -ScriptString $stringa

#endregion

#region -- MODULI **************

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 

# Elenco Moduli installati
Get-InstalledModule 

# Update Modulo se esiste versione precedente la affianca
Update-Module -Name ImportExcel 

# Verifica versione moduli installati
Get-InstalledModule -Name ImportExcel -AllVersions

#Elenco Moduli in memoria
Get-Module

#Rimozione dalla memoria
Remove-Module ImportExcel -Force


# Disinstallazione Modulo
Uninstall-Module -Name ImportExcel -RequiredVersion 7.1.1 # -AllVersions


#Elenco cmd-lets del modulo
get-command -Module ImportExcel



#elenco moduli disponibili nel repository 
Find-Module -filter excel #Azure
Find-Module | Where-Object {$_.Name -like "*excel*"}

#endregion

#region -- FUNCTIONS **************

function Get-Squared($number) {
    $number * $number
}

Get-Squared
Get-Squared -number 5
Get-Squared -number "aaa"


function Get-Squared {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)][int] $number
    )

    $number * $number

}

Get-Squared
Get-Squared -number 5
5 | Get-Squared

Function ShowName{
    param(
        [string]$name
    )
    if(-not[string]::isnullorwhitespace($name)){
    Write-Host 'Welcome' $name
    }
    else{
    Write-Host 'You forget to insert the name'
    }
}
ShowName -name Pippo


#endregion

#region -- UTILITY **************

#Transcript

    Start-Transcript -Path c:\temp\Transcript.txt -Force -IncludeInvocationHeader
    Write-Host "This is a test message"
    Get-ChildItem
    Write-Host "End"
    Stop-Transcript

notepad.exe c:\temp\Transcript.txt

# CREDENTIALS
#$credential = Get-Credential  #recupero credenziali memorizzate
#$credential

$credential = New-Object System.Management.Automation.PSCredential ('username', (ConvertTo-SecureString "AlfaZulu" -AsPlainText -Force))
$credential


# Secret

#
# Microsoft.PowerShell.SecretManagement
# Microsoft.PowerShell.SecretStore
#

# Find-Module -Name 'Microsoft.PowerShell.Secret*' | Format-Table -Wrap -AutoSize 

# Get-Module -Name Microsoft*.Secret* -ListAvailable |Format-Table -Property ModuleType, Version, Name, ExportedCmdlets


#endregion

#region -- MODULI DA INSTALLARE **************

Get-InstalledModule *secre*

    Install-Module Az.Accounts
    Install-Module Az.Sgtorage
    Install-Module Az.Sql
    Install-Module dbatools
    Install-Module ImportExcel

   Update-Module Microsoft.PowerShell.SecretManagement
   Update-Module Microsoft.PowerShell.SecretStore

#endregion


#region -- TODO **************

about_Operators

$elementi = Get-ChildItem c:\temp

$elementi.Count

$elementi | Get-Member

$elementi[1] | get-member

$elementi[10] | Format-list

#endregion

#region -- Filtering and Selecting **************

#PowerShell is based on objects.  Nearly every command will output an object with multiple properties that can be viewed and filtered on individually.
$elementi | Where-Object {$_.Extension -eq '.txt' -and $_.Length -lt 2000}

$elementi| Select-Object -Property Name, Lenght, LastAccessTime

Get-ChildItem  c:\temp  | Sort-Object Length  –Descending | Select-Object -First 5 

Get-ChildItem c:\temp -File | Sort-Object Length  –Descending | Select-Object -Property Name, Length , LastAccessTime -First 5

Get-ChildItem c:\temp -Directory | Sort-Object Length  –Descending | Select-Object -Property Name, Length , LastAccessTime -First 5



cd C:\temp\

$textFile = $elementi | Where-Object {$_.Extension -eq '.txt' -and $_.Length -lt 2000} | Select-Object -First 20
$textFile = $elementi | Where-Object {$_.Name -like "*test*"}


ForEach ($file in $textFile) {Get-Content $textFile}

Get-Content $elementi[18]

$elementi= Get-ChildItem -filter "*114*"
ForEach ($file in $elementi) {Get-Content $file}


ForEach ($file in Get-ChildItem -filter "*114*") {Get-Content $file}

Get-ChildItem c:\temp | Select-Object -First 5 | Format-List *
Get-ChildItem c:\temp -File | Select-Object -First 5 | Format-Table Name, Length , LastAccessTime

    @("1/1/2017", "2/1/2017", "3/1/2017").ForEach([datetime])

    about_Splatting
about_Assignment_Operators
about_Operators
about_For
about_Foreach
about_While

about_Object_Creation    
[<class-name>]@{
      <property-name>=<property-value>
      <property-name>=<property-value>
    }


Noi abbiamo sognato il mondo. Lo abbiamo sognato resistente, misterioso, visibile, ubiquo nello spazio e fermo nel tempo; ma abbiamo ammesso nella sua architettura tenui ed eterni interstizi di assurdità, per sapere che è finto.

#endregion



#region -- REMOTING **************

#region Executing commands on remote systems
# Enable remote commands on local system
Enable-PSRemoting

# Execute a script on a remote system
$credential = New-Object System.Management.Automation.PSCredential ('Franco', (ConvertTo-SecureString "*****" -AsPlainText -Force))

Write-Host "We're currently working on $($env:COMPUTERNAME)"

$scriptBlock = {
    Write-Host "This code is executed on: $($env:COMPUTERNAME)"
}

Invoke-Command -ComputerName "fp01.northeurope.cloudapp.azure.com" `
    -Scriptblock $scriptBlock `
    -Credential $credential

# Open a persisten session on a remote system
$psSession = New-PSSession -ComputerName "demo-sql-1.contoso.local" `
                -Credential $credential

$scriptBlock1 = {
    $a = "Variable updated by ScriptBlock1"
}

Invoke-Command -Session $psSession -ScriptBlock $scriptBlock1

$scriptBlock2 = {
    Write-Host "Variable `$a contains: $a"
}

Invoke-Command -Session $psSession -ScriptBlock $scriptBlock2

$psSession | Remove-PSSession

# Open an interactive remote session
Enter-PSSession -ComputerName "demo-sql-1.contoso.local" `
    -Credential $credential

$env:COMPUTERNAME

Exit-PSSession

$env:COMPUTERNAME

#endregion
```