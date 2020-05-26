###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> New-PASRole -Name "Privilege Access User" -Description "Members of this Role have access to the Privilege Access User Portal"
Create a new Role with a name and description
#>
function global:New-PASRole
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
		# Get current connection to the Centrify Cloud Platform
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Setup variable for query
		$Uri = ("https://{0}/saasManage/StoreRole" -f $PASConnection.PodFqdn)
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Role
			return (Get-PASRole -Name $Name)
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
