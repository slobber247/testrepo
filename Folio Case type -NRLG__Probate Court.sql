---------------------------------
-- Focus on CASE_TYPES  Non-Related Guardianship
--	 17) Probate Court (latest Out Home Placement (O_HM_PLT) )
-----------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 17) Non-Related Legal Guardianship -- Probate Court
-- **NOTE** Same as Query 15, plus  vs.VLNTRY_IND = 'Y', Out_Home_Placement, la.PLC_ATHC = 6539 Probate NRLG   
-- oh.FKPLC_EPST = Client id, oh.FKPLC_EPS0 = Episode id
-- #108  
----------------------------------------------------------------------------------  
-- Q: is it a Permanent Placement if its OH is end dated?
-- Q: Does oh.Intervention Reason '6991' (NREFM Nonguardian) count as Nonrelative NonGuardian?                       
----------------------------------------------------------------------------------  
SELECT  --count(*) 
  		DISTINCT 
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
	  ir.INTVRSNC,
  	  sc2.SHORT_DSC Intervention_Rsn,
  	  sc4.SHORT_DSC Legal_Authority,
	  pe.THIRD_ID Place_EP_Id,
	  pe.PLEPS_ENDT,
	--  la.third_id legal_auth_id,
   	--  la.EFFCTV_DT, 
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
  JOIN CWSWIN.SYS_CD_C sc4 ON sc4.SYS_ID = la.PLC_ATHC 
 WHERE c.SRV_CMPC = 1695		-- Permanent Placement
 --  AND vs.VLNTRY_IND = 'Y'		-- Non Voluntary
   AND vs.VLNTRY_IND IN ( 'Y', 'N')		-- Get All 
   AND ((vs.END_DT IS NULL)   		-- CURRENT Voluntary Status
     		OR (vs.START_DT = (SELECT MAX(vs2.START_DT) FROM CWSWIN.CSVOL_ST vs2 WHERE vs2.FKCASE_T = c.IDENTIFIER) AND vs.END_DT IS NOT NULL)  -- OR latest voluntary rec
       )
   --    
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
--   AND ir.LST_UPD_TS = (SELECT max(ir2.LST_UPD_TS) FROM CWSWIN.INTV_RNT ir2 WHERE ir2.FKCASE_T = c.IDENTIFIER)		--- latest Intervention Reason
   --
--how do you link a PE to a client w/multiple cases??    
   AND ((pe.PLEPS_ENDT IS NULL) 	-- CURRENT Placement Episode
  			OR (pe.PLEPS_ENDT = (SELECT MAX(pe2.PLEPS_ENDT) FROM CWSWIN.PLC_EPST pe2 WHERE pe2.FKCLIENT_T = ct.IDENTIFIER) AND pe.PLEPS_ENDT IS NOT NULL) -- OR latest Placement Episode
   	   )	 	
   --	   
   AND la.PLC_ATHC = 6539	-- Probate NRLG                            
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND la.EFFCTV_DT = (SELECT max(la2.EFFCTV_DT) FROM CWSWIN.LG_AUTHT la2 WHERE la2.FKPLC_EPST = pe.FKCLIENT_T AND la2.FKPLC_EPS0 = pe.THIRD_ID) -- latest Legal Authority
--  
   AND oh.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.SCP_RLTC  in (1637, 6991) -- Nonrelative Nonguardian, NREFM Nonguardian
   AND oh.END_DT IS NULL        -- Returns most current                 
-- test data   	   
--   AND c.IDENTIFIER = 'DfUe0Vl7HV'    -- by case
   --AND ct.IDENTIFIER = '1pjaf9K91u'  -- by client
-- ORDER BY client_id
  ORDER BY c.IDENTIFIER -- CASE IDENTIFIER 

  
