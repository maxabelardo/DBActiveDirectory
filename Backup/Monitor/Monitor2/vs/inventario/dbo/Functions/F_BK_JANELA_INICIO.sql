

CREATE function [dbo].[F_BK_JANELA_INICIO](@IDSGBD INT, @DATA DATETIME)  RETURNS DATETIME  AS
begin

declare @J_INICIO char(8)
declare @J_data char(10)
declare @return DATETIME

	SELECT @J_INICIO = convert(char(8),[startJanela],114)
	 FROM [SGBD].[MnSQLBackupJanela]
	  WHERE [idSGBD] = @IDSGBD

   SET @J_data = LEFT(CONVERT(CHAR(10),@DATA,120),10)

   SELECT @return = CAST( (@J_data +' '+ @J_INICIO) AS datetime)
   
RETURN @return 

end


