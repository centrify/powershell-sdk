################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet allows to get a CisEnrollmentCode

.DESCRIPTION
This CMDlet allows to get a CisEnrollmentCode.  

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
C:\PS> Get-CisEnrollmentCode.ps1 
This CmdLet does nothing

.EXAMPLE
C:\PS> Get-CisEnrollmentCode.ps1 -Role "Ocean" 
This CmdLet gets a CisEnrollmentCode for the specified Role
#>
function global:Get-CisEnrollmentCode
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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Get Enrolment Code(s)
		$Uri = ("https://{0}/ServerAgent/GetAllEnrollmentCodes" -f $CisConnection.PodFqdn)
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Format Result
			$Result = $WebResponseResult.Result.Results.Row | Select-Object -Property ID,Owner,OwnerType,OwnerID,Description,CreationTime,CreatedByID,CreatedBy,NeverExpire,ExpiryDate,IPRange,UseCount,NoMaxUseCount,MaxUseCount,EnrollmentCode
			# Apply filters
			if (-not [System.String]::IsNullOrEmpty($Role))
			{
				# Get Role details
				$CisRole = Get-CisRole -Filter $Role
				if ([System.String]::IsNullOrEmpty($CisRole))
				{
					# Role not found
					Throw ("No Role found with criteria '{0}'." -f $Role)
				}
				elseif ($CisRole.GetType().BaseType -eq [System.Array])
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

# SIG # Begin signature block
# MIIEKgYJKoZIhvcNAQcCoIIEGzCCBBcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUh1LI2kzyiruRXF2XQ8q5rzh3
# 002gggI3MIICMzCCAaCgAwIBAgIQxH+aGsBVZbxNZjfCW1OLZDAJBgUrDgMCHQUA
# MCkxJzAlBgNVBAMTHkNlbnRyaWZ5IFByb2Zlc3Npb25hbCBTZXJ2aWNlczAeFw0x
# NDA2MTEwODAwMTlaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD0ZhYnJpY2Ug
# VmlndWllcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxfURIpF7SU3RmrXd
# /Vww7ud2J0kZL+Sc//kJqxDmjxngCsBjpOqIKLgxsi5DxjZio0gk/aav6Ifk7ej4
# Mtp2IYY1L5EiAitYlRfFCGapnAolrbQ9r1fInmhpAJXiwxD+pedVA3pjQue1xhB7
# dvKZxfwxZqdNHVLPQr8vgCZzscsCAwEAAaNzMHEwEwYDVR0lBAwwCgYIKwYBBQUH
# AwMwWgYDVR0BBFMwUYAQj6wqZRzzWAIFIMGJqC9WlqErMCkxJzAlBgNVBAMTHkNl
# bnRyaWZ5IFByb2Zlc3Npb25hbCBTZXJ2aWNlc4IQ3lgycgf2r6dK3jpN2H3n5DAJ
# BgUrDgMCHQUAA4GBAGl0+syZ3Q+39hBNUyzigpjbswckp3gZc6PVO53a+bd+PFEG
# gi/96JeLpq3PDWZq1n12Kp9ZHsxiuzb0mWdbumw2p5laQWMlO40JQUJOoP64DPLL
# Ou7szPH6o89dHGJ2UDWYlU02Iiysa4hCv9sJaLesnetxlcY4Cdfdlo41LhvfMYIB
# XTCCAVkCAQEwPTApMScwJQYDVQQDEx5DZW50cmlmeSBQcm9mZXNzaW9uYWwgU2Vy
# dmljZXMCEMR/mhrAVWW8TWY3wltTi2QwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcC
# AQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYB
# BAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHl5whR5BOa3
# 24Bz8wMilfsuigcSMA0GCSqGSIb3DQEBAQUABIGAB2uS1jg+WcFyMk4uLQHAmyaM
# 4rF2CKgfQ1jGk98fLeOq8DJrFCK0iqFz4ekuZ1SgC2h/AT3rAMpQN2kGRPIMWLIU
# /ApZMlUFu5My5rlYvVpspSJ4Mtpelb3tEeJSmMy6CLm9f44WHgabOBdoEud+WAh2
# 3km+SHv3ZfJXCiAPjQg=
# SIG # End signature block
