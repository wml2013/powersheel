# run this script as .\sdmsDEV1_diskSnapShot.ps1 in powershell
# login first
# make sure you change the 'Subscription name to the correct one according to the environment you are in'
login-AzureRmAccount
(Get-AzureRmContext).Subscription
Get-AzureRmSubscription -SubscriptionName "OS Enterprise DEV1" | Select-AzureRmSubscription

# sdmsDEV1 Environment
# Subscription name: OS Enterprise DEV
# Batch file that creates Azure VM Disk Snapshots for the sdmsDEV1 environment.

.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w001_osdisk 
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w002_osdisk 
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w003_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w004_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w005_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w006_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w007_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w008_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w009_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w010_osdisk
.\Create-Snapshot -ResourceGroup sdmsdev1_rg -DiskName sdmsdev1w011_osdisk