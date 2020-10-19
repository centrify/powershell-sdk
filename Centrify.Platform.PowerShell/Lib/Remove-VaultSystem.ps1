###########################################################################################
# Centrify Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT centrify.com
# Release  : 21/01/2016
# Copyright: (c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

<#
.SYNOPSIS
This Cmdlet removes the specified [Object] PASSystem from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] PASSystem from the system.
NOTE: The Get-VaultSystem CmdLet must be used to get the desired [Object] PASSystem to delete

.PARAMETER PASSystem
Mandatory parameters to specify the [Object] PASSystem to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] PASSystem

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-VaultSystem.ps1 -System (Get-VaultSystem -Name "W7System")
#>
function global:Remove-VaultSystem
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASSystem(s) to delete.")]
		[System.Object]$VaultSystem,

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
		
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteResource" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the PASSystem ID
			if ([System.String]::IsNullOrEmpty($VaultSystem.ID))
			{
				Throw "Cannot get ResourceID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $VaultSystem.ID

                # Build Json query
			    $Json = $JsonQuery | ConvertTo-Json 
	
				# Debug informations
				Write-Debug ("Uri= {0}" -f $Uri)
				Write-Debug ("Json= {0}" -f $Json)
				
				# Connect using RestAPI
				$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
				$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
				if ($WebResponseResult.Success)
				{
					# Success
					Write-Debug ("System {0} deleted." -f $VaultSystem.Name)
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
					Write-Debug ("Delete account(s) for System {0}." -f $VaultSystem.Name)
                    # Delete Accounts from System
                    Get-VaultAccount -System $VaultSystem | Remove-VaultAccount
                    # Call Remove System again
                    Remove-VaultSystem -System $VaultSystem
					# Success
					Write-Debug ("System {0} deleted." -f $VaultSystem.Name)
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
