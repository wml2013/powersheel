Param(
    [string]$VMName,
    [string]$ResourceGroup
)

login-AzureRmAccount
# using parameters
Start-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroup

# skansa
Start-AzureRmVM -Name psepdev1w002 -ResourceGroupName psepdev1_rg
# skansa2
Start-AzureRmVM -Name psssdev1w001 -ResourceGroupName psssdev1_rg
# hosted arcgis server 1
Start-AzureRmVM -Name psssdev1w002 -ResourceGroupName psssdev1_rg
# hosted arcgis server 2
Start-AzureRmVM -Name psssdev1w003 -ResourceGroupName psssdev1_rg
# File server
Start-AzureRmVM -Name psssdev1w004 -ResourceGroupName psssdev1_rg
# Management server + desktop
Start-AzureRmVM -Name psssdev1w005 -ResourceGroupName psssdev1_rg