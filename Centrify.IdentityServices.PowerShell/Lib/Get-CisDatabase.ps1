################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet retrieves important database information from the system.

.DESCRIPTION
This CMDlet retrieves important database information from the system.
This CmdLet accepts as input following optional parameters: [String] Name.

.PARAMETER Name
Optional [String] parameter to specify the Name of the Database to get.

.INPUTS
This CmdLet accepts as input following optional parameters: [String] Name

.OUTPUTS
This CmdLet returns results upon success. Returns failure message in case of failure.

.EXAMPLE
C:\PS> Get-CisDatabase.ps1
Outputs list of all databases on system

.EXAMPLE
C:\PS> Get-CisDatabase.ps1 -Name "Castle"
Outputs database information of the database specified
#>
function global:Get-CisDatabase
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Name of the Database to get.")]
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
		$Query = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetDatabase"
		
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
			# Get raw result
            $CisDatabases = $WebResponseResult.Result.Results.Row
            
            # Only modify results if not empty
            if ($CisDatabases -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CisDatabases | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetDatabaseActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetDatabasePermissions($_.ID))
                }
            }

            # Return results
            return $CisDatabases
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
