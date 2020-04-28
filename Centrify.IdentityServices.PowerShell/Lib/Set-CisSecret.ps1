################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet sets CisSecret from a specified path.

.DESCRIPTION
This CMDlet sets the CisSecret on the connected server.

.PARAMETER CisSecret
Mandatory parameter to specify the CisSecret to update

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
The following arguments are required: CiSecret
The following parametere are option: FilePath, Name, Description, Password

.EXAMPLE
C:\PS> Set-CisSecret.ps1 -CisSecret (Get-CisSecret -Name "Secret")  -Name "Updated Secrets Name" -Description "New Secrets file"
#>
function global:Set-CisSecret
{
	[CmdletBinding(DefaultParameterSetName = "TextType")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "TextType", HelpMessage = "Specify CisSecret to update.")]
		[System.Object]$CisSecret,

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
	
	# Get current connection to the Centrify Cloud Platform
	$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateDataVaultItem" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $CisSecret.ID
		$JsonQuery.Type = $CisSecret.Type

        # Update Name and Description if needed
        if ([System.String]::IsNullOrEmpty($Name))
        {
            # Keep value
            $JsonQuery.SecretName 	= $CisSecret.SecretName
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Name
        }

        if ([System.String]::IsNullOrEmpty($Description))
        {
            # Keep value
            $JsonQuery.Description 	= $CisSecret.Description
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Description
        }

		if ($CisSecret.Type -eq "Text")
        {
            # Update Text
            if (-not [System.String]::IsNullOrEmpty($Text))
            {
                # Update value
                $JsonQuery.SecretText 	= $Text
            }
        }
        elseif ($CisSecret.Type -eq "File")
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
                $FileSize = Centrify.IdentityServices.PowerShell.DataVault.ConvertFileSize -ByteSize $FileInfo.Length

                # Request File Upload Url
                $UploadRequest = Centrify.IdentityServices.PowerShell.DataVault.RequestSecretUploadUrl -Name $FileInfo.Name -Size $FileInfo.Length -SecretID $CisSecret.ID

                # Upload File to the Vault
                Centrify.IdentityServices.PowerShell.DataVault.UploadSecretFile -Path $File -UploadUrl $UploadRequest.Location

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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return updated Secret
			return (Get-CisSecret -Name $Name)
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
