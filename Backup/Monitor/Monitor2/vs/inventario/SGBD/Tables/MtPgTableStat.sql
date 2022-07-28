CREATE TABLE [SGBD].[MtPgTableStat] (
    [idSGBDPgTableStat] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBDTable]       INT      NOT NULL,
    [seq_scan]          INT      NULL,
    [seq_tup_read]      INT      NULL,
    [idx_scan]          INT      NULL,
    [idx_tup_fetch]     INT      NULL,
    [UpdateDataTimer]   DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDPgTableStat] ASC),
    FOREIGN KEY ([idSGBDTable]) REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
);

