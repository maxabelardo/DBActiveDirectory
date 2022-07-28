USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_TablesSize]    Script Date: 19/03/2020 16:57:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		José Abelardo 
-- Create date: 11/03/2020
-- Description:	SP de documentação
-- =============================================
/**/
CREATE PROCEDURE [dbo].[SP_TablesSize]
AS
BEGIN
/* *************************************************************************************************/
/*                     Estes script tem a finalidade de monitora todas as bases                    */
/*                            e seus resulados seram utilizados                                    */
/*                                para criação de  relatorios								       */
/***************************************************************************************************/

 ----------------------------------------------------------------------------------------------------
 ---- Descrição do Script 
 ---- Este script lista todas as tabelas com o seu tamanho e o total de linhas.
 ----------------------------------------------------------------------------------------------------


/******* Criação das trabelas temporarias *********/

	
		/*** Tebela que vai receber as informações das tabelas por databases ***/
		CREATE TABLE #MtDbTableSize(
			[Servidor] [varchar](255) NULL,
			[base] [varchar](255) NULL,
			[schema_name] [varchar](255) NULL,
			[table_name] [varchar](255) NULL,
			[ReservadoKB] [real] NULL,
			[DadosKB] [real] NULL,
			[IndicesKB] [real] NULL,
			[TotalLinhas] [int] NULL)

			declare @SqlCommand nvarchar(4000)

	set @SqlCommand = 'USE ['+ '?'  +']' 
	+'  '+
' ;with table_space_usage (schema_name,table_Name,index_Name,used,reserved,ind_rows,tbl_rows,type_Desc)
AS(
select s.name, o.name,coalesce(i.name,''heap''),p.used_page_Count*8,
p.reserved_page_count*8, p.row_count ,
case when i.index_id in (0,1) then p.row_count else 0 end, i.type_Desc
from sys.dm_db_partition_stats p
join sys.objects o on o.object_id = p.object_id
join sys.schemas s on s.schema_id = o.schema_id
left join sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
where o.type_desc = ''user_Table'' and o.is_ms_shipped = 0
)

	select t.schema_name, t.table_Name,t.index_Name ,sum(t.used) as used_in_kb,
	sum(t.reserved) as reserved_in_kb,
	case grouping (t.index_Name) when 0 then sum(t.ind_rows) else sum(t.tbl_rows) end as rows,type_Desc
	into #tabelas
	from table_space_usage t
	group by t.schema_name, t.table_Name,t.index_Name,type_Desc
	with rollup
	order by grouping(t.schema_name),t.schema_name,grouping(t.table_Name),t.table_Name,
	grouping(t.index_Name),t.index_Name


			select schema_name sc_name
					, table_Name tb_ame
					, sum(reserved_in_kb) [Reservado (KB)]
					, sum(case 
						when type_Desc in (''CLUSTERED'',''HEAP'') then reserved_in_kb 
							else 0 
							end) [Dados (KB)]
					, sum(case 
						when type_Desc in (''NONCLUSTERED'') then reserved_in_kb 
						else 0 
						end) [Indices (KB)]
				, max(rows) Qtd_Linhas
			into #Resultado_Final
			from #tabelas
			where index_Name is not null
					and type_Desc is not null
			group by schema_name, table_Name
			
insert into #MtDbTableSize
			([Servidor],
			[base],
			[schema_name],
			[table_name],
			[ReservadoKB],
			[DadosKB],
			[IndicesKB],
			[TotalLinhas])
	select @@SERVERNAME as  [Servidor]
		 ,''' + '?' + ''' as base
	     , sc_name
	     , tb_ame
		 , [Reservado (KB)]
		 , [Dados (KB)]
		 , [Indices (KB)]
	     , [Qtd_Linhas]
	from #Resultado_Final
																	
	drop table #tabelas
	drop table #Resultado_Final

	'				
				--PRINT @SqlCommand					
				EXEC sp_MSforeachdb @SqlCommand		

SELECT * FROM #MtDbTableSize 
				   
                       
DROP TABLE #MtDbTableSize 

END



GO


