/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os dados das colunas das tabelas

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    DBTabela do SGBD
   
**************************************************************************************************************/


CREATE TABLE [SGBD].[TBColuna](
	[idTBColuna] [int] IDENTITY(1,1) NOT NULL,
	[idBDTabela] [int] NOT NULL,
	[colunn_name] [varchar](128) NULL,
	[ordenal_positon] [int] NULL,
	[data_type] [varchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[idTBColuna] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[TBColuna]  WITH CHECK ADD  CONSTRAINT [FK_TBColuna_BDTabela] FOREIGN KEY([idBDTabela])
REFERENCES [SGBD].[BDTabela] ([idBDTabela])
GO
