$snapshot = Get-AzureRmSnapshot -ResourceGroupName skanska -SnapshotName skanska_2ab8ba5579ef430cb2db10f732bb1ba3-06Sep2018-snap
$config = New-AzureRmDiskConfig -AccountType "standard" -Location "West Europe" -CreateOption Copy -SourceResourceId $snapshot.Id
New-AzureRmDisk -Disk $config -ResourceGroupName skanska -DiskName skanska_osdisk