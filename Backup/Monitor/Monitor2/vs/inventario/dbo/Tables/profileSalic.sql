CREATE TABLE [dbo].[profileSalic] (
    [RowNumber]       INT            IDENTITY (0, 1) NOT NULL,
    [EventClass]      INT            NULL,
    [ApplicationName] NVARCHAR (128) NULL,
    [NTUserName]      NVARCHAR (128) NULL,
    [LoginName]       NVARCHAR (128) NULL,
    [CPU]             INT            NULL,
    [Reads]           BIGINT         NULL,
    [Writes]          BIGINT         NULL,
    [Duration]        BIGINT         NULL,
    [ClientProcessID] INT            NULL,
    [SPID]            INT            NULL,
    [StartTime]       DATETIME       NULL,
    [EndTime]         DATETIME       NULL,
    [DatabaseName]    NVARCHAR (128) NULL,
    [HostName]        NVARCHAR (128) NULL,
    [ServerName]      NVARCHAR (128) NULL,
    [TextData]        NTEXT          NULL,
    [BinaryData]      IMAGE          NULL,
    PRIMARY KEY CLUSTERED ([RowNumber] ASC)
);

