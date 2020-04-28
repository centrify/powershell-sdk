################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet removes specific members from a [Object] CisCollection.

.DESCRIPTION
This CMDlet removes specific members from a [Object] CisCollection.

NOTE: The appropriate Get-Cis[Account][System][CisSecret][CisDomain][CisDatabase]Collection, 
and Get-Cis[Account][System][CisSecret][CisDomain][CisDatabase] CmdLet must be used to get the desired Cis object to remove.

.PARAMETER CisCollection
Mandatory parameter representing [Object] CisRole object for modify.
NOTE: The appropriate Get-Cis[Account][System][CisSecret][CisDomain][CisDatabase]Collection, 

.PARAMETER CisSystem
Optional parameter representing the [Object]CisSystem to remove as a member.

.PARAMETER CisAccount
Optional parameter representing the [Object]CisAccount to remove as a member.

.PARAMETER CisSecret
Optional parameter representing the [Object]CisSecret to remove as a member.

.PARAMETER CisDomain
Optional parameter representing the [Object]CisDomain to remove as a member.

.PARAMETER CisDatabase
Optional parameter representing the [Object] CisDatabase to remove as a member.

.PARAMETER CisService
Optional parameter representing the [Object] CisService to remove as a member.

.INPUTS 
This CmdLet takes as input the required parameters: [Object] CisCollection

This CmdLet takes as input the following optional parameters: 
[Object] CisSystem, [Object] CisAccount, [Object] CisSecret, 
[Object] CisDomain, [Object] CisDatabase, [Object] CisService

.OUTPUTS
This Cmdlet return nothing in case of success. Returns failure message in case of failure.

.EXAMPLE
C:\PS> Remove-CisCollectionMember -CisCollection (Get-CisSystemCollection -Name "Unix Infrastructure Systems") 
This CmdLet gets specified CisSystemCollection and performs no action.

.EXAMPLE
C:\PS> Remove-CisCollectionMember -CisCollection (Get-CisSystemCollection -Name "Unix Infrastructure Systems") -CisSystem (Get-CisSystem -Name "UnixSystem1")
This CmdLet removes "UnixSystem1" system from the specified CisSystemCollection 

.EXAMPLE
C:\PS> Remove-CisCollectionMember -CisCollection (Get-CisAccountCollection -Name "Ocean") -CisAccount (Get-CisAccount -CisResource * -User "bcrab@cps.centrify.net")
Removes "bcrab@cps.ocean.net" user from the specified CisAccountCollection
#>
function global:Remove-CisCollectionMember
{
	[CmdletBinding(DefaultParameterSetName = "System")]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the CisCollection to add the member to")]
		[Parameter(ParameterSetName = "System")]
		[Parameter(ParameterSetName = "Account")]
		[Parameter(ParameterSetName = "Secret")]
		[Parameter(ParameterSetName = "Domain")]
		[Parameter(ParameterSetName = "Database")]
		[Parameter(ParameterSetName = "Service")]
		[System.Object]$CisCollection,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "System", HelpMessage = "Specify the CisSystem to remove as a member.")]
		[System.Object]$CisSystem,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Account", HelpMessage = "Specify the CisAccount to remove as a member.")]
		[System.Object]$CisAccount,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Secret", HelpMessage = "Specify the CisSecret to remove as a member.")]
		[System.Object]$CisSecret,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Domain", HelpMessage = "Specify the CisDomain to remove as a member.")]
		[System.Object]$CisDomain,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Database", HelpMessage = "Specify the CisDatabase to remove as a member.")]
		[System.Object]$CisDatabase,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Service", HelpMessage = "Specify the CisService to remove as a member.")]
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
		    $JsonQuery.ID 		= $CisCollection.ID
		    $JsonQuery.Remove	= @($Member)
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
