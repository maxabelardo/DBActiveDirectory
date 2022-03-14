#
# Este script foi criado para extrair os usuários e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBN2611"
$SQLDatabase = "DBActiveDirectory"

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos

 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [AD].[STGADGPO]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{

 $Usrs = Get-GPO -All | SELECT Id, DisplayName, DomainName, Owner, GpoStatus, Description, UserVersion, ComputerVersion,
    @{Name='CreationTime';Expression={$_.CreationTime.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name='ModificationTime';Expression={$_.ModificationTime.ToString("yyyy\/MM\/dd HH:mm:ss")}} -ErrorAction stop

}catch{
Write-Output $Inicial
throw $_
break
}


#Loop que será usuado para transferir os dados da matriz para o banco de dados
 ForEach($Usr in $Usrs){
 
 #Para cada linha que a matriz percorre e inserido o valor na variável de destino.

    $Id = $Usr.Id

    if ($Usr.DisplayName){      
        $Lipemza = $Usr.DisplayName         
        $DisplayName = $Lipemza.replace("'","")	 
    }else{$DisplayName = $Usr.DisplayName}

    $DomainName = $Usr.DomainName

    if ($Usr.Owner){      
        $Lipemza = $Usr.Owner         
        $Owner = $Lipemza.replace("'","")	 
    }else{$Owner = $Usr.Owner}

    $GpoStatus = $Usr.GpoStatus

    if ($Usr.Description){      
        $Lipemza = $Usr.Description         
        $Description = $Lipemza.replace("'","")	 
    }else{$Description = $Usr.Description} 

    $UserVersion = $Usr.UserVersion
    $ComputerVersion = $Usr.ComputerVersion
    $CreationTime = $Usr.CreationTime
    $ModificationTime = $Usr.ModificationTime




#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [AD].[STGADGPO]
           ([ID],[DisplayName],[DomainName]
           ,[Owner],[GpoStatus],[Description]
           ,[UserVersion],[ComputerVersion]
           ,[CreationTime],[ModificationTime])

VALUES     ('$ID','$DisplayName','$DomainName'
           ,'$Owner','$GpoStatus','$Description'
           ,'$UserVersion','$ComputerVersion'
           ,'$CreationTime','$ModificationTime') ;"


#Executa o comando de insert com os dados
try{
    $SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
#Fim do loop da matriz com os usuário
}
#A matriz "$Usrs e limpada para reseber novos dados.
$Usrs.clear
