###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER Key

.INPUTS

.OUTPUTS
#>
function global:Get-PASTenantConfig
{
	param
	(
		[Parameter(Mandatory = $false)]
		[System.String]$Key
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
        $Uri = ("https://{0}/TenantConfig/GetAdvancedConfig" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Debug informations
		Write-Debug ("Uri= {0}" -f $CipQuery.Uri)
		Write-Debug ("Args= {0}" -f $Arguments)
		Write-Debug ("Json= {0}" -f $CipQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body "" -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Return Tenant Config
		    if (-not [System.String]::IsNullOrEmpty($Key))
            {
                # Return the requested key
                $WebResponseResult.Result.Results.Row | Select-Object -Property ID, Value | Where-Object { $_.ID -eq $Key }
            }
            else
            {
                # Return all key
                $WebResponseResult.Result.Results.Row | Select-Object -Property ID, Value | Sort-Object -Property ID
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
