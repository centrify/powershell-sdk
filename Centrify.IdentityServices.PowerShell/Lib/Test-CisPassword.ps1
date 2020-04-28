################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet supports ability to verify credentials for a specified CisAccount.

.DESCRIPTION
This Cmdlet verify credentials and will return information on a specified CisAccount. 
NOTE: The CmdLet expect to receive a CisAccount object from parameter or pipeline, which can be returned by using Get-CisAccount Cmdlet

.PARAMETER CisAccount
Mandatory CisAccount object

.INPUTS
[CisAccount]

.OUTPUTS
[System.Object]

.EXAMPLE
C:\PS> Test-CisPassword -CisAccount (Get-CisAccount -User root -CisSystem (Get-CisSystem -Name "engcen6"))
Verify credentials for vaulted account 'root' on system named 'engcen6' using CisAccount parameter

.EXAMPLE
C:\PS> Get-CisAccount -User root -CisSystem (Get-CisSystem -Name "engcen6") | Test-CisPassword
Verify credentials for vaulted account 'root' on system named 'engcen6' using input object from pipe
#>
function global:Test-CisPassword
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[System.Object]$CisAccount		
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
		$Uri = ("https://{0}/ServerManage/CheckAccountHealth" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}

		if (-not [System.String]::IsNullOrEmpty($CisAccount))
		{
			if ([System.String]::IsNullOrEmpty($CisAccount.ID))
			{
				Throw "Cannot get CisAccount ID from given parameter."
			}
			else
			{
				# Get CisAccount ID
				$JsonQuery.ID = $CisAccount.ID
			}
		}

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
			# Get All Account Informations

		    # Setup variable for query
		    $Uri = ("https://{0}/ServerManage/GetAllAccountInformation" -f $CisConnection.PodFqdn)
		    $ContentType = "application/json" 
		    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		    # Set Json query
		    $JsonQuery = @{}

			# Get CisAccount ID
			$JsonQuery.ID = $CisAccount.ID

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
