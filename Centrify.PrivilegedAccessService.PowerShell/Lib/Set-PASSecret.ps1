###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> Set-PASSecret.ps1 -PASSecret (Get-PASSecret -Name "Secret")  -Name "Updated Secrets Name" -Description "New Secrets file"
#>
function global:Set-PASSecret
{
	[CmdletBinding(DefaultParameterSetName = "TextType")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "TextType", HelpMessage = "Specify PASSecret to update.")]
		[System.Object]$PASSecret,

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
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/ServerManage/UpdateDataVaultItem" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $PASSecret.ID
		$JsonQuery.Type = $PASSecret.Type

        # Update Name and Description if needed
        if ([System.String]::IsNullOrEmpty($Name))
        {
            # Keep value
            $JsonQuery.SecretName 	= $PASSecret.SecretName
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Name
        }

        if ([System.String]::IsNullOrEmpty($Description))
        {
            # Keep value
            $JsonQuery.Description 	= $PASSecret.Description
        }
        else
        {
            # Update value
            $JsonQuery.SecretName 	= $Description
        }

		if ($PASSecret.Type -eq "Text")
        {
            # Update Text
            if (-not [System.String]::IsNullOrEmpty($Text))
            {
                # Update value
                $JsonQuery.SecretText 	= $Text
            }
        }
        elseif ($PASSecret.Type -eq "File")
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
                $FileSize = Centrify.PrivilegedAccessService.PowerShell.DataVault.ConvertFileSize -ByteSize $FileInfo.Length

                # Request File Upload Url
                $UploadRequest = Centrify.PrivilegedAccessService.PowerShell.DataVault.RequestSecretUploadUrl -Name $FileInfo.Name -Size $FileInfo.Length -SecretID $PASSecret.ID

                # Upload File to the Vault
                Centrify.PrivilegedAccessService.PowerShell.DataVault.UploadSecretFile -Path $File -UploadUrl $UploadRequest.Location

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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return updated Secret
			return (Get-PASSecret -Name $Name)
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
