###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> Get-PASEnrollmentCode.ps1 
This CmdLet does nothing

.EXAMPLE
C:\PS> Get-PASEnrollmentCode.ps1 -Role "Ocean" 
This CmdLet gets a PASEnrollmentCode for the specified Role
#>
function global:Get-PASEnrollmentCode
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
		# Get current connection to the Centrify Cloud Platform
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Get Enrolment Code(s)
		$Uri = ("https://{0}/ServerAgent/GetAllEnrollmentCodes" -f $PASConnection.PodFqdn)
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Format Result
			$Result = $WebResponseResult.Result.Results.Row | Select-Object -Property ID,Owner,OwnerType,OwnerID,Description,CreationTime,CreatedByID,CreatedBy,NeverExpire,ExpiryDate,IPRange,UseCount,NoMaxUseCount,MaxUseCount,EnrollmentCode
			# Apply filters
			if (-not [System.String]::IsNullOrEmpty($Role))
			{
				# Get Role details
				$PASRole = Get-PASRole -Filter $Role
				if ([System.String]::IsNullOrEmpty($PASRole))
				{
					# Role not found
					Throw ("No Role found with criteria '{0}'." -f $Role)
				}
				elseif ($PASRole.GetType().BaseType -eq [System.Array])
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
