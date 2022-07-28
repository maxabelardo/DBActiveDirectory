/**************************************************************************************************************
Autor: José Abelardo Vicente Filho
Data de criação: 10/12/2021
Data de alteração: 

Descrição
    Esta tabela será usar para armazerna os valores extraidos pelo script de importação em PowerShell.
O login, o status da conta ela está ativa e as licenças atribuida a conta.
	Colunas:
		-userprincipalname = Login do usuário
		-Enabled           = Estatus da conta, ativo ou desativado
		-TxLicening        = Lista das licenças atribuida ao usuário.
        -LastUpdateEtl     = Data da atualização da informação. 

A tabela será criada no Schema AD

**************************************************************************************************************/


CREATE TABLE [AD].[STGADUser](
	[idSTGADUser] [int] IDENTITY(1,1) NOT NULL,
	[userprincipalname] [varchar](100) NULL,
	[Enabled] [bit] NULL,
	[TxLicening] [varchar](max) NULL,
	[LastUpdateEtl] [datetime] NULL,
 CONSTRAINT [PK_idSTGADUser] PRIMARY KEY CLUSTERED 
(
	[idSTGADUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [AD].[STGADUser] ADD  DEFAULT (getdate()) FOR [LastUpdateEtl]
GO


