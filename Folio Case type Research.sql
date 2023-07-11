---------------------------------
-- Focus on CASE_TYPES  Non-Related Guardianship
--   1) Juvenile Dependency Court / WIC 300, with Dependency
--   2) Juvenile Dependency Court / WIC 300, without Dependency
--	 3) Probate Court (latest Out Home Placement (O_HM_PLT) )
-----------------------------------------------------------------------------

-- Case counts by Case Service Component
SELECT count(*), 
		c.SRV_CMPC, sc.SHORT_DSC  
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
GROUP BY c.SRV_CMPC, sc.short_dsc 

200928	1692	Emergency Response                      
1097482	1693	Family Maintenance                      
237582	1694	Family Reunification                    
481765	1695	Permanent Placement                     
38100	6540	Supportive Transition                   

---------------------------------------------------------------------
--   1) Juvenile Dependency Court / WIC 300, with Dependency
-- #143
-- Q: How do you tell its WIC 300? This is tied to Legal Authority
---------------------------------------------------------------------
SELECT  --count(*) 
--  		DISTINCT 
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
--	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
--	  ir.INTVRSNC,
	  sc2.SHORT_DSC Intervention_Rsn
--  	  cs.SRV_CMPC, cs.EFFECTV_DT, cs.END_DT  
  FROM CWSWIN.CASE_T c										  -- CASE table	
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 	  -- JOIN Child Client
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T	  -- JOIN CLIENT 
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 	  -- JOIN CASE Voluntary Reason
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER		  -- JOIN Intervention Reason
  --
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER    -- JOIN Placement Episode
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID	  -- JOIN Placement Episode Legal Authority
--  JOIN cwswin.CS_SVCMT cs ON cs.FKCASE_T = c.IDENTIFIER
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
 WHERE c.SRV_CMPC = 1695		-- Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 1404		-- Guardian Non-RELATIVE
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
 --  AND c.IDENTIFIER = 'AaS77uzGQv'
 
-- Case Counts
-- 481,765    --	Permanent Placement
--  25,273	  --    w/ Non Voluntary = 'N'			   
--     353    --    w/ Guardian Requesting FC Payment
--     322	  --    w/Placement Episode (current)   
--	   143	  --    2/Legal Authority = 'Guardian Non-Relative'
SELECT  count(*) 
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER  
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID 
 WHERE c.SRV_CMPC = 1695		--	Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment   
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 1404		-- Guardian Non-RELATIVE
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
--   AND c.IDENTIFIER = 'AaS77uzGQv'
   
----------------------------------------------------------
-- CASE 
----------------------------------------------------------   
SELECT c.IDENTIFIER , c.SRV_CMPC, sc.SHORT_DSC  
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC 
 WHERE c.IDENTIFIER = 'AaS77uzGQv'
-- WHERE c.SRV_CMPC = 1695 
 
  
--------------------------------------------------------------------  
-- Case Service Component  
--------------------------------------------------------------------  
SELECT cs.IDENTIFIER, EFFECTV_DT, END_DT, SRV_CMPC, 
		sc.SHORT_DSC SC_TYPE, sc.FKS_META_T, 
		--LST_UPD_ID, LST_UPD_TS, 
		FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CS_SVCMT cs
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = cs.SRV_CMPC 
 WHERE cs.FKCASE_T = 'AaavA3P8mB'		--'AYPC4Wwdik'
 ORDER BY cs.EFFECTV_DT 

 
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
--------------------------------------------------------------------  
-- multiple records per case  -- look for null date in end date for latest
SELECT THIRD_ID, START_DT, END_DT, VLNTRY_IND, LST_UPD_ID, LST_UPD_TS, FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CSVOL_ST cv
 WHERE cv.FKCASE_T = 'AaS77uzGQv' 
   AND cv.END_DT IS NULL 
   


