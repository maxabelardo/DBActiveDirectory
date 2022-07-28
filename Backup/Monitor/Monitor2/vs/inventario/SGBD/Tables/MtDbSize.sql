CREATE TABLE [SGBD].[MtDbSize] (
    [idMtDbSize]  INT      IDENTITY (1, 1) NOT NULL,
    [idDatabases] INT      NOT NULL,
    [idSGBD]      INT      NOT NULL,
    [db_size]     REAL     NULL,
    [DataTimer]   DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtDbSize] ASC),
    CONSTRAINT [FK__MtDbSize__idData__245D67DE] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__MtDbSize__idSGBD__7A672E12] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);


GO
CREATE NONCLUSTERED INDEX [IDX_dtsz]
    ON [SGBD].[MtDbSize]([DataTimer] ASC)
    INCLUDE([idDatabases], [idSGBD], [db_size]);


GO
CREATE NONCLUSTERED INDEX [IX_rotineiradodia]
    ON [SGBD].[MtDbSize]([idDatabases] ASC, [idSGBD] ASC)
    INCLUDE([DataTimer]);

