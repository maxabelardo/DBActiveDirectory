USE [msdb]
GO
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ActiveDirectory', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [brz_computer]    Script Date: 15/11/2023 14:28:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'brz_computer', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# Este script foi criado para extrair os "Computadores" e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

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
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i*'',''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',''s*'',''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''

#Loop das iniciais
ForEach($Inicial in $Iniciais){

#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.
    try{
    $Usrs = Get-ADComputer -f {Name -like $Inicial} -Properties * | Select-Object SID, Name, DisplayName, SamAccountName, Description, ObjectClass, PrimaryGroup, MemberOf,
        OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, OperatingSystemVersion,
        CanonicalName, Enabled,IPv4Address, 
        @{Name=''Created'';Expression={$_.Created.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name=''Deleted'';Expression={$_.Deleted.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name=''Modified'';Expression={$_.Modified.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        @{Name=''LastLogonDate'';Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}},
        logonCount,
        PasswordExpired, 
        @{Name=''PasswordLastSet'';Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}}, 
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
        $Name = $Lipemza.replace("''","")	 
    }else{$Name = $Usr.Name}

    if ($Usr.DisplayName){      
        $Lipemza = $Usr.DisplayName
	    $DisplayName = $Lipemza.replace("''","")
    }else{$DisplayName = $Usr.DisplayName}

	$SamAccountName = $Usr.SamAccountName

    if ($Usr.Description){      
        $Lipemza = $Usr.Description
	    $Description = $Lipemza.replace("''","")
    }else{$Description = $Usr.Description}	

    $ObjectClass = $Usr.ObjectClass

    if ($Usr.PrimaryGroup){      
        $Lipemza = $Usr.PrimaryGroup
	    $PrimaryGroup = $Lipemza.replace("''","")
    }else{$PrimaryGroup = $Usr.PrimaryGroup}	

    if ($Usr.MemberOf){      
        $Lipemza = $Usr.MemberOf
	    $MemberOf = $Lipemza.replace("''","")
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
VALUES (''$SID'',''$Name'',''$DisplayName'',''$SamAccountName'',''$Description'',''$ObjectClass'',''$PrimaryGroup'',''$MemberOf''
        ,''$OperatingSystem'',''$OperatingSystemHotfix'',''$OperatingSystemServicePack'',''$OperatingSystemVersion''
        ,''$CanonicalName'',''$Enabled'',''$IPv4Address''
        ,''$Created'',''$Deleted'',''$Modified'',''$LastLogonDate'',''$logonCount'',''$PasswordExpired''
        ,''$PasswordLastSet'',''$AuthenticationPolicy'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [brz_contact]    Script Date: 15/11/2023 14:28:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'brz_contact', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# Este script foi criado para extrair os CONTACT e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[contact]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i*'',''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',''s*'',''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''



#Loop das iniciais
ForEach($Inicial in $Iniciais){


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{

 $Usrs = Get-ADObject -Filter {(objectClass -eq "contact") -and (cn -like $Inicial )} -Properties * | Select-Object Name, DisplayName, mailNickname, mail,  CanonicalName, DistinguishedName,
    @{Name=''Created'';Expression={$_.Created.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Deleted'';Expression={$_.Deleted.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Modified'';Expression={$_.Modified.ToString("yyyy\/MM\/dd HH:mm:ss")}} -ErrorAction stop

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
        $Name = $Lipemza.replace("''","")	 
    }else{$Name = $Usr.Name}

    if ($Usr.DisplayName){      
        $Lipemza = $Usr.DisplayName
	    $DisplayName = $Lipemza.replace("''","")
    }else{$DisplayName = $Usr.DisplayName}

    if ($Usr.mailNickname){      
        $Lipemza = $Usr.mailNickname
	    $mailNickname = $Lipemza.replace("''","")
    }else{$mailNickname = $Usr.mailNickname}


    if ($Usr.mail){      
        $Lipemza = $Usr.mail
	    $mail = $Lipemza.replace("''","")
    }else{$mail = $Usr.mail}

    if ($Usr.CanonicalName){      
        $Lipemza = $Usr.CanonicalName
	    $CanonicalName = $Lipemza.replace("''","")
    }else{$CanonicalName = $Usr.CanonicalName}

    if ($Usr.DistinguishedName){      
        $Lipemza = $Usr.DistinguishedName
	    $DistinguishedName = $Lipemza.replace("''","")
    }else{$DistinguishedName = $Usr.DistinguishedName}

    $Created = $Usr.Created
	$Modified = $Usr.Modified
	$Deleted = $Usr.Deleted


#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[contact]
           ([Name],[DisplayName],[mailNickname],[mail]
           ,[CanonicalName],[DistinguishedName]
		   ,[created],[Deleted],[Modified])
VALUES (''$Name'',''$DisplayName'',''$mailNickname'',''$mail''
       ,''$CanonicalName'',''$DistinguishedName''
	   ,''$created'',''$Deleted'',''$Modified'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [brz_gpo]    Script Date: 15/11/2023 14:28:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'brz_gpo', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#
# Este script foi criado para extrair as GPO e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos

 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[gpo]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{

 $Usrs = Get-GPO -All | Select-Object Id, DisplayName, DomainName, Owner, GpoStatus, Description, UserVersion, ComputerVersion,
    @{Name=''CreationTime'';Expression={$_.CreationTime.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''ModificationTime'';Expression={$_.ModificationTime.ToString("yyyy\/MM\/dd HH:mm:ss")}} -ErrorAction stop

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
        $DisplayName = $Lipemza.replace("''","")	 
    }else{$DisplayName = $Usr.DisplayName}

    $DomainName = $Usr.DomainName

    if ($Usr.Owner){      
        $Lipemza = $Usr.Owner         
        $Owner = $Lipemza.replace("''","")	 
    }else{$Owner = $Usr.Owner}

    $GpoStatus = $Usr.GpoStatus

    if ($Usr.Description){      
        $Lipemza = $Usr.Description         
        $Description = $Lipemza.replace("''","")	 
    }else{$Description = $Usr.Description} 

    $UserVersion = $Usr.UserVersion
    $ComputerVersion = $Usr.ComputerVersion
    $CreationTime = $Usr.CreationTime
    $ModificationTime = $Usr.ModificationTime




#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[gpo]
           ([ID],[DisplayName],[DomainName]
           ,[Owner],[GpoStatus],[Description]
           ,[UserVersion],[ComputerVersion]
           ,[CreationTime],[ModificationTime])

VALUES     (''$ID'',''$DisplayName'',''$DomainName''
           ,''$Owner'',''$GpoStatus'',''$Description''
           ,''$UserVersion'',''$ComputerVersion''
           ,''$CreationTime'',''$ModificationTime'') ;"


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
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [brz_group]    Script Date: 15/11/2023 14:28:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'brz_group', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# Este script foi criado para extrair os GROUP e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[group]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i0*'',''i1*'',''i2*'',''i3*'',''i4*'',''i5*''''i6*'',''i7*'',''i8*'',''i9*'',
''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',
''s_*'',''s0*'',''s1*'',''s2*'',''s3*'',''s4*'',''s5*'',''s6*'',''s7*'',''s8*'',''s9*'',
''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''



#Loop das iniciais
ForEach($Inicial in $Iniciais){


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{
 $Usrs = Get-ADGroup -f {SamAccountName -like $Inicial} -Properties * | Select-Object SID,Name,DisplayName,SamAccountName,Description,CanonicalName,DistinguishedName,
    GroupCategory, Member, MemberOf, GroupScope,ObjectClass,
    ProtectedFromAccidentalDeletion,
    @{Name=''Created'';Expression={$_.Created.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Deleted'';Expression={$_.Deleted.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Modified'';Expression={$_.Modified.ToString("yyyy\/MM\/dd HH:mm:ss")}}  -ErrorAction stop
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
        $Name = $Lipemza.replace("''","")	 
    }else{$Name = $Usr.Name}


    if ($Usr.DisplayName){      
        $Lipemza = $Usr.DisplayName
	    $DisplayName = $Lipemza.replace("''","")
    }else{$DisplayName = $Usr.DisplayName}


    if ($Usr.SamAccountName){      
        $Lipemza = $Usr.SamAccountName
	    $SamAccountName = $Lipemza.replace("''","")
    }else{$DisplayName = $Usr.SamAccountName}


    if ($Usr.Description){      
        $Lipemza = $Usr.Description
	    $Description = $Lipemza.replace("''","")
    }else{$Description = $Usr.Description}	


    if ($Usr.CanonicalName){      
        $Lipemza = $Usr.CanonicalName
	    $CanonicalName = $Lipemza.replace("''","")
    }else{$Description = $Usr.CanonicalName}	


    if ($Usr.DistinguishedName){      
        $Lipemza = $Usr.DistinguishedName
	    $DistinguishedName = $Lipemza.replace("''","")
    }else{$Office = $Usr.DistinguishedName}


	$GroupCategory = $Usr.GroupCategory

    if ($Usr.member){      
        $Lipemza = $Usr.member
	    $member = $Lipemza.replace("''","")
    }else{$member = $Usr.member}

    if ($Usr.MemberOf){      
        $Lipemza = $Usr.MemberOf
	    $MemberOf = $Lipemza.replace("''","")
    }else{$MemberOf = $Usr.MemberOf}


	$GroupScope = $Usr.GroupScope
	$ObjectClass = $Usr.ObjectClass
	$ProtectedFromAccidentalDeletion = $Usr.ProtectedFromAccidentalDeletion
    $Created = $Usr.Created
	$Deleted = $Usr.Deleted
	$Modified = $Usr.Modified


#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[group]
           ([SID],[Name],[DisplayName],[SamAccountName],[Description]
           ,[CanonicalName],[DistinguishedName],[GroupCategory],[Member],[MemberOf]
           ,[GroupScope],[ObjectClass],[ProtectedFromAccidentalDeletion]
           ,[Created],[Deleted],[Modified])
VALUES (''$SID'',''$Name'',''$DisplayName'',''$SamAccountName'',''$Description'',
        ''$CanonicalName'',''$DistinguishedName'',''$GroupCategory'',''$member'',''$MemberOf'',
        ''$GroupScope'',''$ObjectClass'',''$ProtectedFromAccidentalDeletion'',
        ''$Created'',''$Deleted'',''$Modified'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [br_ou]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'br_ou', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#
# Este script foi criado para extrair os OU e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[ou]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i*'',''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',''s*'',''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''



#Loop das iniciais
ForEach($Inicial in $Iniciais){


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{

 $Usrs = Get-ADOrganizationalUnit -f {Name -like $Inicial}  | Select-Object ObjectGUID, Name, ObjectClass, DistinguishedName, ManagedBy -ErrorAction stop

}catch{
Write-Output $Inicial
throw $_
break
}


#Loop que será usuado para transferir os dados da matriz para o banco de dados
 ForEach($Usr in $Usrs){
 
 #Para cada linha que a matriz percorre e inserido o valor na variável de destino.

    $ObjectGUID = $Usr.ObjectGUID

    if ($Usr.Name){      
        $Lipemza = $Usr.Name         
        $Name = $Lipemza.replace("''","")	 
    }else{$Name = $Usr.Name}

    $ObjectClass = $Usr.ObjectClass

    if ($Usr.DistinguishedName){      
        $Lipemza = $Usr.DistinguishedName         
        $DistinguishedName = $Lipemza.replace("''","")	 
    }else{$DistinguishedName = $Usr.DistinguishedName}

    if ($Usr.ManagedBy){      
        $Lipemza = $Usr.ManagedBy         
        $ManagedBy = $Lipemza.replace("''","")	 
    }else{$ManagedBy = $Usr.ManagedBy}


#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[ou]
           ([ObjectGUID],[Name],[ObjectClass]
           ,[DistinguishedName],[ManagedBy])
VALUES     (''$ObjectGUID'',''$Name'',''$ObjectClass''
           ,''$DistinguishedName'',''$ManagedBy'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [brz_user]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'brz_user', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'# Este script foi criado para extrair os USER e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[user]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i0*'',''i1*'',''i2*'',''i3*'',''i4*'',
#''i505000*'',''i505001*'',
''i50501*'',''i50502*'',''i50503*'',''i50504*'',''i50505*'',''i50506*'',''i50507*'',''i50508*'',''i50509*'',
''i5051*'',''i5052*'',''i5053*'',''i5054*'',''i5055*'',''i5056*'',''i5057*'',''i5058*'',''i5059*'',
''i506*'',''i507*'',''i508*'',''i509*'',
''i51*'',''i52*'',''i53*'',''i54*'',''i55*'',''i56*'',''i57*'',''i58*'',''i59*'',
''i501*'',''i502*'',''i503*'',''i504*'',
''i6*'',''i7*'',''i8*'',''i9*'',
''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',''s*'',''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''



#Loop das iniciais
ForEach($Inicial in $Iniciais){


#Iniciar a extração dos Usuários do Active Directory
# A variável "$Usrs" é uma matriz que receberá o resultado do comando de extração dos usuários.

try{
 $Usrs = Get-ADUser -f {SamAccountName -like $Inicial} -Properties * | Select-Object SID,Name,DisplayName,SamAccountName,mail,Title,Department,Description,employeeType,Company,
	Office,City,DistinguishedName,MemberOf,
    @{Name=''createTimeStamp'';Expression={$_.createTimeStamp.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Deleted'';Expression={$_.Deleted.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''Modified'';Expression={$_.Modified.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''PasswordLastSet'';Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''AccountExpirationDate'';Expression={$_.AccountExpirationDate.ToString("yyyy\/MM\/dd HH:mm:ss")}},
	@{Name=''msExchWhenMailboxCreated'';Expression={$_.msExchWhenMailboxCreated.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    @{Name=''LastLogonDate'';Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}},
    EmailAddress,MobilePhone,msExchRemoteRecipientType,
	ObjectClass,PasswordExpired,PasswordNeverExpires,PasswordNotRequired,Enabled,LockedOut,
	CannotChangePassword,
    userAccountControl  -ErrorAction stop
}catch{
Write-Output $Inicial
throw $_
break
}



#Loop que será usuado para transferir os dados da matriz para o banco de dados
 ForEach($Usr in $Usrs){
 
 #Para cada linha que a matriz percorre e inserido o valor na variável de destino.
	$SID = $Usr.SID
         $Lipemza = $Usr.Name         
         $Name = $Lipemza.replace("''","")	 

       if ($Usr.DisplayName){      
         $Lipemza = $Usr.DisplayName
	     $DisplayName = $Lipemza.replace("''","")
        }else{$DisplayName = $Usr.DisplayName}

	$SamAccountName = $Usr.SamAccountName
	$mail = $Usr.mail
	$Title = $Usr.Title
	$Department = $Usr.Department

       if ($Usr.Description){      
         $Lipemza = $Usr.Description
	     $Description = $Lipemza.replace("''","")
        }else{$Description = $Usr.Description}	

	$employeeType = $Usr.employeeType
	$Company = $Usr.Company

       if ($Usr.Office){      
         $Lipemza = $Usr.Office
	     $Office = $Lipemza.replace("''","")
        }else{$Office = $Usr.Office}

		$City = $Usr.City

       if ($Usr.DistinguishedName){      
         $Lipemza = $Usr.DistinguishedName
	     $DistinguishedName = $Lipemza.replace("''","")
        }else{$DistinguishedName = $Usr.DistinguishedName}

       if ($Usr.MemberOf){      
         $Lipemza = $Usr.MemberOf
	     $MemberOf = $Lipemza.replace("''","")
        }else{$MemberOf = $Usr.MemberOf}


    $createTimeStamp = $Usr.createTimeStamp
	$Deleted = $Usr.Deleted
	$Modified = $Usr.Modified
	$PasswordLastSet = $Usr.PasswordLastSet
	$AccountExpirationDate = $Usr.AccountExpirationDate
	$msExchWhenMailboxCreated = $Usr.msExchWhenMailboxCreated
	$LastLogonDate = $Usr.LastLogonDate
	$EmailAddress = $Usr.EmailAddress
	$MobilePhone = $Usr.MobilePhone
	$msExchRemoteRecipientType = $Usr.msExchRemoteRecipientType
	$ObjectClass = $Usr.ObjectClass
	$PasswordExpired = $Usr.PasswordExpired
	$PasswordNeverExpires = $Usr.PasswordNeverExpires
	$PasswordNotRequired = $Usr.PasswordNotRequired
	$Enabled = $Usr.Enabled
	$LockedOut = $Usr.LockedOut
	$CannotChangePassword = $Usr.CannotChangePassword
    $userAccountControl = $Usr.userAccountControl

#A variável "$SQLQuery" receberar o insert com os dados para ser executado no banco
$SQLQuery = "USE $SQLDatabase
INSERT INTO [brz].[user]
 ([SID],[Name],[DisplayName],[SamAccountName],[mail],[Title],[Department],[Description],[employeeType],[Company]
  ,[Office],[City],[DistinguishedName],[MemberOf],[createTimeStamp],[Deleted],[Modified],[PasswordLastSet],[AccountExpirationDate]
  ,[msExchWhenMailboxCreated],[LastLogonDate],[EmailAddress],[MobilePhone],[msExchRemoteRecipientType]
  ,[ObjectClass],[PasswordExpired],[PasswordNeverExpires],[PasswordNotRequired],[Enabled],[LockedOut]
  ,[CannotChangePassword],[userAccountControl])
VALUES (''$SID'',''$Name'',''$DisplayName'',''$SamAccountName'',''$mail'',''$Title'',''$Department'',''$Description'',''$employeeType'',''$Company'',
	''$Office'',''$City'',''$DistinguishedName'',''$MemberOf'',''$createTimeStamp'',''$Deleted'',''$Modified'',''$PasswordLastSet'',''$AccountExpirationDate'',
	''$msExchWhenMailboxCreated'',''$LastLogonDate'',''$EmailAddress'',''$MobilePhone'',''$msExchRemoteRecipientType'',
	''$ObjectClass'',''$PasswordExpired'',''$PasswordNeverExpires'',''$PasswordNotRequired'',''$Enabled'',''$LockedOut'',
    ''$CannotChangePassword'',''$userAccountControl'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [br_domain_controller]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'br_domain_controller', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'#
# Este script foi criado para extrair os DOMAIN CONTROLLER e suas informações do Active Directory e inserir elas 
# em um servido de banco dados para futuro tratamento.
# O script foi criado para ser executado de dentro de um JOB do agent do SQL Server.

#Variáveis do servido e banco de dados
$SQLInstance = "S-SEBP19" # Nome da estância de banco de dados
$SQLDatabase = "ActiveDirectory"   # Nome da base de dados

#Parametro necessário para execução do script dentro do job
Set-Location C:


# Limpeza da tabela de STAGE que reseberá os dados brutos
 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [brz].[domain_controller]"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance


#======= ATENÇÃO ========#
# Devido o volume de usuários ser muito grande foi criado um loop para diminuir o volume por insert

# Variável que vai receber os valores para pesquisa
$Iniciais = ''a*'',''b*'',''c*'',''d*'',''e*'',''g*'',''h*'',
''i*'',''j*'',''k*'',''l*'',''m*'',''n*'',''o*'',''p*'',''q*'',''r*'',''s*'',''t*'',''u*'',''x*'',''z*'',''w*'',
''1*'',''2*'',''3*'',''4*'',''5*'',''6*'',''7*'',''8*'',''9*'',''0*''



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
        $Name = $Lipemza.replace("''","")	 
    }else{$Name = $Usr.Name}

    if ($Usr.HostName){      
        $Lipemza = $Usr.HostName
	    $HostName = $Lipemza.replace("''","")
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
VALUES (''$Name'',''$HostName'',''$IPv4Address''
       ,''$OperatingSystem'',''$OperatingSystemVersion'',''$Site''
       ,''$Enabled'',''$LastUpdateEtl'');"


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
}#fim do loop das legras', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_computer]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_computer', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int
EXECUTE @RC = [siv].[sp_computer] 
', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_contact]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_contact', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_contact]
', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_domain_controller]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_domain_controller', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_domain_controller] ', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_gpo]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_gpo', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @RC int

EXECUTE @RC = [siv].[sp_gpo] ', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_group]    Script Date: 15/11/2023 14:28:49 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_group', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_group] ', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_ou]    Script Date: 15/11/2023 14:28:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_ou', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_ou] 
', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_user]    Script Date: 15/11/2023 14:28:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_user', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_user]', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_ou_member]    Script Date: 15/11/2023 14:28:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_ou_member', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_ou_member]

', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sp_group_member]    Script Date: 15/11/2023 14:28:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_group_member', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @RC int

EXECUTE @RC = [siv].[sp_group_member] ', 
		@database_name=N'ActiveDirectory', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


