---------------------------------
-- Focus on CASE_TYPES  Non-Related Guardianship
--   16) Juvenile Dependency Court / WIC 300, without Dependency
-----------------------------------------------------------------------------
-- Non-Related Legal Guardianship 
-- Juvenile Dependency Court/WIC 300 w/o Dependency
-- **NOTE- Same Query as #15 but add Court_Result table  
-- #183
-- Q: How do you tell its WIC 300? This is tied to Legal Authority
----------------------------------------------------------------------------------
--#571 Distinct w/hearing date
 SELECT DISTINCT 
-- 		count(*)  
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
--	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
  	  vs.END_DT voluntary_status_end_dt,
--	  ir.INTVRSNC,
	  --la.THIRD_ID legal_authority_id,  	  
	  sc2.SHORT_DSC Intervention_Rsn,
	  sc4.SHORT_DSC Legal_Authority,
--  	  cs.SRV_CMPC, cs.EFFECTV_DT, cs.END_DT  
 	  ht.IDENTIFIER hearing_id,
	  ht.HEARING_DT, 
	  cr.IDENTIFIER Court_result_id,
	  cr.FNDGORDC, 
	  sc3.SHORT_DSC court_order,
	  ch.FKHEARNG_T hearing_id, ch.LST_UPD_TS hearing_lst_upt,  
	  ch.CHR_RSLT_B,
	  cr.FKCASE_HR0, cr.FKCASE_HRT  
  FROM CWSWIN.CASE_T c												-- CASE table
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 			-- JOIN Child Client table
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T			-- JOIN Client table
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 			-- JOIN CASE Voluntary Status table
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER				-- JOIN Intervention Reason table
  --
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER 			-- JOIN Placement Episode table
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID			-- JOIN Plcmnt Episode Legal Authority table
--
  JOIN CWSWIN.CASE_HRT ch ON ch.FKCASE_T = c.IDENTIFIER 			-- JOIN Case Hearing table
  JOIN cwswin.HEARNG_T ht ON ht.IDENTIFIER = ch.FKHEARNG_T 			-- JOIN Hearing table
  JOIN CWSWIN.CT_RESLT cr ON cr.FKCASE_HRT = c.IDENTIFIER			-- JOIN Court RESULT table
