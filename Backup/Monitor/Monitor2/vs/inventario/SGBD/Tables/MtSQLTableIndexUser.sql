CREATE TABLE [SGBD].[MtSQLTableIndexUser] (
    [idSGBDTableIndexUser] INT      IDENTITY (1, 1) NOT NULL,
    [idSGBDTableIndex]     INT      NOT NULL,
    [last_user_seek]       DATETIME NULL,
    [last_user_scan]       DATETIME NULL,
    [last_user_lookup]     DATETIME NULL,
    [last_user_update]     DATETIME NULL,
    [UpdateDataTimer]      DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDTableIndexUser] ASC),
    CONSTRAINT [FK__SGBDTableIndexUser__idDat__32AB8735] FOREIGN KEY ([idSGBDTableIndex]) REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
);

