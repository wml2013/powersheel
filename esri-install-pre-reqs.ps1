param(   
    [Parameter(Mandatory = $True)]
    [string]
    $keyvaultName    
)
 
$ErrorActionPreference = "Stop"
 
# install esri DSC module if not already installed  
$arcGisModule = "C:\Program Files\WindowsPowerShell\Modules\ArcGIS"
if (!(Test-Path $arcGisModule)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name ArcGIS -SkipPublisherCheck -Force  
}
 
 
# if the zip installer library that some ESRI DSC scripts are looking for is downloaded then install it
$zipInstaller = "C:\DSC_Resources\7z938-x64.msi"
if (Test-Path $zipInstaller) {
    Write-verbose "found zip installer: $zipInstaller. installing..." -Verbose
    Invoke-Expression "msiexec /i $zipInstaller /quiet"
    Write-verbose "zip installer installed" -Verbose
}
 
# get Keyvault access token
$response = Invoke-WebRequest -UseBasicParsing -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata = "true"}
$content = $response.Content | ConvertFrom-Json 
Write-verbose $content -Verbose
$KeyVaultToken = $content.access_token 
$keyvaultName = "$keyvaultName.vault.azure.net"
 
# get Portal Licence from Keyvault
$secretName = "$($env:COMPUTERNAME.toString().ToUpper())-ArcGISPortalLicence"
 
try {
    $json = (Invoke-WebRequest -UseBasicParsing -Uri https://$keyvaultName/secrets/$secretName"?api-version=2016-10-01" -Method GET -Headers @{Authorization = "Bearer $KeyVaultToken"}).content | ConvertFrom-Json
    Write-verbose $json -Verbose
    $outFile = 'C:\DSC_Resources\ArcGISPortalLicence.prvc'
    $json.value | out-file $outFile -Encoding utf8
    Write-verbose "secret written to file: $outFile" -Verbose
}
catch {
    Write-verbose "No secret: $secretName found in keyvault $keyvaultName" -Verbose
}
 
 
# get Server Licence from Keyvault
$secretName = "$($env:COMPUTERNAME.toString().ToUpper())-ArcGISServerLicence"
 
try {
    $json = (Invoke-WebRequest -UseBasicParsing -Uri https://$keyvaultName/secrets/$secretName"?api-version=2016-10-01" -Method GET -Headers @{Authorization = "Bearer $KeyVaultToken"}).content | ConvertFrom-Json
    Write-verbose $json -Verbose
    $outFile = 'C:\DSC_Resources\ArcGISServerLicence.prvc'
    $json.value | out-file $outFile -Encoding utf8
    Write-verbose "secret written to file: $outFile" -Verbose
}
catch {
    Write-verbose "No secret: $secretName found in keyvault $keyvaultName" -Verbose
}
 
 
# install Server licence if it exists
$licenseFilePath = "C:\DSC_Resources\ArcGISServerLicence.prvc"
if (Test-Path $licenseFilePath) {
    $Product = "Server"
    $Arguments = " -s -ver 10.6"  
    $SoftwareAuthExePath = "$env:SystemDrive\Program Files\Common Files\ArcGIS\bin\SoftwareAuthorization.exe"
    Write-Verbose "Licensing Product [$Product] using Software Authorization Utility at $SoftwareAuthExePath" -Verbose
    $Params = " $Arguments -lif $licenseFilePath"
    Write-Verbose "[Running Command] $SoftwareAuthExePath $Params" -Verbose
    Start-Process -FilePath $SoftwareAuthExePath -ArgumentList $Params
}
 
# install Portal licence if it exists
$licenseFilePath = "C:\DSC_Resources\ArcGISPortalLicence.prvc"
if (Test-Path $licenseFilePath) {
    $Product = "Portal"
    $Arguments = " -s -ver 10.6"  
    $SoftwareAuthExePath = "$env:SystemDrive\Program Files\Common Files\ArcGIS\bin\SoftwareAuthorization.exe"
    Write-Verbose "Licensing Product [$Product] using Software Authorization Utility at $SoftwareAuthExePath" -Verbose
    $Params = " $Arguments -lif $licenseFilePath"
    Write-Verbose "[Running Command] $SoftwareAuthExePath $Params" -Verbose
    Start-Process -FilePath $SoftwareAuthExePath -ArgumentList $Params
}

