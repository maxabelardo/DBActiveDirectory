CREATE PROCEDURE [siv].[sp_gpo]
as 
BEGIN

TRUNCATE TABLE [gld].[gpo]

INSERT INTO [gld].[gpo]
SELECT * FROM [brz].[gpo]

END
GO

