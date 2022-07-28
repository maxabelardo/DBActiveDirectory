CREATE TABLE [SGBD].[MtMySQLReplication] (
    [idMtMySQLReplication] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBD]               INT           NOT NULL,
    [Master_Host]          VARCHAR (65)  NULL,
    [Master_User]          VARCHAR (50)  NULL,
    [Master_Port]          INT           NULL,
    [Connect_Retry]        INT           NULL,
    [Master_Log_File]      VARCHAR (200) NULL,
    [Slave_IO_Running]     VARCHAR (10)  NULL,
    [Slave_SQL_Running]    VARCHAR (10)  NULL,
    [Read_Master_Log_Pos]  VARCHAR (200) NULL,
    [Relay_Log_Pos]        FLOAT (53)    NULL,
    [Exec_Master_Log_Pos]  FLOAT (53)    NULL,
    [Relay_Log_Space]      FLOAT (53)    NULL,
    [DataTimer]            DATETIME      CONSTRAINT [DF__MtMySQLRe__DataT__2E90DD8E] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK__MtMySQLR__BF0CAB1F7A96C33D] PRIMARY KEY CLUSTERED ([idMtMySQLReplication] ASC),
    CONSTRAINT [FK__MtMySQLRe__idSGB__2F8501C7] FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

