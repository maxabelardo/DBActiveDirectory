CREATE TABLE [SGBD].[MtPgDbBackup] (
    [idMtPgDbBackup]      INT           IDENTITY (1, 1) NOT NULL,
    [idDatabases]         INT           NOT NULL,
    [idSGBD]              INT           NOT NULL,
    [no_encoding_collate] VARCHAR (50)  NULL,
    [backup_start_date]   DATETIME      NULL,
    [backup_end_date]     DATETIME      NULL,
    [ds_dir]              VARCHAR (100) NULL,
    [st_type]             VARCHAR (20)  NULL,
    [st_size]             REAL          NULL,
    PRIMARY KEY CLUSTERED ([idMtPgDbBackup] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD]),
    CONSTRAINT [FK__MtPgDbBac__idDat__2CF2ADDF] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

