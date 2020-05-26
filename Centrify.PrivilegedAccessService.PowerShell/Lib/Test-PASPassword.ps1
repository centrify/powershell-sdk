###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet supports ability to verify credentials for a specified PASAccount.

.DESCRIPTION
This Cmdlet verify credentials and will return information on a specified PASAccount. 
NOTE: The CmdLet expect to receive a PASAccount object from parameter or pipeline, which can be returned by using Get-PASAccount Cmdlet

.PARAMETER PASAccount
Mandatory PASAccount object

.INPUTS
[PASAccount]

.OUTPUTS
[System.Object]

.EXAMPLE
C:\PS> Test-PASPassword -PASAccount (Get-PASAccount -User root -PASSystem (Get-PASSystem -Name "engcen6"))
Verify credentials for vaulted account 'root' on system named 'engcen6' using PASAccount parameter

.EXAMPLE
C:\PS> Get-PASAccount -User root -PASSystem (Get-PASSystem -Name "engcen6") | Test-PASPassword
Verify credentials for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Test-PASPassword
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
		$Uri = ("https://{0}/ServerManage/CheckAccountHealth" -f $PASConnection.PodFqdn)
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
			# Get All Account Informations

		    # Setup variable for query
		    $Uri = ("https://{0}/ServerManage/GetAllAccountInformation" -f $PASConnection.PodFqdn)
		    $ContentType = "application/json" 
		    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		    # Set Json query
		    $JsonQuery = @{}

			# Get PASAccount ID
			$JsonQuery.ID = $PASAccount.ID

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
			    # Return Account Informations
                return $WebResponseResult.Result.VaultAccount.Row | Select-Object -Property Name, Healthy, LastHealthCheck, User , ID, IsManaged, UserDisplayName, Description, DatabaseID, DomainID, HealthError, LastChange, MissingPassword
		    }
		    else
		    {
			    # Query error
			    Throw $WebResponseResult.Message
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
