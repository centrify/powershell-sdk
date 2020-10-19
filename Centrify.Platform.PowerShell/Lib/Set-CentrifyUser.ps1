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
C:\PS> Set-CentrifyUser -User (Get-CentrifyUser -Filter "bcrab")

.EXAMPLE
C:\PS> Set-CentrifyUser -User (Get-CentrifyUser -Filter "bcrab") -MobileNumber "5555555555"
Updates the MobileNumber attribute for PASUser "bcrab" 
#>
function global:Set-CentrifyUser
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASUser to set Attributes to.")]
		[System.Object]$CentrifyUser,
		
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
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for query
		$Uri = ("https://{0}/CDirectoryService/ChangeUser" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Format Json query
		if ($CentrifyUser.SourceDsType -eq "CDS")
		{
		    # Get PASUser Attributes and save it as a Centrify Directory Service User
		    $CDSUser = Centrify.Platform.PowerShell.Core.GetUserAttributes $CentrifyUser.ID
		    if ($CDSUser -eq [Void]$null)
		    {
			    Throw "Unable to get PASUser attributes"
		    }

            # Keep PASUser values unless Parameter is given for Update
            if ([System.String]::IsNullOrEmpty($LoginName))
		    {
			    $LoginName = $CentrifyUser.UserName.Split('@')[0]
		    }
		    if ([System.String]::IsNullOrEmpty($LoginSuffix))
		    {
			    $LoginSuffix = $CentrifyUser.UserName.Split('@')[1]
		    }
		    if ([System.String]::IsNullOrEmpty($Mail))
		    {
			    $Mail = $CDSUser.Mail
		    }
		    if ([System.String]::IsNullOrEmpty($DisplayName))
		    {
			    $DisplayName = $CDSUser.DisplayName
		    }
		    if ([System.String]::IsNullOrEmpty($Description))
		    {
			    $Description = $CDSUser.Description
		    }
		    if ([System.String]::IsNullOrEmpty($OfficeNumber))
		    {
			    $OfficeNumber = $CDSUser.TelephoneNumber
		    }
		    if ([System.String]::IsNullOrEmpty($HomeNumber))
		    {
			    $HomeNumber = $CDSUser.HomePhone
		    }
		    if ([System.String]::IsNullOrEmpty($MobileNumber))
		    {
			    $MobileNumber = $CDSUser.Mobile
		    }

		    # Set Json query
		    $JsonQuery = @{}
            $JsonQuery.ID = $CDSUser.Uuid
            $JsonQuery.Name = ("{0}@{1}" -f $LoginName, $LoginSuffix)
            $JsonQuery.LoginName = $LoginName
            $JsonQuery.'loginsuffixfield-1363-inputEl' = $LoginSuffix
            $JsonQuery.LoginName = $LoginName
            $JsonQuery.Mail = $Mail
            $JsonQuery.LoginName = $LoginName
            $JsonQuery.Description = $Description
            $JsonQuery.OfficeNumber = $OfficeNumber
            $JsonQuery.HomeNumber = $HomeNumber
            $JsonQuery.MobileNumber = $MobileNumber

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
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
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
