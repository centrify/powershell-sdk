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
This Cmdlet grants or revoke specific rights to a specified principal on a specified object.

.DESCRIPTION
This Cmdlet can grants or revoke specific relevant rights to a specified principal (User, Group or Role) on a specified object.
Rights available will be different based on the object type of the object this Cmdlet is used to grant or revoke right to.

To grant rigths, separate them by using comma:
  e.g. "View,Edit,Delete"

To revokw rights, simply re-apply permissions with a reduced set of rights:
  e.g. "View,Edit"
  
To revoke entirely the rights, specify None:
  e.g. "None"  

.PARAMETER PASCollection
Optional PASCollection object to apply permissions to.

.PARAMETER PASSystem
Optional PASSystem to apply permissions to.

.PARAMETER PASAccount
Optional PASAccount to apply permissions to.

.PARAMETER PASSecret
Optional PASSecret to apply permissions to.

.PARAMETER PASDomain
Optional PASDomain to apply permissions to.

.PARAMETER PASDatabase
Optional PASDatabase to apply permissions to.

.PARAMETER PASService
Optional PASService to apply permissions to.

.PARAMETER Principal
Mandatory Principal of the User, Group or Role to whom grant permissions to.

.PARAMETER Right
Optional Rights to grant or revoke

.INPUTS 
One of [PASAccount], [PASCollection], [PASCollectionMembers], [PASDatabase], [PASDomain], [PASSecret] or [PASSystem]

.OUTPUTS

.EXAMPLE
C:\PS> Set-VaultPermission -VaultSystem (Get-VaultSystem -Name "WIN-SQLDB01") -Principal "dwirth@ocean.net" -Right "View,Edit"
Grant the permission to View and Edit the system named 'WIN-SQLDB01' to AD User 'dwirth' from domain 'ocean.net' using PASSystem parameter

.EXAMPLE
C:\PS> Get-VaultSecret -Name "castle" | Set-VaultPermission -Principal "Castle-Admins@ocean.net" -Right "View,Retrieve"
Grant the permission to View and Retrieve the secret named 'castle' to AD Group 'Castle-Admins' from domain 'ocean.net' using input object from pipeline