--  
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
  JOIN CWSWIN.SYS_CD_C sc3 ON sc3.SYS_ID = cr.FNDGORDC  
  JOIN CWSWIN.SYS_CD_C sc4 ON sc4.SYS_ID = la.PLC_ATHC 
 WHERE c.SRV_CMPC = 1695		--	Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary
   AND ((vs.END_DT IS NULL)   		-- CURRENT Voluntary Status
     		OR (vs.START_DT = (SELECT MAX(vs2.START_DT) FROM CWSWIN.CSVOL_ST vs2 WHERE vs2.FKCASE_T = c.IDENTIFIER) AND vs.END_DT IS NOT NULL)  -- OR latest voluntary rec
       )
   --    
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
--   AND ir.LST_UPD_TS = (SELECT max(ir2.LST_UPD_TS) FROM CWSWIN.INTV_RNT ir2 WHERE ir2.FKCASE_T = c.IDENTIFIER)		--- latest Intervention Reason
   --
   AND ((pe.PLEPS_ENDT IS NULL) 	-- CURRENT Placement Episode
  			OR (pe.PLEPS_ENDT = (SELECT MAX(pe2.PLEPS_ENDT) FROM CWSWIN.PLC_EPST pe2 WHERE pe2.FKCLIENT_T = ct.IDENTIFIER) AND pe.PLEPS_ENDT IS NOT NULL) -- OR latest Placement Episode
   	   )
   --	   
   AND la.PLC_ATHC = 1404		-- Guardian Non-RELATIVE
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND la.EFFCTV_DT = (SELECT max(la2.EFFCTV_DT) FROM CWSWIN.LG_AUTHT la2 WHERE la2.FKPLC_EPS0 = pe.THIRD_ID AND la2.FKPLC_EPST = pe.FKCLIENT_T) --latest Legal Authority
  --	
   AND ch.CHR_RSLT_B = 'Y'		-- has associated Court RESULT record
   AND ch.FKHEARNG_T = cr.FKCASE_HR0 -- link TO latest Hearing WITH Court Results
 --  AND ch.LST_UPD_TS = (SELECT MAX(ch2.LST_UPD_TS) FROM CWSWIN.CASE_HRT ch2 WHERE ch2.FKCASE_T = c.IDENTIFIER AND ch2.FKHEARNG_T = cr.FKCASE_HR0 )
  -- 
    AND ((ht.HEARING_DT > current_date    
         AND ht.HEARING_DT != '2099-12-31')
         			OR
   		-- look for prior hearing w/o court results	**WORKS!!
	    (ht.HEARING_DT < current_date
	     AND ht.HEARING_DT = (SELECT max(ht2.hearing_dt) 				-- GET most recent hearing record based ON date
 			  	 	 			FROM cwswin.HEARNG_T ht2 			
						  		JOIN cwswin.CASE_HRT ch3 ON ch3.FKHEARNG_T = ht2.IDENTIFIER 
						 	   WHERE ch3.FKCASE_T = c.IDENTIFIER) 		
		))	
	--					 	   
   AND cr.FNDGORDC IN (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated
   AND cr.FKCASE_HR0 = ch.FKHEARNG_T 
  -- test data w dups  
 --AND c.IDENTIFIER = 'R3A99Mn194'
  --ORDER BY client_id 		-- by client IDENTIFIER 
	ORDER BY c.IDENTIFIER  -- BY CASE IDENTIFIER 
   
----------------------------------------------------------
-- CASE 
----------------------------------------------------------   
SELECT c.IDENTIFIER , c.SRV_CMPC, sc.SHORT_DSC, c.START_DT, c.END_DT, c.FKCHLD_CLT  
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC 
 WHERE c.IDENTIFIER = 'R3A99Mn194'	--'R3A99Mn194'
-- WHERE c.SRV_CMPC = 1695 
 
  
--------------------------------------------------------------------  
-- Case Service Component
-- s/b Permanent Placement  
--------------------------------------------------------------------  
SELECT cs.IDENTIFIER, EFFECTV_DT, END_DT, SRV_CMPC, 
		sc.SHORT_DSC SC_TYPE, sc.FKS_META_T, 
		--LST_UPD_ID, LST_UPD_TS, 
		FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CS_SVCMT cs
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = cs.SRV_CMPC 
 WHERE cs.FKCASE_T = 'R3A99Mn194'	--'AaavA3P8mB'		--'AYPC4Wwdik'
 ORDER BY cs.EFFECTV_DT 

-- service component types 
SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'SRV_CMPC' 
 
1692	Emergency Response                      
1693	Family Maintenance                      
1694	Family Reunification                    
1695	Permanent Placement                     
6540	Supportive Transition                    
 
--------------------------------------------------------------------  
-- Case Voluntary Status  
-- s/b VLNTRY_IND = 'N'
--------------------------------------------------------------------  
-- multiple records per case  -- look for null date in end date for latest
SELECT THIRD_ID, START_DT, END_DT, VLNTRY_IND, LST_UPD_ID, LST_UPD_TS, FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CSVOL_ST cv
 WHERE cv.FKCASE_T = 'R3A99Mn194'  --'R3A99Mn194' 
--   AND cv.END_DT IS NULL 
 ORDER BY cv.START_DT 
   
SELECT MAX(vs2.end_dt) FROM CWSWIN.CSVOL_ST vs2 WHERE vs2.FKCASE_T = 'R3A99Mn194'

----------------------------------------------------------------------
-- Intervention Reason 
-- s/b 1225 -- Guardian Requesting FC Payment
----------------------------------------------------------------------
SELECT ir.THIRD_ID, INTVRSNC, 
		sc.SHORT_DSC intervention_reason,	
		ir.LST_UPD_ID, ir.LST_UPD_TS, FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.INTV_RNT ir
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = ir.INTVRSNC  
 WHERE ir.FKCASE_T = 'R3A99Mn194'


-------------------------------------------------------------------- 
-- Placement Episode 
-- Client can have multiple Episodes 
-- s/b pull open placement where pleps_endt is null  
--------------------------------------------------------------------
SELECT  --REMOVAL_DT, --AGY_RSPC, ASGN_SW_CD, ELIG_WK_CD, CHL_RGT_CD, DETNORD_DT, DSP_ORD_DT,
		FKCLIENT_T, THIRD_ID,
		PLEPS_ENDT, 
		NFC_PLCT_B, OUT_CST_DT, OUT_CST_TM, PETN_FILDT, FCISRVWT_B, FCISHRGT_B, 
		PRVT_SVC, RLS_RSNC, RMV_RSNC, REMOVAL_TM, RMV_BY_ID, RMV_BY_CD, RMV_FRM_NM, RMV_FRM1C,
		TMP_CSTIND, LST_UPD_ID, LST_UPD_TS, COMNT_DSC, END_ENT_DT, RMV_ENT_DT, 
		RMVCR1_ID, RMVCR1_CD, RMVCR2_ID, RMVCR2_CD, RMV_FRM2C, TERM_RS_CD, TERM_DSC, TERM_TY_C, 
		FMLYSTR_CD, BIRTHYR1, BIRTHYR2, RSFSURB_NM, GVR_ENTC, PLC24HR_CD
 FROM CWSWIN.PLC_EPST pe
--WHERE pe.FKCLIENT_T = 'Imtyopx6eS' 
--  AND pe.PLEPS_ENDT IS null
WHERE pe.FKCLIENT_T = 'RLuo893194'
 -- AND pe.PLEPS_ENDT IS NULL 
  
  
-------------------------------------------------------------------- 
-- Placement Episode Legal Authority
-- la.FKPLC_EPST = pe.FKCLIENT_T  
-- la.FKPLC_EPS0 = pe.THIRD_ID  
-- s/b 1404 -- Guardian Non-RELATIVE
--------------------------------------------------------------------
SELECT la.THIRD_ID, EFFCTV_DT, PLC_ATHC, la.LST_UPD_ID, la.LST_UPD_TS, 
		FKPLC_EPST, FKPLC_EPS0
		,sc.SHORT_DSC 
  FROM CWSWIN.LG_AUTHT la
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = la.PLC_ATHC 
 --WHERE la.PLC_ATHC = 1404   --PE Legal Authority = 'Guardian Non-Relative'   
--  WHERE la.PLC_ATHC IN ( 1404, 1409, 1410, 1411 )
 WHERE la.FKPLC_EPST = 'RLuo893194'   -- client id
 --  and la.FKPLC_EPS0  = '1T8nKlN194'  -- Episode THIRD_ID 


-------------------------------------------------   
-- Case Hearing -- can have multiple records with same latest update
-------------------------------------------------   
SELECT CHR_RSLT_B, HRNG_TPC, 
		sc.SHORT_DSC, 
		SUBTYP_DSC	, ch.LST_UPD_ID, ch.LST_UPD_TS, FKHEARNG_T, FKCASE_T, RESULT_TXT, RESULT_C, CNTY_SPFCD, RSLCNT_IND
  FROM CWSWIN.CASE_HRT ch
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = ch.HRNG_TPC 
 WHERE ch.FKCASE_T = 'R3A99Mn194'
   --AND ch.FKHEARNG_T IN ('GLq9ykDQ1a', 'J9T1GJuQ1a')
   AND ch.LST_UPD_TS = (SELECT MAX(ch2.LST_UPD_TS) FROM CWSWIN.CASE_HRT ch2 WHERE ch2.FKCASE_T = ch.FKCASE_T)-- AND ch2.FKHEARNG_T = ch.FKCASE_HR0 ) -- latest CH record by CASE
   
