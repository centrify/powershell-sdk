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
This CMDlet delete the specified PASUser from the system.

.DESCRIPTION
This CMDlet delete the specified PASUser from the system.
NOTE: Get-CentrifyUser must be used to get the desired user

.PARAMETER PASUser
Mandatory parameter [Object] PASUser  to remove.

.INPUTS
This CmdLet takes the following inputs: [Object] PASUser

.OUTPUTS
This CmdLet retruns nothing in case of success. Returns error message in case of error.

.EXAMPLE
PS: C:\PS\ Remove-CentrifyUser -CentrifyUser (Get-CentrifyUser -Filter  "bcrab")
This CmdLet gets the use "bcrab" and deletes the object.
#>
function global:Remove-CentrifyUser
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASUser(s) to delete.")]
		[System.Object]$CentrifyUser
	)
	
	# Pre-Pipeline steps
	begin
	{
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
		
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for query
		$Uri = ("https://{0}/UserMgmt/RemoveUsers" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
		
		# Prepare UserList
		$UserIDList = ""
	}
	
	# Pipeline processing
	process
	{
		try
		{
			# Get the PASUser ID
			if ([System.String]::IsNullOrEmpty($CentrifyUser.ID))
			{
				Throw "Cannot get UserID from given parameter."
			}
			else
			{
				if ([system.String]::IsNullOrEmpty($UserIDList))
				{
					# First entry in the list
					$UserIDList = ("`"{0}`"" -f $CentrifyUser.ID)
				}
				else
				{
					# Additional entries
					$UserIDList += (",`"{0}`"" -f $CentrifyUser.ID)
				}
			}
		}
		catch
		{
			Throw $_.Exception   
		}
	}
	
	# Post-Pipeline steps
	end
	{
		try
		{
		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.Users = $UserIDList

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
				# Success
				Write-Debug "User(s) deleted."
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
}
