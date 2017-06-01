/****************************************************
TITLE: sh_create_hhld_ds.sas

DESCRIPTION: 
 Create individual variables datasets  

INPUT: 

OUTPUT:
	- hnz_apps_hhld_2005_06_cohort		
	- household_variables	

DEPENDENCIES: 
	- hnz_apps_ind_2005_06_cohort
	- hnz_hh_newapps_0506
	- &si_pop_table_out.

AUTHOR: Ben Vandenbroucke

DATE: May 2017

HISTORY: 
From create_hhld_analysis_variables_dataset.sas
4 November 2016 V. Benny
****************************************************/

/*Drop all target tables that we are writing to.*/
%si_conditional_drop_table(si_cond_table_in=sand.hnz_apps_hhld_2005_06_cohort);

/* Need to create a household level table by drawing information from the individual level data.
	First, we draw out the application level data and the primary snz_uid related data and attach it to the individuals. 
	Then we need to roll up the required counts to the household level.
*/
proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table work.temp_household as 
		select * 
		from connection to odbc(
			select 
				hh.[app_id],
				hh.[snz_application_uid],
				hh.[snz_legacy_application_uid],
				prim.[primary_snz_uid],
				hh.[hnz_na_date_of_application_date],
				hh.[hnz_re_exit_date],
				hh.[hnz_na_analy_score_afford_text],
				hh.[hnz_na_analy_score_adeq_text],
				hh.[hnz_na_analy_score_suitably_text],
				hh.[hnz_na_analy_score_sustain_text],
				hh.[hnz_na_analy_score_access_text],
				hh.[hnz_na_analysis_total_score_text],
				hh.[hnz_na_main_reason_app_text],
				hh.[hnz_na_hshd_size_nbr],
				hh.[hnz_na_hshd_type_text],
				hh.[hnz_na_bedroom_required_cnt_nbr],
				hh.[hnz_na_stated_location_pref_text],
				hh.[hnz_na_region_code],
				hh.[hnz_na_ta_code],
				hh.[hnz_na_meshblock_code],
				hh.[snz_idi_address_register_uid] as curr_snz_idi_addr_reg_uid, 
				hh.[hnz_na_meshblock_imputed_ind],
				hh.[hnz_re_exit_status_text],
				hh.[hnz_re_exit_reason_text],
				prim.snz_sex_code as primary_sex_code,
				prim.as_at_age as primary_age,
				prim.prioritised_eth as primary_ethnic_ind,
				ind.*,
				case when ind.age >=0 and ind.age <= 5 then 1 else 0 end as P_young_child,
				case when ind.age > 5 and ind.age <=19 then 1 else 0 end as P_older_child,
				case when ind.age > 19 and ind.age < 70 then 1 else 0 end as P_wk_age_adult,
				case when ind.age >=70 then 1 else 0 end as P_old_adult		
			from [IDI_Sandpit].[&si_proj_schema.].[hnz_apps_ind_2005_06_cohort] ind
			inner join [IDI_Sandpit].[&si_proj_schema.].[hnz_hh_newapps_0506] hh on (ind.app_id = hh.app_id)
			inner join (select distinct * from [IDI_Sandpit].[&si_proj_schema.].[all_ind_variables_cohort_0506]
						where primary_snz_uid=snz_uid  
							and &si_as_at_date. between cast('2005-01-01' as date) 
												and cast('2006-12-31' as date)) prim
				on (hh.app_id=prim.app_id and cast(hh.&si_as_at_date. as date)=cast(prim.&si_as_at_date. as date))
		);

		disconnect from odbc;

quit;


