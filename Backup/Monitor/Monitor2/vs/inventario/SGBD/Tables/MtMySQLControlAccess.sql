CREATE TABLE [SGBD].[MtMySQLControlAccess] (
    [idMtMySQLControlAccess] INT            IDENTITY (1, 1) NOT NULL,
    [idDatabases]            INT            NOT NULL,
    [idSGBD]                 INT            NOT NULL,
    [Id]                     INT            NULL,
    [MyUser]                 VARCHAR (60)   NULL,
    [Host]                   VARCHAR (60)   NULL,
    [Command]                VARCHAR (60)   NULL,
    [Time]                   INT            NULL,
    [State]                  VARCHAR (60)   NULL,
    [Info]                   VARCHAR (2000) NULL,
    [DataTimer]              DATETIME       CONSTRAINT [DF__MtMySQLCo__DataT__05D8E0BE] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__MtMySQLC__B807FC5903F0984C] PRIMARY KEY CLUSTERED ([idMtMySQLControlAccess] ASC),
    CONSTRAINT [FK__MtMySQLCo__idDat__07C12930] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__MtMySQLCo__idSGB__06CD04F7] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

