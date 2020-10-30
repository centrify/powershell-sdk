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
This CMDlet supports ability to create new PASCollection objects.

.DESCRIPTION
This CMDlet supports ability to create new PASCollection objects.

This CmdLet takes the following mandatory parameters as input: [String] Name, [String] CollectionType, [String] ObjectType
This CmdLet accepts the following optional parameters as input: [String] Description.

This CmdLet outputs the new PASCollection object created upon success. Outputs failure message upon failure.

.PARAMETER Name
Mandatory [String] Name parameter used to specificy the Collection name.

.PARAMETER Description
Optional [String] Description parameter used to specificy the Collection Description.

.PARAMETER CollectionType
Mandatory [String] CollectionType parameter used to specificy the Collection Type (i.e. Manual or Dynamic).

.PARAMETER ObjectType
Mandatory [String] string parameter used to specify Object Type (i.e. Systems, Domains, Databases, Services, Secrets, Accounts).

.INPUTS
This CmdLet takes the following mandatory parameters as input: [String] Name, [String] CollectionType, [String] ObjectType
This CmdLet accepts the following optional parameters as input: [String] Description

.OUTPUTS
This CmdLet outputs the new PASCollection object created upon success. Outputs failure message upon failure.

.EXAMPLE
C:\PS> New-CentrifySet -Name "Development-Unix Systems" -CollectionType "Manual" -ObjectType "Systems"
Create a new, manual collection labeled "Development-Unix Systems" managing "Systems" object types
#>
function global:New-CentrifySet
{
	[CmdletBinding(DefaultParameterSetName = "TextType")]
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify Collection name.")]
		[System.String]$Name,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify Collection description.")]
		[System.String]$Description,

		[Parameter(Mandatory = $true, HelpMessage = "Specify Collection Type (i.e. Manual or Dynamic).")]
		[ValidateSet("Manual", "Dynamic", IgnoreCase = $false)]
		[System.String]$CollectionType,

		[Parameter(Mandatory = $true, HelpMessage = "Specify Object Type (i.e. Systems, Domains, Databases, Services, Secrets, Accounts).")]
		[ValidateSet("Systems", "Domains", "Databases", "Services", "Secrets", "Accounts", IgnoreCase = $false)]
		[System.String]$ObjectType
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
	
	# Get current connection to the Centrify Platform
	$PlatformConnection = Centrify.Platform.PowerShell.Core.GetPlatformConnection

	try
	{	
		# Validate what Collection Type is to be used
        if ($CollectionType -eq "Manual")
        {
            # Creating new Manual Set
            # Setup variable for query
		    $Uri = ("https://{0}/Collection/CreateManualCollection" -f $PlatformConnection.PodFqdn)
		    $ContentType = "application/json" 
		    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		    # Set Json query
		    $JsonQuery = @{}
		    $JsonQuery.Name 			= $Name
		    $JsonQuery.CollectionType	= "ManualBucket"
		    
            if (-not [System.String]::IsNullOrEmpty($Description))
            {
                $JsonQuery.Description	= $Description
            }

		    # Validate Object Type
            switch ($ObjectType)
            {
		        "Systems" {
                    $JsonQuery.ObjectType = "Server"
                }
		        "Domains" {
                    $JsonQuery.ObjectType = "VaultDomain"
                }
		        "Databases" {
                    $JsonQuery.ObjectType = "VaultDatabase"
                }
		        "Secrets" {
                    $JsonQuery.ObjectType = "DataVault"
                }
		        "Services" {
                    $JsonQuery.ObjectType = "Subscriptions"
                }
		        "Accounts" {
                    $JsonQuery.ObjectType = "VaultAccount"
                }
            }
        }
        elseif ($CollectionType -eq "Dynamic")
        {
            # NOT IMPLEMENTED
            Write-Warning "Dynamic Collections not yet implemented."
            Exit
        }
        else
        {
            Throw "Unknown Collection Type"
        }

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
			# Success return new Collection
            switch ($ObjectType)
            {
		        "Systems" {
                    $NewCollection = Get-VaultSystemSet -Name $Name
                }
		        "Domains" {
                    $NewCollection = Get-VaultDomainCollection -Name $Name
                }
		        "Databases" {
                    $NewCollection = Get-VaultDatabaseCollection -Name $Name
                }
		        "Secrets" {
                    $NewCollection = Get-VaultSecretSet -Name $Name
                }
		        "Services" {
                    $NewCollection = Get-PASServiceCollection -Name $Name
                }
		        "Accounts" {
                    $NewCollection = Get-VaultAccountSet -Name $Name
                }
            }
            return $NewCollection
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
