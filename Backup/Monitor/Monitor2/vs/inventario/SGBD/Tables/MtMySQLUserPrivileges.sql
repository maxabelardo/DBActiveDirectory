CREATE TABLE [SGBD].[MtMySQLUserPrivileges] (
    [idMtMySQLUserPrivileges] INT            IDENTITY (1, 1) NOT NULL,
    [idSGBD]                  INT            NOT NULL,
    [GRANTEE]                 NVARCHAR (128) NULL,
    [PRIVILEGE_TYPE]          NVARCHAR (128) NULL,
    [IS_GRANTABLE]            NVARCHAR (10)  NULL,
    [dataupdate]              DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_idMtMySQLUserPrivileges] PRIMARY KEY CLUSTERED ([idMtMySQLUserPrivileges] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

