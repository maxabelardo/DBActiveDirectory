CREATE TABLE [SGBD].[SGBDTable] (
    [idSGBDTable] INT           IDENTITY (1, 1) NOT NULL,
    [idDatabases] INT           NOT NULL,
    [schema_name] VARCHAR (128) NULL,
    [table_name]  VARCHAR (128) NULL,
    [reservedkb]  REAL          NULL,
    [datakb]      REAL          NULL,
    [Indiceskb]   REAL          NULL,
    [sumline]     INT           NULL,
    [dataupdate]  DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__SGBDTabl__B2C63C1FA6776892] PRIMARY KEY CLUSTERED ([idSGBDTable] ASC),
    CONSTRAINT [FK__SGBDTable__idDat__32AB8735] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

