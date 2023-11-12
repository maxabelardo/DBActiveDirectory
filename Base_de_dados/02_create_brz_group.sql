
CREATE TABLE [brz].[group](
	[SID] [varchar](max) NULL,
	[Name] [varchar](max) NULL,
	[DisplayName] [varchar](max) NULL,
	[SamAccountName] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[CanonicalName] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[GroupCategory] [varchar](max) NULL,
	[Member] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[GroupScope] [varchar](30) NULL,
	[ObjectClass] [varchar](30) NULL,
	[ProtectedFromAccidentalDeletion] [bit] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL)
GO

ALTER TABLE [brz].[group] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


