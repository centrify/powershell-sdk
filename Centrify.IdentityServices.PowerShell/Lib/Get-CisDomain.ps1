################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet retrieves important registered CisDomain information 

.DESCRIPTION
This CMDlet retrieves important registered CisDomain information

.PARAMETER Name
Optional [String] parameter to specify the Name of the Domain to get.

.INPUTS
CmdLet takes as input optional parameters: [String] Name

.OUTPUTS
This Cmdlet returns result upon success. Returns error message upon failure.

.EXAMPLE
C:\PS> Get-CisDomain.ps1 
Output all CisDomain domains registered on system

.EXAMPLE
C:\PS> Get-CisDomain.ps1 -Name "ocean.net"
Output domain information for the specified domain
#>
function global:Get-CisDomain
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Name of the Domain to get.")]
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
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Set RedrockQuery
		$Query = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetDomain"
		
		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
		
		if (-not [System.String]::IsNullOrEmpty($Name))
		{
			# Add Filter to Arguments
			$Arguments.FilterBy 	= ("Name", "")
			$Arguments.FilterValue	= $Name
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
