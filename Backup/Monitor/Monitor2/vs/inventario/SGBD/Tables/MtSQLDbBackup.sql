CREATE TABLE [SGBD].[MtSQLDbBackup] (
    [idMtSQLDbBackup]      INT           IDENTITY (1, 1) NOT NULL,
    [idDatabases]          INT           NOT NULL,
    [idSGBD]               INT           NOT NULL,
    [user_name]            VARCHAR (128) NULL,
    [physical_device_name] VARCHAR (255) NULL,
    [backup_size]          REAL          NULL,
    [BackupType]           VARCHAR (60)  NULL,
    [collation_name]       VARCHAR (128) NULL,
    [server_name]          VARCHAR (128) NULL,
    [backup_start_date]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([idMtSQLDbBackup] ASC),
    CONSTRAINT [FK__MtSQLDbBa__idDat__32AB8735] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__MtSQLDbBa__idSGB__1332DBDC] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);


GO
CREATE NONCLUSTERED INDEX [ix_rotineiradodia]
    ON [SGBD].[MtSQLDbBackup]([idSGBD] ASC)
    INCLUDE([idDatabases], [backup_size], [backup_start_date]);

