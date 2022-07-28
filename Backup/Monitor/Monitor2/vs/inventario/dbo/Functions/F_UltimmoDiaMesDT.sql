
CREATE function [dbo].[F_UltimmoDiaMesDT](@DATA DATETIME) RETURNS DATETIME  AS
begin

--declare @DATA DATETIME
declare @DiaCorrido int
declare @FimDoMes datetime
declare @InicioDoMes datetime
declare @return datetime

--set @DATA = GETDATE()
--Descobrindo quantos dias já foi percorrido
set @DiaCorrido = DATEPART(day,@DATA)

-- Pegando o primeiro dia do mês corrente
set @InicioDoMes = DateAdd(day,(- @DiaCorrido) + 1 ,@DATA)

-- Pegando o ultimo dia do mês corrente
set @FimDoMes =  DATEADD(DAY,-1,DATEADD(MONTH,1,@InicioDoMes))

set @return = CONVERT(CHAR(10 ), @FimDoMes, 120) + ' 23:59:59'
--Apresentando o resultado
--select @DiaCorrido
--select @InicioDoMes, @FimDoMes, @DiaCorrido  -- 01/06/2011

--SET @return = @FimDoMes
RETURN @return    -- 30/06/2011

end

