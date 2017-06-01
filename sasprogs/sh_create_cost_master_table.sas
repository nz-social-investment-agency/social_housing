/****************************************************
TITLE: create_cost_master_table.sas

DESCRIPTION: 

INPUT: 
dataset with predicted scores sand.xgb_predicted_score_weights
events rolled up tables (long): work.hnz_XXX_YYY_rollupl

OUTPUT:
sand.hh_cost_master

DEPENDENCIES: 
	relevant libnames statement to access the relevant
	tables
	rollup_cost_macros also needs to be run

NOTES: 

AUTHOR: 
Ben Vandenbroucke

DATE: 15 May 2017

****************************************************/


proc sql;
	connect to sqlservr (server=WPRDSQL36\ileed database=IDI_Sandpit);
	create table work.household_weights as
		select * 
		from connection to sqlservr
			(select 
				b.snz_legacy_application_uid
				,b.inv_wt_att
				,b.actual_class
			from [IDI_Sandpit].[&si_proj_schema.].[xgb_predicted_score_weights] b 
			)
	;
	disconnect from sqlservr;
quit;

/* stack all the rolled up cost tables*/
data work.stacked_table_returns(where=(substr(vartype, 1, 2) = 'F_' )); /* considering the F_ var, sum of the 6 years costs */
	set
	work.hnz_ACC_injury_rollupl
	work.hnz_COR_sentence_rollupl
	work.hnz_CYF_client_rollupl
	/* make sure PEN is filtered out */
	/* recently changed this as a safe guard to double check we didnt get too many zeroes in the denominator*/
	/* the sum in the next step should prevent it anyway but just to be safe */
	work.hnz_IRD_cost_rollupl 
		(where=(substr(vartype, 11, length(vartype) -14 ) not in ('W&S','PEN','C01', 'C02', 'P01', 'P02', 'S01', 'S02')))
	work.hnz_IRD_taxes_rollupl /* This is only the tax part of W&S (still positive cost) */ 
	work.hnz_MOH_B4School_rollupl 
	work.hnz_MOH_gms_rollupl
	work.hnz_MOH_labtest_rollupl 
	work.hnz_MOH_nnpac_rollupl 
	work.hnz_MOH_pharm_rollupl
	work.hnz_MOH_primhd_rollupl 
	work.hnz_MOH_pfhd_rollupl 
	work.hnz_MSD_T1_rollupl 
	work.hnz_MSD_T2_AS_events_rollupl 
	work.hnz_MSD_T2_no_wff_AS_rollupl 
	work.hnz_MSD_T3_rollupl 
	work.hnz_MOE_school_rollupl
	;
run;


/*Summing the costs by subject area at a individual level and get the app id*/
proc sql;
	create table stacked_table_returns2 as
	select  b.snz_legacy_application_uid as uid2, 
			a.snz_uid,
			substr(vartype, 3, 3) as department,
			substr(vartype, 7, 3) as datamart,
			substr(vartype, 11, length(vartype) -14 ) as subject_area,
			coalesce(sum(value),0) as cost
	from stacked_table_returns a 
	left join sand.individual_variables b on a.snz_uid=b.snz_uid
	where substr(vartype, length(vartype) -2, 3) = 'CST'
	group by a.snz_uid,
			substr(vartype, 3, 3),
			substr(vartype, 7, 3),
			substr(vartype, 11, length(vartype) -14 )
	order by a.snz_uid,
			substr(vartype, 3, 3),
			substr(vartype, 7, 3),
			substr(vartype, 11, length(vartype) -14 )
	;
quit;



/* rollup costs to the dept datamart subject area household level*/
proc sql;
	create table work.returns_hh_level as
		select department
			,datamart
			,subject_area
			,uid2
			,sum(cost) as cost
		from work.stacked_table_returns2
		group by uid2,department, datamart, subject_area 
;
quit;

/* create a list of all our subject areas */
/* we will use these to identify who has zero costs */
proc sql; 
	create table distinct_subject_areas as
		select distinct department,datamart, subject_area
	from  work.stacked_table_returns2;
quit;

/* attached the different subject areas to the households */
proc sql; create table hh_by_subject_area as 
	select distinct a.uid2,
			b.department,
			b.datamart,
			b.subject_area
	from work.returns_hh_level a 
	inner join distinct_subject_areas b 
		on 1=1
	order by uid2, department, datamart, subject_area;
quit;

/* attach the costs back on and impute missing by 0 */
proc sql; create table hh_cost_temp as 
	select  a.*,
			coalesce(b.cost,0) as cost format=Dollar21.2
	from work.hh_by_subject_area a 
	left join returns_hh_level b 
		on a.uid2=b.uid2 
			and a.department=b.department 
			and a.datamart=b.datamart 
			and a.subject_area=b.subject_area
	order by uid2, department, datamart, subject_area;
quit;


/* join weights onto household cost table with zeros and scaling the weights */
/* There should be 21 rows per household */

proc sql; 
	create table work.hh_cost_master as
		select 
			a.*,
			b.actual_class,
			b.inv_wt_att/c.mean_weight as inv_wt_att_scaled
		from work.hh_cost_temp a 
		left join work.household_weights b 
			on a.uid2=b.snz_legacy_application_uid
		left join ( select actual_class, mean(inv_wt_att) as mean_weight
					from work.household_weights group by actual_class ) c
			on b.actual_class=c.actual_class
		order by uid2
	;
quit;


/* Save cost master to sandpit */
%si_conditional_drop_table(si_cond_table_in=sand.hh_cost_master);

data sand.hh_cost_master ;
	set hh_cost_master;
run;


