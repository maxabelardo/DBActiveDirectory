/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os dados voltados as base de dados cadastradas na tabelas "BaseDeDados" 
A parte esclusivas da tecnologia SQL Server será armazenada aqui.

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    BaseDeDados do SGBD

Observação:
    A tabela de base de dados foi reduzia para os dados gerais entre diverso tipos de banco assim a parte esclusivas de cada 
tecnoligia será colocadas nas base voltada a sua versão, exemplo: SQL Server, Oracle, MySQL, PostgreSQL, MongoDb e etc.....    
    
**************************************************************************************************************/


CREATE TABLE [SGBD].[BDSQLServer](
	[idBDSQLServer] [int] IDENTITY(1,1) NOT NULL,
	[idBaseDeDados] [int] NOT NULL,
	[owner] [varchar](30) NULL,
	[dbid] [varchar](30) NULL,
	[OnlineOffline] [varchar](30) NULL,
	[RestrictAccess] [varchar](15) NULL,
	[recovery_model] [varchar](30) NULL,
	[collation] [varchar](30) NULL,
	[compatibility_level] [varchar](30) NULL,
 CONSTRAINT [PK_BDSQLServer_idBDSQLServer] PRIMARY KEY CLUSTERED 
(
	[idBDSQLServer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[BDSQLServer]  WITH CHECK ADD  CONSTRAINT [FK_BDSQLServer_BaseDeDados] FOREIGN KEY([idBaseDeDados])
REFERENCES [SGBD].[BaseDeDados] ([idBaseDeDados])
GO
