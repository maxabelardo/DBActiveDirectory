CREATE TABLE [SGBD].[MtUserConnect] (
    [idMtUserConnect] INT           IDENTITY (1, 1) NOT NULL,
    [idSGBD]          INT           NOT NULL,
    [Login]           VARCHAR (128) NULL,
    [session_count]   INT           NULL,
    [DataTimer]       DATETIME      DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([idMtUserConnect] ASC)
);

