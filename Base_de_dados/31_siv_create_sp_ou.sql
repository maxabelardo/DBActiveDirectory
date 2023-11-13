CREATE PROCEDURE [siv].[sp_ou]
as 
BEGIN

TRUNCATE TABLE [gld].[ou]

INSERT INTO [gld].[ou]
SELECT * FROM [brz].[ou]

END
GO


