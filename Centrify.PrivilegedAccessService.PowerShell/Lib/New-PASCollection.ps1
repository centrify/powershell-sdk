###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
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
C:\PS> New-PASCollection -Name "Development Unix Systems" -CollectionType "Dynamic" -ObjectType "System" 
Create a new, dynamic collection labeled "Development Unix Systems" managing "System" object types
#>
function global:New-PASCollection
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
	
	# Get current connection to the Centrify Cloud Platform
	$PASConnection = Centrify.PrivilegedAccessService.PowerShell.Core.GetPASConnection

	try
	{	
		# Validate what Collection Type is to be used
        if ($CollectionType -eq "Manual")
        {
            # Creating new Manual Set
            # Setup variable for query
		    $Uri = ("https://{0}/Collection/CreateManualCollection" -f $PASConnection.PodFqdn)
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
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PASConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return new Collection
            switch ($ObjectType)
            {
		        "Systems" {
                    $NewCollection = Get-PASSystemCollection -Name $Name
                }
		        "Domains" {
                    $NewCollection = Get-PASDomainCollection -Name $Name
                }
		        "Databases" {
                    $NewCollection = Get-PASDatabaseCollection -Name $Name
                }
		        "Secrets" {
                    $NewCollection = Get-PASSecretCollection -Name $Name
                }
		        "Services" {
                    $NewCollection = Get-PASServiceCollection -Name $Name
                }
		        "Accounts" {
                    $NewCollection = Get-PASAccountCollection -Name $Name
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
