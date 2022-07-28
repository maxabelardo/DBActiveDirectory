CREATE TABLE [Zabbix].[HostNetWork] (
    [idHostNetWork] INT          IDENTITY (1, 1) NOT NULL,
    [idServerHost]  INT          NOT NULL,
    [Componente]    VARCHAR (50) NULL,
    [Tipo]          VARCHAR (50) NULL,
    [Dia]           VARCHAR (10) NULL,
    [Hora]          TIME (7)     NULL,
    [Valor]         REAL         NULL,
    PRIMARY KEY CLUSTERED ([idHostNetWork] ASC)
);

