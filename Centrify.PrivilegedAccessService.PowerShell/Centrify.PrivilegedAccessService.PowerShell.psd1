###########################################################################################
# Centrify Privileged Access Service PowerShell Module Module Manifest
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

@{
	Author 				= 'Fabrice Viguier'
	CompanyName 		= 'Centrify Corporation'
	Copyright 			= '(c) 2016 CENTRIFY. All rights reserved.'
	Description 		= 'This PowerShell module is to be used with Centrify Privileged Access Service platform (both SaaS and on-premise Centrify PAS tenants are supported).'
	GUID 				= '325f94ca-6660-a42b-210d-21ef3488f9ea'
	ModuleToProcess 	= 'Centrify.PrivilegedAccessService.PowerShell.psm1'
	ModuleVersion 		= '1.12.1106'
    NestedModules       = @(
                            # Loading Utils functions
                            '.\Util\Core.ps1',
                            '.\Util\DataVault.ps1',
                            '.\Util\OAuth.ps1',
                            '.\Util\Redrock.ps1',
                            '.\Util\X509Certificates.ps1',
                            # Loading Module Cmdlets
                            '.\Lib\Add-PASAccount.ps1',
                            '.\Lib\Add-PASCollectionMember.ps1',
                            '.\Lib\Add-PASRoleMember.ps1',
                            '.\Lib\Checkin-PASPassword.ps1',
                            '.\Lib\Checkout-PASPassword.ps1',
                            '.\Lib\Checkout-PASSecret.ps1',
                            '.\Lib\Checkout-PASSshKey.ps1',
                            '.\Lib\Connect-PASPlatform.ps1',
                            '.\Lib\Enroll-PASSystem.ps1',
                            # WIP - '.\Lib\Export-PASPolicy.ps1',
                            '.\Lib\Get-PASAccount.ps1',
                            '.\Lib\Get-PASAccountCollection.ps1',
                            '.\Lib\Get-PASApplication.ps1',
                            '.\Lib\Get-PASDatabase.ps1',
                            '.\Lib\Get-PASDomain.ps1',
                            '.\Lib\Get-PASEnrollmentCode.ps1',
                            '.\Lib\Get-PASRole.ps1',
                            '.\Lib\Get-PASSecret.ps1',
                            '.\Lib\Get-PASSecretCollection.ps1',
                            '.\Lib\Get-PASSshKey.ps1',
                            '.\Lib\Get-PASSystem.ps1',
                            '.\Lib\Get-PASSystemCollection.ps1',
                            '.\Lib\Get-PASUser.ps1',
                            # WIP - '.\Lib\Import-PASPolicy.ps1',
                            '.\Lib\Invite-PASUser.ps1',
                            '.\Lib\New-PASAlternateAccount.ps1',
                            '.\Lib\New-PASCollection.ps1',
                            '.\Lib\New-PASEnrollmentCode.ps1',
                            '.\Lib\New-PASRole.ps1',
                            '.\Lib\New-PASSecret.ps1',
                            '.\Lib\New-PASSshKey.ps1',
                            '.\Lib\New-PASSystem.ps1',
                            '.\Lib\New-PASUser.ps1',
                            '.\Lib\Remove-PASAccount.ps1',
                            '.\Lib\Remove-PASCollectionMember.ps1',
                            '.\Lib\Remove-PASRole.ps1',
                            '.\Lib\Remove-PASRoleMember.ps1',
                            '.\Lib\Remove-PASSecret.ps1',
                            '.\Lib\Remove-PASSshKey.ps1',
                            '.\Lib\Remove-PASSystem.ps1',
                            '.\Lib\Remove-PASUser.ps1',
                            '.\Lib\Rotate-PASPassword.ps1',
                            '.\Lib\Run-PASRedrockQuery.ps1',
                            '.\Lib\Set-PASAccount.ps1',
                            '.\Lib\Set-PASPermissions.ps1',
                            '.\Lib\Set-PASSecret.ps1',
                            '.\Lib\Set-PASSystem.ps1',
                            '.\Lib\Set-PASUser.ps1',
                            '.\Lib\Test-PASPassword.ps1',
                            '.\Lib\Update-PASPassword.ps1',
							# Advanced admin commands
							'.\Lib\Get-PASTenantConfig.ps1',
							'.\Lib\Set-PASTenantConfig.ps1'
                           )
	PowerShellVersion 	= '5.0'
	RequiredAssemblies 	= @()
}