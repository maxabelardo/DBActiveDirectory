CREATE TABLE [SGBD].[MtSQLDisk] (
    [idMtSQLDisk] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBD]      INT      NOT NULL,
    [drive]       CHAR (1) NULL,
    [FreeSpace]   INT      NULL,
    [TotalSize]   INT      NULL,
    [Livre]       INT      NULL,
    [DataTimer]   DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtSQLDisk] ASC),
    CONSTRAINT [FK__MtSQLDisk__idSGB__7E02B4CC] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

