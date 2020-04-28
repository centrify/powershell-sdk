################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet returns account(s) from the vault.

.DESCRIPTION
This Cmdlet returns one or more account(s) from a given System, Domain or Database.
NOTE: When targeting a specific type of account, it is possible to use the wildcard character to return all acounts existing of that type.

.PARAMETER CisResource
Mandatory CisResource from where to get account(s) (use * to get accounts from all Resources).

.PARAMETER CisDomain
Mandatory CisDomain from where to get account(s) (use * to get accounts from all Domains).

.PARAMETER CisDatabase
Mandatory CisDatabase from where to get account(s) (use * to get accounts from all Databases).

.PARAMETER User
Optional username of the account to get. 

.INPUTS 
One of [CisSystem], [CisDomain] or [CisDatabase]

.OUTPUTS
[CisAccount]

.EXAMPLE
C:\PS> Get-CisAccount -CisSystem *
Return all accounts of type System accounts (also known as Local Accounts).

.EXAMPLE
C:\PS> Get-CisAccount -User "root" -CisSystem *
Return all accounts named 'root' from all systems.

.EXAMPLE
C:\PS> Get-CisAccount -User "sa" -CisDatabase (Get-CisDatabase -Name "WIN-SQLDB01\AUDIT")
Return account named 'sa' from Database named 'WIN-SQLDB01\AUDIT' using CisDatabase parameter

.EXAMPLE
C:\PS> Get-CisDomain -Name "ocean.net" | Get-CisAccount
Return all accounts from domain 'ocean.net' using input object from pipeline
#> 
function global:Get-CisAccount
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

		[Parameter(Mandatory = $false, HelpMessage)]
		[Parameter(ParameterSetName = "CisSystem")]
		[Parameter(ParameterSetName = "CisDomain")]
		[Parameter(ParameterSetName = "CisDatabase")]
		[System.String]$User,

		[Parameter(Mandatory = $false, HelpMessage)]
		[Switch]$Detailed
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

	if (-not [System.String]::IsNullOrEmpty($CisSystem))
	{
		# Get Local Account
		try
		{	
			# Set Arguments
			$Arguments = @{}
			$Arguments.PageNumber 	= 1
			$Arguments.PageSize 	= 10000
			$Arguments.Limit	 	= 10000
			$Arguments.SortBy	 	= ""
			$Arguments.Direction 	= "False"
			$Arguments.Caching	 	= -1
	
			# Setup variable for the RedRock Query
			$BaseQuery = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetVaultAccount"
			
			if ($CisSystem -eq "*")
			{
				# Resource not specified
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts from ALL Resources
					$Query = ("{0} ORDER BY User COLLATE NOCASE" -f $BaseQuery)
				}
				else
				{
					# Get User from ALL Resources
					$Query = ("{0} WHERE VaultAccount.User ='{1}'" -f $BaseQuery, $User)
				}
			}			
			else
			{
				# Resource is specified
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts for this Resource
					$Query = ("{0} WHERE VaultAccount.Host = '{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $CisSystem.ID)
				}
				else
				{
					# Get User from this Resource
					$Query = ("{0} WHERE VaultAccount.Host = '{1}' AND VaultAccount.User ='{2}'" -f $BaseQuery, $CisSystem.ID, $User)
				}
			}

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
			    # Get raw data
                $CisAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($CisAccounts -ne [Void]$null -and $Detailed.IsPresent)
                {
                    # Modify results
                    $CisAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $CisAccounts
            }
		}
		catch
		{
			Throw $_.Exception   
		}
	}

	if (-not [System.String]::IsNullOrEmpty($CisDomain))
	{
		# Get Domain Account
		try
		{	
			# Get current connection to the Centrify Cloud Platform
			$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection
	
			# Set RedrockQuery
			$BaseQuery = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetDomainAccount"
			
			# Set Arguments
			$Arguments = @{}
			$Arguments.PageNumber 	= 1
			$Arguments.PageSize 	= 10000
			$Arguments.Limit	 	= 10000
			$Arguments.SortBy	 	= ""
			$Arguments.Direction 	= "False"
			$Arguments.Caching	 	= -1
			
			# Add filters
			if (-not [System.String]::IsNullOrEmpty($User))
			{
				# Add Filter to Arguments
				$Arguments.FilterBy 	= ("User", "")
				$Arguments.FilterValue	= $User
				$Arguments.FilterQuery	= "null"
				$Arguments.Caching		= 0
			}

			if ($CisDomain -eq "*")
			{
				# Get acount(s) for ALL Domains
				$Query = ("{0} ORDER BY User COLLATE NOCASE" -f $BaseQuery)
			}
			else
			{
				# Get acount(s) for specified CisDomain
				$Query = ("{0} WHERE VaultDomain.ID ='{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $CisDomain.ID)
			}
				
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
			    # Get raw data
                $CisAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($CisAccounts -ne [Void]$null)
                {
                    # Modify results
                    $CisAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $CisAccounts
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

	if (-not [System.String]::IsNullOrEmpty($CisDatabase))
	{
		# Get Database Account
		try
		{	
			# Set RedrockQuery
			$BaseQuery = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetDatabaseAccount"
			
			# Add filters
			if ($CisDatabase -eq "*")
			{
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts from ALL Databases
					$Query = ("{0} ORDER BY User COLLATE NOCASE" -f $BaseQuery)
				}
				else
				{
					# Get User from ALL Databases
					$Query = ("{0} WHERE VaultAccount.User ='{1}'" -f $BaseQuery, $User)
				}
			}
			else
			{
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts for this Database
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $CisDatabase.ID)
				}
				else
				{
					# Get User from this Database
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}' AND VaultAccount.User ='{2}'" -f $BaseQuery, $CisDatabase.ID, $User)
				}
			}

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
			    # Get raw data
                $CisAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($CisAccounts -ne [Void]$null)
                {
                    # Modify results
                    $CisAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $CisAccounts
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
}
