CREATE TABLE [SGBD].[SGBDBackupOcorrencia] (
    [idSGBDBackupOCorrencia] INT IDENTITY (1, 1) NOT NULL,
    [idSGBDBackupJanela]     INT NOT NULL,
    [FreqMonday]             BIT DEFAULT ((0)) NULL,
    [FreqTuesDay]            BIT DEFAULT ((0)) NULL,
    [FreqWednesday]          BIT DEFAULT ((0)) NULL,
    [FreqTrursday]           BIT DEFAULT ((0)) NULL,
    [FreqFriday]             BIT DEFAULT ((0)) NULL,
    [FreqSaturday]           BIT DEFAULT ((0)) NULL,
    [Sunday]                 BIT DEFAULT ((0)) NULL,
    CONSTRAINT [PK_idSGBDBackupOCorrencia] PRIMARY KEY CLUSTERED ([idSGBDBackupOCorrencia] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK__SGBDBacku__idSGB__770B9E7A] FOREIGN KEY ([idSGBDBackupJanela]) REFERENCES [SGBD].[SGBDBackupJanela] ([idSGBDBackupJanela])
);

