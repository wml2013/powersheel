if (Test-Path "C:\jdk-installer\*.exe")
{
	Write-Host jdk-installer.exe already exists
	Remove-Item -Path "C:\jdk-installer\*.exe"
	Write-Host removed exisiting installer
}

Write-Host Unzipping JDK
Expand-Archive "C:\jdk-installer\*.zip" -DestinationPath "C:\jdk-installer"

Write-Host Removing Zip file
Remove-Item -Path "C:\jdk-installer\*.zip"

Write-Host Installing JDK
Start-Process -Wait -FilePath "C:\jdk-installer\jdk*" -ArgumentList "/s /L c:\jdk-installer\install.log" -PassThru