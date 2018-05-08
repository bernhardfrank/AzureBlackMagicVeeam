<#

    Using Powershell to write Random Data to Storage => $numOfOutputFiles X $totalOutputFileSizeInBytes
    Notes:
     1 GB onto SSD with moderate CPU will take approx 40sec 
     7Zip will give 0% compression ratio, i.e. output is as large as original file.
#>

$totalOutputFileSizeInBytes = 10MB       
$numOfOutputFiles = 100
$outputPath = "c:\temp\random.data"

Write-Host -ForegroundColor Green "Writing $numOfOutputFiles * $($totalOutputFileSizeInBytes/1MB) (MB) = $(($numOfOutputFiles*$totalOutputFileSizeInBytes)/1GB) (GB)"

for ($i = 1; $i -le $numOfOutputFiles; $i++)
{ 
    #create an area of random data.
    $data = New-Object 'byte[]' $totalOutputFileSizeInBytes
    $rnd =  [System.Random]::new()
    $rnd.NextBytes($data)
    
    #create Path if not exists
    $parentPath = Split-Path $outputPath -Parent
    if (!(Test-Path -Path $parentPath ))
    {
        mkdir $parentPath
    }
    
    #write out random data
    (split-path $outputPath -Leaf) -match "(.*)\.(.*)"   #append $i to filename e.g. "random.1.data"
    $path = (split-path $outputPath) + "\" + $Matches[1] + ".$i." + $Matches[2] 
    [System.IO.File]::WriteAllBytes($path,$data)
}
