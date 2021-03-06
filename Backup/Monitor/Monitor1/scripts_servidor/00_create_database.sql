USE [MonitorGW]
GO
/****** Object:  User [sisetl]    Script Date: 09/03/2020 10:10:37 ******/
CREATE USER [sisetl] FOR LOGIN [sisetl] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [sisrelatorio]    Script Date: 09/03/2020 10:10:37 ******/
CREATE USER [sisrelatorio] FOR LOGIN [sisrelatorio] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [usrsm]    Script Date: 09/03/2020 10:10:37 ******/
CREATE USER [usrsm] FOR LOGIN [usrsm] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [sisetl]
GO
ALTER ROLE [db_datareader] ADD MEMBER [sisrelatorio]
GO
ALTER ROLE [db_datareader] ADD MEMBER [usrsm]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [usrsm]
GO
/****** Object:  Schema [Report]    Script Date: 09/03/2020 10:10:37 ******/
CREATE SCHEMA [Report]
GO
/****** Object:  Schema [ServerHost]    Script Date: 09/03/2020 10:10:37 ******/
CREATE SCHEMA [ServerHost]
GO
/****** Object:  Schema [SGBD]    Script Date: 09/03/2020 10:10:37 ******/
CREATE SCHEMA [SGBD]
GO
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNow24]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_HoraDiaNow24](@DATA DATETIME) RETURNS DATETIME  AS
begin

declare @Dia datetime
declare @Dia24Hora datetime

declare @return char(10)


--set @Dia = DateAdd(day, -1 ,@DATA)

set @Dia24Hora = CONVERT(CHAR(10 ), @DATA, 120) + ' 23:59:59'

RETURN @Dia24Hora    

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNowZero]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_HoraDiaNowZero](@DATA DATETIME) RETURNS DATETIME  AS
begin

declare @DiaCorrido int

declare @Dia datetime
declare @DiaZeroHora datetime

declare @return char(10)


--set @Dia = DateAdd(day, -1 ,@DATA)

set @DiaZeroHora = CONVERT(CHAR(10 ), @DATA, 120) + ' 00:00:00'

RETURN @DiaZeroHora    

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesCh]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_PrimeiroDiaMesCh](@DATA DATETIME) RETURNS char(10)  AS
begin

--declare @DATA DATETIME
declare @DiaCorrido int
declare @FimDoMes datetime
declare @InicioDoMes datetime
declare @return char(10)

--set @DATA = GETDATE()
--Descobrindo quantos dias já foi percorrido
set @DiaCorrido = DATEPART(day,@DATA)

-- Pegando o primeiro dia do mês corrente
set @InicioDoMes = DateAdd(day,(- @DiaCorrido) + 1 ,@DATA)

-- Pegando o ultimo dia do mês corrente
set @FimDoMes =  DATEADD(DAY,-1,DATEADD(MONTH,1,@InicioDoMes))

--Apresentando o resultado
--select @DiaCorrido
--select @InicioDoMes, @FimDoMes, @DiaCorrido  -- 01/06/2011

SELECT @return = CONVERT(CHAR(10),@InicioDoMes,103)
RETURN @return    -- 30/06/2011

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesDT]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_PrimeiroDiaMesDT](@DATA DATETIME) RETURNS datetime  AS
begin

--declare @DATA DATETIME
declare @DiaCorrido int
declare @FimDoMes datetime
declare @InicioDoMes datetime
declare @return datetime

--set @DATA = GETDATE()
--Descobrindo quantos dias já foi percorrido
set @DiaCorrido = DATEPART(day,@DATA)

-- Pegando o primeiro dia do mês corrente
set @InicioDoMes = DateAdd(day,(- @DiaCorrido) + 1 ,@DATA)

-- Pegando o ultimo dia do mês corrente
set @FimDoMes =  DATEADD(DAY,-1,DATEADD(MONTH,1,@InicioDoMes))

--Apresentando o resultado
--select @DiaCorrido
--select @InicioDoMes, @FimDoMes, @DiaCorrido  -- 01/06/2011

