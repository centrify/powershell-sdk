################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet supports ability to create a new CisUser

.DESCRIPTION
This CMDlet supports ability to create a new CisUser

.PARAMETER Login
Mandatory string parameter used to specify the Login for the User to create.

.PARAMETER LoginSuffix
Mandatory string parameter used to specify the Login suffixe for the User to create."

.PARAMETER DisplayName
Mandatory string parameter used to specify the Display Name for the User to create.

.PARAMETER Password
Mandatory string parameter used to specify the Password for the User to create.

.PARAMETER Mail
Mandatory string parameter used to specify the Mail for the User to create

.PARAMETER Enabled
Optional string parameter used to specify if the User should be Enabled (default is False).

.PARAMETER PasswordNeverExpire
Optional string parameter used to specify if the User Password should never expire (default is False).

.PARAMETER ForcePasswordChangeNext
Optional string parameter used to specify if the User Password should be changed at next logon (default is True).

.PARAMETER InEverybodyRole
Optional string parameter used to specify if the User should be in the Everybody Role (default is True).

.PARAMETER SendEmailInvite
Optional string parameter used to specify if the User should receive a Email invite (default is False).

.PARAMETER SendSmsInvite
Optional string parameter used to specify if the User should receive a SMS invite (default is False).

.PARAMETER Description
Optional string parameter used to specify the Description for the User to create.

.PARAMETER OfficeNumber
Optional string parameter used to specify the the Office Number for the User to create.

.PARAMETER HomeNumber
Optional string parameter used to specify the Home Number for the User to create.

.PARAMETER MobileNumber
Optional string parameter used to specify the Mobile Number for the User to create.

.PARAMETER Picture
Optional string parameter used to specify the Picture for the User to create

.PARAMETER fileName
Optional string parameter used to specify the Picture file name for the User to create.

.PARAMETER Manager
Optional string parameter used to specify the Manager for the User to create.

.INPUTS
This CmdLet takes no object inputs

.OUTPUTS
Returns the newly created user object on success. Returns failure message on failure.

.EXAMPLE
C:\PS> New-CisUser -Login "bcrab" -LoginSuffix "ocean.net" -DisplayName "Eugene Harold Krabs" -Password "BBadsfsd90*()" -Mail "bcrab@ocean.net"
Create a new use 'bcrab' with the mandatory parameters
#>
function global:New-CisUser
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Login for the User to create.")]
		[System.String]$Login,
	
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Login suffixe for the User to create.")]
		[System.String]$LoginSuffix,
	
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Display Name for the User to create.")]
		[System.String]$DisplayName,
	
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Password for the User to create.")]
		[System.String]$Password,
	
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Mail for the User to create.")]
		[System.String]$Mail,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User should be Enabled (default is False).")]
		[System.Boolean]$Enabled = $false,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User Password should never expire (default is False).")]
		[System.Boolean]$PasswordNeverExpire = $false,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User Password should be changed at next logon (default is True).")]
		[System.Boolean]$ForcePasswordChangeNext = $true,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User should be in the Everybody Role (default is True).")]
		[System.Boolean]$InEverybodyRole = $true,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User should receive a SMS invite (default is True).")]
		[System.Boolean]$SendEmailInvite = $true,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify if the User should receive a SMS invite (default is False).")]
		[System.Boolean]$SendSmsInvite = $false,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Description for the User to create.")]
		[System.String]$Description,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Office Number for the User to create.")]
		[System.String]$OfficeNumber,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Home Number for the User to create.")]
		[System.String]$HomeNumber,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Mobile Number for the User to create.")]
		[System.String]$MobileNumber,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Picture for the User to create.")]
		[System.String]$Picture,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Picture file name for the User to create.")]
		[System.String]$fileName,
	
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Manager for the User to create.")]
		[System.String]$Manager
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

		# Setup variable for query
		$Uri = ("https://{0}/cDirectoryService/CreateUser" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Create hashtable of values
		$hashtable = @{}
		# Account (mandatory fields)
		$hashtable.Add("textfield-1306-inputEl", $Login)
		$hashtable.Add("loginsuffixfield-1309-inputEl", $LoginSuffix)
		$hashtable.Add("Mail", $Mail)
		$hashtable.Add("DisplayName", $DisplayName)
		$hashtable.Add("Password", $Password)
		$hashtable.Add("confirmPassword", $Password)
		# Account (constructed fields)
		$UserName = ("{0}@{1}" -f $Login, $LoginSuffix)
		$hashtable.Add("Name", $UserName)
		$hashtable.Add("ID", "")
		$hashtable.Add("state", "None")
		# Status
		$hashtable.Add("enableState", $Enabled)
		$hashtable.Add("PasswordNeverExpire", $PasswordNeverExpire)
		$hashtable.Add("ForcePasswordChangeNext", $ForcePasswordChangeNext)
		$hashtable.Add("InEverybodyRole", $InEverybodyRole)
		$hashtable.Add("SendEmailInvite", $SendEmailInvite)
		$hashtable.Add("SendSmsInvite", $SendSmsInvite)
		# Profile
		$hashtable.Add("Description", $Description)
		$hashtable.Add("OfficeNumber", $OfficeNumber)
		$hashtable.Add("HomeNumber", $HomeNumber)
		$hashtable.Add("MobileNumber", $MobileNumber)		
		$hashtable.Add("Picture", $Picture)
		$hashtable.Add("fileName", $fileName)
		# Organization
		$hashtable.Add("ReportsTo", $Manager)

		# Format Json query
		$Json = "{"
		foreach ($entry in $hashtable.GetEnumerator())
		{
			$Json += ("`"{0}`":`"{1}`"," -f $entry.Name, $entry.Value)
		}
		$Json += "`"`":null}"		

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
		Write-Debug ("Json= {0}" -f $Json)
		
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return User
			return (Get-CisUser | Where-Object { $_.UserName -eq $UserName })
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
