###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet supports ability to create new [Object] PASSecret of type Text, OR File. 
.
.DESCRIPTION
This CMDlet supports ability to create new [Object] PASSecret of type Text, OR File. 

.PARAMETER Name
Mandatory parameter used to specify Secret name

.PARAMETER Text
Mandatory parameter [String] Text used to specify the Secret text. Not compatible with File parameter.

.PARAMETER File
Mandatory parameter [String] File used to specify the File Path to upload. Not compatible with Text parameter.

.PARAMETER Description
Mandatory parameter used to specify Secret [String] Description.

.PARAMETER Password
Optional parameter used to specify the Password to associate to this File Secret.

.INPUTS
This CmdLet takes the following required parameters: [String] Name, [String] Text OR [String] File
This CmdLet takes the following optional parameters: [String] Description,  [String] Password 

.OUTPUTS
Returns the PASSecret object on success. Returns failure message on failure.

.EXAMPLE
C:\PS> New-PASSecret -Name "Ocean" -Text "The ocean is blue"
Creates a new secret named 'ocean' with the specified text.

.EXAMPLE
C:\PS> New-PASSecret -File "C:\tmp\file.txt" -Name "Ocean2" 
Creates a new secret named 'Ocean2' with the specified text.
#>
function global:New-PASSecret
{
	[CmdletBinding(DefaultParameterSetName = "TextType")]
	param
	(
		[Parameter(Mandatory = $true, ParameterSetName = "TextType", HelpMessage = "Secret text.")]
		[System.String]$Text,

		[Parameter(Mandatory = $true, ParameterSetName = "FileType", HelpMessage = "Specify File Path to upload.")]
		[System.String]$File,

		[Parameter(Mandatory = $true, HelpMessage = "Specify Secret name.")]
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
		$Uri = ("https://{0}/ServerManage/AddDataVaultItem" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.SecretName 	= $Name
    	$JsonQuery.Description	= $Description

		if (-not [System.String]::IsNullOrEmpty($Text))
        {
            # Add Text Secret
    		$JsonQuery.Type 		= "Text"
		    $JsonQuery.SecretText	= $Text
        }
        elseif (-not [System.String]::IsNullOrEmpty($File))
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
            $UploadRequest = Centrify.PrivilegedAccessService.PowerShell.DataVault.RequestSecretUploadUrl -Name $FileInfo.Name -Size $FileInfo.Length -SecretID $null

            # Upload File to the Vault
            Centrify.PrivilegedAccessService.PowerShell.DataVault.UploadSecretFile -Path $File -UploadUrl $UploadRequest.Location

            # Add File Secret
		    $JsonQuery.Type					= "File"
		    $JsonQuery.SecretFilePath		= $UploadRequest.FilePath
		    $JsonQuery.SecretFileSize		= $FileSize
		    $JsonQuery.SecretFilePassword	= $Password
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
			# Success return Secret
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
