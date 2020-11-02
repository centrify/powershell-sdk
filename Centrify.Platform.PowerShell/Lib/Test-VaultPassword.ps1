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
This Cmdlet supports ability to verify credentials for a specified PASAccount.

.DESCRIPTION
This Cmdlet verify credentials and will return information on a specified PASAccount. 
NOTE: The CmdLet expect to receive a PASAccount object from parameter or pipeline, which can be returned by using Get-VaultAccount Cmdlet

.PARAMETER PASAccount
Mandatory PASAccount object

.INPUTS
[PASAccount]

.OUTPUTS
[System.Object]

.EXAMPLE
C:\PS> Test-VaultPassword -VaultAccount (Get-VaultAccount -User root -VaultSystem (Get-VaultSystem -Name "engcen6"))
Verify credentials for vaulted account 'root' on system named 'engcen6' using PASAccount parameter

.EXAMPLE
C:\PS> Get-VaultAccount -User root -VaultSystem (Get-VaultSystem -Name "engcen6") | Test-VaultPassword
Verify credentials for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Test-VaultPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$VaultAccount		
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

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/CheckAccountHealth" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}

		if (-not [System.String]::IsNullOrEmpty($VaultAccount))
		{
			if ([System.String]::IsNullOrEmpty($VaultAccount.ID))
			{
				Throw "Cannot get PASAccount ID from given parameter."
			}
			else
			{
				# Get PASAccount ID
				$JsonQuery.ID = $VaultAccount.ID
			}
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
			# Get All Account Informations

		    # Setup variable for query
		    $Uri = ("https://{0}/ServerManage/GetAllAccountInformation" -f $PlatformConnection.PodFqdn)
		    $ContentType = "application/json" 
		    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		    # Set Json query
		    $JsonQuery = @{}

			# Get PASAccount ID
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
			    # Return Account Informations
                return $WebResponseResult.Result.VaultAccount.Row | Select-Object -Property Name, Healthy, LastHealthCheck, User , ID, IsManaged, UserDisplayName, Description, DatabaseID, DomainID, HealthError, LastChange, MissingPassword
		    }
		    else
		    {
			    # Query error
			    Throw $WebResponseResult.Message
		    }

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
