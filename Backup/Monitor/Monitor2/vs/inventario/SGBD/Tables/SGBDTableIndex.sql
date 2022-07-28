CREATE TABLE [SGBD].[SGBDTableIndex] (
    [idSGBDTableIndex] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBDTable]      INT           NOT NULL,
    [Index_name]       VARCHAR (255) NULL,
    [FileGroup]        VARCHAR (255) NULL,
    [type_desc]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([idSGBDTableIndex] ASC),
    CONSTRAINT [FK__SGBDTableIndex__idDat__32AB8735] FOREIGN KEY ([idSGBDTable]) REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
);

