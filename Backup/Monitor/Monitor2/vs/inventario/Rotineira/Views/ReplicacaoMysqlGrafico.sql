


/**/
CREATE VIEW [Rotineira].[ReplicacaoMysqlGrafico]
as

SELECT RTRIM(LTRIM(B.Servidor)) AS 'Server Slaver'
     , RTRIM(LTRIM(C.Servidor)) AS 'Server Master'
     , [Master_Log_File]
	 , CASE 
		 WHEN [Slave_IO_Running] = 'Yes' AND [Slave_SQL_Running] = 'Yes' THEN ([Read_Master_Log_Pos] / 1024 / 1024)
         WHEN [Slave_IO_Running] = 'No'  OR  [Slave_SQL_Running] = 'No'  THEN 0
	   END AS 'Replicacao'
      ,CONVERT(CHAR(10),[DataTimer],103) AS 'Data'
	  ,CONVERT(CHAR(10),[DataTimer],108) AS 'Hora'
  FROM [SGBD].[MtMySQLReplication] AS A
  INNER JOIN [SGBD].[SGBDServidorProd] AS B ON B.idSGBD = A.idSGBD
  INNER JOIN [SGBD].[SGBDServidorProd] AS C ON C.[IP] = A.[Master_Host] OR C.[IP] = B.IP
  WHERE (B.Servidor LIKE '%sr-dflxbdp067\MySQL%' 
         OR B.Servidor LIKE '%sr-dflxbdp024\MySQL%'
		 OR B.Servidor LIKE '%sr-dflxbdp026\MySQL%'
		 OR B.Servidor LIKE '%sr-dflxbdp056\MySQL%'
		 OR B.Servidor LIKE '%sr-sglxbdp010\MySQL%')
    AND [DataTimer] >= DATEADD(DAY, -3, GETDATE())
	AND [DataTimer] <= GETDATE()



