# Desenvolvimento dos scripts de extração em PowerShell.


Os scripts serão divididos em etapas:
- Limpeza do stager que receberá os dados.
- Montagem do array para busca dos objetos.
- Execução do loop com o array
    - Executa o comando em powershell.
    - Tratamento: remoção de aspas no texto.
    - Gravação do retorno tratado no banco de dados.

Cada script deverá extrair um objeto do Active Directory.


|Script                                |Descrição                        |Tabela de destino |
|--------------------------------------|---------------------------------|------------------|
|[ExportADGPO.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADGPO.ps1) | Extrair as GPO | brz.gpo
|[ExportADGroup.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADGroup.ps1) | Extrair os Grupos de usuários.|brz.group
|[ExportADOrganizationalUnit.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADOrganizationalUnit.ps1) | Extrair as OU. | brz.ou
|[ExportADUser.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADUser.ps1) | Extrair os usuários. |  brz.user
|[ExportADcomputer.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADcomputer.ps1) | Extrair os computadores. | brz.computer
|[ExportADcontact.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportADcontact.ps1) | Extrair os contatos. | brz.contact
|[ExportSTGADDomainController.ps1](https://github.com/maxabelardo/DBActiveDirectory/blob/main/script_extracao/ExportSTGADDomainController.ps1) | Extrair os controladores de domínio. | brz.domain_controller



