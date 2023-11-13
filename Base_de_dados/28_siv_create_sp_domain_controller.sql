
CREATE PROCEDURE [siv].[sp_domain_controller]
as 
BEGIN

TRUNCATE TABLE [gld].[domain_controller]

INSERT INTO [gld].[domain_controller]
SELECT * FROM [brz].[domain_controller]

END
GO
