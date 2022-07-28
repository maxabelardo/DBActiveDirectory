--------Variáveis CHAVES ----------
--Recebe os scripts que serão executados
DECLARE @CreateJobDC nvarchar(4000)

--Recebe o nome do Domain Controller
DECLARE @HostName varchar(100)

--Recebe o Id do Job criado 
DECLARE @JobId varchar(100)



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


	--Localiza o ID do job recen criado, este valor é usado para adicionar o "Step" que contem o script em PowerShell
	select @JobId = CAST(job_id AS nvarchar(100))
	from msdb.dbo.sysjobs 
	where name = 'DBActiveDirectoryDC'+REPLACE(@HostName,'-','')

--DELETA O JOB
--Carrega a variável com o script que vai deletar o job com os valores chaves alterados.
SET @CreateJobDC = 'USE [msdb]
EXEC msdb.dbo.sp_delete_job @job_id=N''' + @JobId +''', @delete_unused_schedule=1
' ;

 --Executa o script adicionando o "Step"
  exec sp_executesql @CreateJobDC

-- Este comando é usado para testa o script sem a sua execução.
--print @CreateJobDC

	FETCH NEXT FROM db_for INTO @HostName
END

CLOSE db_for
DEALLOCATE db_for
