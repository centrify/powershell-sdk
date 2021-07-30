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
This Cmdlet retrieves important information about CentrifyUser(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about CentrifyUser(s) on the system. 
Output can be filtered using -Filter parameter which searches for patterns across: "Username", "DisplayName", "Email", "Status", "LastInvite", and "LastLogin" fields.

.PARAMETER Name
Optional [String] Specify the User by its Centrify Directory Username.

.INPUTS
None

.OUTPUTS
[CentrifyUser]

.EXAMPLE
C:\PS> Get-CentrifyUser 
Outputs all CentrifyUser objects on system

.EXAMPLE
C:\PS> Get-CentrifyUser -Username "john.doe@domain.name"
Return user with username "john.doe@domain.name"
#>
function global:Get-CentrifyUser
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the User by its Centrify Directory Username.")]
		[System.String]$Username,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
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
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetUser"
		
		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($Username))
		{
			# Add Arguments to Statement
			$Query = ("{0} WHERE Username='{1}'" -f $Query, $Username)
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
            $CentrifyUsers = $WebResponseResult.Result.Results.Row
            
            # Only modify results if not empty
            if ($CentrifyUsers -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CentrifyUsers | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetUserActivity($_.ID))

                    # Add Attributes
                    $_ | Add-Member -MemberType NoteProperty -Name Attributes -Value (Centrify.Platform.PowerShell.Core.GetUserAttributes($_.ID))
                }
            }
            
            # Return results
            return $CentrifyUsers
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
