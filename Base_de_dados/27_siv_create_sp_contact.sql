CREATE PROCEDURE [siv].[sp_contact]
as 
BEGIN

TRUNCATE TABLE [gld].[contact]

INSERT INTO [gld].[contact]
SELECT * FROM [brz].[contact]

END
GO