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
This CMDlet removes the specified [Object] PASSecret from the system.

.DESCRIPTION
This CMDlet removes the specified [Object] PASSecret from the system.
NOTE: Get-VaultSecret Cmdlet must be used to acquire the desired [Object] PASSecret 

.PARAMETER PASSecret
Mandatory [Object] PASSecret  to remove.

.INPUTS
This Cmdlet takes the following mandatory inputs: [Object] PASSecret

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns error message in case of failure.

.EXAMPLE
PS: C:\PS\Remove-VaultSecret -VaultSecret (Get-VaultSecret -Filter "Secret")
This CmdLet removes the PASSecret named 'Secret' from the system
#>
function global:Remove-VaultSecret
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, HelpMessage = "Secret to remove.")]
		[System.Object]$VaultSecret
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/DeleteDataVaultItem" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        if ($VaultSecret -ne [void]$null)
        {
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID					= $VaultSecret.ID
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
	catch
	{
		Throw $_.Exception   
	}
}