-------------------------------------------------------------------- 
-- Placement Episode 
-- Client can have multiple Episodes   
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
WHERE pe.FKCLIENT_T = 'KyGpfK89YH'
  AND pe.PLEPS_ENDT IS NULL 
  
  
-------------------------------------------------------------------- 
-- Placement Episode Legal Authority
-- la.FKPLC_EPST = pe.FKCLIENT_T  
-- la.FKPLC_EPS0 = pe.THIRD_ID  
--------------------------------------------------------------------
SELECT la.THIRD_ID, EFFCTV_DT, PLC_ATHC, --LST_UPD_ID, LST_UPD_TS, 
		FKPLC_EPST, FKPLC_EPS0
		,sc.SHORT_DSC 
  FROM CWSWIN.LG_AUTHT la
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = la.PLC_ATHC 
 --WHERE la.PLC_ATHC = 1404   --PE Legal Authority = 'Guardian Non-Relative'   
--  WHERE la.PLC_ATHC IN ( 1404, 1409, 1410, 1411 )
 WHERE la.FKPLC_EPST = 'KyGpfK89YH'
-- WHERE la.FKPLC_EPS0  = 'Cfy0Itv9df'

 -- Sys tables list of Legal Authority (18 types)
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'PLC_ATHC'
  
 
1404	Guardian Non-Relative                   
1409	WIC 300 a, b, c, d, f, g, i or j        
1410	WIC 300e                                
1411	WIC 300h                                
  
 -- Sys tables list of Interventin Reasons
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'SCP_RLTC'	--'INTVRSNC'
  
  
----------------------------------------------------------------------------------
-- 2) Non-Related Legal Guardianship 
-- Juvenile Dependency Court/WIC 300 w/o Dependency
-- **NOTE- Same Query as #1 but add Court_Result table  
-- #43    43 distinct
-- Q: How do you tell its WIC 300? This is tied to Legal Authority
----------------------------------------------------------------------------------
-- COUNTS
 SELECT DISTINCT 
 		count(*)  
  FROM CWSWIN.CASE_T c													-- CASE table
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 				-- JOIN Child Client table
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T				-- JOIN Client table
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 				-- JOIN CASE Voluntary Status table
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER					-- JOIN Intervention Reason table
  --
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER 				-- JOIN Placement Episode table
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID				-- JOIN Plcmnt Episode Legal Authority table
--
  JOIN CWSWIN.CASE_HRT ch ON ch.FKCASE_T = c.IDENTIFIER					-- JOIN Case Hearing table 
  JOIN cwswin.HEARNG_T ht ON ht.IDENTIFIER = ch.FKHEARNG_T 				-- JOIN Hearing table
  JOIN CWSWIN.CT_RESLT cr ON cr.FKCASE_HRT = c.IDENTIFIER				-- JOIN Court RESULT table
