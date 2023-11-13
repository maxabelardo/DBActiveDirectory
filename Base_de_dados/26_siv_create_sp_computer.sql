

CREATE PROCEDURE [siv].[sp_computer]
as 
BEGIN

TRUNCATE TABLE [gld].[computer]

INSERT INTO [gld].[computer]
SELECT * FROM [brz].[computer]

END
GO

