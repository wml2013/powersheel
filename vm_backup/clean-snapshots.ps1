# script to limit snapshots by ($numOfSnaps variable) per vm by deleting oldest ones based on date tags
# requires two variables: systemName & environmentName 
# e.g. sdms dev1 

$numOfSnapshots = 2
$rg = $env:systemName + $env:environmentName + "_rg"

# get all vms in the resource group
$vms = (Get-AzureRmResource -ResourceGroupName $rg -ResourceType Microsoft.Compute/virtualmachines).Name

#get all snapshots already in the resource group to check against later
$rgSnapshots = Get-AzureRmResource -ResourceGroupName $rg -ResourceType Microsoft.Compute/snapshots

foreach ($vm in $vms)
{
    Write-Host `n$vm

    #find all snapshots associated with vm, put them in list
    $vmSnapshots = @()
    foreach ($snapshot in $rgSnapshots)
    {
        if ($snapshot.Name -like $vm + "*")
        {            
            $vmSnapshots += $snapshot#.Tags.creationtime          
        }
    }

    Write-Host FOUND $vmSnapshots.Length snapshots:
    $vmSnapshots.Name

    # find and delete oldest snapshots
    if ($vmSnapshots.length -gt $numOfSnapshots)
    {
        #find oldest snapshots by ordering list by date tag
        $sortedDates = $vmSnapshots | Sort-Object {[System.DateTime]::ParseExact($_.Tags.creationtime, "dd/MM/yyyy-HH:mm:ss", $null)}
        $numToDelete = $sortedDates.length-$numOfSnapshots        
        $snapsToDelete = $sortedDates | select -First $numToDelete

        Write-Host `nDELETING oldest $numToDelete":"
        $snapsToDelete.Name
        Write-Host
        foreach ($delSnap in $snapsToDelete)
        {
            Write-Host DELETING snapshot: $delSnap.Name
            Remove-AzureRmResource -ResourceGroupName $rg -ResourceName $delSnap.Name -ResourceType Microsoft.Compute/snapshots -Force            
        }
    }
}