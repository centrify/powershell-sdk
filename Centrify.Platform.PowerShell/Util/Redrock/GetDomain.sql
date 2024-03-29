SELECT
 VaultDomain.Administrator,
 VaultDomain.AdministratorDisplayName,
 VaultDomain.AllowAutomaticAccountMaintenance,
 VaultDomain.AllowAutomaticAccountUnlock,
 VaultDomain.AllowAutomaticLocalAccountMaintenance,
 VaultDomain.AllowHealthCheck,
 VaultDomain.AllowManualAccountUnlock,
 VaultDomain.AllowManualLocalAccountUnlock,
 VaultDomain.AllowMultipleCheckouts,
 VaultDomain.AllowPasswordHistoryCleanUp,
 VaultDomain.AllowPasswordRotation,
 VaultDomain.AllowPasswordRotationAfterCheckin,
 VaultDomain.AllowRefreshZoneJoined,
 VaultDomain.AllowZoneRoleCleanup,
 VaultDomain.DefaultCheckoutTime,
 VaultDomain.Description,
 VaultDomain.DiscoveredTime,
 VaultDomain.ForestID,
 VaultDomain.HealthCheckInterval,
 VaultDomain.HealthStatus,
 VaultDomain.HealthStatusError,
 VaultDomain.ID,
 VaultDomain.LastHealthCheck,
 VaultDomain.LastRefreshZoneJoined,
 VaultDomain.LastState,
 VaultDomain.LastZoneRoleCleanup,
 VaultDomain.MinimumPasswordAge,
 VaultDomain.Name,
 VaultDomain.ParentID,
 VaultDomain.PasswordHistoryCleanUpDuration,
 VaultDomain.PasswordProfileID,
 VaultDomain.PasswordRotateDuration,
 VaultDomain.PasswordRotateInterval,
 VaultDomain.ProvisioningAdminID,
 VaultDomain.ProxyCollectionList,
 VaultDomain.Reachable,
 VaultDomain.ReachableError,
 VaultDomain.ReconciliationAccountName,
 VaultDomain.RefreshZoneJoinedIntervalMinutes,
 VaultDomain.SyncFromConnector,
 VaultDomain.UniqueId,
 VaultDomain.ZoneRoleCleanupIntervalHours,
 VaultDomain.ZoneRoleWorkflowApprovers,
 VaultDomain.ZoneRoleWorkflowApproversList,
 VaultDomain.ZoneRoleWorkflowEnabled,
 VaultDomain.ZoneRoleWorkflowRoles
 
FROM
 VaultDomain