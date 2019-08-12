#Connecto the my Azure Portal
Connect-AzAccount

#Saves my Azure portal login
Save-AzContext -Path 'C:\Users\mlee\OneDrive - ESRI (UK) Ltd\MyDocs\powershell\az-sub.json'

#Setting to Visual Studio Professional Sub
# Get-AzSubscription -SubscriptionId "255f7704-e82d-45f5-b056-103070046180" -TenantId "78325161-206f-4750-bbca-2c754bb89c4c" | Set-AzContext

#Setting to Visual Studio Professionaal 2
Get-AzSubscription -SubscriptionId "9eae8f1b-47c6-4f5f-9122-8458d4cb45e8" -TenantId "78325161-206f-4750-bbca-2c754bb89c4c" | Set-AzContext