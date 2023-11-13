# Este script foi criado para extrair os "Computadores" e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "XXXXXXXX" # Nome da estância de banco de dados
$SQLDatabase = "XXXXXXXX" # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:

#Script:
# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[computer]"
    
#Executando o script carragado na variável "$SQLQueryDelete"
$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance
    #Variável que recebe a saida da execução: $SQLQuery1Output
    #comando que executa o script: "Invoke-Sqlcmd"
    #Paramentro que indica que será executado um script dentro de uma variável "-query"
    #Paramentro que define a extancia de banco de dados que será executado script "-ServerInstance"


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
    $Usrs = Get-ADComputer -f {Name -like $Inicial} -Properties * | Select-Object SID, Name, DisplayName, SamAccountName, Description, ObjectClass, PrimaryGroup, MemberOf,
        OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, OperatingSystemVersion,
        CanonicalName, Enabled,IPv4Address, 
        @{Name='Created';Expression={$_.Created.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name='Deleted';Expression={$_.Deleted.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name='Modified';Expression={$_.Modified.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name='LastLogonDate';Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        logonCount,
        PasswordExpired, 
        @{Name='PasswordLastSet';Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}}, 
        AuthenticationPolicy -ErrorAction stop
    }catch{
        Write-Output $Inicial
    throw $_
    break
    }


#Loop que será usuado para transferir os dados da matriz para o banco de dados
 ForEach($Usr in $Usrs){
 
 #Para cada linha que a matriz percorre e inserido o valor na variável de destino.
	$SID = $Usr.SID

    if ($Usr.Name){      
        $Lipemza = $Usr.Name         
        $Name = $Lipemza.replace("'","")	 
    }else{$Name = $Usr.Name}

    if ($Usr.DisplayName){      
        $Lipemza = $Usr.DisplayName
	    $DisplayName = $Lipemza.replace("'","")
    }else{$DisplayName = $Usr.DisplayName}

	$SamAccountName = $Usr.SamAccountName

    if ($Usr.Description){      
        $Lipemza = $Usr.Description
	    $Description = $Lipemza.replace("'","")
    }else{$Description = $Usr.Description}	

    $ObjectClass = $Usr.ObjectClass

    if ($Usr.PrimaryGroup){      
        $Lipemza = $Usr.PrimaryGroup
	    $PrimaryGroup = $Lipemza.replace("'","")
    }else{$PrimaryGroup = $Usr.PrimaryGroup}	

    if ($Usr.MemberOf){      
        $Lipemza = $Usr.MemberOf
	    $MemberOf = $Lipemza.replace("'","")
    }else{$MemberOf = $Usr.MemberOf}

    $OperatingSystem = $Usr.OperatingSystem
    $OperatingSystemHotfix = $Usr.OperatingSystemHotfix
    $OperatingSystemServicePack = $Usr.OperatingSystemServicePack
    $OperatingSystemVersion = $Usr.OperatingSystemVersion
    $CanonicalName = $Usr.CanonicalName
    $Enabled = $Usr.Enabled
    $IPv4Address = $Usr.IPv4Address
    $Created = $Usr.Created
	$Modified = $Usr.Modified
	$Deleted = $Usr.Deleted
    $LastLogonDate = $Usr.LastLogonDate
    $logonCount = $Usr.logonCount
    $PasswordExpired = $Usr.PasswordExpired
    $PasswordLastSet = $Usr.PasswordLastSet
    $AuthenticationPolicy = $Usr.AuthenticationPolicy


#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[computer]
           ([SID],[Name],[DisplayName],[SamAccountName],[Description],[ObjectClass],[PrimaryGroup],[MemberOf]
           ,[OperatingSystem],[OperatingSystemHotfix],[OperatingSystemServicePack],[OperatingSystemVersion]
           ,[CanonicalName],[Enabled],[IPv4Address]
           ,[Created],[Deleted],[Modified],[LastLogonDate],[logonCount],[PasswordExpired]
           ,[PasswordLastSet],[AuthenticationPolicy])
VALUES ('$SID','$Name','$DisplayName','$SamAccountName','$Description','$ObjectClass','$PrimaryGroup','$MemberOf'
        ,'$OperatingSystem','$OperatingSystemHotfix','$OperatingSystemServicePack','$OperatingSystemVersion'
        ,'$CanonicalName','$Enabled','$IPv4Address'
        ,'$Created','$Deleted','$Modified','$LastLogonDate','$logonCount','$PasswordExpired'
        ,'$PasswordLastSet','$AuthenticationPolicy');"


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