set @return = CONVERT(DATE, @InicioDoMes)
RETURN @return    -- 30/06/2011

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_RetornoDiaMesAtual]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[F_RetornoDiaMesAtual]()
RETURNS @TableData TABLE ([DataExecucao] nchar(10),[DataExecucaoDT] DATETIME )
AS
BEGIN
	DECLARE @Cont int
	DECLARE @Data nchar(10)
	DECLARE @DIA  nchar(2)
	DECLARE @DiaMax int

		SELECT @DiaMax =  DAY(dbo.F_UltimmoDiaMesDT(GETDATE()))
		SET @cont = 1

			WHILE @cont <= @DiaMax
			BEGIN

				IF @cont <= 9 
					BEGIN		
						SET @Dia = '0' + LTRIM(STR(@cont)) 
					END
					ELSE
					BEGIN
						SET @Dia = LTRIM(STR(@cont))
					END	
			
						SET @Data = @Dia + RIGHT(CONVERT(nchar(10), GETDATE(), 103),8)

				SET @cont = @cont + 1

				INSERT INTO @TableData([DataExecucao],[DataExecucaoDT]) VALUES (@Data, convert(datetime,(RIGHT(@Data,4)+'/'+RIGHT(LEFT(@Data,5),2)+'/'+LEFT(@Data,2)) , 111))	 
			END

	RETURN

END





GO
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesCh]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_UltimmoDiaMesCh](@DATA DATETIME) RETURNS char(10)  AS
begin

--declare @DATA DATETIME
declare @DiaCorrido int
declare @FimDoMes datetime
declare @InicioDoMes datetime
declare @return char(10)

--set @DATA = GETDATE()
--Descobrindo quantos dias já foi percorrido
set @DiaCorrido = DATEPART(day,@DATA)

-- Pegando o primeiro dia do mês corrente
set @InicioDoMes = DateAdd(day,(- @DiaCorrido) + 1 ,@DATA)

-- Pegando o ultimo dia do mês corrente
set @FimDoMes =  DATEADD(DAY,-1,DATEADD(MONTH,1,@InicioDoMes))

--Apresentando o resultado
--select @DiaCorrido
--select @InicioDoMes, @FimDoMes, @DiaCorrido  -- 01/06/2011

SELECT @return = CONVERT(CHAR(10),@FimDoMes,103)
RETURN @return    -- 30/06/2011

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesDT]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_UltimmoDiaMesDT](@DATA DATETIME) RETURNS DATETIME  AS
begin

--declare @DATA DATETIME
declare @DiaCorrido int
declare @FimDoMes datetime
declare @InicioDoMes datetime
declare @return datetime

--set @DATA = GETDATE()
--Descobrindo quantos dias já foi percorrido
set @DiaCorrido = DATEPART(day,@DATA)

-- Pegando o primeiro dia do mês corrente
set @InicioDoMes = DateAdd(day,(- @DiaCorrido) + 1 ,@DATA)

-- Pegando o ultimo dia do mês corrente
set @FimDoMes =  DATEADD(DAY,-1,DATEADD(MONTH,1,@InicioDoMes))

set @return = CONVERT(CHAR(10 ), @FimDoMes, 120) + ' 23:59:59'
--Apresentando o resultado
--select @DiaCorrido
--select @InicioDoMes, @FimDoMes, @DiaCorrido  -- 01/06/2011

--SET @return = @FimDoMes
RETURN @return    -- 30/06/2011

end



