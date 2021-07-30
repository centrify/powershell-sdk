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
This Cmdelt return a PASRole.

.DESCRIPTION
This Cmdlet retrieves detailed PASRole information from the system.

.PARAMETER Name
Optional Name of the Role to return.

.PARAMETER Name
Optional flag to return additional informations: Administrative Rights, Applications, Members.

.INPUTS

.OUTPUTS
[PASRole]

.EXAMPLE
C:\PS> Get-CentrifyRole
Return all existing Roles

.EXAMPLE
C:\PS> Get-CentrifyRole -Name "Infrastructure"
Return the role named 'Infrastructure'
#>
function global:Get-CentrifyRole
{
	param
	(
		[Parameter(Mandatory = $false)]
		[System.String]$Name,

		[Parameter(Mandatory = $false)]
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
	
	try
	{	
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Get built-in RedrockQuery
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetRole"
		
		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($Name))
		{
			# Add Arguments to Statement
			$Query = ("{0} WHERE Name='{1}'" -f $Query, $Name)
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
            $CentrifyRoles = $WebResponseResult.Result.Results.Row
            
            # Only modify results if not empty
            if ($CentrifyRoles -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CentrifyRoles | ForEach-Object {
                    # Add AdministrativeRights
                    $_ | Add-Member -MemberType NoteProperty -Name AdministrativeRights -Value (Centrify.Platform.PowerShell.Core.GetRoleAdministrativeRights($_.ID))

                    # Add Applications
                    $_ | Add-Member -MemberType NoteProperty -Name Applications -Value (Centrify.Platform.PowerShell.Core.GetRoleApps($_.ID))

                    # Add Members
                    $_ | Add-Member -MemberType NoteProperty -Name Members -Value (Centrify.Platform.PowerShell.Core.GetRoleMembers($_.ID))
                }
            }
            
            # Return results
            return $CentrifyRoles
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
