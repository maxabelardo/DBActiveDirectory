CREATE TABLE [Rotineira].[BackupsMsMonitorMes] (
    [idSGBD]       INT            NOT NULL,
    [Servidor]     VARCHAR (8000) NULL,
    [BasedeDados]  VARCHAR (150)  NULL,
    [DataExecucao] NCHAR (10)     NULL,
    [Tamanho]      REAL           NULL,
    [BACKUP]       INT            NOT NULL
);

