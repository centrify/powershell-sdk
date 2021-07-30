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
This CMDlet retrieves important PASEndpoint infrom from the system.

.DESCRIPTION
This CMDlet retrieves important PASEndpoint infrom from the system.

.PARAMETER Name
Optional [String] Name parameter searches device by name

.INPUTS
CmdLet takes as input optional parameters: [String] Filter

.OUTPUTS
This CmdLet returns result details upon success. Returns error message upon failure.

.EXAMPLE
C:\PS> Get-CentrifyDevice
Retrieves all registered CentrifyDevice

.EXAMPLE
C:\PS> Get-CentrifyDevice -Name ""
Retrieves device named 
#>
function global:Get-CentrifyDevice
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the device by name.")]
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
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetDevice"
		
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
