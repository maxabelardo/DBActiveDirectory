/**********************************************************************************************************************************
OBJETIVO DO SCRIPT:
     Este script é usado para criar os jobs utilizados para sincronizar os campos "PasswordLastSet" e "LastLogonDate" que não são 
sincronicado pelo AD

DESCRIÇÃO DO FUNCIONAMENTO DO SCRIPT:
    O script cria um job para cada contrololador de dominio e atribui o horário de execução para cada um deles 10 minutos 
depois da sua criação.

MOTIVO PARA SER USAR ESTA ESTRATEGIA:
	O script em PowerShell estava demorando mais de 24 horas para ir em todos os Domain Controller, devido esta demora
foi montado esta estrategia de se criar um job para cada servidor e executar todos ao mesmo tempo.
Como o processamento é no servidor de destino o servidor de banco não vai ficar sobrecarrado com estas tarefas recorrentes.

**********************************************************************************************************************************/
--------Variáveis CHAVES ----------
--Recebe os scripts que serão executados
DECLARE @CreateJobDC nvarchar(4000)

--Recebe o nome do Domain Controller
DECLARE @HostName varchar(100)

--Recebe o Id do Job criado 
DECLARE @JobId varchar(100)

--Recebe a data e horas que o job será executado
DECLARE @StratDate Varchar(10)
DECLARE @StratTime Varchar(10)
--É utilizada como contador para colocar a execução do Job com a diferença de 2 minutos entre eles.
DECLARE @MinutoCont INT
SET @MinutoCont = 2

--Alimenta as variáveis com os valores da data e hora que será executado
--Pega a hora atual e adiciona 10 minutos atravez do comando DATEADD e converte o valor para script, removendo os dois pontos
SELECT @StratTime = REPLACE(CONVERT(VARCHAR(10), DATEADD(HOUR,4,GETDATE()) , 108),':','')
--SELECT @StratTime = REPLACE(CONVERT(VARCHAR(10), DATEADD(minute,10,GETDATE()) , 108),':','')
--Pega a data atual e remove as barras convertendo para string
SELECT @StratDate = REPLACE(CONVERT(VARCHAR(10),GETDATE(), 111),'/','')

--Iniciar o Loop que relaciona todos os Domain Controller.

--Variável matriz que reberá os valores do select
DECLARE db_for CURSOR FOR

	--Seleciona os Domain Controller e carrega na matriz
	SELECT [HostName] FROM [AD].[STGADDomainController]

--Abre o Loop
OPEN db_for 

--Inicia o Loop
FETCH NEXT FROM db_for INTO @HostName

--Inicia o Loop, se a Variável "@@FETCH_STATUS" está função muda de 0 para outro valor quando o Loop chega ao fim
--ou seja quando a matriz chegar ao fim o valor da função muda e o Loop chega ao fim
WHILE @@FETCH_STATUS = 0
BEGIN

--CREATE JOB
--Carrega a variável com o script que vai criar do job com os valores chaves alterados.
SET @CreateJobDC = 'USE [msdb]

