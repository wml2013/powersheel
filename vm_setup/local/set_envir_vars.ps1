$registry_path="Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment\"
#hash table containing new environment variables
$envir_vars = @{ 
    "AZURE_STORAGE_ACCESS_KEY" = "nuuda7FHdpjDH3zgLeT41Wu5MPlQwvk7m5maISYxiOI4yDmWqAqeM9JwPSS6IFpwvdm+zuCxj2vF8OgxjbTeXw==";
    "AZURE_STORAGE_ACCOUNT" = "sdmsstorage1";
    "GDAL_HTTP_UNSAFESSL" = "TRUE"
}
#array containing path variables
$path_vars = @(
    ";C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3",
    ";C:\Program Files\ArcGIS\Pro\bin\Python\Scripts",
    ";C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\Scripts"
)

#run powershell instance with elevated privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#create new environment variables
Write-Host ================= CREATING ENVIRONMENT VARIABLES =================
foreach($key in $envir_vars.Keys)
{
    Write-Host "Key:" $key "`nValue:" $envir_vars.Item($key) `n
    Set-ItemProperty -Path $registry_path -Name $key -Value ($envir_vars.Item($key))    
}


#add path environment variables
Write-Host ================= ADDING PATHS =================
$oldPath = (Get-ItemProperty -Path $registry_path -Name PATH).path
$newPath = $oldPath
foreach($path in $path_vars)
{
    if(!$oldPath.ToLower().Contains($path.Substring(1).ToLower())){
        $newPath+=$path
        Write-Host $path.Substring(1).ToLower()
    }
}

Set-ItemProperty -Path $registry_path -Name PATH –Value $newPath