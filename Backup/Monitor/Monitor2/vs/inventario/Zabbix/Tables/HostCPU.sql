CREATE TABLE [Zabbix].[HostCPU] (
    [idHostCPU]    INT          IDENTITY (1, 1) NOT NULL,
    [idServerHost] INT          NOT NULL,
    [Componente]   VARCHAR (50) NULL,
    [Tipo]         VARCHAR (50) NULL,
    [Dia]          VARCHAR (10) NULL,
    [Hora]         TIME (7)     NULL,
    [Valor]        REAL         NULL,
    PRIMARY KEY CLUSTERED ([idHostCPU] ASC),
    CONSTRAINT [FK__HostCPU__idServe__395884C4] FOREIGN KEY ([idServerHost]) REFERENCES [ServerHost].[ServerHost] ([idServerHost]),
    CONSTRAINT [FK__HostCPU__idServe__3A4CA8FD] FOREIGN KEY ([idServerHost]) REFERENCES [ServerHost].[ServerHost] ([idServerHost])
);


GO
CREATE NONCLUSTERED INDEX [Id_rotineira]
    ON [Zabbix].[HostCPU]([idServerHost] ASC)
    INCLUDE([Dia], [Valor]);

