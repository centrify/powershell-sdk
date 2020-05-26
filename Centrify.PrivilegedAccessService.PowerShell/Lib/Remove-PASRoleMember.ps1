###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet retrieves removes the specified [Object] PASRole from the system.

.DESCRIPTION
This CMDlet retrieves removes the specified [Object] PASRole from the system.
NOTE: Get-PASRole CmdLet must be used to acquire the desired [Object] PASRole to remove.

.PARAMETER PASRole
Mandatory parameter [Object] PASRole to remove. 

.PARAMETER User
Optional [String] User parameter representing the user to remove from the role member list.

.PARAMETER Group
Optional [String] Group parameter representing the group to remove from the role member list.

.PARAMETER Role
Optional [String] Role parameter representing the role to remove from the role member list.

.INPUTS 
This CmdLet takes as input the following required parameters: [Object] PASRole
This CmdLet takes as input the following optional parameters: [String] User, [String] Group,  [String] Role 

.OUTPUTS
This Cmdlet returns nothing in case of success. Returns failure message in case of failure.

.EXAMPLE
C:\PS> Remove-PASRoleMember -PASRole (Get-PASRole -Name "System Administrator") -User "bcrab@cps.ocean.net"
Removes "bcrab@cps.ocean.net" user from the "System Administrator" role

.EXAMPLE
C:\PS> Remove-PASRoleMember -PASRole (Get-PASRole -Name "System Administrator") -Group "Seargeants"
Removes "bcrab@cps.ocean.net" from the "Seargeants" group

.EXAMPLE
C:\PS> Remove-PASRoleMember -PASRole (Get-PASRole -Name "System Administrator") -Role "NightWatch"
Removes "NightWatch" Role from the "System Administrator" role
#>
function global:Remove-PASRoleMember
{
	[CmdletBinding(DefaultParameterSetName = "PASResource")]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the PASRole to add the member to")]
		[Parameter(ParameterSetName = "User")]
		[Parameter(ParameterSetName = "Group")]
		[Parameter(ParameterSetName = "Role")]
		[System.Object]$PASRole,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "User", HelpMessage = "Specify the User to add as a member.")]
		[System.String]$User,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Group", HelpMessage = "Specify the Group to add as a member.")]
		[System.String]$Group,

		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Role", HelpMessage = "Specify the Role to add as a member.")]
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
	
	# Get current connection to the Centrify Cloud Platform
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Setup variable for query
		$Uri = ("https://{0}/Roles/UpdateRole" -f $PASConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		# Adding target information
		if ([System.String]::IsNullOrEmpty($PASRole.ID))
		{
			Throw "Cannot get RoleID from given parameter."
		}
		else
		{
            # Validate Member
            if (-not [System.String]::IsNullOrEmpty($User))
            {
                # User Query
                $Member = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -User $User
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find User '{0}' in any Directory Services." -f $User)
                } 
            }
            elseif (-not [System.String]::IsNullOrEmpty($Group))
            {
                # Group Query
                $Member = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -Group $Group
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find Group '{0}' in any Directory Services." -f $Group)
                } 
            }
            elseif (-not [System.String]::IsNullOrEmpty($Role))
            {
                # Role Query
                $Member = Centrify.PrivilegedAccessService.PowerShell.Core.DirectoryServiceQuery -Role $Role
                if ($Member -eq [void]$null)
                {
                    Throw ("Cannot find Role '{0}' in any Directory Services." -f $Role)
                } 
            }
            
            # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.Name 		= $PASRole.ID
		    $JsonQuery.Description	= $PASRole.Description
		    $JsonQuery.Users		= @{"Delete" = @($Member.InternalName)}
		}

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