.EXAMPLE
C:\PS> Set-VaultPermission -Principal "Database Admin" -Right "None" -SystemCollection (Get-VaultSystemSet -Name "Domain Controllers")
Revoke the permissions on the Set of Systems named 'Domain Controllers' for the Role named 'Database Admin'
#>
function global:Set-VaultPermission
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASAccount")]
		[System.Object]$VaultAccount,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASCollection")]
		[System.Object]$PASCollection,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASCollectionMembers")]
		[System.Object]$PASCollectionMembers,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDatabase")]
		[System.Object]$VaultDatabase,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDomain")]
		[System.Object]$VaultDomain,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASSecret")]
		[System.Object]$VaultSecret,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASSystem")]
		[System.Object]$VaultSystem,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Principal to grant Permissions to")]
		[Parameter(ParameterSetName = "PASAccount")]
		[Parameter(ParameterSetName = "PASCollection")]
		[Parameter(ParameterSetName = "PASCollectionMembers")]
		[Parameter(ParameterSetName = "PASDatabase")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASSecret")]
		[Parameter(ParameterSetName = "PASSystem")]
		[System.String]$Principal,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Rights to grant.")]
		[Parameter(ParameterSetName = "PASAccount")]
		[Parameter(ParameterSetName = "PASCollection")]
		[Parameter(ParameterSetName = "PASCollectionMembers")]
		[Parameter(ParameterSetName = "PASDatabase")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASSecret")]
		[Parameter(ParameterSetName = "PASSystem")]
		[System.String]$Rights
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
	
	# Get the PASAccount ID
	if (-not [System.String]::IsNullOrEmpty($VaultAccount))
	{
		if ([System.String]::IsNullOrEmpty($VaultAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Set Permissions to PASAccount
			$APIEndpoint = "/ServerManage/SetAccountPermissions"
            $TargetID = $VaultAccount.ID
		}
	}

	# Get the PASCollection ID
	if (-not [System.String]::IsNullOrEmpty($PASCollection))
	{
		if ([System.String]::IsNullOrEmpty($PASCollection.ID))
		{
			Throw "Cannot get CollectionID from given parameter."
		}
		else
		{
			# Set Permissions to PASSystem
			$APIEndpoint = "/Collection/SetCollectionPermissions"
            $TargetID = $PASCollection.ID
		}
	}

	# Get the PASCollectionMembers ID
	if (-not [System.String]::IsNullOrEmpty($PASCollectionMembers))
	{
		if ([System.String]::IsNullOrEmpty($PASCollectionMembers.ID))
		{
			Throw "Cannot get CollectionID from given parameter."
		}
		else
		{
			# Set Permissions to PASSystem
			if ($PASCollectionMembers.ObjectType -eq "DataVault")
            {
                # Collection members are Secrets
                $APIEndpoint = "/ServerManage/SetDataVaultCollectionPermissions"
			}
			elseif ($PASCollectionMembers.ObjectType -eq "DomainVault")
            {
                # Collection members are Domains
                $APIEndpoint = "/ServerManage/SetDomainCollectionPermissions"
			}
			elseif ($PASCollectionMembers.ObjectType -eq "DatabaseVault")
            {
                # Collection members are Databases
                $APIEndpoint = "/ServerManage/SetDatabaseCollectionPermissions"
			}
			elseif ($PASCollectionMembers.ObjectType -eq "VaultAccount")
            {
                # Collection members are Accounts
                $APIEndpoint = "/ServerManage/SetAccountCollectionPermissions"
			}
			elseif ($PASCollectionMembers.ObjectType -eq "Server")
            {
                # Collection members are Systems
                $APIEndpoint = "/ServerManage/SetResourceCollectionPermissions"
			}
			elseif ($PASCollectionMembers.ObjectType -eq "Subscriptions")
            {
                # Collection members are Services
                $APIEndpoint = "/ServerManage/SetSubscriptionsCollectionPermissions"
			}
            else
            {
                # Unknown object type
                Throw "Cannot identify Collection Members. ObjectType unknown."
            }
            # Set target
            $TargetID = $PASCollectionMembers.ID
		}
	}

	# Get the PASDatabase ID
	if (-not [System.String]::IsNullOrEmpty($VaultDatabase))
	{
		if ([System.String]::IsNullOrEmpty($VaultDatabase.ID))
		{
			Throw "Cannot get DatabaseID from given parameter."
		}
		else
		{
			# Set Permissions to PASDatabase
			$APIEndpoint = "/ServerManage/SetDatabasePermissions"
            $TargetID = $VaultDatabase.ID
		}
	}

	# Get the PASDomain ID
	if (-not [System.String]::IsNullOrEmpty($VaultDomain))
	{
		if ([System.String]::IsNullOrEmpty($VaultDomain.ID))
		{
			Throw "Cannot get DomainID from given parameter."
		}
		else
		{
			# Set Permissions to PASDomain
			$APIEndpoint = "/ServerManage/SetDomainPermissions"
            $TargetID = $VaultDomain.ID
		}
	}

	# Get the PASSecret ID
	if (-not [System.String]::IsNullOrEmpty($VaultSecret))
	{
		if ([System.String]::IsNullOrEmpty($VaultSecret.ID))
		{
			Throw "Cannot get Secret ID from given parameter."
		}
		else
		{
			# Set Permissions to PASSystem
			$APIEndpoint = "/ServerManage/SetDataVaultItemPermissions"
            $TargetID = $VaultSecret.ID
		}
	}

	# Get the PASSystem ID
	if (-not [System.String]::IsNullOrEmpty($VaultSystem))
	{
		if ([System.String]::IsNullOrEmpty($VaultSystem.ID))
		{
			Throw "Cannot get SystemID from given parameter."
		}
		else
		{
			# Set Permissions to PASSystem
			$APIEndpoint = "/ServerManage/SetResourcePermissions"
            $TargetID = $VaultSystem.ID
		}
	}
	
    # Set Permissions
	try
	{	
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for query
		$Uri = ("https://{0}{1}" -f $PlatformConnection.PodFqdn, $APIEndpoint)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Look for ID by Principal starting with Users
		$PrincipalType 	= "User"
		$PrincipalID	= Centrify.Platform.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
		if ([System.String]::IsNullOrEmpty($PrincipalID))
		{
			# If PrincipalID not found, try with Groups
			$PrincipalType 	= "Group"
			$PrincipalID	= Centrify.Platform.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
		}
		if ([System.String]::IsNullOrEmpty($PrincipalID))
		{
			# If PrincipalID not found, try with Roles
			$PrincipalType 	= "Role"
			$PrincipalID	= Centrify.Platform.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
		}
		if ([System.String]::IsNullOrEmpty($PrincipalID))
		{
			# If PrincipalID still not found
			Throw ("Cannot find any object with Principal '{0}'." -f $Principal)
		}		
			
		# Set permissions to grant
		$Permissions = @{}
		$Permissions.Principal 		= $Principal
		$Permissions.PrincipalID 	= $PrincipalID
		$Permissions.PType	 		= $PrincipalType
		$Permissions.Rights 		= $Rights

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID 		= $TargetID
		$JsonQuery.PVID 	= $TargetID
		$JsonQuery.Grants	= @($Permissions)
			
		$Json = $JsonQuery | ConvertTo-Json
			
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
						
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result
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
