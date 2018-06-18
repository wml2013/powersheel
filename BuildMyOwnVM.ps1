# let's get started
Connect-AzureAsAccount
Get-AzureRmSubscription -SubscriptionName "Visual Studio Professional 2" | Select-AzureRmSubscription

# Deining some parameters
$resourceGroupName = "skanska2"
$virtualNetworkName = "skanska2"
$locationName = "westeurope"
$destinationVhd = "https://skanska2.blob.core.windows.net/vhds/skanska20180214151044.vhd"
# End of parameters

$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName
$publicIp = New-AzureRmPublicIpAddress -Name "skanska2" -ResourceGroupName $ResourceGroupName -Location $locationName`
        -AllocationMethod Dynamic
$networkInterface = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName `
     -Name "skanska222" -Location $locationName -SubnetId $virtualNetwork.Subnets[0].Id`
     -PublicIpAddressId $publicIp.Id
Get-AzureRmVMSize $locationName | Out-GridView
$vmConfig = New-AzureRmVMConfig -VMName "skanska2" -VMSize "Standard_DS1_v2"
#Set-AzureRMVMPlan -VM $vmConfig -Publisher 'esri' -Product 'arcgis-enterprise-106' -Name 'arcgis-enterprise-106'
Set-AzureRMVMPlan -VM $vmConfig -Publisher 'esri' -Product 'arcgis-enterprise-106' -Name 'byol-106'
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "skanska2" -VhdUri $destinationVhd `
                                -CreateOption Attach -Windows
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id

# Add the components together to make your VM
$vm = New-AzureRmVM -VM $vmConfig -Location $locationName -ResourceGroupName $resourceGroupName