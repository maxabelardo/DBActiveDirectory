USE [master]
GO

/****** Object:  StoredProcedure [dbo].[SP_SlowQueryCPU]    Script Date: 19/03/2020 16:55:13 ******/
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
CREATE PROCEDURE [dbo].[SP_SlowQueryCPU]
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

	
;with high_io_queries as
(   select top 10 
        query_hash, 
        sum(total_logical_reads + total_logical_writes) io
    from sys.dm_exec_query_stats 
    where query_hash <> 0x0
    group by query_hash
    order by sum(total_elapsed_time) desc
)
select  
       @@servername as [Servidor]
     , coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName]

     , CONVERT(TIME, DATEADD(SECOND, round((cast(total_worker_time as money) / 1000000),2), 0), 114)                           as 'SomaTempo2ExecCPU'	
	 , CONVERT(TIME, DATEADD(SECOND, round((cast(total_worker_time / (execution_count + 0.0) as money) / 1000000),2), 0), 114) as 'MedioTempoExecCPU' 
	 , qs.execution_count as 'TotalExecQuery'

     , SUBstRING(st.TEXT,(qs.statement_start_offset + 2) / 2,
        (CASE 
            WHEN qs.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),st.text)) * 2
            ELSE qs.statement_end_offset
            END - qs.statement_start_offset) / 2) as sql_text
    ,CAST(qp.query_plan AS varchar(MAX)) AS 'query_plan'
	INTO #MtDbTable1
from sys.dm_exec_query_stats qs
join high_io_queries lq
    on lq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
where pa.attribute = 'dbid'
  and qp.query_plan is not null
order by CONVERT(TIME, DATEADD(SECOND, round((cast(total_worker_time / (execution_count + 0.0) as money) / 1000000),2), 0), 114) desc
option (recompile)


select * from #MtDbTable1
                       
DROP TABLE #MtDbTable1 

END








GO