----------------------------------------------------------------------------------
-- 18) Non-Related Legal Guardianship -- Probate Court
-- **NOTE** Same as Query 17, but vs.VLNTRY_IND = 'N'   
-- oh.FKPLC_EPST = Client id, oh.FKPLC_EPS0 = Episode id
-- Q: is it a Permanent Placement if its OH is end dated? 
-- #16 
----------------------------------------------------------------------------------  
SELECT  --count(*) 
  		DISTINCT 
	  c.IDENTIFIER Case_id, 
	  ct.IDENTIFIER Client_id,
	  cc.FKCLIENT_T child_client_id,
	  TRIM(ct.COM_FST_NM) || ' ' || TRIM(ct.COM_LST_NM) Client_name, 
	  c.SRV_CMPC Active_Svc_Cmp, 
	  sc.SHORT_DSC Service_Component,
	  vs.VLNTRY_IND,
	  ir.INTVRSNC,
  	  sc2.SHORT_DSC Intervention_Rsn,
      sc4.SHORT_DSC Legal_Authority,
	  pe.THIRD_ID Place_EP_Id,
	  pe.PLEPS_ENDT,
	  la.third_id legal_auth_id,
   	  la.EFFCTV_DT, 
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
  JOIN CWSWIN.SYS_CD_C sc4 ON sc4.SYS_ID = la.PLC_ATHC 
 WHERE c.SRV_CMPC = 1695		-- Permanent Placement
   AND vs.VLNTRY_IND = 'N'		-- Non Voluntary status
   AND ((vs.END_DT IS NULL)   		-- CURRENT Voluntary Status
     		OR (vs.START_DT = (SELECT MAX(vs2.START_DT) FROM CWSWIN.CSVOL_ST vs2 WHERE vs2.FKCASE_T = c.IDENTIFIER) AND vs.END_DT IS NOT NULL)  -- OR latest voluntary rec
       ) 
   --    
   AND ir.INTVRSNC = 1225		-- Guardian Requesting FC Payment
--   AND ir.LST_UPD_TS = (SELECT max(ir2.LST_UPD_TS) FROM CWSWIN.INTV_RNT ir2 WHERE ir2.FKCASE_T = c.IDENTIFIER)		--- latest Intervention Reason
--how do you link a PE to a client w/multiple cases??    
   AND ((pe.PLEPS_ENDT IS NULL) 	-- CURRENT Placement Episode
  			OR (pe.PLEPS_ENDT = (SELECT MAX(pe2.PLEPS_ENDT) FROM CWSWIN.PLC_EPST pe2 WHERE pe2.FKCLIENT_T = ct.IDENTIFIER) AND pe.PLEPS_ENDT IS NOT NULL) -- OR latest Placement Episode
   	   )	 	
   AND la.PLC_ATHC = 6539		-- Probate NRLG                            
   AND la.FKPLC_EPST = pe.FKCLIENT_T 
   AND la.EFFCTV_DT = (SELECT max(la2.EFFCTV_DT) FROM CWSWIN.LG_AUTHT la2 WHERE la2.FKPLC_EPST = pe.FKCLIENT_T AND la2.FKPLC_EPS0 = pe.THIRD_ID) -- latest Legal Authority
   --
   AND oh.FKPLC_EPST = pe.FKCLIENT_T 
   AND oh.SCP_RLTC  in (1637, 6991) -- Nonrelative Nonguardian, NREFM Nonguardian
   AND oh.END_DT IS NULL        -- Returns most current                 
-- test data
--   AND c.IDENTIFIER = 'DfUe0Vl7HV'	-- by Case IDENTIFIER 
   --AND ct.IDENTIFIER = '1pjaf9K91u'	-- by Client IDENTIFIER 
-- ORDER BY client_id
  ORDER BY c.IDENTIFIER -- CASE IDENTIFIER 
 
 
--------------
-- Work Area
-------------- 
----------------------------------------------------------
-- CASE 
----------------------------------------------------------   
SELECT c.IDENTIFIER , c.SRV_CMPC, sc.SHORT_DSC, c.FKCHLD_CLT 
		,c.START_DT, c.END_DT 
  FROM CWSWIN.CASE_T c
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = c.SRV_CMPC 
 WHERE c.IDENTIFIER = 'DfUe0Vl7HV'	--
-- WHERE c.SRV_CMPC = 1695 
-- WHERE c.IDENTIFIER IN ('APQIABs4iP', 'LfmrubZDZD', '7Aof9ay4rr')
 --WHERE c.FKCHLD_CLT = '1pjaf9K91u'
 
--------------------------------------------------------------------  
-- Case Service Component  
--------------------------------------------------------------------  
SELECT cs.IDENTIFIER, EFFECTV_DT, END_DT, SRV_CMPC, 
		sc.SHORT_DSC SC_TYPE, sc.FKS_META_T, 
		--LST_UPD_ID, LST_UPD_TS, 
		FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CS_SVCMT cs
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = cs.SRV_CMPC 
 WHERE cs.FKCASE_T = 'DfUe0Vl7HV'	--'AaavA3P8mB'		--'AYPC4Wwdik'
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
-- s/b 'Y' or 'N' 
--------------------------------------------------------------------  
-- multiple records per case  -- look for null date in end date for latest
SELECT THIRD_ID, START_DT, END_DT, VLNTRY_IND, LST_UPD_ID, LST_UPD_TS, FKCASE_T, CNTY_SPFCD
  FROM CWSWIN.CSVOL_ST cv
 WHERE cv.FKCASE_T = 'DfUe0Vl7HV'  --'DfUe0Vl7HV' 
--   AND cv.END_DT IS NULL 
   
