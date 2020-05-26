###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet removes the specified [Object] PASSecret from the system.

.DESCRIPTION
This CMDlet removes the specified [Object] PASSecret from the system.
NOTE: Get-PASSecret Cmdlet must be used to acquire the desired [Object] PASSecret 

.PARAMETER PASSecret
Mandatory [Object] PASSecret  to remove.

.INPUTS
This Cmdlet takes the following mandatory inputs: [Object] PASSecret

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns error message in case of failure.

.EXAMPLE
PS: C:\PS\Remove-PASSecret.ps1 -PASSecret (Get-PASSecret -Name "Secret")
This CmdLet removes the PASSecret named 'Secret' from the system
#>
function global:Remove-PASSecret
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, HelpMessage = "Secret to remove.")]
		[System.Object]$PASSecret
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
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteDataVaultItem" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        if ($PASSecret -ne [void]$null)
        {
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID					= $PASSecret.ID
        }
        else
        {
            # Missing parameter
            Throw "PASSecret must be specified."
        }

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
