################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet delete the specified CisUser from the system.

.DESCRIPTION
This CMDlet delete the specified CisUser from the system.
NOTE: Get-CisUser must be used to get the desired user

.PARAMETER CisUser
Mandatory parameter [Object] CisUser  to remove.

.INPUTS
This CmdLet takes the following inputs: [Object] CisUser

.OUTPUTS
This CmdLet retruns nothing in case of success. Returns error message in case of error.

.EXAMPLE
PS: C:\PS\Remove-CisUser.ps1 -CisUser (Get-CisUser -Filter "bcrab")
This CmdLet gets the use "bcrab" and deletes the object.
#>
function global:Remove-CisUser
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the CisUser(s) to delete.")]
		[System.Object]$CisUser
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
		$CisConnection = Centrify.IdentityServices.PowerShell.Core.GetCisConnection

		# Setup variable for query
		$Uri = ("https://{0}/UserMgmt/RemoveUsers" -f $CisConnection.PodFqdn)
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
			# Get the CisUser ID
			if ([System.String]::IsNullOrEmpty($CisUser.ID))
			{
				Throw "Cannot get UserID from given parameter."
			}
			else
			{
				if ([system.String]::IsNullOrEmpty($UserIDList))
				{
					# First entry in the list
					$UserIDList = ("`"{0}`"" -f $CisUser.ID)
				}
				else
				{
					# Additional entries
					$UserIDList += (",`"{0}`"" -f $CisUser.ID)
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
			# Format Json query
			$Json = ("{{`"Users`":[{0}]}}" -f $UserIDList) 

			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("Json= {0}" -f $Json)
			
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
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
