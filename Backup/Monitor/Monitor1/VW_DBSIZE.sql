USE [master]
GO

/****** Object:  View [dbo].[VW_DBSIZE]    Script Date: 19/03/2020 16:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VW_DBSIZE]
as
SELECT 
      database_name = DB_NAME(database_id)
    , log_size_mb = ROUND(SUM(CASE WHEN type_desc = 'LOG' THEN cast(size as float) END) * 8. / 1024,2 )
    , row_size_mb = ROUND(SUM(CASE WHEN type_desc = 'ROWS' THEN cast(size as float) END) * 8. / 1024,2)
    , total_size_mb = ROUND(SUM(cast(size as float)) * 8. / 1024 ,2)
FROM sys.master_files WITH(NOWAIT)
GROUP BY database_id



GO


