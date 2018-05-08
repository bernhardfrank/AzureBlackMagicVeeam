<#

    This sample is about using PowerShell to query Azure's RateCard API via REST to get the actual prices
    for resources in Azure (incl. Azure Stack)
    for your subscription that would be priced for a specific offer type.

    #requires to setup an Azure App first.
#>

$ApiVersion = '2016-08-31-preview'
$Currency = 'EUR'
$Locale = 'en-DE'            #de-DE would give your german translations (e.g. "Europa" instead of EU North )which you might not want 
$RegionInfo = 'DE'

#https://azure.microsoft.com/en-us/support/legal/offer-details/
#$OfferDurableId = 'MS-AZR-0121p' #Azure Pass
$OfferDurableId = 'MS-AZR-0003P'  #Pay as you go
#$OfferDurableId = 'MS-AZR-0063P' #Visual Studio Ultimate bei MSDN
#$OfferDurableId = 'ms-azr-0145p' #CSP



#How to get the offer ID? --> log on to: https://account.azure.com/Subscriptions/
#Offer ID "MS-AZR-0015P"
#MS-AZR-0063P   - "Visual Studio Ultimate bei MSDN"

# for a list of offer IDs see https://azure.microsoft.com/en-us/support/legal/offer-details/
#'ms-azr-0145p'     # Azure in CSP
# 0120P-0130P       # Azure Pass
# Pay-As-You-Go 0003P  
# Support Plans 0041P, 0042P, 0043P  
# Free Trial 0044P  
# Visual Studio Professional subscribers 0059P  
# Visual Studio Test Professional subscribers 0060P  
# MSDN Platforms subscribers 0062P  
# Visual Studio Enterprise subscribers 0063P  
# Visual Studio Enterprise (BizSpark) subscribers 0064P  
# Visual Studio Enterprise (MPN) subscribers 0029P  
# Pay-As-You-Go Dev/Test 0023P  
# Enterprise Dev/Test 0148P 



Login-AzureRmAccount
$subscription = Get-AzureRmSubscription

$WebApplicationId = "*******************"
$clientSecret = "******************"

$Body = @{
            'resource' = 'https://management.core.windows.net/'
            'grant_type' = 'client_credentials'
            'client_id' = $WebApplicationId
            'client_secret' = $clientSecret
            }

$params = @{
            ContentType = 'application/x-www-form-urlencoded'
            Headers = @{'accept'='application/json'}
            Body = $Body
            URI = "https://login.microsoftonline.com/$($Subscription.TenantId)/oauth2/token?api-version=1.0"
            Method = 'Post'
}


$Token = Invoke-RestMethod @params

$ResourceCard = "https://management.azure.com/subscriptions/{5}/providers/Microsoft.Commerce/RateCard?api-version={0}&`$filter=OfferDurableId eq '{1}' and Currency eq '{2}' and Locale eq '{3}' and RegionInfo eq '{4}'" -f $ApiVersion, $OfferDurableId, $Currency, $Locale, $RegionInfo, $($Subscription.Id)
$authHeader = @{"Authorization" = "BEARER " + $Token.access_token} 
$r = Invoke-WebRequest -Uri "$ResourceCard" -Method GET -Headers $authHeader 

$mcontent = ($r.Content -split '[rn]')
$mContent = ($mResponse.Content -split '[rn]')

#output as RAW
$File = "C:\temp\ratecardresult_$OfferDurableId.txt"
$r.Content | Out-File $File

$Resources = Get-Content -Raw -Path $File -Encoding UTF8 | ConvertFrom-Json

<#Beispiel Query VM-Typen aus Europe und deren Kosten.
...
VM Standard_D3_v2                                      Europa, Westen @{0=0,2293776}        
VM Standard_D3_v2                                      Europa, Norden @{0=0,2226312}        
VM Standard_D3_v2 (Windows)                            Europa, Westen @{0=0,4528521}        
VM Standard_D3_v2 (Windows)                            Europa, Norden @{0=0,4115304}        
VM Standard_D3_v2 Promo                                Europa, Norden @{0=0,1872126}        
VM Standard_D3_v2 Promo                                Europa, Westen @{0=0,202392}         
VM Standard_D3_v2 Promo (Windows)                      Europa, Norden @{0=0,3423798}        
VM Standard_D3_v2 Promo (Windows)                      Europa, Westen @{0=0,3575592}     
...
#>

#Query Azure VM prices for your subscription 
$Resources.Meters.Where({$_.MeterRegion -like "EU North" -and $_.MeterCategory -eq "Virtual Machines"}) | ft MeterId,MeterCategory,MeterName,MeterRates,MeterStatus,Unit,MeterRegion

#Export all to CSV
$NorthEurope | Export-Csv -Path "C:\temp\RateCardAPI-StorageNEuorpe.csv" -UseCulture -NoTypeInformation