#Powershell Scripts

Some Powershell scripts (mainly aimed against my Azure environment) --that should simplify things..

---------------------------------------------------------------

# BuildMyOwnVM.ps1

A script that builds a new VM from an uploaded VHD file. You cannot clone a machine from one subscription to another if you are using managed disks. This script works around this. 

# startAzureLogin.ps1

A script that one should use to login into to your account and to select the correct subscription.

# CreateLocalUser.ps1

A script that creates a local machine user.

# CreateSnapShotVM.ps1

A script that creates a snapshot from an Azure Managed Disk and to be used as basis of rebuilding a new VM.

# RebuildVM.ps1

A script that uses the snapshot of an OS disk created from 'CreateSnapShotVM.ps1' to rebuild the VM reusing the same NIC and NSG.

## Pre-requisites

**Install-Module AzureRM**
Because the AzureRM module is basically the root of a whole tree of dependencies, installing it can take a couple of minutes.
Once installed, use the following to log into Azure in an interactive fashion:

**Login-AzureRmAccount**
The AzureRM cmdlets only operate on the resources in the subscription that is currently marked as active. In case you have access to more than one subscription, make sure you select the correct one, for example by subscription name (see also here)

**Get-AzureRmSubscription -SubscriptionName "Visual Studio Enterprise" | Select-AzureRmSubscription**
Time to get the correct subscription.

# Uploading or referencing .vhd as a blob

The Blob file will be the source for the new VM. From your existing VM, go to the storage account, select the Blob storage, select VHDS and then locate the VHD file for the VM you want to clone. It will have a URL of the form: https://(blobstoragenane)/vhds/my_test_vm.vhd

Always remember to use the 'login-AzureRMAccount' to ensure that you are in the correct account. 
