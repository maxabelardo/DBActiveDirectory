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