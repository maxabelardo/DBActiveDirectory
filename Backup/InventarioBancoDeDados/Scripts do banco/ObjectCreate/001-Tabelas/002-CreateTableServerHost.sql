/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os servidores seja eles fisica ou virtuais

A tabela será criada no Schema ServerHost

Esta tabela se referencia com a tabela:
    Trilhas
    

**************************************************************************************************************/

CREATE TABLE [ServerHost].[Servidor](
	[idSHServidor] [int] IDENTITY(1,1) NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[HostName] [varchar](60) NULL,
	[FisicoVM] [varchar](20) NULL,
	[SistemaOperaciona] [varchar](50) NULL,
	[IPaddress] [varchar](50) NULL,
	[PortConect] [varchar](10) NULL,
	[Descricao] [varchar](max) NULL,
	[Versao] [varchar](350) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK_Servidor_idServidor] PRIMARY KEY CLUSTERED 
(
	[idSHServidor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [ServerHost].[Servidor] ADD  CONSTRAINT [DF_ServerHost_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO

ALTER TABLE [ServerHost].[Servidor]  WITH CHECK ADD  CONSTRAINT [FK_ServerHost_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO

ALTER TABLE [ServerHost].[Servidor] CHECK CONSTRAINT [FK_ServerHost_Trilha]
GO