GO
/****** Object:  UserDefinedFunction [dbo].[FDIA_SEMANA]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FDIA_SEMANA]  (@DATA DATETIME) RETURNS INT  AS
BEGIN
  DECLARE @DIA INT
  SELECT @DIA = (DATEPART(DW,@DATA ))
  RETURN @DIA
END


GO
/****** Object:  UserDefinedFunction [dbo].[FMES_EXT]    Script Date: 09/03/2020 10:10:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- SET ESTE COMANDO ANTES DE EXECUTA ESTA FUNÇÃO. SET LANGUAGE BRAZILIAN

CREATE function [dbo].[FMES_EXT](@DATA DATETIME) RETURNS Char(10)  AS
begin

DECLARE @return CHAR(10)

--	SET LANGUAGE BRAZILIAN
	
	SELECT  @return   = DateName(Month,@DATA)	

RETURN @return   

end



GO
/****** Object:  Table [SGBD].[SGBDDatabases]    Script Date: 09/03/2020 10:10:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDDatabases](
	[idDatabases] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[BasedeDados] [varchar](150) NULL,
	[Descricao] [varchar](255) NULL,
	[owner] [varchar](30) NULL,
	[dbid] [varchar](30) NULL,
	[created] [datetime] NULL,
	[OnlineOffline] [varchar](10) NULL,
	[RestrictAccess] [varchar](15) NULL,
	[recovery_model] [varchar](15) NULL,
	[collation] [varchar](30) NULL,
	[compatibility_level] [varchar](30) NULL,
	[ativo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[idDatabases] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtDbSize]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbSize](
	[idMtDbSize] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[db_size] [real] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtDbSize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [ServerHost].[ServerHost]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ServerHost].[ServerHost](
	[idServerHost] [int] IDENTITY(1,1) NOT NULL,
	[HostName] [varchar](60) NULL,
	[FisicoVM] [varchar](20) NULL,
	[SistemaOperaciona] [varchar](20) NULL,
	[IPaddress] [varchar](50) NULL,
	[PortConect] [varchar](10) NULL,
	[Descricao] [varchar](255) NULL,
	[Versao] [varchar](350) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK__ServerHo__F1EA723907020F21] PRIMARY KEY CLUSTERED 
(
	[idServerHost] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[SGBD]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBD](
	[idSGBD] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[Estancia] [varchar](255) NULL,
	[SGBD] [varchar](30) NULL,
	[IP] [varchar](255) NULL,
	[Local] [varchar](255) NULL,
	[conectstring] [varchar](255) NULL,
	[Porta] [real] NULL,
	[Cluster] [bit] NULL,
	[Versao] [varchar](255) NULL,
	[Descricao] [varchar](255) NULL,
	[FuncaoServer] [char](100) NULL,
	[SobreAdministracao] [char](100) NULL,
	[Ativo] [bit] NULL,
	[MemoryConfig] [int] NULL,
	[EstanciaAtivo] [bit] NULL,
 CONSTRAINT [PK__SGBD__BD5208B0182C9B23] PRIMARY KEY CLUSTERED 
(
	[idSGBD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [SGBD].[SGBDServidorProd]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [SGBD].[SGBDServidorProd]
as
SELECT S.idSGBD
      ,SH.idServerHost
	  ,UPPER(CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'MSSQLServer 2016'AND [SGBD] <> 'MSSQLServer 2012' AND [SGBD] <> 'MSSQLServer 2008 R2' AND [SGBD] <> 'MSSQLServer 2005'THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'MSSQLServer 2016' OR [SGBD] = 'MSSQLServer 2012' OR [SGBD] = 'MSSQLServer 2008 R2' OR [SGBD] = 'MSSQLServer 2005') THEN ([HostName])				
		END )AS 'Servidor'
      ,UPPER(SH.HostName) as 'HostName'
      ,[Estancia]
      ,[SGBD]
      ,SH.[IPaddress] AS IP
      ,[Local]
      ,[conectstring]
      ,[Porta]
      ,SH.[PortConect]
      ,S.[Cluster]
      ,S.[Versao]
      ,S.[Descricao]
      ,[FuncaoServer]
	  ,[MemoryConfig]
      ,[SobreAdministracao]
  FROM [SGBD].[SGBD] AS S
  INNER JOIN [ServerHost].[ServerHost] AS SH ON SH.idServerHost = S.idServerHost
   WHERE SH.ATIVO = 1 AND S.Ativo = 1




GO
/****** Object:  View [SGBD].[SGBDDatabasesProd]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [SGBD].[SGBDDatabasesProd]
AS
SELECT DB.[idDatabases]
      , DB.idSGBD
	  ,CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'MSSQLServer 2016'AND [SGBD] <> 'MSSQLServer 2012' AND [SGBD] <> 'MSSQLServer 2008 R2' AND [SGBD] <> 'MSSQLServer 2005'THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'MSSQLServer 2016' OR [SGBD] = 'MSSQLServer 2012' OR [SGBD] = 'MSSQLServer 2008 R2' OR [SGBD] = 'MSSQLServer 2005') THEN ([HostName])				
		END AS 'Servidor'
      ,[BasedeDados]
      ,ROUND(SZ.db_size, 2) AS 'SizeMB'
	  ,CONVERT(nCHAR(10),SZ.DataTimer,103) AS 'DataTimer'
      ,SG.[Descricao]
      ,SG.SGBD
      ,[owner]
      ,[dbid]
      ,[created]
      ,[OnlineOffline]
      ,[RestrictAccess]
      ,[recovery_model]
      ,[collation]
      ,[compatibility_level]
      ,[ativo]
  FROM [SGBD].[SGBDDatabases] AS DB
  INNER JOIN [SGBD].[SGBDServidorProd] AS SG ON SG.[idSGBD] = DB.idSGBD
  LEFT JOIN (SELECT [idDatabases],MAX([DataTimer]) AS 'DataTimer' 
               FROM [SGBD].[MtDbSize]
				GROUP BY [idDatabases]) AS ST ON ST.idDatabases = DB.idDatabases
  LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
  WHERE DB.ativo = 1
--  ORDER BY [BasedeDados]
--    AND DB.OnlineOffline = 'ONLINE'




GO
/****** Object:  Table [SGBD].[MtSQLDbBackup]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLDbBackup](
	[idMtSQLDbBackup] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[user_name] [varchar](128) NULL,
	[physical_device_name] [varchar](255) NULL,
	[backup_size] [real] NULL,
	[BackupType] [varchar](60) NULL,
	[collation_name] [varchar](128) NULL,
	[server_name] [varchar](128) NULL,
	[backup_start_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLDbBackup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Report].[BackupsMsMonitorMes]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Report].[BackupsMsMonitorMes]
as

SELECT DB.[Servidor]
     , DB.[BasedeDados]
	 , Tamanho
	 , Dia
  FROM [SGBD].[SGBDDatabasesProd] AS DB
  LEFT JOIN (SELECT B.[Servidor]
				  , B.[BasedeDados]
				  , ROUND([backup_size],2) AS 'Tamanho'
				  , DAY((A.[backup_start_date])) AS 'Dia'
				FROM [SGBD].[MtSQLDbBackup] AS A 
				INNER JOIN [SGBD].[SGBDDatabasesProd] AS B ON B.[idDatabases] = A.[idDatabases]
				WHERE A.[backup_start_date] >= [dbo].[F_PrimeiroDiaMesDT] (GETDATE())
				AND A.[backup_start_date] <= [dbo].[F_UltimmoDiaMesDT] (GETDATE())
				AND B.[dbid] NOT IN(1,2,3,4) ) AS BK ON BK.[Servidor] = DB.[Servidor] AND BK.[BasedeDados] = DB.[BasedeDados]
  WHERE DB.[dbid] NOT IN(1,2,3,4) 

/*	SELECT B.[Servidor]
	     , LEFT(B.[BasedeDados],15) AS BasedeDados
         , ROUND([backup_size],2) AS 'Tamanho'
         , DAY((A.[backup_start_date])) AS 'Dia'
    FROM [SGBD].[MtSQLDbBackup] AS A 
    INNER JOIN [SGBD].[SGBDDatabasesProd] AS B ON B.[idSGBD] = A.[idSGBD] AND B.[idDatabases] = A.[idDatabases]
    WHERE A.[backup_start_date] >= [dbo].[F_PrimeiroDiaMesDT] (GETDATE())
    AND A.[backup_start_date] <= [dbo].[F_UltimmoDiaMesDT] (GETDATE())
	AND [dbid] NOT IN(1,2,3,4) AND B.[BasedeDados] NOT LIKE 'ReportServer%' 
	ORDER BY B.[Servidor], LEFT(B.[BasedeDados],15), DAY((A.[backup_start_date]))*/



