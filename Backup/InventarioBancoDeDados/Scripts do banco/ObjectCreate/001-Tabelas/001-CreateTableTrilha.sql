/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna a trilha dos ambiente como:
    - Produção
    - Homologação
    - Treinamento
    - Teste
    - Desenvolvimento

A tabela será criada no Schema dbo, por ser de uso geral esta tabela ficara no dbo.

**************************************************************************************************************/
CREATE TABLE [dbo].[Trilha](
	[idTrilha] [int] IDENTITY(1,1) NOT NULL,
	[Trilha] [nvarchar](15) NULL,
 CONSTRAINT [PK_Trilha] PRIMARY KEY CLUSTERED 
(
	[idTrilha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


