################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet retrieves the specified CisSecret from the system.

.DESCRIPTION
This CMDlet retrieves the specified CisSecret from the system.
Note; The Get-CisSecret cmdlet must be used to get the desired CisSecret.

The following are required parameters: [Object] CisSecret
The following are optional parameters: [String] Path

.PARAMETER CisSecret
Mandatory parameter [Object] CisSecret to retrieve.
Note; The Get-CisSecret cmdlet must be used to get the desired CisSecret.

.PARAMETER Path
Optional parameter [String] used to specify the file Path to download retrieved secret.

.INPUTS
The following are required parameters: [Object] CisSecret
The following are optional parameters: [String] Path

.OUTPUTS
CmdLet returns results upon success. Returns nothing on failure.

.EXAMPLE
PS: C:\PS\Checkout-CisSecret.ps1 -CisSecret (Get-CisSecret -Name "Secret")
This CmdLet performs a checkout of the specified CisSecret 
#>
function global:Checkout-CisSecret
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify CisSecret to retrieve.")]
		[System.Object]$CisSecret,

		[Parameter(Mandatory = $false, HelpMessage = "Specify File Path to download retrieved secret.")]
		[System.String]$Path
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
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/RetrieveDataVaultItem" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $CisSecret.ID

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
			# Success return Secret content
            $SecretContent = Centrify.IdentityServices.PowerShell.DataVault.GetSecretContent -SecretID $CisSecret.ID
			if ($SecretContent -ne [Void]$null)
            {
                if ($WebResponseResult.Result.Type -eq "Text")
                {
                    # Return Secret Text
                    return ($SecretContent) # | Select-Object -Property SecretName, Type, Description, SecretText | Format-List)
                }
			    elseif ($WebResponseResult.Result.Type -eq "File")
                {
                    # Request File Download Url
                    $DownloadRequest = Centrify.IdentityServices.PowerShell.DataVault.RequestSecretDownloadUrl -SecretID $CisSecret.ID

                    # Get file value from Path and File Name
                    if ([System.String]::IsNullOrEmpty($Path))
                    {
                        # Download File in current directory
                        $File = ("{0}\{1}" -f (Get-Location).Path, $SecretContent.SecretFileName)
                    }
                    else
                    {
                        # Download File in specified directory
                        $File = ("{0}\{1}" -f $Path, $SecretContent.SecretFileName)
                    }

                    # Download File from the Vault
                    Centrify.IdentityServices.PowerShell.DataVault.DownloadSecretFile -Path $File -DownloadUrl $DownloadRequest.Location

                    # Return Secret Password if any
                    return ($SecretContent) # | Select-Object -Property SecretName, Type, Description, SecretFileName, SecretFileSize, SecretFilePassword | Format-List)
                }
            }
            else
            {
                # Secret Content is null
                Throw "Could not retrieve Secret Content."
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
