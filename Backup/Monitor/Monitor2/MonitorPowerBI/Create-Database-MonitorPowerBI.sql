USE [MonitorPowerBI]
GO
/****** Object:  User [sisetlpowerbi]    Script Date: 05/07/2021 11:20:46 ******/
CREATE USER [sisetlpowerbi] FOR LOGIN [sisetlpowerbi] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [sispowerbi]    Script Date: 05/07/2021 11:20:46 ******/
CREATE USER [sispowerbi] FOR LOGIN [sispowerbi] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [sisetlpowerbi]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [sisetlpowerbi]
GO
ALTER ROLE [db_datareader] ADD MEMBER [sispowerbi]
GO
/****** Object:  UserDefinedFunction [dbo].[F_DiaNumeroAno]    Script Date: 05/07/2021 11:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[F_DiaNumeroAno](@DtFinal DATETIME) RETURNS INT  AS
begin

DECLARE @Ano           INT = 2020 
DECLARE @DiaNumeroAno  INT
DECLARE @Cont          INT = 1
DECLARE @Total         INT 
DECLARE @DtInicial     DATE
--DECLARE @DtFinal       DATE = '2020-03-12'
DECLARE @@DiaNumeroAno INT

	/* Primeiro dia do ana */
	SET @DtInicial = CAST(CAST(YEAR(@DtFinal) AS CHAR(4)) +'-01-01' as DATE)

	/* Total de dias entre o primeiro dia e a data informada */
	SET @DiaNumeroAno     = DATEDIFF(DAY, @DtInicial, DATEADD(DAY,1,@DtFinal))


RETURN @DiaNumeroAno    -- 30/06/2011

end




GO
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNow24]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_HoraDiaNowZero]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesCh]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_PrimeiroDiaMesDT]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_SemanaNumeroAnao]    Script Date: 05/07/2021 11:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[F_SemanaNumeroAnao](@DtFinal DATETIME) RETURNS INT  AS
begin

DECLARE @DiaNumeroAno  INT
DECLARE @Cont          INT = 1
DECLARE @Total         INT 
DECLARE @DtInicial     DATE
DECLARE @SemanaNumeroAnao INT = 1
DECLARE @@DiaNumeroAno INT

	/* Primeiro dia do ana */
	SET @DtInicial = CAST(CAST(YEAR(@DtFinal) AS CHAR(4)) +'-01-01' as DATE)

	/* Total de dias entre o primeiro dia e a data informada */
	SET @DiaNumeroAno     = DATEDIFF(DAY, @DtInicial, DATEADD(DAY,1,@DtFinal))
	
	WHILE @Cont <= @DiaNumeroAno
	 BEGIN

		IF [MonitorGW].[dbo].[FDIA_SEMANA] (@DtInicial) = 7 
		 BEGIN
			SET @SemanaNumeroAnao = @SemanaNumeroAnao + 1
		 END

		 SELECT @DtInicial = DATEADD(DAY, 1, @DtInicial);

		 SET @Cont = @Cont + 1;
	 END



RETURN @SemanaNumeroAnao    -- 30/06/2011

end




GO
/****** Object:  UserDefinedFunction [dbo].[F_SemestreNr]    Script Date: 05/07/2021 11:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[F_SemestreNr](@DtFinal DATETIME) RETURNS INT  AS
begin

DECLARE @DiaNumeroAno  INT
DECLARE @Cont          INT = 1
DECLARE @Total         INT 
DECLARE @DtInicial     DATE
DECLARE @SemestreNr INT = 1
DECLARE @@DiaNumeroAno INT

	/* Primeiro dia do ana */
	SET @DtInicial = CAST(CAST(YEAR(@DtFinal) AS CHAR(4)) +'-01-01' as DATE)

	/* Total de dias entre o primeiro dia e a data informada */
	SET @DiaNumeroAno     = DATEDIFF(DAY, @DtInicial, DATEADD(DAY,1,@DtFinal))
	
	WHILE @Cont <= @DiaNumeroAno
	 BEGIN
	 
			IF MONTH(@Cont) = 7 AND @SemestreNr = 1
			 BEGIN
			   SET @SemestreNr = @SemestreNr + 1
			 END

		 SELECT @DtInicial = DATEADD(DAY, 1, @DtInicial);

		 SET @Cont = @Cont + 1;
	 END



RETURN @SemestreNr    -- 30/06/2011

end




GO
/****** Object:  UserDefinedFunction [dbo].[F_TrimestreNr]    Script Date: 05/07/2021 11:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[F_TrimestreNr](@DtFinal DATETIME) RETURNS INT  AS
begin

DECLARE @DiaNumeroAno  INT
DECLARE @Cont          INT = 1
DECLARE @Total         INT 
DECLARE @DtInicial     DATE
DECLARE @TrimestreNr INT = 1
DECLARE @@DiaNumeroAno INT

	/* Primeiro dia do ana */
	SET @DtInicial = CAST(CAST(YEAR(@DtFinal) AS CHAR(4)) +'-01-01' as DATE)

	/* Total de dias entre o primeiro dia e a data informada */
	SET @DiaNumeroAno     = DATEDIFF(DAY, @DtInicial, DATEADD(DAY,1,@DtFinal))
	
	WHILE @Cont <= @DiaNumeroAno
	 BEGIN
	 
			IF MONTH(@Cont) = 4 AND @TrimestreNr = 1
			 BEGIN
			   SET @TrimestreNr = @TrimestreNr + 1
			 END
			IF MONTH(@Cont) = 7 AND @TrimestreNr = 2
			 BEGIN
			   SET @TrimestreNr = @TrimestreNr + 1
			 END
			IF MONTH(@Cont) = 10 AND @TrimestreNr = 3 
			 BEGIN
			   SET @TrimestreNr = @TrimestreNr + 1
			 END

		 SELECT @DtInicial = DATEADD(DAY, 1, @DtInicial);

		 SET @Cont = @Cont + 1;
	 END



RETURN @TrimestreNr    -- 30/06/2011

end




