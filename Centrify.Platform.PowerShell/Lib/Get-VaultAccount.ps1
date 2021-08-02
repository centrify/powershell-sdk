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
C:\PS> Get-VaultAccount -VaultSystem *
Return all accounts of type System accounts (also known as Local Accounts).

.EXAMPLE
C:\PS> Get-VaultAccount -User "root" -VaultSystem *
Return all accounts named 'root' from all systems.

.EXAMPLE
C:\PS> Get-VaultAccount -User "sa" -VaultDatabase (Get-VaultDatabase -Name "service-now-sql")
Return account named 'sa' from Database named 'WIN-SQLDB01\AUDIT' using PASDatabase parameter

.EXAMPLE
C:\PS> Get-VaultDomain -Name "ocean.net" | Get-VaultAccount
Return all accounts from domain 'ocean.net' using input object from pipeline
#> 
function global:Get-VaultAccount
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	if (-not [System.String]::IsNullOrEmpty($VaultSystem))
	{
		# Get Local Account
		try
		{	
			# Setup variable for the RedRock Query
			$BaseQuery = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetVaultAccount"
			
			if ($VaultSystem -eq "*")
			{
				# Resource not specified
				if (-not [System.String]::IsNullOrEmpty($User))
				{
					# Get User from ALL Resources
					$Query = ("{0} WHERE VaultAccount.User ='{1}'" -f $BaseQuery, $User)
				}
				else
				{
					$Query = $BaseQuery
				}
			}			
			else
			{
				# Resource is specified
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts for this Resource
					$Query = ("{0} WHERE VaultAccount.Host = '{1}'" -f $BaseQuery, $VaultSystem.ID)
				}
				else
				{
					# Get User from this Resource
					$Query = ("{0} WHERE VaultAccount.Host = '{1}' AND VaultAccount.User = '{2}'" -f $BaseQuery, $VaultSystem.ID, $User)
				}
			}

			# Build Query
			$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $VaultAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($VaultAccounts -ne [Void]$null -and $Detailed.IsPresent)
                {
                    # Modify results
                    $VaultAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.Platform.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $VaultAccounts
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

	if (-not [System.String]::IsNullOrEmpty($VaultDomain))
	{
		# Get Domain Account
		try
		{	
			# Get current connection to the Centrify Platform
			$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection
	
			# Set RedrockQuery
			$BaseQuery = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetDomainAccount"
	
			if ($VaultDomain -eq "*")
			{
				# Domain not specified
				if (-not [System.String]::IsNullOrEmpty($User))
				{
					# Get User from ALL Domains
					$Query = ("{0} WHERE VaultAccount.User ='{1}'" -f $BaseQuery, $User)
				}
				else
				{
					$Query = $BaseQuery
				}
			}			
			else
			{
				# Domain is specified
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts for this Domain
					$Query = ("{0} WHERE VaultDomain.ID = '{1}'" -f $BaseQuery, $VaultDomain.ID)
				}
				else
				{
					# Get User from this Resource
					$Query = ("{0} WHERE VaultDomain.ID = '{1}' AND VaultAccount.User = '{2}'" -f $BaseQuery, $VaultDomain.ID, $User)
				}
			}

			# Build Query
			$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $VaultAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($VaultAccounts -ne [Void]$null -and $Detailed.IsPresent)
                {
                    # Modify results
                    $VaultAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.Platform.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $VaultAccounts
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

	if (-not [System.String]::IsNullOrEmpty($VaultDatabase))
	{
		# Get Database Account
		try
		{	
			# Set RedrockQuery
			$BaseQuery = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetDatabaseAccount"
			
			# Add filters
			if ($VaultDatabase -eq "*")
			{
				if (-not [System.String]::IsNullOrEmpty($User))
				{
					# Get User from ALL Databases
					$Query = ("{0} WHERE VaultAccount.User ='{1}'" -f $BaseQuery, $User)
				}
				else
				{
					$Query = $BaseQuery
				}
			}
			else
			{
				if ([System.String]::IsNullOrEmpty($User))
				{
					# No Username given, return ALL acounts for this Database
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}'" -f $BaseQuery, $VaultDatabase.ID)
				}
				else
				{
					# Get User from this Database
					$Query = ("{0} WHERE VaultDatabase.ID ='{1}' AND VaultAccount.User ='{2}'" -f $BaseQuery, $VaultDatabase.ID, $User)
				}
			}

			# Build Query
			$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
			Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
			    # Get raw data
                $VaultAccounts = $WebResponseResult.Result.Results.Row
            
                # Only modify results if not empty
                if ($VaultAccounts -ne [Void]$null -and $Detailed.IsPresent)
                {
                    # Modify results
                    $VaultAccounts | ForEach-Object {
                        # Add Activity
                        $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetAccountActivity($_.ID))

                        # Add Permissions
                        $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.Platform.PowerShell.Core.GetAccountPermissions($_.ID))
                    }
                }
            
                # Return results
                return $VaultAccounts
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
