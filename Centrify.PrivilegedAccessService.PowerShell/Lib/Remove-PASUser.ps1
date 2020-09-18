###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This CMDlet delete the specified PASUser from the system.

.DESCRIPTION
This CMDlet delete the specified PASUser from the system.
NOTE: Get-PASUser must be used to get the desired user

.PARAMETER PASUser
Mandatory parameter [Object] PASUser  to remove.

.INPUTS
This CmdLet takes the following inputs: [Object] PASUser

.OUTPUTS
This CmdLet retruns nothing in case of success. Returns error message in case of error.

.EXAMPLE
PS: C:\PS\Remove-PASUser -PASUser (Get-PASUser -Filter "bcrab")
This CmdLet gets the use "bcrab" and deletes the object.
#>
function global:Remove-PASUser
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASUser(s) to delete.")]
		[System.Object]$PASUser
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
		
		# Get current connection to the Centrify Cloud Platform
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Setup variable for query
		$Uri = ("https://{0}/UserMgmt/RemoveUsers" -f $PASConnection.PodFqdn)
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
			if ([System.String]::IsNullOrEmpty($PASUser.ID))
			{
				Throw "Cannot get UserID from given parameter."
			}
			else
			{
				if ([system.String]::IsNullOrEmpty($UserIDList))
				{
					# First entry in the list
					$UserIDList = ("`"{0}`"" -f $PASUser.ID)
				}
				else
				{
					# Additional entries
					$UserIDList += (",`"{0}`"" -f $PASUser.ID)
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
			$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
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
