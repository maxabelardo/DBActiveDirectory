
CREATE TABLE [brz].[gpo](
	[ID] [varchar](100) NULL,
	[DisplayName] [varchar](max) NULL,
	[DomainName] [varchar](100) NULL,
	[Owner] [varchar](100) NULL,
	[GpoStatus] [varchar](100) NULL,
	[Description] [text] NULL,
	[UserVersion] [varchar](100) NULL,
	[ComputerVersion] [varchar](100) NULL,
	[CreationTime] [datetime] NULL,
	[ModificationTime] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [brz].[gpo] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


