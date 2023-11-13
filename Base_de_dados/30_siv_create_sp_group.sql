
CREATE PROCEDURE [siv].[sp_group]
as 
BEGIN

TRUNCATE TABLE [gld].[group]

INSERT INTO [gld].[group]
SELECT * FROM [brz].[group]

END
GO