GO
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesCh]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[F_UltimmoDiaMesDT]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[FDIA_SEMANA]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  UserDefinedFunction [dbo].[FMES_EXT]    Script Date: 05/07/2021 11:20:46 ******/
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
/****** Object:  Table [dbo].[Pasta]    Script Date: 05/07/2021 11:20:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pasta](
	[idPasta] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [nvarchar](40) NULL,
	[ParentID] [nvarchar](40) NULL,
	[Localizacao] [nvarchar](425) NULL,
	[Pasta] [nvarchar](425) NULL,
	[Tipo] [varchar](20) NULL,
	[DataDaCriacao] [datetime] NULL,
	[DataDaModificacao] [datetime] NULL,
	[UltimaVisualizacao] [datetime] NULL,
	[DiasSemAlteracao] [int] NULL,
	[idEstancia] [int] NULL,
	[Nivel] [int] NULL,
	[ativo] [bit] NULL,
	[teste] [int] NULL,
 CONSTRAINT [PK_idWorkSpace] PRIMARY KEY CLUSTERED 
(
	[idPasta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[VW_PastaRaiz]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PastaRaiz]
AS 

SELECT idEstancia
       ,[Pasta] as 'Pasta raiz'
  FROM [dbo].[Pasta]
WHERE [Nivel] = 2

GO
/****** Object:  Table [dbo].[Estancia]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Estancia](
	[idEstancia] [int] IDENTITY(1,1) NOT NULL,
	[Estancia] [nvarchar](55) NULL,
	[Descricao] [nvarchar](100) NULL,
	[URL] [text] NULL,
	[conexaobanco] [nvarchar](255) NULL,
	[Servidor] [nvarchar](30) NULL,
 CONSTRAINT [PK_Estancia] PRIMARY KEY CLUSTERED 
(
	[idEstancia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Painel]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Painel](
	[idObjeto] [int] IDENTITY(1,1) NOT NULL,
	[idPasta] [int] NOT NULL,
	[ItemID] [nvarchar](40) NULL,
	[ParentID] [nvarchar](40) NULL,
	[Localizacao] [nvarchar](425) NULL,
	[Objeto] [nvarchar](425) NULL,
	[Tipo] [varchar](20) NULL,
	[DataDaCriacao] [datetime] NULL,
	[DataDaModificacao] [datetime] NULL,
	[UltimaVisualizacao] [datetime] NULL,
	[DiasSemAlteracao] [int] NULL,
	[Tamanho] [float] NULL,
	[ativo] [bit] NULL,
	[CreatedByUserName] [nvarchar](260) NULL,
	[ModifiedByUserName] [nvarchar](260) NULL,
 CONSTRAINT [PK_idObjeto] PRIMARY KEY CLUSTERED 
(
	[idObjeto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Objeto]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Objeto]
as
SELECT [idObjeto]
      ,[idPasta]
      ,[ItemID]
      ,[ParentID]
      ,[Localizacao]
      ,[Objeto]
      ,[Tipo]
      ,[DataDaCriacao]
	  ,[CreatedByUserName]
      ,[DataDaModificacao]
	  ,[ModifiedByUserName]
      ,[UltimaVisualizacao]
      ,[DiasSemAlteracao]
      ,[Tamanho]   
	  ,[ativo]   
  FROM [dbo].[Painel]
  WHERE [ativo] = 1


GO
/****** Object:  Table [dbo].[Visualizacao]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visualizacao](
	[idVisualizacao] [int] IDENTITY(1,1) NOT NULL,
	[idObjeto] [int] NOT NULL,
	[ItemID] [nvarchar](40) NULL,
	[UserName] [nvarchar](260) NULL,
	[LoginName] [nvarchar](260) NULL,
	[Lotacao] [nvarchar](260) NULL,
	[RequestType] [nvarchar](26) NULL,
	[Format] [nvarchar](26) NULL,
	[ItemAction] [nvarchar](26) NULL,
	[TimeStart] [datetime] NULL,
	[TimeDataRetrieval] [int] NULL,
	[Source] [nvarchar](20) NULL,
	[Status] [nvarchar](40) NULL,
	[CountByte] [bigint] NULL,
	[CountRow] [bigint] NULL,
	[EventDate] [date] NULL,
	[EventTime] [time](7) NULL,
	[ExecutionId] [nvarchar](64) NULL,
 CONSTRAINT [PK_idVisualizacao] PRIMARY KEY CLUSTERED 
(
	[idVisualizacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[VW_Visualizacao_Quantitativo]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_Visualizacao_Quantitativo]
as
SELECT D.idEstancia
      ,COUNT([idVisualizacao]) AS 'TVisualizacao'
      ,ROUND(MIN([TimeDataRetrieval]),2) AS 'MinTransferencia'
	  ,ROUND(AVG([TimeDataRetrieval]),2) AS 'MedTransferencia'
	  ,ROUND(MAX([TimeDataRetrieval]),2) AS 'MaxTransferencia'
      ,ROUND(MIN([CountByte]),2) AS 'MinTransDados'
	  ,ROUND(AVG([CountByte]),2) AS 'MedTransDados'
	  ,ROUND(MAX([CountByte]),2) AS 'MaxTransDados'
     ,[EventDate]
  FROM [dbo].[Visualizacao]   AS A
  INNER JOIN [dbo].[Objeto]   AS B ON B.idObjeto = A.idObjeto
  INNER JOIN [dbo].[Pasta]    AS C ON C.idPasta = B.idPasta
  INNER JOIN [dbo].[Estancia] AS D ON D.idEstancia = C.idEstancia
WHERE [TimeStart] >= DATEADD(DAY, -30, GETDATE()) AND [TimeStart] <= GETDATE()
GROUP BY D.idEstancia,[EventDate]

GO
/****** Object:  View [dbo].[VW_VSTOP10]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_VSTOP10]
AS
SELECT
	   O.idObjeto
	 , O.[Objeto]
	 , T.TOTAL
  FROM [dbo].[Objeto] AS O
  INNER JOIN (SELECT TOP 10 [idObjeto], COUNT([idObjeto]) AS TOTAL
  FROM [dbo].[Visualizacao] AS A
  WHERE A.[TimeStart] >= [dbo].[F_HoraDiaNowZero](GETDATE())
  GROUP BY [idObjeto] ORDER BY COUNT([idObjeto]) DESC) AS T ON T.idObjeto = O.idObjeto

GO
/****** Object:  View [dbo].[VC_VS_Medidas]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VC_VS_Medidas]
AS
SELECT idEstancia
     , MIN(TOTAL) AS 'Mínimo'
     , AVG(TOTAL) AS 'Média'
     , MAX(TOTAL) AS 'Máximo'
	 , SUM(TOTAL) AS 'Soma'
FROM (SELECT P.idEstancia, COUNT(P.idEstancia) AS 'TOTAL',[EventDate]
		FROM [dbo].[Visualizacao] AS V
		INNER JOIN [dbo].[Objeto] AS O ON O.idObjeto = V.idObjeto
		INNER JOIN [dbo].[Pasta] AS P ON P.idPasta = O.idPasta
		WHERE [TimeStart] >= DATEADD(DAY,-30,[dbo].[F_HoraDiaNowZero](GETDATE()))
		GROUP BY P.idEstancia, [EventDate] ) AS A
GROUP BY idEstancia



GO
/****** Object:  View [dbo].[VW_Visualizacao_QT]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_Visualizacao_QT]
AS
SELECT C.[idObjeto]
 	,C.[Objeto] AS 'Objeto'
	,AVG([TimeDataRetrieval]) AS 'Tempo médio de espera milesegundo'
	,CONVERT(TIME, DATEADD(MILLISECOND, AVG([TimeDataRetrieval]) , 0), 114) AS 'Tempo médio de espera'
	,ROUND(ISNULL(CAST(AVG([CountByte]) AS FLOAT) / CAST((1024 * 1024) AS FLOAT), 0),2)  AS 'MB Transferência'
	,COUNT(C.[idObjeto]) AS 'Total diário'
    ,EL.[EventDate] AS 'Data Visualização'
FROM [dbo].[Visualizacao] EL WITH(NOLOCK)
LEFT OUTER JOIN [Objeto] C WITH(NOLOCK) ON (EL.[idObjeto] = C.[idObjeto]) 
WHERE [TimeStart] >= DATEADD(DAY,-30,GETDATE())
GROUP BY C.[idObjeto], C.[Objeto],EL.[EventDate]
HAVING COUNT(C.[Objeto]) > 0
GO
/****** Object:  View [dbo].[VW_ObjetosSemAcesso]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_ObjetosSemAcesso]
AS
SELECT O.[idObjeto]
     , [idVisualizacao]
  FROM [dbo].[Objeto] AS O
  LEFT JOIN [dbo].[Visualizacao] AS V ON O.idObjeto = V.idObjeto
  WHERE [idVisualizacao] IS NULL
GO
/****** Object:  Table [dbo].[RoleUser]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleUser](
	[idRoleUser] [int] IDENTITY(1,1) NOT NULL,
	[idObjeto] [int] NULL,
	[idPasta] [int] NULL,
	[ItemID] [nvarchar](40) NULL,
	[ParentID] [nvarchar](40) NULL,
	[LoginName] [nvarchar](260) NULL,
	[UserName] [nvarchar](260) NULL,
	[Type] [int] NULL,
	[RoleName] [nvarchar](260) NULL,
	[RolePermission] [varchar](500) NULL,
	[UserAccountControl] [int] NULL,
	[email] [nvarchar](100) NULL,
	[Lotacao] [nvarchar](260) NULL,
 CONSTRAINT [PK_idRoleUser] PRIMARY KEY CLUSTERED 
(
	[idRoleUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Schedule]    Script Date: 05/07/2021 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schedule](
	[idschedule] [int] IDENTITY(1,1) NOT NULL,
	[idObjeto] [int] NOT NULL,
	[ItemID] [nvarchar](40) NULL,
	[ScheduleID] [nvarchar](40) NOT NULL,
	[ScheduleName] [nvarchar](260) NULL,
	[TipoRecorrente] [varchar](8) NULL,
	[SubtipoRecorrente] [varchar](16) NULL,
	[ExecutarAcada(Hora)] [varchar](45) NULL,
	[ExecutarAcada(Dia)] [varchar](3) NULL,
	[ExecutarAcada(Semana)] [varchar](3) NULL,
	[ExecutarAcada(DiaDaSemana)] [varchar](30) NULL,
	[ExecutarAcada(SemanaDoMêe)] [varchar](7) NULL,
	[ExecutarAcada(Mes)] [varchar](48) NULL,
	[ExectaraAcada(DiaDoMes)] [varchar](84) NULL,
	[DataInicio] [datetime] NULL,
	[ProximaExecucao] [datetime] NULL,
	[UltimaExecucao] [datetime] NULL,
	[StatusDaExecucao] [varchar](12) NULL,
	[Duracao] [varchar](11) NULL,
	[DataFinal] [datetime] NULL,
 CONSTRAINT [PK_idschedule] PRIMARY KEY CLUSTERED 
(
	[idschedule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ScheduleHist]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduleHist](
	[idScheduleHist] [int] IDENTITY(1,1) NOT NULL,
	[idschedule] [int] NOT NULL,
	[ScheduleID] [sysname] NULL,
	[ItemID] [nvarchar](40) NULL,
	[Objeto] [nvarchar](425) NULL,
	[DataDaExecucao] [datetime] NULL,
	[StatusDaExecucao] [varchar](12) NULL,
	[Duracao] [varchar](11) NULL,
	[run_status] [int] NULL,
	[EventDate] [date] NULL,
	[EventTime] [time](7) NULL,
 CONSTRAINT [PK_idScheduleHist] PRIMARY KEY CLUSTERED 
(
	[idScheduleHist] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[VW_ErrorSchedule]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[VW_ErrorSchedule]
AS
SELECT DISTINCT
       O.idObjeto
      ,E.Servidor
      ,P.Pasta
      ,O.Objeto
      ,O.Localizacao
	  ,[ModifiedByUserName] AS 'ModifiedByLogin'
	  ,[CreatedByUserName] AS 'CreatedBLogin'
	  ,O.[DataDaModificacao]
	  ,M.[UltimaVisualizacao] 
	  ,UC.UserName AS 'CreatedByUserName'
	  ,UC.EMAIL    AS 'CreateEmail'
	  ,UM.UserName AS 'ModifiedByUserName'
	  ,UM.EMAIL    AS 'ModifiedEmail'
      ,[DataDaExecucao]
      ,H.[StatusDaExecucao]
      ,S.[Duracao]
      ,[run_status]
      ,[EventDate]
      ,[EventTime]
  FROM [dbo].[ScheduleHist] AS H
  LEFT JOIN [dbo].[Schedule] AS S ON S.idschedule = H.idschedule
  INNER JOIN [dbo].[Objeto]   AS O ON O.idObjeto = S.idObjeto
  INNER JOIN [dbo].[Pasta]    AS P ON P.idPasta = O.idPasta
  INNER JOIN [dbo].[Estancia] AS E ON E.idEstancia = P.idEstancia
  LEFT  JOIN (SELECT DISTINCT
                     LoginName
				   , UserName
				   , EMAIL
               FROM [dbo].[RoleUser]) AS UC ON UC.LoginName = [CreatedByUserName]
  LEFT  JOIN (SELECT DISTINCT
                     LoginName
				   , UserName
				   , EMAIL
               FROM [dbo].[RoleUser]) AS UM ON UM.LoginName = [ModifiedByUserName]
  LEFT  JOIN (SELECT idObjeto, MAX([TimeStart]) AS 'UltimaVisualizacao' FROM [dbo].[Visualizacao] GROUP BY idObjeto) AS M ON M.idObjeto = S.idObjeto
  WHERE H.[StatusDaExecucao] <> 'Sucesso'
    AND [DataDaExecucao] >= DATEADD(HH,-1,GETDATE())
	--AND [DataDaExecucao] >= '2020-08-20 00:00:00.000' --AND [DataDaExecucao] <= '2020-08-05 03:55:00.000'



GO
/****** Object:  View [dbo].[VW_ErrorLive]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VW_ErrorLive]
AS

SELECT DISTINCT
       E.Servidor
      ,P.Pasta
      ,O.Objeto
      ,O.Localizacao
      ,V.[UserName]
	  ,[ModifiedByUserName] AS 'ModifiedByLogin'
	  ,[CreatedByUserName] AS 'CreatedBLogin'
	  ,O.[DataDaModificacao]
	  ,M.[UltimaVisualizacao] 
	  ,UC.UserName AS 'CreatedByUserName'
	  ,UM.UserName AS 'ModifiedByUserName'
      ,[RequestType]
      ,[Format]
      ,[ItemAction]
      ,[TimeStart]
      ,[TimeDataRetrieval]
      ,[Source]
      ,[Status]
  FROM [dbo].[Visualizacao]   AS V
  INNER JOIN [dbo].[Objeto]   AS O ON O.idObjeto = V.idObjeto
  INNER JOIN [dbo].[Pasta]    AS P ON P.idPasta = O.idPasta
  INNER JOIN [dbo].[Estancia] AS E ON E.idEstancia = P.idEstancia
  LEFT  JOIN [dbo].[RoleUser] AS UC ON UC.LoginName = [CreatedByUserName]
  LEFT  JOIN [dbo].[RoleUser] AS UM ON UM.LoginName = [ModifiedByUserName]
  LEFT  JOIN (SELECT idObjeto, MAX([TimeStart]) AS 'UltimaVisualizacao' FROM [dbo].[Visualizacao] GROUP BY idObjeto) AS M ON M.idObjeto = V.idObjeto
  WHERE [Status] = 'rsInternalError'
    AND [Source] = 'Live'
    AND [TimeStart] >= [dbo].[F_HoraDiaNowZero] (GETDATE())



GO
/****** Object:  View [dbo].[VW_PanielNovoAlterado]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VW_PanielNovoAlterado]
AS
--Arlame de modificação ou painel novo
SELECT E.Servidor
      ,P.[Localizacao]
      ,P.[Objeto]
      ,P.[DataDaCriacao]
      ,P.[CreatedByUserName]
      ,P.[DataDaModificacao]
      ,P.[ModifiedByUserName]
      ,P.[Tamanho]
FROM [dbo].[Painel] AS P
INNER JOIN [dbo].[Pasta] AS PS ON PS.idPasta = P.idPasta
INNER JOIN [dbo].Estancia AS E ON E.idEstancia = PS.idEstancia
WHERE (P.[DataDaCriacao]     >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaCriacao]     <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )
   OR (P.[DataDaModificacao] >= [dbo].[F_HoraDiaNowZero] (DATEADD(DAY, -1, GETDATE()) ) AND P.[DataDaModificacao] <= [dbo].[F_HoraDiaNow24] (DATEADD(DAY, -1, GETDATE()))  )


/*
  WHERE P.[DataDaCriacao]     >= [dbo].[F_HoraDiaNowZero] ('2020-08-04 00:00:00')
     OR P.[DataDaModificacao] >= [dbo].[F_HoraDiaNowZero] ('2020-08-04 00:00:00')

  WHERE [DataDaCriacao]     >= [dbo].[F_HoraDiaNowZero] (GETDATE())
     OR [DataDaModificacao] >= [dbo].[F_HoraDiaNowZero] (GETDATE())
*/

