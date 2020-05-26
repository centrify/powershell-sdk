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

		# Get PASUser Attributes
		$CloudUser = Get-PASUserAttributes -PASUser $PASUser
		if ($CloudUser -eq [Void]$null)
		{
			Throw "Unable to get PASUser informations"
		}

		# Prepare values to set for the User
		#
		# {"LoginName":"clouduser",
		# "loginsuffixfield-1363-inputEl":"oceanlab.my.centrify.com",
		# "DisplayName":"Cloud User",
		# "Password":"-1",
		# "confirmPassword":"-1",
		# "enableState":false,
		# "PasswordNeverExpire":true,
		# "ForcePasswordChangeNext":false,
		# "InEverybodyRole":true,
		# "SendEmailInvite":false,
		# "SendSmsInvite":false,
		# "Description":"Cloud User for API testing",
		# "OfficeNumber":"",
		# "HomeNumber":"",
		# "MobileNumber":"",
		# "Picture":"",
		# "fileName":"",
		# "ID":"eb4fdde5-3cc3-4145-ab94-dfd83519e5eb",
		# "state":"None",
		# "ReportsTo":"Unassigned",
		# "":null,
		# "Name":"clouduser@oceanlab.my.centrify.com"}
		#
		if ([System.String]::IsNullOrEmpty($LoginName))
		{
			$LoginName = $PASUser.UserName.Split('@')[0]
		}
		if ([System.String]::IsNullOrEmpty($LoginSuffix))
		{
			$LoginSuffix = $PASUser.UserName.Split('@')[1]
		}
		if ([System.String]::IsNullOrEmpty($Mail))
		{
			$Mail = $CloudUser.Mail
		}
		if ([System.String]::IsNullOrEmpty($DisplayName))
		{
			$DisplayName = $CloudUser.DisplayName
		}
		if ([System.String]::IsNullOrEmpty($Description))
		{
			$Description = $CloudUser.Description
		}
		if ([System.String]::IsNullOrEmpty($OfficeNumber))
		{
			$OfficeNumber = $CloudUser.TelephoneNumber
		}
		if ([System.String]::IsNullOrEmpty($HomeNumber))
		{
			$HomeNumber = $CloudUser.HomePhone
		}
		if ([System.String]::IsNullOrEmpty($MobileNumber))
		{
			$MobileNumber = $CloudUser.Mobile
		}
		
		# Setup variable for query
		$Uri = ("https://{0}/CDirectoryService/ChangeUser" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		$Json = "{"
		if ($PASUser.SourceDsType -eq "CDS")
		{
			# Modifying a CloudUser
			$Json += ("`"LoginName`":`"{0}`"," -f $LoginName)
			$Json += ("`"loginsuffixfield-1363-inputEl`":`"{0}`"," -f $LoginSuffix)
			$Json += ("`"Mail`":`"{0}`"," -f $Mail)
			$Json += ("`"DisplayName`":`"{0}`"," -f $DisplayName)
			#$Json += ("`"Password`":`"-1`",")
			#$Json += ("`"confirmPassword`":`"-1`",")
			#$Json += ("`"enableState`":false,")
			#$Json += ("`"PasswordNeverExpire`":true,")
			#$Json += ("`"ForcePasswordChangeNext`":false,")
			#$Json += ("`"InEverybodyRole`":true,")
			#$Json += ("`"SendEmailInvite`":false,")
			#$Json += ("`"SendSmsInvite`":false,")
			$Json += ("`"Description`":`"{0}`"," -f $Description)
			$Json += ("`"OfficeNumber`":`"{0}`"," -f $OfficeNumber)
			$Json += ("`"HomeNumber`":`"{0}`"," -f $HomeNumber)
			$Json += ("`"MobileNumber`":`"{0}`"," -f $MobileNumber)
			$Json += ("`"ID`":`"{0}`"," -f $CloudUser.Uuid)
			#$Json += ("`"state`":`"None`",")
			#$Json += ("`"ReportsTo`":`"Unassigned`",")
			#$Json += ("`"`":null,")
			$Json += ("`"Name`":`"{0}@{1}`"" -f $LoginName, $LoginSuffix)
			$Json += "}"
		}
		else
		{
			# Can't modify an AD User or LDAP User enabled in the Cloud
			Throw "This Cmdlet can be use only to modify Users in the Cloud Directory. Any other users should be modified in their respective Directories (AD or LDAP)."
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
