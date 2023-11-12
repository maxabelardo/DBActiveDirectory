
CREATE TABLE [brz].[user](
	[SID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[SamAccountName] [varchar](100) NULL,
	[mail] [varchar](100) NULL,
	[Title] [varchar](max) NULL,
	[Department] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[employeeType] [varchar](30) NULL,
	[Company] [varchar](max) NULL,
	[Office] [varchar](max) NULL,
	[City] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[createTimeStamp] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AccountExpirationDate] [datetime] NULL,
	[msExchWhenMailboxCreated] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[EmailAddress] [varchar](200) NULL,
	[MobilePhone] [varchar](100) NULL,
	[msExchRemoteRecipientType] [int] NULL,
	[ObjectClass] [varchar](30) NULL,
	[PasswordExpired] [bit] NULL,
	[PasswordNeverExpires] [bit] NULL,
	[PasswordNotRequired] [bit] NULL,
	[Enabled] [bit] NULL,
	[LockedOut] [bit] NULL,
	[CannotChangePassword] [bit] NULL,
	[userAccountControl] [int] NULL,
	[LastUpdateEtl] [datetime] NULL);
GO

ALTER TABLE [brz].[user] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


