################################################
# Centrify Cloud Platform unofficial PowerShell Module
# Created by Fabrice Viguier from sample work by Nick Gamb
#
# Author : Fabrice Viguier
# Version: https://bitbucket.org/centrifyps/centrifycloudpowershellmodule
# 
################################################

class CisUser
{
    [System.String]$DisplayName
    [System.String]$SourceDsInstance
    [System.String]$ServiceUser
    [System.String]$DirectoryServiceUuid
    [System.DateTime]$LastInvite
    [System.DateTime]$LastLogin
    [System.String]$UserType
    [System.String]$SearchEmail
    [System.String]$SourceDsLocalized
    [System.String]$StatusEnum
    [System.String]$SecurityQuestionSet
    [System.String]$Email
    [System.String]$Username
    [System.String]$Forest
    [System.String]$SourceDs
    [System.String]$Status
    [System.String]$ID
    [System.String]$SecurityQuestionCount
    [System.String]$SourceDsType
    [CisUserActivity[]]$Activities
    [DirectoryServiceAttributes]$Attributes

    [CisUserActivity[]] GetCisUserActivities([System.String]$ID)
    {
	    try
	    {	
		    # Set RedrockQuery
		    $Query = ("@/lib/get_user_activity_for_admin.js(userid:'{0}')" -f $ID)

		    # Set Arguments
		    $Arguments = @{}
		    $Arguments.PageNumber 	= 1
		    $Arguments.PageSize 	= 10000
		    $Arguments.Limit	 	= 10000
		    $Arguments.SortBy	 	= ""
		    $Arguments.Direction 	= "False"
		    $Arguments.Caching	 	= -1
			
		    # Build Query
		    $RedrockQuery = Centrify.IdentityServices.PowerShell.Redrock.CreateQuery -Query $Query -Arguments $Arguments
	
		    # Debug informations
		    Write-Debug ("Uri= {0}" -f $RedrockQuery.Uri)
		    Write-Debug ("Json= {0}" -f $RedrockQuery.Json)
			
		    # Connect using RestAPI
		    $WebResponse = Invoke-WebRequest -Method Post -Uri $RedrockQuery.Uri -Body $RedrockQuery.Json -ContentType $RedrockQuery.ContentType -Headers $RedrockQuery.Header -WebSession $global:CisConnection.Session
		    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		    if ($WebResponseResult.Success)
		    {
			    return $WebResponseResult.Result.Results.Row
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

    [DirectoryServiceAttributes] GetUserAttributes([System.String]$ID)
	{
	    try
	    {	
		    # Setup variable for query
		    $Uri = ("https://{0}/UserMgmt/GetUserAttributes" -f $global:CisConnection.PodFqdn)
		    $ContentType = "application/json" 
		    $Header = @{ "X-CENTRIFY-NATIVE-CLIENT" = "1"; }

		    # Set Json query
		    $JsonQuery = @{}
            $JsonQuery.ID = $ID
        
		    # Build Json query
		    $Json = $JsonQuery | ConvertTo-Json
			
		    # Debug informations
		    Write-Debug ("Uri= {0}" -f $Uri)
		    Write-Debug ("Json= {0}" -f $Json)
						
		    # Connect using RestAPI
		    $WebResponse = Invoke-WebRequest -Method Post -Uri $Uri -Body $Json -ContentType $ContentType -Headers $Header -WebSession $global:CisConnection.Session
		    $WebResponseResult = $WebResponse.Content | ConvertFrom-Json
		    if ($WebResponseResult.Success)
		    {
			    return $WebResponseResult.Result
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
}

class CisUserActivity
{
    [System.String]$Detail
    [System.String]$FromIPAddress
    [System.String]$EventType
    [System.DateTime]$When
}

class DirectoryServiceAttributes
{
    [System.String]$c
    [System.String]$canonicalname
    [System.String]$company
    [System.String]$department
    [System.String]$description
    [System.String]$directoryServiceUuid
    [System.String]$displayname
    [System.String]$employeeid
    [System.String]$givenname
    [System.String]$homephone
    [System.String]$homepostaladdress
    [System.String]$initials
    [System.String]$l
    [System.String]$mail
    [System.String]$manager
    [DirectoryServiceGroup[]]$memberof
    [System.String]$mobile
    [System.String]$name
    [System.String]$objectguid
    [System.String]$pager
    [System.String]$postaladdress
    [System.String]$postalcode
    [System.String]$postofficebox
    [System.String]$PreferredCulture
    [System.String]$preferredLanguage
    [System.String]$sn
    [System.String]$st
    [System.String]$street
    [System.String]$streetaddress
    [System.String]$telephonenumber
    [System.String]$thumbnailPhoto
    [System.String]$title
    [System.String]$url
    [System.String]$userprincipalname
    [System.String]$Uuid
    [System.String]$wwwhomepage   
}

class DirectoryServiceGroup
{
    [System.String]$name
    [System.String]$objectguid
    [System.String]$description
    [System.String]$securityenabled
    [System.String]$emailaddress
    [System.String]$directoryServiceUuid
    [System.String]$members
    [System.String]$displayname
}