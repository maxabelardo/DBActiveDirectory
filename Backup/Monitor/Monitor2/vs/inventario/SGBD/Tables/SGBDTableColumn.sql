CREATE TABLE [SGBD].[SGBDTableColumn] (
    [idSGBDTableColumn] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBDTable]       INT           NOT NULL,
    [colunn_name]       VARCHAR (128) NULL,
    [ordenal_positon]   INT           NULL,
    [data_type]         VARCHAR (128) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDTableColumn] ASC),
    CONSTRAINT [FK__SGBDTableColumn__idDat__32AB8735] FOREIGN KEY ([idSGBDTable]) REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
);

