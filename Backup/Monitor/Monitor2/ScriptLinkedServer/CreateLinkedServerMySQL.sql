USE [master]
GO

/****** Object:  LinkedServer [LNK_MYSQL_ServerName]    Script Date: 18/06/2021 11:33:46 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_MYSQL_ServerName', @srvproduct=N'ServerName', @provider=N'MSDASQL', @provstr=N'Driver={MySQL ODBC 5.3 ANSI Driver};DATABASE=mysql;OPTION=134217728;SERVER=ServerIP'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_MYSQL_ServerName',@useself=N'False',@locallogin=NULL,@rmtuser=N'usrsm',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_MYSQL_ServerName', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


