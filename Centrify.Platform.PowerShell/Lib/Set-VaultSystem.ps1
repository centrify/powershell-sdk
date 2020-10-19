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
This Cmdlet sets important attributes on an existing PASSystem
.DESCRIPTION
This Cmdlet sets important attributes on an existing PASSystem.
The following parameters are mandatory: [Object] PASSystem
NOTE: Get-VaultSystem commandlet must be used to acquire the PASSystem object to update

The following parameters are optional:

[String] Name, [String] Fqdn, [String] ComputerClass, [String] SessionType, [Int32] Port, 
[String] Description, [String] ProxyUser, [String] ProxyUserPassword, 
[Boolean] ProxyUserIsManaged, [String] ManagementMode, [Int32] ManagementPort, 
[Boolean] AllowPasswordRotation, [Int32] PasswordHistoryCleanupDuration, 
[Boolean] AllowHealthCheck, [Int32] HealthCheckInterval, 
[Int32] DefaultCheckoutTime, [String] ProxyCollectionList

Upon succesful update, the PASSystem object will be displayed.

.PARAMETER PASSystem
Mandatory PASSystem object parameter to specify the PASSystem to update.
NOTE: Get-VaultSystem commandlet must be used to acquire the object

.PARAMETER Name
Optional parameter to specify [String] Name of the resource.

.PARAMETER Fqdn
Optional parameter to specify the [String] FQDN (Fully qualified DNS name) or the IP address to use to connect to this resource.

.PARAMETER ComputerClass
Optional parameter to specify the [String] ComputerClass value to set. Valid parameters are: [String] "Windows", [String] "Unix", [String] [String] "CiscoIOS", [String] "CiscoNXOS", [String] "JuniperJunos", [String] "GenericSsh"

.PARAMETER SessionType
Optional parameter to specify the session type of this resource. Valid parameters are: [String] "Rdp", [String] "Ssh".

.PARAMETER Port
Optional parameter to specify the [Int32] port to use for the session.

.PARAMETER Description
Optional parameter to specify the [String]  Description value for this resource

.PARAMETER ProxyUser
Optional parameter to specify the [String] ProxyUser value for this resource

.PARAMETER ProxyUserPassword
Optional parameter to specify the [String] ProxyUserPassword value for this resource

.PARAMETER ProxyUserIsManaged
Optional parameter to specify the [Boolean] ProxyUserIsManaged value for this resource

.PARAMETER ManagementMode
Optional parameter to specify the [String] ManagementMode value for this resource

.PARAMETER ManagementPort
Optional parameter to specify the [Int32] ManagementPort value for this resource

.PARAMETER AllowPasswordRotation
Optional parameter to specify the [Boolean] AllowPasswordRotation value for this resource

.PARAMETER PasswordRotateDuration
Optional  parameter to specify the [String] PasswordRotateDuration value for this resource

.PARAMETER AllowMultipleCheckouts
Optional  parameter to specify the [Boolean] AllowMultipleCheckouts value for this resource

.PARAMETER AllowPasswordHistoryCleanup
Optional parameter to specify the [Boolean]AllowPasswordHistoryCleanup value for this resource

.PARAMETER PasswordHistoryCleanupDuration
Optional String parameter to specify the [String] PasswordHistoryCleanupDuration value for this resource

.PARAMETER AllowHealthCheck
Optional parameter to specify the [Boolean] AllowHealthCheck value for this resource

.PARAMETER HealthCheckInterval
Optional parameter to specify the  HealthCheckInterval value for this resource

.PARAMETER DefaultCheckoutTime
Optional parameter to specify the [Int32] DefaultCheckoutTime for this resource.

.PARAMETER ProxyCollectionList
Optional  parameter to specify the [String] Cloud Connector list for this resource 

.INPUTS
The following parameters are mandatory: [Object] PASSystem
NOTE: Get-VaultSystem commandlet must be used to acquire the PASSystem object to update

The following parameters are optional:

[String] Name, [String] Fqdn, [String] ComputerClass, [String] SessionType, [Int32] Port, 
[String] Description, [String] ProxyUser, [String] ProxyUserPassword, 
[Boolean] ProxyUserIsManaged, [String] ManagementMode, [Int32] ManagementPort, 
[Boolean] AllowPasswordRotation, [Int32] PasswordHistoryCleanupDuration, 
[Boolean] AllowHealthCheck, [Int32] HealthCheckInterval, 
[Int32] DefaultCheckoutTime, [String] ProxyCollectionList

.OUTPUTS
This Cmdlet returns the [Object] PASSystem upon success. Returns error message upon failure.

