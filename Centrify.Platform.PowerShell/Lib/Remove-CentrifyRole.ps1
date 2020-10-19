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
This CMDlet delete the specified PASRole from the system.

.DESCRIPTION
This CMDlet delete the specified PASRole from the system.
NOTE: Get-CentrifyRole must be used to get the desired role.

.PARAMETER PASRole
[PASRole] to delete.

.INPUTS
[PASRole]

.OUTPUTS

.EXAMPLE
PS: C:\PS\Remove-CentrifyRole -PASRole (Get-CentrifyRole -Name "Unused Role")
This CmdLet delete the Role named "Unused Role".
#>
function global:Remove-CentrifyRole
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "[PASRole] to delete.")]
		[System.Object]$CentrifyRole
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
	    $Uri = ("https://{0}/saasManage/DeleteRoles" -f $PlatformConnection.PodFqdn)
	    $ContentType = "application/json" 
	    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
		
		# Get the PASRole ID
		if ([System.String]::IsNullOrEmpty($CentrifyRole.ID))
		{
			Throw "Cannot get RoleID from given parameter."
		}
		else
		{
		    # Build JSON manually as API for Role deletion does expect the UUID given directly as an Array, instead of ID=<value>
		    $Json = ("[`"{0}`"]" -f $CentrifyRole.ID)

		    # Debug informations
		    Write-Debug ("Uri= {0}" -f $Uri)
		    Write-Debug ("Json= {0}" -f $Json)
			
		    # Connect using RestAPI
		    $WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
		    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		    if ($WebResponseResult.Success)
		    {
			    # Success
			    Write-Debug "Role(s) deleted."
		    }
		    else
		    {
			    # Query error
			    Throw $WebResponseResult.Message
		    }
        }
	}
	catch
	{
		Throw $_.Exception   
	}
}
