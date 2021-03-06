USE [inventario]
GO
/****** Object:  User [sisrelatorio]    Script Date: 27/10/2021 16:48:49 ******/
CREATE USER [sisrelatorio] FOR LOGIN [sisrelatorio] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [usrsm]    Script Date: 27/10/2021 16:48:49 ******/
CREATE USER [usrsm] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [sisrelatorio]
GO
ALTER ROLE [db_owner] ADD MEMBER [usrsm]
GO
/****** Object:  Schema [app]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [app]
GO
/****** Object:  Schema [Report]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [Report]
GO
/****** Object:  Schema [Rotineira]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [Rotineira]
GO
/****** Object:  Schema [ServerHost]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [ServerHost]
GO
/****** Object:  Schema [SGBD]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [SGBD]
GO
/****** Object:  Schema [Zabbix]    Script Date: 27/10/2021 16:48:49 ******/
CREATE SCHEMA [Zabbix]
GO
/****** Object:  UserDefinedFunction [dbo].[F_BackupExe]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_BackupExe] (@idSGBD int,@DATA DATETIME) RETURNS INT  AS
BEGIN

DECLARE @BKE INT

SELECT @BKE = CASE 
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 2 
				 AND B.[FreqMonday] = 1                  THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 3 
				 AND B.[FreqTuesDay] = 1                 THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 4 
				 AND B.[FreqWednesday] = 1               THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 5 
				 AND B.[FreqTrursday] = 1                THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 6 
				 AND B.[FreqFriday] = 1                  THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 7 
				 AND B.[FreqSaturday] = 1                THEN 1
				WHEN [dbo].[FDIA_SEMANA] (@DATA) = 1 
				 AND B.[Sunday] = 1                      THEN 1
			   ELSE 0
			   END 
		  FROM [SGBD].[SGBDServidorProd] AS A
		  INNER JOIN [SGBD].[MnSQLBackupJanela] AS B ON A.idSGBD = B.idSGBD
		  WHERE A.idSGBD = @idSGBD

  RETURN @BKE
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_BK_JANELA_FIM]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[F_BK_JANELA_FIM](@IDSGBD INT, @DATA DATETIME)  RETURNS DATETIME  AS
begin

declare @J_INICIO TIME
declare @J_FIM TIME
declare @J_INICIO1 char(10)
declare @J_FIM1 char(10)
declare @J_data char(10)
declare @return DATETIME

	SELECT @J_INICIO = [startJanela]
	     , @J_FIM    = [endJanela]
	 FROM [SGBD].[MnSQLBackupJanela]
	  WHERE [idSGBD] = @IDSGBD


	 IF @J_FIM < @J_INICIO
	    SET @J_data = LEFT(CONVERT(CHAR(10),DATEADD(DAY,1,@DATA),120),10)
     ELSE 
	   BEGIN  
	    SET @J_data = LEFT(CONVERT(CHAR(10),@DATA,120),10)
	   END;

			SELECT @J_FIM1    = convert(char(8),[endJanela],114)
			 FROM [SGBD].[MnSQLBackupJanela]
			  WHERE [idSGBD] = @IDSGBD
 

   SELECT @return = CAST( (@J_data +' '+ @J_FIM1) AS datetime)
   
RETURN @return 

end



GO
/****** Object:  UserDefinedFunction [dbo].[F_BK_JANELA_INICIO]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[F_BK_JANELA_INICIO](@IDSGBD INT, @DATA DATETIME)  RETURNS DATETIME  AS
begin

declare @J_INICIO char(8)
declare @J_data char(10)
declare @return DATETIME

	SELECT @J_INICIO = convert(char(8),[startJanela],114)
	 FROM [SGBD].[MnSQLBackupJanela]
	  WHERE [idSGBD] = @IDSGBD

   SET @J_data = LEFT(CONVERT(CHAR(10),@DATA,120),10)

   SELECT @return = CAST( (@J_data +' '+ @J_INICIO) AS datetime)
   
RETURN @return 

end


GO
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNow24]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNowZero]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesCh]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesDT]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesCh]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesDT]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[FDIA_SEMANA]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [dbo].[FMES_EXT]    Script Date: 27/10/2021 16:48:49 ******/
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
/****** Object:  UserDefinedFunction [Rotineira].[F_BackupJanelaFim]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [Rotineira].[F_BackupJanelaFim](@idSGBD INT, @DATA DATETIME) RETURNS datetime  AS
BEGIN

declare @Convert   datetime

SELECT --[idSGBD],
    -- @Convert =  CONVERT(CHAR(10),DATEADD(DAY,0,@DATA),120)+' '+CONVERT(CHAR(8),[startJanela],14) --AS 'JanelaInicio'
	  @Convert =  CASE
		WHEN [endJanela] < [startJanela]  THEN CONVERT(CHAR(10),DATEADD(DAY,1,@DATA),120)+' '+CONVERT(CHAR(8),[endJanela],14)
		ELSE CONVERT(CHAR(10),DATEADD(DAY,0,@DATA),120)+' '+CONVERT(CHAR(8),[endJanela],14)
		END --AS 'JanelaFim'
  FROM [SGBD].[MnSQLBackupJanela]
  WHERE [idSGBD] =  @idSGBD

RETURN @Convert 

END

GO
/****** Object:  UserDefinedFunction [Rotineira].[F_BackupJanelaInicio]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [Rotineira].[F_BackupJanelaInicio](@idSGBD INT, @DATA DATETIME) RETURNS datetime  AS
BEGIN

declare @Convert   datetime

SELECT --[idSGBD],
     @Convert =  CONVERT(CHAR(10),DATEADD(DAY,0,@DATA),120)+' '+CONVERT(CHAR(8),[startJanela],14) --AS 'JanelaInicio'
	/*  ,CASE
		WHEN [endJanela] < [startJanela]  THEN CONVERT(CHAR(10),DATEADD(DAY,1,@DATA),120)+' '+CONVERT(CHAR(8),[endJanela],14)
		ELSE CONVERT(CHAR(10),DATEADD(DAY,0,@DATA),120)+' '+CONVERT(CHAR(8),[endJanela],14)
		END AS 'JanelaFim'*/
  FROM [SGBD].[MnSQLBackupJanela]
  WHERE [idSGBD] =  @idSGBD

RETURN @Convert 

END

