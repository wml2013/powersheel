param (
    [Parameter(Mandatory=$true)]
    [String[]] $items
)

#run powershell instance with elevated privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

foreach($item in $items)
{
    if (Test-Path $item)
    {
	    Write-Host $item already exists.	
        Remove-Item -Path $item -Recurse
	    Write-Host $item removed.
    }
    New-Item -ItemType directory -Path $item
    Write-Host Created New Item: $item
}