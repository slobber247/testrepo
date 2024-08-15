----------------------------------------------------------------------------
-- Active Case by Intervention Reason
--
--1226	Incoming ICPC Request 
--5608	Non-CWD Foster Care       
--6129	Non-CWD Mental Health                   
--6130	Non-CWD Kin-GAP 
----------------------------------------------------------------------------

WITH TAB_1 AS 
(
SELECT 	sc.SHORT_DSC county,
		count(*) active_cases	
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.GVR_ENTC
  WHERE c.END_DT IS NULL
GROUP BY c.GVR_ENTC, 
		sc.SHORT_DSC
 ORDER BY c.GVR_ENTC 
),
TAB_2 AS 
( 
SELECT sc.SHORT_DSC county
		,sum(CASE WHEN ir.INTVRSNC = '1226' THEN 1 ELSE 0  END ) AS ir1  
		,sum(CASE WHEN ir.INTVRSNC = '5608' THEN 1 ELSE 0  END ) AS ir2  
		,sum(CASE WHEN ir.INTVRSNC = '6129' THEN 1 ELSE 0  END ) AS ir3
		,sum(CASE WHEN ir.INTVRSNC = '6130' THEN 1 ELSE 0  END ) AS ir4
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER 
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.GVR_ENTC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
 WHERE c.END_DT IS NULL
GROUP BY c.GVR_ENTC, 
		sc.SHORT_DSC
ORDER BY c.GVR_ENTC		
)
SELECT t1.county, 
		t2.ir1 Active_Incoming_ICPC_Request, 
		t2.ir2 Active_Non_CWD_Foster_Care,
		t2.ir3 Active_Non_CWD_Mental_Health,
		t2.ir4 Active_Non_CWD_Kin_GAP,
		t1.active_cases - t2.ir1 - t2.ir2 - t2.ir3 - t2.ir4 OTHERS, 
		t1.active_cases 
  FROM tab_1 t1
  JOIN tab_2 t2 ON t1.county = t2.county


    
 