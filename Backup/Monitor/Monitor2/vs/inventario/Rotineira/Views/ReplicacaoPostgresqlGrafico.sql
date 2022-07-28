


CREATE VIEW [Rotineira].[ReplicacaoPostgresqlGrafico]
as

SELECT RTRIM(LTRIM(B.HostName)) AS 'Servidor'
      ,[replication_delay]
      ,CONVERT(CHAR(10),[EventTime],103) AS 'Data'
	  ,CONVERT(CHAR(10),[EventTime],108) AS 'Hora'
  FROM [SGBD].[MtPgReplicationDelayTime] AS A
  INNER JOIN [SGBD].[SGBDServidorProd] AS B ON B.idSGBD = A.idSGBD


