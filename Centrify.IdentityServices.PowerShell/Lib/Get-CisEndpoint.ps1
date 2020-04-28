################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet retrieves important CisEndpoint infrom from the system.

.DESCRIPTION
This CMDlet retrieves important CisEndpoint infrom from the system. Optional -Filter parameter supports searches across fields: 
"Name", "Serial", "ModelName", "DisplayModelName", "OSVersion", "Owner", "Carrier", "PhoneNumber", "DisplayState"

.PARAMETER Filter
Optional [String] Filter parameter searches across fields: 
"Name", "Serial", "ModelName", "DisplayModelName", "OSVersion", "Owner", "Carrier", "PhoneNumber", "DisplayState"

.INPUTS
CmdLet takes as input optional parameters: [String] Filter

.OUTPUTS
This CmdLet returns result details upon success. Returns error message upon failure.

.EXAMPLE
C:\PS> Get-CisEndpoint.ps1 
Retrieves all registered CisEndpoint 

.EXAMPLE
C:\PS> Get-CisEndpoint.ps1 -Filter "iOS"
Retrieves all registered CisEndpoint with specified filter
#>
function global:Get-CisEndpoint
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for Endpoint(s).")]
		[System.String]$Filter
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
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Set RedrockQuery
		$Query = "SELECT * FROM Device ORDER BY Owner COLLATE NOCASE"

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
		
		if (-not [System.String]::IsNullOrEmpty($Filter))
		{
			# Add Filter to Arguments
			$Arguments.FilterBy 	= ("Name", "Serial", "ModelName", "DisplayModelName", "OSVersion", "Owner", "Carrier", "PhoneNumber", "DisplayState")
			$Arguments.FilterValue	= $Filter
			$Arguments.FilterQuery	= "null"
			$Arguments.Caching		= 0
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
