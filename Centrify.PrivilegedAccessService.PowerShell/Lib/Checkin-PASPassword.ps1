###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet supports ability to checkin PASPassword. 

.DESCRIPTION
This CMDlet supports ability to checkin a previoulsy checked-out PASPassword using either a PASCheckout object obtained previously using the Checkout-PASPassword Cmdlet, or by specifying the CheckoutID string (COID).

.PARAMETER PASCheckout
Optional PASCheckout object

.PARAMETER CheckoutID
Optional CheckoutID (can be retrieved from [PASCheckout] object)

.INPUTS
[PASCheckout]

.OUTPUTS

.EXAMPLE
C:\PS> $CheckoutPASPassword = Checkout-PASPassword -PASAccount (Get-PASAccount -PASResource (Get-PASSystem -Name "PAScoRouter01" -User "admin")
C:\PS> $CheckoutPASPassword
COID                                                                                    Password                                                                               
----                                                                                    --------                                                                               
8338438d-d40b-41a3-b530-827244bcba1c                                                    Centr1fy
C:\PS> Checkin-PASPassword -PASCheckout $CheckoutPASPassword

This series of cmdlet checks out the password for account 'admin' on system 'PAScoRouter01', and then checks the password back in using the PASCheckout object obtained previously.

.EXAMPLE
C:\PS> Checkin-PASPassword -CheckoutID "8338438d-d40b-41a3-b530-827244bcba1c"
Checks password back in using the CheckoutID of the current live check.
#>
function global:Checkin-PASPassword
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[System.String]$PASCheckout,

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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/CheckinPassword" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		if (-not [System.String]::IsNullOrEmpty($PASCheckout))
		{
		    # Get COID from PASCheckout
            if (-not [System.String]::IsNullOrEmpty($PASCheckout.COID))
		    {
    		    $JsonQuery.ID = $PASCheckout.COID
		    }
            else
            {
                Throw "Cannot get COID from PASCheckout parameter."
            }
		}
		elseif (-not [System.String]::IsNullOrEmpty($CheckoutID))
		{
		    # Get COID from CheckoutID
   		    $JsonQuery.ID = $CheckoutID
		}
        else
        {
            Throw "COID must be provided either using PASCheckout or CheckoutID parameter."
        }
		$JsonQuery.RRFormat    = $true

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
