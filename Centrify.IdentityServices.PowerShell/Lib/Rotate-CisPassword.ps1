################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet supports ability to rotate password for a given CisAccount.

.DESCRIPTION
This Cmdlet supports ability to rotate password for a given CisAccount.

.PARAMETER CisAccount
Mandatory CisAccount.

.INPUTS
[CisAccount]

.OUTPUTS

.EXAMPLE
#>
function global:Rotate-CisPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$CisAccount		
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

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/RotatePassword" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}

		if (-not [System.String]::IsNullOrEmpty($CisAccount))
		{
			if ([System.String]::IsNullOrEmpty($CisAccount.ID))
			{
				Throw "Cannot get CisAccount ID from given parameter."
			}
			else
			{
				# Get CisAccount ID
				$JsonQuery.ID = $CisAccount.ID
			}
		}

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Valid Job success
            if ($WebResponseResult.Result.Success)
            {
                # Return nothing
                Exit 0
            }
            else
            {
		        # Job error
		        Throw $WebResponseResult.Result.Reason
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
