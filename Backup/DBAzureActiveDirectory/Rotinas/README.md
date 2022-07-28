<h1>Cruzamento das licenças do usuários.<h1\>

A tabela "AD.STGADUser" contem os campos: 
    "[userprincipalname]" Login do usuário.
    "[Enabled]" Estatus do usuário, se ele está ativo ou desativado.
    "[TxLicening]" a lista das licenças que estão atribuidas ao usuário.

no campo "[TxLicening]" as licenaças estão no formato que não possiblita o cruzamento dos dados e o nome das licença estão com nome "string_id" com isto fica muito complicado identificar qual licença o usuário tem.

Para resolver o problema foi criado um script que vai dericar toda string do campos "[TxLicening]" cruza com a tabelas "[dbo].[Lincesing]" com o campo "[String_ Id]", o resultado é inserido em uma tabela "[dbo].[UserLincesing]", está tabela será uma tabela do tip N para N.

No final da rotina a tabelas "[dbo].[UserLincesing]" deverá ter todos os usuários e a licença que ele tem atribuida a ele.

A view " [AD].[VW_UserLincesing]" retornará este cruzamento entre as tabelas "[AD].[STGADUser]"," [dbo].[UserLincesing]" e "[dbo].[Lincesing]".


