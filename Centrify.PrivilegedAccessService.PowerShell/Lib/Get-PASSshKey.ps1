###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves SSH keys 

.DESCRIPTION
This CMDlet retrieves SSH keys 

.PARAMETER Name
Optional parameter to specify the Name of the SSH key to retrieve

.PARAMETER Filter
Optional parameter to specify the Filter to use to search for Secret(s). Searches the following fields: "Name", "KeyType", "KeyFormat")

.EXAMPLE
C:\PS>  $PASSshKey = Get-PASSshKey 
List all SSH keys from vault and places in $PASSshKey object

.EXAMPLE
C:\PS>  $PASSshKey = Get-PASSshKey -Name "root@server123"
List SSH key from vault with Name "root@server123"
#>
function global:Get-PASSshKey
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to get by Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for Secret(s).")]
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
		$Query = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetSshKey"
		
		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
		
        # Add Filter
		if (-not [System.String]::IsNullOrEmpty($Filter))
		{
			# Add Filter to Arguments
			$Arguments.FilterBy 	= ("Name", "KeyType", "KeyFormat")
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
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Get all results
                $PASSshKeys = $WebResponseResult.Result.Results.Row
            }
            else
            {
                # Get only matches from filtered results
			    $PASSshKeys = $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name }
            }
            
            # Only modify results if not empty
            if ($PASSshKeys -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $PASSshKeys | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetSshKeyActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetSshKeyPermissions($_.ID))
                }
            }
            
            # Return results
            return $PASSshKeys
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
