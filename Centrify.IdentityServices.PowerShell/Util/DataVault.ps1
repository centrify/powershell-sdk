################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

function Centrify.IdentityServices.PowerShell.DataVault.RequestSecretUploadUrl
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Name to upload.")]
		[System.String]$Name,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Size to upload.")]
		[System.String]$Size,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the SecretID (required for updating secret).")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RequestSecretUploadUrl" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

        # Set Json query
		$JsonQuery = @{}
		$JsonQuery.fileName	= $Name
		$JsonQuery.fileSize	= $Size
		$JsonQuery.secretID	= $SecretID

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return Upload request details
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.RequestSecretDownloadUrl
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the SecretID.")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RequestSecretDownloadUrl" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

        # Set Json query
		$JsonQuery = @{}
		$JsonQuery.secretID	= $SecretID

		# Build Json query
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return Upload request details
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.UploadSecretFile
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Path to upload.")]
		[System.String]$Path,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Upload Url to use.")]
		[System.String]$UploadUrl
    )
    
	try
	{
		# Setup variable for connection
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Get File Content
        $Data = Get-Content -Path $Path
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
		Write-Debug ("Certificate=`n{0}" -f $Certificate)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Put -Uri $UploadUrl -Body $Data -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
            # Return nothing
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.DownloadSecretFile
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Path to write downloaded file to.")]
		[System.String]$Path,

		[Parameter(Mandatory = $true, HelpMessage = "Specify the Download Url to use.")]
		[System.String]$DownloadUrl
    )
    
	try
	{
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Get -Uri $DownloadUrl -WebSession $CisConnection.Session -OutFile $Path
		if ($WebResponse.StatusCode -eq 200)
		{
			# Return Success
			return $true
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.ConvertFileSize
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the File Size in Bytes.")]
		[System.Int64]$ByteSize
    )
    
	try
	{
		# Return the Size as a String
        switch -Regex ([Math]::Truncate([Math]::Log($ByteSize, 1024)))
        {
            '^0' {
                $FileSize = ("{0} B" -f $ByteSize)
            }
            '^1' {
                $FileSize = ("{0:n2} KB" -f ($ByteSize / 1KB))
            }
            '^2' {
                $FileSize = ("{0:n2} MB" -f ($ByteSize / 1MB))
            }
            '^3' {
                $FileSize = ("{0:n2} GB" -f ($ByteSize / 1GB))
            }
            Default {
                $FileSize = ("{0:n2} TB" -f ($ByteSize / 1TB))
            }
        }

        # Return the Size as a String
        return $FileSize
	}
	catch
	{
		Throw $_.Exception   
	}
}

function Centrify.IdentityServices.PowerShell.DataVault.GetSecretContent
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the SecretID.")]
		[System.String]$SecretID
    )
    
	try
	{
		# Setup variable for connection
		$Uri = ("https://{0}/ServerManage/RetrieveDataVaultItemContents" -f $CisConnection.PodFqdn)
        $ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
	
		# Set Json query
		$JsonQuery = @{}
		$JsonQuery.ID	= $SecretID

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
            # Return Content
            return $WebResponseResult.Result
		}
		else
		{
			# Unsuccesful connection
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		Throw $_.Exception   
	}
}
