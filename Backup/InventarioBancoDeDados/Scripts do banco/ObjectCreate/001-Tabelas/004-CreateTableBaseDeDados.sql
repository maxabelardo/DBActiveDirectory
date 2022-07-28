/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os banco de dados de uma instancia de banco

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    Trilhas
    Servidor do ServerHost
    Servidor do SGBD

Observação:
    A tabela de base de dados foi reduzia para os dados gerais entre diverso tipos de banco assim a parte esclusivas de cada 
tecnoligia será colocadas nas base voltada a sua versão, exemplo: SQL Server, Oracle, MySQL, PostgreSQL, MongoDb e etc.....    
    
**************************************************************************************************************/

CREATE TABLE [SGBD].[BaseDeDados](
	[idBaseDeDados] [int] IDENTITY(1,1) NOT NULL,
	[idDBServidor] [int] NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[BasedeDados] [varchar](150) NULL,
	[Descricao] [varchar](255) NULL,
	[created] [datetime] NULL,
	[ativo] [bit] NULL,
 CONSTRAINT [PK_BaseDeDados_idBaseDeDados] PRIMARY KEY CLUSTERED 
(
	[idBaseDeDados] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[BaseDeDados] ADD  CONSTRAINT [DF_BaseDeDados_ativo]  DEFAULT ((1)) FOR [ativo]
GO

ALTER TABLE [SGBD].[BaseDeDados]  WITH CHECK ADD  CONSTRAINT [FK_Servidor_BaseDeDados] FOREIGN KEY([idDBServidor])
REFERENCES [SGBD].[Servidor] ([idDBServidor])
GO

ALTER TABLE [SGBD].[BaseDeDados]  WITH CHECK ADD  CONSTRAINT [FK_BaseDeDados_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
