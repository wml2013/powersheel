# login first
# make sure you change the 'Subscription name to the correct one according to the environment you are in'
login-AzureRmAccount
(Get-AzureRmContext).Subscription
Get-AzureRmSubscription -SubscriptionName "OS Enterprise DEV1" | Select-AzureRmSubscription

# Delete the VMs
for ($i = 1; $i -lt 5; $i++) {
    Remove-AzureRmVm -ResourceGroupName sdmsdev1_rg -Name sdmsdev1w00$i -Force
}


# Delete the disks
for ($i = 1; $i -lt 5; $i++) {
    Remove-AzureRmDisk -ResourceGroupName sdmsdev1_rg -DiskName sdmsdev1w00$($i)_osdisk -Force
}


# Create new disks from the snapshots
for ($i = 1; $i -lt 5; $i++) {
    $snapshot = Get-AzureRmSnapshot -ResourceGroupName sdmsdev1_rg -SnapshotName sdmsdev1w00$($i)_osdisk-19Feb2018-snap
    $config = New-AzureRmDiskConfig -AccountType "PremiumLRS" -Location "North Europe" -CreateOption Copy -SourceResourceId $snapshot.Id
    New-AzureRmDisk -Disk $config -ResourceGroupName sdmsdev1_rg -DiskName sdmsdev1w00$($i)_osdisk
}


# Create the VMs and attach the disks and NICs
for ($i = 1; $i -lt 5; $i++) {
    # Get the original NIC 
    $nic = Get-AzureRmNetworkInterface -Name sdmsdev1w00$($i)_nic1 -ResourceGroupName sdmsdev1_rg 

    # Get the New OS disk 
    $osDisk = Get-AzureRmDisk -Name sdmsdev1w00$($i)_osdisk -ResourceGroupName sdmsdev1_rg 

    # Create a new VM using the original NIC and new disk 
    $vmConfig = New-AzureRmVMConfig -VMName sdmsdev1w00$i -VMSize "Standard_DS3_V2" 
    $vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id 
    $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -DiskSizeInGB 128 -CreateOption Attach -Windows 
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable
    New-AzureRmVM -ResourceGroupName sdmsdev1_rg -Location "North Europe" -VM $vm 
}

