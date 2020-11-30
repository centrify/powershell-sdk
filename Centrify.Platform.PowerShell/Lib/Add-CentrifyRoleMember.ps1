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
This Cmdlet adds member(s) to a specified PASRole.

.DESCRIPTION
This Cmdlet adds member(s) to a specified Role. Members can be: Users, Groups, or other Roles.
NOTE: AD Groups of Domain Local scope cannot be added as members of any Role.

.PARAMETER PASRole
Mandatory PASRole add member(s) to.

.PARAMETER User
Optional user name of the User to add.

.PARAMETER Group
Optional group name of the Group to add.

.PARAMETER Role
Optional role name of the Role to add.

.INPUTS
[PASRole]

.OUTPUTS

.EXAMPLE
C:\PS> Add-CentrifyRoleMember -CentrifyRole (Get-CentrifyRole -Name "Sergeant") -User "bcrab@ocean.net"
Add AD user 'bcrab' from 'ocean.net' domain to specified role using PASRole parameter

.EXAMPLE
C:\PS> Get-CentrifyRole -Name "Sergeant" | Add-CentrifyRoleMember -Role "System Administrator"
Add role named 'Seargeant' to specified role using input object from pipeline
#>
function global:Add-CentrifyRoleMember
{
	[CmdletBinding(DefaultParameterSetName = "PASResource")]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Parameter(ParameterSetName = "User")]
		[Parameter(ParameterSetName = "Group")]
		[Parameter(ParameterSetName = "Role")]
		[System.Object]$CentrifyRole,

		[Parameter(Mandatory = $false, ParameterSetName = "User")]
		[System.String]$User,

		[Parameter(Mandatory = $false, ParameterSetName = "Group")]
		[System.String]$Group,

		[Parameter(Mandatory = $false, ParameterSetName = "Role")]
		[System.String]$Role
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/Roles/UpdateRole" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Adding target information
		if ([System.String]::IsNullOrEmpty($CentrifyRole.ID))
		{
			Throw "Cannot get RoleID from given parameter."
		}
		else
		{
            # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.Name 		= $CentrifyRole.ID
		    $JsonQuery.Description	= $CentrifyRole.Description

            # Validate Member
            if (-not [System.String]::IsNullOrEmpty($User))
            {
                # User Query
                $Member = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -User $User
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find User '{0}' in any Directory Services." -f $User)
                } 
    		    $JsonQuery.Users = @{"Add" = @($Member.InternalName)}
            }
            elseif (-not [System.String]::IsNullOrEmpty($Group))
            {
                # Group Query
                $Member = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -Group $Group
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find Group '{0}' in any Directory Services." -f $Group)
                } 
    		    $JsonQuery.Groups = @{"Add" = @($Member.InternalName)}
            }
            elseif (-not [System.String]::IsNullOrEmpty($Role))
            {
                # Role Query
                $Member = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -Role $Role
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find Role '{0}' in any Directory Services." -f $Role)
                } 
    		    $JsonQuery.Roles = @{"Add" = @($Member._ID)}
            }
		}

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
            return
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
