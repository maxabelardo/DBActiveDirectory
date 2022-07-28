

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
