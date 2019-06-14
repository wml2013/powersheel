# login first
# make sure you change the 'Subscription name to the correct one according to the environment you are in'
login-AzureRmAccount
(Get-AzureRmContext).Subscription
Get-AzureRmSubscription -SubscriptionName "OS Enterprise dev1" | Select-AzureRmSubscription

# Web Adaptors - seq 1
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w003" -Force  -AsJob
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w004" -Force  -AsJob

Start-Sleep 60

# ArcGIS Servers - seq 2
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w001" -Force  -AsJob
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w002" -Force  -AsJob

#ArcGIS Data Stores - seq 3
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w005" -Force  -AsJob
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w006" -Force  -AsJob

# Portal - seq 4
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w007" -Force  -AsJob

# Management Desktops - seq 5
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w009" -Force  -AsJob
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w012" -Force  -AsJob

Get-Job | Wait-Job

# Stop the system disk boxes - seq 5
Stop-AzureRmVM -ResourceGroupName "sdmsdev1_rg" -Name "sdmsdev1w008" -Force  -AsJob