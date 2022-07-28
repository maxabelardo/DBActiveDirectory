CREATE TABLE [SGBD].[IvSQLPermissionDb] (
    [idIvSQLPermissionDb]    INT           IDENTITY (1, 1) NOT NULL,
    [idIvSQLPermissionLogin] INT           NOT NULL,
    [idDatabases]            INT           NOT NULL,
    [idSGBD]                 INT           NOT NULL,
    [DbRole]                 VARCHAR (100) NULL,
    [MemberName]             VARCHAR (100) NULL,
    [StatusPermission]       BIT           CONSTRAINT [DF_IvSQLPermissionDb_StatusPermission] DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([idIvSQLPermissionDb] ASC),
    FOREIGN KEY ([idIvSQLPermissionLogin]) REFERENCES [SGBD].[IvSQLPermissionLogin] ([idIvSQLPermissionLogin]),
    CONSTRAINT [FK__IvSQLPerm__idDat__1EA48E88] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__IvSQLPerm__idSGB__367C1819] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

