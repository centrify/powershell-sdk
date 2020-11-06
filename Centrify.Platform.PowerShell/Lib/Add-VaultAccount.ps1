###########################################################################################
# Centrify Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT centrify.com
# Release  : 21/01/2016
# Copyright: (c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet adds an Account to the vault. 

.DESCRIPTION
This Cmdlet adds an Account to either a specified PASResource, PASDomain, or PASDatabase. 
The Account must exists in the target system, domain or database as the credentials will be validated after creation.

.PARAMETER User
Mandatory Username of the account to add.

.PARAMETER PASResource
Mandatory PASResource where to add account to. 

.PARAMETER PASDomain
Mandatory PASDomain where to add account to.

.PARAMETER PASDatabase
Mandatory PASDatabase where to add the account to. 

.PARAMETER Password
Optional Password for the account (note if this paramete is ommited and no PASSshKey provided, the account password will be blank).

.PARAMETER PASSshKey
Optional PASSshKey to use as credential for system account (this parameter is only effective if the account is added to a system of type "Unix").

.PARAMETER Description
Optional Description for this account.

.PARAMETER isManaged
Optional  isManaged to specify whether account password should be managed or not (false by default).

.INPUTS
One of [PASResource], [PASDomain] or [PASDatabase]

.OUTPUTS
[PASAccount]

.EXAMPLE
C:\PS>  Add-VaultAccount -User "svc-bcrab" -VaultSystem (Get-VaultSystem -Name "WIN-BLUECRAB01") -Password "!L1keSeaF00d"
Add the local account 'svc-bcrab' to system named 'WIN-BLUECRAB01' using the VaultSystem parameter.

.EXAMPLE
C:\PS> PASDatabase (Get-VaultDatabase "castledb") | Add-VaultAccount -User "oracastle" -Password "J!IRU()U" -IsManaged $true
Add the account 'oracastle' to database named 'castledb' and immediately managed the paccount password using input object from pipeline.
#> 
function global:Add-VaultAccount
{
	[CmdletBinding(DefaultParameterSetName = "PASSystem")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASSystem")]
		[System.Object]$VaultSystem,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDomain")]
		[System.Object]$VaultDomain,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDatabase")]
		[System.Object]$VaultDatabase,

		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = "PASSystem")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASDatabase")]
		[System.String]$User,
		
		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "PASSystem")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASDatabase")]
		[System.String]$Password,

		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "PASSystem")]
		[System.Object]$PASSshKey,
		
		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "PASSystem")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASDatabase")]
		[System.String]$Description,

		[Parameter(Mandatory = $false)]
		[Parameter(ParameterSetName = "PASSystem")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASDatabase")]
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Get the PASSystem ID
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/AddAccount" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.User 		= $User
		$JsonQuery.IsManaged	= $IsManaged
		$JsonQuery.Description	= $Description

        if (-not [System.String]::IsNullOrEmpty($PASSshKey))
        {
            # Adding SSH Key as credential
    		$JsonQuery.CredentialType = "SshKey"
    		$JsonQuery.SshKeyId       = $PASSshKey.ID
    		$JsonQuery.SshKeyName     = $PASSshKey.Name
        }
        else
        {
            # Adding password as credential
    		$JsonQuery.Password = $Password
        }

		# Adding target information
		if (-not [System.String]::IsNullOrEmpty($VaultSystem))
		{
			if ([System.String]::IsNullOrEmpty($VaultSystem.ID))
			{
				Throw "Cannot get ResourceID from given parameter."
			}
			else
			{
				# Add Local Account to PASSystem
				$JsonQuery.Host = $VaultSystem.ID
			}
		}

		if (-not [System.String]::IsNullOrEmpty($VaultDomain))
		{
			if ([System.String]::IsNullOrEmpty($VaultDomain.ID))
			{
				Throw "Cannot get DomainID from given parameter."
			}
			else
			{
				# Add Account to PASDomain
				$JsonQuery.DomainID = $VaultDomain.ID
			}
		}

		if (-not [System.String]::IsNullOrEmpty($VaultDatabase))
		{
			if ([System.String]::IsNullOrEmpty($VaultDatabase.ID))
			{
				Throw "Cannot get DatabaseID from given parameter."
			}
			else
			{
				# Add Account to PASDatabase
				$JsonQuery.DatabaseID = $VaultDatabase.ID
			}
		}

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Account
		    if (-not [System.String]::IsNullOrEmpty($VaultSystem))
		    {
    			# Return System account filtering by ID to avoid double result due to account being registered both with password and SSH Keys
    			return (Get-VaultAccount -System $VaultSystem -User $User | Where-Object { $_.ID -eq $WebResponseResult.Result })
		    }
            elseif (-not [System.String]::IsNullOrEmpty($VaultDomain))
		    {
    			# Return Domain account
    			return (Get-VaultAccount -Domain $VaultDomain -User $User)
		    }
		    elseif (-not [System.String]::IsNullOrEmpty($VaultDatabase))
		    {
    			# Return Database account
                return (Get-VaultAccount -Database $VaultDatabase -User $User)
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
