###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet create a new Alternate Account.

.DESCRIPTION

.PARAMETER PASAccount
Specify the PASAccount to set as an alternate account.

.PARAMETER Owner
Specify the PASUser to set as the alternate account owner.

.INPUTS
This CmdLet takes as input a PASUser object

.OUTPUTS
This Cmdlet returns result from attempting to update PASUser object

.EXAMPLE
C:\PS> 

.EXAMPLE
C:\PS>  
#>
function global:New-PASAlternateAccount
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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Get PASAccount informations
		if (-not [System.String]::IsNullOrEmpty($Account))
		{
			# Get PASAccount
            $AccountName = $Account.Split('@')[0]
            $AccountDomain = $Account.Split('@')[1]
            $PASAccount = Get-PASAccount -PASDomain (Get-PASDomain -Name $AccountDomain) -User $AccountName
            if ($PASAccount -eq [Void]$null)
            {
                # Could not find any Domain Account with parameters given
                Throw "Unable to get PASAccount informations (alternate account)"
            }
		}
		
		# Get PASUser informations
		if (-not [System.String]::IsNullOrEmpty($Owner))
		{
			$PASUser = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -User $Owner
            if ($PASUser -eq [Void]$null)
            {
                # Could not find AD User 
                Throw "Unable to get PASUser informations (owner account)"
            }
		}

		# Setup variable for query
		$Uri = ("https://{0}/PASUnitTest/SetAccountOwner" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

        # Set Json query
		$JsonQuery = @{}
        $JsonQuery.accountId = $PASAccount.ID
        $JsonQuery.ownerUuid = $PASUser.InternalName
        $JsonQuery.ownerName = $PASUser.SystemName

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
            try
            {
                # Get Alternate Account PASUser
                $AlternateAccount = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -User ("{0}@{1}" -f $PASAccount.User, $PASAccount.Name)
                if ($AlternateAccount -ne [Void]$null)
                {
			        # Redirect MFA for Alternate Account to Owner
		            $Uri = ("https://{0}/UserMgmt/ChangeUserAttributes" -f $PASConnection.PodFqdn)
		            $ContentType = "application/json" 
		            $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

                    # Set Json query
		            $JsonQuery = @{}
                    $JsonQuery.ID = $AlternateAccount.InternalName
                    $JsonQuery.CmaRedirectedUserUuid = $PASUser.InternalName

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
                    Throw ("Cannot found PASUser for account '{0}@{1}'." -f $PASAccount.User, $PASAccount.Name)
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
            Set-PASTenantConfig -Key SmoketestRun -Value True
            New-PASAlternateAccount -Account $Account -Owner $Owner
            Set-PASTenantConfig -Key SmoketestRun -Value False
        }
        else
        {
			# Unhandled exception
            Throw $_.Exception   
        }
	}
}
