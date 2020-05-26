###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet retrieves important information about PASUser(s) on the system.

.DESCRIPTION
This Cmdlet retrieves important information about PASUser(s) on the system. 
Output can be filtered using -Filter parameter which searches for patterns across: "Username", "DisplayName", "Email", "Status", "LastInvite", and "LastLogin" fields.

.PARAMETER Filter
Optional [String] filter parameter to query on. Search for match will include the following attributes: "Username", "DisplayName", "Email", "Status", "LastInvite", "LastLogin"

.INPUTS
This CmdLet takes the following optional parameters: [String] Filter

.OUTPUTS
This Cmdlet retrieves important information about PASUser(s) on the system.

.EXAMPLE
C:\PS> Get-PASUser 
Outputs all PASUser objects on system

.EXAMPLE
C:\PS> Get-PASUser | Select-Object -Property DisplayName, Status, LastLogin
Output all objects showing only properties of DisplayName, Status, LastLogin

.EXAMPLE
C:\PS> Get-PASUser -Filter "admin"
Ouput objects that meet criteria with "admin" in searched fields

.EXAMPLE
C:\PS> Get-PASUser -Filter "08/30/2018"
Output objects that meet criteria with "08/30/2018" such as LastLogin
#>
function global:Get-PASUser
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for User(s).")]
		[System.String]$Filter,

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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Set RedrockQuery
		$Query = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetUser"
		
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
			$Arguments.FilterBy 	= ("Username", "DisplayName", "Email", "Status", "LastInvite", "LastLogin")
			$Arguments.FilterValue 	= $Filter
			$Arguments.FilterQuery 	= ""
			$Arguments.Caching	 	= 0
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
			# Get raw data
            $PASUsers = $WebResponseResult.Result.Results.Row
            
            # Only modify results if not empty
            if ($PASUsers -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $PASUsers | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetUserActivity($_.ID))

                    # Add Attributes
                    $_ | Add-Member -MemberType NoteProperty -Name Attributes -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetUserAttributes($_.ID))
                }
            }
            
            # Return results
            return $PASUsers
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
