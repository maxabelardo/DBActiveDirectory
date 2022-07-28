CREATE TABLE [SGBD].[MtMySQLDatabasePrivileges] (
    [idMtMySQLDatabasePrivileges] INT          IDENTITY (1, 1) NOT NULL,
    [idDatabases]                 INT          NOT NULL,
    [GRANTEE]                     VARCHAR (50) NULL,
    [PRIVILEGE_TYPE]              VARCHAR (30) NULL,
    [IS_GRANTABLE]                VARCHAR (10) NULL,
    [dataupdate]                  DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_idMtMySQLDatabasePrivileges] PRIMARY KEY CLUSTERED ([idMtMySQLDatabasePrivileges] ASC),
    FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

