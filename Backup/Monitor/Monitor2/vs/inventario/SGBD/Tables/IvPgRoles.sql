CREATE TABLE [SGBD].[IvPgRoles] (
    [idIvPgRoles]    INT            IDENTITY (1, 1) NOT NULL,
    [idSGBD]         INT            NOT NULL,
    [oid]            INT            NOT NULL,
    [rolname]        VARCHAR (50)   NULL,
    [rolsuper]       BIT            NULL,
    [rolinherit]     BIT            NULL,
    [rolcreaterole]  BIT            NULL,
    [rolcreatedb]    BIT            NULL,
    [rolcatupdate]   BIT            NULL,
    [rolcanlogin]    BIT            NULL,
    [rolreplication] BIT            NULL,
    [rolconnlimit]   INT            NULL,
    [rolconfig]      NVARCHAR (MAX) NULL,
    [ativo]          BIT            CONSTRAINT [IvPgRoles_Ativo] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_idIvPgRoles] PRIMARY KEY CLUSTERED ([idIvPgRoles] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