GO
/****** Object:  UserDefinedFunction [Rotineira].[F_BackupWindows]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [Rotineira].[F_BackupWindows](@idSGBD INT, @DATA DATETIME) RETURNS INT  AS
BEGIN
	declare @Dia       datetime
	declare @Convert   char(19)
	declare @return    INT

	--SET @Dia =  DateAdd(day, -0 ,@DATA)

		IF [dbo].[FDIA_SEMANA] (@DATA) = 2 
		BEGIN 
			SELECT @return = [FreqMonday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 3 
		BEGIN 
			SELECT @return = [FreqTuesDay]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 4 
		BEGIN 
			SELECT @return = [FreqWednesday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 5 
		BEGIN 
			SELECT @return = [FreqTrursday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 6 
		BEGIN 
			SELECT @return = [FreqFriday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE		   
		IF [dbo].[FDIA_SEMANA] (@DATA) = 7
		BEGIN 
			SELECT @return = [FreqSaturday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
		   ELSE
		IF [dbo].[FDIA_SEMANA] (@DATA) = 1 
		BEGIN 
			SELECT @return = [Sunday]
			  FROM [SGBD].[MnSQLBackupJanela]
			   WHERE [idSGBD] = @idSGBD 
				AND [dateStat] < @DATA  
				 AND [dateEnd] = '2022-12-31 00:00:00.000'   
		END
           
-- SET @return = [dbo].[FDIA_SEMANA] (@Dia)
--             [dbo].[FDIA_SEMANA] (GETDATE())
 
RETURN @return    

END



GO
/****** Object:  UserDefinedFunction [Rotineira].[F_RetornoDBszAcumulado]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [Rotineira].[F_RetornoDBszAcumulado]()
RETURNS @table TABLE(  
         idsgbd int
       , srv varchar(30)
	   , mbsize real
	   , monthN int
	   , monthC char(20))
AS
BEGIN
	DECLARE @cont int 
	DECLARE @x int 
	DECLARE @Valor REAL

	SET @cont = 1
	SET @x = MONTH(DATEADD(MONTH, - 1, GETDATE())) 

		WHILE @cont <= @x 
		BEGIN


			INSERT INTO @table (idsgbd,srv, mbsize, monthN, monthC)
					SELECT
					        SG.idSGBD
						 ,  UPPER(SG.[Servidor])
						 , CASE 
								WHEN ROUND(SUM(SZ.db_size/1024), 2) IS NULL THEN 0 
								ELSE ROUND(SUM(SZ.db_size)/1024, 2) 
							END AS 'SizeMB'
						 , @cont
						 , CASE @cont 
								WHEN 1 THEN 'Janeiro' 
								WHEN 2 THEN 'Fevereiro' 
								WHEN 3 THEN 'Março' 
								WHEN 4 THEN 'Abril' 
								WHEN 5 THEN 'Maio' 
								WHEN 6 THEN 'Junho' 
								WHEN 7 THEN 'Julho' 
								WHEN 8 THEN 'Agosto' 
								WHEN 9 THEN 'Setembro' 
								WHEN 10 THEN 'Outubro' 
								WHEN 11 THEN 'Novembro' 
								WHEN 12 THEN 'Dezembro' 
							END AS Mes
					FROM [SGBD].[SGBDDatabases] AS DB 
					INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD 
					LEFT JOIN (SELECT [idSGBD], [idDatabases], MAX([DataTimer]) AS 'DataTimer'
								FROM [SGBD].[MtDbSize]
								WHERE [DataTimer] >= [dbo].[F_HoraDiaNowZero]([dbo].[F_UltimmoDiaMesDT](CAST(CAST(YEAR(GETDATE()) AS CHAR(4))+ '-' + CASE WHEN @cont > 9 THEN CAST(@cont AS CHAR(2)) ELSE '0' + CAST(@cont AS CHAR(1)) END + '-' + '01 00:00:00' AS datetime))) 
								  AND [DataTimer] <= [dbo].[F_HoraDiaNow24]([dbo].[F_UltimmoDiaMesDT](CAST(CAST(YEAR(GETDATE()) AS CHAR(4))+ '-' + CASE WHEN @cont > 9 THEN CAST(@cont AS CHAR(2)) ELSE '0' + CAST(@cont AS CHAR(1)) END + '-' + '01 00:00:00' AS datetime)))
								GROUP BY [idSGBD], [idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases 
					LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
					--WHERE [SGBD] LIKE 'MSSQLServer%'
					GROUP BY SG.idSGBD, SG.[Servidor]
					ORDER BY SG.[Servidor]


			SET @cont = @cont + 1 

		END

	SET @cont = 3
	SELECT @Valor = CASE 
						WHEN ROUND(SUM(SZ.db_size/1024), 2) IS NULL THEN 0 
						ELSE ROUND(SUM(SZ.db_size)/1024, 2) 
					END 
	FROM [SGBD].[SGBDDatabases] AS DB 
	INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD 
	LEFT JOIN (SELECT [idSGBD], [idDatabases], MAX([DataTimer]) AS 'DataTimer'
			FROM [SGBD].[MtDbSize]
			WHERE [idSGBD] = 83
				AND [DataTimer] >= '2019-03-28 00:00:00' 
				AND [DataTimer] <= '2019-03-29 00:00:00' 
			GROUP BY [idSGBD], [idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases 
	LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
	WHERE SG.idSGBD = 83
	GROUP BY SG.idSGBD, SG.[Servidor]
	ORDER BY SG.[Servidor]

	UPDATE @table 
	    SET mbsize = @Valor
	WHERE idsgbd = 83 
	  AND monthN = 3


	RETURN
END
GO
/****** Object:  UserDefinedFunction [Rotineira].[F_RetornoDiaMesAtual]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [Rotineira].[F_RetornoDiaMesAtual]()
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
/****** Object:  Table [SGBD].[IvPgRoles]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvPgRoles](
	[idIvPgRoles] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[oid] [int] NOT NULL,
	[rolname] [varchar](70) NULL,
	[rolsuper] [bit] NULL,
	[rolinherit] [bit] NULL,
	[rolcreaterole] [bit] NULL,
	[rolcreatedb] [bit] NULL,
	[rolcatupdate] [bit] NULL,
	[rolcanlogin] [bit] NULL,
	[rolreplication] [bit] NULL,
	[rolconnlimit] [int] NULL,
	[rolconfig] [nvarchar](max) NULL,
	[ativo] [bit] NULL,
 CONSTRAINT [PK_idIvPgRoles] PRIMARY KEY CLUSTERED 
(
	[idIvPgRoles] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[IvPgSchemaPrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvPgSchemaPrivileges](
	[idIvPgSchemaPrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idIvPgRoles] [int] NOT NULL,
	[schema_name] [nvarchar](50) NULL,
	[create_a] [bit] NULL,
	[usage_a] [bit] NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK_idIvPgSchemaPrivileges] PRIMARY KEY CLUSTERED 
(
	[idIvPgSchemaPrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_IvPgSchemaPrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [SGBD].[VW_IvPgSchemaPrivileges]
AS
SELECT [idDatabases]
      ,R.[idIvPgRoles]
	  ,R.rolname
      ,[schema_name]
      ,[create_a]
      ,[usage_a]
      ,[dataupdate]
  FROM [SGBD].[IvPgSchemaPrivileges] AS SC
  INNER JOIN [SGBD].[IvPgRoles] AS R ON R.idIvPgRoles = SC.idIvPgRoles
GO
/****** Object:  Table [SGBD].[SGBDDatabases]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDDatabases](
	[idDatabases] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[BasedeDados] [varchar](150) NULL,
	[Descricao] [varchar](255) NULL,
	[owner] [varchar](30) NULL,
	[dbid] [varchar](30) NULL,
	[created] [datetime] NULL,
	[OnlineOffline] [varchar](30) NULL,
	[RestrictAccess] [varchar](15) NULL,
	[recovery_model] [varchar](30) NULL,
	[collation] [varchar](30) NULL,
	[compatibility_level] [varchar](30) NULL,
	[ativo] [bit] NULL,
 CONSTRAINT [PK__SGBDData__2BA9FD7E49097968] PRIMARY KEY CLUSTERED 
(
	[idDatabases] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtDbSize]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtDbSize](
	[idMtDbSize] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[db_size] [real] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtDbSize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[SGBD]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBD](
	[idSGBD] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[IdTrilha] [int] NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ServerHost].[ServerHost]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ServerHost].[ServerHost](
	[idServerHost] [int] IDENTITY(1,1) NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[HostName] [varchar](60) NULL,
	[FisicoVM] [varchar](20) NULL,
	[SistemaOperaciona] [varchar](50) NULL,
	[IPaddress] [varchar](50) NULL,
	[PortConect] [varchar](10) NULL,
	[Descricao] [varchar](max) NULL,
	[Versao] [varchar](350) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK__ServerHo__F1EA723907020F21] PRIMARY KEY CLUSTERED 
(
	[idServerHost] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [SGBD].[SGBDEst]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [SGBD].[SGBDEst]
as
SELECT S.idSGBD
      ,SH.idServerHost
	  ,UPPER(CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])				
		END )AS 'Servidor'
      ,UPPER(SH.HostName) as 'HostName'
      ,[Estancia]
      ,[SGBD]
      ,S.IP AS IP
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
   WHERE SH.ATIVO = 1 AND S.Ativo = 1 AND [EstanciaAtivo] = 1
--ORDER BY [SGBD]


GO
/****** Object:  View [SGBD].[SGBDEstDB]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [SGBD].[SGBDEstDB]
AS
SELECT DB.[idDatabases]
      ,DB.[idSGBD]
	  ,CASE 
		WHEN ([Estancia] <> '' ) AND ([Cluster]  = 0 ) THEN ([HostName]+'\'+[Estancia])
		WHEN ([Cluster]  = 1 ) AND ([Estancia] IS NOT NULL ) THEN UPPER(REPLACE([conectstring],',1433',''))
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])			
		END AS 'Servidor'
      ,[BasedeDados]
      ,ROUND(ST.db_size, 2) AS 'SizeMB'
	  ,CONVERT(nCHAR(10),ST.DataTimer,103) AS 'DataTimer'
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
  INNER JOIN [SGBD].[SGBDEst] AS SG ON SG.[idSGBD] = DB.idSGBD
  LEFT JOIN (SELECT [idSGBD],[idDatabases],MAX([DataTimer]) AS 'DataTimer',MAX([db_size]) as 'db_size'
               FROM [SGBD].[MtDbSize]
				GROUP BY [idSGBD] ,[idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases
  --LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = ST.idSGBD AND SZ.idDatabases = ST.idDatabases AND SZ.DataTimer = ST.DataTimer
  WHERE DB.ativo = 1
--  ORDER BY [BasedeDados]
--    AND DB.OnlineOffline = 'ONLINE'

GO
/****** Object:  Table [SGBD].[SGBDTable]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDTable](
	[idSGBDTable] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[schema_name] [varchar](128) NULL,
	[table_name] [varchar](128) NULL,
	[reservedkb] [real] NULL,
	[datakb] [real] NULL,
	[Indiceskb] [real] NULL,
	[sumline] [int] NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK__SGBDTabl__B2C63C1FA6776892] PRIMARY KEY CLUSTERED 
(
	[idSGBDTable] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDEstDBTable]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [SGBD].[VW_SGBDEstDBTable]
as
SELECT T.[idSGBDTable]
      ,T.[idDatabases]
      ,T.[schema_name]
      ,T.[table_name]
      ,T.[reservedkb]
      ,T.[datakb]
      ,T.[Indiceskb]
      ,T.[sumline]
      ,T.[dataupdate]
  FROM [SGBD].[SGBDTable] AS T
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = T.idDatabases

GO
/****** Object:  Table [SGBD].[MtPgTablePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgTablePrivileges](
	[idSGBDPgTablePrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[grantor] [nvarchar](50) NULL,
	[grantee] [nvarchar](50) NULL,
	[table_catalog] [nvarchar](50) NULL,
	[privilege_type] [nvarchar](20) NULL,
	[is_grantable] [nvarchar](5) NULL,
	[with_hierarchy] [nvarchar](5) NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDPgTablePrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_MtPgTablePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [SGBD].[VW_MtPgTablePrivileges]
AS
SELECT TP.[idSGBDTable]
      ,T.idDatabases
      ,[schema_name]
      ,[table_name]
      ,[grantor]
      ,[grantee]
      ,[table_catalog]
      ,[privilege_type]
      ,[is_grantable]
      ,[with_hierarchy]
      ,[UpdateDataTimer]
  FROM [SGBD].[MtPgTablePrivileges] AS TP
INNER JOIN [SGBD].[VW_SGBDEstDBTable] AS T ON T.[idSGBDTable] = TP.[idSGBDTable]
GO
/****** Object:  Table [SGBD].[SGBDTableIndex]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDTableIndex](
	[idSGBDTableIndex] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[Index_name] [varchar](255) NULL,
	[FileGroup] [varchar](255) NULL,
	[type_desc] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTableIndex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDTableIndex]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [SGBD].[VW_SGBDTableIndex]
AS
SELECT [idSGBDTableIndex]
      ,I.[idSGBDTable]
      ,I.[Index_name]
      ,I.[FileGroup]
      ,I.[type_desc]
  FROM [SGBD].[SGBDTableIndex] AS I
  INNER JOIN [SGBD].[SGBDTable] AS T ON T.idSGBDTable = I.idSGBDTable
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = T.idDatabases
GO
/****** Object:  Table [SGBD].[SGBDTableColumn]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDTableColumn](
	[idSGBDTableColumn] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[colunn_name] [varchar](128) NULL,
	[ordenal_positon] [int] NULL,
	[data_type] [varchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTableColumn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDTableColumn]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [SGBD].[VW_SGBDTableColumn]
as
SELECT C.[idSGBDTableColumn]
      ,C.[idSGBDTable]
      ,C.[colunn_name]
      ,C.[ordenal_positon]
      ,C.[data_type]
  FROM [SGBD].[SGBDTableColumn] AS C
  INNER JOIN [SGBD].[SGBDTable] AS T ON T.idSGBDTable = C.idSGBDTable
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = T.idDatabases
GO
/****** Object:  Table [SGBD].[MtSQLTableIndexUser]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLTableIndexUser](
	[idSGBDTableIndexUser] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableIndex] [int] NOT NULL,
	[last_user_seek] [datetime] NULL,
	[last_user_scan] [datetime] NULL,
	[last_user_lookup] [datetime] NULL,
	[last_user_update] [datetime] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTableIndexUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDSQLTableIndexUser]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [SGBD].[VW_SGBDSQLTableIndexUser]
AS
SELECT U.[idSGBDTableIndex]
      ,MAX(U.[last_user_seek])   AS 'Última busca do usuário'
      ,MAX(U.[last_user_scan])   AS 'Última varredura do usuário'
      ,MAX(U.[last_user_lookup]) AS 'Última consulta de usuário'
      ,MAX(U.[last_user_update]) AS 'Última atualização do usuário'
      ,MAX(U.[UpdateDataTimer])  AS 'Última atualização das metricas'
  FROM [SGBD].[MtSQLTableIndexUser] AS U
  INNER JOIN [SGBD].[SGBDTableIndex] AS I ON I.idSGBDTableIndex = U.idSGBDTableIndex
  INNER JOIN [SGBD].[SGBDTable] AS T ON T.idSGBDTable = I.idSGBDTable
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = T.idDatabases
GROUP BY U.[idSGBDTableIndex]
GO
/****** Object:  Table [SGBD].[MtPgTableStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgTableStat](
	[idSGBDPgTableStat] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[seq_scan] [int] NULL,
	[seq_tup_read] [int] NULL,
	[idx_scan] [int] NULL,
	[idx_tup_fetch] [int] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDPgTableStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDPgTableStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [SGBD].[VW_SGBDPgTableStat]
as
SELECT A.[idSGBDPgTableStat]
      ,A.[idSGBDTable]
      ,A.[seq_scan]
      ,A.[seq_tup_read]
      ,A.[idx_scan]
      ,A.[idx_tup_fetch]
      ,A.[UpdateDataTimer]
  FROM [SGBD].[MtPgTableStat] AS A
  INNER JOIN (SELECT [idSGBDTable]
      ,MAX([UpdateDataTimer]) AS 'UpdateDataTimer'
  FROM [SGBD].[MtPgTableStat]
GROUP BY [idSGBDTable]) AS B ON B.[idSGBDTable] = A.[idSGBDTable]  AND B.[UpdateDataTimer] = A.[UpdateDataTimer]

GO
/****** Object:  View [SGBD].[VWSGBDEstDBSize]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [SGBD].[VWSGBDEstDBSize]
as
SELECT A.idDatabases
	 --,CONVERT(DATE,A.DataTimer,11) AS 'Data'
	 ,MONTH(A.DataTimer) AS 'Mes'
	 ,A.DataTimer
	 , C.db_size
FROM [SGBD].[MtDbSize] AS A
INNER JOIN [SGBD].[MtDbSize] AS C ON C.idDatabases = A.idDatabases 
                                 AND C.DataTimer   = A.DataTimer
WHERE A.DataTimer = (SELECT MAX(B.DataTimer)
                     FROM [SGBD].[MtDbSize] AS B
					 WHERE B.idDatabases = A.idDatabases
					 GROUP BY B.idDatabases)
GO
/****** Object:  Table [SGBD].[MtMySQLControlAccess]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLControlAccess](
	[idMtMySQLControlAccess] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[Id] [int] NULL,
	[MyUser] [varchar](60) NULL,
	[Host] [varchar](60) NULL,
	[Command] [varchar](60) NULL,
	[Time] [int] NULL,
	[State] [varchar](60) NULL,
	[Info] [varchar](2000) NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtMySQLC__B807FC5903F0984C] PRIMARY KEY CLUSTERED 
(
	[idMtMySQLControlAccess] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtSQLControlAccess]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLControlAccess](
	[idMtSQLControlAccess] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtPgControlAccess]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgControlAccess](
	[idMtPgControlAccess] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[usename] [varchar](60) NULL,
	[client_addr] [varchar](60) NULL,
	[query_start] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtPgControlAccess] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[DatabaseAccessIP]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [SGBD].[DatabaseAccessIP]
AS
SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[MyUser]	AS 'Login'
	  ,REPLACE(LEFT([Host],(CHARINDEX(':',[Host]))),':','')  AS 'IP'
  FROM [SGBD].[MtMySQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[loginame] AS 'Login'
      ,[hostname] AS 'IP'	  
  FROM [SGBD].[MtSQLControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

UNION ALL

SELECT DISTINCT
       B.Servidor
      ,B.BasedeDados
      ,[usename] AS 'Login'
      ,[client_addr] AS 'IP'	 
  FROM [SGBD].[MtPgControlAccess]AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases

GO
/****** Object:  View [Rotineira].[DesempenhoDBcrescimentoDiv]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**/
CREATE VIEW [Rotineira].[DesempenhoDBcrescimentoDiv]
as

