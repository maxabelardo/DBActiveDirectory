# Desenvolvimento da base de dados.

Neste projeto vou dividir a base em três schemas "Bronze","Silver" e "Glod"

#### "Schema" esquemas:
+ <b>Bronze - brz</b>: os dados seram armazenados igual a fonte de origem.
+ <b>Silver - siv</b>: objetos de bancos utilizados para o tratamento dos dados.
+ <b>Gold - gld</b>: views e tabelas com os dados finalizados e prontos para serem utilizados.

Na estrutura da base de dados não vamos utilizar chave primeira com autoincremento pois a cardinalidade da base será fornecida pelo Active Directory através da <b>"SID"</b> ou <b>"ID"</b>  

###  Schema brz.

Tabelas:
|Schema |Tabelas |Descrição |
|----------------------|-------------------|-------------|
|brz |user | Usuários e os grupos do qual os usuários faz parte.|
|brz |group | Grupos e usuários do grupo.|
|brz |contact | Contatos. |
|brz |computer | São os computadores, desktop, servidores cadastrados no AD.|
|brz |gpo | Group Policy é um conjunto de regras que controlam o ambiente de trabalho de contas de usuário e contas de    computador.|
|brz |ou | Unidades Organizacionais em um domínio gerenciado "pasta" permitem agrupar logicamente objetos, como contas de usuário, contas de serviço ou contas de computador.|
|brz |domain_controller |É um controlador de domínio, do inglês domain controller, é um servidor que responde à requisições seguras de autenticação dentro de um domínio Windows.|

#### Scripts para criação das tabelas:

- [00_create_shema.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/00_create_shema.sql)
- [01_create_brz_user.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/01_create_brz_user.sql)
- [02_create_brz_group.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/02_create_brz_group.sql)
- [03_create_brz_contact.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/03_create_brz_contact.sql)
- [04_create_brz_computer.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/04_create_brz_computer.sql)
- [05_create_brz_gpo.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/05_create_brz_gpo.sql)
- [06_create_brz_ou.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/06_create_brz_ou.sql)
- [07_create_brz_domain_controller.sql](https://github.com/maxabelardo/DBActiveDirectory/tree/main/Base_de_dados)


###  Schema siv e gld.

Objetos:
|Schema |Objetos | Tipo |Descrição |
|-------|--------|------|----------|
|siv |user_account_control | Tabela | Toda conta de usuário tem um status definido pelo campo <b>"userAccountControl"</b> que pode ser: ativo, desativada ou com senha vencida, será nesta tabela que id deste parâmetro serão armazenados.|
|siv |sp_group_member      | Stored Procedures | separar todos os grupos com usuários ligado, armazena os usuários na tabela "gld.group_member"|
|siv |fc_return_member     | Function | Quebra o vetor com o nome dos usuários que estão ligado ao grupo.|
|siv |sp_ou_member         | Stored Procedures |Separa todos os usuários ligado a OU e armazena os usuários na tabela "gld.ou_member"   
|siv |fc_ou_member         | Function | é usado para separar todos os OU com objetos contido nela.|
|siv |fc_return_ou_objetos | Function | Quebra o vetor com o nome dos objetos que estão ligado a OU.| 
|siv |sp_computer          | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_contact           | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_domain_controller | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_gpo               | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_group             | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_ou                | Stored Procedures |Migra os dados do schema siv para gld.
|siv |sp_user              | Stored Procedures |Migra os dados do schema siv para gld.
|gld |user                 | Tabela |  Usuários e os grupos do qual os usuários faz parte.|
|gld |group                | Tabela |  Grupos e usuários do grupo.|
|gld |contact              | Tabela |  Contatos. |
|gld |computer             | Tabela |  São os computadore, desktop, servidores cadastrados no AD.|
|gld |gpo                  | Tabela |  Group Policy é um conjunto de regras que controlam o ambiente de trabalho de contas de usuário e contas de    computador.|
|gld |ou                   | Tabela |  Unidades Organizacionais em um domínio gerenciado "pasta" permitem agrupar logicamente objetos, como contas de usuário, contas de serviço ou contas de computador.|
|gld |domain_controller    | Tabela | É um controlador de domínio, do inglês domain controller, é um servidor que responde à requisições seguras de autenticação dentro de um domínio Windows.|
|gld |group_member         | Tabela | Faz a junção entre os usuários e o grupo  |
|gld |ou_member            | Tabela | Faz a junção entre os usuários e a OU |


#### Scripts para criação das tabelas, function e stored procedure:

- [20_siv.create_user_account_control.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/20_siv.create_user_account_control.sql)
- [21_siv.create_fc_return_member.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/21_siv.create_fc_return_member.sql)
- [22_siv.create_sp_group_member.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/22_siv.create_sp_group_member.sql)
- [23_siv.create_fc_return_ou_objetos.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/23_siv.create_fc_return_ou_objetos.sql)
- [24_siv.create_fc_ou_member.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/24_siv.create_fc_ou_member.sql)
- [25_siv.create_sp_ou_member.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/25_siv.create_sp_ou_member.sql)
- [26_siv_create_sp_computer.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/26_siv_create_sp_computer.sql)
- [27_siv_create_sp_contact.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/27_siv_create_sp_contact.sql)
- [28_siv_create_sp_domain_controller.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/28_siv_create_sp_domain_controller.sql)
- [29_siv_create_sp_gpo.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/29_siv_create_sp_gpo.sql)
- [30_siv_create_sp_group.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/30_siv_create_sp_group.sql)
- [31_siv_create_sp_ou.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/31_siv_create_sp_ou.sql)
- [32_siv_create_sp_user.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/32_siv_create_sp_user.sql)
- [10_gld.create_user.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/10_gld.create_user.sql)
- [11_gld.create_group.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/11_gld.create_group.sql)
- [12_gld.create_contact.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/12_gld.create_contact.sql)
- [13_gld.create_computer.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/13_gld.create_computer.sql)
- [14_gld.create_gpo.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/14_gld.create_gpo.sql)
- [15_gld.create_ou.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/15_gld.create_ou.sql)
- [16_gld.create_domain_controller.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/16_gld_create_group_member.sql)
- [17_gld.create_domain_controller.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/17_gld.create_domain_controller.sql)
- [18_gld_create_ou_member.sql](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Base_de_dados/18_gld_create_ou_member.sql)


|Diagrama do schema gld|
|-|
|![image](https://github.com/maxabelardo/DBActiveDirectory/blob/main/Imagens/diagrama_gld.png?raw=true)|


