

CREATE TABLE [brz].[computer](
	[SID] [varchar](100) NULL,
	[Name] [varchar](max) NULL,
	[DisplayName] [varchar](max) NULL,
	[SamAccountName] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[ObjectClass] [varchar](30) NULL,
	[PrimaryGroup] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[OperatingSystem] [varchar](max) NULL,
	[OperatingSystemHotfix] [varchar](max) NULL,
	[OperatingSystemServicePack] [varchar](max) NULL,
	[OperatingSystemVersion] [varchar](max) NULL,
	[CanonicalName] [varchar](max) NULL,
	[Enabled] [bit] NULL,
	[IPv4Address] [varchar](max) NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[logonCount] [int] NULL,
	[PasswordExpired] [bit] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AuthenticationPolicy] [varchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [brz].[computer] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


