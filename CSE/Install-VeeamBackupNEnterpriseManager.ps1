<#
 InstallBackupEnterpriseManager.ps1 should install veeams Backup and Enterprise Manager (= a web site)
 with the requirements - e.g. IIS, URL Rewrite module....
#>

#this will be our temp folder - need it for download / logging
$tmpDir = "c:\temp\" 

#create folder if it doesn't exist
if (!(Test-Path $tmpDir)) { mkdir $tmpDir -force}

Start-Transcript "$tmpDir\InstallBackupEnterpriseManager.log"

#install IIS features 
$features = @("Web-Server",
"Web-WebServer",
"Web-Common-Http",
"Web-Default-Doc",
"Web-Dir-Browsing",
"Web-Http-Errors",
"Web-Static-Content",
"Web-Http-Redirect",
"Web-Health",
"Web-Http-Logging",
"Web-Custom-Logging",
"Web-Log-Libraries",
"Web-Request-Monitor",
"Web-Http-Tracing",
"Web-Performance",
"Web-Stat-Compression",
"Web-Dyn-Compression",
"Web-Security",
"Web-Filtering",
"Web-Basic-Auth",
"Web-IP-Security",
"Web-Url-Auth",
"Web-Windows-Auth",
"Web-App-Dev",
"Web-Net-Ext45",
"Web-Asp-Net45",
"Web-ISAPI-Ext",
"Web-ISAPI-Filter",
"Web-Mgmt-Tools",
"Web-Mgmt-Console",
"Web-Scripting-Tools",
"NET-Framework-45-Features",
"NET-Framework-45-Core",
"NET-Framework-45-ASPNET",
"NET-WCF-Services45",
"NET-WCF-TCP-PortSharing45")
Install-WindowsFeature -Name $features -Verbose 

<# To Do: Manually (or Automatically see below) 

- download & Run  http://iis.net/webpi   (aka Web Platform installer)
- run "Microsoft Web Platform Installer" -> search for URL Rewrite 2.1 -> and install

- download and https://download2.veeam.com/VeeamBackup&Replication_9.5.0.1536.Update3.iso
- mount iso and run setup -> install Backup Enterprise Manager.

#>

#region To Do: Automatically
    #download and install URL Rewrite Module for IIS
    $URLRewrite2_1 = "http://download.microsoft.com/download/D/D/E/DDE57C26-C62C-4C59-A1BB-31D58B36ADA2/rewrite_amd64_en-US.msi"
    $URLRewrite2_1Path = $tmpDir + "\$(Split-Path $URLRewrite2_1 -Leaf)"
    if (!(Test-Path $URLRewrite2_1Path ))    #download if not there
    {
        $bitsJob = start-bitstransfer "$URLRewrite2_1" "$URLRewrite2_1Path" -Priority High -RetryInterval 60 -Verbose -TransferType Download #wait until downloaded.
    }

    #unattended install
    start-process -filepath msiexec -ArgumentList "/i ""$URLRewrite2_1Path"" /l*v ""$URLRewrite2_1Path.log""  /passive ACCEPTEULA=""YES""" -Wait


    #download and install veeam Backup and EnterpriseMgr.
    $veeamBnR95 = "https://download2.veeam.com/VeeamBackup&Replication_9.5.0.1536.Update3.iso"
    $veeamBnR95Path = $tmpDir + "\$(Split-Path $veeamBnR95 -Leaf)"
    if (!(Test-Path $veeamBnR95Path ))     #download if not there
    {
        start-bitstransfer "$veeamBnR95" "$veeamBnR95Path" -Priority High -RetryInterval 60 -Verbose -TransferType Download #wait until downloaded.
    }
    
    #mount iso as drive - and remember the driveletter.
    $mountResult = Mount-DiskImage -ImagePath $veeamBnR95Path -StorageType ISO -Access ReadOnly -Verbose -PassThru
    $mountResult | Get-Volume
    $driveLetter = ($mountResult | Get-Volume).DriveLetter

    #this is the path to the package to install    
    $BnEntMgrEXE = "$($driveLetter):\EnterpriseManager\BackupWeb_x64.msi"
    
    #install Backup and Enterprise Manager unattended
    start-process -filepath msiexec -ArgumentList "/i ""$BnEntMgrEXE"" /l*v ""$($tmpDir + "\$(Split-Path $BnEntMgrEXE -Leaf).log")""  /q ACCEPTEULA=""YES""" -Wait

    Dismount-DiskImage -ImagePath $veeamBnR95Path
#endregion

Stop-Transcript    