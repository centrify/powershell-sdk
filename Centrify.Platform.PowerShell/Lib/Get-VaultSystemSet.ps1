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
This Cmdlet returns a PASCollection of PASSystem objects.

.DESCRIPTION
This Cmdlet returns a Set of PASSystems.

.PARAMETER Name
Mandatory Name of the System's Set to get

.INPUTS

.OUTPUTS
[PASCollection]

.EXAMPLE
C:\PS> Get-VaultSystemSet
Returns all existing Sets of PASSystem.

.EXAMPLE
C:\PS> Get-VaultSystemSet -Name "UAT Servers"
Returns the Set of PASSystem named 'UAT Servers'.
#>
function global:Get-VaultSystemSet
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
		# Get current connection to the Centrify Platform
		$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

		# Setup variable for the PASQuery
		$Uri = ("https://{0}/Collection/GetObjectCollectionsAndFilters" -f $PlatformConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }

		# Format Json query
		$JsonQuery = @{}
		$JsonQuery.NoBuiltins	= "True"
		$JsonQuery.ObjectType	= "Server"
		
		$Json = $JsonQuery | ConvertTo-Json
		
		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
				
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
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
