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
This Cmdlet is in developement
#>
function global:Import-CentrifyPolicy
{
	param
	(
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the policy import file path.")]
		[System.String]$File,

		[Parameter(Mandatory = $false, HelpMessage = "Specify the policy name to import.")]
		[System.String]$Name
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

        # Load import file
        if (Test-Path -Path $File)
        {
            # Load policy data
            $PolicyData = Get-Content -Path $File | ConvertFrom-Json
            # Update policy name
            if ([System.String]::IsNullOrEmpty($Name))
            {
                # Append _Copy to policy name
                $PolicyData.Path = ("{0}_Copy" -f $PolicyData.Path)
            }
            else
            {
                # Use parameter to set policy name
                $PolicyData.Path = ("/Policy/{0}" -f $Name)
            }
        }
        # Policy is New
        $PolicyData | Add-Member -MemberType NoteProperty -Name "Newpolicy" -Value "True"

		# Setup variable for query
		$Uri = ("https://{0}/Policy/SavePolicyBlock3" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.policy = $PolicyData

        # Build Json query
		$Json = $JsonQuery | ConvertTo-Json 
	
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
					
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return nothing
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
