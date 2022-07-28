CREATE TABLE [SGBD].[MtPgTableIndexStat] (
    [idSGBDTPgTableIndexStat] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBDTableIndex]        INT      NOT NULL,
    [idx_scan]                BIGINT   NULL,
    [idx_tup_read]            BIGINT   NULL,
    [idx_tup_fetch]           BIGINT   NULL,
    [UpdateDataTimer]         DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDTPgTableIndexStat] ASC),
    FOREIGN KEY ([idSGBDTableIndex]) REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
);

