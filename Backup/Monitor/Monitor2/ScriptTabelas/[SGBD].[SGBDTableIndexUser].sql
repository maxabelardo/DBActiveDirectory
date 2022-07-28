USE [inventario]
GO

/****** Object:  Table [SGBD].[SGBDTableIndexUser]    Script Date: 03/07/2021 20:24:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SGBD].[SGBDTableIndexUser](
	[idSGBDTableIndexUser] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableIndex] [int] NOT NULL,
	[last_user_seek] [datetime] NULL,
	[last_user_scan] [datetime] NULL,
	[last_user_lookup] [datetime] NULL,
	[last_user_update] [datetime] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTableIndexUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[SGBDTableIndexUser] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO

ALTER TABLE [SGBD].[SGBDTableIndexUser]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTableIndexUser__idDat__32AB8735] FOREIGN KEY([idSGBDTableIndex])
REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
GO

ALTER TABLE [SGBD].[SGBDTableIndexUser] CHECK CONSTRAINT [FK__SGBDTableIndexUser__idDat__32AB8735]
GO


