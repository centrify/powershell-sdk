################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdelt return a CisRole.

.DESCRIPTION
This Cmdlet retrieves detailed CisRole information from the system.

.PARAMETER Name
Optional Name of the Role to return.

.PARAMETER Name
Optional flag to return additional informations: Administrative Rights, Applications, Members.

.INPUTS

.OUTPUTS
[CisRole]

.EXAMPLE
C:\PS> Get-CisRole
Return all existing Roles

.EXAMPLE
C:\PS> Get-CisRole -Name "Infrastructure"
Return the role named 'Infrastructure'
#>
function global:Get-CisRole
{
	param
	(
		[Parameter(Mandatory = $false)]
		[System.String]$Name,

		[Parameter(Mandatory = $false)]
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

		# Setup variable for the RedRock Query
		$BaseQuery = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetRole"

		# Set RedrockQuery
		if ([System.String]::IsNullOrEmpty($Name))
		{
			# No Name given, return ALL Roles
    		$Query = ("{0} ORDER BY Name COLLATE NOCASE" -f $BaseQuery)
		}
		else
		{
			# Get Role by name
			$Query = ("{0} WHERE Name ='{1}'" -f $BaseQuery, $Name)
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
			# Get raw data
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Get all results
                $CisRoles = $WebResponseResult.Result.Results.Row
            }
            else
            {
                # Get only matches from filtered results
			    $CisRoles = $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name }
            }
            
            # Only modify results if not empty
            if ($CisRoles -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CisRoles | ForEach-Object {
                    # Add AdministrativeRights
                    $_ | Add-Member -MemberType NoteProperty -Name AdministrativeRights -Value (Centrify.IdentityServices.PowerShell.Core.GetRoleAdministrativeRights($_.ID))

                    # Add Applications
                    $_ | Add-Member -MemberType NoteProperty -Name Applications -Value (Centrify.IdentityServices.PowerShell.Core.GetRoleApps($_.ID))

                    # Add Members
                    $_ | Add-Member -MemberType NoteProperty -Name Members -Value (Centrify.IdentityServices.PowerShell.Core.GetRoleMembers($_.ID))
                }
            }
            
            # Return results
            return $CisRoles
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