proc sort data= work.temp_household ;
	by app_id  
	snz_application_uid  
	snz_legacy_application_uid  
	primary_snz_uid  
	hnz_na_date_of_application_date  
	hnz_re_exit_date  
	hnz_na_analy_score_afford_text  
	hnz_na_analy_score_adeq_text  
	hnz_na_analy_score_suitably_text  
	hnz_na_analy_score_sustain_text  
	hnz_na_analy_score_access_text  
	hnz_na_analysis_total_score_text  
	hnz_na_main_reason_app_text  
	hnz_na_hshd_size_nbr  
	hnz_na_hshd_type_text  
	hnz_na_bedroom_required_cnt_nbr  
	hnz_na_stated_location_pref_text  
	hnz_na_region_code  
	hnz_na_ta_code  
	hnz_na_meshblock_code  
	curr_snz_idi_addr_reg_uid   
	hnz_na_meshblock_imputed_ind  
	hnz_re_exit_status_text  
	hnz_re_exit_reason_text  
	primary_sex_code
	primary_age
	primary_ethnic_ind 
	;

run;


/* All variables starting with 'P_' will be summed up here, grouping on the household and primary snz_uid level attributes.*/

proc summary data=work.temp_household;

	by app_id  
	snz_application_uid  
	snz_legacy_application_uid  
	primary_snz_uid  
	hnz_na_date_of_application_date  
	hnz_re_exit_date  
	hnz_na_analy_score_afford_text  
	hnz_na_analy_score_adeq_text  
	hnz_na_analy_score_suitably_text  
	hnz_na_analy_score_sustain_text  
	hnz_na_analy_score_access_text  
	hnz_na_analysis_total_score_text  
	hnz_na_main_reason_app_text  
	hnz_na_hshd_size_nbr  
	hnz_na_hshd_type_text  
	hnz_na_bedroom_required_cnt_nbr  
	hnz_na_stated_location_pref_text  
	hnz_na_region_code  
	hnz_na_ta_code  
	hnz_na_meshblock_code  
	curr_snz_idi_addr_reg_uid   
	hnz_na_meshblock_imputed_ind  
	hnz_re_exit_status_text  
	hnz_re_exit_reason_text  
	primary_sex_code
	primary_age
	primary_ethnic_ind ;

	var P_: P1_: P2_: P3_: P4_: ;

	output out= work.temp_household_2 sum=  ;

run;


proc sql;
	create table sand.hnz_apps_hhld_2005_06_cohort as
	select * 
	from work.temp_household_2;
quit;


/*Household varaiables*/

 proc sort data=sand.individual_variables  out=work.temp_individual ;

	by app_id
	snz_uid;

run;

proc summary data=work.temp_individual (drop=snz_uid);

	by app_id ;
	var P_: P1_: P2_: P3_: P4_: ;

	output out= work.temp_household sum=  ;

run;

%si_conditional_drop_table(si_cond_table_in=sand.household_variables);

proc sql; 
	create table sand.household_variables(drop= _TYPE_ _FREQ_)
	as select * from work.temp_household  ;
quit;

/*Create the final dataset*/

%si_conditional_drop_table(si_cond_table_in=sand.all_hh_variables_cohort_0506);

