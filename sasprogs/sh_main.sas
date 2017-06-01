/*********************************************************************************************************
TITLE: sh_main.sas

DESCRIPTION: main program for the social housing fiscal impact evaluation

INPUT:

OUTPUT:


AUTHOR: B Vandenbroucke

DATE: 15 May 2017

DEPENDENCIES: 
SIAL tables must exist
[hnz_clean].*
security.concordance
data.*


NOTES: Runtime ~ 2 hours (querying the SIAL agency-specific tables takes the longest)

The complete process has to be run in 4 parts, switching between SAS and R:
	- SAS: sh_main.sas from  1 to the step 9 (create train/test dataset)
	- R: main_part1.R (propensity model)
	- SAS: sh_main.sas from 10 to step 11 (import scores and create cost table)
	- R: main_part2.R (cost analysis)

Ensure that the SIAL tables/views you are using is the same as the IDI refresh version you are pointing this
code to.

HISTORY:

15 May 2017 BV v1
*********************************************************************************************************/


/******************************* 1.SET UP VARIABLES AND MACROS ********************************************/

options mlogic mprint;

/* Set the path */
%let sasdir = \\WPRDFS08\Datalab-MA\MAA2016-15 Supporting the Social Investment Unit\github_social_housing_v2;
%let sasdirgen = \\WPRDFS08\Datalab-MA\MAA2016-15 Supporting the Social Investment Unit\si_data_foundation;

/* To re-run the project as E&I's version (November 16) use IDI_refresh_*/
/*%let IDIrefresh=idi_clean_20161020_srvprd ;*/
/* To point to the latest refresh useline below */
%let IDIrefresh=idi_clean_archive_srvprd ;

/* Set up the libraries */
%include "&sasdir.\sasprogs\libnames.sas";

/* Load all the macros */
options obs=MAX mvarsize=max pagesize=132 
        append=(sasautos=("&sasdirgen.\sasautos"
						  "&sasdir.\sasautos"));

/* Set any other options */
ods graphics on;

/*Setup global macro variables for parameters*/
%sh_si_setup();

/***********************************************************************************************************/



/******************************* 2.DEFINE THE COHORT (2005/2006 HNZ APPLICATIONS)********************************/
/*Estimated completion : 20s */

/* Set years of interest (years of application)  */
%let yearfrom = 2005;
%let yearto = 2006;

/* Create household and individual tables   */
/*	- sand.hnz_ind_newapps_0506				*/
/*	- sand.hnz_hh_newapps_0506				*/
%include "&sasdir.\sasprogs\sh_define_cohort.sas";

/*************************************************************************************************************/


/******************************* 3.PERSONAL CHARACTERISTICS ****************************************************/
/*Estimated completion : 1min */

/* Create master characteristics table */
/*	- sand.pop_master_char             */
%include "&sasdir.\sasprogs\sh_characteristics.sas";

/***********************************************************************************************************/


/******************************* 4.ALIGN SIAL EVENTS TO THE PERIODS ******************************************/
/*Estimated completion : 45 min */

/* Create aligned events tables sand.XXX_YYY_events  */
%include "&sasdir.\sasprogs\sh_align_sialevents.sas";

/***********************************************************************************************************/


/******************************* 5.APPLY DISCOUNTING TO THE EVENTS *******************************************/
/*Estimated completion : 4min */

/* Create discounted events tables work.XXX_YYY_events_disc  */
%include "&sasdir.\sasprogs\sh_apply_discounting.sas";

/***********************************************************************************************************/


/******************************* 6.ROLLUP EVENTS *************************************************************/
/*Estimated completion : 2min */

/* Create discounted events tables work.XXX_YYY_events_disc  */
%include "&sasdir.\sasprogs\sh_rollup_events.sas";

/***********************************************************************************************************/


/******************************* 7.CREATE INDIVIDUAL LEVEL DATASETS *************************************************************/
/*Estimated completion : 2min */

/* Create individual variables datasets  */
/*	- hnz_apps_ind_2005_06_cohort		*/
/*	- individual_variables				*/
/*	- all_ind_variables_cohort_0506		*/
%include "&sasdir.\sasprogs\sh_create_ind_ds.sas";

/***********************************************************************************************************/

/******************************* 8.CREATE HOUSEHOLD LEVEL DATASETS *************************************************************/
/*Estimated completion : 5 min */

/* Create household variables datasets  */
/*	- hnz_apps_hhld_2005_06_cohort		*/
/*	- household_variables				*/
/*	- all_hh_variables_cohort_0506		*/
%include "&sasdir.\sasprogs\sh_create_hhld_ds.sas";

/***********************************************************************************************************/


/******************************* 9.CREATE TRAIN/TEST DATASET *************************************************************/
/*Estimated completion : 1 min */

/* Create train/test datasets for propensity model  */
/*	- sand.sh_pop_0506		*/
%include "&sasdir.\sasprogs\sh_create_train_test.sas";

/***********************************************************************************************************/



/******************************* 10.PROPENSITY MODEL *************************************************************/

/* At this point, run the R file 'main_part1.R'	including the following steps:		*/
/* 	- 1.extract_dataset																*/
/*	- 2.premodelling_tasks															*/
/*	- 3.check_correlations															*/
/*	- 4.xgb_model																	*/
/*	- 5.postmodelling_tasks															*/
/*	- 6.ps_weighting_and_balancing													*/

/*Import the scored dataset generated by the R script with propensity weights*/
proc import datafile="&sasdir.\output\full_data_with_propensity_weights.csv"
out=sand.xgb_predicted_score_weights dbms=csv replace;
run;

/***********************************************************************************************************/



/******************************* 11.CREATE COST MASTER TABLE *************************************************************/
/*Estimated completion : 30 s */

/* Create the cost master table including scaled weights  */
/*	- sand.hh_cost_master					*/
%include "&sasdir.\sasprogs\sh_create_cost_master_table.sas";

/***********************************************************************************************************/



/******************************* 12.COST ESTIMATES / BOOTSTRAP  *************************************************************/

/* At this point, run the R file 'main_part2.R'						*/
/*	- 7.cost_estimate_boostrap										*/
/***********************************************************************************************************/


/******************************* END *************************************************************/
