$rg = $env:systemName + $env:environmentName + "_rg"
$tagName = "sequencestart"
$t = (Get-Date).Hour

# do nothing if times are same
if ($env:stopBeforeHour -ne $env:stopAfterHour)
{
	# variable conditions to stop machines
	if ($t -le $env:stopBeforeHour -Or $t -ge $env:stopAfterHour)
	{
		$tagName = "sequencestop"
	}

	# start/stop each vm in order dependant on sequence tag number
	for ($i=1; $i -lt 6; $i++){
		$vms = Find-AzureRmResource -TagName $tagName -TagValue $i
		foreach ($vm in $vms){
			if ($vm.Name -eq ($env:excludeVm))
			{
				continue
			}
			elseIf($vm.Name.Contains($env:systemName + $env:environmentName))
			{
				# get resource group full name of the vm
				$rg = $vm.ResourceGroupName

				if ($tagName -eq "sequencestart")
				{
					Write-Host "Powering ON:" $vm.Name
					Start-AzureRmVM -ResourceGroupName $rg -Name $vm.Name
				}
				else 
				{
					Write-Host "Powering OFF:" $vm.Name
					Stop-AzureRmVM -ResourceGroupName $rg -Name $vm.Name -Force
				}
			}
		}		
	}
}