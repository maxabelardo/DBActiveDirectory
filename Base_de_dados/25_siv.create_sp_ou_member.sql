
CREATE PROCEDURE [siv].[sp_ou_member]
as 
BEGIN

TRUNCATE TABLE [gld].[ou_member]


INSERT INTO  [gld].[ou_member]
           ([OU]
           ,[DistinguishedName]
           ,[Tipo]
           ,[SID]
           ,[Member]
           ,[SamAccountName])
SELECT * FROM  [siv].[fc_ou_member]()

END;