GO
/****** Object:  View [dbo].[VW_UsuariosDesativados]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_UsuariosDesativados]
as
SELECT DISTINCT
       [UserName] as 'Nome'
      ,[LoginName] as 'Login'
      --,[RoleName] 
      --,[UserAccountControl] 
      ,[email] as 'E-mail'
	  , 'Desativada' as 'Status da conta'
  FROM [dbo].[RoleUser]
  WHERE --[RoleName] = 'Content Manager' AND 
        [UserAccountControl] <> '512' 
	AND [UserAccountControl] IS NOT NULL
	AND [UserAccountControl] <> '16843264' 
	AND [UserAccountControl] <> '66048' 



GO
/****** Object:  Table [dbo].[_Usuario]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_Usuario](
	[UserName] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[_UsuariosSemAcesso]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_UsuariosSemAcesso](
	[LoginName] [nvarchar](260) NULL,
	[UserName] [nvarchar](260) NULL,
	[TimeStart] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Auditoria]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Auditoria](
	[idAuditoria] [int] IDENTITY(1,1) NOT NULL,
	[TabName] [nvarchar](30) NULL,
	[idRegistro] [int] NULL,
	[acao] [nvarchar](10) NULL,
	[valorAnterior] [text] NULL,
	[valorDepois] [text] NULL,
	[DataTimer] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Calendario]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendario](
	[DataAlternativa] [date] NOT NULL,
	[DateKey] [int] NULL,
	[DiaNrMes] [int] NULL,
	[DiaNrAno] [int] NULL,
	[SemanaNome] [nvarchar](13) NOT NULL,
	[SemanaNrMes] [int] NULL,
	[SemanaNrAno] [int] NULL,
	[MesNome] [nvarchar](10) NOT NULL,
	[MesNrAno] [int] NOT NULL,
	[TrimestreNr] [int] NULL,
	[SemestreNr] [int] NULL,
	[Ano] [int] NULL,
 CONSTRAINT [PK_DimDate_DateKey] PRIMARY KEY CLUSTERED 
(
	[DataAlternativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DataSource]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSource](
	[idDataSource] [int] IDENTITY(1,1) NOT NULL,
	[idObjeto] [int] NOT NULL,
	[ItemId] [nvarchar](40) NULL,
	[DSType] [varchar](100) NULL,
	[DSKind] [varchar](100) NULL,
	[AuthType] [varchar](100) NULL,
	[DS] [nvarchar](max) NULL,
 CONSTRAINT [PK_idDataSource] PRIMARY KEY CLUSTERED 
(
	[idDataSource] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ETL]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL](
	[idETL] [int] IDENTITY(1,1) NOT NULL,
	[ETLstart] [datetime] NULL,
	[ETLend] [datetime] NULL,
 CONSTRAINT [PK_idETL] PRIMARY KEY CLUSTERED 
(
	[idETL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupUser]    Script Date: 05/07/2021 11:20:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupUser](
	[idGroupUser] [int] IDENTITY(1,1) NOT NULL,
	[idRoleUserGroup] [int] NULL,
	[LoginName] [nvarchar](260) NULL,
	[UserName] [nvarchar](260) NULL,
	[UserAccountControl] [int] NULL,
 CONSTRAINT [PK_idGroupUser] PRIMARY KEY CLUSTERED 
(
	[idGroupUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PainelSize]    Script Date: 05/07/2021 11:20:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PainelSize](
	[idObjetoSize] [int] IDENTITY(1,1) NOT NULL,
	[idObjeto] [int] NOT NULL,
	[Ob_size] [real] NULL,
	[DataTimer] [datetime] NULL,
	[EventDate] [date] NULL,
	[EventTime] [time](7) NULL,
 CONSTRAINT [PK_idObjetoSize] PRIMARY KEY CLUSTERED 
(
	[idObjetoSize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RespDataSource]    Script Date: 05/07/2021 11:20:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RespDataSource](
	[idRespDataSource] [int] IDENTITY(1,1) NOT NULL,
	[ItemId] [nvarchar](40) NULL,
	[DSKind] [varchar](100) NULL,
	[DSConnectionString] [nvarchar](max) NULL,
	[AuthType] [varchar](100) NULL,
	[Username] [varchar](100) NULL,
 CONSTRAINT [PK_idRespDataSource] PRIMARY KEY CLUSTERED 
(
	[idRespDataSource] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoleUserGroup]    Script Date: 05/07/2021 11:20:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleUserGroup](
	[idRoleUserGroup] [int] IDENTITY(1,1) NOT NULL,
	[idRoleUserGroupP] [int] NULL,
	[GroupName] [nvarchar](260) NULL,
 CONSTRAINT [PK_idRoleUserGroup] PRIMARY KEY CLUSTERED 
(
	[idRoleUserGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WorkSpace]    Script Date: 05/07/2021 11:20:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkSpace](
	[idWorkSpace] [int] IDENTITY(1,1) NOT NULL,
	[idEstancia] [int] NULL,
	[WorkSpace] [nvarchar](425) NULL,
	[ItemID] [nvarchar](40) NULL,
	[Path] [nvarchar](425) NULL,
	[Nivel] [int] NULL,
	[Localizacao] [nvarchar](max) NULL,
 CONSTRAINT [PK_Raiz] PRIMARY KEY CLUSTERED 
(
	[idWorkSpace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Auditoria] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [dbo].[Painel] ADD  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [dbo].[PainelSize] ADD  DEFAULT (getdate()) FOR [DataTimer]
GO
ALTER TABLE [dbo].[Pasta] ADD  DEFAULT ((1)) FOR [ativo]
GO
ALTER TABLE [dbo].[DataSource]  WITH CHECK ADD  CONSTRAINT [FK_idObjeto_DataSource] FOREIGN KEY([idObjeto])
REFERENCES [dbo].[Painel] ([idObjeto])
GO
ALTER TABLE [dbo].[DataSource] CHECK CONSTRAINT [FK_idObjeto_DataSource]
GO
ALTER TABLE [dbo].[GroupUser]  WITH CHECK ADD  CONSTRAINT [FK_GroupUser_RoleUserGroup] FOREIGN KEY([idRoleUserGroup])
REFERENCES [dbo].[RoleUserGroup] ([idRoleUserGroup])
GO
ALTER TABLE [dbo].[GroupUser] CHECK CONSTRAINT [FK_GroupUser_RoleUserGroup]
GO
ALTER TABLE [dbo].[Painel]  WITH CHECK ADD  CONSTRAINT [FK_idWorkSpace] FOREIGN KEY([idPasta])
REFERENCES [dbo].[Pasta] ([idPasta])
GO
ALTER TABLE [dbo].[Painel] CHECK CONSTRAINT [FK_idWorkSpace]
GO
ALTER TABLE [dbo].[PainelSize]  WITH CHECK ADD  CONSTRAINT [FK_idObjeto_Size] FOREIGN KEY([idObjeto])
REFERENCES [dbo].[Painel] ([idObjeto])
GO
ALTER TABLE [dbo].[PainelSize] CHECK CONSTRAINT [FK_idObjeto_Size]
GO
ALTER TABLE [dbo].[RoleUser]  WITH CHECK ADD  CONSTRAINT [FK_RoleUser_Objeto] FOREIGN KEY([idObjeto])
REFERENCES [dbo].[Painel] ([idObjeto])
GO
ALTER TABLE [dbo].[RoleUser] CHECK CONSTRAINT [FK_RoleUser_Objeto]
GO
ALTER TABLE [dbo].[RoleUser]  WITH CHECK ADD  CONSTRAINT [FK_RoleUser_Pasta] FOREIGN KEY([idPasta])
REFERENCES [dbo].[Pasta] ([idPasta])
GO
ALTER TABLE [dbo].[RoleUser] CHECK CONSTRAINT [FK_RoleUser_Pasta]
GO
ALTER TABLE [dbo].[RoleUserGroup]  WITH CHECK ADD  CONSTRAINT [FK_RoleUserGroup_P] FOREIGN KEY([idRoleUserGroupP])
REFERENCES [dbo].[RoleUserGroup] ([idRoleUserGroup])
GO
ALTER TABLE [dbo].[RoleUserGroup] CHECK CONSTRAINT [FK_RoleUserGroup_P]
GO
ALTER TABLE [dbo].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_idObjeto] FOREIGN KEY([idObjeto])
REFERENCES [dbo].[Painel] ([idObjeto])
GO
ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [FK_idObjeto]
GO
ALTER TABLE [dbo].[ScheduleHist]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleHist] FOREIGN KEY([idschedule])
REFERENCES [dbo].[Schedule] ([idschedule])
GO
ALTER TABLE [dbo].[ScheduleHist] CHECK CONSTRAINT [FK_ScheduleHist]
GO
ALTER TABLE [dbo].[Visualizacao]  WITH CHECK ADD  CONSTRAINT [FK_idObjeto_Visualizacao] FOREIGN KEY([idObjeto])
REFERENCES [dbo].[Painel] ([idObjeto])
GO
ALTER TABLE [dbo].[Visualizacao] CHECK CONSTRAINT [FK_idObjeto_Visualizacao]
GO
ALTER TABLE [dbo].[WorkSpace]  WITH CHECK ADD  CONSTRAINT [FK_idEstancia] FOREIGN KEY([idEstancia])
REFERENCES [dbo].[Estancia] ([idEstancia])
GO
ALTER TABLE [dbo].[WorkSpace] CHECK CONSTRAINT [FK_idEstancia]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActiveDirectoryUser]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ActiveDirectoryUser]
AS 
DECLARE @LoginName nvarchar(25)
DECLARE db_for CURSOR FOR

	SELECT DISTINCT
		   RTRIM(LTRIM(REPLACE([LoginName],'D_SEDE\','')))
	  FROM [dbo].[RoleUser] AS U 

OPEN db_for 
FETCH NEXT FROM db_for INTO @LoginName

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		EXECUTE [dbo].[SP_RoleUserActiveDirectory] @LoginName

		FETCH NEXT FROM db_for INTO @LoginName
	END 

CLOSE db_for
DEALLOCATE db_for

GO
/****** Object:  StoredProcedure [dbo].[SP_ActiveDirectoryVisual]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ActiveDirectoryVisual]
AS 
DECLARE @LoginName nvarchar(25)
DECLARE db_for CURSOR FOR

	SELECT DISTINCT
		   RTRIM(LTRIM(REPLACE([UserName],'D_SEDE\','')))
	  FROM [dbo].[Visualizacao] AS U 
	  WHERE [LoginName] IS NULL

OPEN db_for 
FETCH NEXT FROM db_for INTO @LoginName

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		EXECUTE [dbo].[SP_VisualActiveDirectory] @LoginName

		FETCH NEXT FROM db_for INTO @LoginName
	END 

CLOSE db_for
DEALLOCATE db_for


GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteDataSource]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_DeleteDataSource]
	@idObjeto       INT,
	@ItemID         nvarchar(40)

AS
BEGIN
		DELETE 
		  FROM [dbo].[DataSource]
	 		WHERE [idObjeto] = @idObjeto
		     AND [ItemID] = @ItemID
END










GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteObjeto]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_DeleteObjeto]
    @idObjeto         [INT]
AS
BEGIN
	DELETE FROM [dbo].[Objeto]
	 WHERE [idObjeto] = @idObjeto
END





GO
/****** Object:  StoredProcedure [dbo].[SP_DeletePasta]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_DeletePasta]
    @idEstancia         [INT],
	@ItemID             NVARCHAR(40)
AS
BEGIN
	DELETE FROM [dbo].[Pasta]
	 WHERE [idEstancia] = @idEstancia AND [ItemID] = @ItemID
END



GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteRoleUserObjeto]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[SP_DeleteRoleUserObjeto]
	@idObjeto       INT,
	@ItemID         nvarchar(40),
	@LoginName      nvarchar(260),
	@RoleName       nvarchar(260)
AS
BEGIN
		DELETE 
		  FROM [dbo].[RoleUser]
	 		WHERE [idObjeto] = @idObjeto
		     AND [ItemID] = @ItemID
			 AND [LoginName] = @LoginName 
		      AND [RoleName] = @RoleName
END









GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteRoleUserPasta]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[SP_DeleteRoleUserPasta]
	@idPasta        INT,
	@ItemID         nvarchar(40),
	@LoginName      nvarchar(260),
	@RoleName       nvarchar(260)
AS
BEGIN
		DELETE 
		  FROM [dbo].[RoleUser]
	 		WHERE [idPasta] = @idPasta
		      AND [ItemID] = @ItemID
			   AND [LoginName] = @LoginName 
		       AND [RoleName] = @RoleName

END









GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteSchedule]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_DeleteSchedule]
	@idObjeto       INT,
	@ItemID         nvarchar(40),
	@ScheduleID     nvarchar(40)

AS
BEGIN
/*
DECLARE	@idObjeto       INT = 28
DECLARE	@ItemID         nvarchar(40) ='5C981D4A-A292-46DA-A819-597B0A35F9CA'
DECLARE	@ScheduleID     nvarchar(40) = '69A62039-C9F2-42A6-A742-1C9F10263485'
*/


