################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet adds an Account to the vault. 

.DESCRIPTION
This Cmdlet adds an Account to either a specified CisResource, CisDomain, or CisDatabase. 
The Account must exists in the target system, domain or database as the credentials will be validated after creation.

.PARAMETER User
Mandatory Username of the account to add.

.PARAMETER CisResource
Mandatory CisResource where to add account to. 

.PARAMETER CisDomain
Mandatory CisDomain where to add account to.

.PARAMETER CisDatabase
Mandatory CisDatabase where to add the account to. 

.PARAMETER Password
Optional Password for the account (note if this paramete is ommited and no CisSshKey provided, the account password will be blank).

.PARAMETER CisSshKey
Optional CisSshKey to use as credential for system account (this parameter is only effective if the account is added to a system of type "Unix").

.PARAMETER Description
Optional Description for this account.

.PARAMETER isManaged
Optional  isManaged to specify whether account password should be managed or not (false by default).

.INPUTS
One of [CisResource], [CisDomain] or [CisDatabase]

.OUTPUTS
[CisAccount]

.EXAMPLE
C:\PS> Add-CisAccount -User "svc-bcrab" -CisResource (Get-CisSystem "WIN-BLUECRAB01") -Password "!L1keSeaF00d"
Add the local account 'svc-bcrab' to system named 'WIN-BLUECRAB01' using the CisRessource parameter.

.EXAMPLE
C:\PS> CisDatabase (Get-CisDatabase "castledb") | Add-CisAccount -User "oracastle" -Password "J!IRU()U" -IsManaged $true
Add the account 'oracastle' to database named 'castledb' and immediately managed the paccount password using input object from pipeline.
#> 
function global:Add-CisAccount
{
	[CmdletBinding(DefaultParameterSetName = "CisSystem")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisSystem")]
		[System.Object]$CisSystem,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisDomain")]
		[System.Object]$CisDomain,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisDatabase")]
		[System.Object]$CisDatabase,

		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = "CisSystem")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[System.String]$User,
		
		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "CisSystem")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[System.String]$Password,

		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "CisSystem")]
		[System.Object]$CisSshKey,
		
		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "CisSystem")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[System.String]$Description,

		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "CisSystem")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[System.Boolean]$IsManaged = $false
)
	
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
	
	# Get current connection to the Centrify Cloud Platform
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Get the CisSystem ID
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/AddAccount" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.User 		= $User
		$JsonQuery.IsManaged	= $IsManaged
		$JsonQuery.Description	= $Description

        if (-not [System.String]::IsNullOrEmpty($CisSshKey))
        {
            # Adding SSH Key as credential
    		$JsonQuery.CredentialType = "SshKey"
    		$JsonQuery.SshKeyId       = $CisSshKey.ID
    		$JsonQuery.SshKeyName     = $CisSshKey.Name
        }
        else
        {
            # Adding password as credential
    		$JsonQuery.Password = $Password
        }

		# Adding target information
		if (-not [System.String]::IsNullOrEmpty($CisSystem))
		{
			if ([System.String]::IsNullOrEmpty($CisSystem.ID))
			{
				Throw "Cannot get ResourceID from given parameter."
			}
			else
			{
				# Add Local Account to CisSystem
				$JsonQuery.Host = $CisSystem.ID
			}
		}

		if (-not [System.String]::IsNullOrEmpty($CisDomain))
		{
			if ([System.String]::IsNullOrEmpty($CisDomain.ID))
			{
				Throw "Cannot get DomainID from given parameter."
			}
			else
			{
				# Add Account to CisDomain
				$JsonQuery.DomainID = $CisDomain.ID
			}
		}

		if (-not [System.String]::IsNullOrEmpty($CisDatabase))
		{
			if ([System.String]::IsNullOrEmpty($CisDatabase.ID))
			{
				Throw "Cannot get DatabaseID from given parameter."
			}
			else
			{
				# Add Account to CisDatabase
				$JsonQuery.DatabaseID = $CisDatabase.ID
			}
		}

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Account
		    if (-not [System.String]::IsNullOrEmpty($CisSystem))
		    {
    			# Return System account filtering by ID to avoid double result due to account being registered both with password and SSH Keys
    			return (Get-CisAccount -CisSystem $CisSystem -User $User | Where-Object { $_.ID -eq $WebResponseResult.Result })
		    }
            elseif (-not [System.String]::IsNullOrEmpty($CisDomain))
		    {
    			# Return Domain account
    			return (Get-CisAccount -CisDomain $CisDomain -User $User)
		    }
		    elseif (-not [System.String]::IsNullOrEmpty($CisDatabase))
		    {
    			# Return Database account
                return (Get-CisAccount -CisDatabase $CisDatabase -User $User)
		    }
		}
		else
		{
			# Query error
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}
