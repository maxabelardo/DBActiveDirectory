CREATE TABLE [ServerHost].[ServerHost] (
    [idServerHost]      INT           IDENTITY (1, 1) NOT NULL,
    [HostName]          VARCHAR (60)  NULL,
    [FisicoVM]          VARCHAR (20)  NULL,
    [SistemaOperaciona] VARCHAR (20)  NULL,
    [IPaddress]         VARCHAR (50)  NULL,
    [PortConect]        VARCHAR (10)  NULL,
    [Descricao]         VARCHAR (255) NULL,
    [Versao]            VARCHAR (350) NULL,
    [CPU]               INT           NULL,
    [Memory]            INT           NULL,
    [Swap]              INT           NULL,
    [Ativo]             BIT           CONSTRAINT [DF_ServerHost_Ativo] DEFAULT ((1)) NULL,
    CONSTRAINT [PK__ServerHo__F1EA723907020F21] PRIMARY KEY CLUSTERED ([idServerHost] ASC)
);

