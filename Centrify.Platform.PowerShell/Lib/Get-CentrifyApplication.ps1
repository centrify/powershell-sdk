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
This CMDlet retrieves detailed information of the registered CentrifyApplication on the system.

.DESCRIPTION
This CMDlet retrieves detailed information of the registered applications on the systems. 

.PARAMETER Name
Optional [String] Name parameter used to query based on App name.

.INPUTS
This CmdLet accepts following optional parameters: [String] Filter

.OUTPUTS
This CmdLet outputs result upon success. Outputs failure in case of failure.

.EXAMPLE
C:\PS> Get-CentrifyApplication
This will output all applications on systems.

.EXAMPLE
C:\PS> Get-CentrifyApplication -Filter "OAuth Client"
This will return the App "OAuth Client" if it exists.
#>
function global:Get-CentrifyApplication
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Name of the Application.")]
		[System.String]$Name
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
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetApplication"
		
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
