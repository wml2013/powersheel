# Delete the VMs
    Remove-AzureRmVm -ResourceGroupName builder -Name builder -Force


# Delete the disks
    Remove-AzureRmDisk -ResourceGroupName builder -DiskName builder_OsDisk_1_1a999ed63e00439abf557711a7c06b83 -Force


# Create new disks from the snapshots
    $snapshot = Get-AzureRmSnapshot -ResourceGroupName builder -SnapshotName builder_osdisk-29Oct2018
    $config = New-AzureRmDiskConfig -AccountType "standardLRS" -Location "West Europe" -CreateOption Copy -SourceResourceId $snapshot.Id
    New-AzureRmDisk -Disk $config -ResourceGroupName builder -DiskName builder_osdisk

# Create the VMs and attach the disks and NICs
    # Get the original NIC 
    $nic = Get-AzureRmNetworkInterface -Name builder277 -ResourceGroupName builder 

    # Get the New OS disk 
    $osDisk = Get-AzureRmDisk -Name builder_osdisk -ResourceGroupName builder 

    # Create a new VM using the original NIC and new disk 
    $vmConfig = New-AzureRmVMConfig -VMName builderi -VMSize "Standard_DS3_V2" 
    $vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id 
    $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -DiskSizeInGB 128 -CreateOption Attach -Windows 
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable
    New-AzureRmVM -ResourceGroupName builder -Location "West Europe" -VM $vm 