--------------------------------------------------------    
-- Hearing
--------------------------------------------------------   
SELECT IDENTIFIER, CIT_SUBT_B, CNTHRG_C, CT_DEPT_NO, HEARING_DT, CT_SUM_DOC, HRG_ATNT_B, JDCL_OFFNM, JDCL_TLC, LANG_TPC, PT_HRG_T_B, HEARING_TM, LST_UPD_ID, LST_UPD_TS, FKCOURT_T, ATNDEE_DSC, HR_NTE_DSC, NEXT_HR_DT, NEXT_HR_TM, CNTY_SPFCD
  FROM CWSWIN.HEARNG_T h
 WHERE h.IDENTIFIER  IN ('5pPj7Li1AK') 

-------------------------------------------------
-- COURT_RESULT  -- Can have multiple records
-- #22,047,227
-- cr.FKCASE_HRT = Case id
-- cr.FKCASE_HR0 = Hearing id 
-- s/b (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated 
------------------------------------------------- 
  
SELECT IDENTIFIER, FNDGORDC, 
		sc.SHORT_DSC,
		CASE FNDG_ORDCD 
		   WHEN 'F' THEN 'Court Finding Type'
		   WHEN 'O' THEN 'Court Order Type'
		END hearing_type,  
		cr.LST_UPD_ID, cr.LST_UPD_TS, 
		FKCASE_HRT, FKCASE_HR0, CNTY_SPFCD, FKRV_HRT, FKRV_HR0, FKRV_HR1
  FROM CWSWIN.CT_RESLT cr
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = cr.FNDGORDC  
-- WHERE cr.FNDGORDC IN (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated                                    
  WHERE  cr.FKCASE_HRT = 'R3A99Mn194'	--Case id	--'CrcLcmZ84l' --duplicate has BOTH findings ON same DAY 
    AND cr.FKCASE_HR0 = '5pPj7Li1AK' --'4sGwLmNNRD' --Hearing id
    
    
 --------------------------------------------------------
 -- Sys tables list of Legal Authority (18 types)
 --------------------------------------------------------
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'PLC_ATHC'
  
 
1404	Guardian Non-Relative                   
1409	WIC 300 a, b, c, d, f, g, i or j        
1410	WIC 300e                                
1411	WIC 300h                                

--------------------------------------------------------
 -- Sys tables list of Interventin Reasons
--------------------------------------------------------
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'SCP_RLTC'	--'INTVRSNC'
  

