/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os dados dos indexs das tabelas

A tabela será criada no Schema SGBD

Esta tabela se referencia com as tabelas:
    DBTabela do SGBD
   
**************************************************************************************************************/


CREATE TABLE [SGBD].[TBIndex](
	[idTBIndex] [int] IDENTITY(1,1) NOT NULL,
	[idBDTabela] [int] NOT NULL,
	[Index_name] [varchar](255) NULL,
	[FileGroup] [varchar](255) NULL,
	[type_desc] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idTBIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SGBD].[TBIndex]  WITH CHECK ADD  CONSTRAINT [FK_TBIndex_BDTabela] FOREIGN KEY([idBDTabela])
REFERENCES [SGBD].[BDTabela] ([idBDTabela])
GO
