<#
Autor: José Abelardo Vicente Filho
Data de criação: 09/12/2021
Data de alteração: 

Objetivo: Extrair as lista de usuários ativos e suas licenças do Nuvem Office 365

Fluxo de execução:
    - O script se conecta na nuvem com um usuário informado no código e a senha criptografada em um arquivo.
    - Executa o comando de extração.
    - Inseri os dados no banco de dados, na tabela de Stage.
#>

#Variáveis
    #UsuÃ¡rio para se conectar.
    $username = "svc-sede-reportsbi@infraerogovbr.onmicrosoft.com"

    #Arquivo com a senha criptografada.
    $pwdTxt = Get-Content "C:\Temp\ExportedPassword.txt"

    #Converte texto simples ou strings criptografadas em strings seguras.
    $securePwd = $pwdTxt | ConvertTo-SecureString 

    #Cria o objeto para ser conectar na nuvem.
    $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
    
    #Servido e banco de dados.
    $SQLInstance = "S-SEBN2611"

    #Base de dados de destino.
    $SQLDatabase = "DBAzureActiveDirectory"
    

#Parametro necessário para execução do script dentro do job no SQL Server.
Set-Location C:

#Iniciar a conexão com a nuvem.
Connect-MsolService -Credential $credObject

#Como a conexão pode levar um tempo este comando server para parar o codigo por quinze segundos.
Start-Sleep -s 15


    #Extração dos usuários e licenças e importa para a variável que é uma MATRIZ composta por linhas e colunas.
    $Usrs = Get-MsolUser -All -EnabledFilter EnabledOnly | select userprincipalname,islicensed, @{Name='Lincensing';Expression={$_.Licenses.AccountSkuId }}


    #Limpa a tabela de Stage no servidor.
     $SQLQueryDelete = "USE $SQLDatabase
        TRUNCATE TABLE [AD].[STGADUser]"

    #Executa o script caregado na linha acima.
    $SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#Loop que irar ler a matriz da linha 1 até a última linha.
ForEach ($Usr in $Usrs) {

#Cara cada volta do Loop o as variáveis recebem os valores da linha da matriz.
    #Variáveis            Colunas
    $userprincipalname = $Usr.userprincipalname 
    $islicensed  = $Usr.islicensed
    $Lincensing  = $Usr.Lincensing  

        #Script que fará a inserção na tabela.
        $SQLQuery = "USE $SQLDatabase
        INSERT INTO [AD].[STGADUser]
           ([userprincipalname],[Enabled],[TxLicening])
        VALUES ('$userprincipalname', '$islicensed', '$Lincensing' );"

            #Execução do script carregado logo acima.
            try{
                $SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
            }catch{
                Write-Output $SQLQuery
            throw $_
            break
            } 

}