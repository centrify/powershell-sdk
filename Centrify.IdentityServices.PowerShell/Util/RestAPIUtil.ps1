################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

function Centrify.IdentityServices.PowerShell.Core.GetCisConnection
{
    param()
    
    try
    {    
        if ($Global:CisConnection -eq [Void]$null)
        {
            # Inform connection does not exists and suggest to initiate one
            Write-Warning ("No connection could be found with the Centrify Identity Services. Use Connect-CisService Cmdlet to create a valid connection.")
			Break
        }
		else
		{
			# Return existing connection
			return $Global:CisConnection
		}
    }
    catch
    {
        Throw $_.Exception   
    }
}


#region Entitlements functions
function Centrify.IdentityServices.PowerShell.Core.GetDefaultEntitlements
{
    param ()
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/Entitlements/FetchDefaults" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
        $JsonQuery.tenantId = $CisConnection.CustomerID

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
			# Success return list of Default Entitlement values
			return $WebResponseResult.Result | Select-Object -Property Id, Description, Enabled, StartDate
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

function Centrify.IdentityServices.PowerShell.Core.GetEntitlement
{
    param
    (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the ID of the Entitlement to get. If not specified, return all entitlements.")]
		[System.String]$ID
    )
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/Entitlements/FetchEntitlement" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.tenantId = $CisConnection.CustomerID
        $JsonQuery.entitlementId = $ID

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
			# Success return list of Entitlements
			return $WebResponseResult.Result | Select-Object -Property Id, Description, Enabled, StartDate
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

function Centrify.IdentityServices.PowerShell.Core.SetEntitlement
{
    param
    (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the ID of the Entitlement to Enable.")]
		[System.String]$ID,

		[Parameter(Mandatory = $true, HelpMessage = "Set Enablement to True or False.")]
		[System.Boolean]$Enable = $true
    )
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/Entitlements/ModifyEntitlement" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.modifications = @{ "Enabled" = $Enable }
        $JsonQuery.tenantId = $CisConnection.CustomerID
        $JsonQuery.entitlementId = $ID

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
			# Success return modified Entitlment object
            return (Centrify.IdentityServices.PowerShell.Core.GetEntitlement -ID $ID)
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

function Centrify.IdentityServices.PowerShell.Core.SetTenantConfig
{
    param
    (
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Tenant configuration key to set.")]
		[System.String]$Key,

		[Parameter(Mandatory = $true, HelpMessage = "Set Value.")]
		[System.String]$Value
    )
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/Core/SetTenantConfig" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
		$JsonQuery = @{}

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Get -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return nothing
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
#endregion

#region Directory Services functions
function Centrify.IdentityServices.PowerShell.Core.GetDirectoryServices
{
    param ()
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/core/GetDirectoryServices" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}

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
			# Success return list of DirectoryServices ID
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.DirectoryServiceQuery
{
    param
    (
		[Parameter(Mandatory = $false, HelpMessage = "Specify the User to find from DirectoryServices.")]
		[System.Object]$User,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Group to find from DirectoryServices.")]
		[System.Object]$Group,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Role to find from DirectoryServices.")]
		[System.Object]$Role
    )
    
    try
    {
		# Setup variable for query
		$Uri = ("https://{0}/UserMgmt/DirectoryServiceQuery" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Arguments
		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1

        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.Args = $Arguments
        $JsonQuery.directoryServices = (Centrify.IdentityServices.PowerShell.Core.GetDirectoryServices | Select-Object -Property directoryServiceUuid).directoryServiceUuid

        if (-not [System.String]::IsNullOrEmpty($User))
        {
            # User Query
            $JsonQuery.user = ("{{`"_and`":[{{`"_or`":[{{`"DisplayName`":`"{0}`"}},{{`"SystemName`":`"{0}`"}}]}},{{`"ObjectType`":`"user`"}}]}}" -f $User)
        }
        elseif (-not [System.String]::IsNullOrEmpty($Group))
        {
            # Group Query
            $JsonQuery.group = ("{{`"_or`":[{{`"DisplayName`":`"{0}`"}},{{`"SystemName`":`"{0}`"}}]}}" -f $Group)
        }
        elseif (-not [System.String]::IsNullOrEmpty($Role))
        {
            # Role Query
            $JsonQuery.roles = ("{{`"_or`":[{{`"_ID`":`"{0}`"}},{{`"Name`":`"{0}`"}}]}}" -f $Role)
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
			# Success return found object
            if (-not [System.String]::IsNullOrEmpty($User))
            {
                # User Query
                return $WebResponseResult.Result.User.Results.Row
            }
            elseif (-not [System.String]::IsNullOrEmpty($Group))
            {
                # Group Query
                return $WebResponseResult.Result.Group.Results.Row
            }
            elseif (-not [System.String]::IsNullOrEmpty($Role))
            {
                # Role Query
                return $WebResponseResult.Result.roles.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetUserActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisUser ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/get_user_activity_for_admin.js(userid:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetUserAttributes
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisUser ID to get Attributes from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/UserMgmt/GetUserAttributes" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
        $JsonQuery.ID = $ID
        
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

function Centrify.IdentityServices.PowerShell.Core.GetSystemActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisSystem ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/server/get_activity_for_server.js(id:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetSystemPermissions
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisSystem ID to get Permissions from.")]
		[System.String]$ID
	)

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/GetResourcePermissions" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID = $ID
			
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

function Centrify.IdentityServices.PowerShell.Core.GetSecretActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisSecret ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/server/get_activity_for_generic_secret.js(id:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetSecretPermissions
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisSecret ID to get Permissions from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/GetDataVaultItemRightsAndChallenges" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID = $ID
			
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

function Centrify.IdentityServices.PowerShell.Core.GetDatabaseActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisDatabase ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/server/get_activity_for_database.js(id:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetDatabasePermissions
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisDatabase ID to get Permissions from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/GetDatabasePermissions" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID = $ID
			
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

function Centrify.IdentityServices.PowerShell.Core.GetAccountActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisAccount ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/server/get_activity_for_account.js(id:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetAccountPermissions
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisAccount ID to get Permissions from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/GetAccountPermissions" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID = $ID
			
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

function Centrify.IdentityServices.PowerShell.Core.GetRoleAdministrativeRights
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisRole ID to get Administrative Rights from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for the CipQuery
		$Uri = ("https://{0}/Core/GetAssignedAdministrativeRights" -f $CisConnection.PodFqdn, $RoleId)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.Role	= $ID
		$JsonQuery.Args	= $Arguments
			
		$Json = $JsonQuery | ConvertTo-Json
			
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
									
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetRoleApps
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisRole ID to get Apps from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/SaasManage/GetRoleApps?role={1}" -f $CisConnection.PodFqdn, $ID)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body "" -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetRoleMembers
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisRole ID to get Members from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/SaasManage/GetRoleMembers?name={1}" -f $CisConnection.PodFqdn, $ID)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body "" -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetSshKeyActivity
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisSshKey ID to get Activity from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Set RedrockQuery
		$Query = ("@/lib/server/get_activity_for_sshkeys.js(id:'{0}')" -f $ID)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
			
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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

function Centrify.IdentityServices.PowerShell.Core.GetSshKeyPermissions
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisSshKey ID to get Permissions from.")]
		[System.String]$ID
	)
	
	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/GetSshKeyRightsAndChallenges" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.ID = $ID
			
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
#endregion

#region Redrock functions
function Centrify.IdentityServices.PowerShell.Redrock.CreateQuery
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Query to use for the RedRock Query.")]
		[System.String]$Query,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Arguments to use for the RedRock Query.")]
		[System.Collections.Hashtable]$Arguments
	)

	try
	{
		# Get antixss value from Cookies
		$CookieUri = ("https://{0}" -f $CisConnection.PodFqdn)
		$antixss = ($CisConnection.Session.Cookies.GetCookies($CookieUri) | Where-Object { $_.Name -eq "antixss" }).Value

        # Build Uri value from CisConnection variable including antixss value
		$Uri = ("https://{0}/RedRock/query?antixss={1}" -f $CisConnection.PodFqdn, $antixss)

		# Create RedrockQuery
		$RedrockQuery = @{}
		$RedrockQuery.Uri			= $Uri
		$RedrockQuery.ContentType	= "application/json"
		$RedrockQuery.Header 		= @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		#$RedrockQuery.Header 		= $CisConnection.Session.Headers

		# Build the JsonQuery string and add it to the RedrockQuery
		$JsonQuery = @{}
		$JsonQuery.Script 	= $Query
		$JsonQuery.Args 	= $Arguments

		$RedrockQuery.Json 	= $JsonQuery | ConvertTo-Json
		
		# Return RedrockQuery
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the SQL Query Name to get from files.")]
		[System.String]$Name
	)
	
	try
	{
		# Get Redrock query definition from file
		$RedrockQuery = ""
		Get-Content -Path ("{0}\Redrock\{1}.sql" -f $PSScriptRoot, $Name) | ForEach-Object {
			$RedrockQuery += $_
		}
		# Return CipQuery object
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.Redrock.GetIDFromPrincipal
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Principal to get ID from.")]
		[System.String]$Principal,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the PrincipalType to get ID from.")]
		[System.String]$PrincipalType
	)

	try
	{
		# Set RedrockQuery
		switch ($PrincipalType)
		{
			"User"
			{
				# Search for Users
				$Query = ("SELECT InternalName as ID FROM DsUsers WHERE SystemName LIKE '{0}'" -f $Principal)
			}
			
			"Group"
			{
				# Search for Groups
				$Query = ("SELECT InternalName as ID FROM DsGroups WHERE SystemName LIKE '{0}'" -f $Principal)
			}

			"Role"
			{
				# Search for Roles
				$Query = ("SELECT ID FROM Role WHERE Name LIKE '{0}'" -f $Principal)
			}
			
			default
			{
				Throw "Unsupported PrincipalType value."
			}
		}
		
		# Set Arguments
		$Arguments = @{}
		
		# Build Query
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row.ID
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
#endregion

#region OAuth2 functions
function Centrify.IdentityServices.PowerShell.OAuth2.ConvertToSecret
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Client ID.")]
        [System.String]$ClientID,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Client password.")]
		[System.String]$Password		
    )

    # Combine ClientID and Password then encode authentication string in Base64
    $AuthenticationString = ("{0}:{1}" -f $ClientID, $Password)
    $Secret = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($AuthenticationString))

    # Return Base64 encoded secret
    return $Secret
}

function Centrify.IdentityServices.PowerShell.OAuth2.ConvertFromSecret
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Secret to decode.")]
        [System.String]$Secret		
    )

    # Decode authentication string from Base64
    $AuthenticationString = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Secret))
    $AuthenticationCreds = @{ "ClientID" = $AuthenticationString.Split(':')[0]; "Password" = $AuthenticationString.Split(':')[1]}

    # Return Base64 decoded authentication details
    return $AuthenticationCreds
}

