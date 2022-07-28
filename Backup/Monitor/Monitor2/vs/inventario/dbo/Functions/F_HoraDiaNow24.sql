
CREATE function [dbo].[F_HoraDiaNow24](@DATA DATETIME) RETURNS DATETIME  AS
begin

declare @Dia datetime
declare @Dia24Hora datetime

declare @return char(10)


--set @Dia = DateAdd(day, -1 ,@DATA)

set @Dia24Hora = CONVERT(CHAR(10 ), @DATA, 120) + ' 23:59:59'

RETURN @Dia24Hora    

end

