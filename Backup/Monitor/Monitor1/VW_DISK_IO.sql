USE [master]
GO

/****** Object:  View [dbo].[VW_DISK_IO]    Script Date: 19/03/2020 16:53:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VW_DISK_IO] 
AS
SELECT DB_NAME ([vfs].[database_id]) AS [DB]
    ,  mf.name as 'namefile'
	,  LEFT ([mf].[physical_name], 2) AS [Drive]
	, [ReadLatency] = CASE 
						WHEN [num_of_reads] = 0 THEN 0 
						ELSE ([io_stall_read_ms] / [num_of_reads]) 
						END
	, [WriteLatency] = CASE 
						WHEN [num_of_writes] = 0 THEN 0 
							ELSE ([io_stall_write_ms] / [num_of_writes]) 
						END
	, [Latency] = CASE 
					WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 
					ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) 
					END
	, [AvgBPerRead] = CASE 
						WHEN [num_of_reads] = 0 THEN 0 
						ELSE ([num_of_bytes_read] / [num_of_reads]) 
						END
	, [AvgBPerWrite] = CASE WHEN [num_of_writes] = 0 THEN 0 
						ELSE ([num_of_bytes_written] / [num_of_writes]) 
						END
	, [AvgBPerTransfer] = CASE 
							WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 
							ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) 
							END
FROM
    sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN sys.master_files AS [mf]  ON [vfs].[database_id] = [mf].[database_id]  AND [vfs].[file_id] = [mf].[file_id]



GO


