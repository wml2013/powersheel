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
        
    Initializes EC2 instance by configuring all required settings.

.DESCRIPTION
        
    During EC2 instance launch, it configures all required settings and displays information to console.

    0. Wait for sysprep: to ensure that sysprep process is finished.
    1. Add routes: to connect to instance metadata service and KMS service.
    2. Wait for metadata: to ensure that metadata is available to retrieve.
    3. Rename computer: to rename computer based on instance ip address.
    4. Display instance info: to inform user about your instance/AMI.
    5. Extend boot volume: to extend boot volume with unallocated spaces.
    6. Set password: to set password, so you can get password from console
    7. Windows is Ready: to display "Message: Windows is Ready to use" to console.
    8. Execute userdata: to execute userdata retrieved from metadata
    9. Register disabled scheduledTask: to keep the script as scheduledTask for future use.

    * By default, it always checks serial port setup.
    * If any task requires reboot, it re-regsiters the script as scheduledTask.
    * Userdata is executed after windows is ready because it is not required by default and can be a long running process.

.PARAMETER Schedule
        
    Provide this parameter to register script as scheduledtask and trigger it at startup. If you want to run script immediately, run it without this parameter.
        
.EXAMPLE

    ./InitializeInstance.ps1 -Schedule

#>

# Required for powershell to determine what parameter set to use when running with zero args (us a non existent set name)
[CmdletBinding(DefaultParameterSetName = 'Default')]
param (
    # Schedules the script to run on the next boot.
    # If this argument is not provided, script is executed immediately.
    [parameter(Mandatory = $false, ParameterSetName = "Schedule")]
    [switch] $Schedule = $false,
    # Schedules the script to run at every boot.
    # If this argument is not provided, script is executed immediately.
    [parameter(Mandatory = $false, ParameterSetName = "SchedulePerBoot")]
    [switch] $SchedulePerBoot = $false,
    # After the script executes, keeps the schedule instead of disabling it.
    [parameter(Mandatory = $false, ParameterSetName = "KeepSchedule")]
    [switch] $KeepSchedule = $false
)

Set-Variable rootPath -Option Constant -Scope Local -Value (Join-Path $env:ProgramData -ChildPath "Amazon\EC2-Windows\Launch")
Set-Variable modulePath -Option Constant -Scope Local -Value (Join-Path $rootPath -ChildPath "Module\Ec2Launch.psd1")
Set-Variable scriptPath -Option Constant -Scope Local -Value (Join-Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)
Set-Variable scheduleName -Option Constant -Scope Local -Value "Instance Initialization"

Set-Variable amazonSSMagent -Option Constant -Scope Local -Value "AmazonSSMAgent"
Set-Variable ssmAgentTimeoutSeconds -Option Constant -Scope Local -Value 25
Set-Variable ssmAgentSleepSeconds -Option Constant -Scope Local -Value 5

# Import Ec2Launch module to prepare to use helper functions.
Import-Module $modulePath

# Before calling any function, initialize the log with filename and also allow LogToConsole. 
Initialize-Log -Filename "Ec2Launch.log" -AllowLogToConsole

if ($Schedule -or $SchedulePerBoot) {
    $arguments = $null
    if ($SchedulePerBoot) {
        # If a user wants to run on every reboot, the next invocation of InitializeInstance should not disable it's schedule
        $arguments = "-KeepSchedule"

        # Disable and user data schedule so that user data doesn't run twice on the next run (once in launch, another time in the external schedule)
        Invoke-Userdata -OnlyUnregister
    }

    # Scheduling script with no argument tells script to start normally.
    Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName -Arguments $arguments

    # Set AmazonSSMAgent StartupType to be Disabled to prevent AmazonSSMAgent from running util windows is ready.
    Set-Service $amazonSSMagent -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Log "Instance initialization is scheduled successfully"
    Complete-Log
    Exit 0
}

