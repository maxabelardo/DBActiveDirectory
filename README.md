# Automatizando a extração de dados do Active Directory para construção de relatórios.

Hoje já existe várias ferramentas que auxiliam o administrador do Active Directory em sua gestão e no desenvolvimento de relatórios ou gráficos, porem os melhores softwares são pagos o que para muitas empresas é o principal problema. Este projeto tem o objetivo de ajudar aqueles que gostariam de ter as  informações do seu AD se ter que ficar rodando script, criando planilha, cruzando dados em Excel, toda vez que vão montando relatórios do seu AD, ou so estão querendo  aprender a automatizar a extração e montagem do relatórios do Active Directory.


Softwares que seram utilizados neste projeto:
|Software |Descrição|
|----|----|
| Active Directory |Origem dos dados
| PowerShell     |Ferramenta de extração
| Microsoft SQL Server  |Local para armazenar os dados.
| Power BI | Ferramenta de analise de dados.


### Atenção:
<i><b> Este projeto não tem objetivo de subistuir ferramentas como [Varonis](https://www.varonis.com/blog/what-is-active-directory), porem é possível obter muitas das informações que o Varonis traz via PowerShell.</i></b>


### O que será feito neste projeto.
+ Criação de uma base de dados no MS SQL Server que vai armazenar os dados.
+ Desenvolvimento dos scripts de extração em PowerShell.
+ Desenvolvimento de View, procedures e functions no MS SQL Server que vão auxiliar no tratamento dos dados.
+ Automatizar a extração dos dados utilizando o MS SQL Agent.
+ Desenvolvimento dos paineis no Power BI Desktop.

### O que será extraido do Active Directory.
- Usuários
- Grupos
- Computadores
- Controladores de dominio.
- OU - Unidades organizacionais.
- Contatos.
- GPO - Diretiva de Grupo.

### Relatórios a serem desenvolvidos com as informações extraidas.
- Qualitativos:
    - Todos os usuários desativados que está fora da OU "BLOQUEADOS" e "DESATIVADOS"
    - Lista de usuários com a senha expirada porem com a conta ativa.
    - Grafico com os indicadores de usuários que teram a conta expiradas nos próximos 60 dias.
    - Grafico com a proporção dos estatus das contas: "Ativa", "Desabilitada", "Expirada" e etc....
- Quantitativo:
    - Total de contas
    - Contas destivadas
    - Contas Ativas
    - Contas ativas de funcionarios da casa.
    - Contas ativas de Cedidos
    - Contas ativas de Tercerizados.
    - Contas Ativas e expiradas.
    - Contas desativadas fora da OU "Bloqueados" ou "Desativados"  


## A execuçã do projeto será divido nos topicos abaixo:

+ [Desenvolvimento da base de dados.](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/README.md)
+ [Desenvolvimento dos scripts de extração em PowerShell.](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/README.md)
+ [Executar o tratamento dos dados.](https://github.com/maxabelardo/DBActiveDirectory/blob/main/tratamento_de_dados/README.md)
+ Automatizar a extração dos dados utilizando o MS SQL Agent.
+ Desenvolvimento dos paineis no Power BI Desktop.