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
This CMDlet supports ability to create new PASEnrollmentCode.

.DESCRIPTION
This CMDlet supports ability to create new PASEnrollmentCode. 

This CmdLet takes following mandatory inputs: [String] Role
This CmdLet takes following optional inputs: , [String] ExpiryDate, [String] MaxUseCount, [String] Description, [String] IPRange

.PARAMETER Role
Mandatory [String] parameter used to specify the Name of the role that will be owner of the new enrollment code.

.PARAMETER ExpiryDate
Optional [DateTime]  parameter used to specify the expiry date for this code (if none given then code will never expire

.PARAMETER MaxUseCount
Optional [String]  parameter used to specificy maximum use count for this code (if none given then code can be used for a unlimited number of resources).

.PARAMETER Description
Optional [String]  parameter used to specify the description for this enrollment code.

.PARAMETER IPRange
Optional [String[]] parameter used to specify the IP Range allowed for resource enrollment.

.INPUTS
This CmdLet takes following mandatory inputs: [String] Role
This CmdLet takes following optional inputs: , [String] ExpiryDate, [String] MaxUseCount, [String] Description, [String[]] IPRange

.OUTPUTS
This CmdLet returns  enrollment code in case of success. Returns error in case of error.

.EXAMPLE
C:\PS> $EnrollmentCode = New-CentrifyEnrollmentCode -Role "Administrators" 
Get a new Centrify Enrollment Code and place in the $EnrollmentCode variable
#>
function global:New-CentrifyEnrollmentCode
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Name of the role that will be owner of the new enrollment code.")]
		[System.String]$Role,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the expiry date for this code (if none given then code will never expire).")]
		[System.DateTime]$ExpiryDate,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the maximum use count for this code (if none given then code can be used for a unlimited number of resources).")]
		[System.DateTime]$MaxUseCount,
		
		[Parameter(Mandatory = $false, HelpMessage = "Optionally set a description for this enrollment code.")]
		[System.Int64]$Description,

		[Parameter(Mandatory = $false, HelpMessage = "IP Range allowed for resource enrollment.")]
		[System.String[]]$IPRange
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

		# Adding Enrollment Code
		$Uri = ("https://{0}/ServerAgent/AddEnrollmentCode" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
		
		# Get Role details
		$CentrifyRole = Get-CentrifyRole -Name $Role
		if ([System.String]::IsNullOrEmpty($CentrifyRole))
		{
			# Role not found
			Throw ("No Role found with criteria '{0}'." -f $Role)
		}
		elseif ($CentrifyRole.GetType().BaseType -eq [System.Array])
		{
			# Too much Roles found
			Throw ("There is more than one Role found with criteria '{0}'." -f $Role)
		}
			
		# Format Json query
		$JsonQuery = @{}
		# Enrollment Code
		$JsonQuery.Add("OwnerType", "Role")
		$JsonQuery.Add("OwnerID", $CentrifyRole.Id)
		$JsonQuery.Add("Owner", $CentrifyRole.Name)
		$JsonQuery.Add("Description", $Description)
		if ([System.String]::IsNullOrEmpty($ExpiryDate))
		{
			# No ExpiryDate given
			$JsonQuery.Add("NeverExpire", "true")
		}
		else
		{
			# Set ExpiryDate - Use short date pattern
			$JsonQuery.Add("NeverExpire", "false")
			$JsonQuery.Add("ExpiryDate", (Get-Date -Date $ExpiryDate -Format d))
		}
		if ([System.String]::IsNullOrEmpty($MaxUseCount))
		{
			# No MaxUseCount given
			$JsonQuery.Add("NoMaxUseCount", "true")
		}
		else
		{
			# Set MaxUseCount
			$JsonQuery.Add("NoMaxUseCount", "false")
			$JsonQuery.Add("MaxUseCount", $MaxUseCount)
		}
		if (-not [System.String]::IsNullOrEmpty($IPRange))
		{
			# Set IP Range(s)
			$JsonQuery.Add("IPRange", $IPRange)
		}		
        # Build Json query
		$Json = $JsonQuery | ConvertTo-Json 
					
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Enrollment Cose
			return $WebResponseResult.Result.EnrollmentCode
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