function Centrify.IdentityServices.PowerShell.OAuth2.GetBearerToken
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the URL to connect to.")]
        [System.String]$Url,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Service name.")]
		[System.String]$Service,	

        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Scope name.")]
		[System.String]$Scope,	

        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Secret.")]
		[System.String]$Secret		
    )

    # Setup variable for connection
	$Uri = ("https://{0}/oauth2/token/{1}" -f $Url, $Service)
	$ContentType = "application/x-www-form-urlencoded" 
	$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; "Authorization" = ("Basic {0}" -f $Secret) }
	Write-Host ("Connecting to Centrify Identity Services (https://{0}) using OAuth2 Client Credentials flow" -f $Url)
			
    # Format body
    $Body = ("grant_type=client_credentials&scope={0}" -f  $Scope)
	
	# Debug informations
	Write-Debug ("Uri= {0}" -f $Uri)
	Write-Debug ("Header= {0}" -f $Header)
	Write-Debug ("Body= {0}" -f $Body)
    		
	# Connect using OAuth2 Client
	$WebResponse = Invoke-WebRequest -Method Post -SessionVariable CisSession -Uri $Uri -Body $Body -ContentType $ContentType -Headers $Header
    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
    if ([System.String]::IsNullOrEmpty($WebResponseResult.access_token))
    {
        Throw "OAuth2 Client authentication error."
    }
	else
    {
        # Return Bearer Token from successfull login
        return $WebResponseResult.access_token
    }
}
#endregion

