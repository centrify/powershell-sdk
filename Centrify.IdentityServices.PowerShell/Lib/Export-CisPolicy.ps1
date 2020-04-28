################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
Work In Progress
#>
function global:Export-CisPolicy
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the policy name to export.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the policy export file path (Export is in JSON format).")]
		[System.String]$File = ("./{0}.pol" -f $Name)
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

		# Setup variable for query
		$Uri = ("https://{0}/Policy/GetPolicyBlock" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.Name = ("/Policy/{0}" -f $Name)

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
			# Success export policy in XML format
            $WebResponseResult.Result | ConvertTo-Json | Out-File -FilePath $SaveAs
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
