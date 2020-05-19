################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

function Centrify.IdentityServices.PowerShell.OAuth2.ConvertToSecret
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Client ID.")]
        [System.String]$ClientID,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Client password.")]
		[System.String]$Password		
    )

    # Combine ClientID and Password then encode authentication string in Base64
    $AuthenticationString = ("{0}:{1}" -f $ClientID, $Password)
    $Secret = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($AuthenticationString))

    # Return Base64 encoded secret
    return $Secret
}

function Centrify.IdentityServices.PowerShell.OAuth2.ConvertFromSecret
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Secret to decode.")]
        [System.String]$Secret		
    )

    # Decode authentication string from Base64
    $AuthenticationString = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Secret))
    $AuthenticationCreds = @{ "ClientID" = $AuthenticationString.Split(':')[0]; "Password" = $AuthenticationString.Split(':')[1]}

    # Return Base64 decoded authentication details
    return $AuthenticationCreds
}

function Centrify.IdentityServices.PowerShell.OAuth2.GetBearerToken
{
    param(
        [Parameter(Mandatory=$true, HelpMessage = "Specify the URL to connect to.")]
        [System.String]$Url,
        
        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Service name.")]
		[System.String]$Service,	

        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Scope name.")]
		[System.String]$Scope,	

        [Parameter(Mandatory=$true, HelpMessage = "Specify the OAuth2 Secret.")]
		[System.String]$Secret		
    )

    # Setup variable for connection
	$Uri = ("https://{0}/oauth2/token/{1}" -f $Url, $Service)
	$ContentType = "application/x-www-form-urlencoded" 
	$Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; "Authorization" = ("Basic {0}" -f $Secret) }
	Write-Host ("Connecting to Centrify Identity Services (https://{0}) using OAuth2 Client Credentials flow" -f $Url)
			
    # Format body
    $Body = ("grant_type=client_credentials&scope={0}" -f  $Scope)
	
	# Debug informations
	Write-Debug ("Uri= {0}" -f $Uri)
	Write-Debug ("Header= {0}" -f $Header)
	Write-Debug ("Body= {0}" -f $Body)
    		
	# Connect using OAuth2 Client
	$WebResponse = Invoke-WebRequest -Method Post -SessionVariable CisSession -Uri $Uri -Body $Body -ContentType $ContentType -Headers $Header
    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
    if ([System.String]::IsNullOrEmpty($WebResponseResult.access_token))
    {
        Throw "OAuth2 Client authentication error."
    }
	else
    {
        # Return Bearer Token from successfull login
        return $WebResponseResult.access_token
    }
}
