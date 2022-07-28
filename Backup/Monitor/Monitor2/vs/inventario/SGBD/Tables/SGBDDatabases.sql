CREATE TABLE [SGBD].[SGBDDatabases] (
    [idDatabases]         INT           IDENTITY (1, 1) NOT NULL,
    [idSGBD]              INT           NOT NULL,
    [BasedeDados]         VARCHAR (150) NULL,
    [Descricao]           VARCHAR (255) NULL,
    [owner]               VARCHAR (30)  NULL,
    [dbid]                VARCHAR (30)  NULL,
    [created]             DATETIME      NULL,
    [OnlineOffline]       VARCHAR (30)  NULL,
    [RestrictAccess]      VARCHAR (15)  NULL,
    [recovery_model]      VARCHAR (30)  NULL,
    [collation]           VARCHAR (30)  NULL,
    [compatibility_level] VARCHAR (30)  NULL,
    [ativo]               BIT           CONSTRAINT [DF_SGBDDatabases_ativo] DEFAULT ((1)) NULL,
    CONSTRAINT [PK__SGBDData__2BA9FD7E49097968] PRIMARY KEY CLUSTERED ([idDatabases] ASC),
    CONSTRAINT [FK__SGBDDatab__idSGB__5629CD9C] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

