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
This Cmdlet create a new Alternate Account.

.DESCRIPTION

.PARAMETER Account
Specify the Domain Account to set as an alternate account.

.PARAMETER Owner
Specify the AD User to set as the alternate account owner.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
C:\PS> 

.EXAMPLE
C:\PS>  
#>
function global:New-VaultAlternateAccount
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Domain Account to set as an alternate account.")]
		[System.String]$Account,
		
		[Parameter(Mandatory = $true, HelpMessage = "Specify the AD User to set as the alternate account owner.")]
		[System.String]$Owner
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

		# Get Account information
		if (-not [System.String]::IsNullOrEmpty($Account))
		{
			# Get Vault Account
            $AccountName = $Account.Split('@')[0]
            $AccountDomain = $Account.Split('@')[1]
            $VaultAccount = Get-VaultAccount -VaultDomain (Get-VaultDomain -Name $AccountDomain) -User $AccountName
            if ($VaultAccount -eq [Void]$null)
            {
                # Could not find any Domain Account with parameters given
                Throw "Unable to get Account informations (Vaulted Domain account)"
            }
		}
		
		# Get Centrify User information
		if (-not [System.String]::IsNullOrEmpty($Owner))
		{
			$CentrifyUser = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -User $Owner
            if ($CentrifyUser -eq [Void]$null)
            {
                # Could not find AD User 
                Throw "Unable to get Owner informations (AD User account)"
            }
		}

		# Setup variable for query
		$Uri = ("https://{0}/PASUnitTest/SetAccountOwner" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.accountId = $VaultAccount.ID
        $JsonQuery.ownerUuid = $CentrifyUser.InternalName
        $JsonQuery.ownerName = $CentrifyUser.SystemName

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
            try
            {
                # Get Alternate Account
                $AlternateAccount = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -User ("{0}@{1}" -f $VaultAccount.User, $VaultAccount.Name)
                if ($AlternateAccount -ne [Void]$null)
                {
			        # Redirect MFA for Alternate Account to Owner
		            $Uri = ("https://{0}/UserMgmt/ChangeUserAttributes" -f $PlatformConnection.PodFqdn)
		            $ContentType = "application/json" 
		            $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

                    # Set Json query
		            $JsonQuery = @{}
                    $JsonQuery.ID = $AlternateAccount.InternalName
                    $JsonQuery.CmaRedirectedUserUuid = $CentrifyUser.InternalName

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
                        # Return nothing
		            }
		            else
		            {
			            # Query error
			            Throw $WebResponseResult.Message
		            }
                }
                else
                {
                    # Account not found
                    Throw ("Cannot found Vault Account '{0}@{1}'." -f $VaultAccount.User, $VaultAccount.Name)
                }
	        }
	        catch
	        {
		        Throw $_.Exception   
	        }
		}
		else
		{
			# Query error
			Throw $WebResponseResult.Message
		}
	}
	catch
	{
		if ($_.Exception.Message -match "This controller is only usable under SmokeTest environment.")
        {
			# Rest API for Alternate accounts can only be run under Smoketest environment atm
            Set-CentrifyTenantConfig -Key SmoketestRun -Value True
            New-VaultAlternateAccount -Account $Account -Owner $Owner
            Set-CentrifyTenantConfig -Key SmoketestRun -Value False
        }
        else
        {
			# Unhandled exception
            Throw $_.Exception   
        }
	}
}
