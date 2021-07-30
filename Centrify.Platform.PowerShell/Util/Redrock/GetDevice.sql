SELECT
 Device.AfwDeviceId,
 Device.AgentAccount,
 Device.AMSPolicyEnforced,
 Device.Apps,
 Device.AvailableDeviceCapacity,
 Device.AvailableDeviceCapacityDisplay,
 Device.BatteryLevel,
 Device.BytesReceivedNetwork,
 Device.BytesReceivedWIFI,
 Device.BytesSentNetwork,
 Device.BytesSentWIFI,
 Device.Capabilities,
 Device.Carrier,
 Device.CellularTechnology,
 Device.ClientPackageId,
 Device.CommandCountThisWeek,
 Device.CommandCountToday,
 Device.ComplianceState,
 Device.CorporateOwned,
 Device.CustomerID,
 Device.DeviceCapacity,
 Device.DeviceCapacityDisplay,
 Device.DeviceDetails,
 Device.DeviceID,
 Device.DisplayModelName,
 Device.DisplayOsVersion,
 Device.DisplayOwner,
 Device.DisplayState,
 Device.DisplayStateString,
 Device.EnrollmentType,
 Device.FileVaultStatus,
 Device.HasNonExportableKeychainData,
 Device.ID,
 Device.Imei,
 Device.InternalDeviceType,
 Device.IpAddress,
 Device.IsAdminLocationTrackingEnabled,
 Device.Jailbroken,
 Device.KnoxApiLevel,
 Device.KnoxContainerStatus,
 Device.KnoxLicenseActivated,
 Device.KnoxSdkVersion,
 Device.KnoxVersionDisplay,
 Device.LastAttestationState,
 Device.LastAttestationSucceeded,
 Device.LastDeviceOwnerLogin,
 Device.LastInfoReceived,
 Device.LastNotify,
 Device.LastSeen,
 Device.LastUsedCentrifyUrl,
 Device.LastUsedPodUrl,
 Device.Latitude,
 Device.LatitudeDisplay,
 Device.LocationAccuracy,
 Device.LocationTime,
 Device.LoggingCallInfo,
 Device.LoggingCarrierDataUsage,
 Device.LoggingSMS,
 Device.Longitude,
 Device.LongitudeDisplay,
 Device.Manufacturer,
 Device.MissedCallsCount,
 Device.MobileManagerVersion,
 Device.Model,
 Device.ModelName,
 Device.Name,
 Device.OSBuild,
 Device.OSPlatform,
 Device.OSVersion,
 Device.Owner,
 Device.OwnerID,
 Device.PhoneNumber,
 Device.PrimaryEnrolledTenant,
 Device.PrimaryEnrolledUser,
 Device.Product,
 Device.SafeKeyVersion,
 Device.SafeSdkVersion,
 Device.Serial,
 Device.SSOEnabled,
 Device.State,
 Device.StatusFlags,
 Device.SuccessCallsCount
 
FROM
 Device