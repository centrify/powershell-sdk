################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet returns a CisCollection of CisSecret objects.

.DESCRIPTION
This Cmdlet returns a Set of CisSecrets.

.PARAMETER Name
Mandatory Name of the Secret's Set to get

.INPUTS

.OUTPUTS
[CisCollection]

.EXAMPLE
C:\PS> Get-CisSecretCollection
Returns all existing Sets of CisSecret.

.EXAMPLE
C:\PS> Get-CisSecretCollection -Name "License Keys"
Returns the Set of CisSecret named 'License Keys'.
#>
function global:Get-CisSecretCollection
{
	param
	(
		[Parameter(Mandatory = $false)]
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

		# Setup variable for the CisQuery
		$Uri = ("https://{0}/Collection/GetObjectCollectionsAndFilters" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.NoBuiltins	= "True"
		$JsonQuery.ObjectType	= "DataVault"
		$JsonQuery.Args			= $Arguments
		
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Return all Collections
                return $WebResponseResult.Result.Results.Row | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
            else
            {
                # Return Collection by Name
                return $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name } | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
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
