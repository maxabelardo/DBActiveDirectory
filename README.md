# Active Directory - Power BI
## Active Directory, PowerShell, SQL Server 2016 e Power BI
#ActiveDirectory, #PowerShell, #SQLServer2016, #PowerBI

Hoje já existe várias ferramentas que auxiliam o administrador do Active Directory na criação de relatórios e gráficos, do ambiente de AD, porem as melhores são paga. Este projeto tem o objetivo de ajudar aqueles que gostariam de ter informações do seu AD se precisar ficar rodando script criando planilha e montando relatório ou mesmo aprender como extrair estas informações.

## Atenção:
Este projeto não tem objetivo de subistuir ferramentas como [Varonis](https://www.varonis.com/blog/what-is-active-directory), porem é possível obter muitas das informações que o Varonis traz via PowerShell.


## Descrição:
Criar uma estrutura de banco de dados com as informações extraida do Active Directory via PowerShell, que serão utilizados para criação de vários relatórios, painéis e gráficos via Power BI.


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

Job que executa os script de extração:
![image](https://user-images.githubusercontent.com/55700120/158241700-036236ee-f2b6-460a-80b8-39b1a7011e8b.png)









