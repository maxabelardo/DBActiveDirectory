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

DECLARE @TX00 Nvarchar(max)
DECLARE @Mcont INT
DECLARE @McontVirgula INT
DECLARE @MconPonto INT


--Alimenta as variáveis com os valores da data e hora que será executado
--Pega a hora atual e adiciona 10 minutos atravez do comando DATEADD e converte o valor para script, removendo os dois pontos
SELECT @StratTime = REPLACE(CONVERT(VARCHAR(10), GETDATE() , 108),':','')
--SELECT @StratTime = REPLACE(CONVERT(VARCHAR(10), DATEADD(minute,10,GETDATE()) , 108),':','')
--Pega a data atual e remove as barras convertendo para string
SELECT @StratDate = REPLACE(CONVERT(VARCHAR(10),GETDATE(), 111),'/','')

--Iniciar o Loop que relaciona todos os Domain Controller.

--Variável matriz que reberá os valores do select
DECLARE db_for CURSOR FOR

	--Seleciona os Domain Controller e carrega na matriz
	SELECT  [HostName] FROM [AD].[STGADDomainController]

--Abre o Loop
OPEN db_for 

--Inicia o Loop
FETCH NEXT FROM db_for INTO @HostName

--Inicia o Loop, se a Variável "@@FETCH_STATUS" está função muda de 0 para outro valor quando o Loop chega ao fim
--ou seja quando a matriz chegar ao fim o valor da função muda e o Loop chega ao fim
WHILE @@FETCH_STATUS = 0
BEGIN

		SET @Mcont = (SELECT LEN(@HostName))

		SET @MconPonto = CHARINDEX('.', @HostName)

		SET @MconPonto = @MconPonto - 1

		SET @TX00 = LEFT(@HostName, @MconPonto)
		

--CREATE JOB
--Carrega a variável com o script que vai criar do job com os valores chaves alterados.
SET @CreateJobDC = 'USE [msdb]

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
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
SET @CreateJobDC = 'USE [msdb]
EXEC msdb.dbo.sp_add_jobstep @job_id=N'''  + @JobId +''' , @step_name=N''Servidor'', 
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

Set-Location C:

 $SQLQueryDelete = "USE $SQLDatabase
    TRUNCATE TABLE [AD].[STGADUser'+REPLACE(@TX00,'-','') +']"

$SQLQuery1Output = Invoke-Sqlcmd -query $SQLQueryDelete -ServerInstance $SQLInstance

$Iniciais = ''''a*'''',''''b*'''',''''c*'''',''''d*'''',''''e*'''',''''g*'''',''''h*'''',
''''i0*'''',''''i1*'''',''''i2*'''',''''i3*'''',''''i4*'''',
''''i505003*'''',''''i505004*'''',''''i505005*'''',''''i505006*'''',''''i505007*'''',''''i505008*'''',''''i505009*'''',
''''i50501*'''',''''i50502*'''',''''i50503*'''',''''i50504*'''',''''i50505*'''',''''i50506*'''',''''i50507*'''',''''i50508*'''',''''i50509*'''',
''''i5051*'''',''''i5052*'''',''''i5053*'''',''''i5054*'''',''''i5055*'''',''''i5056*'''',''''i5057*'''',''''i5058*'''',''''i5059*'''',
''''i506*'''',''''i507*'''',''''i508*'''',''''i509*'''',
''''i501*'''',''''i502*'''',''''i503*'''',''''i504*'''',
''''i500*'''',
''''i51*'''',''''i52*'''',''''i53*'''',''''i54*'''',''''i55*'''',''''i56*'''',''''i57*'''',''''i58*'''',''''i59*'''',
''''i6*'''',''''i7*'''',''''i8*'''',''''i9*'''',
''''j*'''',''''k*'''',''''l*'''',''''m*'''',''''n*'''',''''o*'''',''''p*'''',''''q*'''',''''r*'''',''''s*'''',''''t*'''',''''u*'''',''''x*'''',''''z*'''',''''w*'''',
''''1*'''',''''2*'''',''''3*'''',''''4*'''',''''5*'''',''''6*'''',''''7*'''',''''8*'''',''''9*'''',''''0*''''

$HostName = "'+ @HostName  +'"

ForEach($Inicial in $Iniciais){
        try{
        $Usrs = Get-ADUser -server $HostName -f {SamAccountName -like $Inicial }  -Properties * | SELECT SamAccountName,
                    @{Name=''''PasswordLastSet'''';Expression={$_.PasswordLastSet.ToString("yyyy\/MM\/dd HH:mm:ss")}},
                    @{Name=''''LastLogonDate'''';Expression={$_.LastLogonDate.ToString("yyyy\/MM\/dd HH:mm:ss")}}
            }catch{
                Write-Output $Inicial
                throw $_
                break
            } 
 ForEach($Usr in $Usrs){
 
 	$SamAccountName = $Usr.SamAccountName
	$PasswordLastSet = $Usr.PasswordLastSet
	$LastLogonDate = $Usr.LastLogonDate

$SQLQuery = "USE $SQLDatabase
INSERT INTO [AD].[STGADUser'+REPLACE(@TX00,'-','') +']
       ( [SamAccountName], [PasswordLastSet], [LastLogonDate])
VALUES (''''$SamAccountName'''',''''$PasswordLastSet'''',''''$LastLogonDate'''');"

try{
    $SQLQuery1Output = Invoke-Sqlcmd -query $SQLQuery -ServerInstance $SQLInstance -ErrorAction stop
}catch{
Write-Output $SQLQuery
throw $_
break
}
}
$Usrs.clear
}

'', 
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
SELECT @StratTime =  REPLACE(CONVERT(VARCHAR(10), DATEADD(minute,@MinutoCont, GETDATE()  ) , 108),':','')


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
