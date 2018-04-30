<# 
    This Custom Script Extension downloads the Adventure Works Sample DB 

#>

#this will be our temp folder - need it for download / logging
$tmpDir = "c:\temp\" 

#create folder if it doesn't exist
if (!(Test-Path $tmpDir)) { mkdir $tmpDir -force}

Start-Transcript "$tmpDir\Download-AdventureWorks2016.log"

$AdventureWorks2016 = "https://download.microsoft.com/download/F/6/4/F6444AC3-ACF7-4024-BD31-3CACA2DA62DC/AdventureWorks2016CTP3.bak" #"https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2016.bak"
$AdventureWorks2016Path = $tmpDir + "\$(Split-Path $AdventureWorks2016 -Leaf)"


if (!(Test-Path $AdventureWorks2016Path )) 
{
    start-bitstransfer "$AdventureWorks2016" "$AdventureWorks2016Path" -Priority High -RetryInterval 60 -Verbose -TransferType Download
}

Write-Output "Please restore DB: $AdventureWorks2016Path using SQL Server Management Studio."

Stop-Transcript



