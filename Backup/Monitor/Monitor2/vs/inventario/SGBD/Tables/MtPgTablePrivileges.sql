CREATE TABLE [SGBD].[MtPgTablePrivileges] (
    [idSGBDPgTablePrivileges] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBDTable]             INT           NOT NULL,
    [grantor]                 NVARCHAR (50) NULL,
    [grantee]                 NVARCHAR (50) NULL,
    [table_catalog]           NVARCHAR (50) NULL,
    [privilege_type]          NVARCHAR (20) NULL,
    [is_grantable]            NVARCHAR (5)  NULL,
    [with_hierarchy]          NVARCHAR (5)  NULL,
    [UpdateDataTimer]         DATETIME      DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDPgTablePrivileges] ASC),
    FOREIGN KEY ([idSGBDTable]) REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
);

