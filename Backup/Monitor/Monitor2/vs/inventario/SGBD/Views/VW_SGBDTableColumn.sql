
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
