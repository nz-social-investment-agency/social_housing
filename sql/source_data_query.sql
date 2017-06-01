/*	This script extracts all the data relative to the application,		*/
/*		households and individuals necessary to build the propensity	*/
/*		model as detailed in the social houseing technical report.		*/
/*																		*/
/* Note: this script reads the table sh_pop_0506 that has previously	*/
/*		been created according to our specifications					*/
/*																		*/
/*	This script is intented to be called in R							*/
/*	Author: Vinay Benny													*/
/*	Date: Nov. 2016														*/


select 
	snz_legacy_application_uid
	, appl_year_qtr
	,[hnz_na_analy_score_afford_text]
	,[hnz_na_analy_score_adeq_text]
	,[hnz_na_analy_score_suitably_text]
	,[hnz_na_analy_score_sustain_text]
	,[hnz_na_analy_score_access_text]
	,[hnz_na_analysis_total_score_text]
	,[hnz_na_main_reason_app_text]
	,[hnz_na_hshd_size_nbr]
	,case when [hnz_na_bedroom_required_cnt_nbr] = 0 then 1 else [hnz_na_bedroom_required_cnt_nbr] end as [hnz_na_bedroom_required_cnt_nbr]
	,coalesce(coalesce( right('0'+[hnz_na_region_code], 2), addr.ant_region_code), '98') as region_code
	,[P1_IRD_INC_BEN_CST]
    ,[P2_IRD_INC_BEN_CST]
    ,[P3_IRD_INC_BEN_CST]
    ,[P4_IRD_INC_BEN_CST]
    ,[P1_IRD_INC_W&S_CST] as P1_IRD_INC_W_S_CST
    ,[P2_IRD_INC_W&S_CST] as P2_IRD_INC_W_S_CST
    ,[P3_IRD_INC_W&S_CST] as P3_IRD_INC_W_S_CST
    ,[P4_IRD_INC_W&S_CST] as P4_IRD_INC_W_S_CST
	  ,[P1_MSD_BEN_T2_AS_CST]
      ,[P2_MSD_BEN_T2_AS_CST]
      ,[P3_MSD_BEN_T2_AS_CST]
      ,[P4_MSD_BEN_T2_AS_CST]
      ,[P1_MSD_BEN_T2_CST]
      ,[P2_MSD_BEN_T2_CST]
      ,[P3_MSD_BEN_T2_CST]
      ,[P4_MSD_BEN_T2_CST]
      ,[P1_MSD_BEN_T3_CST]
      ,[P2_MSD_BEN_T3_CST]
      ,[P3_MSD_BEN_T3_CST]
      ,[P4_MSD_BEN_T3_CST]
      ,[P1_MOH_GMS_GMS_CST]
      ,[P2_MOH_GMS_GMS_CST]
      ,[P3_MOH_GMS_GMS_CST]
      ,[P4_MOH_GMS_GMS_CST]
      ,[P1_MOH_PFH_PFH_CST]
      ,[P2_MOH_PFH_PFH_CST]
      ,[P3_MOH_PFH_PFH_CST]
      ,[P4_MOH_PFH_PFH_CST]
      ,[P1_MOH_LAB_LAB_CST]
      ,[P2_MOH_LAB_LAB_CST]
      ,[P3_MOH_LAB_LAB_CST]
      ,[P4_MOH_LAB_LAB_CST]
      ,[P1_MSD_CYF_CNP_CST]
      ,[P2_MSD_CYF_CNP_CST]
      ,[P3_MSD_CYF_CNP_CST]
      ,[P4_MSD_CYF_CNP_CST]
      ,[P1_MSD_CYF_YJU_CST]
      ,[P2_MSD_CYF_YJU_CST]
      ,[P3_MSD_CYF_YJU_CST]
      ,[P4_MSD_CYF_YJU_CST]
      ,[P1_COR_MMP_SAR_CST]
      ,[P2_COR_MMP_SAR_CST]
      ,[P3_COR_MMP_SAR_CST]
      ,[P4_COR_MMP_SAR_CST]
      ,[P1_ACC_CLA_INJ_CST]
      ,[P2_ACC_CLA_INJ_CST]
      ,[P3_ACC_CLA_INJ_CST]
      ,[P4_ACC_CLA_INJ_CST]
      ,[P1_MOE_MOE_ENR_CST]
      ,[P2_MOE_MOE_ENR_CST]
      ,[P3_MOE_MOE_ENR_CST]
      ,[P4_MOE_MOE_ENR_CST]
      ,[P_MSD_CYF_ABE_CNT]
      ,[P_MOH_CAN_REG_CNT]
      ,[P_MOH_TKR_CCC_CNT]
      ,[P_MOE_STU_INT_DUR]
      ,[P_MOE_STU_INT_CNT]
	,[P_young_child]
	,[P_older_child]
	,[P_wk_age_adult]
	,[P_old_adult]
	,[primary_sex_code]
	,[primary_age]
	,[primary_ethnicity]
	,[primary_Y1_wage]
	,[primary_Y2_wage]
	,[primary_Y3_wage]
	,[primary_Y4_wage]
	,[P1_IRD_INC_BEN_CST]+[P2_IRD_INC_BEN_CST]+[P3_IRD_INC_BEN_CST]+[P4_IRD_INC_BEN_CST] as [primary_total_ben]
	,log(1.+[P1_IRD_INC_BEN_CST]+[P2_IRD_INC_BEN_CST]+[P3_IRD_INC_BEN_CST]+[P4_IRD_INC_BEN_CST])-log(1.+[primary_total_wage]) as ben_to_wage_log_ratio
	,age_band
	,[hnz_re_exit_status_text]
	,case when [hnz_re_exit_status_text] = 'HOUSED' then 1 else 0 end as actual_class
	,[Group]
from [DL-MAA2016-15].sh_pop_0506 hh
	left join IDI_Clean.data.address_notification addr 
on (hh.primary_snz_uid =addr.snz_uid and hh.hnz_na_date_of_application_date between addr.[ant_notification_date] and addr.[ant_replacement_date])
