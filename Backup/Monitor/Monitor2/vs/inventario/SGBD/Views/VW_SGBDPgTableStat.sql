
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

