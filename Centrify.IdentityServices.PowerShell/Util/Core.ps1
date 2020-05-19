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
