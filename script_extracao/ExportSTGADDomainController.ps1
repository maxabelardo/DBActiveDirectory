#
# Este script foi criado para extrair os DOMAIN CONTROLLER e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "XXXXXXXX"
$SQLDatabase = "XXXXXXXX"

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[domain_controller]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = 'a*','b*','c*','d*','e*','g*','h*',
'i*','j*','k*','l*','m*','n*','o*','p*','q*','r*','s*','t*','u*','x*','z*','w*',
'1*','2*','3*','4*','5*','6*','7*','8*','9*','0*'



#Loop das iniciais
ForEach($Inicial in $Iniciais){


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{

 $Usrs = Get-ADDomainController -Filter {Name -like $Inicial} | Select-Object Name, HostName, ipv4Address, OperatingSystem, OperatingSystemVersion, site, Enabled  -ErrorAction stop

}catch{
Write-Output $Inicial
throw $_
break
}


#Loop que será usuado para transferir os dados da matriz para o banco de dados
 ForEach($Usr in $Usrs){
 
 #Para cada linha que a matriz percorre e inserido o valor na variável de destino.

    if ($Usr.Name){      
        $Lipemza = $Usr.Name         
        $Name = $Lipemza.replace("'","")	 
    }else{$Name = $Usr.Name}

    if ($Usr.HostName){      
        $Lipemza = $Usr.HostName
	    $HostName = $Lipemza.replace("'","")
    }else{$HostName = $Usr.HostName}

    $IPv4Address = $Usr.IPv4Address

    $OperatingSystem = $Usr.OperatingSystem

    $OperatingSystemVersion = $Usr.OperatingSystemVersion

    $site = $Usr.site

    $Enabled = $Usr.Enabled


#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[domain_controller]
           ([Name],[HostName],[IPv4Address]
           ,[OperatingSystem],[OperatingSystemVersion],[Site]
           ,[Enabled],[LastUpdateEtl])
VALUES ('$Name','$HostName','$IPv4Address'
       ,'$OperatingSystem','$OperatingSystemVersion','$Site'
       ,'$Enabled','$LastUpdateEtl');"


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
}#fim do loop das legras