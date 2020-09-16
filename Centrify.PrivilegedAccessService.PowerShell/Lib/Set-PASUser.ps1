###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet sets important attributes on an existing PAS user.

.DESCRIPTION
This Cmdlet sets important attributes on an existing PAS user. 
Updatable attributes are: LoginName, LoginSuffix, Mail, DisplayName, OfficeNumber, HomeNumber, MobileNumber, and Description.

.PARAMETER PASUser
Mandatory parameter to specify the PASUser to set Attributes to

.PARAMETER LoginName
Optional parameter to specify the the LoginName value to set.

.PARAMETER LoginSuffix
Optional parameter to specify the the LoginSuffix value to set.

.PARAMETER Mail
Optional parameter to specify the Mail value to set.

.PARAMETER DisplayName
Optional parameter to specify the DisplayName value to set.

.PARAMETER OfficeNumber
Optional parameter to specify the OfficeNumber value to set.

.PARAMETER HomeNumber
Optional parameter to specify the HomeNumber value to set.

.PARAMETER MobileNumber
Optional parameter to specify the MobileNumber value to set.

.PARAMETER Description
Optional parameter to specify the Description value to set.

.INPUTS
This CmdLet takes as input a PASUser object

.OUTPUTS
This Cmdlet returns result from attempting to update PASUser object

.EXAMPLE
C:\PS> Set-PASUser -PASUser (Get-PASUser -Filter "bcrab")

.EXAMPLE
C:\PS> Set-PASUser -PASUser (Get-PASUser -Filter "bcrab") -MobileNumber "5555555555"
Updates the MobileNumber attribute for PASUser "bcrab" 
#>
function global:Set-PASUser
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASUser to set Attributes to.")]
		[System.Object]$PASUser,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the LoginName value to set.")]
		[System.String]$LoginName,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the LoginSuffix value to set.")]
		[System.String]$LoginSuffix,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Mail value to set.")]
		[System.String]$Mail,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the DisplayName value to set.")]
		[System.String]$DisplayName,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the OfficeNumber value to set.")]
		[System.String]$OfficeNumber,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the HomeNumber value to set.")]
		[System.String]$HomeNumber,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the MobileNumber value to set.")]
		[System.String]$MobileNumber,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Description value to set.")]
		[System.String]$Description
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

		# Setup variable for query
		$Uri = ("https://{0}/CDirectoryService/ChangeUser" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		if ($PASUser.SourceDsType -eq "CDS")
		{
		    # Set Json query
		    $JsonQuery = @{}
		    
		    # Get PASUser Attributes and save it as a Centrify Directory Service User
		    $CDSUser = Centrify.PrivilegedAccessService.PowerShell.Core.GetUserAttributes $PASUser.ID
		    if ($CDSUser -eq [Void]$null)
		    {
			    Throw "Unable to get PASUser attributes"
		    }

            # Overriding PASUser LoginName if Parameter is used
            if ([System.String]::IsNullOrEmpty($LoginName))
		    {
			    $JsonQuery.Add("LoginName", $PASUser.UserName.Split('@')[0])
		    }
            else
            {
			    $JsonQuery.Add("LoginName", $LoginName)
            }

            # Overriding PASUser LoginSuffix if Parameter is used
		    if ([System.String]::IsNullOrEmpty($LoginSuffix))
		    {
			    $JsonQuery.Add("loginsuffixfield-1363-inputEl", $PASUser.UserName.Split('@')[1])
		    }
            else
            {
			    $JsonQuery.Add("loginsuffixfield-1363-inputEl", $LoginSuffix)
            }

            # Overriding PASUser Mail if Parameter is used
		    if ([System.String]::IsNullOrEmpty($Mail))
		    {
			    $JsonQuery.Add("Mail", $CDSUser.Mail)
		    }
            else
            {
			    $JsonQuery.Add("Mail", $Mail)
            }

            # Overriding PASUser DisplayName if Parameter is used
		    if ([System.String]::IsNullOrEmpty($DisplayName))
		    {
			    $JsonQuery.Add("DisplayName", $CDSUser.DisplayName)
		    }
            else
            {
			    $JsonQuery.Add("DisplayName", $DisplayName)
            }

            # Overriding PASUser Description if Parameter is used
		    if ([System.String]::IsNullOrEmpty($Description))
		    {
			    $JsonQuery.Add("Description", $CDSUser.Description)
		    }
            else
            {
			    $JsonQuery.Add("Description", $Description)
            }

            # Overriding PASUser OfficeNumber if Parameter is used
		    if ([System.String]::IsNullOrEmpty($OfficeNumber))
		    {
			    $JsonQuery.Add("OfficeNumber", $CDSUser.TelephoneNumber)
		    }
            else
            {
			    $JsonQuery.Add("OfficeNumber", $OfficeNumber)
            }

            # Overriding PASUser HomeNumber if Parameter is used
		    if ([System.String]::IsNullOrEmpty($HomeNumber))
		    {
			    $JsonQuery.Add("HomeNumber", $CDSUser.HomePhone)
		    }
            else
            {
			    $JsonQuery.Add("HomeNumber", $HomeNumber)
            }

            # Overriding PASUser MobileNumber if Parameter is used
		    if ([System.String]::IsNullOrEmpty($MobileNumber))
		    {
			    $JsonQuery.Add("MobileNumber", $CDSUser.Mobile)
		    }
            else
            {
			    $JsonQuery.Add("MobileNumber", $MobileNumber)
            }

            # Set common values 
            $JsonQuery.Add("ID", $CDSUser.Uuid)		    
            $JsonQuery.Add("Name", ("{0}@{1}" -f $JsonQuery.LoginName, $JsonQuery.'loginsuffixfield-1363-inputEl'))		    

		    # Build Json query
		    $Json = $JsonQuery | ConvertTo-Json
		}
		else
		{
			# Can't modify an AD User or LDAP User enabled in the Cloud
			Throw "This Cmdlet can be use only to modify Users in the Cloud Directory. Any other users should be modified in their respective Directory Services (AD or LDAP)."
		}
		# Debug informations
		Write-Debug ("Uri= {0}" -f $CipQuery.Uri)
		Write-Debug ("Args= {0}" -f $Arguments)
		Write-Debug ("Json= {0}" -f $CipQuery.Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			return $WebResponseResult.Result.Results.Row
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
