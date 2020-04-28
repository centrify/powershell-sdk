################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet supports ability to update password on a specified CisAccount

.DESCRIPTION
This Cmdlet update the password on a specified CisAccount. 

.PARAMETER CisAccount 
Mandatory CisAccount to update the password from.

.PARAMETER Password
Mandatory password value to update to.

.INPUTS
[CisAccount]

.OUTPUTS

.EXAMPLE
C:\PS> Update-CisPassword -CisAccount (Get-CisAccount -User root -CisSystem (Get-CisSystem -Name "engcen6")) -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using parameter CisAccount

.EXAMPLE
C:\PS> Get-CisAccount -User root -CisSystem (Get-CisSystem -Name "engcen6") | Update-CisPassword -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Update-CisPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$CisAccount,
		
		[Parameter(Mandatory = $true)]
		[System.String]$Password		
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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Get the CisAccount ID
		if ([System.String]::IsNullOrEmpty($CisAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/UpdatePassword" -f $CisConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $CisAccount.ID
			$JsonQuery.Password = $Password

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
	}
	catch
	{
		Throw $_.Exception   
	}
}
