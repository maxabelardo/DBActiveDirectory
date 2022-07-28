USE [master]
GO

/****** Object:  LinkedServer [LNK_SQL_PETLA]    Script Date: 22/06/2021 08:26:46 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_SQL_PETLA', @srvproduct=N'PETLA', @provider=N'SQLNCLI11', @datasrc=N'PETLA'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_SQL_PETLA',@useself=N'False',@locallogin=NULL,@rmtuser=N'usrsm',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_PETLA', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


