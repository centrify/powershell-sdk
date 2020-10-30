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
This Cmdlet adds specific members to an existing Set.

.DESCRIPTION
This Cmdlet adds one or more member(s) of the same object type to an existing Set of the same object type.
You can add System(s) to a Set of System but not any other objects types, neither you can add System(s) to a Set of any objects other than Systems.
This goes for all Set object types existing in the PAS Portal.

.PARAMETER PASCollection
Mandatory PASCollection to add member(s) to.

.PARAMETER PASSystem
Optional PASSystem to add as a member.

.PARAMETER PASAccount
Optional PASAccount to add as a member.

.PARAMETER PASSecret
Optional PASSecret to add as a member.

.PARAMETER PASDomain
Optional PASDomain to add as a member.

.PARAMETER PASDatabase
Optional PASDatabase to add as a member.

.PARAMETER PASService
Optional PASService to add as a member.

.INPUTS 
One of [PASSystem], [PASAccount], [PASSecret], [PASDomain], [PASDatabase] or [PASService]

.OUTPUTS

.EXAMPLE
C:\PS> Add-CentrifySetMember -PASCollection (Get-VaultSystemSet -Name "Unix Infrastructure Systems") -VaultSystem (Get-VaultSystem -Name "UnixSystem1") 
Adds a system named 'UnixSystem1' the specified PASCollection of object type PASSystemCollection using parameter PASSystem

.EXAMPLE
C:\PS> Get-VaultAccount -User "Administrator" -System (Get-VaultSystem -Name "WIN-SQLDB01") | Add-CentrifySetMember -PASCollection (Get-VaultAccountSet -Name "Windows Admin Accounts")
This Cmdlet adds account named 'Administrator' from system 'WIN-SQLDB01' to the specified PASCollection of type PASAccountCollection using input objects from pipeline
#>
function global:Add-CentrifySetMember
{
	[CmdletBinding(DefaultParameterSetName = "System")]
	param
	(
		[Parameter(Mandatory = $true)]
		[Parameter(ParameterSetName = "System")]
		[Parameter(ParameterSetName = "Account")]
		[Parameter(ParameterSetName = "Secret")]
		[Parameter(ParameterSetName = "Domain")]
		[Parameter(ParameterSetName = "Database")]
		[Parameter(ParameterSetName = "Service")]
		[System.Object]$PASCollection,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "System")]
		[System.Object]$VaultSystem,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Account")]
		[System.Object]$VaultAccount,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Secret")]
		[System.Object]$VaultSecret,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Domain")]
		[System.Object]$VaultDomain,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Database")]
		[System.Object]$VaultDatabase,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Service")]
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
		    $JsonQuery.ID 	= $PASCollection.ID
		    $JsonQuery.Add	= @($Member)
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

