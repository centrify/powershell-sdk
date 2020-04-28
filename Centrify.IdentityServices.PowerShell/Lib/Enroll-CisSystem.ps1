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
This Cmdlet allows to enroll a Windows server using Enrollment Code. 

.DESCRIPTION
This Cmdlet allows to enroll a Windows server to the Centrify Platform using Enrollment Code. Enrollment will store the system Certificate on the LocalMachine store and create a Service User account on the Centrify Directory for the machine (exact equivalent to cenroll behaviour on Linux).

.PARAMETER Url
Mandatory URL to use to enroll this system (e.g. oceanlab.my.centrify.net)

.PARAMETER EnrollmentCode
Mandatory EnrollmentCode to use to enroll this system.

.PARAMETER Description
Optional Description to optionally set a description for this resource

.PARAMETER ProxyUser
Optional ProxyUser name for this resource.

.PARAMETER ProxyUserPassword
Optional ProxyUserPassword for this resource.

.PARAMETER ProxyUserIsManaged
Optional parameter ProxyUserIsManaged specify if the Proxy account password should be managed (false by default)

.PARAMETER Force
Optional parameter Force to overwrite an existing AgentProfile.

.INPUTS

.OUTPUTS
[CisSystem]

.EXAMPLE
C:\PS> Enroll-CisSystem -Url "vault.centrify.lab" -EnrollmentCode "2EE9F1CA-F06A-4470-B07A-32907444A023"
Enrolls a System to Centrify Platform using the tenant URL and enrollment code.
#>
function global:Enroll-CisSystem
{
	param
	(
		[Parameter(Mandatory = $true)]
		[System.String]$Url,
		
		[Parameter(Mandatory = $true)]
		[System.String]$EnrollmentCode,
		
		[Parameter(Mandatory = $false)]
		[System.String]$Description,

		[Parameter(Mandatory = $false)]
		[System.String]$ProxyUser,

		[Parameter(Mandatory = $false)]
		[System.String]$ProxyUserPassword,

		[Parameter(Mandatory = $false)]
		[System.Boolean]$ProxyUserIsManaged = $false,
		
		[Parameter(Mandatory = $false)]
		[Switch]$Force
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
		# Set Security Protocol for RestAPI (must use TLS 1.2)
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

		# Registering Computer to the Cloud
		$Uri = ("https://{0}/ServerAgent/RegisterV2" -f $Url)
		$ContentType = "application/json" 
		$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }
		
		# Get FQDN for the current Computer and deduct resource name
		$FQDN = [System.Net.Dns]::GetHostByName("").HostName
		$ResourceName = $FQDN.Split('.')[0]

        # Generate random password for X509Certificate enrollment
		# Password is 25 chars long using [0-9a-zA-Z] range
        $CertificatePassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 25  | ForEach-Object {[System.Char]$_})

		# Create CisSystem
		$CisSystem = @{}
		$CisSystem.Name					= $ResourceName
		$CisSystem.ResourceName			= $ResourceName
		$CisSystem.FQDN					= $FQDN
		$CisSystem.OperatingSystem 		= "Windows"
		$CisSystem.AgentVersion 			= "1.0.0" 
		$CisSystem.EnrollmentCode	 		= $EnrollmentCode
		$CisSystem.CertificatePassword	= $CertificatePassword

		# Add Resource settings
		$ResourceSettings = @{}
		$ResourceSettings.Name			= $ResourceName
		$ResourceSettings.ComputerClass	= "Windows"
		if (-not [System.String]::IsNullOrEmpty($Description))
		{
			$ResourceSettings.Description = $Description
		}
		if (-not [System.String]::IsNullOrEmpty($ProxyUser))
		{
			$ResourceSettings.ProxyUser = $ProxyUser
		}
		if (-not [System.String]::IsNullOrEmpty($ProxyUserPassword))
		{
			$ResourceSettings.ProxyUserPassword = $ProxyUserPassword
		}
		if ($ProxyUserIsManaged)
		{
			$ResourceSettings.ProxyUserIsManaged = "true"
		}
		$CisSystem.ResourceSetting = $ResourceSettings | ConvertTo-Json
		
		# -Force can overwrite existing AgentProfile if this resource already have been enrolled in the past
		if ($Force.IsPresent)
		{
			$CisSystem.Overwrite = "true"
		}
		
		# Format Json query
		$Json = $CisSystem | ConvertTo-Json

		# Debug informations
		Write-Debug ("Uri= {0}" -f $Uri)
		Write-Debug ("Json= {0}" -f $Json)
			
		# Connect using RestAPI
		$WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
		$WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		if ($WebResponseResult.Success)
		{
			# Read the X509Certificate from result
			$Password = ConvertTo-SecureString $CertificatePassword -AsPlainText -Force
			$X509Certificate = Centrify.IdentityServices.PowerShell.X509Certificates.GetCertificateFromBase64String -Base64String $WebResponseResult.Result.Cert -Password $Password
			if ($X509Certificate -eq [void]$null)
			{
				Throw ("Failed to get X509Certificate from enrolment.")
			}
	
			# Add the X509Certificate into Cert:\LocalMachine\My certificate store
			Centrify.IdentityServices.PowerShell.X509Certificates.AddCertificateToStore -Store "Cert:\LocalMachine\My"  -Certificate $X509Certificate
			
			# Return enrolled resource
			return (Get-CisSystem -Name -eq $Name)
		}
		else
		{
			if ($WebResponseResult.Message -match "Agent already exists in platform")
			{
				Write-Warning ("System {0} is already Cloud enrolled. Use -Force to overwrite existing resource." -f $Name)
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

