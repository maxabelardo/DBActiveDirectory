CREATE TABLE [SGBD].[MtPgControlAccess] (
    [idMtPgControlAccess] INT          IDENTITY (1, 1) NOT NULL,
    [idDatabases]         INT          NOT NULL,
    [idSGBD]              INT          NOT NULL,
    [usename]             VARCHAR (60) NULL,
    [client_addr]         VARCHAR (60) NULL,
    [query_start]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([idMtPgControlAccess] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD]),
    CONSTRAINT [FK__MtPgContr__idDat__2B0A656D] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

