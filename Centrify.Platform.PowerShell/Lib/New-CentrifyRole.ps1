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
This CMDlet supports ability to create a new PASRole

.DESCRIPTION
This CMDlet supports ability to create a new PASRole

.PARAMETER Name
Mandatory string parameter used to specify the Display Name for the User to create.

.PARAMETER Description
Optional string parameter used to specify the Description for the User to create.

.INPUTS
This CmdLet takes no object inputs

.OUTPUTS
Returns the newly created Role object on success. Returns failure message on failure.

.EXAMPLE
C:\PS> New-CentrifyRole -Name "Privilege Access User" -Description "Members of this Role have access to the Privilege Access User Portal"
Create a new Role with a name and description
#>
function global:New-CentrifyRole
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Name for the Role to create.")]
		[System.String]$Name,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Description for the Role to create.")]
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

		# Setup variable for query
		$Uri = ("https://{0}/saasManage/StoreRole" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.Name 	    = $Name
    	$JsonQuery.Description	= $Description

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
		Write-Debug ("Json= {0}" -f $Json)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Role
			return (Get-CentrifyRole -Name $Name)
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
