
CREATE function [dbo].[F_HoraDiaNowZero](@DATA DATETIME) RETURNS DATETIME  AS
begin

declare @DiaCorrido int

declare @Dia datetime
declare @DiaZeroHora datetime

declare @return char(10)


--set @Dia = DateAdd(day, -1 ,@DATA)

set @DiaZeroHora = CONVERT(CHAR(10 ), @DATA, 120) + ' 00:00:00'

RETURN @DiaZeroHora    

end

