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
This Cmdlet send en email invitation to a User or Group of users from connected Directory Services.

.DESCRIPTION

.PARAMETER Filter
Optional [String] filter parameter to query on. Search for match will include the following attributes: "Username", "DisplayName", "Email", "Status", "LastInvite", "LastLogin"

.INPUTS

.OUTPUTS

.EXAMPLE

.EXAMPLE 
 C:\PS>  Invite-CentrifyUser -user "bcrab@aak0956"
 "bcrab" user will receive an invite via email .
.EXAMPLE
#>
function global:Invite-CentrifyUser
{
	param
	(
		[Parameter(Mandatory = $false, HelpMessage = "Specify the User to invite.")]
		[System.String]$User,

		[Parameter(Mandatory = $false, HelpMessage = "Show details.")]
		[Switch]$Detailed
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

		# Get object from connected Directory Services
		if (-not [System.String]::IsNullOrEmpty($User))
        {
            # Search for User
            $DirectoryServiceUser = Centrify.Platform.PowerShell.Core.DirectoryServiceQuery -User $User
            # Adding missing informations
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Type -Value "User"
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Guid -Value $DirectoryServiceUser.InternalName
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Name -Value $DirectoryServiceUser.SystemName

            # Validate Email is present
            if (-not [System.String]::IsNullOrEmpty($DirectoryServiceUser.EMail))
		    {
                # Setup variable for query
		        $Uri = ("https://{0}/UserMgmt/InviteUsers" -f $PlatformConnection.PodFqdn)
		        $ContentType = "application/json" 
		        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		        # Set Json query
		        $JsonQuery = @{}
		        $JsonQuery.EmailInvite	= "True"
		        $JsonQuery.Role = "Invited Users"
                $JsonQuery.Entities = @($DirectoryServiceUser)

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
                    # Return results
                    Write-Debug ("Invitation sent to {0}" -f $DirectoryServiceUser.EMail)
		        }
		        else
		        {
			        # Query error
			        Throw $WebResponseResult.Message
		        }
            }
            else
            {
                Write-Error ("No valid email found for user {0}." -f $DirectoryServiceUser.DisplayName)
            }
        }
	}
	catch
	{
		Throw $_.Exception   
	}
}
