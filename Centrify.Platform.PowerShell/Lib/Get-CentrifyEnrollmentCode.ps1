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
This CMDlet allows to get a PASEnrollmentCode

.DESCRIPTION
This CMDlet allows to get a PASEnrollmentCode.  

Enrollment will drop a Certificate on the LocalMachine store and create a Service User account on the Centrify Directory for the machine (exact equivalent to cenroll behaviour on Linux).
This Cmdlet takes the following optional inputs: [String] Role, [String] ExpiryDateAfter, [Switch] NeverExpire

.PARAMETER Role
Optional parameter [String] Role to use to enroll this resource.

.PARAMETER ExpiryDateAfter
Optional parameter [String] ExpiryDateAfter to optionally get enrollment code(s) that expire after this date.
NOTE: Date must be in format, "dd/mo/year".  Ex: "06/20/2020"

.PARAMETER ExpiryDateBefore
Optional parameter [String] ExpiryDateBefore to optionally set a description for this resource. 
NOTE: Date must be in format, "dd/mo/yr".  Ex: "06/20/2020"

.PARAMETER NeverExpire
Optional parameter [Switch] NeverExpire name for this resource.

.INPUTS
This Cmdlet takes the following optional inputs: [String] Role, [String] ExpiryDateAfter, [Boolean] ExpiryDateBefore, [Switch] NeverExpire

.OUTPUTS
This CmdLet returns the result on success. Returns failure message on failure.

.EXAMPLE
C:\PS> Get-CentrifyEnrollmentCode.ps1 
This CmdLet does nothing

.EXAMPLE
C:\PS> Get-CentrifyEnrollmentCode -Role "Ocean" 
This CmdLet gets a PASEnrollmentCode for the specified Role
#>
function global:Get-CentrifyEnrollmentCode
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Name of the role for wich to get enrollment code(s).")]
		[System.String]$Role,
		
		[Parameter(Mandatory = $false, HelpMessage = "Get enrollment code(s) that expire after this date.")]
		[System.DateTime]$ExpiryDateAfter,

		[Parameter(Mandatory = $false, HelpMessage = "Get enrollment code(s) that expire before this date.")]
		[System.String]$ExpiryDateBefore,
		
		[Parameter(Mandatory = $false, HelpMessage = "Get enrollment code(s) that never expire.")]
		[Switch]$NeverExpire
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

		# Get Enrolment Code(s)
		$Uri = ("https://{0}/ServerAgent/GetAllEnrollmentCodes" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json"
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1
		
		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.RRFormat	= "true"
		$JsonQuery.Args		= $Arguments
		
		$Json = $JsonQuery | ConvertTo-Json 
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Format Result
			$Result = $WebResponseResult.Result.Results.Row | Select-Object -Property ID,Owner,OwnerType,OwnerID,Description,CreationTime,CreatedByID,CreatedBy,NeverExpire,ExpiryDate,IPRange,UseCount,NoMaxUseCount,MaxUseCount,EnrollmentCode
			# Apply filters
			if (-not [System.String]::IsNullOrEmpty($Role))
			{
				# Get Role details
				$CentrifyRole = Get-CentrifyRole -Filter $Role
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
				# Filter Result by Role
				$Result = $Result | Where-Object { $_.Owner -eq $Role }
			}
			if ($NeverExpire.IsPresent)
			{
				# Filter Result by Date
				$Result = $Result | Where-Object { $_.NeverExpire -eq $true}
			}
			if (-not [System.String]::IsNullOrEmpty($ExpiryDateAfter))
			{
				# Filter Result by Date
				$Result = $Result | Where-Object { $_.NeverExpire -eq $false -and $_.ExpiryDate -gt $ExpiryDateAfter }
			}
			if (-not [System.String]::IsNullOrEmpty($ExpiryDateBefore))
			{
				# Filter Result by Date
				$Result = $Result | Where-Object { $_.NeverExpire -eq $false -and $_.ExpiryDate -lt $ExpiryDateBefore }
			}
			# Return filtered result
			return $Result
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
