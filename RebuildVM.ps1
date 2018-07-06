# Delete the VMs
for ($i = 1; $i -lt 5; $i++) {
    Remove-AzureRmVm -ResourceGroupName escpdev4_rg -Name escpdev4w00$i -Force
}

# Delete the disks
for ($i = 1; $i -lt 5; $i++) {
    Remove-AzureRmDisk -ResourceGroupName escpdev4_rg -DiskName escpdev4w00$($i)_osdisk -Force
}

# Create new disks from the snapshots
for ($i = 1; $i -lt 5; $i++) {
    $snapshot = Get-AzureRmSnapshot -ResourceGroupName escpdev4_rg -SnapshotName escpdev4w00$($i)_osdisk-26Jun2018-snap
    $config = New-AzureRmDiskConfig -AccountType "Premium_LRS" -Location "North Europe" -CreateOption Copy -SourceResourceId $snapshot.Id
    New-AzureRmDisk -Disk $config -ResourceGroupName escpdev4_rg -DiskName escpdev4w00$($i)_osdisk
}

# Create the VMs and attach the disks and NICs
for ($i = 1; $i -lt 5; $i++) {
    # Get the original NIC 
    $nic = Get-AzureRmNetworkInterface -Name escpdev4w00$($i)_nic1 -ResourceGroupName escpdev4_rg 

    # Get the New OS disk 
    $osDisk = Get-AzureRmDisk -Name escpdev4w00$($i)_osdisk -ResourceGroupName escpdev4_rg 

    # Create a new VM using the original NIC and new disk 
    $vmConfig = New-AzureRmVMConfig -VMName escpdev4w00$i -VMSize "Standard_DS3_V2" 
    $vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id 
    $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -DiskSizeInGB 128 -CreateOption Attach -Windows 
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable
    New-AzureRmVM -ResourceGroupName escpdev4_rg -Location "North Europe" -VM $vm 
}