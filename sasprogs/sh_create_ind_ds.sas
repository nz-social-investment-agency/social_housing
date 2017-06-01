/****************************************************
TITLE: sh_create_ind_ds.sas

DESCRIPTION: 
 Create individual variables datasets  

INPUT: 

OUTPUT:
	- hnz_apps_ind_2005_06_cohort		
	- individual_variables	

DEPENDENCIES: 
	- hnz_ind_newapps_0506
	- &si_pop_table_out.
	- events rolled up tables hnz_XXX_YYY_rollupw

AUTHOR: Ben Vandenbroucke

DATE: May 2017

HISTORY: 
From create_ind_analysis_variables_dataset.sas
4 November 2016 V. Benny
****************************************************/


proc sql;
	/* Create a person-level table for all people who are part of the 2005 to 2006 cohort*/

	create table work.temp_individual as 
			select 
				apps.app_id,
				apps.snz_application_uid,
				apps.snz_legacy_application_uid,
				apps.snz_uid,
				apps.hnz_na_date_of_application_date as start_date,
				case when ch.as_at_age is null then -999 else ch.as_at_age end as age,
				case when ch.prioritised_eth is null then 'NA' else ch.prioritised_eth end as ethnic_prioritised, 
				ch.snz_sex_code,
				/*12 month income of the person prior to application*/
				sum(coalesce(wages.'P1_IRD_INC_W&S_CST'n,0) +
					coalesce(ben.P1_IRD_INC_BEN_CST,0) +
					coalesce(ben.P1_IRD_INC_CLM_CST,0) +
					coalesce(ben.P1_IRD_INC_PEN_CST,0) +
					coalesce(ben.P1_IRD_INC_PPL_CST,0) +
					coalesce(ben.P1_IRD_INC_STU_CST,0) ) as P_income_12_mnth,
				/*12 month Wages of the person prior to application*/
				sum(coalesce(wages.'P1_IRD_INC_W&S_CST'n,0)) as wages,
				/*12 month benefits of the person prior to application*/
				sum(coalesce(ben.P1_IRD_INC_BEN_CST,0) +
					coalesce(ben.P1_IRD_INC_CLM_CST,0) +
					coalesce(ben.P1_IRD_INC_PEN_CST,0) +
					coalesce(ben.P1_IRD_INC_PPL_CST,0) +
					coalesce(ben.P1_IRD_INC_STU_CST,0) )  as benefits
			from (select distinct * from sand.hnz_ind_newapps_0506) apps
			left join (select distinct * from sand.&si_pop_table_out.) ch 
					on (apps.snz_uid = ch.snz_uid and apps.&si_as_at_date. = ch.&si_as_at_date.)

			left join work.hnz_ird_wages_rollupw wages on apps.snz_uid = wages.snz_uid
			left join work.hnz_ird_cost_rollupw ben on apps.snz_uid = ben.snz_uid

			group by
/*				catx("_",coalesce(apps.snz_application_uid,""), coalesce(apps.snz_legacy_application_uid,"") ),*/
				apps.app_id,
				apps.snz_application_uid,
				apps.snz_legacy_application_uid,
				apps.snz_uid,
				apps.hnz_na_date_of_application_date,
				case when ch.as_at_age is null then -999 else ch.as_at_age end,
				case when ch.prioritised_eth is null then 'NA' else ch.prioritised_eth end,
				ch.snz_sex_code
		;

quit;

%macro CreateIndividualDataset(tablename=);	

	proc sql;

	create table work.temp_individual(drop = F_: F0: F1_: F2_: F3_: F4_: F5_:  ) as
		select * 
		from work.temp_individual a
		left join &tablename. b 
			on (a.snz_uid=b.snz_uid);

	quit;

%mend;

/* Link the rolled up tables to the individual level dataset using the macro.*/
%CreateIndividualDataset(tablename=work.hnz_IRD_cost_rollupw);
%CreateIndividualDataset(tablename=work.hnz_IRD_wages_rollupw);
%CreateIndividualDataset(tablename=work.hnz_IRD_taxes_rollupw);
%CreateIndividualDataset(tablename=work.hnz_CYF_abuse_rollupw);
%CreateIndividualDataset(tablename=work.hnz_CYF_client_rollupw);
%CreateIndividualDataset(tablename=work.hnz_ACC_injury_rollupw);
%CreateIndividualDataset(tablename=work.hnz_COR_sentence_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_cancer_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_chronic_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_gms_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_labtest_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_pharm_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_primhd_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOH_pfhd_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MSD_T1_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MSD_T2_no_wff_AS_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MSD_T2_AS_events_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MSD_T3_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOE_intervention_rollupw);
%CreateIndividualDataset(tablename=work.hnz_MOE_school_rollupw);

/* In those cases where the rolled up variables are nulls because the snz_uids do not exist in the roll up tables,
   replace those NULLs with zeros. This may not be relevant to all rolled up variables, so we need to be careful 
	about the variables in which we replace the zeros with NULLs.
*/
proc stdize data=work.temp_individual reponly missing=0 
	out=work.temp_individual;
	var P_: P1_: P2_: P3_: P4_: ;
run;

%si_conditional_drop_table(si_cond_table_in=sand.hnz_apps_ind_2005_06_cohort);

proc sql;
	create table sand.hnz_apps_ind_2005_06_cohort as 
	select * 
	from work.temp_individual;
quit;

%si_conditional_drop_table(si_cond_table_in=sand.individual_variables);

