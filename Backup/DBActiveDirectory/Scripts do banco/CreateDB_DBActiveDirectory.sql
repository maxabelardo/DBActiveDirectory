USE [DBActiveDirectory]
GO
/****** Object:  Table [AD].[STGADComputer]    Script Date: 06/11/2021 12:42:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGADComputer](
	[idSTGADComputer] [int] IDENTITY(1,1) NOT NULL,
	[SID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[SamAccountName] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[ObjectClass] [varchar](30) NULL,
	[PrimaryGroup] [nvarchar](max) NULL,
	[MemberOf] [nvarchar](max) NULL,
	[OperatingSystem] [varchar](30) NULL,
	[OperatingSystemHotfix] [varchar](30) NULL,
	[OperatingSystemServicePack] [varchar](100) NULL,
	[OperatingSystemVersion] [varchar](30) NULL,
	[CanonicalName] [varchar](max) NULL,
	[Enabled] [bit] NULL,
	[IPv4Address] [varchar](20) NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[logonCount] [int] NULL,
	[PasswordExpired] [bit] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AuthenticationPolicy] [varchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADComputer] PRIMARY KEY CLUSTERED 
(
	[idSTGADComputer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGGroup]    Script Date: 06/11/2021 12:42:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGGroup](
	[idSTGGroup] [int] IDENTITY(1,1) NOT NULL,
	[SID] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL,
	[SamAccountName] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[CanonicalName] [varchar](max) NULL,
	[DistinguishedName] [nvarchar](max) NULL,
	[GroupCategory] [varchar](30) NULL,
	[GroupScope] [varchar](30) NULL,
	[ObjectClass] [varchar](30) NULL,
	[ProtectedFromAccidentalDeletion] [bit] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[Modified] [datetime] NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGGroup] PRIMARY KEY CLUSTERED 
(
	[idSTGGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [AD].[STGuser]    Script Date: 06/11/2021 12:42:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AD].[STGuser](
	[idSTGUser] [int] IDENTITY(1,1) NOT NULL,
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
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGUser] PRIMARY KEY CLUSTERED 
(
	[idSTGUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [AD].[STGADComputer] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGGroup] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
ALTER TABLE [AD].[STGuser] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO
