# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

<#
.SYNOPSIS
        
    Initializes disks attached to your EC2 instance. 

.DESCRIPTION
        

.PARAMETER Schedule
        
    Provide this parameter to register script as scheduledtask and trigger it at startup. If you want to run script immediately, run it without this parameter.
        
.EXAMPLE

    ./InitializeDisks.ps1 -Schedule
        
.EXAMPLE

    ./InitializeDisks.ps1 -EnableTrim
        
#>
param (
    # Scheduling the script as task initializes all disks at startup.
    # If this argument is not provided, script is executed immediately.
    [parameter(Mandatory=$false)]
    [switch] $Schedule = $false,

    [parameter(Mandatory=$false)]
    [switch] $EnableTrim
)

Set-Variable rootPath -Option Constant -Scope Local -Value (Join-Path $env:ProgramData -ChildPath "Amazon\EC2-Windows\Launch")
Set-Variable modulePath -Option Constant -Scope Local -Value (Join-Path $rootPath -ChildPath "Module\Ec2Launch.psd1")
Set-Variable scriptPath -Option Constant -Scope Local -Value (Join-Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
Set-Variable scheduleName -Option Constant -Scope Local -Value "Disk Initialization" 
Set-Variable shellHwRegPath -Option Constant -Scope Local -Value "HKLM:\SYSTEM\CurrentControlSet\services\ShellHWDetection"

# Import Ec2Launch module to prepare to use helper functions.
Import-Module $modulePath

# Before calling any function, initialize the log with filename
Initialize-Log -Filename "DiskInitialization.log"

if ($Schedule)
{
    # Scheduling script with no argument tells script to start normally.
    if ($EnableTrim)
    {
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName -Arguments "-EnableTrim"
    }
    else
    {
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
    }
    Write-Log "Disk initialization is scheduled successfully"
    Complete-Log
    Exit 0
}

try 
{    
    Write-Log "Initializing disks started"
    
    # Set TRIM using settings value from userdata.
    # By default, TRIM is disabled before formatting disk.
    $wasTrimEnabled = Set-Trim -Enable $EnableTrim
    
    # This count is used to label ephemeral disks.
    $ephemeralCount = 0
    
    $allSucceeded = $true

    # Retrieve and initialize each disk drive.
    foreach ($disk in (Get-CimInstance -ClassName Win32_DiskDrive)) 
    {
        Write-Log ("Found Disk Name:{0}; Index:{1}; SizeBytes:{2};" -f $disk.Name, $disk.Index, $disk.Size)
        
        # Disk must not be set to readonly.
        Set-Disk -Number $disk.Index -IsReadonly $False -ErrorAction SilentlyContinue | Out-Null

        # Check if a partition is available for the disk.
        # If no partition is found for the disk, we need to create a new partition.
        $partitioned = Get-Partition $disk.Index -ErrorAction SilentlyContinue
        if ($partitioned)
        {
            Write-Log ("Partition already exists: PartitionNumber {0}; DriverLetter {1}" -f $partitioned.PartitionNumber, $partitioned.DriveLetter)
            continue
        }

        # Find out if the disk is whether ephemeral or not.
        $isEphemeral = $false
        $isEphemeral = Test-EphemeralDisk -DiskIndex $disk.Index -DiskSCSITargetId $disk.SCSITargetId

        # Finally, set the disk and get drive letter for result.
        # If disk is ephemeral, label the disk.
        $driveLetter = Initialize-Ec2Disk -DiskIndex $disk.Index -EphemeralCount $ephemeralCount -IsEphemeral $isEphemeral

        # If disk is successfully loaded, driver letter should be assigned.
        if ($driveLetter)
        {
            # If it was ephemeral, increment the ephemeral count and create a warning file.
            if ($isEphemeral)
            {
                New-WarningFile -DriveLetter $driveLetter
                $ephemeralCount++
            }
        }
        else 
        {
            # If any disk failed to be initilaized, exitcode needs to be 1. 
            $allSucceeded = $false
        }
    }

    # Set drive letters based on drive letter mapping config.
    Set-DriveLetters

    if ($allSucceeded)
    {
        Write-Log "Initializing disks done successfully"
        Exit 0
    }
    else
    {
        Write-Log "Initializing disks done, but with at least one disk failure"
        Exit 1
    }
}
catch 
{
    Write-Log ("Failed to initialize drives: {0}" -f $_.Exception.Message)
    Exit 1
}
finally
{
    # If TRIM was originally enabled, make sure TRIM is set to be enabled.
    Set-Trim -Enable $wasTrimEnabled | Out-Null

    # Before finishing the script, complete the log.
    Complete-Log
}
