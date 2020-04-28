################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet removes the specified [Object] CisAccount from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] CisAccount from the system.
NOTE: The Get-CisAccount CmdLet must be used to get the desired [Object] CisAccount to delete

.PARAMETER CisAccount
Mandatory parameters to specify the [Object] CisAccount to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] CisAccount

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-CisAccount -CisAccount (Get-CisAccount -CisSystem (Get-CisSystem -Name "TST-SRV123") -Name "root")
#>
function global:Remove-CisAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisAccount(s) to delete.")]
		[System.Object]$CisAccount,

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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteAccount" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the CisAccount ID
			if ([System.String]::IsNullOrEmpty($CisAccount.ID))
			{
				Throw "Cannot get AccountID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $CisAccount.ID

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
					# Success
					Write-Debug ("Account {0} deleted." -f $CisAccount.Name)
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
