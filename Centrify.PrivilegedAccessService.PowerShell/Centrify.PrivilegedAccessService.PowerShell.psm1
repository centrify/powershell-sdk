###########################################################################################
# Centrify Privileged Access Service PowerShell Module
#
# Author : Fabrice Viguier
# Contact: fabrice.viguier AT centrify.com
# Release: 21/01/2016
###########################################################################################

###########################################################################################
# EXPORT NESTED FUNCTIONS
###########################################################################################

# Explicit Cmdlets export
$FunctionsList = @( 'Add-PASAccount',
                    'Add-PASCollectionMember',
                    'Add-PASRoleMember',
                    'Checkin-PASPassword',
                    'Checkout-PASPassword',
                    'Checkout-PASSecret',
                    'Checkout-PASSshKey',
                    'Connect-PASPlatform',
                    'Enroll-PASSystem',
                    # WIP - 'Export-PASPolicy',
                    'Get-PASAccount',
                    'Get-PASAccountCollection',
                    'Get-PASDatabase',
                    'Get-PASDomain',
                    'Get-PASEnrollmentCode',
                    'Get-PASRole',
                    'Get-PASSecret',
                    'Get-PASSecretCollection',
                    'Get-PASSshKey',
                    'Get-PASSystem',
                    'Get-PASSystemCollection',
                    'Get-PASUser',
                    # WIP - 'Import-PASPolicy',
                    'Invite-PASUser',
                    'New-PASAlternateAccount',
                    'New-PASCollection',
                    'New-PASEnrollmentCode',
                    'New-PASRole',
                    'New-PASSecret',
                    'New-PASSshKey',
                    'New-PASSystem',
                    'New-PASUser',
                    'Remove-PASAccount',
                    'Remove-PASCollectionMember',
                    'Remove-PASRole',
                    'Remove-PASRoleMember',
                    'Remove-PASSecret',
                    'Remove-PASSshKey',
                    'Remove-PASSystem',
                    'Remove-PASUser',
                    'Rotate-PASPassword',
                    'Run-PASRedrockQuery',
                    'Set-PASAccount',
                    'Set-PASPermissions',
                    'Set-PASSecret',
                    'Set-PASSystem',
                    'Set-PASUser',
                    'Test-PASPassword',
                    'Update-PASPassword',
					# Advanced admin commands
					'Get-PASTenantConfig',
					'Set-PASTenantConfig'
                )
Export-ModuleMember -Function $FunctionsList