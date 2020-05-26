###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

<#
.SYNOPSIS
This Cmdlet is opening a connection to a Centrify Identity Service tenant specified by its Url.

.DESCRIPTION
This Cmdlet support different methods of authentication to connect to a Centrify Identity Service tenant. 
The methods available are:
- Interactive authentication using Multi-Factor Authentication.
    This connection is made by specifying a User name and answering any challenge prompted. The User could be using simple password authentication if exempted from MFA, or have to choose from a list of mechanism available for him. This method is subject to Centrify Portal policy in effect for this particular User.

- Silent authentication using User or Machine certificate.
    This connection is made by specifying a Certificate Thumbprint and the type of Certificate to use (i.e. User or Machine certificate). The Certificate used must be present and readable from the corresponding Certificate store on the computer. The Certificate must be valid and recognised by the Centrify Identity Platform to allow connection. Finally a Service User corresponding to the Certificate must exist and have connection permissions.

- Pre-authorised authentication using OAuth2 Client authentication.
    This connection is made by specifying an OAuth2 Service name and scope, as well as the Secret for a Service User authorised to obtain an OAuth2 token. An OAuth2 Client App must be configured on the Centrify Identity Platform to allow OAUth2 Client authentication.

.PARAMETER Url
Specify the URL to use for the connection (e.g. oceanlab.my.centrify.com).

.PARAMETER User
Specify the User login to use for the connection (e.g. CloudAdmin@oceanlab.my.centrify.com).
		
.PARAMETER Thumbprint
Specify the Certificate Thumbprint to use for the connection.

.PARAMETER UseMachineCertificate
Use Machine Certificate to connect to the Centrify Identity Services.

.PARAMETER UseUserCertificate
Use User Certificate to connect to the Centrify Identity Services.

.PARAMETER OAuth2Secret
Specify the OAuth2 Secret to use for the ClientID.

.PARAMETER OAuth2Service
Specify the OAuth2 Service Name to use to obtain a Bearer Token.

.PARAMETER OAuth2Scope
Specify the OAuth2 Scope Name to claim a Bearer Token for.

.INPUTS
None. You can't redirect or pipe input to this script.

.OUTPUTS
This Cmdlet returns a PASConnection object that print information about the opened connection to the Centrify Identity Service.

.EXAMPLE
C:\PS> Connect-PASService -Url cps.ocean.net -User admin@cps.ocean.net
This will attempt interactive connection to Url cps.ocean.net using admin@cps.ocean.net user. The user will be prompted to enter credentials following the Centrify Portal policy in effect for this user.

.EXAMPLE
C:\PS> Connect-PASService -Url cps.ocean.net -UseMachineCertificate -Thumbprint "009D5C993F3ABDE6B5198924CC39B48B4B90C5EE"
This will attempt certificate authentication using a certificate located in the LocalMachine certificate store.
The following command show how to retrieve the Thumbprint value of a Certificate with "win-centrify" name in the Subject (i.e. machine certificate).
$Thumbprint = (Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -match "win-centrify" }).Thumbprint

