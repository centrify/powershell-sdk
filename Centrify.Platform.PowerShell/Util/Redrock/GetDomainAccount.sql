SELECT
	VaultAccount.ID as ID,
	VaultDomain.Name as Name,
	VaultDomain.Description as DomainDescription,
	VaultDomain.AllowPasswordHistoryCleanUp,
	VaultDomain.PasswordHistoryCleanUpDuration,
	VaultDomain.DiscoveredTime as DomainDiscoveredTime,
	VaultAccount.User as User,
	VaultAccount.Description as Description,
	VaultDomain.ID as DomainID,
	VaultAccount.DatabaseID as DatabaseID,
	VaultDomain.ProxyCollectionList,
	VaultAccount.ID as VaultAccountID,
	VaultAccount.OwnerName,
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
	VaultDomain 
JOIN
	VaultAccount 
ON
	VaultAccount.DomainID = VaultDomain.ID