--  
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
  JOIN CWSWIN.SYS_CD_C sc3 ON sc3.SYS_ID = cr.FNDGORDC  
 WHERE c.SRV_CMPC = 1695		--	Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 1404		-- Guardian Non-RELATIVE
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND ch.FKHEARNG_T = cr.FKCASE_HR0 
   AND cr.FNDGORDC IN (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated
 --  AND c.IDENTIFIER = 'AaS77uzGQv'

   
-- DATA ---
--#43    43 Distinct w/hearing date
SELECT DISTINCT  
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
--	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
--	  ir.INTVRSNC,
	  sc2.SHORT_DSC Intervention_Rsn,
--  	  cs.SRV_CMPC, cs.EFFECTV_DT, cs.END_DT  
	  ht.HEARING_DT, 
	  cr.FNDGORDC, 
	  sc3.SHORT_DSC court_order,
	  ch.FKHEARNG_T, ch.LST_UPD_TS,  
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
 WHERE c.SRV_CMPC = 1695		--	Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 1404		-- Guardian Non-RELATIVE
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND ch.FKHEARNG_T = cr.FKCASE_HR0 
   AND cr.FNDGORDC IN (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated
--   AND c.IDENTIFIER = 'L0mhNHEBEJ'
  ORDER BY client_id 
 
   
-- COURT_RESULT
-- #22,047,227
SELECT count(*) --IDENTIFIER, FNDGORDC, FNDG_ORDCD, LST_UPD_ID, LST_UPD_TS, FKCASE_HRT, FKCASE_HR0, CNTY_SPFCD, FKRV_HRT, FKRV_HR0, FKRV_HR1
  FROM CWSWIN.CT_RESLT cr
  
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
 WHERE cr.FNDGORDC IN (5857, 1362)  --Dependency Terminated, Jurisdiction Terminated                                    
   AND cr.FKCASE_HRT = 'CrcLcmZ84l' --duplicate has BOTH findings ON same DAY 

LpdhjuvOmh
PqzkM8Gbfi   
   
-- Case Hearing
SELECT CHR_RSLT_B, HRNG_TPC, 
		sc.SHORT_DSC, 
		SUBTYP_DSC	, ch.LST_UPD_ID, ch.LST_UPD_TS, FKHEARNG_T, FKCASE_T, RESULT_TXT, RESULT_C, CNTY_SPFCD, RSLCNT_IND
  FROM CWSWIN.CASE_HRT ch
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = ch.HRNG_TPC 
 WHERE ch.FKCASE_T = 'L0mhNHEBEJ'
   AND ch.FKHEARNG_T IN ('LpdhjuvOmh', 'PqzkM8Gbfi')

-- Hearing
SELECT IDENTIFIER, CIT_SUBT_B, CNTHRG_C, CT_DEPT_NO, HEARING_DT, CT_SUM_DOC, HRG_ATNT_B, JDCL_OFFNM, JDCL_TLC, LANG_TPC, PT_HRG_T_B, HEARING_TM, LST_UPD_ID, LST_UPD_TS, FKCOURT_T, ATNDEE_DSC, HR_NTE_DSC, NEXT_HR_DT, NEXT_HR_TM, CNTY_SPFCD
  FROM CWSWIN.HEARNG_T h
 WHERE h.IDENTIFIER  IN ('LpdhjuvOmh', 'PqzkM8Gbfi') 
   
   
   
----------------------------------------------------------------------------------
-- 3) Non-Related Legal Guardianship -- Probate Court
-- **NOTE** Same as Query 1, plus  vs.VLNTRY_IND = 'Y', Out_Home_Placement, la.PLC_ATHC = 6539 Probate NRLG   
-- oh.FKPLC_EPST = Client id, oh.FKPLC_EPS0 = Episode id
-- #171    83 non duplicates w/oh.END_DT IS NULL -- Returns most current
----------------------------------------------------------------------------------  
--**TEST CASE** AaW0HXeC0W	Diamond Joy has 2 OH recs w/end dates
-- Q: is it a Permanent Placement if its OH is end dated?
-- Q: Does oh.Intervention Reason '6991' (NREFM Nonguardian) count as Nonrelative NonGuardian?                       
----------------------------------------------------------------------------------  
SELECT  --count(*) 
  		DISTINCT 
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
--	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
  	  sc2.SHORT_DSC Intervention_Rsn,
  	  --la.EFFCTV_DT, 
--	  ir.INTVRSNC,
	  pe.THIRD_ID Place_EP_Id,
	  oh.START_DT oh_START_DT, oh.END_DT oh_END_DT, 
	  sc3.SHORT_DSC SCP_Relationship_to_Client
  FROM CWSWIN.CASE_T c													-- CASE table
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 				-- JOIN Child Client table
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T				-- JOIN Client table
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 				-- JOIN CASE Voluntary Status table
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER					-- JOIN Intervention Reason table
  --
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER 				-- JOIN Placement Episode table
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID				-- JOIN Plcmnt Episode Legal Authority table
  JOIN CWSWIN.O_HM_PLT oh ON oh.FKPLC_EPS0 = pe.THIRD_ID 				-- JOIN OUT Home Placement table
--  
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
  JOIN CWSWIN.SYS_CD_C sc3 ON sc3.SYS_ID = oh.SCP_RLTC 
 WHERE c.SRV_CMPC = 1695		-- Permanent Placement
   AND vs.VLNTRY_IND = 'Y'		-- Voluntary status
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 6539		-- Probate NRLG                            
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.SCP_RLTC  = 1637		-- Nonrelative Nonguardian
   AND oh.END_DT IS NULL        -- Returns most current                 
 --  AND c.IDENTIFIER = 'AaS77uzGQv'
   --AND ct.IDENTIFIER = 'G2VDUFLLjU'
 ORDER BY client_id

 
 -- Placement Episode
 SELECT REMOVAL_DT, AGY_RSPC, ASGN_SW_CD, ELIG_WK_CD, CHL_RGT_CD, DETNORD_DT, DSP_ORD_DT, PLEPS_ENDT, NFC_PLCT_B, OUT_CST_DT, OUT_CST_TM, PETN_FILDT, FCISRVWT_B, FCISHRGT_B, PRVT_SVC, RLS_RSNC, RMV_RSNC, REMOVAL_TM, RMV_BY_ID, RMV_BY_CD, RMV_FRM_NM, RMV_FRM1C, TMP_CSTIND, LST_UPD_ID, LST_UPD_TS, FKCLIENT_T, THIRD_ID, COMNT_DSC, END_ENT_DT, RMV_ENT_DT, RMVCR1_ID, RMVCR1_CD, RMVCR2_ID, RMVCR2_CD, RMV_FRM2C, TERM_RS_CD, TERM_DSC, TERM_TY_C, FMLYSTR_CD, BIRTHYR1, BIRTHYR2, RSFSURB_NM, GVR_ENTC, PLC24HR_CD
   FROM CWSWIN.PLC_EPST pe
  --WHERE pe.THIRD_ID = '6CZU5TTJz8'
  WHERE pe.FKCLIENT_T = 'G2VDUFLLjU'

-- Placement Episode Legal Authority  -- can contain dups but not by EFF DT  
SELECT la.THIRD_ID, EFFCTV_DT, PLC_ATHC, la.LST_UPD_ID, la.LST_UPD_TS, 
		FKPLC_EPST, FKPLC_EPS0
		,sc.SHORT_DSC 
  FROM CWSWIN.LG_AUTHT la
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = la.PLC_ATHC 
 --WHERE la.PLC_ATHC = 1404   --PE Legal Authority = 'Guardian Non-Relative'   
--  WHERE la.PLC_ATHC IN ( 1404, 1409, 1410, 1411 )
 WHERE la.FKPLC_EPST = 'G2VDUFLLjU'
-- WHERE la.FKPLC_EPS0  = 'Cfy0Itv9df'
 
 -- Out Home Placement DATA  - has duplicates
 -- oh.FKPLC_EPST = pe.FKCLIENT_T
 -- oh.FKPLC_EPS0 = pe.THIRD_ID
 SELECT IDENTIFIER, FKPLC_EPST, FKPLC_EPS0, --AGR_EFF_DT, APRVL_NO, APV_STC, CHDP_RF_DT, CHDP_RQIND, DFPRNT_IND, SOC158_DOC, AFDC_PRDOC, AGNFP_ADOC, AGNGH_ADOC, EMRG_PLIND, 
 		START_DT, END_DT, --, EXMP_HMIND, GHM_PLCIND, INT_NTC_DT, PAYEETPC, PND_LICIND, PLCG_RNC, PROGRAM_NO, SCP_RLTC, EXT_APVNO, XT_APV_STC, PAYEE_ENDT, SUBP_FSTNM, SUBP_LSTNM, SUBP_MIDNM, PYE_STRTDT, YOUAKM_CD, LST_UPD_ID, LST_UPD_TS, FKPLC_HM_T, FKPLC_EPST, FKPLC_EPS0, PL_RTNLDSC, REMVL_DSC, SCPROXIND, HEP_DT, SBPLRSNC, SIBPLC_TXT, SCPROX_TXT, GRDDEP_IND, SCH_PPL_CD, SIBTGHR_CD, TDCNSL_IND, TDAGR_DT, CPWNMD_IND, CPWNMD_CNT, TRBSPH_CD, LOC_ASM_DT
 		sc.SHORT_DSC 
   FROM CWSWIN.O_HM_PLT oh
   JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = oh.SCP_RLTC
  WHERE oh.FKPLC_EPS0 = '6CZU5TTJz8'	--'7cPCMn44Dr'
    AND oh.SCP_RLTC = 1637 
  
-- Sys tables list of
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'SCP_RLTC'  --    SCP Relationship TO Child (from Out home placement)
 
 
----------------------------------------------------------------------------------
-- 4) Non-Related Legal Guardianship -- Probate Court
-- **NOTE** Same as Query 3, plus  vs.VLNTRY_IND = 'N'   
-- oh.FKPLC_EPST = Client id, oh.FKPLC_EPS0 = Episode id
-- #74    13 non duplicates w/oh.END_DT IS NULL -- Returns most current
-- Q: is it a Permanent Placement if its OH is end dated? 
----------------------------------------------------------------------------------  
SELECT  --count(*) 
  		DISTINCT 
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
--	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
  	  sc2.SHORT_DSC Intervention_Rsn,
  	  --la.EFFCTV_DT, 
