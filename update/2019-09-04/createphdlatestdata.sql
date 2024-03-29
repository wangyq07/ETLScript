use dspstore
go
CREATE VIEW VW_SystemHealth_PHDLatelyData as
SELECT  
cast(timestamp as date) inputtime,
sum(case when FLP = 6 then 1 else 0 end) 
+ sum(case when whp = 6 then 1 else 0 end) 
+sum(case when dischargepressure = 6 then 1 else 0 end) 
+sum(case when Frequency = 6 then 1 else 0 end)
+sum(case when IntakePressure = 6 then 1 else 0 end)
+sum(case when Amperage = 6 then 1 else 0 end) fvalue,  
sum(6) sumvalue 
FROM PHDWellRealTimeStatus ps
where exists(select 1 from (select dateadd(mm,-1,max(TimeStamp)) tsp from PHDWellRealTimeStatus) t where t.tsp<=ps.TimeStamp)
group by cast(timestamp as date)
go

alter VIEW [dbo].[VW_SystemHealth_Connectivity_DataQuality]
AS
select
row_number() OVER (ORDER BY INPUTDATETIME DESC) rn, LEVEL_NAME, ctarget, cactual, dtarget,

case when phd.fvalue is not null then phd.fvalue else dactual end dactual, 
INPUTDATETIME, STATISTICSTYPE,case when phd.sumvalue is not null then phd.sumvalue else 1 end sumvalue
from
(
SELECT   LEVEL_NAME, 95 ctarget, CASE WHEN SYS_LOG_CASE_ID = 14 THEN 0 ELSE 1 END cactual, 95 dtarget, 
                                 CASE WHEN SYS_LOG_CASE_ID = 14 THEN 0 ELSE 1 END dactual, datetime INPUTDATETIME, 
                                 1 STATISTICSTYPE
                 FROM      SYS_RUN_LOG
                 WHERE   SYS_LOG_CASE_ID IN (14, 15)
                 UNION
                 SELECT   LEVEL_NAME, ctarget, cactual, dtarget, dactual, INPUTDATETIME, 0 STATISTICSTYPE
                 FROM      (SELECT   row_number() OVER (partition BY level_name
                                  ORDER BY datetime DESC) rn, LEVEL_NAME, 95 ctarget, 
                                 CASE WHEN SYS_LOG_CASE_ID = 14 THEN 0 ELSE 1 END cactual, 95 dtarget, 
                                 CASE WHEN SYS_LOG_CASE_ID = 14 THEN 0 ELSE 1 END dactual, datetime INPUTDATETIME
                 FROM      SYS_RUN_LOG
                 WHERE   SYS_LOG_CASE_ID IN (14, 15)) t0
WHERE   rn = 1
) ata
left join
(
select 'PHD' Levelname,inputtime,fvalue,sumvalue,1 satis from VW_SystemHealth_PHDLatelyData where inputtime <=getdate()
union
select Levelname,inputtime,fvalue,sumvalue,  0 satis
from
(
select row_number()over(order by inputtime) rn, 'PHD' Levelname,inputtime,fvalue,sumvalue  
from VW_SystemHealth_PHDLatelyData where inputtime <=getdate()
) t0
where t0.rn=1
) phd
on phd.Levelname=ata.LEVEL_NAME and phd.satis=ata.STATISTICSTYPE
and phd.inputtime=cast(ata.inputdatetime as date)
go