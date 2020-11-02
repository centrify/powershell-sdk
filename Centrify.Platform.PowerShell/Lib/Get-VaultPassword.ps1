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
This CMDlet supports ability to checkout PASPassword on a specified PASAccount.
You can specify the Lifetime in minute (default value is 0, meaning that it will wait for manual checkin or default value of lifetime checkout set at tenant level).

.DESCRIPTION
This CMDlet supports ability to checkout PASPassword on a specified PASAccount. 

.PARAMETER PASAccount 
Mandatory PASAccount to checkout the password from.

.PARAMETER Lifetime
Optional Lifetime to use before checkin the password (default value is 5 minutes).

.PARAMETER Description
Optional Description to use for this checkout. 

.INPUTS

.OUTPUTS
[PASCheckout]

.EXAMPLE
C:\PS> Get-VaultPassword -VaultAccount (Get-VaultAccount -User "root" -VaultSystem (Get-VaultSystem -Name "LNX-APP02"))
Checkout the 'root' password on system 'LNX-APP02' using the PASAccount parameter

.EXAMPLE
C:\PS> Get-VaultAccount -User "oracle" -VaultSystem (Get-VaultSystem -Name "LNX-ORADB01") | Get-VaultPassword -Lifetime 30 -Description "Need to patch Oracle database"
Checkout the 'oracle' password on system 'LNX-ORADB01' using the input object from pipeline and specifying a custom lifetime and a description giving the reason for the checkout.
#>
function global:Get-VaultPassword
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[System.Object]$VaultAccount,
		
		[Parameter(Mandatory = $false)]
		[System.Int32]$Lifetime = 5,

		[Parameter(Mandatory = $false)]
		[System.String]$Description		
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
			$Uri = ("https://{0}/ServerManage/CheckoutPassword" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $VaultAccount.ID
			if ($Lifetime)
			{
				$JsonQuery.Lifetime = $Lifetime
			}
			if (-not [System.String]::IsNullOrEmpty($Description))
			{
				$JsonQuery.Description = $Description
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
				# Success return the Password
				return ($WebResponseResult.Result.Password).ToString()
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
