################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

<#
.SYNOPSIS
This CMDlet supports ability to create a new [Object] CisSystem.

.DESCRIPTION

This CMDlet supports ability to create a new [Object] CisSystem.

.PARAMETER Name
Mandatory parameter used to specify the [String] Name of the system to register to the Cloud.

.PARAMETER Fqdn
Mandatory parameter used to sepcify the [String] fqdn (fully qualified DNS name) or the IP address to use to connect to this system.

.PARAMETER ComputerClass
Optional parameter used to specify the [String] ComputerClass of this resource. 
Valid types are: "Windows", "Unix", "CiscoIOS", "CiscoNXOS", "JuniperJunos", "GenericSsh".

.PARAMETER SessionType
Optional parameter used to specify the [String] SessionType. 
Valid values are: "Rdp", "Ssh".

.PARAMETER Description
Optional parameter used to set a [String] description for this system.

.PARAMETER ProxyUser
Optional parameter used to specify the [String] ProxyUser name for this system.

.PARAMETER ProxyUserPassword
Optional parameter used to specify the [String] ProxyUserPassword for this system.

.PARAMETER ProxyUserIsManaged
Optional parameter used to specify [Boolean] ProxyUserIsManaged if the Proxy account password should be managed (false by default).

.Inputs
This CmdLet takes following mandatory parameters: 
[String] Name, [String] Fqdn

This CmdLet takes following mandatory parameters: 
[String] ComputerClass, [String] SessionType, [String] Description, 
[String] ProxyUser, [String] ProxyUserPassword, [Boolean] ProxyUserIsManaged

.OUTPUTS
Returns the newly created user object on success. Returns failure message on failure.

.EXAMPLE
C:\PS> New-CisSystem -Name "bcrabcastle" -Fqdn "castle1.cps.ocean.net"
Create a new CisSystem with Name and Fqdn specified
#>
function global:New-CisSystem
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = "Specify the Name of the system to register to the Cloud.")]
		[System.String]$Name,
		
		[Parameter(Mandatory = $true, HelpMessage = "Specify the fully qualified DNS name or the IP address to use to connect to this system.")]
		[System.String]$Fqdn,
		
		[Parameter(Mandatory = $false, HelpMessage = "Specify the Computer class of this resource.")]
		[ValidateSet("Windows", "Unix", "CiscoIOS", "CiscoNXOS", "JuniperJunos", "GenericSsh", IgnoreCase = $false)]
		[System.String]$ComputerClass,
		
		[Parameter(Mandatory = $false, HelpMessage = "Optionally set the Session type of this system.")]
		[ValidateSet("Rdp", "Ssh", IgnoreCase = $false)]
		[System.String]$SessionType,

		[Parameter(Mandatory = $false, HelpMessage = "Optionally set a description for this system.")]
		[System.String]$Description,

		[Parameter(Mandatory = $false, HelpMessage = "Optional Proxy User name for this system.")]
		[System.String]$ProxyUser,

		[Parameter(Mandatory = $false, HelpMessage = "Optional Proxy User password for this system.")]
		[System.String]$ProxyUserPassword,

		[Parameter(Mandatory = $false, HelpMessage = "Specify if the Proxy account password should be managed (false by default).")]
		[System.Boolean]$ProxyUserIsManaged = $false
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

		# Registering Computer to the Cloud
		$Uri = ("https://{0}/ServerManage/AddResource" -f $CisConnection.PodFqdn)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
			
		# Create CisSystem
		$CisSystem = @{}
		$CisSystem.Name	= $Name
		$CisSystem.FQDN	= $Fqdn
		if (-not [System.String]::IsNullOrEmpty($ComputerClass))
		{
			$CisSystem.ComputerClass = $ComputerClass
		}
		if (-not [System.String]::IsNullOrEmpty($Description))
		{
			$CisSystem.Description = $Description
		}
		if (-not [System.String]::IsNullOrEmpty($ProxyUser))
		{
			$CisSystem.ProxyUser = $ProxyUser
		}
		if (-not [System.String]::IsNullOrEmpty($ProxyUserPassword))
		{
			$CisSystem.ProxyUserPassword = $ProxyUserPassword
		}
		if ($ProxyUserIsManaged)
		{
			$CisSystem.ProxyUserIsManaged = "true"
		}
		
		# Format Json query
		$Json = $CisSystem | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $CisConnection.Session
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Success return Ressource
			return (Get-CisSystem | Where-Object { $_.Name -eq $Name })
		}
		else
		{
			if ($WebResponseResult.Message -match "Resource already exists")
			{
				Write-Warning ("System {0} is already registred. Skipping registration." -f $Name)
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

