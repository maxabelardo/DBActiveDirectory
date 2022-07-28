CREATE TABLE [SGBD].[IvPgRolesMembers] (
    [IvPgRolesMembers] INT IDENTITY (1, 1) NOT NULL,
    [idSGBD]           INT NOT NULL,
    [roleid]           INT NULL,
    [member]           INT NULL,
    [grantor]          INT NULL,
    [admin_option]     BIT NULL,
    [ativo]            BIT CONSTRAINT [IvPgRolesMembersAtivo] DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([IvPgRolesMembers] ASC),
    FOREIGN KEY ([idSGBD]) REFERENCES [SGBD].[SGBD] ([idSGBD])
);

