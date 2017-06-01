/************************************************************************/
/*																		*/
/* TITLE: sh_align_sialevents.sas										*/
/*																		*/
/* DESCRIPTION:  														*/					
/*	This script creates the events tables from the SIAL events tables   */
/*	aligned to the profile and forecast periods							*/
/*	Remark: for this version, point to a specific ACC SIAL table		*/
/*		from the 20160715 refresh due to data availablitity				*/
/*		(snz_uid updated to be consistent with last refresh				*/
/*																		*/
/*																		*/
/* INPUT: 																*/
/* Requires defined macro variables:									*/
/*	in_pop = population (for sql explicit pass through) 				*/
/*				with snz_uid and asonb_date								*/
/*	periods_before = profile period										*/
/*	periods_after = forecast period										*/
/*																		*/
/* OUTPUT:																*/
/* Create aligned events tables sand.XXX_YYY_events  					*/					
/* IRD events split in cost and revenue datasets						*/
/*																		*/
/* Author: Ben Vandenbroucke											*/	
/* Date: May 2017														*/
/*																		*/
/************************************************************************/


/*Align SIAL events to the periods and rollup*/

/*ACC claim: ! specific SIAL table from the 20160715 refresh dut to data availabibily issue for thge latest refresh */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_20161020_ACC_injury_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.ACC_injury_events, period_aligned_to_calendar = False);


/*MSD T1*/
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MSD_T1_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MSD_T1_events, period_aligned_to_calendar = False);

/*MSD T2*/
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MSD_T2_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MSD_T2_events, period_aligned_to_calendar = False);

/*MSD T3*/
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MSD_T3_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MSD_T3_events, period_aligned_to_calendar = False);


/*CYF client */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_CYF_client_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.CYF_client_events, period_aligned_to_calendar = False);

/*CYF abuse */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_CYF_abuse_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.CYF_abuse_events, period_aligned_to_calendar = False);


/*MOH pharm */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_pharm_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_pharm_events, period_aligned_to_calendar = False);


/*MOH gms */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_gms_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_gms_events, period_aligned_to_calendar = False);

/*MOH chronic */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_chronic_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_chronic_events, period_aligned_to_calendar = False);

/*MOH nnpac */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_nnpac_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_nnpac_events, period_aligned_to_calendar = False);

/*MOH pfhd */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_pfhd_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_pfhd_events, period_aligned_to_calendar = False);
	
/*MOH labtest */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_labtest_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_labtest_events, period_aligned_to_calendar = False);

/*MOH nir */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_nir_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_nir_events, period_aligned_to_calendar = False);

/*MOH B4School */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_B4School_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_B4School_events, period_aligned_to_calendar = False);

/*MOH primhd */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_primhd_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_primhd_events, period_aligned_to_calendar = False);

/*MOH cancer */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOH_cancer_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOH_cancer_events, period_aligned_to_calendar = False);


/*MOJ courtcase */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOJ_courtcase_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOJ_courtcase_events, period_aligned_to_calendar = False);


/*COR sentences */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_COR_sentence_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.COR_sentence_events, period_aligned_to_calendar = False);


/*MOE ECE */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOE_ECE_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOE_ECE_events, period_aligned_to_calendar = False);

/*MOE student interventions */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOE_intervention_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOE_intervention_events, period_aligned_to_calendar = False);

/*MOE ITL */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOE_ITL_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOE_ITL_events, period_aligned_to_calendar = False);

/*MOE school */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOE_school_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOE_school_events, period_aligned_to_calendar = False);

/*MOE tertiary */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_MOE_tertiary_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.MOE_tertiary_events, period_aligned_to_calendar = False);


/*IRD cost */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_IRD_income_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
si_amount_col = cost, period_duration= &si_period_duration., si_out_table=sand.IRD_cost_events, period_aligned_to_calendar = False);

/*IRD revenue */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_IRD_income_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
si_amount_col = revenue, period_duration= &si_period_duration., si_out_table=sand.IRD_revenue_events, period_aligned_to_calendar = False);


/*POL offender */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_POL_offender_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.POL_offender_events, period_aligned_to_calendar = False);

/*POL victim */
%si_align_sialevents_to_periods(si_table_in=[IDI_Sandpit].[&si_proj_schema.].[&si_pop_table_out.], si_sial_table=[IDI_Sandpit].[&si_proj_schema.].[SIAL_POL_victim_events], si_as_at_date =&si_as_at_date., si_amount_type= L, noofperiodsbefore=&si_num_periods_before., noofperiodsafter=&si_num_periods_after., 
period_duration= &si_period_duration., si_out_table=sand.POL_victim_events, period_aligned_to_calendar = False);
