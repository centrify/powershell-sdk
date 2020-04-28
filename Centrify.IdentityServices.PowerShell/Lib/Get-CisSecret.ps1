################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

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
C:\PS>  $CisSecret = Get-CisSecret 
Retrieves all secrets on system and places in $CisSecret object

.EXAMPLE
C:\PS>  $CisSecret = Get-CisSecret -Name "Secret"
Retrieves detailed secret on machine with Name "Secret"

.EXAMPLE
C:\PS>  $CisSecret = Get-CisSecret -Filter "Text"
Retrieves detailed secret(s) on system that contain "text" in "SecretName", "Type", or "SecretFileName"
#>
function global:Get-CisSecret
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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Set RedrockQuery
		$Query = Centrify.IdentityServices.PowerShell.Redrock.GetQueryFromFile -Name "GetSecret"
		
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
                $CisSecrets = $WebResponseResult.Result.Results.Row
            }
            else
            {
                # Get only matches from filtered results
			    $CisSecrets = $WebResponseResult.Result.Results.Row | Where-Object { $_.SecretName -eq $Name }
            }
            
            # Only modify results if not empty
            if ($CisSecrets -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $CisSecrets | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.IdentityServices.PowerShell.Core.GetSecretActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.IdentityServices.PowerShell.Core.GetSecretPermissions($_.ID))
                }
            }
            
            # Return results
            return $CisSecrets
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
