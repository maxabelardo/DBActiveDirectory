CREATE TABLE [SGBD].[MtSQLCPU] (
    [idMtSQLCPU]                     INT      IDENTITY (1, 1) NOT NULL,
    [idSGBD]                         INT      NOT NULL,
    [SQLServerProcessCPUUtilization] INT      NULL,
    [SystemIdleProcess]              INT      NULL,
    [OtherProcessCPUUtilization]     INT      NULL,
    [EventTime]                      DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtSQLCPU] ASC),
    CONSTRAINT [FK__MtSQLCPU__idSGBD__6CD828CA] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