DELETE A
  FROM [dbo].[ScheduleHist] AS A
  INNER JOIN [dbo].[Schedule] AS B ON B.ScheduleID = A.ScheduleID
	WHERE B.[idObjeto] = @idObjeto
		AND B.[ItemID] = @ItemID
		AND B.[ScheduleID] = @ScheduleID

DELETE 
	FROM [dbo].[Schedule]
	WHERE [idObjeto] = @idObjeto
		AND [ItemID] = @ItemID
		AND [ScheduleID] = @ScheduleID


END












GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteWorkSpace]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_DeleteWorkSpace]
    @idEstancia         [INT],
	@ItemID             NVARCHAR(40)
AS
BEGIN
	DELETE FROM [dbo].[WorkSpace]
	 WHERE [idEstancia] = @idEstancia AND [ItemID] = @ItemID
END


GO
/****** Object:  StoredProcedure [dbo].[SP_LastRecord]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**/
CREATE PROCEDURE [dbo].[SP_LastRecord] 
@Estancia INT,
@TableName char(30), 
@ReturDate  Datetime OUTPUT 
AS 
BEGIN
--DECLARE @ReturDate  Datetime  
--DECLARE @TableName char(30) = 'FatoDisk'
DECLARE @script nvarchar(4000)
DECLARE @CountSQLQuery INT = 0 

