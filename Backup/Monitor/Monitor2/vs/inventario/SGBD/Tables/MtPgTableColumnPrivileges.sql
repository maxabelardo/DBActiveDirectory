CREATE TABLE [SGBD].[MtPgTableColumnPrivileges] (
    [idSGBDPgTableColumnPrivileges] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBDTableColumn]             INT           NOT NULL,
    [grantee]                       NVARCHAR (50) NULL,
    [privilege_type]                NVARCHAR (20) NULL,
    [is_grantable]                  NVARCHAR (5)  NULL,
    [UpdateDataTimer]               DATETIME      DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDPgTableColumnPrivileges] ASC),
    FOREIGN KEY ([idSGBDTableColumn]) REFERENCES [SGBD].[SGBDTableColumn] ([idSGBDTableColumn])
);