proc sql;
	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.all_hh_variables_cohort_0506 as 
		select * 
		from connection to odbc(
			select a.[app_id] 
				  ,a.[hnz_na_date_of_application_date]
			      ,a.[snz_application_uid]
			      ,a.[snz_legacy_application_uid]
			      ,a.[snz_msd_uid]
			      ,a.[legacy_snz_msd_uid]
			      ,a.[hnz_na_analy_score_afford_text]
			      ,a.[hnz_na_analy_score_adeq_text]
			      ,a.[hnz_na_analy_score_suitably_text]
			      ,a.[hnz_na_analy_score_sustain_text]
			      ,a.[hnz_na_analy_score_access_text]
			      ,a.[hnz_na_analysis_total_score_text]
			      ,a.[hnz_na_main_reason_app_text]
			      ,a.[hnz_na_hshd_size_nbr]
			      ,a.[hnz_na_stated_location_pref_text]
			      ,a.[hnz_na_bedroom_required_cnt_nbr]
			      ,a.[hnz_na_no_particular_pref_text]
			      ,a.[hnz_na_hshd_type_text]
			      ,a.[snz_idi_address_register_uid]
			      ,a.[hnz_na_region_code]
			      ,a.[hnz_na_ta_code]
			      ,a.[hnz_na_meshblock_code]
			      ,a.[hnz_na_meshblock_imputed_ind]
			      ,a.[hnz_re_exit_date]
			      ,a.[hnz_re_exit_reason_text]
			      ,a.[hnz_re_exit_status_text]
			      ,c.[primary_snz_uid]
				  ,b.[P1_IRD_INC_BEN_CST]
			      ,b.[P2_IRD_INC_BEN_CST]
			      ,b.[P3_IRD_INC_BEN_CST]
			      ,b.[P4_IRD_INC_BEN_CST]
			      ,b.[P1_IRD_INC_W&S_CST]
			      ,b.[P2_IRD_INC_W&S_CST]
			      ,b.[P3_IRD_INC_W&S_CST]
			      ,b.[P4_IRD_INC_W&S_CST]
			      ,b.[P1_MSD_BEN_T2_AS_CST]
			      ,b.[P2_MSD_BEN_T2_AS_CST]
			      ,b.[P3_MSD_BEN_T2_AS_CST]
			      ,b.[P4_MSD_BEN_T2_AS_CST]
			      ,b.[P1_MSD_BEN_T2_CST]
			      ,b.[P2_MSD_BEN_T2_CST]
			      ,b.[P3_MSD_BEN_T2_CST]
			      ,b.[P4_MSD_BEN_T2_CST]
			      ,b.[P1_MSD_BEN_T3_CST]
			      ,b.[P2_MSD_BEN_T3_CST]
			      ,b.[P3_MSD_BEN_T3_CST]
			      ,b.[P4_MSD_BEN_T3_CST]
			      ,b.[P1_MOH_GMS_GMS_CST]
			      ,b.[P2_MOH_GMS_GMS_CST]
			      ,b.[P3_MOH_GMS_GMS_CST]
			      ,b.[P4_MOH_GMS_GMS_CST]
			      ,b.[P1_MOH_PFH_PFH_CST]
			      ,b.[P2_MOH_PFH_PFH_CST]
			      ,b.[P3_MOH_PFH_PFH_CST]
			      ,b.[P4_MOH_PFH_PFH_CST]
			      ,b.[P1_MOH_LAB_LAB_CST]
			      ,b.[P2_MOH_LAB_LAB_CST]
			      ,b.[P3_MOH_LAB_LAB_CST]
			      ,b.[P4_MOH_LAB_LAB_CST]
			      ,b.[P1_MSD_CYF_CNP_CST]
			      ,b.[P2_MSD_CYF_CNP_CST]
			      ,b.[P3_MSD_CYF_CNP_CST]
			      ,b.[P4_MSD_CYF_CNP_CST]
			      ,b.[P1_MSD_CYF_YJU_CST]
			      ,b.[P2_MSD_CYF_YJU_CST]
			      ,b.[P3_MSD_CYF_YJU_CST]
			      ,b.[P4_MSD_CYF_YJU_CST]
			      ,b.[P1_COR_MMP_SAR_CST]
			      ,b.[P2_COR_MMP_SAR_CST]
			      ,b.[P3_COR_MMP_SAR_CST]
			      ,b.[P4_COR_MMP_SAR_CST]
			      ,b.[P1_ACC_CLA_INJ_CST]
			      ,b.[P2_ACC_CLA_INJ_CST]
			      ,b.[P3_ACC_CLA_INJ_CST]
			      ,b.[P4_ACC_CLA_INJ_CST]
			      ,b.[P1_MOE_MOE_ENR_CST]
			      ,b.[P2_MOE_MOE_ENR_CST]
			      ,b.[P3_MOE_MOE_ENR_CST]
			      ,b.[P4_MOE_MOE_ENR_CST]
			      ,b.[P_MSD_CYF_ABE_CNT]
			      ,b.[P_MOH_CAN_REG_CNT]
			      ,b.[P_MOH_TKR_CCC_CNT]
			      ,b.[P_MOE_STU_INT_DUR]
			      ,b.[P_MOE_STU_INT_CNT]
				  ,c.[snz_sex_code] as primary_sex_code
				  ,c.[as_at_age] as primary_age
			      ,c.[prioritised_eth] as primary_ethnicity
				  ,d.[P1_IRD_INC_W&S_CST] as primary_Y1_wage
				  ,d.[P2_IRD_INC_W&S_CST] as primary_Y2_wage
				  ,d.[P3_IRD_INC_W&S_CST] as primary_Y3_wage
				  ,d.[P4_IRD_INC_W&S_CST] as primary_Y4_wage
				  ,d.[P1_IRD_INC_W&S_CST] + d.[P2_IRD_INC_W&S_CST] + d.[P3_IRD_INC_W&S_CST] + d.[P4_IRD_INC_W&S_CST] as primary_total_wage
				  ,sum(e.P_young_child) as P_young_child
				  ,sum(e.P_older_child) as P_older_child
				  ,sum(e.P_wk_age_adult) as P_wk_age_adult
				  ,sum(e.P_old_adult) as P_old_adult
		 
			 from [IDI_Sandpit].[&si_proj_schema.].[hnz_hh_newapps_0506] a
				 inner join [IDI_Sandpit].[&si_proj_schema.].[household_variables] b 
					on (a.[app_id] = b.[app_id])
				 inner join (select * from [IDI_Sandpit].[&si_proj_schema.].[all_ind_variables_cohort_0506] 
							where primary_snz_uid=snz_uid) c 
					on (a.[app_id]= c.[app_id])
				 inner join [IDI_Sandpit].[&si_proj_schema.].[all_ind_variables_cohort_0506] d 
					on (a.[app_id]=d.[app_id] and c.[snz_uid]=d.[snz_uid])
				 inner join [IDI_Sandpit].[&si_proj_schema.].[all_ind_variables_cohort_0506] e 
					on (a.[app_id]=e.[app_id] )
			 group by 
				   a.[app_id]
				  ,a.[hnz_na_date_of_application_date]
			      ,a.[snz_application_uid]
			      ,a.[snz_legacy_application_uid]
			      ,a.[snz_msd_uid]
			      ,a.[legacy_snz_msd_uid]
			      ,a.[hnz_na_analy_score_afford_text]
			      ,a.[hnz_na_analy_score_adeq_text]
			      ,a.[hnz_na_analy_score_suitably_text]
			      ,a.[hnz_na_analy_score_sustain_text]
			      ,a.[hnz_na_analy_score_access_text]
			      ,a.[hnz_na_analysis_total_score_text]
			      ,a.[hnz_na_main_reason_app_text]
			      ,a.[hnz_na_hshd_size_nbr]
			      ,a.[hnz_na_stated_location_pref_text]
			      ,a.[hnz_na_bedroom_required_cnt_nbr]
			      ,a.[hnz_na_no_particular_pref_text]
			      ,a.[hnz_na_hshd_type_text]
			      ,a.[snz_idi_address_register_uid]
			      ,a.[hnz_na_region_code]
			      ,a.[hnz_na_ta_code]
			      ,a.[hnz_na_meshblock_code]
			      ,a.[hnz_na_meshblock_imputed_ind]
			      ,a.[hnz_re_exit_date]
			      ,a.[hnz_re_exit_reason_text]
			      ,a.[hnz_re_exit_status_text]
			      ,c.[primary_snz_uid]
				  ,b.[P1_IRD_INC_BEN_CST]
			      ,b.[P2_IRD_INC_BEN_CST]
			      ,b.[P3_IRD_INC_BEN_CST]
			      ,b.[P4_IRD_INC_BEN_CST]
			      ,b.[P1_IRD_INC_W&S_CST]
			      ,b.[P2_IRD_INC_W&S_CST]
			      ,b.[P3_IRD_INC_W&S_CST]
			      ,b.[P4_IRD_INC_W&S_CST]
			      ,b.[P1_MSD_BEN_T2_AS_CST]
			      ,b.[P2_MSD_BEN_T2_AS_CST]
			      ,b.[P3_MSD_BEN_T2_AS_CST]
			      ,b.[P4_MSD_BEN_T2_AS_CST]
			      ,b.[P1_MSD_BEN_T2_CST]
			      ,b.[P2_MSD_BEN_T2_CST]
			      ,b.[P3_MSD_BEN_T2_CST]
			      ,b.[P4_MSD_BEN_T2_CST]
			      ,b.[P1_MSD_BEN_T3_CST]
			      ,b.[P2_MSD_BEN_T3_CST]
			      ,b.[P3_MSD_BEN_T3_CST]
			      ,b.[P4_MSD_BEN_T3_CST]
			      ,b.[P1_MOH_GMS_GMS_CST]
			      ,b.[P2_MOH_GMS_GMS_CST]
			      ,b.[P3_MOH_GMS_GMS_CST]
			      ,b.[P4_MOH_GMS_GMS_CST]
			      ,b.[P1_MOH_PFH_PFH_CST]
			      ,b.[P2_MOH_PFH_PFH_CST]
			      ,b.[P3_MOH_PFH_PFH_CST]
			      ,b.[P4_MOH_PFH_PFH_CST]
			      ,b.[P1_MOH_LAB_LAB_CST]
			      ,b.[P2_MOH_LAB_LAB_CST]
			      ,b.[P3_MOH_LAB_LAB_CST]
			      ,b.[P4_MOH_LAB_LAB_CST]
			      ,b.[P1_MSD_CYF_CNP_CST]
			      ,b.[P2_MSD_CYF_CNP_CST]
			      ,b.[P3_MSD_CYF_CNP_CST]
			      ,b.[P4_MSD_CYF_CNP_CST]
			      ,b.[P1_MSD_CYF_YJU_CST]
			      ,b.[P2_MSD_CYF_YJU_CST]
			      ,b.[P3_MSD_CYF_YJU_CST]
			      ,b.[P4_MSD_CYF_YJU_CST]
			      ,b.[P1_COR_MMP_SAR_CST]
			      ,b.[P2_COR_MMP_SAR_CST]
			      ,b.[P3_COR_MMP_SAR_CST]
			      ,b.[P4_COR_MMP_SAR_CST]
			      ,b.[P1_ACC_CLA_INJ_CST]
			      ,b.[P2_ACC_CLA_INJ_CST]
			      ,b.[P3_ACC_CLA_INJ_CST]
			      ,b.[P4_ACC_CLA_INJ_CST]
			      ,b.[P1_MOE_MOE_ENR_CST]
			      ,b.[P2_MOE_MOE_ENR_CST]
			      ,b.[P3_MOE_MOE_ENR_CST]
			      ,b.[P4_MOE_MOE_ENR_CST]
			      ,b.[P_MSD_CYF_ABE_cnt]
			      ,b.[P_MOH_CAN_REG_cnt]
			      ,b.[P_MOH_TKR_CCC_cnt]
			      ,b.[P_MOE_STU_INT_DUR]
			      ,b.[P_MOE_STU_INT_CNT]
				  ,c.[snz_sex_code]
				  ,c.[as_at_age]
			      ,c.[prioritised_eth]
				  ,d.[P1_IRD_INC_W&S_CST]
				  ,d.[P2_IRD_INC_W&S_CST]
				  ,d.[P3_IRD_INC_W&S_CST]
				  ,d.[P4_IRD_INC_W&S_CST]

		);

		disconnect from odbc;

quit;

proc datasets lib=work;
	delete temp_:;
run;