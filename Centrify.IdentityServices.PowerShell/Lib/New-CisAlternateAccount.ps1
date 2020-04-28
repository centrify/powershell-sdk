################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet create a new Alternate Account.

.DESCRIPTION

.PARAMETER CisAccount
Specify the CisAccount to set as an alternate account.

.PARAMETER Owner
Specify the CisUser to set as the alternate account owner.

.INPUTS
This CmdLet takes as input a CisUser object

.OUTPUTS
This Cmdlet returns result from attempting to update CisUser object

.EXAMPLE
C:\PS> 

.EXAMPLE
C:\PS>  
#>
function global:New-CisAlternateAccount
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
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Get CisAccount informations
		if (-not [System.String]::IsNullOrEmpty($Account))
		{
			# Get CisAccount
            $AccountName = $Account.Split('@')[0]
            $AccountDomain = $Account.Split('@')[1]
            $CisAccount = Get-CisAccount -CisDomain (Get-CisDomain -Name $AccountDomain) -User $AccountName
            if ($CisAccount -eq [Void]$null)
            {
                # Could not find any Domain Account with parameters given
                Throw "Unable to get CisAccount informations (alternate account)"
            }
		}
		
		# Get CisUser informations
		if (-not [System.String]::IsNullOrEmpty($Owner))
		{
			$CisUser = Centrify.IdentityServices.PowerShell.Core.DirectoryServiceQuery -User $Owner
            if ($CisUser -eq [Void]$null)
            {
                # Could not find AD User 
                Throw "Unable to get CisUser informations (owner account)"
            }
		}

		# Setup variable for query
		$Uri = ("https://{0}/PASUnitTest/SetAccountOwner" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.accountId = $CisAccount.ID
        $JsonQuery.ownerUuid = $CisUser.InternalName
        $JsonQuery.ownerName = $CisUser.SystemName

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
            try
            {
                # Get Alternate Account CisUser
                $AlternateAccount = Centrify.IdentityServices.PowerShell.Core.DirectoryServiceQuery -User ("{0}@{1}" -f $CisAccount.User, $CisAccount.Name)
                if ($AlternateAccount -ne [Void]$null)
                {
			        # Redirect MFA for Alternate Account to Owner
		            $Uri = ("https://{0}/UserMgmt/ChangeUserAttributes" -f $CisConnection.PodFqdn)
		            $ContentType = "application/json" 
		            $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

                    # Set Json query
		            $JsonQuery = @{}
                    $JsonQuery.ID = $AlternateAccount.InternalName
                    $JsonQuery.CmaRedirectedUserUuid = $CisUser.InternalName

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
                    Throw ("Cannot found CisUser for account '{0}@{1}'." -f $CisAccount.User, $CisAccount.Name)
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
            Set-CisTenantConfig -Key SmoketestRun -Value True
            New-CisAlternateAccount -Account $Account -Owner $Owner
            Set-CisTenantConfig -Key SmoketestRun -Value False
        }
        else
        {
			# Unhandled exception
            Throw $_.Exception   
        }
	}
}
