################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet retrieves detailed CisSystem information.

.DESCRIPTION
This CMDlet retrieves detailed CisSystem information. 

This CmdLet accepts one of the following optional inputs: [String] Name
This CmdLet outputs the [Object] CisSystem object upon success. 

.PARAMETER Name
Optional [String] parameter used to query system name

.INPUTS
This CmdLet accepts one of the following optional inputs: [String] Name

.OUTPUTS
This CmdLet outputs the following upon success: [Object] CisSystem

.EXAMPLE
C:\PS> Get-CisSystem.ps1 
This cmdlet will output detailed information for all registered CisSystem objects on system

.EXAMPLE
C:\PS> Get-CisSystem.ps1 -Name "Windows7Sy1"
This cmdlet will output detailed information for specified CisSystem
#>
function global:Get-CisSystem
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Name of the System to get.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Detailed
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
		$Query = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetResource"

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
			$Arguments.FilterBy 	= ("Name", "FQDN")
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
			# Get raw data
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Get all results
                $CisSystems = $WebResponseResult.Result.Results.Row
            }
            else
            {
                # Get only matches from filtered results
			    $CisSystems = $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name }
            }
            
            # Only modify results if not empty
            if ($CisSystems -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CisSystems | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetSystemActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetSystemPermissions($_.ID))
                }
            }
            
            # Return results
            return $CisSystems
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
