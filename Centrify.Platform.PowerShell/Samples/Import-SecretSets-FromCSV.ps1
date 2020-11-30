###############################################################################################################
# Import Secret's Sets from CSV
#
# DISCLAIMER   : Sample script using the Centrify.PrivilegedAccessService.PowerShell Module to demonstrate how to add Sets of Secrets into Centrify Privilege Access Service (CPAS) and configure permissions. 
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

# Connect to Centrify PAS instance
$Url = "cps.ocean.net"
$User = "fabrice@ocean.net"

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
        # Proceed list of sets
        foreach ($Entry in $Data)
        {
            # Verify if Set already exist
            $PASSecretCollection = Get-PASSecretCollection -Name $Entry.Name
            if ($PASSecretCollection -eq [Void]$null)
            {
                Write-Debug ("Secret Collection '{0}' does not exists." -f $Entry.Name)
                # Create set
                $PASSecretCollection = New-PASCollection -Name $Entry.Name -Description $Entry.Description -CollectionType Manual -ObjectType Secrets
                Write-Debug ("Secret Collection '{0}' has been created." -f $PASSecretCollection.Name)
            }
            
            # Verify if Set Permissions should be set
            if (-not [System.String]::IsNullOrEmpty($Entry.Permissions))
            {
                Write-Debug "Adding Set Permissions."
                # Each Permissions setting is separated by semi column
                $Entry.Permissions.Split(';') | ForEach-Object {
                    # Principal and Rights are separated by column
                    # e.g. ADGroup@domain.name:Grant,View,Edit,Delete
                    Set-PASPermissions -PASCollection $PASSecretCollection -Principal $_.Split(':')[0] -Rights $_.Split(':')[1]
                    Write-Debug ("'{0}' has been granted '{1}' permissions on Set '{2}'." -f $_.Split(':')[0], $_.Split(':')[1], $PASSecretCollection.Name)
                }
            }
            
            # Verify if Member Permissions should be set
            if (-not [System.String]::IsNullOrEmpty($Entry.MemberPermissions))
            {
                Write-Debug "Adding Member Permissions."
                # Each Permissions setting is separated by semi column
                $Entry.MemberPermissions.Split(';') | ForEach-Object {
                    # Principal and Rights are separated by column
                    # e.g. ADGroup@domain.name:Grant,View,Edit,Delete
                    Set-PASPermissions -PASCollectionMembers $PASSecretCollection -Principal $_.Split(':')[0] -Rights $_.Split(':')[1]
                    Write-Debug ("'{0}' has been granted '{1}' permissions on Members of Set '{2}'." -f $_.Split(':')[0], $_.Split(':')[1], $PASSecretCollection.Name)
                }
            }
            
        }
    }
    else
    {
        Throw "Unable to read CSV file."
    }
}
