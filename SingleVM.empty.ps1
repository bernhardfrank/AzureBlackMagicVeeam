<#The Mission:

    Create a PowerShell Script that should deploy a single VM just like 
    https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/virtual-machines-windows/single-vm

    - create at minimum 2 Subnets within the VNET
    - Use variables 
    - Use Powershell help .... -examples 
    - Copy 'n Paste with pride!

     have fun!
#>


#region Variables
$RG = "BlackMagic"
$Location = ""
$VNETName = ""
$NSGName = ""
$AVSetName = ""
$VMName = ""
$PublicIPAddressName = ""
$NICName = ""
$OSDiskCaching = ""
$DataDiskCaching = ""
$VMLocalAdminUser = ""
$OSDiskName = ""
$DataDiskName = ""
$VMLocalAdminSecurePassword = ConvertTo-SecureString "SehrSehrK0mplexesPWD!" -AsPlainText -Force 
#endregion

#Login to Azure
#Create a Resource Group
#Create Subnet
#Create VNET
#Create NSG
#Create PublicIP
#Create NIC
#Create VM (Azure ARM VM Config) [Size,additional Data Disk (ReadCache on Data Disk)...]
#Create Availabilityset
#Attach NIC
#Get VMSize   (Get-AzureRmVMSize)

#Create VM using an image....
#PublisherName: "MicrosoftSQLServer" Offer: "SQL2017-WS2016"
#hint: help Set-AzureRmVMSourceImage -Examples

#Create a Credential
#$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)

#Config OSDisk (Name, Caching, fromImage?, Size?)
#create and attach DataDisk (Premiumstorage - empty - attach)
#then create the New VM
#Add Custom Script Extension


#Clean up :-)