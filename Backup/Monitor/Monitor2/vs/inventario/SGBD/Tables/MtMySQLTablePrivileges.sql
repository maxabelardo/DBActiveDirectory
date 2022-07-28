CREATE TABLE [SGBD].[MtMySQLTablePrivileges] (
    [idMtMySQLTablePrivileges] INT          IDENTITY (1, 1) NOT NULL,
    [idSGBDTable]              INT          NOT NULL,
    [GRANTEE]                  VARCHAR (50) NULL,
    [PRIVILEGE_TYPE]           VARCHAR (30) NULL,
    [IS_GRANTABLE]             VARCHAR (10) NULL,
    [dataupdate]               DATETIME     DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtMySQLTablePrivileges] ASC),
    FOREIGN KEY ([idSGBDTable]) REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
);

