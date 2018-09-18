Login-AzureRmAccount
(Get-AzureRmAccount).subscription
Get-AzureRmSubscription -SubscriptionName "Visual Studio Professional" | Select-AzureRmSubscription
# Sub 2
# Get-AzureRmSubscription -SubscriptionName "Visual Studio Professional 2" | Select-AzureRmSubscription

# Now run the script and pass the arguments over..
.\CreateSnapshotVM -ResourceGroup "skanska" -Diskname "skanska_osdisk"
# Skanska2
#.\CreateSnapshotVM -ResourceGroup "skanska2" -Diskname "skanska2_osdisk"