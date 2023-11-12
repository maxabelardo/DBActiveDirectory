
CREATE TABLE [brz].[contact](
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[mailNickname] [varchar](100) NULL,
	[mail] [varchar](100) NULL,
	[CanonicalName] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [brz].[contact] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


