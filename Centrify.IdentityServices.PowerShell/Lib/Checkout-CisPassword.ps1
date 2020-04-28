################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet supports ability to checkout CisPassword on a specified CisAccount.
You can specify the Lifetime in minute (default value is 0, meaning that it will wait for manual checkin or default value of lifetime checkout set at tenant level).

.DESCRIPTION
This CMDlet supports ability to checkout CisPassword on a specified CisAccount. 

.PARAMETER CisAccount 
Mandatory CisAccount to checkout the password from.

.PARAMETER Lifetime
Optional Lifetime to use before checkin the password.

.PARAMETER Description
Optional Description to use for this checkout. 

.INPUTS

.OUTPUTS
[CisCheckout]

.EXAMPLE
C:\PS> Checkout-CisPassword -CisAccount (Get-CisAccount -User "root" -CisSystem (Get-CisSystem -Name "LNX-APP02"))
Checkout the 'root' password on system 'LNX-APP02' using the CisAccount parameter

.EXAMPLE
C:\PS> Get-CisAccount -User "oracle" -CisSystem (Get-CisSystem -Name "LNX-ORADB01") | Checkout-CisPassword -Lifetime 30 -Description "Need to patch Oracle database"
Checkout the 'oracle' password on system 'LNX-ORADB01' using the input object from pipeline and specifying a custom lifetime and a description giving the reason for the checkout.
#>
function global:Checkout-CisPassword
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[System.Object]$CisAccount,
		
		[Parameter(Mandatory = $false)]
		[System.Int32]$Lifetime = 0,

		[Parameter(Mandatory = $false)]
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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Get the CisAccount ID
		if ([System.String]::IsNullOrEmpty($CisAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/CheckoutPassword" -f $CisConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $CisAccount.ID
			if ($Lifetime)
			{
				$JsonQuery.Lifetime = $Lifetime
			}
			if (-not [System.String]::IsNullOrEmpty($Description))
			{
				$JsonQuery.Description = $Description
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
				# Success return the Password
				return $WebResponseResult.Result
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
