SELECT
	VaultAccount.ID as ID,
	VaultAccount.DomainID as DomainID,
	VaultAccount.DatabaseID as DatabaseID,
	Server.Name as Name,
	Server.SessionType as SessionType,
	Server.FQDN as FQDN,
	Server.ProxyUser,
	Server.ProxyCollectionList,
	Server.Description as ServerDescription,
	VaultAccount.User as User,
	VaultAccount.Description as Description,
	Server.ComputerClass as ComputerClass,
	Server.ID as ServerID,
	Server.Port as Port,
	VaultAccount.ID as VaultAccountID,
	VaultAccount.OwnerName,
	VaultAccount.LastChange,
	VaultAccount.Healthy,
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
	VaultAccount.WorkflowApprover,
	VaultAccount.WorkflowEnabled 
FROM
	Server 
JOIN
	VaultAccount 
ON
	VaultAccount.Host = Server.ID
