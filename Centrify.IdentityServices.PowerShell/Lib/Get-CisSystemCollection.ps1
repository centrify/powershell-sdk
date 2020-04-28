################################################
# Centrify Cloud Platform unofficial PowerShell Module
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This Cmdlet returns a CisCollection of CisSystem objects.

.DESCRIPTION
This Cmdlet returns a Set of CisSystems.

.PARAMETER Name
Mandatory Name of the System's Set to get

.INPUTS

.OUTPUTS
[CisCollection]

.EXAMPLE
C:\PS> Get-CisSystemCollection
Returns all existing Sets of CisSystem.

.EXAMPLE
C:\PS> Get-CisSystemCollection -Name "UAT Servers"
Returns the Set of CisSystem named 'UAT Servers'.
#>
function global:Get-CisSystemCollection
{
	param
	(
		[Parameter(Mandatory = $false)]
		[System.String]$Name
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

		# Setup variable for the CisQuery
		$Uri = ("https://{0}/Collection/GetObjectCollectionsAndFilters" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Set Arguments
		$Arguments = @{}
		$Arguments.PageNumber 	= 1
		$Arguments.PageSize 	= 10000
		$Arguments.Limit	 	= 10000
		$Arguments.SortBy	 	= ""
		$Arguments.Direction 	= "False"
		$Arguments.Caching	 	= -1

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.NoBuiltins	= "True"
		$JsonQuery.ObjectType	= "Server"
		$JsonQuery.Args			= $Arguments
		
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Return all Collections
                $CisCollections = $WebResponseResult.Result.Results.Row | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
            else
            {
                # Return Collection by Name
                $CisCollections = $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name } | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
            # Convert Result into CisCollection with Members ID listed instead of Filters
            $Result = @()

            $CisCollections | ForEach-Object {
                # Create a CisCollection Object
                $CisCollection = New-Object System.Object
                $CisCollection | Add-Member -MemberType NoteProperty -Name ID -Value $_.ID
                $CisCollection | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name
                $CisCollection | Add-Member -MemberType NoteProperty -Name CollectionType -Value $_.CollectionType
                $CisCollection | Add-Member -MemberType NoteProperty -Name ObjectType -Value $_.ObjectType

                # Get Members from Filters
                $CisCollection | Add-Member -MemberType NoteProperty -Name Members -Value $_.Filters.Split("in ")[-1].Split(",").Replace("'","").Replace("(","").Replace(")","")

                # Add modified object to result
                $Result += $CisCollection | Select-Object -Property ID, Name, CollectionType, ObjectType, Members
            }
            # Return Result
            return $Result
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
