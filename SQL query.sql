SELECT
    TOP 50
    qs.total_elapsed_time / qs.execution_count AS AvgElapsedTime,
    qs.total_elapsed_time AS TotalElapsedTime,
    qs.execution_count AS ExecutionCount,
    qs.creation_time AS CreationTime,
    qs.last_execution_time AS LastExecutionTime,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset)/2)+1) AS QueryText
FROM
    sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE
    qs.creation_time >= DATEADD(HOUR, -24, GETDATE())
ORDER BY
    AvgElapsedTime DESC;





SELECT TOP 50
    qsqt.query_sql_text,
    qsq.execution_type_desc,
    rs.avg_duration,
    rs.last_duration,
    rs.count_executions
FROM sys.query_store_runtime_stats rs
JOIN sys.query_store_plan qsp ON rs.plan_id = qsp.plan_id
JOIN sys.query_store_query qsq ON qsp.query_id = qsq.query_id
JOIN sys.query_store_query_text qsqt ON qsq.query_text_id = qsqt.query_text_id
ORDER BY rs.avg_duration DESC;