DECLARE @ParmCount nvarchar(30);

	SET @ParmCount = N'@Count INT = 0  OUTPUT';

	SET @script = 'SELECT @Count = COUNT(*) FROM  [dbo].['+ RTRIM(LTRIM(@TableName)) + ']'
	
	EXEC sp_executesql @script, @ParmCount, @Count = @CountSQLQuery OUTPUT;

	IF ( @CountSQLQuery > 0 OR @CountSQLQuery IS NULL)
	  BEGIN

		SET @ParmCount = N'@LastDate Datetime  OUTPUT';

		SET @script = ' SELECT TOP(1)  @LastDate = cast(cast([EventDate] as date) as char(11)) +  CASE WHEN cast(cast([EventTime] as time) as char(8)) IS NULL THEN ''00:00:00'' ELSE cast(cast([EventTime] as time) as char(8)) END 
						  FROM [dbo].[Objeto] AS A
						  INNER JOIN [dbo].[Pasta] AS B ON B.idPasta = A.idPasta
						  INNER JOIN [dbo].['+ RTRIM(LTRIM(@TableName)) + '] AS C ON C.idObjeto = A.idObjeto
						  WHERE B.idEstancia = '+ RTRIM(LTRIM(@Estancia)) + '
						  ORDER BY [EventDate] DESC, [EventTime] DESC'

		EXEC sp_executesql @script, @ParmCount, @LastDate = @ReturDate OUTPUT;
	  END
	ELSE
	  BEGIN

		SET @ParmCount = N'@LastDate Datetime  OUTPUT';

		SET @script = ' SELECT TOP(1) @LastDate = cast(cast([DataAlternativa] as date) as char(11)) + CASE WHEN cast(cast([EventTime] as time) as char(8)) IS NULL THEN ''00:00:00'' ELSE cast(cast([EventTime] as time) as char(8)) END 
		                 FROM [dbo].[DimDate]
						  ORDER BY [DataAlternativa] '

		EXEC sp_executesql @script, @ParmCount, @LastDate = @ReturDate OUTPUT;
	  END
	  
END



