###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet supports ability to rotate password for a given PASAccount.

.DESCRIPTION
This Cmdlet supports ability to rotate password for a given PASAccount.

.PARAMETER PASAccount
Mandatory PASAccount.

.INPUTS
[PASAccount]

.OUTPUTS

.EXAMPLE
#>
function global:Rotate-PASPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$PASAccount		
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
		$Uri = ("https://{0}/ServerManage/RotatePassword" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}

		if (-not [System.String]::IsNullOrEmpty($PASAccount))
		{
			if ([System.String]::IsNullOrEmpty($PASAccount.ID))
			{
				Throw "Cannot get PASAccount ID from given parameter."
			}
			else
			{
				# Get PASAccount ID
				$JsonQuery.ID = $PASAccount.ID
			}
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
			# Valid Job success
            if ($WebResponseResult.Result.Success)
            {
                # Return nothing
                Exit 0
            }
            else
            {
		        # Job error
		        Throw $WebResponseResult.Result.Reason
            }
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
