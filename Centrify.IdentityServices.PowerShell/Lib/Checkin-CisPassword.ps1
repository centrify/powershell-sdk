################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet supports ability to checkin CisPassword. 

.DESCRIPTION
This CMDlet supports ability to checkin a previoulsy checked-out CisPassword using either a CisCheckout object obtained previously using the Checkout-CisPassword Cmdlet, or by specifying the CheckoutID string (COID).

.PARAMETER CisCheckout
Optional CisCheckout object

.PARAMETER CheckoutID
Optional CheckoutID (can be retrieved from [CisCheckout] object)

.INPUTS
[CisCheckout]

.OUTPUTS

.EXAMPLE
C:\PS> $CheckoutCisPassword = Checkout-CisPassword -CisAccount (Get-CisAccount -CisResource (Get-CisSystem -Name "CiscoRouter01" -User "admin")
C:\PS> $CheckoutCisPassword
COID                                                                                    Password                                                                               
----                                                                                    --------                                                                               
8338438d-d40b-41a3-b530-827244bcba1c                                                    Centr1fy
C:\PS> Checkin-CisPassword -CisCheckout $CheckoutCisPassword

This series of cmdlet checks out the password for account 'admin' on system 'CiscoRouter01', and then checks the password back in using the CisCheckout object obtained previously.

.EXAMPLE
C:\PS> Checkin-CisPassword -CheckoutID "8338438d-d40b-41a3-b530-827244bcba1c"
Checks password back in using the CheckoutID of the current live check.
#>
function global:Checkin-CisPassword
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[System.String]$CisCheckout,

		[Parameter(Mandatory = $false)]
		[System.String]$CheckoutID
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
		$Uri = ("https://{0}/ServerManage/CheckinPassword" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		if (-not [System.String]::IsNullOrEmpty($CisCheckout))
		{
		    # Get COID from CisCheckout
            if (-not [System.String]::IsNullOrEmpty($CisCheckout.COID))
		    {
    		    $JsonQuery.ID = $CisCheckout.COID
		    }
            else
            {
                Throw "Cannot get COID from CisCheckout parameter."
            }
		}
		elseif (-not [System.String]::IsNullOrEmpty($CheckoutID))
		{
		    # Get COID from CheckoutID
   		    $JsonQuery.ID = $CheckoutID
		}
        else
        {
            Throw "COID must be provided either using CisCheckout or CheckoutID parameter."
        }
		$JsonQuery.RRFormat    = $true

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
			# Checkin return nothing in case of success
            Exit 0
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
