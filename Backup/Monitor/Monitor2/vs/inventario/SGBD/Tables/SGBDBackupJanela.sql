CREATE TABLE [SGBD].[SGBDBackupJanela] (
    [idSGBDBackupJanela] INT            IDENTITY (1, 1) NOT NULL,
    [idSGBD]             INT            NOT NULL,
    [idToolsBackup]      INT            NOT NULL,
    [idTipoOcorrencia]   INT            NOT NULL,
    [idSGBDBackupTipo]   INT            NOT NULL,
    [startJanela]        TIME (7)       NULL,
    [endJanela]          TIME (7)       NULL,
    [dateStat]           DATETIME       NULL,
    [dateEnd]            DATETIME       NULL,
    [outrasConfig]       NVARCHAR (MAX) NULL,
    [Ativo]              BIT            CONSTRAINT [DF__SGBDBacku__Ativo__6B99EBCE] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_idMnBackupJanela] PRIMARY KEY CLUSTERED ([idSGBDBackupJanela] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK__SGBDBacku__idSGB__2D12A970] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD]),
    CONSTRAINT [FK__SGBDBacku__idTip__75235608] FOREIGN KEY ([idTipoOcorrencia]) REFERENCES [SGBD].[TipoOcorrencia] ([idTipoOcorrencia]),
    CONSTRAINT [FK__SGBDBacku__idToo__76177A41] FOREIGN KEY ([idToolsBackup]) REFERENCES [SGBD].[ToolsBackup] ([idToolsBackup]),
    CONSTRAINT [FK_SGBDBackupJanela_SGBDBackupTipo] FOREIGN KEY ([idSGBDBackupTipo]) REFERENCES [SGBD].[SGBDBackupTipo] ([idSGBDBackupTipo])
);

