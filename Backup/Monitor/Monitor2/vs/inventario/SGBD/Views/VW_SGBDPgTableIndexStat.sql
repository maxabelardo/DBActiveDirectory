CREATE VIEW SGBD.[VW_SGBDPgTableIndexStat]
as
SELECT [idSGBDTPgTableIndexStat]
      ,[idSGBDTableIndex]
      ,[idx_scan]
      ,[idx_tup_read]
      ,[idx_tup_fetch]
      ,[UpdateDataTimer]
  FROM [SGBD].[MtPgTableIndexStat]

