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
        
    Sends Windows-Is-Ready message to console output.

.DESCRIPTION
 
    Windows-Is-Ready message is detected by ICD in droplet and also many customers/teams rely on thie message 
    to perform their task after this message appears in console. The script can be scheduled to be executed on every startup.        

.PARAMETER Schedule
        
    Provide this parameter to register script as scheduledtask and trigger it at startup. If you want to run script immediately, run it without this parameter.
        
.EXAMPLE

    ./SendWindowsIsReady.ps1 -Schedule

#>
param (
    # Scheduling the script as task sends Windows is ready message to console at startup.
    # If this argument is not provided, script is executed immediately.
    [parameter(Mandatory=$false)]
    [switch] $Schedule = $false
)

Set-Variable rootPath -Option Constant -Scope Local -Value (Join-Path $env:ProgramData -ChildPath "Amazon\EC2-Windows\Launch")
Set-Variable modulePath -Option Constant -Scope Local -Value (Join-Path $rootPath -ChildPath "Module\Ec2Launch.psd1")
Set-Variable scriptPath -Option Constant -Scope Local -Value (Join-Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
Set-Variable scheduleName -Option Constant -Scope Local -Value "Windows is Ready to Console" 

# Import Ec2Launch module to prepare to use helper functions.
Import-Module $modulePath

# Before calling any function, initialize the log with filename
Initialize-Log -Filename "WindowsIsReadyToConsole.log" -AllowLogToConsole

if ($Schedule)
{
    # Scheduling script with no argument tells script to start normally.
    Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
    Write-Log "Sending `"Windows is Ready`" message to console is scheduled successfully"
    Complete-Log
    Exit
}

try
{
    Write-Log "Sending windows is ready message started"

    # Serial port COM1 must be opened before sending any message to console.
    Open-SerialPort
    
    # Send the message to console.
    Send-WindowsIsReady

    Write-Log "Sending windows is ready message done"
}
catch
{
    Write-Log ("Failed to send windows-is-ready message to console: {0}" -f $_.Exception.Message)
}
finally
{
    # Serial port COM1 must be closed before ending.
    Close-SerialPort

    # Before finishing the script, complete the log.
    Complete-Log
}

