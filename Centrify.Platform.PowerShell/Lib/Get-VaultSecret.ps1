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
This CMDlet retrieves detailed secret information 

.DESCRIPTION
This CMDlet retrieves detailed secret information 

.PARAMETER Name
Optional parameter to specify the Name of the Secret to retrieve

.PARAMETER Filter
Optional parameter to specify the Filter to use to search for Secret(s). Searches the following fields: "SecretName", "Type", "SecretFileName")

.EXAMPLE
C:\PS> Get-VaultSecret 
Retrieves all secrets on system and places in $VaultSecret object

.EXAMPLE
C:\PS> Get-VaultSecret -Filter "Ocean" 
Retrieves detailed secret on machine with Name "Ocean"

.EXAMPLE
C:\PS> Get-VaultSecret -Filter "Text"
Retrieves detailed secret(s) on system that contain "text" in "SecretName", "Type", or "SecretFileName"
#>
function global:Get-VaultSecret
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to get by Name.")]
		[System.String]$Name,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the Filter to use to search for Secret(s).")]
		[System.String]$Filter,

		[Parameter(Mandatory = $false, HelpMessage = "Specify File Path to download retrieved secret.")]
		[System.String]$Path,

		[Parameter(Mandatory = $false, HelpMessage = "Retrieve secret contents.")]
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
		$Query = Centrify.Platform.PowerShell.Redrock.GetQueryFromFile -Name "GetSecret"
		
		# Set Arguments
		if (-not [System.String]::IsNullOrEmpty($Name))
		{
			# Add Arguments to Statement
			$Query = ("{0} WHERE SecretName='{1}'" -f $Query, $Name)
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
                # Setup variable for query
		        $Uri = ("https://{0}/ServerManage/RetrieveSecretMetadata" -f $PlatformConnection.PodFqdn)
		        $ContentType = "application/json" 
		        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		        # Set Json query
		        $JsonQuery = @{}
		        $JsonQuery.ID	= $WebResponseResult.Result.Results.Row.ID

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
			        # Get Secret ID and return secret content
                    $SecretID = $WebResponseResult.Result.'_RowKey'
                    $SecretContent = Centrify.Platform.PowerShell.DataVault.GetSecretContent -SecretID $SecretID
			        if ($SecretContent -ne [Void]$null)
                    {
                        if ($WebResponseResult.Result.Type -eq "Text")
                        {
                            # Return Secret content
                            return $SecretContent.SecretText
                        }
			            elseif ($WebResponseResult.Result.Type -eq "File")
                        {
                            # Request File Download Url
                            $DownloadRequest = Centrify.Platform.PowerShell.DataVault.RequestSecretDownloadUrl -SecretID $SecretID

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
                            Centrify.Platform.PowerShell.DataVault.DownloadSecretFile -Path $File -DownloadUrl $DownloadRequest.Location
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
            else
            {
                # Get query result
                $VaultSecrets = $WebResponseResult.Result.Results.Row
            }

            # Only modify results if not empty
            if ($VaultSecrets -ne [Void]$null -and $Detailed.IsPresent)
            {
                # Modify results
                $VaultSecrets | ForEach-Object {
                    # Add Activity
                    $_ | Add-Member -MemberType NoteProperty -Name Activity -Value (Centrify.Platform.PowerShell.Core.GetSecretActivity($_.ID))

                    # Add Permissions
                    $_ | Add-Member -MemberType NoteProperty -Name Permissions -Value (Centrify.Platform.PowerShell.Core.GetSecretPermissions($_.ID))
                }
            }
            
            # Return results
            return $VaultSecrets
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
