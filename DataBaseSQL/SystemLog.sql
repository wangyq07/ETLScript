CREATE OR REPLACE VIEW kockwidf.vw_systemhealth_log as
SELECT t.inputdatetime,
        CASE
            WHEN t.dayofweek = 0::double precision THEN 'SUNDAY'::text
            WHEN t.dayofweek = 1::double precision THEN 'MONDAY'::text
            WHEN t.dayofweek = 2::double precision THEN 'TUESDAY'::text
            WHEN t.dayofweek = 3::double precision THEN 'WENSDAY'::text
            WHEN t.dayofweek = 4::double precision THEN 'THURSDAY'::text
            WHEN t.dayofweek = 5::double precision THEN 'FRIDAY'::text
            WHEN t.dayofweek = 6::double precision THEN 'SATUDAY'::text
            ELSE NULL::text
        END AS day_of_the_week, 
    t.ticket_duration_inhours AS duration,
    t.category,
    t.ticketstatus, 
    t.description AS remark,
    closeddate
   FROM ( SELECT date_part('dow'::text, to_date("vwGetTicketWorkflowDetails".ticketdetails ->> 'ReportedDate'::text, 'mm/dd/yyyy'::text)) AS dayofweek,
            to_date("vwGetTicketWorkflowDetails".ticketdetails ->> 'ReportedDate'::text, 'mm/dd/yyyy'::text) AS inputdatetime,
            "vwGetTicketWorkflowDetails".ticketdetails ->> 'ProblemArea'::text AS category,
            "vwGetTicketWorkflowDetails".ticket_duration_inhours,
            "vwGetTicketWorkflowDetails".ticketstatus,
            "vwGetTicketWorkflowDetails".closeddate,
            "vwGetTicketWorkflowDetails".description,
            "vwGetTicketWorkflowDetails".workflowname
           FROM kockwidf."vwGetTicketWorkflowDetails"
          WHERE "vwGetTicketWorkflowDetails".workflowid = 2) t;
CREATE OR REPLACE VIEW kockwidf.vw_systemhealth_incident_log_data
AS 
SELECT row_number() OVER (ORDER BY t.inputdatetime) AS rn,
   t.inputdatetime,
            t.day_of_the_week, 
            t.duration, 
            t.category,
             t.ticketstatus,
            t. remarks, 
            t.closeddate,
    t.statisticstype
   FROM ( SELECT  inputdatetime,
             day_of_the_week, 
            duration, 
             category,
             ticketstatus,
             remark AS remarks, 
            closeddate,
            1 AS statisticstype
           FROM kockwidf.vw_systemhealth_log
        UNION
         SELECT t0.inputdatetime,
             t0.day_of_the_week, 
            t0.duration, 
            t0.category,
             t0.ticketstatus,
            t0.remarks, 
            t0.closeddate,
            t0.statisticstype
           FROM ( SELECT row_number() OVER (PARTITION BY  category ORDER BY inputdatetime DESC) AS rn,
                    inputdatetime,
            day_of_the_week, 
             duration, 
            category,
              ticketstatus,
             remark AS remarks, 
            closeddate,
                    0 AS statisticstype
                   FROM kockwidf.vw_systemhealth_log) t0
          WHERE t0.rn = 1) t;
create or replace VIEW kockwidf.VW_SystemHealth_Incident_Log  as
SELECT   ROW_NUMBER() OVER (ORDER BY INPUTDATETIME) RN, CATEGORY, DURATION, INPUTDATETIME  , 
STATISTICSTYPE
FROM      (SELECT   CATEGORY, DURATION, INPUTDATETIME, 1 STATISTICSTYPE
                 FROM      kockwidf.vw_systemhealth_log
                 UNION
                 SELECT   CATEGORY, DURATION, INPUTDATETIME, STATISTICSTYPE
                 FROM      (SELECT   ROW_NUMBER() OVER (PARTITION BY CATEGORY
                                  ORDER BY INPUTDATETIME DESC) RN, CATEGORY, DURATION, INPUTDATETIME, 0 STATISTICSTYPE
                 FROM      kockwidf.vw_systemhealth_log) T0
WHERE   RN = 1) T1;