################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet removes the specified [Object] CisSshKey from the vault.

.DESCRIPTION
This CMDlet removes the specified [Object] CisSshKey from the vault.
NOTE: Get-CisSshKey Cmdlet must be used to acquire the desired [Object] CisSshKey 

.PARAMETER CisSshKey
Mandatory [Object] CisSshKey  to remove.

.INPUTS
This Cmdlet takes the following mandatory inputs: [Object] CisSshKey

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns error message in case of failure.

.EXAMPLE
PS: C:\PS\Remove-CisSshKey -CisSshKey (Get-CisSshKey -Name "root@server123")
This CmdLet removes the CisSshKey named 'Secret' from the vault
#>
function global:Remove-CisSshKey
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "SSH Key to remove.")]
		[System.Object]$CisSshKey
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
		$Uri = ("https://{0}/ServerManage/DeleteSshKey" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        if ($CisSshKey -ne [void]$null)
        {
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID = $CisSshKey.ID
        }
        else
        {
            # Missing parameter
            Throw "CisSshKey must be specified."
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
