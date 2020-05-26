###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet store a new SSH key to the vault 

.DESCRIPTION
This CMDlet store a new SSH key to the vault

.PARAMETER Name
Mandatory parameter to specify the Name of the SSH key to create

.PARAMETER PrivateKey
Mandatory parameter to specify the private key to store in PEM format

.PARAMETER PrivateKey
Optional parameter to specify the key passphrase

.EXAMPLE
C:\PS>  $PASSshKey = Get-PASSshKey 
List all SSH keys from vault and places in $PASSshKey object

.EXAMPLE
C:\PS>  $PASSshKey = Get-PASSshKey -Name "root@server123"
List SSH key from vault with Name "root@server123"
#>
function global:New-PASSshKey
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the private key Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the path to the private key in PEM format.")]
		[System.String]$PrivateKey,

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
	
    if (Test-Path -Path $PrivateKey)
    {
        # Read key file and format data into one string
        $RawKey = ""
        Get-Content -Path $PrivateKey | ForEach-Object {
            $RawKey += ("{0}`n" -f $_ )
        }
    }
    else
    {
        Throw "Can't open private key file."
    }

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/AddSshKey" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.Name 	  = $Name
    	$JsonQuery.PrivateKey = $RawKey
    	$JsonQuery.Type       = "Manual"

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
			# Success return SshKey
			return (Get-PASSshKey -Name $Name)
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
