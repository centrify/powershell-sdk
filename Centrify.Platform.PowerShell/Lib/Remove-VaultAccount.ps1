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
This Cmdlet removes the specified [Object] PASAccount from the system.

.DESCRIPTION
This Cmdlet removes the specified [Object] PASAccount from the system.
NOTE: The Get-VaultAccount CmdLet must be used to get the desired [Object] PASAccount to delete

.PARAMETER PASAccount
Mandatory parameters to specify the [Object] PASAccount to remove

.INPUTS
This CmdLet takes as input 1 required parameter: [Object] PASAccount

.OUTPUTS
This Cmdlet returns the result of the operation

.EXAMPLE
C:\PS> Remove-VaultAccount -VaultAccount (Get-VaultAccount -VaultSystem (Get-VaultSystem -Name "sarita-test2") -User "abc")
#>
function global:Remove-VaultAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASAccount(s) to delete.")]
		[System.Object]$VaultAccount,

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
		
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteAccount" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the PASAccount ID
			if ([System.String]::IsNullOrEmpty($VaultAccount.ID))
			{
				Throw "Cannot get AccountID from given parameter."
			}
			else
			{
			    # Format Json query
			    $JsonQuery = @{}
			    $JsonQuery.ID = $VaultAccount.ID

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
					Write-Debug ("Account {0} deleted." -f $VaultAccount.Name)
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
