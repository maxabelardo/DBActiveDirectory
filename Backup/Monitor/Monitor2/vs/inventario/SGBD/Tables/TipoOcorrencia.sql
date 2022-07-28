CREATE TABLE [SGBD].[TipoOcorrencia] (
    [idTipoOcorrencia] INT            IDENTITY (1, 1) NOT NULL,
    [Descricao]        NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_idTipoOcorrencia] PRIMARY KEY CLUSTERED ([idTipoOcorrencia] ASC) WITH (FILLFACTOR = 80)
);

