USE [master]
GO

/****** Object:  LinkedServer [LNK_SQL_SSEBP192016]    Script Date: 09/03/2020 10:16:10 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_SQL_SSEBP192016', @srvproduct=N'S-SEBP19\SQL2016', @provider=N'SQLNCLI', @datasrc=N'S-SEBP19\SQL2016,1435'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_SQL_SSEBP192016',@useself=N'False',@locallogin=NULL,@rmtuser=N'usrsm',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_SQL_SSEBP192016', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


