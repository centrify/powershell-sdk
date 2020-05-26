###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves the specified PASSecret from the system.

.DESCRIPTION
This CMDlet retrieves the specified PASSecret from the system.
Note; The Get-PASSecret cmdlet must be used to get the desired PASSecret.

The following are required parameters: [Object] PASSecret
The following are optional parameters: [String] Path

.PARAMETER PASSecret
Mandatory parameter [Object] PASSecret to retrieve.
Note; The Get-PASSecret cmdlet must be used to get the desired PASSecret.

.PARAMETER Path
Optional parameter [String] used to specify the file Path to download retrieved secret.

.INPUTS
The following are required parameters: [Object] PASSecret
The following are optional parameters: [String] Path

.OUTPUTS
CmdLet returns results upon success. Returns nothing on failure.

.EXAMPLE
PS: C:\PS\Checkout-PASSecret.ps1 -PASSecret (Get-PASSecret -Name "Secret")
This CmdLet performs a checkout of the specified PASSecret 
#>
function global:Checkout-PASSecret
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify PASSecret to retrieve.")]
		[System.Object]$PASSecret,

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
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/RetrieveDataVaultItem" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $PASSecret.ID

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
			# Success return Secret content
            $SecretContent = Centrify.PrivilegedAccessService.PowerShell.DataVault.GetSecretContent -SecretID $PASSecret.ID
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
                    $DownloadRequest = Centrify.PrivilegedAccessService.PowerShell.DataVault.RequestSecretDownloadUrl -SecretID $PASSecret.ID

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
                    Centrify.PrivilegedAccessService.PowerShell.DataVault.DownloadSecretFile -Path $File -DownloadUrl $DownloadRequest.Location

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