GO
/****** Object:  Table [SGBD].[MtSQLCPU]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLCPU](
	[idMtSQLCPU] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[cpucount] [int] NULL,
	[SQLServerProcessCPUUtilization] [int] NULL,
	[SystemIdleProcess] [int] NULL,
	[OtherProcessCPUUtilization] [int] NULL,
	[EventTime] [datetime] NULL,
 CONSTRAINT [PK__MtSQLCPU__D3B39380166D9A6D] PRIMARY KEY CLUSTERED 
(
	[idMtSQLCPU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[CPU30MINUTOS]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CPU30MINUTOS]
AS
select ETC03.idSGBD
	 , CONVERT([varchar], ETC03.EventTime, 103) AS 'EVENTDATE'
	 , CONVERT([varchar], ETC03.EventTime, 108) AS 'EVENTTIME'
	 , ETC03.CPUSQL   AS 'CPUSQL'
	 , ETC03.CPUOS    AS 'CPUOS'
	 , (100 - (ETC03.CPUSQL + ETC03.CPUOS)) AS 'CPUFREE'
from (select ET02.idSGBD
			 , DATEADD(minute, ET02.EventTime * 30, '2010-01-01T00:00:00') AS EventTime
			 , ROUND(ET02.CPUSQL, 2)   AS 'CPUSQL'
			 , ROUND(ET02.CPUOS, 2)    AS 'CPUOS'
		from (select ET01.idSGBD
		   		   , ET01.EventTime
				   , SUM(ET01.CPUSQL)   AS 'CPUSQL'
				   , SUM(ET01.CPUOS)    AS 'CPUOS'
				from (select CPU.idSGBD
				           , datediff(minute, '2010-01-01T00:00:00', CPU.[EventTime]) / 30 AS 'EventTime' -- Trinta minutos
						   , ROUND(AVG(CAST(CPU.[SQLServerProcessCPUUtilization] AS FLOAT)),2) AS 'CPUSQL'
						   , ROUND(AVG(CAST(CPU.[OtherProcessCPUUtilization] AS FLOAT)),2)     AS 'CPUOS'
						FROM [SGBD].[MtSQLCPU] as CPU
						GROUP BY  CPU.idSGBD, datediff(minute, '2010-01-01T00:00:00', CPU.[EventTime]) / 30 -- Trinta minutos
				) as ET01
				group by  ET01.idSGBD, ET01.EventTime ) as ET02) as ETC03
--ORDER BY CONVERT([varchar], ETC03.EventTime, 103) DESC, CONVERT([varchar], ETC03.EventTime, 108) DESC

GO
/****** Object:  Table [SGBD].[BackupsMsMonitorMes]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[BackupsMsMonitorMes](
	[idDatabases] [int] NOT NULL,
	[Servidor] [varchar](8000) NULL,
	[BasedeDados] [varchar](150) NULL,
	[DataExecucao] [nchar](10) NULL,
	[Tamanho] [real] NULL,
	[BACKUP] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[BackupsMsQuadroDetalhado]    Script Date: 09/03/2020 10:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[BackupsMsQuadroDetalhado](
	[Servidor] [varchar](8000) NULL,
	[BasedeDados] [varchar](150) NULL,
	[01] [int] NOT NULL,
	[02] [int] NOT NULL,
	[03] [int] NOT NULL,
	[04] [int] NOT NULL,
	[05] [int] NOT NULL,
	[06] [int] NOT NULL,
	[07] [int] NOT NULL,
	[08] [int] NOT NULL,
	[09] [int] NOT NULL,
	[10] [int] NOT NULL,
	[11] [int] NOT NULL,
	[12] [int] NOT NULL,
	[13] [int] NOT NULL,
	[14] [int] NOT NULL,
	[15] [int] NOT NULL,
	[16] [int] NOT NULL,
	[17] [int] NOT NULL,
	[18] [int] NOT NULL,
	[19] [int] NOT NULL,
	[20] [int] NOT NULL,
	[21] [int] NOT NULL,
	[22] [int] NOT NULL,
	[23] [int] NOT NULL,
	[24] [int] NOT NULL,
	[25] [int] NOT NULL,
	[26] [int] NOT NULL,
	[27] [int] NOT NULL,
	[28] [int] NOT NULL,
	[29] [int] NOT NULL,
	[30] [int] NOT NULL,
	[31] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[IvSQLPermissionDb]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvSQLPermissionDb](
	[idIvSQLPermissionDb] [int] IDENTITY(1,1) NOT NULL,
	[idIvSQLPermissionLogin] [int] NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[DbRole] [varchar](100) NULL,
	[MemberName] [varchar](100) NULL,
	[StatusPermission] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[idIvSQLPermissionDb] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[IvSQLPermissionLogin]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvSQLPermissionLogin](
	[idIvSQLPermissionLogin] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[nameUser] [varchar](128) NULL,
	[loginname] [varchar](128) NULL,
	[isntname] [int] NULL,
	[sysadmin] [int] NULL,
	[securityadmin] [int] NULL,
	[serveradmin] [int] NULL,
	[setupadmin] [int] NULL,
	[processadmin] [int] NULL,
	[diskadmin] [int] NULL,
	[dbcreator] [int] NULL,
	[bulkadmin] [int] NULL,
	[Ativo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[idIvSQLPermissionLogin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtDbBuffeDB]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbBuffeDB](
	[idMtSQLMemoriaBuffeDB] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[CachedSizeMB] [real] NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtSQLMem__044DCC69756D6ECB] PRIMARY KEY CLUSTERED 
(
	[idMtSQLMemoriaBuffeDB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtDbFile]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbFile](
	[idMtDbFile] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[NameFiles] [varchar](255) NULL,
	[typedesc] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtDbFile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtDbFileOI]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbFileOI](
	[idMtDbFileOi] [int] IDENTITY(1,1) NOT NULL,
	[idMtDbFile] [int] NULL,
	[Driver] [varchar](10) NULL,
	[ReadLatency] [bigint] NULL,
	[WriteLatency] [bigint] NULL,
	[Latency] [bigint] NULL,
	[AvgBPerRead] [bigint] NULL,
	[AvgBPerWrite] [bigint] NULL,
	[AvgBPerTransfer] [bigint] NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtSQLDis__3949F4D9DEC85678] PRIMARY KEY CLUSTERED 
(
	[idMtDbFileOi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtDbFilesize]    Script Date: 09/03/2020 10:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbFilesize](
	[idMtDbFilesize] [int] IDENTITY(1,1) NOT NULL,
	[idMtDbFile] [int] NOT NULL,
	[dbsize] [real] NULL,
	[maxsize] [real] NULL,
	[growth] [nchar](31) NULL,
	[txc] [nchar](10) NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtDbFile__86C4DC9020BE65D4] PRIMARY KEY CLUSTERED 
(
	[idMtDbFilesize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtSQLControlAccess]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLControlAccess](
	[idMtSQLControlAccess] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[loginame] [varchar](128) NULL,
	[cpu] [int] NULL,
	[hostname] [varchar](128) NULL,
	[program_name] [varchar](128) NULL,
	[status] [varchar](30) NULL,
	[blocked] [varchar](5) NULL,
	[spid] [int] NULL,
	[login_time] [datetime] NULL,
	[horasAtual] [datetime] NULL,
	[tempo] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLControlAccess] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtSQLDisk]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLDisk](
	[idMtSQLDisk] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[drive] [char](1) NULL,
	[FreeSpace] [int] NULL,
	[TotalSize] [int] NULL,
	[Livre] [int] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLDisk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtSQLPageLifeExp]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLPageLifeExp](
	[idMtSQLPageLifeExp] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NULL,
	[ple_seconds] [int] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLPageLifeExp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [SGBD].[MtSQLRam]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLRam](
	[idMtSQLRam] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[physicalmemory] [int] NULL,
	[sqlmemory] [int] NULL,
	[memoryused] [int] NULL,
	[totaluserconect] [int] NULL,
	[connectionmemory] [int] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLRam] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [ServerHost].[ServerHost] ADD  CONSTRAINT [DF_ServerHost_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb] ADD  CONSTRAINT [DF_IvSQLPermissionDb_StatusPermission]  DEFAULT ((1)) FOR [StatusPermission]
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin] ADD  CONSTRAINT [DF_IvSQLPermissionLogin_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[MtDbBuffeDB] ADD  CONSTRAINT [DF__MtSQLMemo__DataT__7755B73D]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtDbFileOI] ADD  CONSTRAINT [DF__MtSQLDisk__DataT__4E88ABD4]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtDbFilesize] ADD  CONSTRAINT [DF__MtDbFiles__DataT__6754599E]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtDbSize] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtSQLCPU] ADD  CONSTRAINT [DF__MtSQLCPU__EventT__3F466844]  DEFAULT (getdate()) FOR [EventTime]
GO
ALTER TABLE [SGBD].[MtSQLDisk] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtSQLPageLifeExp] ADD  DEFAULT ((300)) FOR [ple_seconds]
GO
ALTER TABLE [SGBD].[MtSQLPageLifeExp] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtSQLRam] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[SGBD] ADD  CONSTRAINT [DF_SGBD_Cluster]  DEFAULT ((0)) FOR [Cluster]
GO
ALTER TABLE [SGBD].[SGBD] ADD  CONSTRAINT [DF_SGBD_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[SGBDDatabases] ADD  CONSTRAINT [DF_SGBDDatabases_ativo]  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD FOREIGN KEY([idIvSQLPermissionLogin])
REFERENCES [SGBD].[IvSQLPermissionLogin] ([idIvSQLPermissionLogin])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idSGB__367C1819] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb] CHECK CONSTRAINT [FK__IvSQLPerm__idSGB__367C1819]
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin]  WITH CHECK ADD FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idSGB__1EA48E88] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin] CHECK CONSTRAINT [FK__IvSQLPerm__idSGB__1EA48E88]
GO
ALTER TABLE [SGBD].[MtDbBuffeDB]  WITH CHECK ADD  CONSTRAINT [FK_MtDbBuffeDB_SGBDDatabases] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtDbBuffeDB] CHECK CONSTRAINT [FK_MtDbBuffeDB_SGBDDatabases]
GO
ALTER TABLE [SGBD].[MtDbFile]  WITH CHECK ADD  CONSTRAINT [FK_MtDbFile_SGBDDatabases] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtDbFile] CHECK CONSTRAINT [FK_MtDbFile_SGBDDatabases]
GO
ALTER TABLE [SGBD].[MtDbFileOI]  WITH CHECK ADD  CONSTRAINT [FK_MtDbFileOI_MtDbFile] FOREIGN KEY([idMtDbFile])
REFERENCES [SGBD].[MtDbFile] ([idMtDbFile])
GO
ALTER TABLE [SGBD].[MtDbFileOI] CHECK CONSTRAINT [FK_MtDbFileOI_MtDbFile]
GO
ALTER TABLE [SGBD].[MtDbFilesize]  WITH CHECK ADD  CONSTRAINT [FK__MtDbFiles__idMtD__68487DD7] FOREIGN KEY([idMtDbFile])
REFERENCES [SGBD].[MtDbFile] ([idMtDbFile])
GO
ALTER TABLE [SGBD].[MtDbFilesize] CHECK CONSTRAINT [FK__MtDbFiles__idMtD__68487DD7]
GO
ALTER TABLE [SGBD].[MtDbSize]  WITH CHECK ADD FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtSQLControlAccess]  WITH CHECK ADD FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtSQLCPU]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLCPU__idSGBD__6CD828CA] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLCPU] CHECK CONSTRAINT [FK__MtSQLCPU__idSGBD__6CD828CA]
GO
ALTER TABLE [SGBD].[MtSQLDbBackup]  WITH CHECK ADD FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtSQLDisk]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLDisk__idSGB__7E02B4CC] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLDisk] CHECK CONSTRAINT [FK__MtSQLDisk__idSGB__7E02B4CC]
GO
ALTER TABLE [SGBD].[MtSQLPageLifeExp]  WITH CHECK ADD  CONSTRAINT [FK_MtSQLPageLifeExp_SGBD] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLPageLifeExp] CHECK CONSTRAINT [FK_MtSQLPageLifeExp_SGBD]
GO
ALTER TABLE [SGBD].[MtSQLRam]  WITH CHECK ADD  CONSTRAINT [FK_MtSQLRam_SGBD] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLRam] CHECK CONSTRAINT [FK_MtSQLRam_SGBD]
GO
ALTER TABLE [SGBD].[SGBD]  WITH CHECK ADD  CONSTRAINT [FK__SGBD__idServerHo__1A14E395] FOREIGN KEY([idServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [SGBD].[SGBD] CHECK CONSTRAINT [FK__SGBD__idServerHo__1A14E395]
GO
ALTER TABLE [SGBD].[SGBDDatabases]  WITH CHECK ADD  CONSTRAINT [FK__SGBDDatab__idSGB__5629CD9C] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[SGBDDatabases] CHECK CONSTRAINT [FK__SGBDDatab__idSGB__5629CD9C]
GO
/****** Object:  StoredProcedure [dbo].[SP_AtlBackupMsQuadroDetalhado]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








/**/
CREATE PROCEDURE [dbo].[SP_AtlBackupMsQuadroDetalhado]
AS
DECLARE @Servidor    nchar(50)
DECLARE @BasedeDados  nchar(50)
DECLARE @Backup		 INT
DECLARE @DataExecucao nCHAR(2)
DECLARE @ScriptExec nchar(3000)
DECLARE @lError		 SMALLINT

