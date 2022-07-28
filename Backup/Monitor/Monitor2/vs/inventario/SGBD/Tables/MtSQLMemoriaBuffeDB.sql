CREATE TABLE [SGBD].[MtSQLMemoriaBuffeDB] (
    [idMtSQLMemoriaBuffeDB] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBD]                INT           NOT NULL,
    [DatabaseName]          VARCHAR (200) NULL,
    [CachedSizeMB]          REAL          NULL,
    [DataTimer]             DATETIME      CONSTRAINT [DF__MtSQLMemo__DataT__7755B73D] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__MtSQLMem__044DCC69756D6ECB] PRIMARY KEY CLUSTERED ([idMtSQLMemoriaBuffeDB] ASC),
    CONSTRAINT [FK__MtSQLMemo__idSGB__7849DB76] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

