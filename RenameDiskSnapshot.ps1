$snapshot = Get-AzureRmSnapshot -ResourceGroupName 'skanska' -SnapshotName 'skanska_2ab8ba5579ef430cb2db10f732bb1ba3-19Jul2018-snap';
$snapshot.Name = 'skanska_osdisk-19Jul2018-snap';
Update-AzureRmSnapshot -ResourceGroupName 'skanska' -Snapshotname 'skanska_osdisk-19Jul2018-snap' -Snapshot $snapshot -location "West Europe";