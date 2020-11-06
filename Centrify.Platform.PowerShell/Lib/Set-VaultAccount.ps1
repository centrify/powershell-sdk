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
This Cmdlet update an existing PASAccount. 

.DESCRIPTION
This Cmdlet update an existing PASAccount to either a specified PASResource, PASDomain, PASDatabase. 

This CmdLet can be used to update the following Optional values: "User","Description", "isManaged"

.PARAMETER PASAccount
Mandatory PASAccount to update. 

.PARAMETER User
Optional Username parameter to change account name. 

.PARAMETER Description
Optional Description for this account.

.PARAMETER isManaged
Optional IsManaged boolean flag to specify whether account password should be managed or not.

.INPUTS
[PASAccount]

.OUTPUTS

.EXAMPLE
C:\PS> Set-VaultAccount -VaultAccount (Get-VaultAccount -User "root" -VaultSystem (Get-VaultSystem "RedHat7")) -Description "System Account"
Update the description field for the account 'root' on system 'RedHat7' using the VaultAccount parameter.

.EXAMPLE
C:\PS> Get-VaultAccount -User "sa" -Database (Get-VaultDatabase "WIN-SQLDB01\AUDIT")) | Set-VaultAccount -IsManaged $true
Enable password management for the 'sa' on database 'WIN-SQLDB01\AUDIT' using the input pobject from pipeline.
#> 
function global:Set-VaultAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$VaultAccount,

		[Parameter(Mandatory = $false)]
		[System.String]$User,
		
		[Parameter(Mandatory = $false)]
		[System.String]$Description,

		[Parameter(Mandatory = $false)]
		[System.Boolean]$IsManaged
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
		# Get the PASSystem ID
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateAccount" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID 			= $VaultAccount.ID
		$JsonQuery.User 		= $VaultAccount.User
		$JsonQuery.Description	= $VaultAccount.Description
		$JsonQuery.IsManaged	= $VaultAccount.IsManaged
		$JsonQuery.Host 		= $VaultAccount.ServerID
		$JsonQuery.DomainID 	= $VaultAccount.DomainID
		$JsonQuery.DatabaseID	= $VaultAccount.DatabaseID

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