/****** Object:  Job [DBActiveDirectoryDCssecn03.infraero.gov.br]    Script Date: 17/11/2021 14:26:33 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 17/11/2021 14:26:34 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''DBActiveDirectoryDC'+REPLACE(@HostName,'-','') +''', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N''No description available.'', 
		@category_name=N''[Uncategorized (Local)]'', 
		@owner_login_name=N''D_SEDE\admin-abelardo'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

';
  -- Executa o script criando o Job
  exec sp_executesql @CreateJobDC

-- Este comando é usado para testa o script sem a sua execução.
--	print @CreateJobDC

----------------------------------------------------------------------------------------------------------------------------------------

--Localiza o ID do job recen criado, este valor é usado para adicionar o "Step" que contem o script em PowerShell
select @JobId = CAST(job_id AS nvarchar(100))
from msdb.dbo.sysjobs 
where name = 'DBActiveDirectoryDC'+REPLACE(@HostName,'-','')

--CREATE STEP
--Carrega o script que vai criar o "Step" com as variáveis chaves alteradas.
SET @CreateJobDC = ' 
USE [msdb]
EXEC msdb.dbo.sp_add_jobstep @job_id=N''' + @JobId +''', @step_name=N''Servidor'', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N''PowerShell'', 
		@command=N''
$SQLInstance = "S-SEBN2611"
$SQLDatabase = "DBActiveDirectory"
$SQLQuery = "USE $SQLDatabase
SELECT [HostName] FROM [AD].[STGADDomainController] ;"
$QueryDC = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance 
$SQLQuery = "USE $SQLDatabase
SELECT [SamAccountName],[PasswordLastSet],[LastLogonDate],[LastUpdateEtl]
FROM [AD].[STGADUser] ORDER BY [SamAccountName]  ;"
$QueryUsr = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance 

$DomainController = "'+ @HostName  +'"

ForEach($QUsr in $QueryUsr){  
$Usr = $QUsr.SamAccountName
try{
$ADUsr = Get-ADUser -server $DomainController -f {SamAccountName -like $Usr } -Properties * | Select SamAccountName,
@{Name="PasswordLastSet";Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}},
@{Name="LastLogonDate";Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}} -ErrorAction stop
}catch{
Write-Output $DomainController '''' - '''' $Usr
throw $_
break
}            
$SamAccountName  = $ADUsr.SamAccountName
$OldPasswordLastSet = $QUsr.PasswordLastSet.ToString("yyyy/MM/dd HH:mm:ss") 
$OldLastLogonDate   = $QUsr.LastLogonDate.ToString("yyyy/MM/dd HH:mm:ss") 
$PasswordLastSet = $ADUsr.PasswordLastSet
$LastLogonDate   = $ADUsr.LastLogonDate
IF ($QUsr.PasswordLastSet.ToString("yyyy/MM/dd HH:mm:ss") -lt $PasswordLastSet){
$SQLQuery = "USE $SQLDatabase
UPDATE [AD].[STGADUser]
SET [PasswordLastSet] = ''''$PasswordLastSet'''',
[LastUpdateEtl] = GETDATE()
WHERE SamAccountName  = ''''$SamAccountName''''
AND PasswordLastSet < ''''$PasswordLastSet'''' ;"
try{
$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
$SQLQuery = "USE $SQLDatabase
INSERT INTO [AD].[STGADUserDC]
([SamAccountName]
,[OldPasswordLastSet]
,[NewPasswordLastSet]
,[LastUpdateEtl]
,[HostName])
SELECT [SamAccountName]
,''''$OldPasswordLastSet''''
,[PasswordLastSet]
,[LastUpdateEtl]
,''''$DomainController''''
FROM [AD].[STGADUser]
WHERE [SamAccountName]  = ''''$SamAccountName''''
AND [PasswordLastSet] = ''''$PasswordLastSet'''' ;"
try{
$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
}

IF ($QUsr.LastLogonDate.ToString("yyyy/MM/dd HH:mm:ss") -lt $ADUsr.LastLogonDate){
$SQLQuery = "USE $SQLDatabase
UPDATE [AD].[STGADUser]
SET [LastLogonDate] = ''''$LastLogonDate'''',
[LastUpdateEtl] = GETDATE()
WHERE SamAccountName  = ''''$SamAccountName''''
AND LastLogonDate < ''''$LastLogonDate'''' ;"
try{
$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
$SQLQuery = "USE $SQLDatabase
INSERT INTO [AD].[STGADUserDC]
([SamAccountName]
,[OldLastLogonDate]
,[NewLastLogonDate]
,[LastUpdateEtl]
,[HostName])
SELECT [SamAccountName]
,''''$OldLastLogonDate''''
,[LastLogonDate]
,[LastUpdateEtl]
,''''$DomainController''''
FROM [AD].[STGADUser]
WHERE [SamAccountName]  = ''''$SamAccountName''''
AND [LastLogonDate] = ''''$LastLogonDate'''' ;"
try{
$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
}
$ADUsr.clear
}'', 
		@database_name=N''master'', 
		@flags=0
'

 --Executa o script adicionando o "Step"
  exec sp_executesql @CreateJobDC

-- Este comando é usado para testa o script sem a sua execução.
-- print @CreateJobDC
	
----------------------------------------------------------------------------------------------------------------------

--CREATE SCHEDULE
--Alimenta as variáveis com os valores da data e hora que será executado
--Pega a hora atual e adiciona 10 minutos atravez do comando DATEADD e converte o valor para script, removendo os dois pontos
SELECT @StratTime =  REPLACE(CONVERT(VARCHAR(10), DATEADD(minute,@MinutoCont, DATEADD(HOUR,4,GETDATE())  ) , 108),':','')


--Carrega o script que vai criar o "Schedule" com as variáveis chaves alteradas.
SET @CreateJobDC = '
USE [msdb]

DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_id=N''' + @JobId +''', @name=N''Agora'', 
		@enabled=1, 
		@freq_type=1, 
		@freq_interval=1, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date='+ @StratDate +', 
		@active_end_date=99991231, 
		@active_start_time='+ @StratTime +', 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
';
 --Executa o script adicionando o "Schedule"
  exec sp_executesql @CreateJobDC

-- Este comando é usado para testa o script sem a sua execução.
-- print @CreateJobDC


SET @MinutoCont = @MinutoCont + 2

	FETCH NEXT FROM db_for INTO @HostName
END

CLOSE db_for
DEALLOCATE db_for