try {
    Write-Log "Initializing instance is started"

    # Serial Port must be available in your instance to send logs to console. 
    # If serial port is not available, it sets the serial port and requests reboot. 
    # If serial port is already available, it continues without reboot.
    if ((Test-NanoServer) -and (Set-SerialPort)) {
        # Now Computer can restart.
        Write-Log "Message: Windows is restarting..." 
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
        Restart-Computer
        Exit 0
    }

    # Serial port COM1 must be opened before executing any task.
    Open-SerialPort

    # Task must be executed after sysprep is complete.
    # WMI object seems to be missing during sysprep.
    Wait-Sysprep

    # Routes need to be added to connect to instance metadata service and KMS service.
    Add-Routes 
            
    # Once routes are added, we need to wait for metadata to be available 
    # becuase there are several tasks that need information from metadata.
    Wait-Metadata

    # Set KMS server and port in registry key.
    Set-ActivationSettings

    # Create wallpaper setup cmd file in windows startup directory, which
    # renders instance information on wallpaper as user logs in.
    New-WallpaperSetup

    # Installs EGPU for customers that request it
    Install-EgpuManager
    
    # Before renaming computer, it checks if computer is already renamed.
    # If computer is not renamed yet, it renames computer and requests reboot.
    # If computer is already renamed or failed to be renamed, it continues without reboot. 
    if (Set-ComputerName) {
        # Now Computer can restart.
        Write-Log "Message: Windows is restarting..." -LogToConsole
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
        Close-SerialPort
        Restart-Computer
        Exit 0
    }

    # All of the instance information is displayed to console.
    Send-AMIInfo
    Send-OSInfo
    Send-IDInfo
    Send-InstanceInfo
    Send-MsSqlInfo
    Send-DriverInfo
    Send-Ec2LaunchVersion 
    Send-VSSVersion
    Send-SSMAgentVersion
    Send-RDPCertInfo
    Send-FeatureStatus
            
    # Add DNS suffixes in search list and store that in registry key. 
    Add-DnsSuffixList

    # The volume size is extended with unallocated spaces.
    Set-BootVolumeSize

    # Configure ENA Network settings 
    if (Set-ENAConfig) {
        # Now Computer can restart.
        Write-Log "Message: Windows is restarting..." -LogToConsole
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName
        Close-SerialPort
        Restart-Computer
        Exit 0
    }

    # If requested, sets the monitor to never turn off which will interfere with acpi signals
    Set-MonitorAlwaysOn
    # If requested, tells windows to go in to hibernate instead of sleep
    # when the system sends the acpi sleep signal.
    Set-HibernateOnSleep
        
    # Password is randomly generated and provided to console in encrypted format.
    # Here, also admin account gets enabled.
    $creds = Set-AdminAccount

    # Encrypt the admin credentials and send it to console.
    # Console understands the admin password and allows users to decrypt it with private key.
    if ($creds.Username -and $creds.Password) {
        Send-AdminCredentials -Username $creds.Username -Password $creds.Password
    }

    try {
        # Set AmazonSSMAgent StartupType to be back to Automatic
        Set-Service $amazonSSMagent -StartupType Automatic -ErrorAction Stop
    }
    catch {
        Write-Log ("Failed to set AmazonSSMAgent service to Automatic {0}" -f $_.Exception.Message)
    }

    # Windows-is-ready message is displayed to console after all steps above are complete.
    Send-WindowsIsReady

    # Disable the scheduledTask if we were only suppose to run once, otherwise, leave the schedule.
    if (!$KeepSchedule) {
        Register-ScriptScheduler -ScriptPath $scriptPath -ScheduleName $scheduleName -Disabled
    }
    
    # Serial port COM1 must be closed before ending.
    Close-SerialPort

    # If this run is from a "run on every boot" schedule, make sure we only execute user data (dont
    # schedule it as a separate task), this is so we can instead execute it inline on every boot.

    # Userdata can be executed now if user provided one before launching instance. Because 
    # userdata is not required by default and can be a long running process, it is not a 
    # part of windows-is-ready condition and executed after Send-WindowsIsReady.
    $persistUserData = Invoke-Userdata -Username $creds.Username -Password $creds.Password -OnlyExecute:$KeepSchedule
    
    try {
        # Start AmazonSSMAgent service.
        # Have to use closure argument list because the closure will be running in a sub-job that wont have access to local variables
        Invoke-WithTimeout -ScriptName $amazonSSMagent -ScriptBlock { Start-Service -Name $args[0] -ErrorAction Stop } -ArgumentList $amazonSSMagent -SleepSeconds $ssmAgentSleepSeconds -TimeoutSeconds $ssmAgentTimeoutSeconds
    }
    catch {
        Write-Log ("Failed to start AmazonSSMAgent service: {0}" -f $_.Exception.Message)
    }

    # If this run is from a "run on every boot" schedule, disable certain functionality for future runs.
    if ($KeepSchedule) {
        Get-LaunchConfig -Key AdminPasswordType -Delete
        Get-LaunchConfig -Key SetMonitorAlwaysOn -Delete

        # Only disable handle user data if persist was false
        if (!$persistUserData) {
            Get-LaunchConfig -Key HandleUserData -Delete
        }
    }

    Write-Log "Initializing instance is done"
    Exit 0
}
catch {
    Write-Log ("Failed to continue initializing the instance: {0}" -f $_.Exception.Message)

    # Serial port COM1 must be closed before ending.
    Close-SerialPort
    Exit 1
}
finally {
    # Before finishing the script, complete the log.
    Complete-Log
    
    # Clear the credentials from memory.
    if ($creds) {
        $creds.Clear()
    }
}
