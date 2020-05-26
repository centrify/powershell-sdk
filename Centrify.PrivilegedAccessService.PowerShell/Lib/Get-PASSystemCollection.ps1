###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet returns a PASCollection of PASSystem objects.

.DESCRIPTION
This Cmdlet returns a Set of PASSystems.

.PARAMETER Name
Mandatory Name of the System's Set to get

.INPUTS

.OUTPUTS
[PASCollection]

.EXAMPLE
C:\PS> Get-PASSystemCollection
Returns all existing Sets of PASSystem.

.EXAMPLE
C:\PS> Get-PASSystemCollection -Name "UAT Servers"
Returns the Set of PASSystem named 'UAT Servers'.
#>
function global:Get-PASSystemCollection
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
		$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

		# Setup variable for the PASQuery
		$Uri = ("https://{0}/Collection/GetObjectCollectionsAndFilters" -f $PASConnection.PodFqdn)
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			if ([System.String]::IsNullOrEmpty($Name))
            {
                # Return all Collections
                $PASCollections = $WebResponseResult.Result.Results.Row | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
            else
            {
                # Return Collection by Name
                $PASCollections = $WebResponseResult.Result.Results.Row | Where-Object { $_.Name -eq $Name } | Select-Object -Property ID, Name, CollectionType, ObjectType, Filters
            }
            # Convert Result into PASCollection with Members ID listed instead of Filters
            $Result = @()

            $PASCollections | ForEach-Object {
                # Create a PASCollection Object
                $PASCollection = New-Object System.Object
                $PASCollection | Add-Member -MemberType NoteProperty -Name ID -Value $_.ID
                $PASCollection | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name
                $PASCollection | Add-Member -MemberType NoteProperty -Name CollectionType -Value $_.CollectionType
                $PASCollection | Add-Member -MemberType NoteProperty -Name ObjectType -Value $_.ObjectType

                # Get Members from Filters
                $PASCollection | Add-Member -MemberType NoteProperty -Name Members -Value $_.Filters.Split("in ")[-1].Split(",").Replace("'","").Replace("(","").Replace(")","")

                # Add modified object to result
                $Result += $PASCollection | Select-Object -Property ID, Name, CollectionType, ObjectType, Members
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
