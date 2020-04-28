################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER CisUser

.PARAMETER LoginName

.INPUTS
This CmdLet takes as input a CisUser object

.OUTPUTS
This Cmdlet returns result from attempting to update CisUser object
#>
function global:Set-CisTenantConfig
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Tenant Config key to set.")]
		[System.String]$Key,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the value to set.")]
		[System.String]$Value
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
		$Uri = ("https://{0}/Core/SetTenantConfig?key={1}&value={2}" -f $CisConnection.PodFqdn, $Key, $Value)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Debug informations
		Write-Debug ("Uri= {0}" -f $CipQuery.Uri)
		Write-Debug ("Args= {0}" -f $Arguments)
		Write-Debug ("Json= {0}" -f $CipQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body "" -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Nothing to return
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
