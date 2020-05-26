###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves detailed secret information 

.DESCRIPTION
This CMDlet retrieves detailed secret information 

.PARAMETER Name
Optional parameter to specify the Name of the Secret to retrieve

.PARAMETER Filter
Optional parameter to specify the Filter to use to search for Secret(s). Searches the following fields: "SecretName", "Type", "SecretFileName")

.EXAMPLE
C:\PS>  $PASSecret = Get-PASSecret 
Retrieves all secrets on system and places in $PASSecret object

.EXAMPLE
C:\PS>  $PASSecret = Get-PASSecret -Name "Secret"
Retrieves detailed secret on machine with Name "Secret"

.EXAMPLE
C:\PS>  $PASSecret = Get-PASSecret -Filter "Text"
Retrieves detailed secret(s) on system that contain "text" in "SecretName", "Type", or "SecretFileName"
#>
function global:Get-PASSecret
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
		$Query = Centrify.PrivilegedAccessService.PowerShell.Redrock.GetQueryFromFile -Name "GetSecret"
		
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
			$Arguments.FilterBy 	= ("SecretName", "Type", "SecretFileName")
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
                $PASSecrets = $WebResponseResult.Result.Results.Row
            }
            else
            {
                # Get only matches from filtered results
			    $PASSecrets = $WebResponseResult.Result.Results.Row | Where-Object { $_.SecretName -eq $Name }
            }
            
            # Only modify results if not empty
            if ($PASSecrets -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $PASSecrets | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetSecretActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.PrivilegedAccessService.PowerShell.Core.GetSecretPermissions($_.ID))
                }
            }
            
            # Return results
            return $PASSecrets
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
