/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os valores do tamanho da base neste monento da capitura

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    Trilhas
    BancoDeDados ServerHost
    
**************************************************************************************************************/

CREATE TABLE [SGBD].[MTBDTamanho](
	[idMTBDTamanho] [int] IDENTITY(1,1) NOT NULL,
	[idBaseDeDados] [int] NOT NULL,
	[Tamanho] [real] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMTBDTamanho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[MTBDTamanho] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO

ALTER TABLE [SGBD].[MTBDTamanho]  WITH CHECK ADD  CONSTRAINT [FK_BaseDeDados_idBaseDeDados] FOREIGN KEY([idBaseDeDados])
REFERENCES [SGBD].[BaseDeDados] ([idBaseDeDados])
GO
