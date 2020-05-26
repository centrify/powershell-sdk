###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet removes the specified [Object] PASSshKey from the vault.

.DESCRIPTION
This CMDlet removes the specified [Object] PASSshKey from the vault.
NOTE: Get-PASSshKey Cmdlet must be used to acquire the desired [Object] PASSshKey 

.PARAMETER PASSshKey
Mandatory [Object] PASSshKey  to remove.

.INPUTS
This Cmdlet takes the following mandatory inputs: [Object] PASSshKey

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns error message in case of failure.

.EXAMPLE
PS: C:\PS\Remove-PASSshKey -PASSshKey (Get-PASSshKey -Name "root@server123")
This CmdLet removes the PASSshKey named 'Secret' from the vault
#>
function global:Remove-PASSshKey
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "SSH Key to remove.")]
		[System.Object]$PASSshKey
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
		$Uri = ("https://{0}/ServerManage/DeleteSshKey" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        if ($PASSshKey -ne [void]$null)
        {
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID = $PASSshKey.ID
        }
        else
        {
            # Missing parameter
            Throw "PASSshKey must be specified."
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
