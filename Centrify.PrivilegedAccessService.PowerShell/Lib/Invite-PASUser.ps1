###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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

.EXAMPLE
#>
function global:Invite-PASUser
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
		# Get current connection to the Centrify Cloud Platform
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Get object from connected Directory Services
		if (-not [System.String]::IsNullOrEmpty($User))
        {
            # Search for User
            $DirectoryServiceUser = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -User $User
            # Adding missing informations
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Type -Value "User"
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Guid -Value $DirectoryServiceUser.InternalName
            $DirectoryServiceUser | Add-Member -MemberType NoteProperty -Name Name -Value $DirectoryServiceUser.SystemName

            # Validate Email is present
            if (-not [System.String]::IsNullOrEmpty($DirectoryServiceUser.EMail))
		    {
                # Setup variable for query
		        $Uri = ("https://{0}/UserMgmt/InviteUsers" -f $PASConnection.PodFqdn)
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
		        $WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
