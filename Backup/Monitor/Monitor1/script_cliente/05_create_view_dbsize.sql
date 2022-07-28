USE [master]
GO

/****** Object:  View [dbo].[VW_DBSIZE]    Script Date: 09/03/2020 10:13:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_DBSIZE]
as
SELECT 
      database_name = DB_NAME(database_id)
    , log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
    , row_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
    , total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2))
FROM sys.master_files WITH(NOWAIT)
GROUP BY database_id

GO


