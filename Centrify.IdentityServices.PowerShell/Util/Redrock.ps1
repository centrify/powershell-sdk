################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

function Centrify.IdentityServices.PowerShell.Redrock.CreateQuery
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Query to use for the RedRock Query.")]
		[System.String]$Query,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Arguments to use for the RedRock Query.")]
		[System.Collections.Hashtable]$Arguments
	)

	try
	{
		# Get antixss value from Cookies
		$CookieUri = ("https://{0}" -f $CisConnection.PodFqdn)
		$antixss = ($CisConnection.Session.Cookies.GetCookies($CookieUri) | Where-Object { $_.Name -eq "antixss" }).Value

        # Build Uri value from CisConnection variable including antixss value
		$Uri = ("https://{0}/RedRock/query?antixss={1}" -f $CisConnection.PodFqdn, $antixss)

		# Create RedrockQuery
		$RedrockQuery = @{}
		$RedrockQuery.Uri			= $Uri
		$RedrockQuery.ContentType	= "application/json"
		$RedrockQuery.Header 		= @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		#$RedrockQuery.Header 		= $CisConnection.Session.Headers

		# Build the JsonQuery string and add it to the RedrockQuery
		$JsonQuery = @{}
		$JsonQuery.Script 	= $Query
		$JsonQuery.Args 	= $Arguments

		$RedrockQuery.Json 	= $JsonQuery | ConvertTo-Json
		
		# Return RedrockQuery
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile
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
		# Return CipQuery object
		return $RedrockQuery
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.Redrock.GetIDFromPrincipal
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
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
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
