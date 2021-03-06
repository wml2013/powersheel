Param(
    [string]$ResourceGroup,
    [string]$DiskName
)

# Creates a snapshot of an Azure VM disk
# Snapshot is created in the same RG as the disk
# Snapshot name is in format "diskname-ddMMMyyyy-snap", e.g. "psssdev1w002_osdisk-05Apr2018-snap"
#
#Power the VM down before taking the snapshot, then run the script like this:
#
# .\CreateSnapshotVM.ps1 -ResourceGroup <RGname> -DiskName <vmname>_osdisk
# E.g.
# .\CreateSnapshotVM -ResourceGroup skanska -DiskName skanska_2ahhhjyys8tuulderk

$ErrorActionPreference = "Stop"

$disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName

$snapshot = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location 'westeurope'

$snapshotName = "$($disk.Name )-$(Get-Date -Format ddMMMyyyy)-snap"

New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $ResourceGroup

