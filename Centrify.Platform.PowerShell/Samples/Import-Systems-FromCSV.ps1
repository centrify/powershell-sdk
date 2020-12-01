###############################################################################################################
# Import Systems from CSV
#
# DISCLAIMER   : Sample script using the Centrify.PrivilegedAccessService.PowerShell Module to demonstrate how to add Systems into Centrify Privilege Access Service (CPAS), add them to Sets and configure permissions. 
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
[System.String]$ModuleName = "Centrify.PrivilegedAccessService.PowerShell"
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

# Connect to Centrify PAS instance using Oauth
$Url = "tenant.my.centrify.net" # your tenant url
$Client = "OAuthClient"         # the OAuth2 Client application ID to use
$Scope = "All"                  # the scope to use for the Oauth token
$Secret = ""                    # the Base64 string used for the Basic Authentication, can be obtained using: Connect-PASPlatform -EncodeSecret

if ($PASConnection -eq [Void]$Null)
{
    # Connect to Centrify Identity Services
    Connect-PASPlatform -Url $Url -Client $Client -Scope $Scope -Secret $Secret
    if ($PASConnection -eq [Void]$Null)
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
        # Proceed list of systems
        foreach ($Entry in $Data)
        {
            # Verify if System already exist
            $PASSystem = Get-PASSystem -Name $Entry.Name
            if ($PASSystem -eq [Void]$null)
            {
                Write-Debug ("System '{0}' does not exists." -f $Entry.Name)
                # Set boolean values
                $ProxyUserIsManaged = $false
                if ($Entry.ProxyUserIsManaged -eq "True")
                {
                    $ProxyUserIsManaged = $true
                }
            
                # Create system
                $PASSystem = New-PASSystem -Name $Entry.Name -Fqdn $Entry.Fqdn -ComputerClass $Entry.ComputerClass -Description $Entry.Description -ProxyUser $Entry.ProxyUser -ProxyUserPassword $Entry.ProxyUserPassword -ProxyUserIsManaged $ProxyUserIsManaged
                Write-Debug ("System '{0}' has been created." -f $PASSystem.Name)
            }
            
            # Verify if SystemPermissions should be set
            if (-not [System.String]::IsNullOrEmpty($Entry.Permissions))
            {
                Write-Debug "Adding System Permissions."
                # Each Permissions setting is separated by semi column
                $Entry.Permissions.Split(';') | ForEach-Object {
                    # Principal and Rights are separated by column
                    # e.g. ADGroup@domain.name:Grant,View,Edit,Delete
                    Set-PASPermissions -PASSystem $PASSystem -Principal $_.Split(':')[0] -Rights $_.Split(':')[1]
                    Write-Debug ("'{0}' has been granted '{1}' permissions on System '{2}'." -f $_.Split(':')[0], $_.Split(':')[1], $PASSystem.Name)
                }
            }
            
            # Verify is System should be added to Sets
            if (-not [System.String]::IsNullOrEmpty($Entry.Sets))
            {
                Write-Debug "Adding System to Set(s)."
                # Each Set name is comma separated
                $Entry.Sets.Split(',') | ForEach-Object {
                    # Get System Set and add System to it if exist
                    $SystemSet = Get-PASSystemCollection -Name $_
                    if ($SystemSet -ne [Void]$null)
                    {
                        # Add system to set
                        Add-PASCollectionMember -PASCollection $SystemSet -PASSystem $PASSystem
                        Write-Debug ("System '{0}' has been added to Set '{1}'." -f $PASSystem.Name, $SystemSet.Name)
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
