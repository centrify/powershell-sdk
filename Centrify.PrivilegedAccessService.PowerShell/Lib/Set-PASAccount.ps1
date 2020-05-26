###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> Set-PASAccount -PASAccount (Get-PASAccount -User "root" -PASResource (Get-PASSystem "RedHat7")) -Description "System Account"
Update the description field for the account 'root' on system 'RedHat7' using the PASAccount parameter.

.EXAMPLE
C:\PS> Get-PASAccount -User "sa" -PASDatabase (Get-PASDatabase "WIN-SQLDB01\AUDIT")) | Set-PASAccount -IsManaged $true
Enable password management for the 'sa' on database 'WIN-SQLDB01\AUDIT' using the input pobject from pipeline.
#> 
function global:Set-PASAccount
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$PASAccount,

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
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Get the PASSystem ID
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateAccount" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID 			= $PASAccount.ID
		$JsonQuery.User 		= $PASAccount.User
		$JsonQuery.Description	= $PASAccount.Description
		$JsonQuery.IsManaged	= $PASAccount.IsManaged
		$JsonQuery.Host 		= $PASAccount.ServerID
		$JsonQuery.DomainID 	= $PASAccount.DomainID
		$JsonQuery.DatabaseID	= $PASAccount.DatabaseID

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
