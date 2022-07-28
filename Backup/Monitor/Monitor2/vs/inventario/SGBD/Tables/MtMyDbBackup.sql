CREATE TABLE [SGBD].[MtMyDbBackup] (
    [idMtMyDbBackup]    INT      IDENTITY (1, 1) NOT NULL,
    [idDatabases]       INT      NOT NULL,
    [idSGBD]            INT      NOT NULL,
    [backup_size]       REAL     NULL,
    [backup_start_date] DATETIME NULL,
    [backup_end_date]   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([idMtMyDbBackup] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD]),
    CONSTRAINT [FK__MtMyDbBac__idDat__2645B050] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

