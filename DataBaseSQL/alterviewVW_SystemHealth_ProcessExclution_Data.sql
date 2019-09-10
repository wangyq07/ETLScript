--alter view VW_SystemHealth_ProcessExclution_Data as
SELECT   date, LEVELNAME, SUM(elipsetime) AS datavalue, CASE WHEN SUM(errors) > 0 THEN 0 ELSE 1 END AS status
FROM      (SELECT   DATEADD(MM, 3, CAST(CONVERT(varchar(10), ENDDATE, 121) AS DATETIME)) AS date, LOGDATE, 
                                 ENDDATE, CASE WHEN jobname IN ('KwIDF_Get_Finder_WaterInjection', 
                                 'KwIDF_Get_Finder_WaterInjection_Success_2', 'KwIDF_Get_Finder_WellData', 
                                 'KwIDF_Get_Finder_LevelDailyData', 'KwIDF_Get_Finder_WellDailyData') 
                                 THEN 'Transfer Finder Data' WHEN JOBNAME LIKE '%PETEX%' THEN 'Transfer IVM Data' WHEN jobname LIKE '%ALMS%'
                                  THEN 'Transfer ALMS Data' WHEN JOBNAME LIKE '%PHD%' THEN 'Transfer PHD Data' WHEN JOBNAME LIKE
                                  '%OpenWell%' THEN 'Transfer EDM Data' ELSE NULL END AS LEVELNAME, DATEDIFF(second, ENDDATE, 
                                 LOGDATE) AS elipsetime, ISNULL(ERRORS, 0) AS errors
                 FROM      
				 
				 ( SELECT
 JOBNAME,ENDDATE,LOGDATE,ERRORS
 FROM
 (
 SELECT
				 ROW_NUMBER()OVER(PARTITION BY JOBNAME,CAST(ENDDATE AS DATE) ORDER BY ENDDATE DESC) RN,JOBNAME,ENDDATE,LOGDATE,ERRORS
				FROM [log].ETL_Log_Job AS t
				WHERE (JOBNAME LIKE '%FINDEr%' OR JOBNAME LIKE '%PETEX%' OR jobname LIKE '%ALMS%' OR JOBNAME LIKE '%PHD%' OR JOBNAME LIKE
                                  '%OpenWell%') AND
								  EXISTS((SELECT   1  
                                      FROM      (SELECT   JOBNAME, DATEADD(mm, - 2, MAX(ENDDATE)) AS ddate
                                                       FROM      [log].ETL_Log_Job
                                                       GROUP BY JOBNAME) AS tt
                                      WHERE   (t.ENDDATE >= ddate) AND (JOBNAME = t.JOBNAME)) )
									  ) T
									  WHERE RN=1 
                    ) T0 ) TT
WHERE   (LEVELNAME IS NOT NULL) and LEVELNAME='Transfer IVM Data'
GROUP BY date, LEVELNAME
order by date desc