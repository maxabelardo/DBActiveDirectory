CREATE TABLE [SGBD].[SGBDBackupTipo] (
    [idSGBDBackupTipo] INT            IDENTITY (1, 1) NOT NULL,
    [Descricao]        NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_idSGBDBackupTipo] PRIMARY KEY CLUSTERED ([idSGBDBackupTipo] ASC) WITH (FILLFACTOR = 80)
);

