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
This CMDlet update an existing SSH key to the vault 

.DESCRIPTION
This CMDlet update an existing a new SSH key to the vault

.PARAMETER Name
Mandatory parameter to specify the Name of the SSH key to update

.EXAMPLE
C:\PS>  Get-VaultSshKey -Name "root@server123" | Set-VaultSshKey -Name "root@server456"
This CMDlet change SSH key name from "root@server123" to "root@server456"

.EXAMPLE
C:\PS>  Set-VaultSshKey -Id (Get-VaultSshKey -Name "root@server123") -Description "Root key for Server123"
This CMDlet update description for SSH key name "root@server123"
#>
function global:Set-VaultSshKey
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the SSH Key to update.")]
		[System.String]$VaultSshKey,
        
        [Parameter(Mandatory = $false, HelpMessage = "Specify the new Name for the SSH Key to update.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the private key Description.")]
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

    if (-not [System.String]::IsNullOrEmpty($Passphrase) -and [System.String]::IsNullOrEmpty($PrivateKey))
    {
        # Passphrase must be update along Private key
        Throw "Passphrase can only be update when also updating Private Key. Both parameters must be used at the same time."
    }

    # Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
        # Setup variable for query
        $Uri = ("https://{0}/ServerManage/UpdateSshKey" -f $PlatformConnection.PodFqdn)
        $ContentType = "application/json" 
        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
        $JsonQuery = @{}
        $JsonQuery.Id 	  = $VaultSshKey.Id

        if (-not [System.String]::IsNullOrEmpty($Name))
        {
            $JsonQuery.Name = $Name
        }
        if (-not [System.String]::IsNullOrEmpty($Description))
        {
            $JsonQuery.Comment = $Description
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
