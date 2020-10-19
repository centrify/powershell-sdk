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
This CMDlet sets PASSecret from a specified path.

.DESCRIPTION
This CMDlet sets the PASSecret on the connected server.

.PARAMETER PASSecret
Mandatory parameter to specify the PASSecret to update

.PARAMETER Text
Optional parameter to represent the secret text.

.PARAMETER File
Optional parameter to specify the file path to upload.

.PARAMETER Name
Optional parameter to specify secret name.

.PARAMETER Description
Optional parameter to specify secret Description.

.PARAMETER Password
The password of the secret.

.INPUTS 
The following arguments are required: PASecret
The following parametere are option: FilePath, Name, Description, Password

.EXAMPLE
C:\PS> Set-VaultSecret.ps1 -PASSecret (Get-VaultSecret -Name "Secret")  -Name "Updated Secrets Name" -Description "New Secrets file"
#>
function global:Set-VaultSecret
{
	[CmdletBinding(DefaultParameterSetName = "TextType")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "TextType", HelpMessage = "Specify PASSecret to update.")]
		[System.Object]$VaultSecret,

		[Parameter(Mandatory = $false, ParameterSetName = "TextType", HelpMessage = "Secret text.")]
		[System.String]$Text,

		[Parameter(Mandatory = $false, ParameterSetName = "FileType", HelpMessage = "Specify File Path to upload.")]
		[System.String]$File,

		[Parameter(Mandatory = $false, HelpMessage = "Specify Secret name.")]
		[Parameter(ParameterSetName = "TextType")]
		[Parameter(ParameterSetName = "FileType")]
		[System.String]$Name,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify Secret description.")]
		[Parameter(ParameterSetName = "TextType")]
		[Parameter(ParameterSetName = "FileType")]
		[System.String]$Description,

		[Parameter(Mandatory = $false, HelpMessage = "Specify Password to associate to this File Secret.")]
		[Parameter(ParameterSetName = "FileType")]
		[System.String]$Password
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateDataVaultItem" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $VaultSecret.ID
		$JsonQuery.Type = $VaultSecret.Type

        # Update Name and Description if needed
        if ([System.String]::IsNullOrEmpty($Name))
        {
            # Keep value
            $JsonQuery.SecretName 	= $VaultSecret.SecretName
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Name
        }

        if ([System.String]::IsNullOrEmpty($Description))
        {
            # Keep value
            $JsonQuery.Description 	= $VaultSecret.Description
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Description
        }

		if ($VaultSecret.Type -eq "Text")
        {
            # Update Text
            if (-not [System.String]::IsNullOrEmpty($Text))
            {
                # Update value
                $JsonQuery.SecretText 	= $Text
            }
        }
        elseif ($VaultSecret.Type -eq "File")
        {
            # Update File Secret
            if (-not [System.String]::IsNullOrEmpty($File))
            {
                # Validate file
                if (-not (Test-Path -Path $File))
                {
                    # Cannot find File to upload
                    Throw "File not found."
                }

                # Get File Info
                $FileInfo = Get-Item -Path $File
                $FileSize = Centrify.Platform.PowerShell.DataVault.ConvertFileSize -ByteSize $FileInfo.Length

                # Request File Upload Url
                $UploadRequest = Centrify.Platform.PowerShell.DataVault.RequestSecretUploadUrl -Name $FileInfo.Name -Size $FileInfo.Length -SecretID $VaultSecret.ID

                # Upload File to the Vault
                Centrify.Platform.PowerShell.DataVault.UploadSecretFile -Path $File -UploadUrl $UploadRequest.Location

		        # Update file
                $JsonQuery.SecretFilePath		= $UploadRequest.FilePath
		        $JsonQuery.SecretFileSize		= $FileSize
		        $JsonQuery.SecretFilePassword	= $Password
            }
        }
        else
        {
            # Missing parameter
            Throw "Either Text or File parameter need to be specified."
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
			# Success return updated Secret
			return (Get-VaultSecret -Name $Name)
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