GO
/****** Object:  StoredProcedure [dbo].[SP_ObjetoSize]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ObjetoSize]
AS
INSERT INTO [dbo].[objetoSize]
           ([idObjeto]
           ,[Ob_size]
           ,[DataTimer]
           ,[EventDate]
           ,[EventTime])
SELECT [idObjeto]
      ,[Tamanho] 
	  ,[dbo].[F_HoraDiaNowZero] (GETDATE()) AS 'DataTimer'
	 , CONVERT(date, [dbo].[F_HoraDiaNowZero] (GETDATE()), 23) AS 'EVENTDATE'
	 , CONVERT(time, [dbo].[F_HoraDiaNowZero] (GETDATE()), 108) AS 'EVENTTIME'      
  FROM [dbo].[Objeto]



GO
/****** Object:  StoredProcedure [dbo].[SP_RoleUserActiveDirectory]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_RoleUserActiveDirectory] (@inUser NVARCHAR(25) )
AS
--DECLARE @inUser NVARCHAR(25)
DECLARE @Query VARCHAR(MAX)
CREATE TABLE #TBValidade (Validar INT)
CREATE TABLE #TBusr (dName NVARCHAR(50), UsrAControl INT, SAccountName NVARCHAR(50),mail  NVARCHAR(50), department NVARCHAR(260))

--SET @inUser = 'DL_BI_Admin'
--SET @inUser = 'T818008511'


----------------Verifica no Active Directory se o LOGIN informado é um USUÁRIO-------------------
	SET @Query = 'INSERT INTO #TBValidade (Validar) SELECT COUNT(SamAccountName)  FROM OpenQuery (
	ADSI,
	''SELECT SamAccountName
	FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
	WHERE objectClass =''''User''''
	 AND  SamAccountName = ''''' + @inUser + '''''
	'')'
		EXEC(@Query)
--------------------------------------------------------------------------------------------------

	---Ser o valor for 1 LOGIN é um usuário
	 IF (SELECT Validar FROM #TBValidade) = 1
	 BEGIN 
		-------------------- Extrair as informações do usuário -------------------
		SET @Query = 'INSERT INTO #TBusr (dName, UsrAControl,SAccountName,mail,department) SELECT displayName, UserAccountControl, SamAccountName, mail, department FROM OpenQuery (
		ADSI,
		''SELECT displayName, UserAccountControl,SamAccountName,mail,department
		FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
		WHERE objectClass =''''User''''
		 AND  SamAccountName = ''''' + @inUser + '''''
		'')'
			EXEC(@Query)

			----- Atualiza a tabela ROleUser com as informações extraida do AD.
			UPDATE [dbo].[RoleUser]
			   SET [RoleUser].[UserName] = B.dName
				  ,[RoleUser].[UserAccountControl] = B.UsrAControl
				  ,[RoleUser].[Lotacao]   = B.department
				  ,[RoleUser].[email] = B.mail
			FROM [RoleUser] AS A
			INNER JOIN #TBusr AS B ON B.SAccountName = RTRIM(LTRIM(REPLACE(A.[LoginName],'D_SEDE\','')))
			 WHERE A.[LoginName] LIKE  '%' + @inUser


	 END
	 ELSE --Ser for um usuário verifica se é um GRUPO
	   BEGIN 
	   TRUNCATE TABLE #TBValidade
	   TRUNCATE TABLE #TBusr
			----------------Verifica no Active Directory se o LOGIN informado é um GRUPO-------------------
			SET @Query = 'INSERT INTO #TBValidade (Validar) SELECT COUNT(SamAccountName)  FROM OpenQuery (
			ADSI,
			''SELECT SamAccountName
			FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
			WHERE objectClass =''''group''''
			 AND  SamAccountName = ''''' + @inUser + '''''
			'')'
				EXEC(@Query)

				---Ser o valor for 1 LOGIN é um GRUPO
				 IF (SELECT Validar FROM #TBValidade) = 1
				 BEGIN 
					-------------------- Extrair as informações do Grupo -------------------
					SET @Query = 'INSERT INTO #TBusr (SAccountName) SELECT SamAccountName FROM OpenQuery (
					ADSI,
					''SELECT SamAccountName
					FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
					WHERE objectClass =''''group''''
					 AND  SamAccountName = ''''' + @inUser + '''''
					'')'
						EXEC(@Query)
				 
						INSERT INTO [dbo].[RoleUserGroup]([GroupName])
						 SELECT SAccountName
						 FROM #TBusr
						 WHERE NOT EXISTS(SELECT * FROM [dbo].[RoleUserGroup] WHERE [GroupName] = (SELECT SAccountName FROM #TBusr) )
					
					UPDATE [dbo].[RoleUser]
						SET [UserName] = 'Login é um Grupo do AD'
					  FROM [dbo].[RoleUser]
					WHERE [LoginName] LIKE  '%' + @inUser

				 END
					ELSE
					UPDATE [dbo].[RoleUser]
						SET [UserName] = 'Usuário não foi localizado no AD'
					  FROM [dbo].[RoleUser]
					WHERE [LoginName] LIKE  '%' + @inUser
						   
	   END

	DROP TABLE #TBValidade
	DROP TABLE #TBusr





GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateCalendario]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_UpdateCalendario]
AS
DECLARE @TABLE_NAME nchar(50)
DECLARE @ExeScript nchar(3000)
DECLARE @lError SMALLINT
DECLARE @cnt_total INT --= 13513;
DECLARE @cnt       INT = 0
DECLARE @dtInicial date --= '1994-01-01'
DECLARE @dtCont date --= '1994-01-01'
DECLARE @AnoC int --= 1994
DECLARE @AnoV int --= 1994
DECLARE @DiaNumeroAno INT = 1
DECLARE @SemanaNumeroAnao INT = 1
DECLARE @TrimestreNr INT = 1
DECLARE @SemestreNr INT = 1
DECLARE @dt INT = 1

SET LANGUAGE BRAZILIAN


	CREATE TABLE #TBDATE([EventDate] DATE)


	DECLARE db_for CURSOR FOR

		SELECT TABLE_NAME 
		 FROM [MonitorDW].INFORMATION_SCHEMA.TABLES
		  WHERE TABLE_NAME IN('Schedule','Visualizacao','objetoSize')

		OPEN db_for 
		FETCH NEXT FROM db_for INTO @TABLE_NAME

			WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @ExeScript = 'INSERT INTO #TBDATE ([EventDate]) SELECT MIN([EventDate]) FROM [dbo].'+ RTRIM(@TABLE_NAME) + ' '
				exec sp_executesql @ExeScript

				SET @ExeScript = 'INSERT INTO #TBDATE ([EventDate]) SELECT MAX([EventDate]) FROM [dbo].'+ RTRIM(@TABLE_NAME) + ' '
				exec sp_executesql @ExeScript

				FETCH NEXT FROM db_for INTO @TABLE_NAME
			END

		CLOSE db_for
		DEALLOCATE db_for

	/*Número de dias, este valor será o valor de execuções do loop */
	SELECT @cnt_total = DATEDIFF(DAY,(SELECT MIN([EventDate]) FROM  #TBDATE),(SELECT MAX([EventDate]) FROM  #TBDATE))
	SET @cnt_total = @cnt_total + 1

	/*Data que iniciarar o loop */
	SELECT @dtInicial = MIN([EventDate]) FROM  #TBDATE
	SELECT @dtCont    = MIN([EventDate]) FROM  #TBDATE

	/*Ano que se iniciara o contador */
	SELECT @AnoC      = YEAR((SELECT MIN([EventDate]) FROM  #TBDATE))
	SELECT @AnoV      = YEAR((SELECT MIN([EventDate]) FROM  #TBDATE))
	
	/*Reduz um dia na data inicial do contado que vai criar a lista de datas que serão comparada com a tabela DimDate */
	SELECT @dtInicial = DATEADD(DAY,-1,@dtInicial) 
	
	--SELECT * FROM #TBDATE
	/*Limpa a tabela para receber os valores entre a menor data e a maior data*/
	TRUNCATE TABLE #TBDATE

	/*Iniciar o loop com a menor data menos um dia, pois ocontador já iniciar com mais um*/
		WHILE @dt <= @cnt_total   
		  BEGIN
			INSERT INTO #TBDATE ([EventDate]) VALUES(DATEADD(DAY, @dt ,@dtInicial))				
		    SET @dt = @dt + 1
		  END

		  
     INSERT INTO [dbo].[Calendario]
     SELECT REPLACE(CAST(A.[EventDate] AS char(10)),'-','')                 AS 'DateKey'
	      , A.[EventDate]                                                   AS 'DataAlternativa'
		  , DAY(A.[EventDate])                                              AS 'DiaNrMes'
		  , (SELECT MonitorGW.[dbo].[F_DiaNumeroAno] (A.[EventDate]))       AS 'DiaNrMes'
		  , CASE [dbo].[FDIA_SEMANA] (A.[EventDate])
		      WHEN 1 THEN 'domingo'
			  WHEN 2 THEN 'segunda-feira'
			  WHEN 3 THEN 'terça-feira'
			  WHEN 4 THEN 'quarta-feira'
			  WHEN 5 THEN 'quinta-feira'
			  WHEN 6 THEN 'sexta-feira'
			  WHEN 7 THEN 'sábado'
		     END                                                             AS 'SemanaNome'  
		   , [dbo].[FDIA_SEMANA] (A.[EventDate])                 AS 'SemanaNrMes'
		   , (SELECT [dbo].[F_SemanaNumeroAnao] (A.[EventDate])) AS 'SemanaNrAno'
		   , [dbo].[FMES_EXT] (A.[EventDate])                    AS 'MesNome' 
		   , MONTH(A.[EventDate])                                            AS 'MesNrAno'
		   , (SELECT [dbo].[F_TrimestreNr] (A.[EventDate]))      AS 'TrimestreNr' 
		   , (SELECT [dbo].[F_SemestreNr] (A.[EventDate]))       AS 'SemestreNr'
		   , YEAR(A.[EventDate])                                                   AS 'Ano'
	 FROM #TBDATE AS A
	 WHERE NOT EXISTS(SELECT * FROM [dbo].[Calendario] AS B WHERE B.[DataAlternativa] = A.[EventDate])

DROP TABLE #TBDATE


/**** *****/








GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateDataSource]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_UpdateDataSource]
	@idObjeto           INT,
	@ItemID             NVARCHAR(40),
	@DSType             [varchar](100),
	@DSKind             [varchar](100),
	@AuthType           [varchar](100)
AS
BEGIN

			UPDATE [dbo].[DataSource]
			   SET [DSType] = @DSType
				  ,[DSKind] = @DSKind
				  ,[AuthType] = @AuthType
			 WHERE idObjeto = @idObjeto
			   AND [ItemID] = @ItemID

END






GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateObjeto]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_UpdateObjeto]
    @idPasta            INT,
	@ItemID             NVARCHAR(40),
	@Objeto             nvarchar(425),
	@Localizacao        nvarchar(425),
	@DataDaCriacao      datetime,
	@DataDaModificacao  datetime,
	@DiasSemAlteracao   INT,
	@Tamanho            FLOAT,
	@CreatedByUserName  nvarchar(260),
	@ModifiedByUserName nvarchar(260)
AS
BEGIN

	UPDATE [dbo].[Objeto]
	   SET [Localizacao]        = @Localizacao
		  ,[Objeto]				= @Objeto
		  ,[DataDaCriacao]      = @DataDaCriacao
		  ,[DataDaModificacao]  = @DataDaModificacao
		  ,[DiasSemAlteracao]   = @DiasSemAlteracao
		  ,[Tamanho]            = @Tamanho
		  ,[CreatedByUserName]  = @CreatedByUserName
		  ,[ModifiedByUserName] = @ModifiedByUserName
	 WHERE [idPasta] = @idPasta
	   AND [ItemID] = @ItemID

END





GO
/****** Object:  StoredProcedure [dbo].[SP_UpdatePasta]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_UpdatePasta]
    @idEstancia         [INT],
	@ItemID             NVARCHAR(40),
    @Pasta              nvarchar(425),
	@Localizacao        nvarchar(425),
	@DataDaCriacao      datetime,
	@DataDaModificacao  datetime,
	@DiasSemAlteracao   int,
	@Nivel              int
AS
BEGIN

	UPDATE [dbo].[Pasta]
	   SET [Pasta]              = @Pasta
	      ,[Localizacao]        = @Localizacao
		  ,[DataDaCriacao]      = @DataDaCriacao
		  ,[DataDaModificacao]  = @DataDaModificacao
		  ,[DiasSemAlteracao]   = @DiasSemAlteracao
		  ,[Nivel]              = @Nivel
	 WHERE [idEstancia] = @idEstancia
	   AND [ItemID] = @ItemID

END


GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateSchedule]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SP_UpdateSchedule]
	@idObjeto           INT,
	@ItemID             NVARCHAR(40),
    @ScheduleID         nvarchar(40),
    @ScheduleName       nvarchar(260),
    @TipoRecorrente     varchar(8),
    @SubtipoRecorrente   varchar(16),
    @ExecutarAcadaHora  varchar(45),
    @ExecutarAcadaDia  varchar(3),
    @ExecutarAcadaSemana  varchar(3),
    @ExecutarAcadaDiaDaSemana  varchar(30),
    @ExecutarAcadaSemanaDoMêe  varchar(7),
    @ExecutarAcadaMes  varchar(48),
    @ExectaraAcadaDiaDoMes  varchar(84),
    @DataInicio  datetime,
    @ProximaExecucao datetime,
    @UltimaExecucao datetime,
    @StatusDaExecucao varchar(12),
    @Duracao  varchar(11),
    @DataFinal  datetime
AS
BEGIN

			UPDATE [dbo].[Schedule]
			   SET [ScheduleName] = @ScheduleName
				  ,[TipoRecorrente] = @TipoRecorrente
				  ,[SubtipoRecorrente] = @SubtipoRecorrente
				  ,[ExecutarAcada(Hora)] = @ExecutarAcadaHora
				  ,[ExecutarAcada(Dia)] = @ExecutarAcadaDia
				  ,[ExecutarAcada(Semana)] = @ExecutarAcadaSemana
				  ,[ExecutarAcada(DiaDaSemana)] = @ExecutarAcadaDiaDaSemana
				  ,[ExecutarAcada(SemanaDoMêe)] = @ExecutarAcadaSemanaDoMêe
				  ,[ExecutarAcada(Mes)] = @ExecutarAcadaMes
				  ,[ExectaraAcada(DiaDoMes)] = @ExecutarAcadaMes
				  ,[DataInicio] = @DataInicio
				  ,[ProximaExecucao] = @ProximaExecucao
				  ,[UltimaExecucao] = @UltimaExecucao
				  ,[StatusDaExecucao] = @StatusDaExecucao
				  ,[Duracao] = @Duracao
				  ,[DataFinal] = @DataFinal
			 WHERE idObjeto = @idObjeto
			   AND [ItemID] = @ItemID
			   AND [ScheduleID] = @ScheduleID

END



GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateWorkSpace]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_UpdateWorkSpace]
    @idEstancia         [INT],
	@ItemID             NVARCHAR(40),
    @Localizacao        [nvarchar](425),
	@WorkSpace          [nvarchar](425)
AS
BEGIN
	UPDATE [dbo].[WorkSpace]
	   SET [Localizacao] = @Localizacao
		  ,[WorkSpace]   = @WorkSpace
	 WHERE [idEstancia] = @idEstancia
	   AND [ItemID] = @ItemID

END





GO
/****** Object:  StoredProcedure [dbo].[SP_VisualActiveDirectory]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_VisualActiveDirectory] (@inUser NVARCHAR(25) )
AS
--DECLARE @inUser NVARCHAR(25)
DECLARE @Query VARCHAR(MAX)
CREATE TABLE #TBValidade (Validar INT)
CREATE TABLE #TBusr (dName NVARCHAR(50), UsrAControl INT, SAccountName NVARCHAR(50), mail  NVARCHAR(50), department NVARCHAR(260))

--SET @inUser = 'DL_BI_Admin'
--SET @inUser = 'T818008511'


----------------Verifica no Active Directory se o LOGIN informado é um USUÁRIO-------------------
	SET @Query = 'INSERT INTO #TBValidade (Validar) SELECT COUNT(SamAccountName)  FROM OpenQuery (
	ADSI,
	''SELECT SamAccountName
	FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
	WHERE objectClass =''''User''''
	 AND  SamAccountName = ''''' + @inUser + '''''
	'')'
		EXEC(@Query)
--------------------------------------------------------------------------------------------------

	---Ser o valor for 1 LOGIN é um usuário
	 IF (SELECT Validar FROM #TBValidade) = 1
	 BEGIN 
		-------------------- Extrair as informações do usuário -------------------
		SET @Query = 'INSERT INTO #TBusr (dName, UsrAControl,SAccountName,mail,department) SELECT displayName, UserAccountControl, SamAccountName, mail, department FROM OpenQuery (
		ADSI,
		''SELECT displayName, UserAccountControl,SamAccountName,mail,department
		FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
		WHERE objectClass =''''User''''
		 AND  SamAccountName = ''''' + @inUser + '''''
		'')'
			EXEC(@Query)

			----- Atualiza a tabela ROleUser com as informações extraida do AD.
			UPDATE [dbo].[Visualizacao]
			   SET [Visualizacao].[LoginName] = B.dName,
			       [Visualizacao].[Lotacao]   = B.department
			FROM [Visualizacao] AS A
			INNER JOIN #TBusr AS B ON B.SAccountName = RTRIM(LTRIM(REPLACE(A.[UserName],'D_SEDE\','')))
			 WHERE A.[UserName] LIKE  '%' + @inUser


	 END
	 ELSE --Ser for um usuário verifica se é um GRUPO
	   BEGIN 
	   TRUNCATE TABLE #TBValidade
	   TRUNCATE TABLE #TBusr
			----------------Verifica no Active Directory se o LOGIN informado é um GRUPO-------------------
			SET @Query = 'INSERT INTO #TBValidade (Validar) SELECT COUNT(SamAccountName)  FROM OpenQuery (
			ADSI,
			''SELECT SamAccountName
			FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
			WHERE objectClass =''''group''''
			 AND  SamAccountName = ''''' + @inUser + '''''
			'')'
				EXEC(@Query)

				---Ser o valor for 1 LOGIN é um GRUPO
				 IF (SELECT Validar FROM #TBValidade) = 1
				 BEGIN 
					-------------------- Extrair as informações do Grupo -------------------
					SET @Query = 'INSERT INTO #TBusr (SAccountName) SELECT SamAccountName FROM OpenQuery (
					ADSI,
					''SELECT SamAccountName
					FROM ''''LDAP://S-SEAD34.infraero.gov.br''''
					WHERE objectClass =''''group''''
					 AND  SamAccountName = ''''' + @inUser + '''''
					'')'
						EXEC(@Query)
				 
						INSERT INTO [dbo].[RoleUserGroup]([GroupName])
						 SELECT SAccountName
						 FROM #TBusr
						 WHERE NOT EXISTS(SELECT * FROM [dbo].[RoleUserGroup] WHERE [GroupName] = (SELECT SAccountName FROM #TBusr) )
					
					UPDATE [dbo].[RoleUser]
						SET [UserName] = 'Login é um Grupo do AD'
					  FROM [dbo].[RoleUser]
					WHERE [LoginName] LIKE  '%' + @inUser

				 END
					ELSE
					UPDATE [dbo].[Visualizacao]
						SET [LoginName] = 'Usuário não foi localizado no AD'
					  FROM [dbo].[Visualizacao]
					WHERE [LoginName] LIKE  '%' + @inUser
						   
	   END

	DROP TABLE #TBValidade
	DROP TABLE #TBusr







GO
/****** Object:  StoredProcedure [dbo].[usp_resultset_html]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_resultset_html] (@consulta nvarchar(max), @titulo_tabela nvarchar(300) = '', @css nvarchar(max) = 'default')
as begin
    begin transaction
    set nocount on
    set xact_abort on
    declare @colunas varchar(max)
    declare @html_final nvarchar(max)
    declare @html_parcial nvarchar(max)
    declare @sql nvarchar(max)
    -- Obtem colunas do select original e converte para TDs
    set @colunas = stuff((select ', [' + name + '] as td' from sys.dm_exec_describe_first_result_set(@consulta, null, 0) for xml path('')), 1, 1, '')
 
    -- Define nome da tabela temporária com newid para permitir execução simultanea por diversos terminais
    declare @table_name varchar(50)
    set @table_name = 'tb' + convert(varchar, abs(checksum(newid())))
 
    -- Altera query original para salvar o resultado da query na tabela temporária
    -- Ex: DE: "select * from produtos" PARA: "select * into tb123456 from produtos"
    if charindex('from', @consulta) = 0
        begin
            -- selects sem "from tabela", exemplo: select 1, 2
            set @consulta = @consulta + ' into ' + @table_name
        end
    else
        begin
            -- Selects normais, com tabelas
            set @consulta = replace(@consulta, 'from', ' into ' + @table_name + ' from ')
        end
    execute (@consulta)
 
    -- Cria html a partir da tabela temporária salva
    set @html_final = '<table class="sql_tabela">'
    if @titulo_tabela <> '' set @html_final = @html_final + '<caption>' + @titulo_tabela + '</caption>'
    set @html_final = @html_final + '<thead><tr>'
    set @sql = 'set @html_parcial= (select column_name as th from information_schema.columns where table_name = ''' + @table_name + ''' for xml path(''''))'
    execute sp_executesql @sql, N'@html_parcial varchar(max) out', @html_parcial out
    set @html_final = @html_final + @html_parcial
    set @html_final = @html_final + '</tr></thead>'
    set @html_final = @html_final + '<tbody>'
    set @sql = 'set @html_parcial= (select ' + @colunas + ' from ' + @table_name + ' for xml raw(''tr''), elements)'
    execute sp_executesql @sql, N'@html_parcial nvarchar(max) out', @html_parcial out
    set @html_final = @html_final + @html_parcial
    set @html_final = @html_final + '</tbody></table>'
 
    -- Adiciona CSS:
    if @css is null set @css = ''
    if @css = 'default'
        set @css = '
            <style>
                .sql_tabela {
                    border-spacing: 0px;
                }
                .sql_tabela caption {
                    padding: 5px;
                    border: 1px solid #F0F0F0;
                    text-align: center;
                }
                .sql_tabela thead {
                    background: #FCFCFC;
                }
                .sql_tabela th {
                    padding: 1px 10px 1px 5px;
                    border: 1px solid #F0F0F0;
                    font-weight: normal;    
                    text-align: left;
                    word-wrap: break-word;
                    max-width: 200px;
                }
                .sql_tabela body {
                }
                .sql_tabela td {
                    padding: 1px 10px 1px 5px;
                    border: 1px solid #F0F0F0;
                    word-wrap: break-word;
                    max-width: 200px;
                }
            </style>'
    if @css = 'default_inline'
        begin
            set @css = ''
            set @html_final = replace(@html_final, '<table class="sql_tabela">', '<table style="border-spacing: 0px;">')
            set @html_final = replace(@html_final, '<caption>', '<caption style="padding: 5px; border: 1px solid #F0F0F0; text-align: center;">')
            set @html_final = replace(@html_final, '<thead>', '<thead style="background: #FCFCFC;">')
            set @html_final = replace(@html_final, '<th>', '<th style="padding: 1px 10px 1px 5px; border: 1px solid #F0F0F0; font-weight: normal; text-align: left; word-wrap: break-word; max-width: 200px;">')
            set @html_final = replace(@html_final, '<td>', '<td style="padding: 1px 10px 1px 5px; border: 1px solid #F0F0F0; word-wrap: break-word; max-width: 200px;">')
        end
    set @html_final = @css + @html_final
     
    -- Mostra HTML
    select @html_final
 
    -- Exclui tabela temporária
    execute ('drop table ' + @table_name)
    rollback transaction
end

GO
/****** Object:  Trigger [dbo].[TG_DL_DataSource]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TG_DL_DataSource] ON [dbo].[DataSource]
INSTEAD OF DELETE
AS 
BEGIN
DECLARE @OB INT 
DECLARE @PT INT

		INSERT INTO [dbo].[Auditoria]
				   ([TabName],[idRegistro],[acao],[valorAnterior])
		SELECT 'DataSource'     --TabName
			  ,A.[idDataSource] --idRegistro
			  ,'DELETE'        --acao
			  , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[DSType]+' ; '+A.[DSKind]+' ; '+A.[AuthType] -- valorAnterior
		  FROM [dbo].[DataSource] AS A
		  INNER JOIN DELETED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 
		  WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 


		DELETE A
			FROM [dbo].[DataSource] AS A
			INNER JOIN DELETED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 
		    WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 

END;

GO
ALTER TABLE [dbo].[DataSource] ENABLE TRIGGER [TG_DL_DataSource]
GO
/****** Object:  Trigger [dbo].[TG_UP_DataSource]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TG_UP_DataSource] ON [dbo].[DataSource]
INSTEAD OF UPDATE
AS 
BEGIN
DECLARE @OB INT 
DECLARE @PT INT
/*
		INSERT INTO [dbo].[Auditoria]
				   ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
		SELECT 'DataSource'     --TabName
			  ,A.[idDataSource] --idRegistro
			  ,'Update'        --acao
			  , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[DSType]+' ; '+A.[DSKind]+' ; '+A.[AuthType] -- valorAnterior
			  , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+B.[ItemID]+' ; '+B.[DSType]+' ; '+B.[DSKind]+' ; '+B.[AuthType] -- valorDepois
		  FROM [dbo].[DataSource] AS A
		  INNER JOIN INSERTED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 
		  WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID */

			UPDATE [dbo].[DataSource]
			   SET [DSType] = A.[DSType]
				  ,[DSKind] = A.[DSKind]
				  ,[AuthType] = A.[AuthType]
			FROM [dbo].[DataSource] AS A
			INNER JOIN INSERTED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 
		    WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID 

END;

GO
ALTER TABLE [dbo].[DataSource] ENABLE TRIGGER [TG_UP_DataSource]
GO
/****** Object:  Trigger [dbo].[TG_DL_Objeto]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE TRIGGER [dbo].[TG_DL_Objeto] ON [dbo].[Painel]
INSTEAD OF DELETE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior])
	SELECT 'Objeto'     --TabName
		  ,A.[idPasta] --idRegistro
		  ,'DELETE'        --acao
		  , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[ParentID]+' ; '+A.[Objeto]+' ; '+A.[Localizacao]+' ; '+CAST(A.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(A.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(A.[DiasSemAlteracao] AS NVARCHAR(3)) -- valorAnterior
	  FROM [dbo].[Objeto] AS A
	  INNER JOIN DELETED AS B ON B.[idObjeto] = A.idObjeto
	  WHERE B.[idObjeto] = A.idObjeto



		UPDATE [dbo].[Objeto]
		   SET  [ativo] = 0
			FROM [dbo].[Objeto] AS A
				  INNER JOIN DELETED AS B ON B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID]
				  WHERE B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID] 


END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */







GO
ALTER TABLE [dbo].[Painel] ENABLE TRIGGER [TG_DL_Objeto]
GO
/****** Object:  Trigger [dbo].[TG_UP_Objeto]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TG_UP_Objeto] ON [dbo].[Painel]
INSTEAD OF UPDATE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
	SELECT 'Objeto'     --TabName
		 , A.[idPasta] --idRegistro
		 , 'UPDATE'    --acao
		 , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[ParentID]+' ; '+A.[Objeto]+' ; '+A.[Localizacao]+' ; '+CAST(A.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(A.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(A.[DiasSemAlteracao] AS NVARCHAR(3)) -- valorAnterior
		 , CAST(B.[idObjeto] AS nvarchar(10))+' ; '+B.[ItemID]+' ; '+B.[ParentID]+' ; '+B.[Objeto]+' ; '+B.[Localizacao]+' ; '+CAST(B.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(B.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(B.[DiasSemAlteracao] AS NVARCHAR(3)) -- valorDepois
	  FROM [dbo].[Objeto] AS A
	  INNER JOIN INSERTED AS B ON B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID]


		UPDATE [dbo].[Objeto]
		   SET [Objeto]             = B.[Objeto]
			  ,[Localizacao]        = B.Localizacao
			  ,[DataDaCriacao]      = B.DataDaCriacao
			  ,[DataDaModificacao]  = B.DataDaModificacao
			  ,[DiasSemAlteracao]   = B.DiasSemAlteracao
			  ,[Tamanho]            = B.[Tamanho]
			  ,[CreatedByUserName]  = B.[CreatedByUserName]
			  ,[ModifiedByUserName] = B.[ModifiedByUserName]
			FROM [dbo].[Objeto] AS A
				  INNER JOIN INSERTED AS B ON B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID]
				  WHERE B.[idPasta] = A.[idPasta] AND B.[ItemID] = A.[ItemID] 
	  

END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */




GO
ALTER TABLE [dbo].[Painel] ENABLE TRIGGER [TG_UP_Objeto]
GO
/****** Object:  Trigger [dbo].[TG_DL_Pasta]    Script Date: 05/07/2021 11:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE TRIGGER [dbo].[TG_DL_Pasta] ON [dbo].[Pasta]
INSTEAD OF DELETE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior])
	SELECT 'Pasta'     --TabName
		  ,A.[idPasta] --idRegistro
		  ,'DELETE'        --acao
		  , CAST(A.[idEstancia] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[ParentID]+' ; '+A.[Pasta]+' ; '+A.[Localizacao]+' ; '+CAST(A.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(A.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(A.[DiasSemAlteracao] AS NVARCHAR(3))+' ; '+ CAST(A.[Nivel] AS NVARCHAR(3)) -- valorAnterior
	  FROM [dbo].[Pasta] AS A
	  INNER JOIN DELETED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  
		UPDATE [dbo].[Pasta]
		   SET  [ativo] = 0
		FROM [dbo].[Pasta] AS A
			  INNER JOIN DELETED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
			  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID] 


END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */





GO
ALTER TABLE [dbo].[Pasta] ENABLE TRIGGER [TG_DL_Pasta]
GO
/****** Object:  Trigger [dbo].[TG_UP_Pasta]    Script Date: 05/07/2021 11:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[TG_UP_Pasta] ON [dbo].[Pasta]
INSTEAD OF UPDATE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
	SELECT 'Pasta'     --TabName
		 , A.[idPasta] --idRegistro
		 , 'UPDATE'    --acao
		 , CAST(A.[idEstancia] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[ParentID]+' ; '+A.[Pasta]+' ; '+A.[Localizacao]+' ; '+CAST(A.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(A.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(A.[DiasSemAlteracao] AS NVARCHAR(3))+' ; '+ CAST(A.[Nivel] AS NVARCHAR(3)) -- valorAnterior
		 , CAST(B.[idEstancia] AS nvarchar(10))+' ; '+B.[ItemID]+' ; '+B.[ParentID]+' ; '+B.[Pasta]+' ; '+B.[Localizacao]+' ; '+CAST(B.[DataDaCriacao] AS NVARCHAR(24))+' ; '+CAST(B.[DataDaModificacao] AS NVARCHAR(24))+' ; '+ CAST(B.[DiasSemAlteracao] AS NVARCHAR(3))+' ; '+ CAST(B.[Nivel] AS NVARCHAR(3)) -- valorDepois
	  FROM [dbo].[Pasta] AS A
	  INNER JOIN INSERTED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]


		UPDATE [dbo].[Pasta]
		   SET [Pasta]              = B.Pasta
			  ,[Localizacao]        = B.Localizacao
			  ,[DataDaCriacao]      = B.DataDaCriacao
			  ,[DataDaModificacao]  = B.DataDaModificacao
			  ,[DiasSemAlteracao]   = B.DiasSemAlteracao
			  ,[Nivel]              = B.Nivel
			FROM [dbo].[Pasta] AS A
				  INNER JOIN INSERTED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
				  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID] 
	  

END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */


GO
ALTER TABLE [dbo].[Pasta] ENABLE TRIGGER [TG_UP_Pasta]
GO
/****** Object:  Trigger [dbo].[TG_DL_RoleUser]    Script Date: 05/07/2021 11:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE TRIGGER [dbo].[TG_DL_RoleUser] ON [dbo].[RoleUser]
INSTEAD OF DELETE
AS 
BEGIN
DECLARE @OB INT 
DECLARE @PT INT


SELECT @OB = [idObjeto], @PT = idPasta
FROM DELETED 

	IF @OB IS NOT NULL AND @PT IS NULL
	BEGIN
		INSERT INTO [dbo].[Auditoria]
				   ([TabName],[idRegistro],[acao],[valorAnterior])
		SELECT 'RoleUser'     --TabName
			  ,A.[idRoleUser] --idRegistro
			  ,'DELETE'        --acao
			  , CAST(A.[idObjeto] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[LoginName]+' ; '+A.[RoleName]+' ; '+CAST(A.[RolePermission] AS NVARCHAR(MAX)) -- valorAnterior
		  FROM [dbo].[RoleUser] AS A
		  INNER JOIN DELETED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName
		  WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName


		DELETE A
			FROM [dbo].[RoleUser] AS A
			INNER JOIN DELETED AS B ON B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName
		    WHERE B.[idObjeto] = A.idObjeto AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName
	END
		
	IF @PT IS NOT NULL AND @OB IS NULL
	BEGIN 
		INSERT INTO [dbo].[Auditoria]
				   ([TabName],[idRegistro],[acao],[valorAnterior])
		SELECT 'RoleUser'     --TabName
			  ,A.[idRoleUser] --idRegistro
			  ,'DELETE'        --acao
			  , CAST(A.[idPasta] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[LoginName]+' ; '+A.[RoleName]+' ; '+CAST(A.[RolePermission] AS NVARCHAR(MAX)) -- valorAnterior
		  FROM [dbo].[RoleUser] AS A
		  INNER JOIN DELETED AS B ON B.[idPasta] = A.[idPasta] AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName
		  WHERE B.[idPasta] = A.[idPasta] AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName


		DELETE A
			FROM [dbo].[RoleUser] AS A
			INNER JOIN DELETED AS B ON B.[idPasta] = A.[idPasta] AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName
		    WHERE B.[idPasta] = A.[idPasta] AND B.ItemID = A.ItemID AND B.LoginName = A.LoginName AND B.[RoleName] = A.RoleName


	END
END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */







GO
ALTER TABLE [dbo].[RoleUser] ENABLE TRIGGER [TG_DL_RoleUser]
GO
/****** Object:  Trigger [dbo].[TG_DL_WorkSpace]    Script Date: 05/07/2021 11:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE TRIGGER [dbo].[TG_DL_WorkSpace] ON [dbo].[WorkSpace]
INSTEAD OF DELETE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior])
	SELECT 'WorkSpace'     --TabName
		  ,A.[idWorkSpace] --idRegistro
		  ,'DELETE'        --acao
		  ,CAST(A.[idEstancia] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[Path]+' ; '+A.[WorkSpace]+' ; '+A.[Localizacao] --valorAnterior		  
	  FROM [dbo].[WorkSpace] AS A
	  INNER JOIN DELETED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]


	DELETE A
		FROM [dbo].[WorkSpace] AS A
			  INNER JOIN DELETED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
			  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID] 

END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */



GO
ALTER TABLE [dbo].[WorkSpace] ENABLE TRIGGER [TG_DL_WorkSpace]
GO
/****** Object:  Trigger [dbo].[TG_UP_WorkSpace]    Script Date: 05/07/2021 11:20:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TG_UP_WorkSpace] ON [dbo].[WorkSpace]
INSTEAD OF UPDATE
AS 
BEGIN

	INSERT INTO [dbo].[Auditoria]
			   ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
	SELECT 'WorkSpace'     --TabName
		  ,A.[idWorkSpace] --idRegistro
		  ,'UPDATE'        --acao
		  ,CAST(A.[idEstancia] AS nvarchar(10))+' ; '+A.[ItemID]+' ; '+A.[Path]+' ; '+A.[WorkSpace]+' ; '+A.[Localizacao] --valorAnterior
		  ,CAST(B.[idEstancia] AS nvarchar(10))+' ; '+B.[ItemID]+' ; '+B.[Path]+' ; '+B.[WorkSpace]+' ; '+B.[Localizacao] --valorDepois
	  FROM [dbo].[WorkSpace] AS A
	  INNER JOIN INSERTED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]

UPDATE [dbo].[WorkSpace]
   SET [WorkSpace] = B.WorkSpace
      ,[Localizacao] = B.[Localizacao]
FROM [dbo].[WorkSpace] AS A
	  INNER JOIN INSERTED AS B ON B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID]
	  WHERE B.[idEstancia] = A.[idEstancia] AND B.[ItemID] = A.[ItemID] 
	  

END;
/*
INSERT INTO [dbo].[Auditoria]
           ([TabName],[idRegistro],[acao],[valorAnterior],[valorDepois])
     VALUES (@TabName,@idRegistro,@acao,@valorAnterior,@valorDepois)
	 */

GO
ALTER TABLE [dbo].[WorkSpace] ENABLE TRIGGER [TG_UP_WorkSpace]
GO
