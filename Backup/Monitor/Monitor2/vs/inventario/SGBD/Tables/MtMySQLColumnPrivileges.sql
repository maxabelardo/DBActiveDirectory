CREATE TABLE [SGBD].[MtMySQLColumnPrivileges] (
    [idMtMySQLColumnPrivileges] INT          IDENTITY (1, 1) NOT NULL,
    [idSGBDTableColumn]         INT          NOT NULL,
    [GRANTEE]                   VARCHAR (50) NULL,
    [PRIVILEGE_TYPE]            VARCHAR (30) NULL,
    [IS_GRANTABLE]              VARCHAR (10) NULL,
    [dataupdate]                DATETIME     DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtMySQLColumnPrivileges] ASC),
    FOREIGN KEY ([idSGBDTableColumn]) REFERENCES [SGBD].[SGBDTableColumn] ([idSGBDTableColumn])
);

