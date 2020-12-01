###########################################################################################
# Centrify Platform PowerShell module - Centrify.Platform.PowerShell Module Installer
# 
#
# Author   : Fabrice Viguier
# Contact  : support AT centrify.com
# Release  : 21/01/2016
# Copyright: (c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################


function Install-PSModule
{
    param ([System.String]$Path)

    # Install Module by copying Module folder to destination folder
    try
    {
	    # Deduct source location from script invocation path
        $Source = ("{0}\Centrify.Platform.PowerShell" -f (Split-Path -Parent $PSCommandPath))
        
        # Copy source to module location
        $FileCopied = Copy-Item -Path $Source -Destination $Path -Recurse -Force -PassThru -ErrorAction "SilentlyContinue"
        if ($FileCopied.Count -gt 0)
        {
	        Write-Host
	        Write-Host ("{0} files copied." -f $FileCopied.Count)
	        Write-Host
        }
        else
        {
            Write-Error ("No files copied.")
        }

        # Unblock files to avoid preventing importing the module
        Get-ChildItem -Path $Path -Recurse | Unblock-File
    }
    catch
    {
		# Unhandled Exception
		Throw $_.Exception
    }
}

function Remove-PSModule
{
    param ([System.String]$Path)

    # Delete Module
    Remove-Item -Path $Path -Recurse -Force
}

function Test-AdminRight
{
	# Get current user identity and principal
    $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($Identity)
	
	# Validate that current user is a Local Administrator
	if (-not $WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
	{
        Write-Warning ("Installation must be run with Local Administrator privileges. User {0} does not have enough privileges." -f $Identity)
        Exit
	}
}

function Get-PSModulePath
{
    # Get PSModulePath from Environment
    $PSModulePath = ([System.Environment]::GetEnvironmentVariable("PSModulePath")) -Split ';' | Where-Object { $_ -match "\\Centrify\\PowerShell\\" }
    if ([System.String]::IsNullOrEmpty($PSModulePath))
    {
	    Write-Host "No Centrify Platform PowerShell Module detected on this system."
	    if (-not (Test-Path -Path "C:\Program Files\Centrify\"))
	    {
		    # Create full path
		    mkdir "C:\Program Files\Centrify"
		    mkdir "C:\Program Files\Centrify\PowerShell"
	    }
	    else
	    {
		    # Create PowerShell folder
		    if (-not (Test-Path -Path "C:\Program Files\Centrify\PowerShell"))
		    {
			    mkdir "C:\Program Files\Centrify\PowerShell"
		    }
	    }
	    $PSModulePath = "C:\Program Files\Centrify\PowerShell\"
        # Set PSModulePath into Machine Environment
        [System.Environment]::SetEnvironmentVariable("PSModulePath", ("{0};{1}" -f [System.Environment]::GetEnvironmentVariable("PSModulePath"), $PSModulePath), "Machine")
        Write-Warning "PSModulePath environmnet variable has been updated. Operating System may need to be rebooted for change to be taken into account."  
    }
    else
    {
	    Write-Host ("Centrify Platform PowerShell module detected on this system under '{0}'" -f $PSModulePath)
    }
    # Return Path
    return $PSModulePath
}

##############
# Main Logic #
##############

# Validate Local Admin privileges
Test-AdminRight

# Starting installation
Write-Host
Write-Host "################################################################"
Write-Host "# Centrify.Platform.PowerShell Module Installer #"
Write-Host "################################################################"
Write-Host

$PSModulePath = Get-PSModulePath
$InstallationPath = ("{0}Centrify.Platform.PowerShell" -f $PSModulePath)

Write-Host ("Centrify Platform PowerShell module will be using Installation path:`n`t'{0}'" -f $InstallationPath)

if (Test-Path -Path $InstallationPath)
{
	# Build Menu
	$Title = "The Centrify Platform PowerShell module is already installed."
	$Message = ("Choose action to perform:`n")
	$Message += ("[R] - Repair/Upgrade Module by deleting and re-installing all files.`n")
	$Message += ("[U] - Uninstall and exit.`n")
	$Message += ("[C] - Cancel and exit.`n")
	$Choice0 = New-Object System.Management.Automation.Host.ChoiceDescription "&Repair", "Repair Module"
	$Choice1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Uninstall", "Uninstall and exit"
	$Choice2 = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancel and exit"
	$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Choice0, $Choice1, $Choice2)
	# Prompt for choice
	$Prompt = $Host.UI.PromptForChoice($Title, $Message, $Options, 2)
	switch ($Prompt)
	{
		0 # Repare
		{
			Write-Host "Repairing/Upgrading Module."
            # Remove Module
            Remove-PSModule -Path $InstallationPath
            Write-Host ("Centrify Platform PowerShell module '{0}' deleted" -f $InstallationPath)
            # Installing Module
            Install-PSModule -Path $InstallationPath
            Write-Host ("Centrify Platform PowerShell module installed under '{0}'" -f $PSModulePath)
		}
		1 # Uninstall
		{
			Write-Host "Uninstalling Module."
            # Remove Module
            Remove-PSModule -Path $InstallationPath
            Write-Host ("Centrify Platform PowerShell module '{0}' deleted" -f $InstallationPath)
            Exit
		}
		2 # Exit
		{
			Write-Host "Operation canceled.`n"
			Exit
		}
	}
}
else
{
	Write-Host "Installing module."
	# Installing Module
    Install-PSModule -Path $InstallationPath
    Write-Host ("Centrify Platform PowerShell module installed under '{0}'" -f $PSModulePath)
}
# Done.