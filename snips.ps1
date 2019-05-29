#Removing a resource group using it's name
Remove-AzureRmResourceGroup -Name cathtest -Confirm

#Removing a resource group using it's name but running as a job (so you get your prompt back asap)
Remove-AzureRmResourceGroup -Name cm-test -AsJob -Confirm

#Removing a resource group using it's name but running as a job and forced (quicker)
Remove-AzureRmResourceGroup -Name gspptest -AsJob -Force

#Get Job Status
Get-Job