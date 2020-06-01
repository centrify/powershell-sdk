###############################################################################################################
# Import Secrets from CSV
#
# DISCLAIMER   : Sample script using the Centrify.PrivilegedAccessService.PowerShell Module to demonstrate how to add Secrets into Centrify Privilege Access Service (CPAS) and add them to Sets.
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
        # Proceed list of secrets
        foreach ($Entry in $Data)
        {
            # Verify if Secret already exist
            $PASSecret = Get-PASSecret -Name $Entry.Name
            if ($PASSecret -eq [Void]$null)
            {
                Write-Debug ("Secret '{0}' does not exists." -f $Entry.Name)
                # Create secret
                if ([System.String]::IsNullOrEmpty($Entry.Text)) {
                    # Import File secret
                    $PASSecret = New-PASSecret -Name $Entry.Name -Description $Entry.Description -File $Entry.File -Password $Entry.Password
                    Write-Debug ("File Secret '{0}' has been created." -f $Entry.Name)
                }
                else {
                    # Import Text secret
                    $PASSecret = New-PASSecret -Name $Entry.Name -Description $Entry.Description -Text $Entry.Text
                    Write-Debug ("Text Secret '{0}' has been created." -f $Entry.Name)
                }
            }
            
            # Verify if Secret Permissions should be set
            if (-not [System.String]::IsNullOrEmpty($Entry.Permissions))
            {
                Write-Debug "Adding Secret Permissions."
                # Each Permissions setting is separated by semi column
                $Entry.Permissions.Split(';') | ForEach-Object {
                    # Principal and Rights are separated by column
                    # e.g. ADGroup@domain.name:Grant,View,Edit,Delete
                    Set-PASPermissions -PASSecret $PASSecret -Principal $_.Split(':')[0] -Rights $_.Split(':')[1]
                    Write-Debug ("'{0}' has been granted '{1}' permissions on Secret '{2}'." -f $_.Split(':')[0], $_.Split(':')[1], $PASSecret.Name)
                }
            }
            
            # Verify is Secret should be added to Sets
            if (-not [System.String]::IsNullOrEmpty($Entry.Sets))
            {
                Write-Debug "Adding System to Set(s)."
                # Each Set name is comma separated
                $Entry.Sets.Split(',') | ForEach-Object {
                    # Get System Set and add System to it if exist
                    $SecretSet = Get-PASSecretCollection -Name $_
                    if ($SecretSet -ne [Void]$null)
                    {
                        # Add system to set
                        Add-PASCollectionMember -PASCollection $SecretSet -PASSecret $PASSecret
                        Write-Debug ("Secret '{0}' has been added to Set '{1}'." -f $PASSecret.Name, $SecretSet.Name)
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
