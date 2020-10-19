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

###########################################################################################
# EXPORT NESTED FUNCTIONS
###########################################################################################

# Explicit Cmdlets export
$FunctionsList = @( 'Add-VaultAccount',
                    'Add-CentrifySetMember',
                    'Add-CentrifyRoleMember',
                    'Checkin-VaultPassword',
                    'Get-VaultPassword',
                    'Checkout-VaultSecret',
                    'Checkout-VaultSshKey',
                    'Connect-CentrifyPlatform',
                    'Enroll-VaultSystem',
                    # WIP - 'Export-CentrifyPolicy',
                    'Get-VaultAccount',
                    'Get-VaultAccountSet',
                    'Get-VaultDatabase',
                    'Get-VaultDomain',
                    'Get-CentrifyEnrollmentCode',
                    'Get-CentrifyRole',
                    'Get-VaultSecret',
                    'Get-VaultSecretSet',
                    'Get-VaultSshKey',
                    'Get-VaultSystem',
                    'Get-VaultSystemSet',
                    'Get-CentrifyUser',
                    # WIP - 'Import-CentrifyPolicy',
                    'Invite-CentrifyUser',
                    'New-VaultAlternateAccount',
                    'New-CentrifySet',
                    'New-CentrifyEnrollmentCode',
                    'New-CentrifyRole',
                    'New-VaultSecret',
                    'New-VaultSshKey',
                    'New-VaultSystem',
                    'New-CentrifyUser',
                    'Remove-VaultAccount',
                    'Remove-CentrifySetMember',
                    'Remove-CentrifyRole',
                    'Remove-CentrifyRoleMember',
                    'Remove-VaultSecret',
                    'Remove-VaultSshKey',
                    'Remove-VaultSystem',
                    'Remove-CentrifyUser',
                    'Rotate-VaultPassword',
                    'Run-RedrockQuery',
                    'Set-VaultAccount',
                    'Set-VaultPermissions',
                    'Set-VaultSecret',
                    'Set-VaultSystem',
                    'Set-CentrifyUser',
                    'Test-VaultPassword',
                    'Set-VaultPassword',
					# Advanced admin commands
					'Get-CentrifyTenantConfig',
					'Set-CentrifyTenantConfig'
                )
Export-ModuleMember -Function $FunctionsList