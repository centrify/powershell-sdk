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

function Centrify.Platform.PowerShell.Redrock.CreateQuery
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Query to use for the RedRock Query.")]
		[System.String]$Query
	)

	try
	{
		# Build Uri value from PlatformConnection variable
		$Uri = ("https://{0}/RedRock/Query" -f $PlatformConnection.PodFqdn)
		
		# Create RedrockQuery
		$RedrockQuery = @{}
		$RedrockQuery.Uri			= $Uri
		$RedrockQuery.ContentType	= "application/json"
		$RedrockQuery.Header 		= @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Build the JsonQuery string and add it to the RedrockQuery
		$JsonQuery = @{}
		$JsonQuery.Script 	= $Query

		$RedrockQuery.Json 	= $JsonQuery | ConvertTo-Json
		
		# Return RedrockQuery
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.Platform.PowerShell.Redrock.GetQueryFromFile
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
		# Return Redrock query
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.Platform.PowerShell.Redrock.GetIDFromPrincipal
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
		$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
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
