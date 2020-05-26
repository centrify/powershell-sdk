###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet supports ability to update password on a specified PASAccount

.DESCRIPTION
This Cmdlet update the password on a specified PASAccount. 

.PARAMETER PASAccount 
Mandatory PASAccount to update the password from.

.PARAMETER Password
Mandatory password value to update to.

.INPUTS
[PASAccount]

.OUTPUTS

.EXAMPLE
C:\PS> Update-PASPassword -PASAccount (Get-PASAccount -User root -PASSystem (Get-PASSystem -Name "engcen6")) -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using parameter PASAccount

.EXAMPLE
C:\PS> Get-PASAccount -User root -PASSystem (Get-PASSystem -Name "engcen6") | Update-PASPassword -Password "NewPassw0rd!"
Update password for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Update-PASPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$PASAccount,
		
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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Get the PASAccount ID
		if ([System.String]::IsNullOrEmpty($PASAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/UpdatePassword" -f $PASConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $PASAccount.ID
			$JsonQuery.Password = $Password

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
	}
	catch
	{
		Throw $_.Exception   
	}
}
