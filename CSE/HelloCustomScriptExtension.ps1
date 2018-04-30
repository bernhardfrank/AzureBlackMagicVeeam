<# 
    This Custom Script Extension just writes the date in a file....

#>

#this will be our temp folder - need it for download / logging
$tmpDir = "c:\temp\" 

#create folder if it doesn't exist
if (!(Test-Path $tmpDir)) { mkdir $tmpDir -force}

"I was run at: {0}" -f (Get-Date)  | Out-File -FilePath $($tmpDir+"\HelloCustomScriptExtension.log") -Append

