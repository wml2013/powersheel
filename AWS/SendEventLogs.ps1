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
       
    Sends windows event logs to console output based on congifuration in EventLogConfig.json.

.DESCRIPTION

    Event logs can be used to troubleshoot your instance and the script replies on EventLogConfig.json.
    If you execute this script, your instance must restart to show event logs in console output. 
    The script can be scheduled to be executed on every startup. If the script is scheduled, the event logs
    appear in console output three minutes after your instance restarts.

.PARAMETER Schedule
        
    Provide this parameter to register script as scheduledtask and trigger it at startup. If you want to run 
    script immediately, run it without this parameter.
        
.EXAMPLE

    ./SendEventLogs.ps1 -Schedule

#>
param (
    # Scheduling the script as task collect and sends event logs to console at startup.
    # If this argument is not provided, script is executed immediately.
    [parameter(Mandatory=$false)]
    [switch] $Schedule = $false
)

Set-Variable rootPath -Option Constant -Scope Local -Value (Join-Path $env:ProgramData -ChildPath "Amazon\EC2-Windows\Launch")
Set-Variable modulePath -Option Constant -Scope Local -Value (Join-Path $rootPath -ChildPath "Module\Ec2Launch.psd1")
Set-Variable scriptPath -Option Constant -Scope Local -Value (Join-Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
Set-Variable scheduleName -Option Constant -Scope Local -Value "Event logs to Console" 

# Import Ec2Launch module to prepare to use helper functions.
Import-Module $modulePath

# Before calling any function, initialize the log with filename
Initialize-Log -Filename "EventlogsToConsole.log" -AllowLogToConsole

if ($Schedule)
{
    # Scheduling script with no argument tells script to start normally.
    Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
    Write-Log "Sending eventlogs to console is scheduled successfully"
    Complete-Log
    Exit 0
}

try
{
    Write-Log "Sending event logs to console started"

    $outputs = @()
    $eventLogConfigs = Get-EventLogConfig
    if (-not $eventLogConfigs)
    {
        throw New-Object System.Exception("Could not find the event log config or it is empty")
    }

    foreach ($eventLogConfig in $eventLogConfigs)
    {
        $filter = @{}
    
        if ($eventLogConfig.LogName)
        { 
            $filter += @{ LogName = $eventLogConfig.LogName; }
        } 
    
        if ($eventLogConfig.Source)
        {
            $filter += @{ ProviderName = $eventLogConfig.Source; }
        }

        if ($eventLogConfig.Level)
        {
            $filter += @{ Level = $eventLogConfig.Level; }
        }
    
        # Get event logs based on configuration above.
        try
        {
            $results = Get-WinEvent -FilterHashtable $filter -MaxEvents $eventLogConfig.NumEntries -ErrorAction SilentlyContinue
        }
        catch
        {
            continue
        }

        foreach ($result in $results)
        {
            $timeCreated = "{0:M/dd/yyyy hh:mm:ss tt}" -f $result.TimeCreated
            $outputs += "EventLogEntry: {0}  {1}  {2}  {3}  {4}" -f $result.LogName, $result.LevelDisplayName, 
                                                                    $result.ProviderName, $timeCreated, $result.Message
        }
    }
    
    # Serial port COM1 must be opened before sending eventlogs to console.
    Open-SerialPort
    
    # Finally, send the outputs to console.
    for ($i=$outputs.Length-1; $i -ge 0; $i--)
    {
        Write-Log $outputs[$i] -LogToConsole
    }

    Write-Log "Sending event logs to console done"
    Exit 0
}
catch
{
    Write-Log ("Failed to continue collect and send eventlogs: {0}" -f $_.Exception.Message)
    Exit 1
}    
finally
{
    # Serial port COM1 must be closed before ending.
    Close-SerialPort

    # Before finishing the script, complete the log.
    Complete-Log
}

