/************************************************************************/
/*																		*/
/* TITLE: sh_rollup_events.sas											*/
/*																		*/
/* DESCRIPTION:  														*/					
/*	This script creates the rolled-up events tables	   					*/
/*	MSD T2 events split in 2 outputs:									*/
/*		- T2 events excluding WFF and AS								*/
/*		- T2 AS events													*/
/*	IRD costs rolled up only for 'BEN','CLM','PEN','PPL','STU' 			*/
/*	IRD revenues split in 2 outputs:									*/
/*		- IRD_wages for 'W&S' only										*/
/*		- IRD_taxes = 13.39% * 'W&S'									*/
/*																		*/
/* INPUT: 																*/
/* discounted events tables work.hnz_XXX_YYY_events_disc				*/
/* Requires defined macro variable	:									*/
/*	in_pop = population dataset (sas lib)								*/
/*																		*/
/* OUTPUT:																*/
/* Create rolled-up events tables work.XXX_YYY_rollup					*/					
/* 																		*/
/*																		*/
/* Author: Ben Vandenbroucke											*/	
/* Date: May 2017														*/
/*																		*/
/************************************************************************/

/*ACC claim*/
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_ACC_injury_events_disc, si_out_table=work.hnz_ACC_injury_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*MSD T1*/
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MSD_T1_events_disc, si_out_table=work.hnz_MSD_T1_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MSD T2 (excluding wff and AS)*/
data work.hnz_MSD_T2_no_wff_AS_events_disc;
	set work.hnz_MSD_T2_events_disc(where=(event_type not in ('064','471')));
run;
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MSD_T2_no_wff_AS_events_disc, si_out_table=work.hnz_MSD_T2_no_wff_AS_rollup,
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MSD T2 event type level for AS (event_type 471)*/
data work.hnz_MSD_T2_AS_events_disc;
	set work.hnz_MSD_T2_events_disc(where=(event_type eq '471'));
	event_type='AS';
run;
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MSD_T2_AS_events_disc, si_out_table=work.hnz_MSD_T2_AS_events_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area event_type), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*MSD T3*/
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MSD_T3_events_disc, si_out_table=work.hnz_MSD_T3_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*CYF client */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_CYF_client_events_disc, si_out_table=work.hnz_CYF_client_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*CYF abuse */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_CYF_abuse_events_disc, si_out_table=work.hnz_CYF_abuse_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*MOH pharm */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_pharm_events_disc, si_out_table=work.hnz_MOH_pharm_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH gms */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_gms_events_disc, si_out_table=work.hnz_MOH_gms_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH chronic */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_chronic_events_disc, si_out_table=work.hnz_MOH_chronic_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*MOH nnpac */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_nnpac_events_disc, si_out_table=work.hnz_MOH_nnpac_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH pfhd */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_pfhd_events_disc, si_out_table=work.hnz_MOH_pfhd_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );
	
/*MOH labtest */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_labtest_events_disc, si_out_table=work.hnz_MOH_labtest_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH nir */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_nir_events_disc, si_out_table=work.hnz_MOH_nir_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH B4School */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_B4School_events_disc, si_out_table=work.hnz_MOH_B4School_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH primhd */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_primhd_events_disc, si_out_table=work.hnz_MOH_primhd_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOH cancer */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOH_cancer_events_disc, si_out_table=work.hnz_MOH_cancer_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );



/*MOJ courtcase */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOJ_courtcase_events_disc, si_out_table=work.hnz_MOJ_courtcase_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*COR sentences */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_COR_sentence_events_disc, si_out_table=work.hnz_COR_sentence_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*MOE ECE */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOE_ECE_events_disc, si_out_table=work.hnz_MOE_ECE_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOE student interventions */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOE_intervention_events_disc, si_out_table=work.hnz_MOE_intervention_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOE ITL */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOE_ITL_events_disc, si_out_table=work.hnz_MOE_ITL_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOE school */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOE_school_events_disc, si_out_table=work.hnz_MOE_school_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*MOE tertiary */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_MOE_tertiary_events_disc, si_out_table=work.hnz_MOE_tertiary_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );


/*POL offender */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_POL_offender_events_disc, si_out_table=work.hnz_POL_offender_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*POL victim */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_POL_victim_events_disc, si_out_table=work.hnz_POL_victim_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );



/*IRD costs */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_IRD_cost_events_disc(where=(subject_area in ('BEN','CLM','PEN','PPL','STU'))), si_out_table=work.hnz_IRD_cost_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= cost_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*IRD wages and salaries */
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_IRD_revenue_events_disc(where=(subject_area eq 'W&S') ), si_out_table=work.hnz_IRD_wages_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= revenue_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

/*IRD Tax part = W&S revenue *0.1339*/
data work.hnz_IRD_tax_events_disc;
	set work.hnz_IRD_revenue_events_disc(where=(subject_area eq 'W&S') );
	subject_area='TAX';
	tax_disc3=revenue_disc3*0.1339;
run;
%si_create_rollup_vars(si_table_in=sand.&si_pop_table_out., si_sial_table=work.hnz_IRD_tax_events_disc(where=(subject_area eq 'TAX') ), si_out_table=work.hnz_IRD_taxes_rollup, 
	si_as_at_date=&si_as_at_date., si_agg_cols= %str(department datamart subject_area), cost = True, si_amount_col= tax_disc3, duration = True, count = True, count_startdate = True, dayssince = False, si_rollup_ouput_type =Both  );

