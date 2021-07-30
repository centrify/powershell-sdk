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
This CMDlet retrieves SSH keys 

.DESCRIPTION
This CMDlet retrieves SSH keys 

.PARAMETER Name
Optional parameter to specify the Name of the SSH key to retrieve

.PARAMETER Filter
Optional parameter to specify the Filter to use to search for Secret(s). Searches the following fields: "Name", "KeyType", "KeyFormat")

.EXAMPLE
C:\PS>  Get-VaultSshKey 
List all SSH keys from vault and places in $PASSshKey object

.EXAMPLE
C:\PS> Get-VaultSshKey -Filter "root@server123"
List SSH key from vault with Name "root@server123"
#>
function global:Get-VaultSshKey
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to get by Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for Secret(s).")]
		[System.String]$Filter,

		[Parameter(Mandatory = $false, HelpMessage = "Specify key type to retrieve (default is PublicKey).")]
		[ValidateSet("Private", "Public", IgnoreCase = $false)]
        [System.String]$KeyType = "Public",

		[Parameter(Mandatory = $false, HelpMessage = "Specify key format to use to retrieve key (default is OpenSSH.")]
		[ValidateSet("OpenSSH", "PEM", IgnoreCase = $false)]
        [System.String]$KeyFormat = "OpenSSH",

		[Parameter(Mandatory = $false, HelpMessage = "Specify the private key passphrase.")]
		[System.String]$Passphrase,

		[Parameter(Mandatory = $false, HelpMessage = "Retrieve ssh key contents.")]
		[Switch]$Retrieve,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Detailed
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
	
	try
	{	
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Get built-in RedrockQuery
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetSshKey"
		
		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($Name))
		{
			# Add Arguments to Statement
			$Query = ("{0} WHERE Name='{1}'" -f $Query, $Name)
		}

		# Build Query
		$RedrockQuery = Centrify.Platform.PowerShell.Redrock.CreateQuery -Query $Query

		# Debug informations
		Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Get raw data
			if ($Retrieve.IsPresent)
            {
                # Get SSH Key ID and return key in requested format and type 
			    $VaultSshKeyID = $WebResponseResult.Result.Results.Row.ID
                
                # Setup variable for query
		        $Uri = ("https://{0}/ServerManage/RetrieveSshKey" -f $PlatformConnection.PodFqdn)
		        $ContentType = "application/json" 
		        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		        # Set Json query
		        $JsonQuery = @{}
		        $JsonQuery.ID	        = $VaultSshKeyID
		        $JsonQuery.KeyFormat    = "PEM"
		        $JsonQuery.KeyPairType	= "PrivateKey"

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
			        # Success return Private Key
                    $PrivateKey = $WebResponseResult.Result

                    # Now retrieve PublicKey if requested
                    if ($KeyType -eq "Public")
                    {
                        # Setup variable for query
		                $Uri = ("https://{0}/ServerManage/RetrieveSshKey" -f $PlatformConnection.PodFqdn)
		                $ContentType = "application/json" 
		                $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		                # Set Json query
		                $JsonQuery = @{}
		                $JsonQuery['hidden-field-1733-inputEl'] = $PrivateKey
		                $JsonQuery.ID	        = $VaultSshKeyID
		                $JsonQuery.KeyFormat    = $KeyFormat
		                $JsonQuery.KeyPairType	= "PublicKey"

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
			                # Success return Public Key
                            $VaultSshKeys = $WebResponseResult.Result
		                }
		                else
		                {
			                # Query error
			                Throw $WebResponseResult.Message
		                }
                    }
                    else
                    {
			            # Return Private Key
                        $VaultSshKeys = $PrivateKey
                    }
		        }
		        else
		        {
			        # Query error
			        Throw $WebResponseResult.Message
		        }
            }
            else
            {
                # Get all results
                $VaultSshKeys = $WebResponseResult.Result.Results.Row
            }

            # Only modify results if not empty
            if ($VaultSshKeys -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $VaultSshKeys | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetSshKeyActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.Platform.PowerShell.Core.GetSshKeyPermissions($_.ID))
                }
            }
            
            # Return results
            return $VaultSshKeys
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
