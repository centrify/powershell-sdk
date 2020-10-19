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
This Cmdlet supports ability to update password on a specified PASAccount

.DESCRIPTION
This Cmdlet update the password on a specified PASAccount. 

.PARAMETER PASAccount 
Mandatory PASAccount to update the password from.

.PARAMETER Password
Mandatory password value to update to.

.INPUTS
[PASAccount]

.OUTPUTS

.EXAMPLE
C:\PS> Set-VaultPassword -Account (Get-VaultAccount -User root -System (Get-VaultSystem -Name "engcen6")) -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using parameter PASAccount

.EXAMPLE
C:\PS> Get-VaultAccount -User root -System (Get-VaultSystem -Name "engcen6") | Set-VaultPassword -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Set-VaultPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$VaultAccount,
		
		[Parameter(Mandatory = $true)]
		[System.String]$Password		
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
	
	try
	{	
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Get the PASAccount ID
		if ([System.String]::IsNullOrEmpty($VaultAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/UpdatePassword" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $VaultAccount.ID
			$JsonQuery.Password = $Password

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
				# Success return nothing
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
