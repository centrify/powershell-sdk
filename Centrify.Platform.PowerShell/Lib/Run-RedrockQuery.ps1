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
This CMDlet execute a Redrock Query and return results.

.DESCRIPTION
This CMDlet execute a Redrock Query from a file or string and return results.

.PARAMETER Query
Optional [String] query to execute.

.PARAMETER SqlFile
Optional [String] file that contains the query to execute.

.INPUTS

.OUTPUTS

.EXAMPLE
 C:\PS>Run-RedrockQuery -Query "SELECT * FROM (Select * FROM VaultDomain)
 This CMDlet execute a Redrock Query and return results.

.EXAMPLE
#>
function global:Run-RedrockQuery
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Query to execute.")]
		[System.String]$Query,

		[Parameter(Mandatory = $false, HelpMessage = "File that contains the query to execute.")]
		[System.String]$SqlFile
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

		# Setup variable for the RedRock Query
		if ([System.String]::IsNullOrEmpty($Query))
        {
            # Query not specified using -Query
            if ([System.String]::IsNullOrEmpty($SqlFile))
            {
                # If -Query is not used then -SqlFile cannot also be null
                Throw "Must specify the query to execute by using -Query or -SqlFile parameter."
            }
            else
            {
                # Verify that file exists
                if (Test-Path $SqlFile)
                {
		            # Load query from file
                    $Query = ""
                    Get-Content -Path $SqlFile | ForEach-Object { $Query += $_ }
                }
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
		$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return results
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
