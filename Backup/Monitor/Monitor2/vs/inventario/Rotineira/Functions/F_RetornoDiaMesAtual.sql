



CREATE FUNCTION [Rotineira].[F_RetornoDiaMesAtual]()
RETURNS @TableData TABLE ([DataExecucao] nchar(10),[DataExecucaoDT] DATETIME )
AS
BEGIN
	DECLARE @Cont int
	DECLARE @Data nchar(10)
	DECLARE @DIA  nchar(2)
	DECLARE @DiaMax int

		SELECT @DiaMax =  DAY(dbo.F_UltimmoDiaMesDT(GETDATE()))
		SET @cont = 1

			WHILE @cont <= @DiaMax
			BEGIN

				IF @cont <= 9 
					BEGIN		
						SET @Dia = '0' + LTRIM(STR(@cont)) 
					END
					ELSE
					BEGIN
						SET @Dia = LTRIM(STR(@cont))
					END	
			
						SET @Data = @Dia + RIGHT(CONVERT(nchar(10), GETDATE(), 103),8)

				SET @cont = @cont + 1

				INSERT INTO @TableData([DataExecucao],[DataExecucaoDT]) VALUES (@Data, convert(datetime,(RIGHT(@Data,4)+'/'+RIGHT(LEFT(@Data,5),2)+'/'+LEFT(@Data,2)) , 111))	 
			END

	RETURN

END



