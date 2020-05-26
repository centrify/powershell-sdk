###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet removes the specified [Object] PASSystem from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] PASSystem from the system.
NOTE: The Get-PASSystem CmdLet must be used to get the desired [Object] PASSystem to delete

.PARAMETER PASSystem
Mandatory parameters to specify the [Object] PASSystem to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] PASSystem

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-PASSystem.ps1 -PASSystem (Get-PASSystem -Name "W7System")
#>
function global:Remove-PASSystem
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASSystem(s) to delete.")]
		[System.Object]$PASSystem,

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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteResource" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the PASSystem ID
			if ([System.String]::IsNullOrEmpty($PASSystem.ID))
			{
				Throw "Cannot get ResourceID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $PASSystem.ID

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
					Write-Debug ("System {0} deleted." -f $PASSystem.Name)
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
					Write-Debug ("Delete account(s) for System {0}." -f $PASSystem.Name)
                    # Delete Accounts from System
                    Get-PASAccount -PASSystem $PASSystem | Remove-PASAccount
                    # Call Remove System again
                    Remove-PASSystem -PASSystem $PASSystem
					# Success
					Write-Debug ("System {0} deleted." -f $PASSystem.Name)
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
