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

