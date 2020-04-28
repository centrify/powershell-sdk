################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

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

.PARAMETER CisCollection
Optional CisCollection object to apply permissions to.

.PARAMETER CisSystem
Optional CisSystem to apply permissions to.

.PARAMETER CisAccount
Optional CisAccount to apply permissions to.

.PARAMETER CisSecret
Optional CisSecret to apply permissions to.

.PARAMETER CisDomain
Optional CisDomain to apply permissions to.

.PARAMETER CisDatabase
Optional CisDatabase to apply permissions to.

.PARAMETER CisService
Optional CisService to apply permissions to.

.PARAMETER Principal
Mandatory Principal of the User, Group or Role to whom grant permissions to.

.PARAMETER Right
Optional Rights to grant or revoke

.INPUTS 
One of [CisAccount], [CisCollection], [CisCollectionMembers], [CisDatabase], [CisDomain], [CisSecret] or [CisSystem]

.OUTPUTS

.EXAMPLE
C:\PS> Set-CisPermissions -CisSystem (Get-CisSystem -Name "WIN-SQLDB01") -Principal "dwirth@ocean.net" -Right "View,Edit"
Grant the permission to View and Edit the system named 'WIN-SQLDB01' to AD User 'dwirth' from domain 'ocean.net' using CisSystem parameter

.EXAMPLE
C:\PS> Get-CisSecret -Name "castle" | Set-CisPermissions -Principal "Castle-Admins@ocean.net" -Right "View,Retrieve"
Grant the permission to View and Retrieve the secret named 'castle' to AD Group 'Castle-Admins' from domain 'ocean.net' using input object from pipeline

