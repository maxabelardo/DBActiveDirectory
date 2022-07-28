/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna as instancias instaladas nos servidores

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    Trilhas
    Servidor ServerHost
    
**************************************************************************************************************/

CREATE TABLE [SGBD].[Servidor](
	[idDBServidor] [int] IDENTITY(1,1) NOT NULL,
	[idSHServidor] [int] NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[Estancia] [varchar](255) NULL,
	[SGBD] [varchar](30) NULL,
	[IP] [varchar](255) NULL,
	[Local] [varchar](255) NULL,
	[conectstring] [varchar](255) NULL,
	[Porta] [real] NULL,
	[Cluster] [bit] NULL,
	[Versao] [varchar](255) NULL,
	[Descricao] [varchar](255) NULL,
	[FuncaoServer] [char](100) NULL,
	[SobreAdministracao] [char](100) NULL,
	[Ativo] [bit] NULL,
	[MemoryConfig] [int] NULL,
	[EstanciaAtivo] [bit] NULL,
 CONSTRAINT [PK_Servidor_idDBServidor] PRIMARY KEY CLUSTERED 
(
	[idDBServidor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[Servidor] ADD  CONSTRAINT [DF_SGBD_Cluster]  DEFAULT ((0)) FOR [Cluster]
GO

ALTER TABLE [SGBD].[Servidor] ADD  CONSTRAINT [DF_SGBD_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO

ALTER TABLE [SGBD].[Servidor]  WITH CHECK ADD CONSTRAINT [FK_SHServidor_Servidor] FOREIGN KEY([idSHServidor])
REFERENCES [ServerHost].[Servidor] ([idSHServidor])
GO

ALTER TABLE [SGBD].[Servidor]  WITH CHECK ADD  CONSTRAINT [FK_Servidor_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
