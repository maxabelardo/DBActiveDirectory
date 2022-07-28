USE [inventario]
GO

/****** Object:  Table [SGBD].[SGBDTable]    Script Date: 03/07/2021 20:23:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SGBD].[SGBDTable](
	[idSGBDTable] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[schema_name] [varchar](128) NULL,
	[table_name] [varchar](128) NULL,
	[reservedkb] [real] NULL,
	[datakb] [real] NULL,
	[Indiceskb] [real] NULL,
	[sumline] [int] NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK__SGBDTabl__B2C63C1FA6776892] PRIMARY KEY CLUSTERED 
(
	[idSGBDTable] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[SGBDTable]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTable__idDat__32AB8735] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO

ALTER TABLE [SGBD].[SGBDTable] CHECK CONSTRAINT [FK__SGBDTable__idDat__32AB8735]
GO


