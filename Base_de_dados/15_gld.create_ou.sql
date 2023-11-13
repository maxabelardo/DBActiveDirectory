
CREATE TABLE [gld].[ou](
	[ObjectGUID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[ObjectClass] [varchar](30) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[ManagedBy] [nvarchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [gld].[ou] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


