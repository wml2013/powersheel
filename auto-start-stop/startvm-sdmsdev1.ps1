# login first
# make sure you change the 'Subscription name to the correct one according to the environment you are in'
login-AzureRmAccount
(Get-AzureRmContext).Subscription
Get-AzureRmSubscription -SubscriptionName "OS Enterprise dev1" | Select-AzureRmSubscription

# File Server - seq 1
Start-AzureRmVM -Name sdmsdev1w011 -ResourceGroupName sdmsdev1_rg	

# web adaptor for Portal - seq 1
Start-AzureRmVM -Name sdmsdev1w004 -ResourceGroupName sdmsdev1_rg	
# sdmsdev1 Portal for ArcGIS - seq 2
Start-AzureRmVM -Name sdmsdev1w007 -ResourceGroupName sdmsdev1_rg	

# web adaptor for ArcGIS Server 1  - seq 2
Start-AzureRmVM -Name sdmsdev1w003 -ResourceGroupName sdmsdev1_rg	
# Arcgis server 1 - seq 3
Start-AzureRmVM -Name sdmsdev1w001 -ResourceGroupName sdmsdev1_rg	
# Arcgis server 2 - seq 4
Start-AzureRmVM -Name sdmsdev1w002 -ResourceGroupName sdmsdev1_rg	

# Data store - seq 5
Start-AzureRmVM -Name sdmsdev1w005 -ResourceGroupName sdmsdev1_rg	
#Start-AzureRmVM -Name sdmsdev1w006 -ResourceGroupName sdmsdev1_rg