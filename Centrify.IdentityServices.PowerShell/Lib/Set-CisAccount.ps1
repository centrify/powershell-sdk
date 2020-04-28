################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet update an existing CisAccount. 

.DESCRIPTION
This Cmdlet update an existing CisAccount to either a specified CisResource, CisDomain, CisDatabase. 

This CmdLet can be used to update the following Optional values: "User","Description", "isManaged"

.PARAMETER CisAccount
Mandatory CisAccount to update. 

.PARAMETER User
Optional Username parameter to change account name. 

.PARAMETER Description
Optional Description for this account.

.PARAMETER isManaged
Optional IsManaged boolean flag to specify whether account password should be managed or not.

.INPUTS
[CisAccount]

.OUTPUTS

.EXAMPLE
C:\PS> Set-CisAccount -CisAccount (Get-CisAccount -User "root" -CisResource (Get-CisSystem "RedHat7")) -Description "System Account"
Update the description field for the account 'root' on system 'RedHat7' using the CisAccount parameter.

.EXAMPLE
C:\PS> Get-CisAccount -User "sa" -CisDatabase (Get-CisDatabase "WIN-SQLDB01\AUDIT")) | Set-CisAccount -IsManaged $true
Enable password management for the 'sa' on database 'WIN-SQLDB01\AUDIT' using the input pobject from pipeline.
#> 
function global:Set-CisAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$CisAccount,

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
	
	# Get current connection to the Centrify Cloud Platform
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Get the CisSystem ID
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateAccount" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID 			= $CisAccount.ID
		$JsonQuery.User 		= $CisAccount.User
		$JsonQuery.Description	= $CisAccount.Description
		$JsonQuery.IsManaged	= $CisAccount.IsManaged
		$JsonQuery.Host 		= $CisAccount.ServerID
		$JsonQuery.DomainID 	= $CisAccount.DomainID
		$JsonQuery.DatabaseID	= $CisAccount.DatabaseID

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