proc sql;
	create table sand.individual_variables 
	as select * 
	from work.temp_individual;
 quit;



/*Create the final dataset*/

%si_conditional_drop_table(si_cond_table_in=sand.all_ind_variables_cohort_0506);

proc sql;
	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.all_ind_variables_cohort_0506 as 
		select * 
		from connection to odbc(
			select a.*
				  ,b.[snz_sex_code]
			      ,b.[snz_spine_ind]
			      ,b.[snz_ethnicity_grp1_nbr]
			      ,b.[snz_ethnicity_grp2_nbr]
			      ,b.[snz_ethnicity_grp3_nbr]
			      ,b.[snz_ethnicity_grp4_nbr]
			      ,b.[snz_ethnicity_grp5_nbr]
			      ,b.[snz_ethnicity_grp6_nbr]
			      ,b.[uid_miss_ind_cnt]
			      ,b.[hnz_na_date_of_application_date]
			      ,b.[as_at_age]
			      ,b.[prioritised_eth]
				  ,c.[P1_IRD_INC_BEN_CST]
			      ,c.[P2_IRD_INC_BEN_CST]
			      ,c.[P3_IRD_INC_BEN_CST]
			      ,c.[P4_IRD_INC_BEN_CST]
			      ,c.[P1_IRD_INC_W&S_CST]
			      ,c.[P2_IRD_INC_W&S_CST]
			      ,c.[P3_IRD_INC_W&S_CST]
			      ,c.[P4_IRD_INC_W&S_CST]
			      ,c.[P1_MSD_BEN_T2_AS_CST]
			      ,c.[P2_MSD_BEN_T2_AS_CST]
			      ,c.[P3_MSD_BEN_T2_AS_CST]
			      ,c.[P4_MSD_BEN_T2_AS_CST]
			      ,c.[P1_MSD_BEN_T2_CST]
			      ,c.[P2_MSD_BEN_T2_CST]
			      ,c.[P3_MSD_BEN_T2_CST]
			      ,c.[P4_MSD_BEN_T2_CST]
			      ,c.[P1_MSD_BEN_T3_CST]
			      ,c.[P2_MSD_BEN_T3_CST]
			      ,c.[P3_MSD_BEN_T3_CST]
			      ,c.[P4_MSD_BEN_T3_CST]
			      ,c.[P1_MOH_GMS_GMS_CST]
			      ,c.[P2_MOH_GMS_GMS_CST]
			      ,c.[P3_MOH_GMS_GMS_CST]
			      ,c.[P4_MOH_GMS_GMS_CST]
			      ,c.[P1_MOH_PFH_PFH_CST]
			      ,c.[P2_MOH_PFH_PFH_CST]
			      ,c.[P3_MOH_PFH_PFH_CST]
			      ,c.[P4_MOH_PFH_PFH_CST]
			      ,c.[P1_MOH_LAB_LAB_CST]
			      ,c.[P2_MOH_LAB_LAB_CST]
			      ,c.[P3_MOH_LAB_LAB_CST]
			      ,c.[P4_MOH_LAB_LAB_CST]
			      ,c.[P1_MSD_CYF_CNP_CST]
			      ,c.[P2_MSD_CYF_CNP_CST]
			      ,c.[P3_MSD_CYF_CNP_CST]
			      ,c.[P4_MSD_CYF_CNP_CST]
			      ,c.[P1_MSD_CYF_YJU_CST]
			      ,c.[P2_MSD_CYF_YJU_CST]
			      ,c.[P3_MSD_CYF_YJU_CST]
				  ,c.[P4_MSD_CYF_YJU_CST]
			      ,c.[P1_COR_MMP_SAR_CST]
			      ,c.[P2_COR_MMP_SAR_CST]
			      ,c.[P3_COR_MMP_SAR_CST]
			      ,c.[P4_COR_MMP_SAR_CST]
			      ,c.[P1_ACC_CLA_INJ_CST]
			      ,c.[P2_ACC_CLA_INJ_CST]
			      ,c.[P3_ACC_CLA_INJ_CST]
			      ,c.[P4_ACC_CLA_INJ_CST]
			      ,c.[P1_MOE_MOE_ENR_CST]
			      ,c.[P2_MOE_MOE_ENR_CST]
			      ,c.[P3_MOE_MOE_ENR_CST]
			      ,c.[P4_MOE_MOE_ENR_CST]
			      ,c.[P_MSD_CYF_ABE_CNT]
			      ,c.[P_MOH_CAN_REG_CNT]
			      ,c.[P_MOH_TKR_CCC_CNT]
			      ,c.[P_MOE_STU_INT_DUR]
			      ,c.[P_MOE_STU_INT_CNT]
				  ,case when as_at_age >=0 and as_at_age <= 5 then 1 else 0 end as P_young_child,
					case when as_at_age > 5 and as_at_age <=19 then 1 else 0 end as P_older_child,
					case when as_at_age > 19 and as_at_age < 65 then 1 else 0 end as P_wk_age_adult,
					case when as_at_age >=65 then 1 else 0 end as P_old_adult	
				from [IDI_Sandpit].[&si_proj_schema.].[hnz_ind_newapps_0506] a
				inner join [IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.] b 
					on (a.snz_uid=b.snz_uid)
				inner join [IDI_Sandpit].[&si_proj_schema.].[individual_variables] c 
					on (a.snz_uid=c.snz_uid)

		);

		disconnect from odbc;

quit;

proc datasets lib=work;
	delete temp_:;
run;