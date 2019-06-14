$batPath= "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\map-z-dekstop.bat"

#run powershell instance with elevated privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#copy map-z.bat to startup folder and run
Write-Host ================= DEPLOYING STARTUP SCRIPT: map-z-dekstop.bat =================
if (Test-Path $batPath)
{
	Write-Host $batPath already exists	
    Remove-Item -Path $batPath
	Write-Host removed exisiting file
}
Move-Item -Path "C:\scripts\map-z-desktop.bat" -Destination $batPath
Write-Host map-z-desktop.bat moved into startup folder.