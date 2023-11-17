# Executar o tratamento dos dados.
Neste momento vamos executar as tarefas que vão transferir os dados do schema <b>brz</b> para o <b>gld</b>, os dados oriundos do AD. já são extraídos com uma certa qualidade o principal motivo para executarmos esta etapa é devido a possíveis problemas na execução da extração, sendo assim só vamos apagar os dados quando a extração for executada com sucesso.

### Grupo e os usuários ligados a ele:
Para termos a lista de usuários que estão vinculados ao um grupo será preciso desmontar o array contido na coluna "Member" da tabela "brz.group", foi desenvolvida Stored Procedure e Funciton que vão executar está tarefa.

- siv.sp_group_member
- siv.fc_return_member

#### Executando o tratamento para os grupos e seus usuários:
```` 
DECLARE @RC int

EXECUTE @RC = [siv].[sp_group_member] 
GO
````

### OU e os usuários ligados a ele:
Para termos a lista de usuários que estão vinculados à OU será preciso desmontar o array contido na coluna "DistinguishedName" da tabela "brz.user", foi desenvolvida Stored Procedure e Funciton que vão executar está tarefa.

- siv.sp_ou_member
- siv.fc_return_member
- siv.fc_return_ou_objetos

#### Executando o tratamento para as OU e seus usuários:
```` 
DECLARE @RC int

EXECUTE @RC = [siv].[sp_ou_member]
GO
````

### Executar a transferência de todas as demais tabelas.
Serão  transferidos os dados das tabelas:
- brz.user
- brz.group
- brz.contact
- brz.computer
- brz.gpo
- brz.ou
- brz.domain_controller


#### Executando o tratamento para as OU e seus usuários:
```` 
DECLARE @RC int

EXECUTE @RC = [siv].[sp_user] 
EXECUTE @RC = [siv].[sp_group] 
EXECUTE @RC = [siv].[sp_gpo] 
EXECUTE @RC = [siv].[sp_computer] 
EXECUTE @RC = [siv].[sp_ou] 
EXECUTE @RC = [siv].[sp_contact] 
EXECUTE @RC = [siv].[sp_domain_controller] 
EXECUTE @RC = [siv].[sp_user] 
EXECUTE @RC = [siv].[sp_user] 

GO
````

