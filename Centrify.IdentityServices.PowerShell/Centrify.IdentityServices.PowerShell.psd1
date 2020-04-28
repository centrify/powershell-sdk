###########################################################################################
# Centrify Identity Services PowerShell Module Module Manifest                            #
#                                                                                         #
# Author : Fabrice Viguier                                                                #
# Contact: fabrice.viguier AT centrify.com                                                #
# Release: 21/01/2016                                                                     #
###########################################################################################

@{
	Author 				= 'Fabrice Viguier'
	CompanyName 		= 'Centrify Corporation'
	Copyright 			= '(c) 2016 CENTRIFY. All rights reserved.'
	Description 		= 'This PowerShell module is to be used with Centrify Identity Services (both Cloud and on-premise Tenants are supported).'
	GUID 				= '325f94ca-6660-a42b-210d-21ef3488f9ea'
	ModuleToProcess 	= 'Centrify.IdentityServices.PowerShell.psm1'
	ModuleVersion 		= '1.11.1010'
    NestedModules       = @(
                            '.\Util\RestAPIUtil.ps1',
                            '.\Lib\Add-CisAccount.ps1',
                            '.\Lib\Add-CisCollectionMember.ps1',
                            '.\Lib\Add-CisRoleMember.ps1',
                            '.\Lib\Checkin-CisPassword.ps1',
                            '.\Lib\Checkout-CisPassword.ps1',
                            '.\Lib\Checkout-CisSecret.ps1',
                            '.\Lib\Checkout-CisSshKey.ps1',
                            '.\Lib\Connect-CisService.ps1',
                            '.\Lib\Enroll-CisSystem.ps1',
                            # WIP - '.\Lib\Export-CisPolicy.ps1',
                            '.\Lib\Get-CisAccount.ps1',
                            '.\Lib\Get-CisAccountCollection.ps1',
                            '.\Lib\Get-CisDatabase.ps1',
                            '.\Lib\Get-CisDomain.ps1',
                            '.\Lib\Get-CisEnrollmentCode.ps1',
                            '.\Lib\Get-CisRole.ps1',
                            '.\Lib\Get-CisSecret.ps1',
                            '.\Lib\Get-CisSecretCollection.ps1',
                            '.\Lib\Get-CisSshKey.ps1',
                            '.\Lib\Get-CisSystem.ps1',
                            '.\Lib\Get-CisSystemCollection.ps1',
                            '.\Lib\Get-CisUser.ps1',
                            # WIP - '.\Lib\Import-CisPolicy.ps1',
                            '.\Lib\Invite-CisUser.ps1',
                            '.\Lib\New-CisAlternateAccount.ps1',
                            '.\Lib\New-CisCollection.ps1',
                            '.\Lib\New-CisEnrollmentCode.ps1',
                            '.\Lib\New-CisRole.ps1',
                            '.\Lib\New-CisSecret.ps1',
                            '.\Lib\New-CisSshKey.ps1',
                            '.\Lib\New-CisSystem.ps1',
                            '.\Lib\New-CisUser.ps1',
                            '.\Lib\Remove-CisAccount.ps1',
                            '.\Lib\Remove-CisCollectionMember.ps1',
                            '.\Lib\Remove-CisRole.ps1',
                            '.\Lib\Remove-CisRoleMember.ps1',
                            '.\Lib\Remove-CisSecret.ps1',
                            '.\Lib\Remove-CisSshKey.ps1',
                            '.\Lib\Remove-CisSystem.ps1',
                            '.\Lib\Remove-CisUser.ps1',
                            '.\Lib\Rotate-CisPassword.ps1',
                            '.\Lib\Run-CisRedrockQuery.ps1',
                            '.\Lib\Set-CisAccount.ps1',
                            '.\Lib\Set-CisPermissions.ps1',
                            '.\Lib\Set-CisSecret.ps1',
                            '.\Lib\Set-CisSystem.ps1',
                            '.\Lib\Set-CisUser.ps1',
                            '.\Lib\Test-CisPassword.ps1',
                            '.\Lib\Update-CisPassword.ps1',
							# Advanced admin commands
							'.\Lib\Get-CisTenantConfig.ps1',
							'.\Lib\Set-CisTenantConfig.ps1'
                           )
	PowerShellVersion 	= '5.0'
	RequiredAssemblies 	= @()
}