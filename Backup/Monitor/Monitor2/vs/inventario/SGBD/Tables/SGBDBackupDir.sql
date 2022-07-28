CREATE TABLE [SGBD].[SGBDBackupDir] (
    [idSGBDBackupDir]    INT           IDENTITY (1, 1) NOT NULL,
    [idSGBDBackupJanela] INT           NOT NULL,
    [DirToBackup]        VARCHAR (MAX) NULL,
    [ExtFile]            VARCHAR (3)   NULL,
    [ativo]              BIT           DEFAULT ((1)) NULL,
    CONSTRAINT [PK_idSGBDBackupJanelaConfig ] PRIMARY KEY CLUSTERED ([idSGBDBackupDir] ASC),
    CONSTRAINT [FK__SGBDBacku__idSGB__733B0D96] FOREIGN KEY ([idSGBDBackupJanela]) REFERENCES [SGBD].[SGBDBackupJanela] ([idSGBDBackupJanela])
);

