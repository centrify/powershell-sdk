###########################################################################################
# Centrify Identity Services PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

###########################################################################################
# EXPORT NESTED FUNCTIONS
###########################################################################################

# Explicit Cmdlets export
$FunctionsList = @( 'Add-CisAccount',
                    'Add-CisCollectionMember',
                    'Add-CisRoleMember',
                    'Checkin-CisPassword',
                    'Checkout-CisPassword',
                    'Checkout-CisSecret',
                    'Checkout-CisSshKey',
                    'Connect-CisService',
                    'Enroll-CisSystem',
                    # WIP - 'Export-CisPolicy',
                    'Get-CisAccount',
                    'Get-CisAccountCollection',
                    'Get-CisDatabase',
                    'Get-CisDomain',
                    'Get-CisEnrollmentCode',
                    'Get-CisRole',
                    'Get-CisSecret',
                    'Get-CisSecretCollection',
                    'Get-CisSshKey',
                    'Get-CisSystem',
                    'Get-CisSystemCollection',
                    'Get-CisUser',
                    # WIP - 'Import-CisPolicy',
                    'Invite-CisUser',
                    'New-CisAlternateAccount',
                    'New-CisCollection',
                    'New-CisEnrollmentCode',
                    'New-CisRole',
                    'New-CisSecret',
                    'New-CisSshKey',
                    'New-CisSystem',
                    'New-CisUser',
                    'Remove-CisAccount',
                    'Remove-CisCollectionMember',
                    'Remove-CisRole',
                    'Remove-CisRoleMember',
                    'Remove-CisSecret',
                    'Remove-CisSshKey',
                    'Remove-CisSystem',
                    'Remove-CisUser',
                    'Rotate-CisPassword',
                    'Run-CisRedrockQuery',
                    'Set-CisAccount',
                    'Set-CisPermissions',
                    'Set-CisSecret',
                    'Set-CisSystem',
                    'Set-CisUser',
                    'Test-CisPassword',
                    'Update-CisPassword',
					# Advanced admin commands
					'Get-CisTenantConfig',
					'Set-CisTenantConfig'
                )
Export-ModuleMember -Function $FunctionsList