USE [master]
GO

/****** Object:  LinkedServer [LNK_PGSQL_MCSRV217]    Script Date: 21/06/2021 11:28:00 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_PGSQL_MCSRV217', @srvproduct=N'MCSRV217', @provider=N'MSDASQL', @provstr=N'Driver=PostgreSQL Unicode(x64);uid=usrsm;Server=10.0.0.217;database=postgres;pwd=Z34azI8ChLpmLIy3'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_PGSQL_MCSRV217',@useself=N'False',@locallogin=NULL,@rmtuser=N'usrsm',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_PGSQL_MCSRV217', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


