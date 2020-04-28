################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet supports ability to create new CisEnrollmentCode.

.DESCRIPTION
This CMDlet supports ability to create new CisEnrollmentCode. 

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
C:\PS> $CisEnrollmentCode = New-CisEnrollmentCode -Role "Administrators" 
Get a new CisEnrollmentCode and place in the $CisEnrollmentCode variable
#>
function global:New-CisEnrollmentCode
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
		# Get current connection to the Centrify Cloud Platform
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Adding Enrollment Code
		$Uri = ("https://{0}/ServerAgent/AddEnrollmentCode" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("ContentType= {0}" -f $ContentType)
		
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
			
		# Create hashtable of values
		$hashtable = @{}
		# Enrollment Code
		$hashtable.Add("OwnerType", "Role")
		$hashtable.Add("OwnerID", $CisRole.Id)
		$hashtable.Add("Owner", $CisRole.Name)
		$hashtable.Add("Description", $Description)
		if ([System.String]::IsNullOrEmpty($ExpiryDate))
		{
			# No ExpiryDate given
			$hashtable.Add("NeverExpire", "true")
		}
		else
		{
			# Set ExpiryDate - Use short date pattern
			$hashtable.Add("NeverExpire", "false")
			$hashtable.Add("ExpiryDate", (Get-Date -Date $ExpiryDate -Format d))
		}
		if ([System.String]::IsNullOrEmpty($MaxUseCount))
		{
			# No MaxUseCount given
			$hashtable.Add("NoMaxUseCount", "true")
		}
		else
		{
			# Set MaxUseCount
			$hashtable.Add("NoMaxUseCount", "false")
			$hashtable.Add("MaxUseCount", $MaxUseCount)
		}
		if (-not [System.String]::IsNullOrEmpty($IPRange))
		{
			# Set IP Range(s)
			$RangeList = "["
			for($i = 0; $i -lt $IPRange.Count; $i++)
			{
				$RangeList += ("`"{0}`"" -f $IPRange[$i])
				# Add separator except for last value
				if ($i -ne ($IPRange.Count -1))
				{
					$RangeList += ","
				}
			}
			$RangeList += "]"
		}		
		# Format Json query
		$Json = "{"
		foreach ($entry in $hashtable.GetEnumerator())
		{
			$Json += ("`"{0}`":`"{1}`"," -f $entry.Name, $entry.Value)
		}
		$Json += "}"
		Write-Debug ("Json= {0}" -f $Json)
					
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
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