.EXAMPLE
C:\PS> Connect-PASService -Url cps.ocean.net -OAuth2Service "Bluecrab" -OAuth2Scope "All" -OAuth2Secret "c3ZjLWJjcmFiQGNwcy5vY2Vhbi5uZXQ6Q2VudHIxZnk="
This will attempt OAuth2 Client authentication using the Service named "Bluecrab" with Scope "All". The secret is a Base64 encoded credentials of a Service User allowed to obtain an OAuth2 token for this service.
The following command can be used to encode Service User name and password into a Base64 string.
$Secret = Centrify.PrivilegedAccessService.PowerShell.OAuth2.ConvertToSecret -ClientID "svc-bcrab@cps.ocean.net" -Password "Centr1fy"
#>
function global:Connect-PASService
{
	param
	(
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the URL to use for the connection (e.g. oceanlab.my.centrify.com).")]
		[Parameter(ParameterSetName = "Interactive")]
		[Parameter(ParameterSetName = "Certificate")]
		[Parameter(ParameterSetName = "OAuth2")]
		[System.String]$Url,
		
		[Parameter(Mandatory = $true, ParameterSetName = "Interactive", HelpMessage = "Specify the User login to use for the connection (e.g. CloudAdmin@oceanlab.my.centrify.com).")]
		[System.String]$User,
		
		[Parameter(Mandatory = $true, ParameterSetName = "Certificate", HelpMessage = "Specify the Certificate Thumbprint to use for the connection.")]
        [System.String]$Thumbprint,

		[Parameter(Mandatory = $false, ParameterSetName = "Certificate", HelpMessage = "Use Machine Certificate to connect to the Centrify Identity Services.")]
		[Switch]$UseMachineCertificate,

		[Parameter(Mandatory = $false, ParameterSetName = "Certificate", HelpMessage = "Use User Certificate to connect to the Centrify Identity Services.")]
		[Switch]$UseUserCertificate,

		[Parameter(Mandatory = $true, ParameterSetName = "OAuth2", HelpMessage = "Specify the OAuth2 Secret to use for the ClientID.")]
        [System.String]$OAuth2Secret,

		[Parameter(Mandatory = $true, ParameterSetName = "OAuth2", HelpMessage = "Specify the OAuth2 Service Name to use to obtain a Bearer Token.")]
        [System.String]$OAuth2Service,

		[Parameter(Mandatory = $true, ParameterSetName = "OAuth2", HelpMessage = "Specify the OAuth2 Scope Name to claim a Bearer Token for.")]
        [System.String]$OAuth2Scope
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

        # Delete any existing connexion cache
        $global:PASConnection = [Void]$null

        if ($UseUserCertificate.IsPresent)
		{
			# Get User Certificate from CurrentUser store
			$X509Certificate = Centrify.PrivilegedAccessService.PowerShell.X509Certificates.GetCertificateFromStore -StoreName "CurrentUser" -Thumbprint $Thumbprint
			
			# Setup variable for connection
			$Uri = ("https://{0}/NegotiateCertSecurity/Whoami" -f $Url)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
			Write-Host ("Connecting to Centrify Identity Services (https://{0}) using User Certificate" -f $Url)
			
			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("UserCertificate=`n{0}" -f $X509Certificate)
			
			# Format Json query
			$Json = @{} | ConvertTo-Json
			
			# Connect using Certificate
			$WebResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -Certificate $X509Certificate -TimeoutSec 60
            $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
            if ($WebResponseResult.Success)
		    {
                # Get Session Token from successfull login
			    Write-Debug ("WebResponse=`n{0}" -f $WebResponseResult)
			    # Validate that a valid .ASPXAUTH cookie has been returned for the PASConnection
			    $CookieUri = ("https://{0}" -f $Url)
			    $ASPXAuth = $PASSession.Cookies.GetCookies($CookieUri) | Where-Object { $_.Name -eq ".ASPXAUTH" }
			
			    if ([System.String]::IsNullOrEmpty($ASPXAuth))
			    {
				    # .ASPXAuth cookie value is empty
				    Throw ("Failed to get a .ASPXAuth cookie for Url {0}. Verify Url and try again." -f $CookieUri)
			    }
			    else
			    {
				    # Get Connection details
				    $Connection = $WebResponseResult.Result
				
				    # Force URL into PodFqdn to retain URL when performing MachineCertificate authentication
					$Connection | Add-Member -MemberType NoteProperty -Name CustomerId -Value $Connection.TenantId
					$Connection | Add-Member -MemberType NoteProperty -Name PodFqdn -Value $Url
				
				    # Add session to the Connection
				    $Connection | Add-Member -MemberType NoteProperty -Name Session -Value $PASSession

				    # Set Connection as global
				    $global:PASConnection = $Connection
				
				    # Return information values to confirm connection success
				    return ($Connection | Select-Object -Property CustomerId, User, PodFqdn | Format-List)
			    }
            }
            else
            {
                Throw "User Certificate authentication error."
            }
		}
		elseif ($UseMachineCertificate.IsPresent)
		{
    		# Get Hostname for the current Computer
        	#$HostName = ([System.Net.Dns]::GetHostByName("").HostName)
			
            # Get Machine Certificate from LocalMachine store
			$X509Certificate = Centrify.PrivilegedAccessService.PowerShell.X509Certificates.GetCertificateFromStore -StoreName "LocalMachine" -Thumbprint $Thumbprint
			
			# Setup variable for connection
			$Uri = ("https://{0}/NegotiateCertSecurity/Whoami" -f $Url)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
			Write-Host ("Connecting to Centrify Identity Services (https://{0}) using Machine Certificate" -f $Url)
			
			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("MachineCertificate=`n{0}" -f $X509Certificate)
			
			# Format Json query
			$Json = @{} | ConvertTo-Json
			
			# Connect using Certificate
			$WebResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -Certificate $X509Certificate -TimeoutSec 60
            $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
            if ($WebResponseResult.Success)
		    {
                # Get Session Token from successfull login
			    Write-Debug ("WebResponse=`n{0}" -f $WebResponseResult)
			    # Validate that a valid .ASPXAUTH cookie has been returned for the PASConnection
			    $CookieUri = ("https://{0}" -f $Url)
			    $ASPXAuth = $PASSession.Cookies.GetCookies($CookieUri) | Where-Object { $_.Name -eq ".ASPXAUTH" }
			
			    if ([System.String]::IsNullOrEmpty($ASPXAuth))
			    {
				    # .ASPXAuth cookie value is empty
				    Throw ("Failed to get a .ASPXAuth cookie for Url {0}. Verify Url and try again." -f $CookieUri)
			    }
			    else
			    {
				    # Get Connection details
				    $Connection = $WebResponseResult.Result
				
				    # Force URL into PodFqdn to retain URL when performing MachineCertificate authentication
					$Connection | Add-Member -MemberType NoteProperty -Name CustomerId -Value $Connection.TenantId
					$Connection | Add-Member -MemberType NoteProperty -Name PodFqdn -Value $Url
				
				    # Add session to the Connection
				    $Connection | Add-Member -MemberType NoteProperty -Name Session -Value $PASSession

				    # Set Connection as global
				    $global:PASConnection = $Connection
				
				    # Return information values to confirm connection success
				    return ($Connection | Select-Object -Property CustomerId, User, PodFqdn | Format-List)
			    }
            }
            else
            {
                Throw "Machine Certificate authentication error."
            }
		}
		elseif (-not [System.String]::IsNullOrEmpty($OAuth2Service))
        {
            # Get Bearer Token from OAuth2 Client App
			$BearerToken = Centrify.PrivilegedAccessService.PowerShell.OAuth2.GetBearerToken -Url $Url -Service $OAuth2Service -Secret $OAuth2Secret -Scope $OAuth2Scope

            # Validate Bearer Token and obtain Session details
			$Uri = ("https://{0}/Security/Whoami" -f $Url)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; "Authorization" = ("Bearer {0}" -f $BearerToken) }
			Write-Debug ("Connecting to Centrify Identity Services (https://{0}) using Bearer Token" -f $Url)
			
			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("BearerToken={0}" -f $BearerToken)
			
			# Format Json query
			$Json = @{} | ConvertTo-Json
			
			# Connect using Certificate
			$WebResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
            $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
            if ($WebResponseResult.Success)
		    {
				# Get Connection details
				$Connection = $WebResponseResult.Result
				
				# Force URL into PodFqdn to retain URL when performing MachineCertificate authentication
				$Connection | Add-Member -MemberType NoteProperty -Name CustomerId -Value $Connection.TenantId
				$Connection | Add-Member -MemberType NoteProperty -Name PodFqdn -Value $Url
				
				# Add session to the Connection
				$Connection | Add-Member -MemberType NoteProperty -Name Session -Value $PASSession

				# Set Connection as global
				$global:PASConnection = $Connection
				
				# Return information values to confirm connection success
				return ($Connection | Select-Object -Property CustomerId, User, PodFqdn | Format-List)
            }
            else
            {
                Throw "Invalid Bearer Token."
            }
        }
        else
		{
			# Setup variable for connection
			$Uri = ("https://{0}/Security/StartAuthentication" -f $Url)
			$ContentType = "application/json" 
			$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
			Write-Host ("Connecting to Centrify Identity Services (https://{0}) as {1}`n" -f $Url, $User)
			
			# Debug informations
			Write-Debug ("Uri= {0}" -f $Uri)
			Write-Debug ("Login= {0}" -f $UserName)
			
			# Format Json query
			$Auth = @{}
			$Auth.TenantId = $Url.Split('.')[0]
			$Auth.User = $User
            $Auth.Version = "1.0"
			$Json = $Auth | ConvertTo-Json
			
			# Initiate connection
			$InitialResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header

    		# Getting Authentication challenges from initial Response
            $InitialResponseResult = $InitialResponse.Content | ConvertFrom-Json
		    if ($InitialResponseResult.Success)
		    {
			    Write-Debug ("InitialResponse=`n{0}" -f $InitialResponseResult)
                # Go through all challenges
                foreach ($Challenge in $InitialResponseResult.Result.Challenges)
                {
                    # Go through all available mechanisms
                    if ($Challenge.Mechanisms.Count -gt 1)
                    {
                        Write-Host "`n[Available mechanisms]"
                        # More than one mechanism available
                        $MechanismIndex = 1
                        foreach ($Mechanism in $Challenge.Mechanisms)
                        {
                            # Show Mechanism
                            Write-Host ("{0} - {1}" -f $MechanismIndex++, $Mechanism.PromptSelectMech)
                        }
                        
                        # Prompt for Mechanism selection
                        $Selection = Read-Host -Prompt "Please select a mechanism [1]"
                        # Default selection
                        if ([System.String]::IsNullOrEmpty($Selection))
                        {
                            # Default selection is 1
                            $Selection = 1
                        }
                        # Validate selection
                        if ($Selection -gt $Challenge.Mechanisms.Count)
                        {
                            # Selection must be in range
                            Throw "Invalid selection. Authentication challenge aborted." 
                        }
                    }
                    elseif($Challenge.Mechanisms.Count -eq 1)
                    {
                        # Force selection to unique mechanism
                        $Selection = 1
                    }
                    else
                    {
                        # Unknown error
                        Throw "Invalid number of mechanisms received. Authentication challenge aborted."
                    }

                    # Select chosen Mechanism and prepare answer
                    $ChosenMechanism = $Challenge.Mechanisms[$Selection - 1]

			        # Format Json query
			        $Auth = @{}
			        $Auth.TenantId = $InitialResponseResult.Result.TenantId
			        $Auth.SessionId = $InitialResponseResult.Result.SessionId
                    $Auth.MechanismId = $ChosenMechanism.MechanismId
                    
                    # Decide for Prompt or Out-of-bounds Auth
                    switch($ChosenMechanism.AnswerType)
                    {
                        "Text" # Prompt User for answer
                        {
                            $Auth.Action = "Answer"
                            # Prompt for User answer using SecureString to mask typing
                            $SecureString = Read-Host $ChosenMechanism.PromptMechChosen -AsSecureString
                            $Auth.Answer = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
                        }
                        
                        "StartTextOob" # Out-of-bounds Authentication (User need to take action other than through typed answer)
                        {
                            $Auth.Action = "StartOOB"
                            # Notify User for further actions
                            Write-Host $ChosenMechanism.PromptMechChosen
                        }
                    }
	                $Json = $Auth | ConvertTo-Json
                    
                    # Send Challenge answer
			        $Uri = ("https://{0}/Security/AdvanceAuthentication" -f $Url)
			        $ContentType = "application/json" 
			        $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
			
			        # Send answer
			        $WebResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
            		
                    # Get Response
                    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
                    if ($WebResponseResult.Success)
		            {
                        # Evaluate Summary response
                        if($WebResponseResult.Result.Summary -eq "OobPending")
                        {
                            $Answer = Read-Host "Enter code or press <enter> to finish authentication"
                            # Send Poll message to Centrify Identity Platform after pressing enter key
			                $Uri = ("https://{0}/Security/AdvanceAuthentication" -f $Url)
			                $ContentType = "application/json" 
			                $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1" }
			
			                # Format Json query
			                $Auth = @{}
			                $Auth.TenantId = $Url.Split('.')[0]
			                $Auth.SessionId = $InitialResponseResult.Result.SessionId
                            $Auth.MechanismId = $ChosenMechanism.MechanismId
                            
                            # Either send entered code or poll service for answer
                            if ([System.String]::IsNullOrEmpty($Answer))
                            {
                                $Auth.Action = "Poll"
                            }
                            else
                            {
                                $Auth.Action = "Answer"
                                $Auth.Answer = $Answer
                            }
			                $Json = $Auth | ConvertTo-Json
			
                            # Send Poll message or Answer
			                $WebResponse = Invoke-WebRequest -Method Post -SessionVariable PASSession -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header
                            $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
                            if ($WebResponseResult.Result.Summary -ne "LoginSuccess")
                            {
                                Throw "Failed to receive challenge answer or answer is incorrect. Authentication challenge aborted."
                            }
                        }

                        # If summary return LoginSuccess at any step, we can proceed with session
                        if ($WebResponseResult.Result.Summary -eq "LoginSuccess")
		                {
                            # Get Session Token from successfull login
			                Write-Debug ("WebResponse=`n{0}" -f $WebResponseResult)
			                # Validate that a valid .ASPXAUTH cookie has been returned for the PASConnection
			                $CookieUri = ("https://{0}" -f $Url)
			                $ASPXAuth = $PASSession.Cookies.GetCookies($CookieUri) | Where-Object { $_.Name -eq ".ASPXAUTH" }
			
			                if ([System.String]::IsNullOrEmpty($ASPXAuth))
			                {
				                # .ASPXAuth cookie value is empty
				                Throw ("Failed to get a .ASPXAuth cookie for Url {0}. Verify Url and try again." -f $CookieUri)
			                }
			                else
			                {
				                # Get Connection details
				                $Connection = $WebResponseResult.Result
				
				                # Add session to the Connection
				                $Connection | Add-Member -MemberType NoteProperty -Name Session -Value $PASSession

				                # Set Connection as global
				                $global:PASConnection = $Connection
				
				                # Return information values to confirm connection success
				                return ($Connection | Select-Object -Property CustomerId, User, PodFqdn | Format-List)
			                }
                        }
		            }
		            else
		            {
                        # Unsuccesful connection
			            Throw $WebResponseResult.Message
		            }
                }
		    }
		    else
		    {
			    # Unsuccesful connection
			    Throw $InitialResponseResult.Message
		    }
		}				
	}
	catch
	{
		Throw $_.Exception   
	}
}
