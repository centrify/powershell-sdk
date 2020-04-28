###############################################################################################################
# Import Secrets from CSV
#
# DISCLAIMER   : Sample script using the Centrify.IdentityServices.PowerShell Module to demonstrate how to add Secrets into Centrify Privilege Access Service (CPAS) and add them to Sets.
#
# Author       : Fabrice Viguier
# Contact      : fabrice.viguier AT centrify.com
# Release      : 1/11/2018
# Version      : Git repository https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
###############################################################################################################

param
(
	[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the CSV file to perform import actions.")]
	[Alias("f")]
	[System.String]$File
)

###########################
###     PREFERENCES     ###
###########################

# Debug preference
if ($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent)
{
	# Debug continue without waiting for confirmation
	$DebugPreference = "Continue"
}
else
{
	# Debug message are turned off
	$DebugPreference = "SilentlyContinue"
}

##########################################
###     CENTRIFY POWERSHELL MODULE     ###
##########################################

# Add PowerShell Module to session if not already loaded
[System.String]$ModuleName = "Centrify.IdentityServices.PowerShell"
# Load PowerShell Module if not already loaded
if (@(Get-Module | Where-Object {$_.Name -eq $ModuleName}).count -eq 0)
{
	Write-Verbose ("Loading {0} module..." -f $ModuleName)
	Import-Module $ModuleName
	if (@(Get-Module | Where-Object {$_.Name -eq $ModuleName}).count -ne 0)
    {
		Write-Verbose ("{0} module loaded." -f $ModuleName)
	}
	else
    {
		Throw "Unable to load PowerShell module."
	}
}

##########################
###     MAIN LOGIC     ###
##########################

# Connect to Centrify PAS instance
$Url = "cps.ocean.net"
$User = "fabrice@ocean.net"

if ($CisConnection -eq [Void]$Null)
{
    # Connect to Centrify Identity Services
    Connect-CisService -Url $Url -User $User
    if ($CisConnection -eq [Void]$Null)
    {
        Throw "Unable to establish connection."
    }
}

# Read CSV file
if (Test-Path -Path $File)
{
    # Load data
    $Data = Import-Csv -Path $File
    if ($Data -ne [Void]$null)
    {
        Write-Debug ("CSV file '{0}' loaded." -f $File)
        # Proceed list of secrets
        foreach ($Entry in $Data)
        {
            # Verify if SSH Key already exist
            $CisSshKey = Get-CisSshKey -Name $Entry.Name
            if ($CisSshKey -eq [Void]$null)
            {
                Write-Debug ("SSH Key '{0}' does not exists." -f $Entry.Name)
                # Add SSH key
                $CisSshKey = New-CisSshKey -Name $Entry.Name -PrivateKey $Entry.File
                Write-Debug ("SSH Key '{0}' has been added." -f $Entry.Name)
            }
            
            # Verify if System exist
            $CisSystem = Get-CisSystem -Name $Entry.System
            if ($CisSystem -eq [Void]$null)
            {
                Write-Debug ("System '{0}' does not exists." -f $Entry.System)
                Throw "Cannot add Accout to missing System."
            }

            try
            {
                # Create account adding the SSH Key for credentials
                $CisAccount = Add-CisAccount -CisSystem $CisSystem -User $Entry.User -CisSshKey $CisSshKey
                Write-Debug ("Account '{0}' has been created." -f $CisAccount.User)
            }
            catch
            {
                # Cannot verify account using Get-CisAccount as no difference exists between accounts using password and SSH keys
            }
            
            # Verify if AccountPermissions should be set
            if (-not [System.String]::IsNullOrEmpty($Entry.Permissions))
            {
                Write-Debug "Adding Account Permissions."
                # Each Permissions setting is separated by semi column
                $Entry.Permissions.Split(';') | ForEach-Object {
                    # Principal and Rights are separated by column
                    # e.g. ADGroup@domain.name:Grant,View,Edit,Delete
                    Set-CisPermissions -CisAccount $CisAccount -Principal $_.Split(':')[0] -Rights $_.Split(':')[1]
                    Write-Debug ("'{0}' has been granted '{1}' permissions on Account '{2}'." -f $_.Split(':')[0], $_.Split(':')[1], $CisAccount.User)
                }
            }
            
            # Verify is Account should be added to Sets
            if (-not [System.String]::IsNullOrEmpty($Entry.Sets))
            {
                Write-Debug "Adding Account to Set(s)."
                # Each Set name is comma separated
                $Entry.Sets.Split(',') | ForEach-Object {
                    # Get Account Set and add Account to it if exist
                    $AccountSet = Get-CisAccountCollection -Name $_
                    if ($AccountSet -ne [Void]$null)
                    {
                        # Add account to set
                        Add-CisCollectionMember -CisCollection $AccountSet -CisAccount $CisAccount
                        Write-Debug ("Account '{0}' has been added to Set '{1}'." -f $CisAccount.User, $AccountSet.Name)
                    }
                }
            }
        }
    }
    else
    {
        Throw "Unable to read CSV file."
    }
}
