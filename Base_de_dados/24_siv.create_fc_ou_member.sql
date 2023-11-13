

CREATE FUNCTION [siv].[fc_ou_member]()
Returns @res TABLE ([OUName] Nvarchar(max) NULL, [OU] Nvarchar(max) NULL,[Tipo] Nvarchar(20) NULL,[SID] Nvarchar(max) NULL, [Member] Nvarchar(max) NULL,[SamAccountName] Nvarchar(max) NULL )
AS
BEGIN

DECLARE @SID Nvarchar(max)
DECLARE @Name Nvarchar(max)
DECLARE @DistinguishedName Nvarchar(max)
DECLARE @SamAccountName Nvarchar(max)


DECLARE db_for CURSOR FOR

	SELECT  [SID],[Name],[DistinguishedName],[SamAccountName]
	  FROM  [brz].[user] 
		WHERE LEN(DistinguishedName) > 0

OPEN db_for 
FETCH NEXT FROM db_for INTO @SID, @Name, @DistinguishedName, @SamAccountName

WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO @res
		SELECT M.OU
		     , M.[DistinguishedName]
			 , 'organizationalUnit'
			 , @SID
			 , @Name
			 , @SamAccountName
		FROM  [siv].[fc_return_ou_objetos] (@Name,@DistinguishedName) AS M

	FETCH NEXT FROM db_for INTO  @SID, @Name, @DistinguishedName, @SamAccountName
END

CLOSE db_for
DEALLOCATE db_for

RETURN;
END;

GO


