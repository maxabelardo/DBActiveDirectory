CREATE PROCEDURE [siv].[sp_user]
as 
BEGIN

TRUNCATE TABLE [gld].[user]

INSERT INTO [gld].[user]
SELECT * FROM [brz].[user]



END
GO

