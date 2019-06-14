# script to create snapshot of all vm disks in a given resource group
# requires two variables: systemName & environmentName 
# e.g. sdms dev1 

$rg = $env:systemName + $env:environmentName + "_rg"

# get all vms in the resource group
$vms = Get-AzureRmResource -ResourceGroupName $rg -ResourceType Microsoft.Compute/virtualmachines

#get all snapshots already in the resource group to check against later
$snapshotList = (Get-AzureRmResource -ResourceGroupName $rg -ResourceType "Microsoft.Compute/snapshots").Name

foreach ($vm in $vms)
{
    #prepare snapshot variables
    $diskName = $vm.Name + "_osdisk"
    $disk = Get-AzureRmResource -ResourceGroupName $rg -Name $diskName -ResourceType Microsoft.Compute/disks
    $snapshot = New-AzureRmSnapshotConfig -SourceUri $disk.ResourceId -CreateOption Copy -Location 'northeurope' 
    $snapshotName = "$($disk.Name )-$(Get-Date -Format ddMMMyyyy)-1-snap"

    #check if snapshot already exists
    $i=1
    while (($snapshotList | Where-Object {$snapshotName -eq $_}) -And $i -lt 9) 
    {
        Write-Host $snapshotName already exists.
        $i++
        $snapshotName = $snapshotName.Substring(0, $snapshotName.Length-6) + $i + "-snap"        
    }

    #create new snapshot
    Write-Host CREATING NEW SNAPSHOT: $snapshotName
    New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $rg
	
	#add Date-Time tag to snapshot
	$tags = (Get-AzureRmResource | Where-Object ResourceGroupName -eq $rg | Where-Object ResourceName -eq $snapshotName).Tags
	$tags += @{creationtime=$(Get-Date -Format dd/MM/yyyy-HH:mm:ss)}
	Set-AzureRmResource -ResourceGroupName $rg -Name $snapshotName -ResourceType "Microsoft.Compute/snapshots" -Tag $tags -Force
}