SELECT B.Servidor	
	  ,B.BasedeDados
	 , CASE 
	    WHEN [db_size] IS NULL THEN 0
		ELSE [db_size] END AS 'Tamanho'
     , CASE 
	     WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
		  AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
		 THEN LAG([db_size], 1, null) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
		 ELSE 0
		END AS 'ValorAnterior'
     , CASE 
	     WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
		  AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
		 THEN ROUND([db_size] - LAG([db_size], 1)OVER(ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111)),2) 
		 ELSE 0 --ROUND([db_size],2) 
		END AS 'ValorDiferencia'
	,CONVERT([varchar], C.[DataTimer], 111) AS 'Periodo'
    ,B.SGBD
  FROM [SGBD].[MtDbSize] AS C
INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idSGBD = C.idSGBD AND B.[idDatabases] = C.[idDatabases] 
WHERE C.[DataTimer] >= DATEADD(DAY,-15, GETDATE())
  AND C.[DataTimer] <= GETDATE()	
AND B.Descricao = 'Produção'
AND (B.BasedeDados <> 'master'
  AND B.BasedeDados <> 'model'
  AND B.BasedeDados <> 'msdb'
  AND B.BasedeDados <> 'tempdb'
  AND B.BasedeDados <> 'postgres'
  AND B.BasedeDados <> 'mysql'
  AND B.BasedeDados <> 'information_schema'
  AND B.BasedeDados <> 'performance_schema'
  AND B.BasedeDados NOT LIKE 'Report%')
--ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111)

