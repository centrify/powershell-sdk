################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet removes the specified [Object] CisSystem from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] CisSystem from the system.
NOTE: The Get-CisSystem CmdLet must be used to get the desired [Object] CisSystem to delete

.PARAMETER CisSystem
Mandatory parameters to specify the [Object] CisSystem to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] CisSystem

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-CisSystem.ps1 -CisSystem (Get-CisSystem -Name "W7System")
#>
function global:Remove-CisSystem
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisSystem(s) to delete.")]
		[System.Object]$CisSystem,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Force
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
		$Uri = ("https://{0}/ServerManage/DeleteResource" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the CisSystem ID
			if ([System.String]::IsNullOrEmpty($CisSystem.ID))
			{
				Throw "Cannot get ResourceID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $CisSystem.ID

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
					Write-Debug ("System {0} deleted." -f $CisSystem.Name)
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
			if ($_.Exception -match "System has active accounts")
            {
                # System has active accounts
                if ($Force.IsPresent)
                {
					Write-Debug ("Delete account(s) for System {0}." -f $CisSystem.Name)
                    # Delete Accounts from System
                    Get-CisAccount -CisSystem $CisSystem | Remove-CisAccount
                    # Call Remove System again
                    Remove-CisSystem -CisSystem $CisSystem
					# Success
					Write-Debug ("System {0} deleted." -f $CisSystem.Name)
                }
                else
                {
                    # Unhandled exception
                    Throw $_.Exception
                }
            }
            else
            {
                # Unhandled exception
                Throw $_.Exception
            }
		}
	}
	
	# Post-Pipeline steps
	end
	{
		try
		{
			# Success
			Write-Debug "Resource(s) deleted."
		}
		catch
		{
			Throw $_.Exception   
		}
	}
}
