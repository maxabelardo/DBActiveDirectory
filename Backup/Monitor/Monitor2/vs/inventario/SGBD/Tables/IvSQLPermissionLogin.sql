CREATE TABLE [SGBD].[IvSQLPermissionLogin] (
    [idIvSQLPermissionLogin] INT           IDENTITY (1, 1) NOT NULL,
    [idDatabases]            INT           NOT NULL,
    [idSGBD]                 INT           NOT NULL,
    [nameUser]               VARCHAR (128) NULL,
    [loginname]              VARCHAR (128) NULL,
    [isntname]               INT           NULL,
    [sysadmin]               INT           NULL,
    [securityadmin]          INT           NULL,
    [serveradmin]            INT           NULL,
    [setupadmin]             INT           NULL,
    [processadmin]           INT           NULL,
    [diskadmin]              INT           NULL,
    [dbcreator]              INT           NULL,
    [bulkadmin]              INT           NULL,
    [Ativo]                  BIT           CONSTRAINT [DF_IvSQLPermissionLogin_Ativo] DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([idIvSQLPermissionLogin] ASC),
    CONSTRAINT [FK__IvSQLPerm__idDat__2180FB33] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__IvSQLPerm__idSGB__1EA48E88] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

