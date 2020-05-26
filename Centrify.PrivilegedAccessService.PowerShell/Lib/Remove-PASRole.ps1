###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet delete the specified PASRole from the system.

.DESCRIPTION
This CMDlet delete the specified PASRole from the system.
NOTE: Get-PASRole must be used to get the desired role.

.PARAMETER PASRole
[PASRole] to delete.

.INPUTS
[PASRole]

.OUTPUTS

.EXAMPLE
PS: C:\PS\Remove-PASRole -PASRole (Get-PASRole -Filter "Unused Role")
This CmdLet delete the Role named "Unused Role".
#>
function global:Remove-PASRole
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "[PASRole] to delete.")]
		[System.Object]$PASRole
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

	    # Setup variable for query
	    $Uri = ("https://{0}/saasManage/DeleteRoles" -f $PASConnection.PodFqdn)
	    $ContentType = "application/json" 
	    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
		
		# Get the PASRole ID
		if ([System.String]::IsNullOrEmpty($PASRole.ID))
		{
			Throw "Cannot get RoleID from given parameter."
		}
		else
		{
		    # Build JSON manually as API for Role deletion does expect the UUID given directly as an Array, instead of ID=<value>
		    $Json = ("[`"{0}`"]" -f $PASRole.ID)

		    # Debug informations
		    Write-Debug ("Uri= {0}" -f $Uri)
		    Write-Debug ("Json= {0}" -f $Json)
			
		    # Connect using RestAPI
		    $WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
