# Get the VM 
$vm = Get-AzureRmVM -ResourceGroupName skanska -Name skanska

# Make sure the VM is stopped\deallocated
Stop-AzureRmVM -ResourceGroupName skanska -Name $vm.Name -Force

# Get the new disk that you want to swap in
$disk = Get-AzureRmDisk -ResourceGroupName skanska -Name skanska_osdisk

# Set the VM configuration to point to the new disk  
Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name 

# Update the VM with the new OS disk
Update-AzureRmVM -ResourceGroupName skanska -VM $vm 

# Start the VM
Start-AzureRmVM -Name $vm.Name -ResourceGroupName skanska