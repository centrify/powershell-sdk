###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet supports ability to checkout PASPassword on a specified PASAccount.
You can specify the Lifetime in minute (default value is 0, meaning that it will wait for manual checkin or default value of lifetime checkout set at tenant level).

.DESCRIPTION
This CMDlet supports ability to checkout PASPassword on a specified PASAccount. 

.PARAMETER PASAccount 
Mandatory PASAccount to checkout the password from.

.PARAMETER Lifetime
Optional Lifetime to use before checkin the password.

.PARAMETER Description
Optional Description to use for this checkout. 

.INPUTS

.OUTPUTS
[PASCheckout]

.EXAMPLE
C:\PS> Checkout-PASPassword -PASAccount (Get-PASAccount -User "root" -PASSystem (Get-PASSystem -Name "LNX-APP02"))
Checkout the 'root' password on system 'LNX-APP02' using the PASAccount parameter

.EXAMPLE
C:\PS> Get-PASAccount -User "oracle" -PASSystem (Get-PASSystem -Name "LNX-ORADB01") | Checkout-PASPassword -Lifetime 30 -Description "Need to patch Oracle database"
Checkout the 'oracle' password on system 'LNX-ORADB01' using the input object from pipeline and specifying a custom lifetime and a description giving the reason for the checkout.
#>
function global:Checkout-PASPassword
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[System.Object]$PASAccount,
		
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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Get the PASAccount ID
		if ([System.String]::IsNullOrEmpty($PASAccount.ID))
		{
			Throw "Cannot get AccountID from given parameter."
		}
		else
		{
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/CheckoutPassword" -f $PASConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$JsonQuery = @{}
			$JsonQuery.ID = $PASAccount.ID
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
			$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
