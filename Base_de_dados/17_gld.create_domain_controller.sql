
CREATE TABLE [gld].[domain_controller](
	[Name] [varchar](max) NULL,
	[HostName] [varchar](max) NULL,
	[IPv4Address] [varchar](max) NULL,
	[OperatingSystem] [varchar](max) NULL,
	[OperatingSystemVersion] [varchar](max) NULL,
	[Site] [varchar](max) NULL,
	[Enabled] [bit] NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [gld].[domain_controller] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


