/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 05/12/2021
Data de alteração: 

Descrição
Esta tabela será usar para armazerna os valores de configurações da aplicação:
	Colunas:
		-Paremetro = Vai ser os valores 
		-Valor = Os valores do paramentrô
		-TipoValor = o tipo do valor assim o item que chamar o paramentro vai converter para o tipo declarados

A tabela será criada no Schema dbo, por ser de uso geral esta tabela ficara no dbo.

**************************************************************************************************************/

CREATE TABLE [dbo].[Parametro](
	[idParametro] [int] IDENTITY(1,1) NOT NULL,
	[Parametro] [nvarchar](max) NULL,
	[Valor] [nvarchar](max) NULL,
	[TipoValor] [nvarchar](20) NULL,
 CONSTRAINT [PK_idParametro] PRIMARY KEY CLUSTERED 
(
	[idParametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


