SELECT
 ID,
 CloudState,
 DisplayName,
 DirectoryServiceUuid,
 Email,
 Forest,
 LastInvite,
 LastLogin,
 SearchEmail,
 SecurityQuestionCount,
 SecurityQuestionSet,
 ServiceUser,
 SourceDs,
 SourceDsInstance,
 SourceDsLocalized,
 SourceDsType,
 Status,
 StatusEnum,
 Username,
 UserType 
FROM
 User 
ORDER BY
 Username 
COLLATE NOCASE