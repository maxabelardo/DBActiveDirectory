


CREATE PROCEDURE [siv].[sp_group_member]
AS
BEGIN

DECLARE @SID Nvarchar(max)
DECLARE @Name Nvarchar(max)
DECLARE @Member Nvarchar(max)
DECLARE @Cont INT

SET @Cont = 0

CREATE TABLE #res([Grupo] Nvarchar(max) NULL,[Tipo] Nvarchar(10) NULL,[SID] Nvarchar(max) NULL, [Member] Nvarchar(max) NULL,[SamAccountName] Nvarchar(max) NULL )

CREATE TABLE #US ([SID] [varchar](100) NULL,[Name] [varchar](100) NULL,[SamAccountName] [varchar](100) NULL)
CREATE TABLE #GO ([SID] [varchar](max) NULL,[Name] [varchar](max) NULL,[SamAccountName] [varchar](max) NULL)
CREATE TABLE #TC ([Name] [varchar](100) NULL,[DisplayName] [varchar](100) NULL)


INSERT INTO #US
SELECT [SID], [Name], [SamAccountName] FROM [brz].[user]

INSERT INTO #GO
SELECT [SID], [Name], [SamAccountName] FROM [brz].[group] 

INSERT INTO #TC
SELECT [Name], [DisplayName] FROM  [brz].[contact] 


DECLARE db_for CURSOR FOR

	SELECT  [SID],[Name],[Member]
	  FROM [brz].[group] 
		WHERE LEN([Member]) > 0

OPEN db_for 
FETCH NEXT FROM db_for INTO @SID, @Name, @Member

WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO #res
	SELECT @Name AS 'Group'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN 'Usuário'
			WHEN G.SID IS NOT NULL THEN 'Grupo'
			WHEN C.[Name] IS NOT NULL THEN 'Contato'
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'Tipo'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.SID
			WHEN G.SID IS NOT NULL THEN G.SID
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SID'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.Name
			WHEN G.SID IS NOT NULL THEN G.Name
			WHEN C.[Name] IS NOT NULL THEN C.Name
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN M.[Member]
		   END AS 'Member'
	     , CASE 
			WHEN U.SID IS NOT NULL THEN U.[SamAccountName]
			WHEN G.SID IS NOT NULL THEN G.[SamAccountName]
			WHEN C.[Name] IS NOT NULL THEN C.[DisplayName]
			WHEN (U.SID IS NULL) AND (G.SID IS NULL) THEN ''
		   END AS 'SamAccountName'		
	FROM [siv].[fc_return_member] (@Member, @Name) AS M
	LEFT JOIN #US AS U ON U.[Name] = M.[Member]
	LEFT JOIN #GO AS G ON G.[Name] = M.[Member]
	LEFT JOIN #TC AS C ON C.[Name] = M.[Member]

	SET @Cont = @Cont + 1

	PRINT CAST(@Cont AS CHAR(10))
	
	FETCH NEXT FROM db_for INTO  @SID, @Name, @Member
END

CLOSE db_for
DEALLOCATE db_for

	IF EXISTS
	(
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'AD.STGADGroupMember')
	)
		BEGIN
			DROP TABLE AD.STGADGroupMember
	END;

	SELECT Grupo, Tipo, SID, Member, SamAccountName INTO AD.STGADGroupMember FROM #res

DROP TABLE #res
DROP TABLE #US 
DROP TABLE #GO 
DROP TABLE #TC 

END;
GO