#region X509Certificates functions
function Centrify.IdentityServices.PowerShell.X509Certificates.GetCertificateFromBase64String
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate in Base64 String format.")]
        [System.String]$Base64String,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate password.")]
		[System.Security.SecureString]$Password		
    )
	
    $pfxBytes = [System.Convert]::FromBase64String($Base64String)
	
    $keyStoreFlags 	= 		[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet `
					-bOr 	[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet `
					-bOr 	[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    
	if(-not [System.String]::IsNullOrEmpty($Password))
    {
        # Return a X509 Certificate with associated Password
		return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxBytes, $Password, $keyStoreFlags)
    }   
    else
    {
        # Return a X509 Certificate with no Password
        return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxBytes, "", $keyStoreFlags)
    }
}


function Centrify.IdentityServices.PowerShell.X509Certificates.AddCertificateToStore
{
    param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Certificate store where to add the Certificate.")]
		[System.String]$Store,
		
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate to use to connect.")]
        [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate
    )
    
	try
	{
		# Determine Certificate Store to use
		$StoreName 		= $Store.Split('\')[2]
		$StoreLocation 	= $Store.Split('\')[1]
		$CertStore 		= New-Object System.Security.Cryptography.X509Certificates.X509Store($StoreName, $StoreLocation)

		# Open Certificate Store in RW mode
		$CertStore.Open("ReadWrite")
		
		# Remove any already existing Certificate to replace
		$CertStore.Certificates | Where-Object { $_.Subject -eq $Certificate.Subject } | ForEach-Object { $CertStore.Remove($_) }
				
		# Add Certificate and close Store
		$CertStore.Add($Certificate)
		$CertStore.Close()
	}
	catch
	{
		if ($_.Exception.Message -match "Access is denied")
		{
			# Certificate Store access denied
			Throw ("Access to Certificate store {0} is denied." -f $Store)
		}
		else
		{
			# Unknown exception
			Throw $_.Exception   		
		}
	}
}

function Centrify.IdentityServices.PowerShell.X509Certificates.GetCertificateFromStore
{
    param(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Certificate Store name.")]
		[System.String]$StoreName,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Certificate Thumbprint.")]
		[System.String]$Thumbprint
    )
    
	try
	{
		# Open Certificate Store in RO mode
        $CertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", $StoreName)
		$CertStore.Open("ReadOnly")
		
		# Get Certificate by Thumbprint and close Store
		$X509Certificate = $CertStore.Certificates | Where-Object { $_.Thumbprint -eq $Thumbprint }
		$CertStore.Close()
		if ($X509Certificate -eq [void]$null)
		{
			# Certificate not found
			Throw ("Could not find Certificate from store {0}." -f $StoreName)
		}
        elseif ($X509Certificate.GetType().BaseType -eq [System.Array])
        {
            Throw "More than one certificate found using given CN. Try refining certificate common name."
        }
		
		# Return X509Certificate
		return $X509Certificate
	}
	catch
	{
		if ($_.Exception.Message -match "Access is denied")
		{
			# Certificate Store access denied
			Throw ("Access to Certificate store {0} is denied." -f $StoreName)
		}
		else
		{
			# Unknown exception
			Throw $_.Exception   		
		}
	}
}
#endregion

#region DataVault functions
function Centrify.IdentityServices.PowerShell.DataVault.RequestSecretUploadUrl
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Name to upload.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Size to upload.")]
		[System.String]$Size,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the SecretID (required for updating secret).")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RequestSecretUploadUrl" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

        # Set Json query
		$JsonQuery = @{}
		$JsonQuery.fileName	= $Name
		$JsonQuery.fileSize	= $Size
		$JsonQuery.secretID	= $SecretID

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return Upload request details
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.RequestSecretDownloadUrl
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the SecretID.")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RequestSecretDownloadUrl" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

        # Set Json query
		$JsonQuery = @{}
		$JsonQuery.secretID	= $SecretID

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return Upload request details
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.UploadSecretFile
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Path to upload.")]
		[System.String]$Path,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Upload Url to use.")]
		[System.String]$UploadUrl
    )
    
	try
	{
		# Setup variable for connection
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Get File Content
        $Data = Get-Content -Path $Path
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Put -Uri $UploadUrl -Body $Data -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return nothing
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.DownloadSecretFile
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Path to write downloaded file to.")]
		[System.String]$Path,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Download Url to use.")]
		[System.String]$DownloadUrl
    )
    
	try
	{
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Get -Uri $DownloadUrl -WebSession $CisConnection.Session -OutFile $Path
		if ($WebResponse.StatusCode -eq 200)
		{
			# Return Success
			return $true
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.ConvertFileSize
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Size in Bytes.")]
		[System.Int64]$ByteSize
    )
    
	try
	{
		# Return the Size as a String
        switch -Regex ([Math]::Truncate([Math]::Log($ByteSize, 1024)))
        {
            '^0' {
                $FileSize = ("{0} B" -f $ByteSize)
            }
            '^1' {
                $FileSize = ("{0:n2} KB" -f ($ByteSize / 1KB))
            }
            '^2' {
                $FileSize = ("{0:n2} MB" -f ($ByteSize / 1MB))
            }
            '^3' {
                $FileSize = ("{0:n2} GB" -f ($ByteSize / 1GB))
            }
            Default {
                $FileSize = ("{0:n2} TB" -f ($ByteSize / 1TB))
            }
        }

        # Return the Size as a String
        return $FileSize
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.GetSecretContent
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the SecretID.")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RetrieveDataVaultItemContents" -f $CisConnection.PodFqdn)
        $ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	
		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $SecretID

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
            # Return Content
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}
#endregion
