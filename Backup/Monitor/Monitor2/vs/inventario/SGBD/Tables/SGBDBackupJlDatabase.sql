CREATE TABLE [SGBD].[SGBDBackupJlDatabase] (
    [idSGBDBackupJlDatabase] INT            IDENTITY (1, 1) NOT NULL,
    [idSGBDBackupJanela]     INT            NOT NULL,
    [idDatabases]            INT            NOT NULL,
    [RetentionDays]          INT            NOT NULL,
    [startJanela]            TIME (7)       NULL,
    [endJanela]              TIME (7)       NULL,
    [dateStat]               DATETIME       NULL,
    [dateEnd]                DATETIME       NULL,
    [outrasConfig]           NVARCHAR (MAX) NULL,
    [Ativo]                  BIT            NULL,
    CONSTRAINT [PK_idSGBDBackupJlDatabase] PRIMARY KEY CLUSTERED ([idSGBDBackupJlDatabase] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK__SGBDBacku__idSGB__186C9245] FOREIGN KEY ([idSGBDBackupJanela]) REFERENCES [SGBD].[SGBDBackupJanela] ([idSGBDBackupJanela]),
    CONSTRAINT [FK_SGBDBackupJlDatabase_SGBDDatabases] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
);

