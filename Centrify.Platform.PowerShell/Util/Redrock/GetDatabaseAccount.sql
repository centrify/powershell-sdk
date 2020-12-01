SELECT 
 VaultAccount.ID as ID,
 VaultDatabase.Name as Name,
 VaultDatabase.Description as DatabaseDescription,
 VaultDatabase.DatabaseClass as DatabaseClass,
 VaultDatabase.AllowPasswordHistoryCleanUp,
 VaultDatabase.PasswordHistoryCleanUpDuration,
 VaultAccount.User as User,
 VaultAccount.Description as Description,
 VaultDatabase.ID as DatabaseID,
 VaultAccount.DomainID as DomainID,
 VaultDatabase.ProxyCollectionList,
 VaultAccount.ID as VaultAccountID,
 VaultAccount.LastChange,
 VaultAccount.Status,
 VaultAccount.MissingPassword,
 VaultAccount.ActiveSessions,
 VaultAccount.ActiveCheckouts,
 VaultAccount.User,
 VaultAccount.NeedsPasswordReset,
 VaultAccount.PasswordResetRetryCount,
 VaultAccount.PasswordResetLastError,
 VaultAccount.Rights,
 VaultAccount.IsManaged,
 VaultAccount.Host,
 VaultAccount.UseWheel,
 VaultAccount.Description,
 COALESCE(NULLIF(VaultAccount.WorkflowApprovers, ""), NULLIF(VaultAccount.WorkflowApprover, "")) as WorkflowApprovers,
 VaultAccount.WorkflowEnabled,
 VaultAccount.IsFavorite, 
 VaultAccount.DiscoveredTime as AccountDiscoveredTime  
FROM
 VaultDatabase 
JOIN
 VaultAccount 
ON 
 VaultAccount.DatabaseID = VaultDatabase.ID