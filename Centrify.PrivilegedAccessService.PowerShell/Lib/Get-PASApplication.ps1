###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves detailed information of the registered PASApplication on the system.

.DESCRIPTION
This CMDlet retrieves detailed information of the registered applications on the systems. 
Cmdlet supports optional -Filter param which search in the following fields for matching strings:
"Name", "AppTypeDisplayName", "Description", "State"

.PARAMETER Filter
Optional [String] Filter parameter used to query based on system name.

.INPUTS
This CmdLet accepts following optional parameters: [String] Filter

.OUTPUTS
This CmdLet outputs result upon success. Outputs failure in case of failure.

.EXAMPLE
C:\PS> Get-PASApplication.ps1
This will output all applications on systems.

.EXAMPLE
C:\PS> Get-PASApplication -Filter "OAuth"
This will attempt to provide output of all the objects which have specified filter in it's searched fields.

.EXAMPLE
C:\PS> Get-PASApplication -Filter "Active"
This will attempt to provide output of all objects which have specified filter in it's searched fields.
#>
function global:Get-PASApplication
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for App(s).")]
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
		$Query = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetApplication"

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
			$Arguments.FilterBy 	= ("Name", "AppTypeDisplayName", "Description", "State")
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
