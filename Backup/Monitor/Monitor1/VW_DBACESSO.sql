USE [master]
GO

/****** Object:  View [dbo].[VW_DBACESSO]    Script Date: 19/03/2020 16:53:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create view [dbo].[VW_DBACESSO]
AS
select DB_NAME (dbid)as namedb,loginame,cpu,hostname,program_name,dbid, status,blocked,login_time,spid
from master.sys.sysprocesses


GO