.EXAMPLE
C:\PS> Set-VaultSystem -System (Get-VaultSystem -Name "Windows7") -Name "Windows7Sys1"
This CmdLet gets the specified system and updates the name.
#>
function global:Set-VaultSystem
{
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the PASSystem to update.")]
		[System.Object]$VaultSystem,

		[Parameter(Mandatory = $false, HelpMessage = "Name of the resource.")]
		[System.String]$Name,
		
		[Parameter(Mandatory = $false, HelpMessage = "Fully qualified DNS name or the IP address to use to connect to this resource.")]
		[System.String]$Fqdn,
		
		[Parameter(Mandatory = $false, HelpMessage = "Computer class of this resource.")]
		[ValidateSet("Windows", "Unix", "CiscoIOS", "CiscoNXOS", "JuniperJunos", "GenericSsh", IgnoreCase = $false)]
		[System.String]$ComputerClass,
		
		[Parameter(Mandatory = $false, HelpMessage = "Session type of this resource.")]
		[ValidateSet("Rdp", "Ssh", IgnoreCase = $false)]
		[System.String]$SessionType,

		[Parameter(Mandatory = $false, HelpMessage = "Port to use for the session.")]
		[System.Int32]$Port = 0,

		[Parameter(Mandatory = $false, HelpMessage = "Description for this resource.")]
		[System.String]$Description,

		[Parameter(Mandatory = $false, HelpMessage = "Proxy User name for this resource.")]
		[System.String]$ProxyUser,

		[Parameter(Mandatory = $false, HelpMessage = "Proxy User password for this resource.")]
		[System.String]$ProxyUserPassword,

		[Parameter(Mandatory = $false, HelpMessage = "Specify if the Proxy account password should be managed (false by default).")]
		[System.Boolean]$ProxyUserIsManaged = $false,

		[Parameter(Mandatory = $false, HelpMessage = "Management mode of this resource.")]
		[System.String]$ManagementMode,

		[Parameter(Mandatory = $false, HelpMessage = "Management port to use for the session.")]
		[System.Int32]$ManagementPort = 0,

		[Parameter(Mandatory = $false, HelpMessage = "Allow password rotation for this resource.")]
		[System.Boolean]$AllowPasswordRotation = $false,

		[Parameter(Mandatory = $false, HelpMessage = "Password rotate duration for this resource.")]
		[System.String]$PasswordRotateDuration,

		[Parameter(Mandatory = $false, HelpMessage = "Allow multiple checkouts for this resource.")]
		[System.Boolean]$AllowMultipleCheckouts = $true,

		[Parameter(Mandatory = $false, HelpMessage = "Allow password history cleanup for this resource.")]
		[System.Boolean]$AllowPasswordHistoryCleanup = $true,

		[Parameter(Mandatory = $false, HelpMessage = "Password history cleanup duration for this resource.")]
		[System.String]$PasswordHistoryCleanupDuration,

		[Parameter(Mandatory = $false, HelpMessage = "Allow health check for this resource.")]
		[System.Boolean]$AllowHealthCheck = $true,

		[Parameter(Mandatory = $false, HelpMessage = "Password history cleanup duration for this resource.")]
		[System.String]$HealthCheckInterval,

		[Parameter(Mandatory = $false, HelpMessage = "Default checkout time for this resource.")]
		[System.String]$DefaultCheckoutTime,

		[Parameter(Mandatory = $false, HelpMessage = "Cloud Connector list for this resource.")]
		[System.String]$ProxyCollectionList
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

		# Get the PASSystem ID
		if ([System.String]::IsNullOrEmpty($VaultSystem.ID))
		{
			Throw "Cannot get ResourceID from given parameter."
		}
		else
		{
			# Conserve values not request for update
			if ([System.String]::IsNullOrEmpty($Name))
			{
				$Name = $VaultSystem.Name
			}
			if ([System.String]::IsNullOrEmpty($FQDN))
			{
				$FQDN = $VaultSystem.FQDN
			}
			if ([System.String]::IsNullOrEmpty($ComputerClass))
			{
				$ComputerClass = $VaultSystem.ComputerClass
			}
			if ([System.String]::IsNullOrEmpty($SessionType))
			{
				$SessionType = $VaultSystem.SessionType
			}
			if (-not $Port)
			{
				$Port = $VaultSystem.Port
			}
			if ([System.String]::IsNullOrEmpty($Description))
			{
				$Description = $VaultSystem.Description
			}
			if ([System.String]::IsNullOrEmpty($ProxyUser))
			{
				$ProxyUser = $VaultSystem.ProxyUser
			}
			if ([System.String]::IsNullOrEmpty($ProxyUserPassword))
			{
				$ProxyUserPassword = $VaultSystem.ProxyUserPassword
			}
			if (-not $ProxyUserIsManaged)
			{
				$ProxyUserIsManaged = $VaultSystem.ProxyUserIsManaged
			}
			if ([System.String]::IsNullOrEmpty($ManagementMode))
			{
				$ManagementMode = $VaultSystem.ManagementMode
			}
			if (-not $ManagementPort)
			{
				$ManagementPort = $VaultSystem.ManagementPort
			}
			if (-not $AllowPasswordRotation)
			{
				$AllowPasswordRotation = $VaultSystem.AllowPasswordRotation
			}
			if ([System.String]::IsNullOrEmpty($PasswordRotationDuration))
			{
				$PasswordRotationDuration = $VaultSystem.PasswordRotationDuration
			}
			if (-not $AllowMultipleCheckouts)
			{
				$AllowMultipleCheckouts = $VaultSystem.AllowMultipleCheckouts
			}
			if (-not $AllowPasswordHistoryCleanup)
			{
				$AllowPasswordHistoryCleanup = $VaultSystem.AllowPasswordHistoryCleanup
			}
			if ([System.String]::IsNullOrEmpty($PasswordHistoryCleanupDuration))
			{
				$PasswordHistoryCleanupDuration = $VaultSystem.PasswordHistoryCleanupDuration
			}
			if (-not $AllowHealthCheck)
			{
				$AllowHealthCheck = $VaultSystem.AllowHealthCheck
			}
			if ([System.String]::IsNullOrEmpty($HealtCheckInterval))
			{
				$HealtCheckInterval = $VaultSystem.HealtCheckInterval
			}
			if ([System.String]::IsNullOrEmpty($DefaultCheckoutTime))
			{
				$DefaultCheckoutTime = $VaultSystem.DefaultCheckoutTime
			}
			if ([System.String]::IsNullOrEmpty($ProxyCollectionList))
			{
				$ProxyCollectionList = $VaultSystem.ProxyCollectionList
			}
			
			# Setup variable for query
			$Uri = ("https://{0}/ServerManage/UpdateResource" -f $PlatformConnection.PodFqdn)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
	
			# Format Json query
			$Json = "{"
			$Json += ("`"ID`":`"{0}`"," -f $VaultSystem.ID)
			$Json += ("`"Name`":`"{0}`"," -f $Name)
			$Json += ("`"FQDN`":`"{0}`"," -f $Fqdn)
			$Json += ("`"ComputerClass`":`"{0}`"," -f $ComputerClass)
			$Json += ("`"SessionType`":`"{0}`"," -f $SessionType)
			if ($Port)
			{
				$Json += ("`"Port`":`"{0}`"," -f $Port)
			}
			$Json += ("`"Description`":`"{0}`"," -f $Description)
			$Json += ("`"ProxyUser`":`"{0}`"," -f $ProxyUser)
			$Json += ("`"ProxyUserPassword`":`"{0}`"," -f $ProxyUserPassword)
			$Json += ("`"ProxyUserIsManaged`":`"{0}`"," -f $ProxyUserIsManaged)
			$Json += ("`"ManagementMode`":`"{0}`"," -f $ManagementMode)
			if ($ManagementPort)
			{
				$Json += ("`"ManagementPort`":`"{0}`"," -f $ManagementPort)
			}
			$Json += ("`"AllowPasswordRotation`":`"{0}`"," -f $AllowPasswordRotation)
			$Json += ("`"PasswordRotationDuration`":`"{0}`"," -f $PasswordRotationDuration)
			$Json += ("`"AllowMultipleCheckouts`":`"{0}`"," -f $AllowMultipleCheckouts)
			$Json += ("`"AllowPasswordHistoryCleanup`":`"{0}`"," -f $AllowPasswordHistoryCleanup)
			$Json += ("`"PasswordHistoryCleanupDuration`":`"{0}`"," -f $PasswordHistoryCleanupDuration)
			$Json += ("`"AllowHealthCheck`":`"{0}`"," -f $AllowHealthCheck)
			$Json += ("`"HealtCheckInterval`":`"{0}`"," -f $HealtCheckInterval)
			if (-not [System.String]::IsNullOrEmpty($DefaultCheckoutTime))
			{
				$Json += ("`"DefaultCheckoutTime`":`"{0}`"," -f $DefaultCheckoutTime)
			}
			if (-not [System.String]::IsNullOrEmpty($ProxyCollectionList))
			{
				$Json += ("`"ProxyCollectionList`":`"{0}`"" -f $ProxyCollectionList)
			}
			$Json += "}"
	
			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("Args= {0}" -f $Arguments)
			Write-Debug ("Json= {0}" -f $Json)
					
			# Connect using RestAPI
			$WebResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $PlatformConnection.Session
			$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
			if ($WebResponseResult.Success)
			{
				# Success return Resource
				return (Get-VaultSystem | Where-Object { $_.ID -eq $VaultSystem.ID })
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

