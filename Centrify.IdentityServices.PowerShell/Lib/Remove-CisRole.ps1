################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet delete the specified CisRole from the system.

.DESCRIPTION
This CMDlet delete the specified CisRole from the system.
NOTE: Get-CisRole must be used to get the desired role.

.PARAMETER CisRole
[CisRole] to delete.

.INPUTS
[CisRole]

.OUTPUTS

.EXAMPLE
PS: C:\PS\Remove-CisRole -CisRole (Get-CisRole -Filter "Unused Role")
This CmdLet delete the Role named "Unused Role".
#>
function global:Remove-CisRole
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "[CisRole] to delete.")]
		[System.Object]$CisRole
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

	    # Setup variable for query
	    $Uri = ("https://{0}/saasManage/DeleteRoles" -f $CisConnection.PodFqdn)
	    $ContentType = "application/json" 
	    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
		
		# Get the CisRole ID
		if ([System.String]::IsNullOrEmpty($CisRole.ID))
		{
			Throw "Cannot get RoleID from given parameter."
		}
		else
		{
		    # Build JSON manually as API for Role deletion does expect the UUID given directly as an Array, instead of ID=<value>
		    $Json = ("[`"{0}`"]" -f $CisRole.ID)

		    # Debug informations
		    Write-Debug ("Uri= {0}" -f $Uri)
		    Write-Debug ("Json= {0}" -f $Json)
			
		    # Connect using RestAPI
		    $WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
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