GO
/****** Object:  View [Report].[DatabaseSize]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Report].[DatabaseSize]
as
SELECT VA.idSGBD
     , VA.idDatabases
	 , VA.DT
	 , CONVERT(CHAR(8), VA.HM, 114) AS 'HM'
	 , VZ.DataTimer
	 , CAST(CAST(VZ.db_size AS REAL) AS DECIMAL(20,2)) AS 'TamanhoMB'
	 , CAST(CAST(VZ.db_size / 1024 AS REAL) AS DECIMAL(20,2)) AS 'TamanhoGM'
	 
FROM (SELECT V.idSGBD, V.idDatabases, V.DT, MAX(CAST(VH.DataTimer AS TIME)) AS 'HM'
		FROM (SELECT idSGBD, idDatabases, MAX(CAST([DataTimer] as DATE)) AS 'DT', MAX(CAST([DataTimer] as time)) AS 'HM'
				FROM [SGBD].[MtDbSize]
				GROUP BY idSGBD, idDatabases, CAST([DataTimer] as DATE)) AS V
		INNER JOIN [SGBD].[MtDbSize] AS VH ON VH.idSGBD = V.idSGBD AND VH.idDatabases = V.idDatabases AND CAST(VH.DataTimer AS DATE) = V.DT
		GROUP BY  V.idSGBD, V.idDatabases, V.DT ) AS VA
INNER JOIN [SGBD].[MtDbSize] AS VZ ON VZ.idSGBD = VA.idSGBD 
       AND VZ.idDatabases = VA.idDatabases 
	   AND CAST(VZ.DataTimer AS DATE) = VA.DT 
	   AND CAST(VZ.DataTimer AS TIME) = VA.HM
INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = VA.idDatabases
GO
/****** Object:  Table [SGBD].[IvPgRolesMembers]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvPgRolesMembers](
	[IvPgRolesMembers] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[roleid] [int] NULL,
	[member] [int] NULL,
	[grantor] [int] NULL,
	[admin_option] [bit] NULL,
	[ativo] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[IvPgRolesMembers] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_IvPgRolesName]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [SGBD].[VW_IvPgRolesName]
AS
SELECT DISTINCT
      CAST(CAST(M.idSGBD AS VARCHAR(20)) + CAST([roleid] AS VARCHAR(20)) AS FLOAT) 'roles_oid'      
      ,M.idSGBD
      ,M.[roleid] 
      ,R.rolname
      ,R.[rolsuper]
      ,R.[rolinherit]
      ,R.[rolcreaterole]
      ,R.[rolcreatedb]
      ,R.[rolcatupdate]
      ,R.[rolcanlogin]
      ,R.[rolreplication]
      ,R.[rolconnlimit]
  FROM [SGBD].[IvPgRolesMembers] M  
  INNER JOIN [SGBD].[SGBDEst] AS S ON S.idSGBD = M.idSGBD
  INNER JOIN [SGBD].[IvPgRoles] R ON R.idSGBD = M.idSGBD AND R.[idIvPgRoles] = M.roleid
  
--ORDER BY 1, 2
GO
/****** Object:  View [SGBD].[VW_IvPgRolesMembers]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [SGBD].[VW_IvPgRolesMembers]
as
SELECT DISTINCT
       M.idSGBD
	  ,CAST(CAST(M.idSGBD AS VARCHAR(20)) + CAST([roleid] AS VARCHAR(20)) AS FLOAT) 'roles_oid'
	  ,CAST(CAST(M.idSGBD AS VARCHAR(20)) + CAST([member] AS VARCHAR(20)) AS FLOAT) 'user_oid'
	  ,CAST(CAST(M.idSGBD AS VARCHAR(20)) + CAST([grantor] AS VARCHAR(20)) AS FLOAT) 'grantor_oid'
      ,R.rolname as 'roles_name'
	  ,B.rolname as 'user_name'
      ,C.rolname as 'user_grantor'
  FROM [SGBD].[IvPgRolesMembers] M  
  LEFT JOIN [SGBD].[IvPgRoles] R ON R.idSGBD = M.idSGBD AND R.[idIvPgRoles] = M.roleid
  LEFT JOIN [SGBD].[IvPgRoles] B ON B.idSGBD = M.idSGBD AND B.[idIvPgRoles] = M.member
  LEFT JOIN [SGBD].[IvPgRoles] C ON C.idSGBD = M.idSGBD AND C.[idIvPgRoles] = M.grantor
--ORDER BY 1, 2
GO
/****** Object:  View [SGBD].[VW_IvPgRolesUser]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [SGBD].[VW_IvPgRolesUser]
AS
SELECT CAST(CAST(R.idSGBD AS VARCHAR(20)) + CAST([idIvPgRoles] AS VARCHAR(20)) AS FLOAT) 'user_oid'
      ,R.[idSGBD]
	  ,[idIvPgRoles]
      ,[oid] 
      ,[rolname]
      ,[rolsuper]
      ,[rolinherit]
      ,[rolcreaterole]
      ,[rolcreatedb]
      ,[rolcatupdate]
      ,[rolcanlogin]
      ,[rolreplication]
      ,[rolconnlimit]
      ,[rolconfig]
      ,[ativo]
  FROM [SGBD].[IvPgRoles] AS R
  INNER JOIN [SGBD].[SGBDEst] AS S ON S.idSGBD = R.idSGBD
  WHERE NOT EXISTS (SELECT * FROM [SGBD].[IvPgRolesMembers] AS M
                     WHERE R.idSGBD = M.idSGBD AND R.oid = M.roleid)

GO
/****** Object:  Table [SGBD].[MtPgTableIndexStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgTableIndexStat](
	[idSGBDTPgTableIndexStat] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableIndex] [int] NOT NULL,
	[idx_scan] [bigint] NULL,
	[idx_tup_read] [bigint] NULL,
	[idx_tup_fetch] [bigint] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTPgTableIndexStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_SGBDPgTableIndexStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [SGBD].[VW_SGBDPgTableIndexStat]
as
SELECT [idSGBDTPgTableIndexStat]
      ,[idSGBDTableIndex]
      ,[idx_scan]
      ,[idx_tup_read]
      ,[idx_tup_fetch]
      ,[UpdateDataTimer]
  FROM [SGBD].[MtPgTableIndexStat]
GO
/****** Object:  Table [SGBD].[MtOracleControlAccess]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtOracleControlAccess](
	[idMtOracleControlAccess] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[SID] [int] NULL,
	[SQL_ID] [varchar](15) NULL,
	[USERNAME] [varchar](40) NULL,
	[SCHEMANAME] [varchar](40) NULL,
	[MACHINE] [varchar](70) NULL,
	[STATUS] [varchar](10) NULL,
	[SQL_ADDRESS] [varchar](40) NULL,
	[SQL_HASH_VALUE] [varchar](40) NULL,
	[SQL_CHILD_NUMBER] [varchar](40) NULL,
	[LOGON_TIME] [datetime] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtOracleControlAccess] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[DatabaseAccess]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [SGBD].[DatabaseAccess]
AS

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(DATE,[login_time],11) AS 'Data'
  FROM [SGBD].[MtSQLControlAccess] AS A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases],CONVERT(DATE,[login_time],11)

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(date, A.[DataTimer], 111) AS 'Data'
  FROM [SGBD].[MtMySQLControlAccess] A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases], CONVERT(date, A.[DataTimer], 111)

UNION ALL

SELECT A.[idSGBD]
      ,A.[idDatabases]
	  ,COUNT(A.[idDatabases]) AS 'Acesso'
      ,CONVERT(DATE,[query_start],11) AS 'Data'
  FROM [SGBD].[MtPgControlAccess]A
  INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idDatabases = A.idDatabases
  GROUP BY A.[idSGBD],A.[idDatabases],CONVERT(DATE,[query_start],11)

UNION ALL

SELECT [idSGBD]
      ,[idDatabases]
	  ,COUNT([idDatabases]) AS 'Acesso'
      ,CONVERT(DATE,[LOGON_TIME],11) AS 'Data'
 FROM [SGBD].[MtOracleControlAccess] 
 GROUP BY [idSGBD],[idDatabases],CONVERT(DATE,[LOGON_TIME],11)



GO
/****** Object:  View [SGBD].[SGBDServidorProd]    Script Date: 27/10/2021 16:48:49 ******/
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
		WHEN ([Cluster]  = 0 ) AND [Estancia] = '' AND [SGBD] <> 'SQL Server' THEN ([HostName] +'\'+ [SGBD]) 
		WHEN ([Cluster]  = 0 ) AND ([SGBD] = 'SQL Server') THEN ([HostName])			
		END )AS 'Servidor'
      ,UPPER(SH.HostName) as 'HostName'
      ,[Estancia]
      ,[SGBD]
      ,S.IP AS IP
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
/****** Object:  View [SGBD].[SGBDDatabasesProd]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [SGBD].[SGBDDatabasesProd]
AS
SELECT DB.[idDatabases]
      ,DB.[idSGBD]
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
  LEFT JOIN (SELECT [idSGBD],[idDatabases],MAX([DataTimer]) AS 'DataTimer' 
               FROM [SGBD].[MtDbSize]
				GROUP BY [idSGBD] ,[idDatabases]) AS ST ON ST.idSGBD = DB.idSGBD AND ST.idDatabases = DB.idDatabases
  LEFT JOIN [SGBD].[MtDbSize] AS SZ ON SZ.idSGBD = DB.idSGBD AND SZ.idDatabases = DB.idDatabases AND SZ.DataTimer = ST.DataTimer
  WHERE DB.ativo = 1
--  ORDER BY [BasedeDados]
--    AND DB.OnlineOffline = 'ONLINE'

GO
/****** Object:  UserDefinedFunction [Rotineira].[F_DesempenhoDBcrescimentoDiv]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Rotineira].[F_DesempenhoDBcrescimentoDiv](@DataExecucaoDT DATETIME)
RETURNS TABLE
AS
RETURN(
		SELECT B.Servidor	
				,B.BasedeDados
				, CASE 
				WHEN [db_size] IS NULL THEN 0
				ELSE [db_size] END AS 'Tamanho'
				, CASE 
					WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
					THEN LAG([db_size], 1, null) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					ELSE 0
				END AS 'ValorAnterior'
				, CASE 
					WHEN B.Servidor = LAG(B.Servidor, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))
					AND B.BasedeDados = LAG(B.BasedeDados, 1) OVER (ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111))		  
					THEN ROUND([db_size] - LAG([db_size], 1)OVER(ORDER BY [Servidor], [BasedeDados], CONVERT([varchar], C.[DataTimer], 111)),2) 
					ELSE 0 --ROUND([db_size],2) 
				END AS 'ValorDiferencia'
			,CONVERT([varchar], C.[DataTimer], 111) AS 'Periodo'
			,B.SGBD
			FROM [SGBD].[MtDbSize] AS C
		INNER JOIN [SGBD].[SGBDEstDB] AS B ON B.idSGBD = C.idSGBD AND B.[idDatabases] = C.[idDatabases] 
		WHERE C.[DataTimer] >= @DataExecucaoDT
			AND C.[DataTimer] <= GETDATE()
		AND B.Descricao = 'Produção'
		AND (B.BasedeDados <> 'master'
			AND B.BasedeDados <> 'model'
			AND B.BasedeDados <> 'msdb'
			AND B.BasedeDados <> 'tempdb'
			AND B.BasedeDados <> 'postgres'
			AND B.BasedeDados <> 'mysql'
			AND B.BasedeDados <> 'information_schema'
			AND B.BasedeDados <> 'performance_schema'
			AND B.BasedeDados NOT LIKE 'Report%')
		);
GO
/****** Object:  Table [SGBD].[IvPgDatabasePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[IvPgDatabasePrivileges](
	[idIvPgDatabasePrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idIvPgRoles] [int] NOT NULL,
	[CONNECT_A] [bit] NULL,
	[CREATE_A] [bit] NULL,
	[TEMPORARY_A] [bit] NULL,
	[TEMP_A] [bit] NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK_idIvPgDatabasePrivilege] PRIMARY KEY CLUSTERED 
(
	[idIvPgDatabasePrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [SGBD].[VW_IvPgDatabasePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [SGBD].[VW_IvPgDatabasePrivileges]
AS
SELECT [idIvPgDatabasePrivileges]
      ,U.idSGBD
      ,D.[idDatabases]
      ,D.[idIvPgRoles]
	  ,U.rolname
	  ,CAST(CAST(U.idSGBD AS VARCHAR(20)) + CAST(D.[idIvPgRoles] AS VARCHAR(20)) AS FLOAT) 'user_oid'
      ,[CONNECT_A]
      ,[CREATE_A]
      ,[TEMPORARY_A]
      ,[TEMP_A]
      ,[dataupdate]
  FROM [SGBD].[IvPgDatabasePrivileges]  D
  INNER JOIN [SGBD].[VW_IvPgRolesUser]  U ON U.[idIvPgRoles] = D.[idIvPgRoles]

GO
/****** Object:  Table [app].[aplicacoes]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[aplicacoes](
	[idaplicacoes] [int] IDENTITY(1,1) NOT NULL,
	[IdServerHost] [int] NOT NULL,
	[IdTrilha] [int] NOT NULL,
	[AppName] [varchar](60) NULL,
	[Descricao] [varchar](max) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK_idaplicacoes] PRIMARY KEY CLUSTERED 
(
	[idaplicacoes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [app].[aplicacoesUrl]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[aplicacoesUrl](
	[idaplicacoesUrl] [int] IDENTITY(1,1) NOT NULL,
	[idaplicacoes] [int] NOT NULL,
	[UrlName] [varchar](max) NULL,
	[Trilha] [varchar](50) NULL,
	[IPaddress] [varchar](50) NULL,
	[PortConect] [varchar](10) NULL,
	[Descricao] [varchar](max) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK_idaplicacoesUrl] PRIMARY KEY CLUSTERED 
(
	[idaplicacoesUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Trilha]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Trilha](
	[idTrilha] [int] IDENTITY(1,1) NOT NULL,
	[Trilha] [nvarchar](15) NULL,
 CONSTRAINT [PK_Trilha] PRIMARY KEY CLUSTERED 
(
	[idTrilha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Rotineira].[BackupMySQLQuadroDetalhado]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Rotineira].[BackupMySQLQuadroDetalhado](
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
/****** Object:  Table [Rotineira].[BackupPgSQLQuadroDetalhado]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Rotineira].[BackupPgSQLQuadroDetalhado](
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
/****** Object:  Table [Rotineira].[BackupsMsMonitorMes]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Rotineira].[BackupsMsMonitorMes](
	[idSGBD] [int] NOT NULL,
	[Servidor] [varchar](8000) NULL,
	[BasedeDados] [varchar](150) NULL,
	[DataExecucao] [nchar](10) NULL,
	[Tamanho] [real] NULL,
	[BACKUP] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[IvSQLPermissionDb]    Script Date: 27/10/2021 16:48:49 ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[IvSQLPermissionLogin]    Script Date: 27/10/2021 16:48:49 ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MnSQLBackupJanela]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MnSQLBackupJanela](
	[idMnSQLBackupJanela] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[startJanela] [time](7) NULL,
	[endJanela] [time](7) NULL,
	[dateStat] [datetime] NULL,
	[dateEnd] [datetime] NULL,
	[FreqMonday] [int] NULL,
	[FreqMondayTpBK] [nchar](10) NULL,
	[FreqTuesDay] [int] NULL,
	[FreqTuesDayTpBk] [nchar](10) NULL,
	[FreqWednesday] [int] NULL,
	[FreqWednesdayTpBk] [nchar](10) NULL,
	[FreqTrursday] [int] NULL,
	[FredTrursdayTpBk] [nchar](10) NULL,
	[FreqFriday] [int] NULL,
	[FreqFridayTpBk] [nchar](10) NULL,
	[FreqSaturday] [int] NULL,
	[FreqSaturdayTpBk] [nchar](10) NULL,
	[Sunday] [int] NULL,
	[SundayTpBk] [nchar](10) NULL,
 CONSTRAINT [PK__MnSQLBac__75A31E97679450C0] PRIMARY KEY CLUSTERED 
(
	[idMnSQLBackupJanela] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMyDbBackup]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMyDbBackup](
	[idMtMyDbBackup] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[backup_size] [real] NULL,
	[backup_start_date] [datetime] NULL,
	[backup_end_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtMyDbBackup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLColumnPrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLColumnPrivileges](
	[idMtMySQLColumnPrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableColumn] [int] NOT NULL,
	[GRANTEE] [varchar](50) NULL,
	[PRIVILEGE_TYPE] [varchar](30) NULL,
	[IS_GRANTABLE] [varchar](10) NULL,
	[dataupdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtMySQLColumnPrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLDatabasePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLDatabasePrivileges](
	[idMtMySQLDatabasePrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[GRANTEE] [varchar](50) NULL,
	[PRIVILEGE_TYPE] [varchar](30) NULL,
	[IS_GRANTABLE] [varchar](10) NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK_idMtMySQLDatabasePrivileges] PRIMARY KEY CLUSTERED 
(
	[idMtMySQLDatabasePrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLReplication]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLReplication](
	[idMtMySQLReplication] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[Master_Host] [varchar](65) NULL,
	[Master_User] [varchar](50) NULL,
	[Master_Port] [int] NULL,
	[Connect_Retry] [int] NULL,
	[Master_Log_File] [varchar](200) NULL,
	[Slave_IO_Running] [varchar](10) NULL,
	[Slave_SQL_Running] [varchar](10) NULL,
	[Read_Master_Log_Pos] [varchar](200) NULL,
	[Relay_Log_Pos] [float] NULL,
	[Exec_Master_Log_Pos] [float] NULL,
	[Relay_Log_Space] [float] NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtMySQLR__BF0CAB1F7A96C33D] PRIMARY KEY CLUSTERED 
(
	[idMtMySQLReplication] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLTableIndexStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLTableIndexStat](
	[idSGBDTMySQLTableIndexStat] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableIndex] [int] NOT NULL,
	[INDEX_ID] [bigint] NULL,
	[page_no] [bigint] NULL,
	[n_recs] [bigint] NULL,
	[data_size] [bigint] NULL,
	[hashed] [bigint] NULL,
	[access_time] [bigint] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDTMySQLTableIndexStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLTablePrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLTablePrivileges](
	[idMtMySQLTablePrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[GRANTEE] [varchar](50) NULL,
	[PRIVILEGE_TYPE] [varchar](30) NULL,
	[IS_GRANTABLE] [varchar](10) NULL,
	[dataupdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtMySQLTablePrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtMySQLUserPrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtMySQLUserPrivileges](
	[idMtMySQLUserPrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[GRANTEE] [nvarchar](128) NULL,
	[PRIVILEGE_TYPE] [nvarchar](128) NULL,
	[IS_GRANTABLE] [nvarchar](10) NULL,
	[dataupdate] [datetime] NULL,
 CONSTRAINT [PK_idMtMySQLUserPrivileges] PRIMARY KEY CLUSTERED 
(
	[idMtMySQLUserPrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtOracleTableStat]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtOracleTableStat](
	[idMtOracleTableStat] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTable] [int] NOT NULL,
	[BLOCKS] [int] NULL,
	[EMPTY_BLOCKS] [int] NULL,
	[NUM_ROWS] [int] NULL,
	[ALLCATED_Size] [int] NULL,
	[FRAG] [int] NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtOracleTableStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtPgDbBackup]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgDbBackup](
	[idMtPgDbBackup] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
	[no_encoding_collate] [varchar](50) NULL,
	[backup_start_date] [datetime] NULL,
	[backup_end_date] [datetime] NULL,
	[ds_dir] [varchar](100) NULL,
	[st_type] [varchar](20) NULL,
	[st_size] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtPgDbBackup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtPgReplicationDelayTime]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgReplicationDelayTime](
	[idMtPgReplicationdelayTime] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[replication_delay] [real] NOT NULL,
	[EventTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtPgReplicationdelayTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtPgTableColumnPrivileges]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtPgTableColumnPrivileges](
	[idSGBDPgTableColumnPrivileges] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDTableColumn] [int] NOT NULL,
	[grantee] [nvarchar](50) NULL,
	[privilege_type] [nvarchar](20) NULL,
	[is_grantable] [nvarchar](5) NULL,
	[UpdateDataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idSGBDPgTableColumnPrivileges] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtSQLCPU]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLCPU](
	[idMtSQLCPU] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[SQLServerProcessCPUUtilization] [int] NULL,
	[SystemIdleProcess] [int] NULL,
	[OtherProcessCPUUtilization] [int] NULL,
	[EventTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtSQLCPU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtSQLDbBackup]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLDbBackup](
	[idMtSQLDbBackup] [int] IDENTITY(1,1) NOT NULL,
	[idDatabases] [int] NOT NULL,
	[idSGBD] [int] NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtSQLDisk]    Script Date: 27/10/2021 16:48:49 ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtSQLMemoriaBuffeDB]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtSQLMemoriaBuffeDB](
	[idMtSQLMemoriaBuffeDB] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[DatabaseName] [varchar](200) NULL,
	[CachedSizeMB] [real] NULL,
	[DataTimer] [datetime] NULL,
 CONSTRAINT [PK__MtSQLMem__044DCC69756D6ECB] PRIMARY KEY CLUSTERED 
(
	[idMtSQLMemoriaBuffeDB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[MtUserConnect]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[MtUserConnect](
	[idMtUserConnect] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[Login] [varchar](128) NULL,
	[session_count] [int] NULL,
	[DataTimer] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[idMtUserConnect] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[SGBDBackupDir]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDBackupDir](
	[idSGBDBackupDir] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDBackupJanela] [int] NOT NULL,
	[DirToBackup] [varchar](max) NULL,
	[ExtFile] [varchar](3) NULL,
	[ativo] [bit] NULL,
 CONSTRAINT [PK_idSGBDBackupJanelaConfig ] PRIMARY KEY CLUSTERED 
(
	[idSGBDBackupDir] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[SGBDBackupJanela]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDBackupJanela](
	[idSGBDBackupJanela] [int] IDENTITY(1,1) NOT NULL,
	[idSGBD] [int] NOT NULL,
	[idToolsBackup] [int] NOT NULL,
	[idTipoOcorrencia] [int] NOT NULL,
	[startJanela] [time](7) NULL,
	[endJanela] [time](7) NULL,
	[dateStat] [datetime] NULL,
	[dateEnd] [datetime] NULL,
	[outrasConfig] [nvarchar](max) NULL,
	[Ativo] [bit] NULL,
 CONSTRAINT [PK_idMnBackupJanela] PRIMARY KEY CLUSTERED 
(
	[idSGBDBackupJanela] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[SGBDBackupOCorrencia]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[SGBDBackupOCorrencia](
	[idSGBDBackupOCorrencia] [int] IDENTITY(1,1) NOT NULL,
	[idSGBDBackupJanela] [int] NOT NULL,
	[FreqMonday] [int] NULL,
	[FreqMondayTpBK] [nchar](10) NULL,
	[FreqTuesDay] [int] NULL,
	[FreqTuesDayTpBk] [nchar](10) NULL,
	[FreqWednesday] [int] NULL,
	[FreqWednesdayTpBk] [nchar](10) NULL,
	[FreqTrursday] [int] NULL,
	[FredTrursdayTpBk] [nchar](10) NULL,
	[FreqFriday] [int] NULL,
	[FreqFridayTpBk] [nchar](10) NULL,
	[FreqSaturday] [int] NULL,
	[FreqSaturdayTpBk] [nchar](10) NULL,
	[Sunday] [int] NULL,
	[SundayTpBk] [nchar](10) NULL,
 CONSTRAINT [PK_idSGBDBackupOCorrencia] PRIMARY KEY CLUSTERED 
(
	[idSGBDBackupOCorrencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[TipoOcorrencia]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[TipoOcorrencia](
	[idTipoOcorrencia] [int] IDENTITY(1,1) NOT NULL,
	[Descricao] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_idTipoOcorrencia] PRIMARY KEY CLUSTERED 
(
	[idTipoOcorrencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SGBD].[ToolsBackup]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SGBD].[ToolsBackup](
	[idToolsBackup] [int] IDENTITY(1,1) NOT NULL,
	[Descricao] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_idToolsBackup] PRIMARY KEY CLUSTERED 
(
	[idToolsBackup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Zabbix].[HostCPU]    Script Date: 27/10/2021 16:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Zabbix].[HostCPU](
	[idHostCPU] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[Componente] [varchar](50) NULL,
	[Tipo] [varchar](50) NULL,
	[Dia] [varchar](10) NULL,
	[Hora] [time](7) NULL,
	[Valor] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[idHostCPU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Zabbix].[HostMemory]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Zabbix].[HostMemory](
	[idHostMemory] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[Componente] [varchar](50) NULL,
	[Tipo] [varchar](50) NULL,
	[Dia] [varchar](10) NULL,
	[Hora] [time](7) NULL,
	[Valor] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[idHostMemory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Zabbix].[HostNetWork]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Zabbix].[HostNetWork](
	[idHostNetWork] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[Componente] [varchar](50) NULL,
	[Tipo] [varchar](50) NULL,
	[Dia] [varchar](10) NULL,
	[Hora] [time](7) NULL,
	[Valor] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[idHostNetWork] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Zabbix].[HostSWAP]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Zabbix].[HostSWAP](
	[idHostSWAP] [int] IDENTITY(1,1) NOT NULL,
	[idServerHost] [int] NOT NULL,
	[Componente] [varchar](50) NULL,
	[Tipo] [varchar](50) NULL,
	[Dia] [varchar](10) NULL,
	[Hora] [time](7) NULL,
	[Valor] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[idHostSWAP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [app].[aplicacoes] ADD  CONSTRAINT [DF__aplicacoe__Ativo__1D114BD1]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [app].[aplicacoesUrl] ADD  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [ServerHost].[ServerHost] ADD  CONSTRAINT [DF_ServerHost_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[IvPgDatabasePrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[IvPgRoles] ADD  CONSTRAINT [IvPgRoles_Ativo]  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [SGBD].[IvPgRolesMembers] ADD  CONSTRAINT [IvPgRolesMembersAtivo]  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [SGBD].[IvPgSchemaPrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb] ADD  CONSTRAINT [DF_IvSQLPermissionDb_StatusPermission]  DEFAULT ((1)) FOR [StatusPermission]
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin] ADD  CONSTRAINT [DF_IvSQLPermissionLogin_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqM__7211DF33]  DEFAULT ((1)) FOR [FreqMonday]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqT__7306036C]  DEFAULT ((1)) FOR [FreqTuesDay]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqW__73FA27A5]  DEFAULT ((1)) FOR [FreqWednesday]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqT__74EE4BDE]  DEFAULT ((1)) FOR [FreqTrursday]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqF__75E27017]  DEFAULT ((1)) FOR [FreqFriday]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__FreqS__76D69450]  DEFAULT ((1)) FOR [FreqSaturday]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] ADD  CONSTRAINT [DF__MnSQLBack__Sunda__77CAB889]  DEFAULT ((1)) FOR [Sunday]
GO
ALTER TABLE [SGBD].[MtDbSize] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtMySQLColumnPrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[MtMySQLControlAccess] ADD  CONSTRAINT [DF__MtMySQLCo__DataT__05D8E0BE]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtMySQLDatabasePrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[MtMySQLReplication] ADD  CONSTRAINT [DF__MtMySQLRe__DataT__2E90DD8E]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtMySQLTableIndexStat] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtMySQLTablePrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[MtMySQLUserPrivileges] ADD  DEFAULT (getdate()) FOR [dataupdate]
GO
ALTER TABLE [SGBD].[MtOracleControlAccess] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtOracleTableStat] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtPgReplicationDelayTime] ADD  DEFAULT (getdate()) FOR [EventTime]
GO
ALTER TABLE [SGBD].[MtPgTableColumnPrivileges] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtPgTableIndexStat] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtPgTablePrivileges] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtPgTableStat] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[MtSQLCPU] ADD  DEFAULT (getdate()) FOR [EventTime]
GO
ALTER TABLE [SGBD].[MtSQLDisk] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtSQLMemoriaBuffeDB] ADD  CONSTRAINT [DF__MtSQLMemo__DataT__7755B73D]  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [SGBD].[MtSQLTableIndexUser] ADD  DEFAULT (getdate()) FOR [UpdateDataTimer]
GO
ALTER TABLE [SGBD].[SGBD] ADD  CONSTRAINT [DF_SGBD_Cluster]  DEFAULT ((0)) FOR [Cluster]
GO
ALTER TABLE [SGBD].[SGBD] ADD  CONSTRAINT [DF_SGBD_Ativo]  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[SGBDBackupDir] ADD  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [SGBD].[SGBDBackupJanela] ADD  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqMonday]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqTuesDay]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqWednesday]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqTrursday]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqFriday]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [FreqSaturday]
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia] ADD  DEFAULT ((0)) FOR [Sunday]
GO
ALTER TABLE [SGBD].[SGBDDatabases] ADD  CONSTRAINT [DF_SGBDDatabases_ativo]  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [app].[aplicacoes]  WITH CHECK ADD  CONSTRAINT [FK_aplicacoes_ServerHost] FOREIGN KEY([IdServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [app].[aplicacoes] CHECK CONSTRAINT [FK_aplicacoes_ServerHost]
GO
ALTER TABLE [app].[aplicacoes]  WITH CHECK ADD  CONSTRAINT [FK_aplicacoes_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
ALTER TABLE [app].[aplicacoes] CHECK CONSTRAINT [FK_aplicacoes_Trilha]
GO
ALTER TABLE [app].[aplicacoesUrl]  WITH CHECK ADD  CONSTRAINT [FK_aplicacoes_aplicacoesUrl] FOREIGN KEY([idaplicacoes])
REFERENCES [app].[aplicacoes] ([idaplicacoes])
GO
ALTER TABLE [app].[aplicacoesUrl] CHECK CONSTRAINT [FK_aplicacoes_aplicacoesUrl]
GO
ALTER TABLE [ServerHost].[ServerHost]  WITH CHECK ADD  CONSTRAINT [FK_ServerHost_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
ALTER TABLE [ServerHost].[ServerHost] CHECK CONSTRAINT [FK_ServerHost_Trilha]
GO
ALTER TABLE [SGBD].[IvPgDatabasePrivileges]  WITH CHECK ADD  CONSTRAINT [FK__IvPgDatab__idDat__04459E07] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvPgDatabasePrivileges] CHECK CONSTRAINT [FK__IvPgDatab__idDat__04459E07]
GO
ALTER TABLE [SGBD].[IvPgDatabasePrivileges]  WITH CHECK ADD FOREIGN KEY([idIvPgRoles])
REFERENCES [SGBD].[IvPgRoles] ([idIvPgRoles])
GO
ALTER TABLE [SGBD].[IvPgRoles]  WITH CHECK ADD  CONSTRAINT [FK__IvPgRoles__idSGB__2610A626] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvPgRoles] CHECK CONSTRAINT [FK__IvPgRoles__idSGB__2610A626]
GO
ALTER TABLE [SGBD].[IvPgRolesMembers]  WITH CHECK ADD  CONSTRAINT [FK__IvPgRoles__idSGB__0BE6BFCF] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvPgRolesMembers] CHECK CONSTRAINT [FK__IvPgRoles__idSGB__0BE6BFCF]
GO
ALTER TABLE [SGBD].[IvPgRolesMembers]  WITH CHECK ADD  CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles3] FOREIGN KEY([roleid])
REFERENCES [SGBD].[IvPgRoles] ([idIvPgRoles])
GO
ALTER TABLE [SGBD].[IvPgRolesMembers] CHECK CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles3]
GO
ALTER TABLE [SGBD].[IvPgRolesMembers]  WITH CHECK ADD  CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles4] FOREIGN KEY([member])
REFERENCES [SGBD].[IvPgRoles] ([idIvPgRoles])
GO
ALTER TABLE [SGBD].[IvPgRolesMembers] CHECK CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles4]
GO
ALTER TABLE [SGBD].[IvPgRolesMembers]  WITH CHECK ADD  CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles5] FOREIGN KEY([grantor])
REFERENCES [SGBD].[IvPgRoles] ([idIvPgRoles])
GO
ALTER TABLE [SGBD].[IvPgRolesMembers] CHECK CONSTRAINT [FK_IvPgRolesMembers_IvPgRoles5]
GO
ALTER TABLE [SGBD].[IvPgSchemaPrivileges]  WITH CHECK ADD  CONSTRAINT [FK__IvPgSchem__idDat__78D3EB5B] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvPgSchemaPrivileges] CHECK CONSTRAINT [FK__IvPgSchem__idDat__78D3EB5B]
GO
ALTER TABLE [SGBD].[IvPgSchemaPrivileges]  WITH CHECK ADD FOREIGN KEY([idIvPgRoles])
REFERENCES [SGBD].[IvPgRoles] ([idIvPgRoles])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idDat__1EA48E88] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb] CHECK CONSTRAINT [FK__IvSQLPerm__idDat__1EA48E88]
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD FOREIGN KEY([idIvSQLPermissionLogin])
REFERENCES [SGBD].[IvSQLPermissionLogin] ([idIvSQLPermissionLogin])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idSGB__367C1819] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvSQLPermissionDb] CHECK CONSTRAINT [FK__IvSQLPerm__idSGB__367C1819]
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idDat__2180FB33] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin] CHECK CONSTRAINT [FK__IvSQLPerm__idDat__2180FB33]
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin]  WITH CHECK ADD  CONSTRAINT [FK__IvSQLPerm__idSGB__1EA48E88] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[IvSQLPermissionLogin] CHECK CONSTRAINT [FK__IvSQLPerm__idSGB__1EA48E88]
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela]  WITH CHECK ADD  CONSTRAINT [FK__MnSQLBack__idSGB__697C9932] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MnSQLBackupJanela] CHECK CONSTRAINT [FK__MnSQLBack__idSGB__697C9932]
GO
ALTER TABLE [SGBD].[MtDbSize]  WITH CHECK ADD  CONSTRAINT [FK__MtDbSize__idData__245D67DE] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtDbSize] CHECK CONSTRAINT [FK__MtDbSize__idData__245D67DE]
GO
ALTER TABLE [SGBD].[MtDbSize]  WITH CHECK ADD  CONSTRAINT [FK__MtDbSize__idSGBD__7A672E12] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtDbSize] CHECK CONSTRAINT [FK__MtDbSize__idSGBD__7A672E12]
GO
ALTER TABLE [SGBD].[MtMyDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtMyDbBac__idDat__2645B050] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtMyDbBackup] CHECK CONSTRAINT [FK__MtMyDbBac__idDat__2645B050]
GO
ALTER TABLE [SGBD].[MtMyDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtMyDbBac__idSGB__0B91BA14] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtMyDbBackup] CHECK CONSTRAINT [FK__MtMyDbBac__idSGB__0B91BA14]
GO
ALTER TABLE [SGBD].[MtMySQLColumnPrivileges]  WITH CHECK ADD FOREIGN KEY([idSGBDTableColumn])
REFERENCES [SGBD].[SGBDTableColumn] ([idSGBDTableColumn])
GO
ALTER TABLE [SGBD].[MtMySQLColumnPrivileges]  WITH CHECK ADD FOREIGN KEY([idSGBDTableColumn])
REFERENCES [SGBD].[SGBDTableColumn] ([idSGBDTableColumn])
GO
ALTER TABLE [SGBD].[MtMySQLControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtMySQLCo__idDat__07C12930] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtMySQLControlAccess] CHECK CONSTRAINT [FK__MtMySQLCo__idDat__07C12930]
GO
ALTER TABLE [SGBD].[MtMySQLControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtMySQLCo__idSGB__06CD04F7] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtMySQLControlAccess] CHECK CONSTRAINT [FK__MtMySQLCo__idSGB__06CD04F7]
GO
ALTER TABLE [SGBD].[MtMySQLDatabasePrivileges]  WITH CHECK ADD  CONSTRAINT [FK__MtMySQLDa__idDat__1209AD79] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtMySQLDatabasePrivileges] CHECK CONSTRAINT [FK__MtMySQLDa__idDat__1209AD79]
GO
ALTER TABLE [SGBD].[MtMySQLReplication]  WITH CHECK ADD  CONSTRAINT [FK__MtMySQLRe__idSGB__2F8501C7] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtMySQLReplication] CHECK CONSTRAINT [FK__MtMySQLRe__idSGB__2F8501C7]
GO
ALTER TABLE [SGBD].[MtMySQLTableIndexStat]  WITH CHECK ADD FOREIGN KEY([idSGBDTableIndex])
REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
GO
ALTER TABLE [SGBD].[MtMySQLTablePrivileges]  WITH CHECK ADD FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[MtMySQLUserPrivileges]  WITH CHECK ADD  CONSTRAINT [FK__MtMySQLUs__idSGB__04AFB25B] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtMySQLUserPrivileges] CHECK CONSTRAINT [FK__MtMySQLUs__idSGB__04AFB25B]
GO
ALTER TABLE [SGBD].[MtOracleControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtOracleC__idDat__1E3A7A34] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtOracleControlAccess] CHECK CONSTRAINT [FK__MtOracleC__idDat__1E3A7A34]
GO
ALTER TABLE [SGBD].[MtOracleControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtOracleC__idSGB__1F2E9E6D] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtOracleControlAccess] CHECK CONSTRAINT [FK__MtOracleC__idSGB__1F2E9E6D]
GO
ALTER TABLE [SGBD].[MtOracleTableStat]  WITH CHECK ADD FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[MtPgControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtPgContr__idDat__2B0A656D] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtPgControlAccess] CHECK CONSTRAINT [FK__MtPgContr__idDat__2B0A656D]
GO
ALTER TABLE [SGBD].[MtPgControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtPgContr__idSGB__10566F31] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtPgControlAccess] CHECK CONSTRAINT [FK__MtPgContr__idSGB__10566F31]
GO
ALTER TABLE [SGBD].[MtPgDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtPgDbBac__idDat__2CF2ADDF] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtPgDbBackup] CHECK CONSTRAINT [FK__MtPgDbBac__idDat__2CF2ADDF]
GO
ALTER TABLE [SGBD].[MtPgDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtPgDbBac__idSGB__123EB7A3] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtPgDbBackup] CHECK CONSTRAINT [FK__MtPgDbBac__idSGB__123EB7A3]
GO
ALTER TABLE [SGBD].[MtPgReplicationDelayTime]  WITH CHECK ADD  CONSTRAINT [FK__MtPgRepli__idSGB__1332DBDC] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtPgReplicationDelayTime] CHECK CONSTRAINT [FK__MtPgRepli__idSGB__1332DBDC]
GO
ALTER TABLE [SGBD].[MtPgTableColumnPrivileges]  WITH CHECK ADD FOREIGN KEY([idSGBDTableColumn])
REFERENCES [SGBD].[SGBDTableColumn] ([idSGBDTableColumn])
GO
ALTER TABLE [SGBD].[MtPgTableIndexStat]  WITH CHECK ADD FOREIGN KEY([idSGBDTableIndex])
REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
GO
ALTER TABLE [SGBD].[MtPgTablePrivileges]  WITH CHECK ADD FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[MtPgTableStat]  WITH CHECK ADD FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[MtPgTableStat]  WITH CHECK ADD FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[MtSQLControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLCont__idDat__2FCF1A8A] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtSQLControlAccess] CHECK CONSTRAINT [FK__MtSQLCont__idDat__2FCF1A8A]
GO
ALTER TABLE [SGBD].[MtSQLControlAccess]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLCont__idSGB__7DCDAAA2] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLControlAccess] CHECK CONSTRAINT [FK__MtSQLCont__idSGB__7DCDAAA2]
GO
ALTER TABLE [SGBD].[MtSQLCPU]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLCPU__idSGBD__6CD828CA] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLCPU] CHECK CONSTRAINT [FK__MtSQLCPU__idSGBD__6CD828CA]
GO
ALTER TABLE [SGBD].[MtSQLDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLDbBa__idDat__32AB8735] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[MtSQLDbBackup] CHECK CONSTRAINT [FK__MtSQLDbBa__idDat__32AB8735]
GO
ALTER TABLE [SGBD].[MtSQLDbBackup]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLDbBa__idSGB__1332DBDC] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLDbBackup] CHECK CONSTRAINT [FK__MtSQLDbBa__idSGB__1332DBDC]
GO
ALTER TABLE [SGBD].[MtSQLDisk]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLDisk__idSGB__7E02B4CC] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLDisk] CHECK CONSTRAINT [FK__MtSQLDisk__idSGB__7E02B4CC]
GO
ALTER TABLE [SGBD].[MtSQLMemoriaBuffeDB]  WITH CHECK ADD  CONSTRAINT [FK__MtSQLMemo__idSGB__7849DB76] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtSQLMemoriaBuffeDB] CHECK CONSTRAINT [FK__MtSQLMemo__idSGB__7849DB76]
GO
ALTER TABLE [SGBD].[MtSQLTableIndexUser]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTableIndexUser__idDat__32AB8735] FOREIGN KEY([idSGBDTableIndex])
REFERENCES [SGBD].[SGBDTableIndex] ([idSGBDTableIndex])
GO
ALTER TABLE [SGBD].[MtSQLTableIndexUser] CHECK CONSTRAINT [FK__SGBDTableIndexUser__idDat__32AB8735]
GO
ALTER TABLE [SGBD].[MtUserConnect]  WITH CHECK ADD  CONSTRAINT [FK_MtUserConnect_SGBD] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[MtUserConnect] CHECK CONSTRAINT [FK_MtUserConnect_SGBD]
GO
ALTER TABLE [SGBD].[SGBD]  WITH CHECK ADD  CONSTRAINT [FK__SGBD__idServerHo__1A14E395] FOREIGN KEY([idServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [SGBD].[SGBD] CHECK CONSTRAINT [FK__SGBD__idServerHo__1A14E395]
GO
ALTER TABLE [SGBD].[SGBD]  WITH CHECK ADD  CONSTRAINT [FK_SGBD_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
ALTER TABLE [SGBD].[SGBD] CHECK CONSTRAINT [FK_SGBD_Trilha]
GO
ALTER TABLE [SGBD].[SGBDBackupDir]  WITH CHECK ADD FOREIGN KEY([idSGBDBackupJanela])
REFERENCES [SGBD].[SGBDBackupJanela] ([idSGBDBackupJanela])
GO
ALTER TABLE [SGBD].[SGBDBackupJanela]  WITH CHECK ADD  CONSTRAINT [FK__SGBDBacku__idSGB__2D12A970] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[SGBDBackupJanela] CHECK CONSTRAINT [FK__SGBDBacku__idSGB__2D12A970]
GO
ALTER TABLE [SGBD].[SGBDBackupJanela]  WITH CHECK ADD FOREIGN KEY([idTipoOcorrencia])
REFERENCES [SGBD].[TipoOcorrencia] ([idTipoOcorrencia])
GO
ALTER TABLE [SGBD].[SGBDBackupJanela]  WITH CHECK ADD FOREIGN KEY([idToolsBackup])
REFERENCES [SGBD].[ToolsBackup] ([idToolsBackup])
GO
ALTER TABLE [SGBD].[SGBDBackupOCorrencia]  WITH CHECK ADD FOREIGN KEY([idSGBDBackupJanela])
REFERENCES [SGBD].[SGBDBackupJanela] ([idSGBDBackupJanela])
GO
ALTER TABLE [SGBD].[SGBDDatabases]  WITH CHECK ADD  CONSTRAINT [FK__SGBDDatab__idSGB__5629CD9C] FOREIGN KEY([idSGBD])
REFERENCES [SGBD].[SGBD] ([idSGBD])
GO
ALTER TABLE [SGBD].[SGBDDatabases] CHECK CONSTRAINT [FK__SGBDDatab__idSGB__5629CD9C]
GO
ALTER TABLE [SGBD].[SGBDDatabases]  WITH CHECK ADD  CONSTRAINT [FK_SGBDDatabases_Trilha] FOREIGN KEY([IdTrilha])
REFERENCES [dbo].[Trilha] ([idTrilha])
GO
ALTER TABLE [SGBD].[SGBDDatabases] CHECK CONSTRAINT [FK_SGBDDatabases_Trilha]
GO
ALTER TABLE [SGBD].[SGBDTable]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTable__idDat__32AB8735] FOREIGN KEY([idDatabases])
REFERENCES [SGBD].[SGBDDatabases] ([idDatabases])
GO
ALTER TABLE [SGBD].[SGBDTable] CHECK CONSTRAINT [FK__SGBDTable__idDat__32AB8735]
GO
ALTER TABLE [SGBD].[SGBDTableColumn]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTableColumn__idDat__32AB8735] FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[SGBDTableColumn] CHECK CONSTRAINT [FK__SGBDTableColumn__idDat__32AB8735]
GO
ALTER TABLE [SGBD].[SGBDTableIndex]  WITH CHECK ADD  CONSTRAINT [FK__SGBDTableIndex__idDat__32AB8735] FOREIGN KEY([idSGBDTable])
REFERENCES [SGBD].[SGBDTable] ([idSGBDTable])
GO
ALTER TABLE [SGBD].[SGBDTableIndex] CHECK CONSTRAINT [FK__SGBDTableIndex__idDat__32AB8735]
GO
ALTER TABLE [Zabbix].[HostCPU]  WITH CHECK ADD  CONSTRAINT [FK__HostCPU__idServe__2180FB33] FOREIGN KEY([idServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [Zabbix].[HostCPU] CHECK CONSTRAINT [FK__HostCPU__idServe__2180FB33]
GO
ALTER TABLE [Zabbix].[HostCPU]  WITH CHECK ADD  CONSTRAINT [FK__HostCPU__idServe__22751F6C] FOREIGN KEY([idServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [Zabbix].[HostCPU] CHECK CONSTRAINT [FK__HostCPU__idServe__22751F6C]
GO
ALTER TABLE [Zabbix].[HostSWAP]  WITH CHECK ADD  CONSTRAINT [FK__HostSWAP__idServ__236943A5] FOREIGN KEY([idServerHost])
REFERENCES [ServerHost].[ServerHost] ([idServerHost])
GO
ALTER TABLE [Zabbix].[HostSWAP] CHECK CONSTRAINT [FK__HostSWAP__idServ__236943A5]
GO
/****** Object:  StoredProcedure [dbo].[SP_CreateLinkServer_SQL]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CreateLinkServer_SQL](
@SGBDServer char(50),
@HostServer char(50),
@stringConnect char(30))
AS
declare @scriptcmd nchar(3000)
BEGIN

SET @scriptcmd ='
USE [master]
EXEC master.dbo.sp_addlinkedserver @server = N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @srvproduct=N'''+RTRIM(LTRIM(@HostServer))+''', @provider=N''SQLNCLI'', @datasrc=N'''+RTRIM(LTRIM(@stringConnect))+'''
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''',@useself=N''False'',@locallogin=NULL,@rmtuser=N''usrsm'',@rmtpassword=''k50pSYcBiTD1mU3GjhHvau1wLqpiYws1''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''collation compatible'', @optvalue=N''false''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''data access'', @optvalue=N''true''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''dist'', @optvalue=N''false''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''pub'', @optvalue=N''false''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''rpc'', @optvalue=N''true''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''rpc out'', @optvalue=N''true''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''sub'', @optvalue=N''false''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''connect timeout'', @optvalue=N''0''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''collation name'', @optvalue=null
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''lazy schema validation'', @optvalue=N''false''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''query timeout'', @optvalue=N''0''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''use remote collation'', @optvalue=N''true''
EXEC master.dbo.sp_serveroption @server=N''LNK_SQL'+RTRIM(LTRIM(@SGBDServer))+''', @optname=N''remote proc transaction promotion'', @optvalue=N''true'''

exec sp_executesql @scriptcmd
--PRINT RTRIM(LTRIM(@scriptcmd))

END
GO
/****** Object:  StoredProcedure [Rotineira].[SP_AtlBackupMsQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/**/
CREATE PROCEDURE [Rotineira].[SP_AtlBackupMsQuadroDetalhado]
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
		  FROM [Rotineira].[BackupsMsMonitorMes]

