###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet returns account(s) from the vault.

.DESCRIPTION
This Cmdlet returns one or more account(s) from a given System, Domain or Database.
NOTE: When targeting a specific type of account, it is possible to use the wildcard character to return all acounts existing of that type.

.PARAMETER PASResource
Mandatory PASResource from where to get account(s) (use * to get accounts from all Resources).

.PARAMETER PASDomain
Mandatory PASDomain from where to get account(s) (use * to get accounts from all Domains).

.PARAMETER PASDatabase
Mandatory PASDatabase from where to get account(s) (use * to get accounts from all Databases).

.PARAMETER User
Optional username of the account to get. 

.INPUTS 
One of [PASSystem], [PASDomain] or [PASDatabase]

.OUTPUTS
[PASAccount]

.EXAMPLE
C:\PS> Get-PASAccount -PASSystem *
Return all accounts of type System accounts (also known as Local Accounts).

.EXAMPLE
C:\PS> Get-PASAccount -User "root" -PASSystem *
Return all accounts named 'root' from all systems.

.EXAMPLE
C:\PS> Get-PASAccount -User "sa" -PASDatabase (Get-PASDatabase -Name "WIN-SQLDB01\AUDIT")
Return account named 'sa' from Database named 'WIN-SQLDB01\AUDIT' using PASDatabase parameter

.EXAMPLE
C:\PS> Get-PASDomain -Name "ocean.net" | Get-PASAccount
Return all accounts from domain 'ocean.net' using input object from pipeline
#> 
function global:Get-PASAccount
{
	[CmdletBinding(DefaultParameterSetName = "PASSystem")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASSystem")]
		[System.Object]$PASSystem,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDomain")]
		[System.Object]$PASDomain,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "PASDatabase")]
		[System.Object]$PASDatabase,

		[Parameter(Mandatory = $false, HelpMessage)]
		[Parameter(ParameterSetName = "PASSystem")]
		[Parameter(ParameterSetName = "PASDomain")]
		[Parameter(ParameterSetName = "PASDatabase")]
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
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	if (-not [System.String]::IsNullOrEmpty($PASSystem))
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
			$BaseQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetVaultAccount"
			
			if ($PASSystem -eq "*")
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
					$Query = ("{0} WHERE VaultAccount.Host = '{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $PASSystem.ID)
				}
				else
				{
					# Get User from this Resource
					$Query = ("{0} WHERE VaultAccount.Host = '{1}' AND VaultAccount.User ='{2}'" -f $BaseQuery, $PASSystem.ID, $User)
				}
			}

			# Build Query
			$RedrockQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PASConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $PASAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($PASAccounts -ne [Void]$null -and $Detailed.IsPresent)
                {
                    # Modify results
                    $PASAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $PASAccounts
            }
		}
		catch
		{
			Throw $_.Exception   
		}
	}

	if (-not [System.String]::IsNullOrEmpty($PASDomain))
	{
		# Get Domain Account
		try
		{	
			# Get current connection to the Centrify Cloud Platform
			$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection
	
			# Set RedrockQuery
			$BaseQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetDomainAccount"
			
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

			if ($PASDomain -eq "*")
			{
				# Get acount(s) for ALL Domains
				$Query = ("{0} ORDER BY User COLLATE NOCASE" -f $BaseQuery)
			}
			else
			{
				# Get acount(s) for specified PASDomain
				$Query = ("{0} WHERE VaultDomain.ID ='{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $PASDomain.ID)
			}
				
			# Build Query
			$RedrockQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PASConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $PASAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($PASAccounts -ne [Void]$null)
                {
                    # Modify results
                    $PASAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $PASAccounts
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

	if (-not [System.String]::IsNullOrEmpty($PASDatabase))
	{
		# Get Database Account
		try
		{	
			# Set RedrockQuery
			$BaseQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetDatabaseAccount"
			
			# Add filters
			if ($PASDatabase -eq "*")
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
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}' ORDER BY User COLLATE NOCASE" -f $BaseQuery, $PASDatabase.ID)
				}
				else
				{
					# Get User from this Database
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}' AND VaultAccount.User ='{2}'" -f $BaseQuery, $PASDatabase.ID, $User)
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
			$RedrockQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PASConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $PASAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($PASAccounts -ne [Void]$null)
                {
                    # Modify results
                    $PASAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $PASAccounts
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