SELECT MAX(vs2.end_dt) FROM CWSWIN.CSVOL_ST vs2 WHERE vs2.FKCASE_T = 'DfUe0Vl7HV'

--------------------------------------------------------------------  
-- Intervention Reason
-- s/b (1225) -- Guardian Requesting FC Payment
--------------------------------------------------------------------  
 SELECT ir.THIRD_ID, INTVRSNC, ir.LST_UPD_ID, ir.LST_UPD_TS, FKCASE_T, CNTY_SPFCD
 		,sc.SHORT_DSC 
   FROM CWSWIN.INTV_RNT ir
   JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = ir.INTVRSNC 
   WHERE ir.FKCASE_T = 'DfUe0Vl7HV'	-- BY CASE id
  

-------------------------------------------------------------------- 
-- Placement Episode 
-- Client can have multiple Episodes   
-- Q: pe.PLEPS_ENDT = NULL always present?   
-- Q: how do you link a PE record with a Client w/multiple cases  
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
WHERE pe.FKCLIENT_T = '1pjaf9K91u'
 -- AND pe.PLEPS_ENDT IS NULL 
  
  
-------------------------------------------------------------------- 
-- Placement Episode Legal Authority
-- la.FKPLC_EPST = pe.FKCLIENT_T  
-- la.FKPLC_EPS0 = pe.THIRD_ID  
-- s/b (6539) -- Probate NRLG 
--------------------------------------------------------------------
SELECT la.THIRD_ID, EFFCTV_DT,  --LST_UPD_ID, LST_UPD_TS, 
		FKPLC_EPST, FKPLC_EPS0, PLC_ATHC
		,sc.SHORT_DSC 
  FROM CWSWIN.LG_AUTHT la
  JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = la.PLC_ATHC 
 --WHERE la.PLC_ATHC = 1404   --PE Legal Authority = 'Guardian Non-Relative'   
--  WHERE la.PLC_ATHC IN ( 1404, 1409, 1410, 1411 )
 WHERE la.FKPLC_EPST = '1pjaf9K91u'
-- WHERE la.FKPLC_EPS0  = 'GZhghqo91u'

  
  
 ---------------------------------------------------- 
 -- Out Home Placement DATA  - has duplicates
 -- oh.FKPLC_EPST = pe.FKCLIENT_T
 -- oh.FKPLC_EPS0 = pe.THIRD_ID
 -- s/b oh.SCP_RLTC in (1637, 6991) -- Nonrelative Nonguardian, NREFM Nonguardian
 --------------------------------------------------
 SELECT IDENTIFIER, FKPLC_EPST, FKPLC_EPS0, --AGR_EFF_DT, APRVL_NO, APV_STC, CHDP_RF_DT, CHDP_RQIND, DFPRNT_IND, SOC158_DOC, AFDC_PRDOC, AGNFP_ADOC, AGNGH_ADOC, EMRG_PLIND, 
 		START_DT, END_DT, --, EXMP_HMIND, GHM_PLCIND, INT_NTC_DT, PAYEETPC, PND_LICIND, PLCG_RNC, PROGRAM_NO, SCP_RLTC, EXT_APVNO, XT_APV_STC, PAYEE_ENDT, SUBP_FSTNM, SUBP_LSTNM, SUBP_MIDNM, PYE_STRTDT, YOUAKM_CD, LST_UPD_ID, LST_UPD_TS, FKPLC_HM_T, FKPLC_EPST, FKPLC_EPS0, PL_RTNLDSC, REMVL_DSC, SCPROXIND, HEP_DT, SBPLRSNC, SIBPLC_TXT, SCPROX_TXT, GRDDEP_IND, SCH_PPL_CD, SIBTGHR_CD, TDCNSL_IND, TDAGR_DT, CPWNMD_IND, CPWNMD_CNT, TRBSPH_CD, LOC_ASM_DT
 		SCP_RLTC,
 		sc.SHORT_DSC 
   FROM CWSWIN.O_HM_PLT oh
   JOIN CWSWIN.SYS_CD_C sc ON sc.SYS_ID = oh.SCP_RLTC
  WHERE oh.FKPLC_EPST = '1pjaf9K91u' -- Client id	
--  AND oh.END_DT IS NULL 
 --   AND oh.SCP_RLTC = 1637 
    
----------------------------------------------  
-- Sys tables list of
----------------------------------------------    
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'SCP_RLTC'  --    SCP Relationship TO Child (from Out home placement)
 
  -- Sys tables list of Legal Authority for Placement (18 types)
 SELECT sc.SYS_ID ,sc.SHORT_DSC 
  FROM CWSWIN.SYS_CD_C sc
 WHERE sc.FKS_META_T = 'PLC_ATHC'
 
