CREATE TABLE [SGBD].[SGBD] (
    [idSGBD]             INT           IDENTITY (1, 1) NOT NULL,
    [idServerHost]       INT           NOT NULL,
    [Estancia]           VARCHAR (255) NULL,
    [SGBD]               VARCHAR (30)  NULL,
    [IP]                 VARCHAR (255) NULL,
    [Local]              VARCHAR (255) NULL,
    [conectstring]       VARCHAR (255) NULL,
    [Porta]              REAL          NULL,
    [Cluster]            BIT           CONSTRAINT [DF_SGBD_Cluster] DEFAULT ((0)) NULL,
    [Versao]             VARCHAR (255) NULL,
    [Descricao]          VARCHAR (255) NULL,
    [FuncaoServer]       CHAR (100)    NULL,
    [SobreAdministracao] CHAR (100)    NULL,
    [Ativo]              BIT           CONSTRAINT [DF_SGBD_Ativo] DEFAULT ((1)) NULL,
    [MemoryConfig]       INT           NULL,
    [EstanciaAtivo]      BIT           NULL,
    CONSTRAINT [PK__SGBD__BD5208B0182C9B23] PRIMARY KEY CLUSTERED ([idSGBD] ASC),
    CONSTRAINT [FK__SGBD__idServerHo__1A14E395] FOREIGN KEY ([idServerHost]) REFERENCES [ServerHost].[ServerHost] ([idServerHost])
);

