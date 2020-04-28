SELECT
 Server.ID,
 Server.AgentVersion,
 Server.ComputerClass,
 Server.Description,
 Server.FQDN,
 Server.LastState,
 Server.IsFavorite,
 Server.ActiveSessions,
 Server.ActiveCheckouts,
 Server.IPAddress,
 Server.Joined,
 Server.OperatingSystem,
 Server.Name,
 Server.SessionType,
 Server.Port,
 Server.ProxyUser,
 Server.AllowRemote,
 Server.DefaultCheckoutTime,
 Server.AllowMultipleCheckouts,
 Server.ProxyUserIsManaged,
 Server.ManagementMode,
 Server.ManagementPort,
 Server.AllowHealthCheck,
 Server.HealthCheckInterval,
 Server.AllowPasswordRotation,
 Server.PasswordRotateDuration,
 Server.AllowPasswordHistoryCleanUp,
 Server.PasswordHistoryCleanUpDuration,
 Server.ProxyCollectionList,
 Server.TimeZoneID,
 Server.DiscoveredTime as ServerDiscoveredTime 
FROM
 Server 
ORDER BY
 Name 
COLLATE NOCASE