DECLARE db_for CURSOR FOR

		SELECT [Servidor]
			  ,[BasedeDados]			  
			  ,[BACKUP]
			  ,LEFT([DataExecucao],2)
		  FROM [SGBD].[BackupsMsMonitorMes]

OPEN db_for 
FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao 

WHILE @@FETCH_STATUS = 0
BEGIN

		IF (@Backup = 1) -- O backup falhou
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''1''
								FROM [SGBD].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
								
		END
			ELSE
		IF (@Backup = 2) -- O backup executou com falha
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''2''
								FROM [SGBD].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END
			ELSE		
		IF (@Backup = 3) -- O backup executou com sucesso.
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''3''
								FROM [SGBD].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	
			ELSE		
		IF (@Backup = 4) -- O backup nao executou ainda
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''4''
								FROM [SGBD].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	

	EXEC sp_executesql @ScriptExec

	--PRINT @ScriptExec

	FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao
END

CLOSE db_for
DEALLOCATE db_for










GO
/****** Object:  StoredProcedure [dbo].[SP_PrcBackupMsQuadroDetalhado]    Script Date: 09/03/2020 10:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_PrcBackupMsQuadroDetalhado]
AS
	DECLARE @ultimodia  int
	DECLARE @cont       int
	DECLARE @campoCont  varchar(20)
	DECLARE @scritp1    varchar(2000)
	DECLARE @scritp2    varchar(500)
	DECLARE @scritpExec nchar(3000)

	SELECT @ultimodia =  DAY(dbo.F_UltimmoDiaMesDT(GETDATE()))

	SET @cont = 1
	SET @campoCont = '[]'
	SET @scritp1 = ''
	SET @scritp2 = ''

	WHILE @cont <= @ultimodia
	BEGIN

		IF @cont <= 9 
			BEGIN		
				SET @campoCont = '[0' + LTRIM(STR(@cont)) + ']'
			END
			ELSE
			BEGIN
				SET @campoCont = '[' + LTRIM(STR(@cont)) + ']'
			END	



		SET @scritp1 = @scritp1 + ', CASE WHEN ' + @campoCont + ' IS NULL THEN 4 ELSE 4 END AS ' + @campoCont	

		IF @cont < @ultimodia
				SET @scritp2 = @scritp2  + @campoCont + ', '
			ELSE
				SET @scritp2 = @scritp2  + @campoCont 

		SET @cont = @cont + 1

	
	END

		SET @scritpExec = '
		
					IF OBJECT_ID(''[SGBD].[BackupsMsQuadroDetalhado]'', ''U'') IS NOT NULL 
						DROP TABLE [SGBD].[BackupsMsQuadroDetalhado]
		
		
						    SELECT Servidor
								, BasedeDados'
								+ @scritp1 +
							 'INTO SGBD.BackupsMsQuadroDetalhado
							  FROM (SELECT [Servidor]
										  ,[BasedeDados]
										  ,ROUND(SUM([Tamanho]),2) AS ''Tamanho''
										  ,[Dia]
									  FROM [Report].[BackupsMsMonitorMes]
									  GROUP BY [Servidor],[BasedeDados],[Dia]) AS A
							 PIVOT (SUM(A.Tamanho) FOR [Dia] IN('+ @scritp2 +')) AS B
							ORDER BY Servidor, BasedeDados'

		 EXEC sp_executesql @scritpExec
		 --print   @scritpExec







GO
