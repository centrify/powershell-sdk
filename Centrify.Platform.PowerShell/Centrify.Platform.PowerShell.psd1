###########################################################################################
# Centrify Platform PowerShell module manifest
#
# Author   : Fabrice Viguier
# Contact  : support AT centrify.com
# Release  : 21/01/2016
# Copyright: (c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
#            You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
#            distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#            See the License for the specific language governing permissions and limitations under the License.
###########################################################################################

@{
	Author 				= 'Fabrice Viguier'
	CompanyName 		= 'Centrify Corporation'
	Copyright 			= '(c) 2016 Centrify Corporation. Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.'
	Description 		= 'This PowerShell module is to be used with Centrify Platform (both SaaS and on-premise Centrify Platform tenants are supported).'
	GUID 				= '325f94ca-6660-a42b-210d-21ef3488f9ea'
	ModuleToProcess 	= 'Centrify.Platform.PowerShell.psm1'
	ModuleVersion 		= '1.13.1609'
    NestedModules       = @(
                            # Loading Utils functions
                            '.\Util\Core.ps1',
                            '.\Util\DataVault.ps1',
                            '.\Util\OAuth.ps1',
                            '.\Util\Redrock.ps1',
                            '.\Util\X509Certificates.ps1',
                            # Loading Module Cmdlets
                            '.\Lib\Add-VaultAccount.ps1',
                            '.\Lib\Add-CentrifySetMember.ps1',
                            '.\Lib\Add-CentrifyRoleMember.ps1',
                            # REMOVED - '.\Lib\Checkin-VaultPassword.ps1',
                            '.\Lib\Get-VaultPassword.ps1',
                            # REMOVED - '.\Lib\Checkout-VaultSecret.ps1',
                            # REMOVED - '.\Lib\Checkout-VaultSshKey.ps1',
                            '.\Lib\Connect-CentrifyPlatform.ps1',
                            # REMOVED - '.\Lib\Enroll-VaultSystem.ps1',
                            # WIP - '.\Lib\Export-CentrifyPolicy.ps1',
                            '.\Lib\Get-VaultAccount.ps1',
                            '.\Lib\Get-VaultAccountSet.ps1',
                            '.\Lib\Get-CentrifyApplication.ps1',
                            '.\Lib\Get-VaultDatabase.ps1',
                            '.\Lib\Get-VaultDatabaseSet.ps1',
                            '.\Lib\Get-VaultDomain.ps1',
                            '.\Lib\Get-VaultDomainSet.ps1',
                            '.\Lib\Get-CentrifyEnrollmentCode.ps1',
                            '.\Lib\Get-CentrifyRole.ps1',
                            '.\Lib\Get-VaultSecret.ps1',
                            '.\Lib\Get-VaultSecretSet.ps1',
                            '.\Lib\Get-VaultSshKey.ps1',
                            '.\Lib\Get-VaultSystem.ps1',
                            '.\Lib\Get-VaultSystemSet.ps1',
                            '.\Lib\Get-CentrifyUser.ps1',
                            # WIP - '.\Lib\Import-CentrifyPolicy.ps1',
                            '.\Lib\Invite-CentrifyUser.ps1',
                            '.\Lib\New-VaultAlternateAccount.ps1',
                            '.\Lib\New-CentrifySet.ps1',
                            '.\Lib\New-CentrifyEnrollmentCode.ps1',
                            '.\Lib\New-CentrifyRole.ps1',
                            '.\Lib\New-VaultSecret.ps1',
                            '.\Lib\New-VaultSshKey.ps1',
                            '.\Lib\New-VaultSystem.ps1',
                            '.\Lib\New-CentrifyUser.ps1',
                            '.\Lib\Remove-VaultAccount.ps1',
                            '.\Lib\Remove-CentrifySetMember.ps1',
                            '.\Lib\Remove-CentrifyRole.ps1',
                            '.\Lib\Remove-CentrifyRoleMember.ps1',
                            '.\Lib\Remove-VaultSecret.ps1',
                            '.\Lib\Remove-VaultSshKey.ps1',
                            '.\Lib\Remove-VaultSystem.ps1',
                            '.\Lib\Remove-CentrifyUser.ps1',
                            '.\Lib\Rotate-VaultPassword.ps1',
                            '.\Lib\Run-RedrockQuery.ps1',
                            '.\Lib\Set-VaultAccount.ps1',
                            '.\Lib\Set-VaultPermission.ps1',
                            '.\Lib\Set-VaultSecret.ps1',
                            '.\Lib\Set-VaultSystem.ps1',
                            '.\Lib\Set-CentrifyUser.ps1',
                            '.\Lib\Test-VaultPassword.ps1',
                            '.\Lib\Set-VaultPassword.ps1',
							# Advanced admin commands
							'.\Lib\Get-CentrifyTenantConfig.ps1',
							'.\Lib\Set-CentrifyTenantConfig.ps1'
                           )
	PowerShellVersion 	= '5.0'
	RequiredAssemblies 	= @()
}