# CHANGELOG
**1.14.0712**

- Fix Samples scripts to use new cmdlets names

**1.14.0112**

- Renaming the module into Centrify.Platform.Powershell for marketing alignment
- Renaming all cmdlets part of the module for marketing alignement with Centrify Vault Suite
- Fix Role membership update
- Fix call to Get-CentrifyRole
- Fix issue with paremters using Get-VaultAccount
- Fix call to resultant object
- Adding new cmdlets for Set management
- Fix variables name
- Fix Get-VaultSecret
- Fix Get-VaultSshKey

**1.13.1609**

- Fixing several issues with cross cmdlet calls calling for wrong parameter
- Updating Json formatting on several old cmdlets

**1.12.1106**

- Fixing OAuth issues preventing authentication following module renaming

**1.12.1905**

- Renaming the PS Module to match product name, PS Module is now Centrify.PrivilegedAccessService.PowerShell and refer to Centrify PAS Platform
- Adding abiltiy to encode and decode Bas64 secrets for OAuth from the Connect-PASPlatform cmdlet
- Fixing module installation error for first installation (was trying to remove non-existing version)
- Fixing minor issues with uploading file secret to the Centrify Vault

**1.11.1504**

- Hotfix for Secrets management preventing Export in certain conditions

**1.11.1010**

- Adding Set-CisAccount cmdlet to allow enabling/disabling password management on a vaulted account
- Adding CisPassword management cmdlets: Test-CisPassword, Rotate-CisPassword, Update-CisPassword
- Updating Module definition for added cmdlets
- Updating Synopsis information details for several Cmdlets (simplifying the information and correcting mistakes on the Inputs/Outputs) 

**1.10.823**

- Improvement on the Install-CisModule.ps1 script so it can be invoked from a different folder, warn for lack of privilege and unblock files in case policy prevent to execute scripts downloaded from Internet
- Adding wording about Upgrading the module when existing
- Introducing back Get-CisApp and Get-CisEndpoint (as part of Centrify PAS) and deleting the deprecated cmdlets that are part of their respective Get-Cis* cmdlets
- Adding abilty to create Role
- Improve reading Roles by adding search by Name
- Fixing few issues and removing Classes tests
- Adding capabilty to execute any Redrock Query
- Fixing issue with SQL query
- Updating SQL query from wildcard SELECT
- Adding ability to remove Roles
- Listing new Cmdlets for publication as exported commands
- Fixing bugs on Remove-Cisrole and Run-CisRedrockQuery cmdlets
- Updating format of the Readme.md file

**1.9.624**

- Adding ability to create Alternate Account (admin accounts with owners)
- Adding ability to read and update Tenant Config for PAS On-premise edition (Cloud edition only allow to set few settings)
- Adding ability to send email invite to Users existing in connected Directory Services  

**1.8.116**

- Adding ability to remove Systems that have active accounts by deleting the accounts first then the systems (using -Force)
- Adding ability to Export and Import policies. Still known issues preventing Import that need to be fixed in future version.
- Fixing issues on loading Cmdlets by declaring them as NestedModules then explicitly declaring Module members using Export-ModuleMember -Function [List of Cmdlets]
- Still looking at using Classes for object definition and hopefuly improve performance.

**1.7.102**

- Adding feature to mark Cmdlet as deprecated. Now Module only loads *.ps1 files from the Lib folder and ignore others, allowing to disable Cmdlets that will be removed in near future due to the company split.
- Re-work on most of the Get-Cis* commands so they now include additional information like Permissions, Activities, etc. The corresponding Cmdlets have been deprecated.
- Adding SSH Keys support (import, checkout, deletion)
- Identified an issue with ScriptToProcess() method from the Module definition. PowerShell does not always load scripts resulting in failure to properly use this Module as all Cmdlets need the GetCisConnection method.
- Planing to move to Class (supported in PowerShell v5.0) for most of the object definition and allow performance improvement. This however need a lot of work and a massive re-write of several sections.

**1.6.1113**

- The Module has been heavily modified for a better definition of the Cmdlet while masking the internal functions (UtilRestAPI.ps1 scriopt is now loaded as part of the Module).
- All Cmdlets have been added a Help section (using Synopsis format).

**1.5.918**

- The Module is now supporting multiple methods for Authentication and have more Cmdlets for Centrify Privilege Access Services management (CPAS).
- Adding support for MFA on interactive login, adding OAuth2 and Certificates for automation.
- Adding Password management, Secrets management, Sets management
- Installer script has been modified as a PowerShell script that now handled PSModulePath environment variable and support fresh install as well as update (choose Repare).

**1.4.326**

- All references to Resources are changed for Systems. Adding Secrets and Collections (i.e. Sets) management.

**1.3.227**

- The Module is renamed into Centrify.IdentityServices.PowerShell to reflect Product line referencing the Centrify Identity Services being a combination of CIS and CPS running on the Centrify Identity Platform.
- Modified Redrock queries files to be SQL files added as references into the Util folder under Redrock
- Functions available through Utils library are renamed to match Methods naming pattern rather than Cmdlets (as they are not intend to be used as Cmdlets)
- Rename Set-CipConnection into Connect-CisService to reflect MSOL logic, this Cmdlet now use PSCredential object to initiate connection
- Get-CipConnection is deprecated and current connection will be available simply by getting the Global variable
- Rename all Cmdlets with *Cis* trigram to reflect Module name Centrify.IdentityServices.PowerShell and create consistensy across names (removed all *Cps* trigram from names)

**1.2.126**

- Adding Centrify Privilege Services support
- Changes in the Connection need. Now if there is no existing connection, the Cmdlets would return an error and stop, suggesting to create a connection first using Set-CipConnection.
- SQL used for RedRock queries where there is no RestAPI existing is now stored in external files to allow easy update through CIS/CPS upgrade.

**1.1.308**

- Cmdlets are now using a stable Authentication mode to communicate with the Centrify Cloud (using a WebSession for RestAPI calls and replay the ASPXAuth cookie).
- Few functions have been exported into RestAPI library and Cmdlets have been improved.

**1.0.121**

- Redesign of the Module as a proper PowerShell Module (psd built on scripts).

**1.0.703 - BETA**

- First release of a set of Cmdlets for CIS built on Nick Gamb's PS samples to use Centrify RestAPI for the Cloud.	
