###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves the specified PASSshKey from the system.

.DESCRIPTION
This CMDlet retrieves the specified PASSshKey from the system.
Note; The Get-PASSshKey cmdlet must be used to get the desired PASSshKey.

The following are required parameters: [Object] PASSshKey
The following are optional parameters: [String] KeyType

.PARAMETER PASSshKey
Mandatory parameter [Object] PASSshKey to retrieve.
Note; The Get-PASSshKey cmdlet must be used to get the desired PASSshKey.

.PARAMETER Path
Optional parameter [String] used to specify the key type to retrieve (default is Public Key).

.INPUTS
The following are required parameters: [Object] PASSshKey
The following are optional parameters: [String] KeyType

.OUTPUTS
CmdLet returns results upon success. Returns nothing on failure.

.EXAMPLE
PS: C:\PS\Checkout-PASSshKey -PASSshKey (Get-PASSshKey -Name "root@server123")
This CmdLet performs a checkout of the specified PASSshKey and retrieve the public key using OpenSSH format (default behaviour) 

.EXAMPLE
PS: C:\PS\Checkout-PASSshKey -PASSshKey (Get-PASSshKey -Name "root@server123") -KeyType "Public" -KeyFormat "PEM"
This CmdLet performs a checkout of the specified PASSshKey and retrieve the public key using PEM format

.EXAMPLE
PS: C:\PS\Checkout-PASSshKey -PASSshKey (Get-PASSshKey -Name "root@server123") -KeyType "Private"
This CmdLet performs a checkout of the specified PASSshKey and retrieve the private key. Note that private keys are always retrieved using PEM format.
#>
function global:Checkout-PASSshKey
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify PASSecret to retrieve.")]
		[System.Object]$PASSshKey,

		[Parameter(Mandatory = $false, HelpMessage = "Specify key type to retrieve (default is PublicKey).")]
		[ValidateSet("Private", "Public", IgnoreCase = $false)]
        [System.String]$KeyType = "Public",

		[Parameter(Mandatory = $false, HelpMessage = "Specify key format to use to retrieve key (default is OpenSSH.")]
		[ValidateSet("OpenSSH", "PEM", IgnoreCase = $false)]
        [System.String]$KeyFormat = "OpenSSH",

		[Parameter(Mandatory = $false, HelpMessage = "Specify the private key passphrase.")]
		[System.String]$Passphrase
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
	
	# Get current connection to the Centrify Cloud Platform
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# First retrieve Private Key using OpenSSH format as will be needed to retrieve the public key if requested. 
        # Setup variable for query
		$Uri = ("https://{0}/ServerManage/RetrieveSshKey" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	        = $PASSshKey.ID
		$JsonQuery.KeyFormat    = "PEM"
		$JsonQuery.KeyPairType	= "PrivateKey"

		if (-not [System.String]::IsNullOrEmpty($Passphrase))
        {
            $JsonQuery.Passphrase = $Passphrase
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
			# Success return Private Key
            $PrivateKey = $WebResponseResult.Result

            # Now retrieve PublicKey if requested
            if ($KeyType -eq "Public")
            {
                # Setup variable for query
		        $Uri = ("https://{0}/ServerManage/RetrieveSshKey" -f $PASConnection.PodFqdn)
		        $ContentType = "application/json" 
		        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		        # Set Json query
		        $JsonQuery = @{}
		        $JsonQuery['hidden-field-1733-inputEl'] = $PrivateKey
		        $JsonQuery.ID	        = $PASSshKey.ID
		        $JsonQuery.KeyFormat    = $KeyFormat
		        $JsonQuery.KeyPairType	= "PublicKey"

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
			        # Success return Public Key
                    return $WebResponseResult.Result
		        }
		        else
		        {
			        # Query error
			        Throw $WebResponseResult.Message
		        }
            }
            else
            {
			    # Return Private Key
                return $PrivateKey
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
