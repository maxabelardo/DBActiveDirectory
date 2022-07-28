CREATE TABLE [SGBD].[MtMySQLTableIndexStat] (
    [idSGBDTMySQLTableIndexStat] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBDTableIndex]           INT      NOT NULL,
    [INDEX_ID]                   BIGINT   NULL,
    [page_no]                    BIGINT   NULL,
    [n_recs]                     BIGINT   NULL,
    [data_size]                  BIGINT   NULL,
    [hashed]                     BIGINT   NULL,
    [access_time]                BIGINT   NULL,
    [UpdateDataTimer]            DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDTMySQLTableIndexStat] ASC),
    FOREIGN KEY ([idSGBDTableIndex]) REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
);

