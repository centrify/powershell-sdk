###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet removes the specified [Object] PASAccount from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] PASAccount from the system.
NOTE: The Get-PASAccount CmdLet must be used to get the desired [Object] PASAccount to delete

.PARAMETER PASAccount
Mandatory parameters to specify the [Object] PASAccount to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] PASAccount

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-PASAccount -PASAccount (Get-PASAccount -PASSystem (Get-PASSystem -Name "TST-SRV123") -Name "root")
#>
function global:Remove-PASAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASAccount(s) to delete.")]
		[System.Object]$PASAccount,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Detailed
	)
	
	# Pre-Pipeline steps
	begin
	{
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

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteAccount" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the PASAccount ID
			if ([System.String]::IsNullOrEmpty($PASAccount.ID))
			{
				Throw "Cannot get AccountID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $PASAccount.ID

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
					# Success
					Write-Debug ("Account {0} deleted." -f $PASAccount.Name)
				}
				else
				{
					# Query error
					Throw $WebResponseResult.Message
				}
			}
		}
		catch
		{
            Throw $_.Exception
		}
	}
	
	# Post-Pipeline steps
	end
	{
		try
		{
			# Success
			Write-Debug "Account(s) deleted."
		}
		catch
		{
			Throw $_.Exception   
		}
	}
}
