###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> Remove-PASCollectionMember -PASCollection (Get-PASSystemCollection -Name "Unix Infrastructure Systems") 
This CmdLet gets specified PASSystemCollection and performs no action.

.EXAMPLE
C:\PS> Remove-PASCollectionMember -PASCollection (Get-PASSystemCollection -Name "Unix Infrastructure Systems") -PASSystem (Get-PASSystem -Name "UnixSystem1")
This CmdLet removes "UnixSystem1" system from the specified PASSystemCollection 

.EXAMPLE
C:\PS> Remove-PASCollectionMember -PASCollection (Get-PASAccountCollection -Name "Ocean") -PASAccount (Get-PASAccount -PASResource * -User "bcrab@cps.centrify.net")
Removes "bcrab@cps.ocean.net" user from the specified PASAccountCollection
#>
function global:Remove-PASCollectionMember
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
		[System.Object]$PASSystem,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Account", HelpMessage = "Specify the PASAccount to remove as a member.")]
		[System.Object]$PASAccount,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Secret", HelpMessage = "Specify the PASSecret to remove as a member.")]
		[System.Object]$PASSecret,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Domain", HelpMessage = "Specify the PASDomain to remove as a member.")]
		[System.Object]$PASDomain,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Database", HelpMessage = "Specify the PASDatabase to remove as a member.")]
		[System.Object]$PASDatabase,

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
	
	# Get current connection to the Centrify Cloud Platform
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/Collection/UpdateMembersCollection" -f $PASConnection.PodFqdn)
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
            if (-not [System.String]::IsNullOrEmpty($PASSystem))
            {
                # Remove System
                $Member.Key 		= $PASSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "Server"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASAccount))
            {
                # Remove Account
                $Member.Key 		= $PASAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultAccount"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASSecret))
            {
                # Remove Secret
                $Member.Key 		= $PASSecret.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "DataVault"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASDatabase))
            {
                # Remove System
                $Member.Key 		= $PASSystem.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDatabase"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASDomain))
            {
                # Remove Account
                $Member.Key 		= $PASAccount.ID
                $Member.MemberType 	= "Row"
                $Member.Table 		= "VaultDomain"
            }
            elseif (-not [System.String]::IsNullOrEmpty($PASService))
            {
                # Remove Secret
                $Member.Key 		= $PASSecret.ID
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
