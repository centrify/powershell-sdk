###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves important PASEndpoint infrom from the system.

.DESCRIPTION
This CMDlet retrieves important PASEndpoint infrom from the system. Optional -Filter parameter supports searches across fields: 
"Name", "Serial", "ModelName", "DisplayModelName", "OSVersion", "Owner", "Carrier", "PhoneNumber", "DisplayState"

.PARAMETER Filter
Optional [String] Filter parameter searches across fields: 
"Name", "Serial", "ModelName", "DisplayModelName", "OSVersion", "Owner", "Carrier", "PhoneNumber", "DisplayState"

.INPUTS
CmdLet takes as input optional parameters: [String] Filter

.OUTPUTS
This CmdLet returns result details upon success. Returns error message upon failure.

.EXAMPLE
C:\PS> Get-PASEndpoint.ps1 
Retrieves all registered PASEndpoint 

.EXAMPLE
C:\PS> Get-PASEndpoint.ps1 -Filter "iOS"
Retrieves all registered PASEndpoint with specified filter
#>
function global:Get-PASEndpoint
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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

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
		$RedrockQuery = Centrify.PrivilegedAccessService.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PASConnection.Session
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