--	  ir.INTVRSNC,
	  pe.THIRD_ID Place_EP_Id,
	  oh.START_DT oh_START_DT, oh.END_DT oh_END_DT, 
	  sc3.SHORT_DSC SCP_Relationship_to_Client
  FROM CWSWIN.CASE_T c												-- CASE table
  JOIN CWSWIN.CHLD_CLT cc ON cc.FKCLIENT_T = c.FKCHLD_CLT 			-- JOIN Child Client table
  JOIN CWSWIN.CLIENT_T ct ON ct.IDENTIFIER = cc.FKCLIENT_T			-- JOIN Client table
  JOIN CWSWIN.CSVOL_ST vs ON vs.FKCASE_T = c.IDENTIFIER 			-- JOIN CASE Voluntary Status table
  JOIN CWSWIN.INTV_RNT ir ON ir.FKCASE_T = c.IDENTIFIER				-- JOIN Intervention Reason table
  --
  JOIN CWSWIN.PLC_EPST pe ON pe.FKCLIENT_T = ct.IDENTIFIER 			-- JOIN Placement Episode table
  JOIN CWSWIN.LG_AUTHT la ON la.FKPLC_EPS0 = pe.THIRD_ID			-- JOIN Plcmnt Episode Legal Authority table
  JOIN CWSWIN.O_HM_PLT oh ON oh.FKPLC_EPS0 = pe.THIRD_ID 			-- JOIN OUT Home Placement table
--  
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC
  JOIN CWSWIN.SYS_CD_C sc2 ON sc2.SYS_ID = ir.INTVRSNC 
  JOIN CWSWIN.SYS_CD_C sc3 ON sc3.SYS_ID = oh.SCP_RLTC 
 WHERE c.SRV_CMPC = 1695		-- Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary status
   AND vs.END_DT IS NULL   		-- CURRENT Voluntary Status
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
   AND pe.PLEPS_ENDT IS NULL 	-- CURRENT Placement Episode
   AND la.PLC_ATHC = 6539		-- Probate NRLG                            
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.SCP_RLTC  = 1637		-- Nonrelative Nonguardian      
   AND oh.END_DT IS NULL       -- Returns most current          
 --  AND c.IDENTIFIER = 'AaS77uzGQv'
   --AND ct.IDENTIFIER = 'G2VDUFLLjU'
 ORDER BY client_id
 
 