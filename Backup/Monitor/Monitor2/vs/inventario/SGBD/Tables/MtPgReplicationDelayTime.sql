CREATE TABLE [SGBD].[MtPgReplicationDelayTime] (
    [idMtPgReplicationdelayTime] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBD]                     INT      NOT NULL,
    [replication_delay]          REAL     NOT NULL,
    [EventTime]                  DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtPgReplicationdelayTime] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);


GO
CREATE NONCLUSTERED INDEX [indx_replicatinografico]
    ON [SGBD].[MtPgReplicationDelayTime]([idSGBD] ASC)
    INCLUDE([replication_delay], [EventTime]);

