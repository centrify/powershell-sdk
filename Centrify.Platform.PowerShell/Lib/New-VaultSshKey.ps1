###########################################################################################
# Centrify Platform PowerShell module
#
# Author   : Fabrice Viguier
# Contact  : support AT centrify.com
# Release  : 21/01/2016
# Copyright: (c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
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

.PARAMETER Description
Optional parameter to specify the Name of the SSH key to create

.PARAMETER PrivateKey
Optional parameter to specify the key passphrase

.EXAMPLE
C:\PS>  New-VaultSshKey -Name "root@server123" -PrivateKey ..\sshkey@30.pem 
This CMDlet store a new SSH key name "root@server123" to the vault

.EXAMPLE
C:\PS>  New-VaultSshKey -Name "instance-key-vpc" -PrivateKey ..\aws_key.pem -Description "AWS Key" 
This CMDlet store a new SSH key name "root@server123" to the vault
#>
function global:New-VaultSshKey
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the private key Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the path to the private key in PEM format.")]
		[System.String]$PrivateKey,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the private key Description.")]
		[System.String]$Description,
		
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

	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/AddSshKey" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.Name 	  = $Name
    	$JsonQuery.PrivateKey = $RawKey
    	$JsonQuery.Type       = "Manual"

		if (-not [System.String]::IsNullOrEmpty($Description))
        {
            $JsonQuery.Comment = $Description
        }
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
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return SshKey
			return (Get-VaultSshKey -Name $Name)
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
