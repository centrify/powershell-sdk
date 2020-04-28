################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

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

.EXAMPLE
#>
function global:Run-CisRedrockQuery
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
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

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
		$RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $CisConnection.Session
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
