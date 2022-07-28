CREATE TABLE [SGBD].[MtSQLControlAccess] (
    [idMtSQLControlAccess] INT           IDENTITY (1, 1) NOT NULL,
    [idDatabases]          INT           NOT NULL,
    [idSGBD]               INT           NOT NULL,
    [loginame]             VARCHAR (128) NULL,
    [cpu]                  INT           NULL,
    [hostname]             VARCHAR (128) NULL,
    [program_name]         VARCHAR (128) NULL,
    [status]               VARCHAR (30)  NULL,
    [blocked]              VARCHAR (5)   NULL,
    [spid]                 INT           NULL,
    [login_time]           DATETIME      NULL,
    [horasAtual]           DATETIME      NULL,
    [tempo]                INT           NULL,
    PRIMARY KEY CLUSTERED ([idMtSQLControlAccess] ASC),
    CONSTRAINT [FK__MtSQLCont__idDat__2FCF1A8A] FOREIGN KEY ([idDatabases]) REFERENCES [SGBD].[SGBDDatabases] ([idDatabases]),
    CONSTRAINT [FK__MtSQLCont__idSGB__0C85DE4D] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