OPEN db_for 
FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao 

WHILE @@FETCH_STATUS = 0
BEGIN

		IF (@Backup = 1) -- O backup falhou
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''1''
								FROM [Rotineira].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
								
		END
			ELSE
		IF (@Backup = 2) -- O backup executou com falha
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''2''
								FROM [Rotineira].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END
			ELSE		
		IF (@Backup = 3) -- O backup executou com sucesso.
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''3''
								FROM [Rotineira].[BackupsMsQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	
			ELSE		
		IF (@Backup = 4) -- O backup nao executou ainda
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''4''
								FROM [Rotineira].[BackupsMsQuadroDetalhado] AS UP    
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
/****** Object:  StoredProcedure [Rotineira].[SP_AtlBackupMyQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/**/
CREATE PROCEDURE [Rotineira].[SP_AtlBackupMyQuadroDetalhado]
AS
DECLARE @Servidor    nchar(50)
DECLARE @BasedeDados  nchar(50)
DECLARE @Backup		 INT
DECLARE @DataExecucao nCHAR(2)
DECLARE @ScriptExec nchar(3000)
DECLARE @lError		 SMALLINT

DECLARE db_for CURSOR FOR

		SELECT Servidor
			  ,[BasedeDados]			  
			  ,[BACKUP]
			  ,LEFT([DataExecucao],2)
		  FROM [Report].[BackupsMySQLMonitorMesvf]

OPEN db_for 
FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao 

WHILE @@FETCH_STATUS = 0
BEGIN

		IF (@Backup = 1) -- O backup falhou
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''1''
								FROM [Rotineira].[BackupMySQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
								
		END
			ELSE
		IF (@Backup = 2) -- O backup executou com falha
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''2''
								FROM [Rotineira].[BackupMySQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END
			ELSE		
		IF (@Backup = 3) -- O backup executou com sucesso.
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''3''
								FROM [Rotineira].[BackupMySQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	
			ELSE		
		IF (@Backup = 4) -- O backup nao executou ainda
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''4''
								FROM [Rotineira].[BackupMySQLQuadroDetalhado] AS UP    
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
/****** Object:  StoredProcedure [Rotineira].[SP_AtlBackupPgQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [Rotineira].[SP_AtlBackupPgQuadroDetalhado]
AS
DECLARE @Servidor    nchar(50)
DECLARE @BasedeDados  nchar(50)
DECLARE @Backup		 INT
DECLARE @DataExecucao nCHAR(2)
DECLARE @ScriptExec nchar(3000)
DECLARE @lError		 SMALLINT

DECLARE db_for CURSOR FOR

		SELECT Servidor
			  ,[BasedeDados]			  
			  ,[BACKUP]
			  ,LEFT([DataExecucao],2)
		  FROM [Report].[BackupsPgSQLMonitorMesvf]

OPEN db_for 
FETCH NEXT FROM db_for INTO @Servidor ,@BasedeDados, @Backup ,@DataExecucao 

WHILE @@FETCH_STATUS = 0
BEGIN

		IF (@Backup = 1) -- O backup falhou
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''1''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
								
		END
			ELSE
		IF (@Backup = 2) -- O backup executou com falha
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''2''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END
			ELSE		
		IF (@Backup = 3) -- O backup executou com sucesso.
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''3''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
								WHERE [Servidor] = '+ ''''+RTRIM(@Servidor) +'''
								  AND [BasedeDados] = '+ ''''+RTRIM(@BasedeDados) +''''
		END	
			ELSE		
		IF (@Backup = 4) -- O backup nao executou ainda
		BEGIN
			SET @ScriptExec = 'UPDATE UP
								   SET UP.['+ @DataExecucao +'] = ''4''
								FROM [Rotineira].[BackupPgSQLQuadroDetalhado] AS UP    
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
/****** Object:  StoredProcedure [Rotineira].[SP_PrcBackupMsQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [Rotineira].[SP_PrcBackupMsQuadroDetalhado]
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
		
					IF OBJECT_ID(''[Rotineira].[BackupsMsQuadroDetalhado]'', ''U'') IS NOT NULL 
						DROP TABLE [Rotineira].[BackupsMsQuadroDetalhado]
		
		
						    SELECT Servidor
								, BasedeDados'
								+ @scritp1 +
							 'INTO Rotineira.BackupsMsQuadroDetalhado
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
/****** Object:  StoredProcedure [Rotineira].[SP_PrcBackupMyQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [Rotineira].[SP_PrcBackupMyQuadroDetalhado]
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
		
					IF OBJECT_ID(''[Rotineira].[BackupMySQLQuadroDetalhado]'', ''U'') IS NOT NULL 
						DROP TABLE [Rotineira].[BackupMySQLQuadroDetalhado]
		
		
						    SELECT Servidor
								, BasedeDados'
								+ @scritp1 +
							 'INTO Rotineira.BackupMySQLQuadroDetalhado
							  FROM (SELECT [Servidor]
										  ,[BasedeDados]
										  ,ROUND(SUM([Tamanho]),2) AS ''Tamanho''
										  ,[Dia]
									  FROM [Report].[BackupsMyMonitorMes]
									  GROUP BY [Servidor],[BasedeDados],[Dia]) AS A
							 PIVOT (SUM(A.Tamanho) FOR [Dia] IN('+ @scritp2 +')) AS B
							ORDER BY Servidor, BasedeDados'

		 EXEC sp_executesql @scritpExec







GO
/****** Object:  StoredProcedure [Rotineira].[SP_PrcBackupPgQuadroDetalhado]    Script Date: 27/10/2021 16:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [Rotineira].[SP_PrcBackupPgQuadroDetalhado]
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
		
					IF OBJECT_ID(''[Rotineira].[BackupPgSQLQuadroDetalhado]'', ''U'') IS NOT NULL 
						DROP TABLE [Rotineira].[BackupPgSQLQuadroDetalhado]
		
		
						    SELECT Servidor
								, BasedeDados'
								+ @scritp1 +
							 'INTO Rotineira.BackupPgSQLQuadroDetalhado
							  FROM (SELECT [Servidor]
										  ,[BasedeDados]
										  ,ROUND(SUM([Tamanho]),2) AS ''Tamanho''
										  ,[Dia]
									  FROM [Report].[BackupsPgMonitorMes]
									  GROUP BY [Servidor],[BasedeDados],[Dia]) AS A
							 PIVOT (SUM(A.Tamanho) FOR [Dia] IN('+ @scritp2 +')) AS B
							ORDER BY Servidor, BasedeDados'

		 EXEC sp_executesql @scritpExec





GO
