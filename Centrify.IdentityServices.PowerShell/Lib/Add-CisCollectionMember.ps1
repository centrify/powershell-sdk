################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet adds specific members to an existing Set.

.DESCRIPTION
This Cmdlet adds one or more member(s) of the same object type to an existing Set of the same object type.
You can add System(s) to a Set of System but not any other objects types, neither you can add System(s) to a Set of any objects other than Systems.
This goes for all Set object types existing in the PAS Portal.

.PARAMETER CisCollection
Mandatory CisCollection to add member(s) to.

.PARAMETER CisSystem
Optional CisSystem to add as a member.

.PARAMETER CisAccount
Optional CisAccount to add as a member.

.PARAMETER CisSecret
Optional CisSecret to add as a member.

.PARAMETER CisDomain
Optional CisDomain to add as a member.

.PARAMETER CisDatabase
Optional CisDatabase to add as a member.

.PARAMETER CisService
Optional CisService to add as a member.

.INPUTS 
One of [CisSystem], [CisAccount], [CisSecret], [CisDomain], [CisDatabase] or [CisService]

.OUTPUTS

.EXAMPLE
C:\PS> Add-CisCollectionMember -CisCollection (Get-CisSystemCollection -Name "Unix Infrastructure Systems") -CisSystem (Get-CisSystem -Name "UnixSystem1")
Adds a system named 'UnixSystem1' the specified CisCollection of object type CisSystemCollection using parameter CisSystem

.EXAMPLE
C:\PS> Get-CisAccount -User "Administrator" -CisSystem (Get-CisSystem -Name "WIN-SQLDB01") | Add-CisCollectionMember -CisCollection (Get-CisAccountCollection -Name "Windows Admin Accounts")
This Cmdlet adds account named 'Administrator' from system 'WIN-SQLDB01' to the specified CisCollection of type CisAccountCollection using input objects from pipeline
#>
function global:Add-CisCollectionMember
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
		[System.Object]$CisCollection,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "System")]
		[System.Object]$CisSystem,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Account")]
		[System.Object]$CisAccount,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Secret")]
		[System.Object]$CisSecret,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Domain")]
		[System.Object]$CisDomain,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Database")]
		[System.Object]$CisDatabase,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Service")]
		[System.Object]$CisService
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
	
	# Get current connection to the Centrify Cloud Platform
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/Collection/UpdateMembersCollection" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Adding target information
		if ([System.String]::IsNullOrEmpty($CisCollection.ID))
		{
			Throw "Cannot get SetID from given parameter."
		}
		else
		{
            # Validate Member
            $Member = @{}
            if (-not [System.String]::IsNullOrEmpty($CisSystem))
            {
                # Remove System
                $Member.Key 		= $CisSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "Server"
            }
            elseif (-not [System.String]::IsNullOrEmpty($CisAccount))
            {
                # Remove Account
                $Member.Key 		= $CisAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultAccount"
            }
            elseif (-not [System.String]::IsNullOrEmpty($CisSecret))
            {
                # Remove Secret
                $Member.Key 		= $CisSecret.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "DataVault"
            }
            elseif (-not [System.String]::IsNullOrEmpty($CisDatabase))
            {
                # Remove System
                $Member.Key 		= $CisSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDatabase"
            }
            elseif (-not [System.String]::IsNullOrEmpty($CisDomain))
            {
                # Remove Account
                $Member.Key 		= $CisAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDomain"
            }
            elseif (-not [System.String]::IsNullOrEmpty($CisService))
            {
                # Remove Secret
                $Member.Key 		= $CisSecret.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "Subscriptions"
            }
            
            # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.ID 	= $CisCollection.ID
		    $JsonQuery.Add	= @($Member)
		}

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
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

