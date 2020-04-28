################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet removes the specified [Object] CisSecret from the system.

.DESCRIPTION
This CMDlet removes the specified [Object] CisSecret from the system.
NOTE: Get-CisSecret Cmdlet must be used to acquire the desired [Object] CisSecret 

.PARAMETER CisSecret
Mandatory [Object] CisSecret  to remove.

.INPUTS
This Cmdlet takes the following mandatory inputs: [Object] CisSecret

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns error message in case of failure.

.EXAMPLE
PS: C:\PS\Remove-CisSecret.ps1 -CisSecret (Get-CisSecret -Name "Secret")
This CmdLet removes the CisSecret named 'Secret' from the system
#>
function global:Remove-CisSecret
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, HelpMessage = "Secret to remove.")]
		[System.Object]$CisSecret
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
	
	# Get current connection to the Centrify Cloud Platform
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteDataVaultItem" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        if ($CisSecret -ne [void]$null)
        {
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID					= $CisSecret.ID
        }
        else
        {
            # Missing parameter
            Throw "CisSecret must be specified."
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
			# Success return nothing
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
