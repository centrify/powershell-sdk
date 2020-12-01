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

function Centrify.Platform.PowerShell.X509Certificates.GetCertificateFromBase64String
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate in Base64 String format.")]
        [System.String]$Base64String,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate password.")]
		[System.Security.SecureString]$Password		
    )
	
    $pfxBytes = [System.Convert]::FromBase64String($Base64String)
	
    $keyStoreFlags 	= 		[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet `
					-bOr 	[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet `
					-bOr 	[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    
	if(-not [System.String]::IsNullOrEmpty($Password))
    {
        # Return a X509 Certificate with associated Password
		return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxBytes, $Password, $keyStoreFlags)
    }   
    else
    {
        # Return a X509 Certificate with no Password
        return New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($pfxBytes, "", $keyStoreFlags)
    }
}


function Centrify.Platform.PowerShell.X509Certificates.AddCertificateToStore
{
    param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Certificate store where to add the Certificate.")]
		[System.String]$Store,
		
        [Parameter(Mandatory=$true, HelpMessage = "Specify the X509 Certificate to use to connect.")]
        [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate
    )
    
	try
	{
		# Determine Certificate Store to use
		$StoreName 		= $Store.Split('\')[2]
		$StoreLocation 	= $Store.Split('\')[1]
		$CertStore 		= New-Object System.Security.Cryptography.X509Certificates.X509Store($StoreName, $StoreLocation)

		# Open Certificate Store in RW mode
		$CertStore.Open("ReadWrite")
		
		# Remove any already existing Certificate to replace
		$CertStore.Certificates | Where-Object { $_.Subject -eq $Certificate.Subject } | ForEach-Object { $CertStore.Remove($_) }
				
		# Add Certificate and close Store
		$CertStore.Add($Certificate)
		$CertStore.Close()
	}
	catch
	{
		if ($_.Exception.Message -match "Access is denied")
		{
			# Certificate Store access denied
			Throw ("Access to Certificate store {0} is denied." -f $Store)
		}
		else
		{
			# Unknown exception
			Throw $_.Exception   		
		}
	}
}

function Centrify.Platform.PowerShell.X509Certificates.GetCertificateFromStore
{
    param(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Certificate Store name.")]
		[System.String]$StoreName,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Certificate Thumbprint.")]
		[System.String]$Thumbprint
    )
    
	try
	{
		# Open Certificate Store in RO mode
        $CertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", $StoreName)
		$CertStore.Open("ReadOnly")
		
		# Get Certificate by Thumbprint and close Store
		$X509Certificate = $CertStore.Certificates | Where-Object { $_.Thumbprint -eq $Thumbprint }
		$CertStore.Close()
		if ($X509Certificate -eq [void]$null)
		{
			# Certificate not found
			Throw ("Could not find Certificate from store {0}." -f $StoreName)
		}
        elseif ($X509Certificate.GetType().BaseType -eq [System.Array])
        {
            Throw "More than one certificate found using given CN. Try refining certificate common name."
        }
		
		# Return X509Certificate
		return $X509Certificate
	}
	catch
	{
		if ($_.Exception.Message -match "Access is denied")
		{
			# Certificate Store access denied
			Throw ("Access to Certificate store {0} is denied." -f $StoreName)
		}
		else
		{
			# Unknown exception
			Throw $_.Exception   		
		}
	}
}
