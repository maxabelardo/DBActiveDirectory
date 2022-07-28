# Microsoft Office 365 Licenciamento.

## Objetivo do projeto:
Este projeto visa estrair as informações do Microsoft Office 365 e consolidar as informações em um banco de dados, apois finalizado o processo de consolidação a informações estara pronta para ser apresentatada em um painel no Power BI.

### Etapas:
#### Levantamento dos requesitos funcionais:
Quais dados serão extraidos?
- Lista de todas as licenças adiquiridas pelo cliente
- Quantitativo de licenças utilizadas pelo cliente.
- Lista de todos os usuário replicado para Nuvem.
- Estatus da conta, se o usuário está ativo ou inativo.
- Licenças atribuidas aos usuários.

        


Será criado um ETL utilizando PowerShell para extrair as informações gravar os dados no SQL Server.
Transformar os campo "Licenses.AccountSkuId", este campo contem as informações das licenças que o usuário detem.
Exporta a lista de licenças do site da Microsoft para o banco de dados.
A lista se contrase no site https://docs.microsoft.com/pt-br/azure/active-directory/enterprise-users/licensing-service-plan-reference

