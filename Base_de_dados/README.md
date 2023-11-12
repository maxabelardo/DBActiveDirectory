# Desenvolvimento da base de dados.

Neste projeto vou trazer um pouco da estrutuda do Data Lake, será utilizada três camadas de dados.

<b>Camada Bronze:</b>  Nesta camada, os dados são armazenados no mesmo formato que existem no sistema de origem.

<b>Camada Prata:</b> Dentro desta camada, os dados limpos e transformados são armazenados. Por exemplo, considere lidar com valores vazios (nulos), definir convenções de nomenclatura de colunas e manter os dados em um formato adequado (CSV/Parquet/JSON/etc.). É importante aplicar os mesmos padrões em todos os conjuntos de dados da camada Silver, pois isso garante que os usuários entendam o que esperar dos dados no Data Lake.

<b>Camada Dourada:</b> Armazenamos todos os produtos finais (voltados para o cliente) nesta camada. Se necessário, os conjuntos de dados são unidos e/ou agregados.

A base de dados será divida em "schema" esquemas.

+ brz: os dados seram armazenados igual a fonte de origem.
+ siv: objetos de bancos utilizados para o tratamento dos dados.
+ gld: views e tabelas com os dados finalizados e prontos para serem utilizados.

Na estrutura da base de dados não vamos utilizar chavem primeria auto-incremental pois a cardinalizada da base será fornecida pelo Active Directory atravez da <b>"SID"</b> ou <b>"ID"</b>  

###  Schema <b> brz</b>.

Tabelas:
|Schema |Tabelas |Descrição |
|----------------------|-------------------|-------------|
|brz |user | Usuários e os grupos do qual o usuários faz parte.|
|brz |group | Grupos e usuários do grupo.|
|brz |contact | Contatos. |
|brz |computer | São os computadore, desktop, servidore cadastrados no AD.|
|brz |gpo | Group Policy é um conjunto de regras que controlam o ambiente de trabalho de contas de usuário e contas de    computador.|
|brz |ou | Unidades Organizacionais em um domínio gerenciado "pasta" permitem agrupar logicamente objetos, como contas de usuário, contas de serviço ou contas de computador.|
|brz |domain_controller |É um controlador de domínio, do inglês domain controller, é um servidor que responde à requisições seguras de autenticação dentro de um domínio Windows.|

#### Scripts para criação das tabelas:

- [00_create_shema_brz.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/00_create_shema_brz.sql)
- [01_create_brz_user.sql](Base_de_dados/01_create_brz_user.sql)
- [02_create_brz_group.sql]()
- [03_create_brz_contact.sql]()
- [04_create_brz_computer.sql]()
- [05_create_brz_gpo.sql]()
- [06_create_brz_ou.sql]()
- [07_create_brz_domain_controller.sql]()
