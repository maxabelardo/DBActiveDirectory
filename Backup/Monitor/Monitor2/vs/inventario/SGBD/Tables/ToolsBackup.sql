CREATE TABLE [SGBD].[ToolsBackup] (
    [idToolsBackup] INT            IDENTITY (1, 1) NOT NULL,
    [Descricao]     NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_idToolsBackup] PRIMARY KEY CLUSTERED ([idToolsBackup] ASC) WITH (FILLFACTOR = 80)
);

