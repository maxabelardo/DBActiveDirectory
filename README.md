# DBActiveDirectory

## Descrição:
Este projeto tem o objetivo de criar uma estrutura de dados com as informações extraida do Active Directory que serão utilizados para criação de vários relatórios gerenciais.

### Objetivos a serem alcançados com projeto:
- Lista de usuários
- Lista dos grupos
- Lista dos computadores
- Lista dos controladores de dominio.
- Lista das Unidades organizacionais OU.
- Lista dos contatos
- Lista de GPO 

### Relatórios a serem desenvolvidos com as informações extraidas.
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

## Estrutura de dados
Como os dados são carregados totalmente a cada carrga, as tabelas não são normatizadas e não exites chave extrangeira entre elas, para controle de relacionamento será utilizado os compos ID do Active Directory.

## Tabelas 
![image](https://user-images.githubusercontent.com/55700120/158218921-b82ed99b-7f41-4dc0-9554-6dd2ecc69c9e.png)