.EXAMPLE
C:\PS> Set-CisPermissions -Principal "Database Admin" -Right "None" -CisSystemCollection (Get-CisSystemCollection -Name "Domain Controllers")
Revoke the permissions on the Set of Systems named 'Domain Controllers' for the Role named 'Database Admin'
#>
function global:Set-CisPermissions
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisAccount")]
		[System.Object]$CisAccount,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisCollection")]
		[System.Object]$CisCollection,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisCollectionMembers")]
		[System.Object]$CisCollectionMembers,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisDatabase")]
		[System.Object]$CisDatabase,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisDomain")]
		[System.Object]$CisDomain,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisSecret")]
		[System.Object]$CisSecret,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "CisSystem")]
		[System.Object]$CisSystem,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Principal to grant Permissions to")]
		[Parameter(ParameterSetName = "CisAccount")]
		[Parameter(ParameterSetName = "CisCollection")]
		[Parameter(ParameterSetName = "CisCollectionMembers")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisSecret")]
		[Parameter(ParameterSetName = "CisSystem")]
		[System.String]$Principal,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Rights to grant.")]
		[Parameter(ParameterSetName = "CisAccount")]
		[Parameter(ParameterSetName = "CisCollection")]
		[Parameter(ParameterSetName = "CisCollectionMembers")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisSecret")]
		[Parameter(ParameterSetName = "CisSystem")]
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
	
	# Get the CisAccount ID
	if (-not [System.String]::IsNullOrEmpty($CisAccount))
	{
		if ([System.String]::IsNullOrEmpty($CisAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Set Permissions to CisAccount
			$APIEndpoint = "/ServerManage/SetAccountPermissions"
            $TargetID = $CisAccount.ID
		}
	}

	# Get the CisCollection ID
	if (-not [System.String]::IsNullOrEmpty($CisCollection))
	{
		if ([System.String]::IsNullOrEmpty($CisCollection.ID))
		{
			Throw "Cannot get CollectionID from given parameter."
		}
		else
		{
			# Set Permissions to CisSystem
			$APIEndpoint = "/Collection/SetCollectionPermissions"
            $TargetID = $CisCollection.ID
		}
	}

	# Get the CisCollectionMembers ID
	if (-not [System.String]::IsNullOrEmpty($CisCollectionMembers))
	{
		if ([System.String]::IsNullOrEmpty($CisCollectionMembers.ID))
		{
			Throw "Cannot get CollectionID from given parameter."
		}
		else
		{
			# Set Permissions to CisSystem
			if ($CisCollectionMembers.ObjectType -eq "DataVault")
            {
                # Collection members are Secrets
                $APIEndpoint = "/ServerManage/SetDataVaultCollectionPermissions"
			}
			elseif ($CisCollectionMembers.ObjectType -eq "DomainVault")
            {
                # Collection members are Domains
                $APIEndpoint = "/ServerManage/SetDomainCollectionPermissions"
			}
			elseif ($CisCollectionMembers.ObjectType -eq "DatabaseVault")
            {
                # Collection members are Databases
                $APIEndpoint = "/ServerManage/SetDatabaseCollectionPermissions"
			}
			elseif ($CisCollectionMembers.ObjectType -eq "VaultAccount")
            {
                # Collection members are Accounts
                $APIEndpoint = "/ServerManage/SetAccountCollectionPermissions"
			}
			elseif ($CisCollectionMembers.ObjectType -eq "Server")
            {
                # Collection members are Systems
                $APIEndpoint = "/ServerManage/SetResourceCollectionPermissions"
			}
			elseif ($CisCollectionMembers.ObjectType -eq "Subscriptions")
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
            $TargetID = $CisCollectionMembers.ID
		}
	}

	# Get the CisDatabase ID
	if (-not [System.String]::IsNullOrEmpty($CisDatabase))
	{
		if ([System.String]::IsNullOrEmpty($CisDatabase.ID))
		{
			Throw "Cannot get DatabaseID from given parameter."
		}
		else
		{
			# Set Permissions to CisDatabase
			$APIEndpoint = "/ServerManage/SetDatabasePermissions"
            $TargetID = $CisDatabase.ID
		}
	}

	# Get the CisDomain ID
	if (-not [System.String]::IsNullOrEmpty($CisDomain))
	{
		if ([System.String]::IsNullOrEmpty($CisDomain.ID))
		{
			Throw "Cannot get DomainID from given parameter."
		}
		else
		{
			# Set Permissions to CisDomain
			$APIEndpoint = "/ServerManage/SetDomainPermissions"
            $TargetID = $CisDomain.ID
		}
	}

	# Get the CisSecret ID
	if (-not [System.String]::IsNullOrEmpty($CisSecret))
	{
		if ([System.String]::IsNullOrEmpty($CisSecret.ID))
		{
			Throw "Cannot get Secret ID from given parameter."
		}
		else
		{
			# Set Permissions to CisSystem
			$APIEndpoint = "/ServerManage/SetDataVaultItemPermissions"
            $TargetID = $CisSecret.ID
		}
	}

	# Get the CisSystem ID
	if (-not [System.String]::IsNullOrEmpty($CisSystem))
	{
		if ([System.String]::IsNullOrEmpty($CisSystem.ID))
		{
			Throw "Cannot get SystemID from given parameter."
		}
		else
		{
			# Set Permissions to CisSystem
			$APIEndpoint = "/ServerManage/SetResourcePermissions"
            $TargetID = $CisSystem.ID
		}
	}
	
    # Set Permissions
	try
	{	
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Setup variable for query
		$Uri = ("https://{0}{1}" -f $CisConnection.PodFqdn, $APIEndpoint)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Look for ID by Principal starting with Users
		$PrincipalType 	= "User"
		$PrincipalID	= Centrify.IdentityServices.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
		if ([System.String]::IsNullOrEmpty($PrincipalID))
		{
			# If PrincipalID not found, try with Groups
			$PrincipalType 	= "Group"
			$PrincipalID	= Centrify.IdentityServices.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
		}
		if ([System.String]::IsNullOrEmpty($PrincipalID))
		{
			# If PrincipalID not found, try with Roles
			$PrincipalType 	= "Role"
			$PrincipalID	= Centrify.IdentityServices.PowerShell.Redrock.GetIDFromPrincipal -Principal $Principal -PrincipalType $PrincipalType
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
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