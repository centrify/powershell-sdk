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
This CMDlet removes specific members from a [Object] PASCollection.

.DESCRIPTION
This CMDlet removes specific members from a [Object] PASCollection.

NOTE: The appropriate Get-PAS[Account][System][PASSecret][PASDomain][PASDatabase]Collection, 
and Get-PAS[Account][System][PASSecret][PASDomain][PASDatabase] CmdLet must be used to get the desired PAS object to remove.

.PARAMETER PASCollection
Mandatory parameter representing [Object] PASRole object for modify.
NOTE: The appropriate Get-PAS[Account][System][PASSecret][PASDomain][PASDatabase]Collection, 

.PARAMETER PASSystem
Optional parameter representing the [Object]PASSystem to remove as a member.

.PARAMETER PASAccount
Optional parameter representing the [Object]PASAccount to remove as a member.

.PARAMETER PASSecret
Optional parameter representing the [Object]PASSecret to remove as a member.

.PARAMETER PASDomain
Optional parameter representing the [Object]PASDomain to remove as a member.

.PARAMETER PASDatabase
Optional parameter representing the [Object] PASDatabase to remove as a member.

.PARAMETER PASService
Optional parameter representing the [Object] PASService to remove as a member.

.INPUTS 
This CmdLet takes as input the required parameters: [Object] PASCollection

This CmdLet takes as input the following optional parameters: 
[Object] PASSystem, [Object] PASAccount, [Object] PASSecret, 
[Object] PASDomain, [Object] PASDatabase, [Object] PASService

.OUTPUTS
This Cmdlet return nothing in case of success. Returns failure message in case of failure.

.EXAMPLE
C:\PS> Remove-CentrifySetMember -PASCollection (Get-VaultSystemSet -Name "Unix Infrastructure Systems") 
This CmdLet gets specified PASSystemCollection and performs no action.

.EXAMPLE
C:\PS> Remove-CentrifySetMember -PASCollection (Get-VaultSystemSet -Name "Unix Infrastructure Systems") -System (Get-VaultSystem -Name "UnixSystem1")
This CmdLet removes "UnixSystem1" system from the specified PASSystemCollection 

.EXAMPLE
C:\PS> Remove-CentrifySetMember -PASCollection (Get-VaultAccountSet -Name "Ocean") -Account (Get-VaultAccount -PASResource * -User "bcrab@cps.centrify.net")
Removes "bcrab@cps.ocean.net" user from the specified PASAccountCollection
#>
function global:Remove-CentrifySetMember
{
	[CmdletBinding(DefaultParameterSetName = "System")]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the PASCollection to add the member to")]
		[Parameter(ParameterSetName = "System")]
		[Parameter(ParameterSetName = "Account")]
		[Parameter(ParameterSetName = "Secret")]
		[Parameter(ParameterSetName = "Domain")]
		[Parameter(ParameterSetName = "Database")]
		[Parameter(ParameterSetName = "Service")]
		[System.Object]$PASCollection,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "System", HelpMessage = "Specify the PASSystem to remove as a member.")]
		[System.Object]$VaultSystem,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Account", HelpMessage = "Specify the PASAccount to remove as a member.")]
		[System.Object]$VaultAccount,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Secret", HelpMessage = "Specify the PASSecret to remove as a member.")]
		[System.Object]$VaultSecret,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Domain", HelpMessage = "Specify the PASDomain to remove as a member.")]
		[System.Object]$VaultDomain,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Database", HelpMessage = "Specify the PASDatabase to remove as a member.")]
		[System.Object]$VaultDatabase,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Service", HelpMessage = "Specify the PASService to remove as a member.")]
		[System.Object]$PASService
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
		$Uri = ("https://{0}/Collection/UpdateMembersCollection" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Adding target information
		if ([System.String]::IsNullOrEmpty($PASCollection.ID))
		{
			Throw "Cannot get SetID from given parameter."
		}
		else
		{
            # Validate Member
            $Member = @{}
            if (-not [System.String]::IsNullOrEmpty($VaultSystem))
            {
                # Remove System
                $Member.Key 		= $VaultSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "Server"
            }
            elseif (-not [System.String]::IsNullOrEmpty($VaultAccount))
            {
                # Remove Account
                $Member.Key 		= $VaultAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultAccount"
            }
            elseif (-not [System.String]::IsNullOrEmpty($VaultSecret))
            {
                # Remove Secret
                $Member.Key 		= $VaultSecret.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "DataVault"
            }
            elseif (-not [System.String]::IsNullOrEmpty($VaultDatabase))
            {
                # Remove System
                $Member.Key 		= $VaultSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDatabase"
            }
            elseif (-not [System.String]::IsNullOrEmpty($VaultDomain))
            {
                # Remove Account
                $Member.Key 		= $VaultAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDomain"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASService))
            {
                # Remove Secret
                $Member.Key 		= $VaultSecret.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "Subscriptions"
            }
            
            # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID 		= $PASCollection.ID
		    $JsonQuery.Remove	= @($Member)
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
			# Success
            return
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
