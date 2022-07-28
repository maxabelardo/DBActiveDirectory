


CREATE function [dbo].[F_BK_JANELA_FIM](@IDSGBD INT, @DATA DATETIME)  RETURNS DATETIME  AS
begin

declare @J_INICIO TIME
declare @J_FIM TIME
declare @J_INICIO1 char(10)
declare @J_FIM1 char(10)
declare @J_data char(10)
declare @return DATETIME

	SELECT @J_INICIO = [startJanela]
	     , @J_FIM    = [endJanela]
	 FROM [SGBD].[MnSQLBackupJanela]
	  WHERE [idSGBD] = @IDSGBD


	 IF @J_FIM < @J_INICIO
	    SET @J_data = LEFT(CONVERT(CHAR(10),DATEADD(DAY,1,@DATA),120),10)
     ELSE 
	   BEGIN  
	    SET @J_data = LEFT(CONVERT(CHAR(10),@DATA,120),10)
	   END;

			SELECT @J_FIM1    = convert(char(8),[endJanela],114)
			 FROM [SGBD].[MnSQLBackupJanela]
			  WHERE [idSGBD] = @IDSGBD
 

   SELECT @return = CAST( (@J_data +' '+ @J_FIM1) AS datetime)
   
RETURN @return 

end



