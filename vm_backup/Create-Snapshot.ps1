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
# .\Create-Snapshot -ResourceGroup <RGname> -DiskName <vmname>_osdisk
# E.g.
# .\Create-Snapshot -ResourceGroup psjptst1_rg_mid -DiskName psjptst1wm01_osdisk


$ErrorActionPreference = "Stop"

$disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName

$snapshot = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location 'northeurope'

$snapshotName = "$($disk.Name )-$(Get-Date -Format ddMMMyyyy)-snap"

New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $ResourceGroup
