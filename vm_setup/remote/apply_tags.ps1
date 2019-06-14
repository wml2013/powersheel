$rg = $env:systemName + $env:environmentName + "_rg"
$vmId = "w0"

#check if subnets are present for rg and vm name variable
if($env:subnetZone -ne "na")
{
    $rg = $rg + "_" + $env:subnetZone
    switch ( $env:subnetZone )
    {
        front
        {
            $vmId = "wf"
        }
        mid
        {
            $vmId = "wm"
        }
        back
        {
            $vmId = "wb"
        }
        mang
        {
            $vmId = "wg"
        }
    }
}

#amend vmId if variable only contains a single digit
if(($env:svrCountInit.ToString().length) -lt 2)
{
  $vmId = $vmId + "0"
}

$vmName = $env:systemName + $env:environmentName  + $vmId + $env:svrCountInit
$tagList = @{sequencestart=$env:sequenceStart; sequencestop=$env:sequenceStop}

Write-Host vmName: $vmName

$tags = (Get-AzureRmResource | Where-Object ResourceGroupName -eq $rg | Where-Object ResourceName -eq $vmName).Tags

foreach ($tag in $tagList.Keys)
{
    if ($tags.ContainsKey($tag))
    {
        $tags.Remove($tag)
    }
}

$tags += $tagList #@{sequencestart=$env:sequenceStart; sequencestop=$env:sequenceStop}

Set-AzureRmResource -ResourceGroupName $rg -Name $vmName -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -Force

Write-Host Updated Tags:
(Get-AzureRmResource | Where-Object ResourceGroupName -eq $rg | Where-Object ResourceName -eq $vmName).Tags