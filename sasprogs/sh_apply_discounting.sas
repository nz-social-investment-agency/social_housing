/************************************************************************/
/*																		*/
/* TITLE: sh_apply_discounting.sas										*/
/*																		*/
/* DESCRIPTION:  														*/					
/*	This script creates the discounted events tables				    */
/*	Apllied to the cost variable for all business areas except IRD		*/
/*	(both cost and revenue)												*/
/*																		*/
/* INPUT: 																*/
/* aligned events tables sand.XXX_YYY_events							*/
/* Requires defined macro variable	:									*/
/*	si_disc_rate = discounting rate										*/
/*																		*/
/* OUTPUT:																*/
/* Create discounted events tables work.XXX_YYY_events_disc				*/					
/* 																		*/
/*																		*/
/* Author: Ben Vandenbroucke											*/	
/* Date: May 2017														*/
/*																		*/
/************************************************************************/


/*ACC claim*/
%si_apply_discounting(si_table_in=sand.ACC_injury_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_ACC_injury_events_disc);


/*MSD T1*/
%si_apply_discounting(si_table_in=sand.MSD_T1_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MSD_T1_events_disc);

/*MSD T2*/
%si_apply_discounting(si_table_in=sand.MSD_T2_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MSD_T2_events_disc);

/*MSD T3*/
%si_apply_discounting(si_table_in=sand.MSD_T3_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MSD_T3_events_disc);


/*CYF client */
%si_apply_discounting(si_table_in=sand.CYF_client_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_CYF_client_events_disc);

/*CYF abuse */
%si_apply_discounting(si_table_in=sand.CYF_abuse_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_CYF_abuse_events_disc);


/*MOH pharm */
%si_apply_discounting(si_table_in=sand.MOH_pharm_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_pharm_events_disc);

/*MOH gms */
%si_apply_discounting(si_table_in=sand.MOH_gms_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_gms_events_disc);

/*MOH chronic */
%si_apply_discounting(si_table_in=sand.MOH_chronic_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_chronic_events_disc);

/*MOH nnpac */
%si_apply_discounting(si_table_in=sand.MOH_nnpac_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_nnpac_events_disc);

/*MOH pfhd */
%si_apply_discounting(si_table_in=sand.MOH_pfhd_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_pfhd_events_disc);
	
/*MOH labtest */
%si_apply_discounting(si_table_in=sand.MOH_labtest_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_labtest_events_disc);

/*MOH nir */
%si_apply_discounting(si_table_in=sand.MOH_nir_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_nir_events_disc);

/*MOH B4School */
%si_apply_discounting(si_table_in=sand.MOH_B4School_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_B4School_events_disc);

/*MOH primhd */
%si_apply_discounting(si_table_in=sand.MOH_primhd_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_primhd_events_disc);

/*MOH cancer */
%si_apply_discounting(si_table_in=sand.MOH_cancer_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOH_cancer_events_disc);


/*MOJ courtcase */
%si_apply_discounting(si_table_in=sand.MOJ_courtcase_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOJ_courtcase_events_disc);


/*COR sentences */
%si_apply_discounting(si_table_in=sand.COR_sentence_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_COR_sentence_events_disc);


/*MOE ECE */
%si_apply_discounting(si_table_in=sand.MOE_ECE_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOE_ECE_events_disc);

/*MOE student interventions */
%si_apply_discounting(si_table_in=sand.MOE_intervention_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOE_intervention_events_disc);

/*MOE ITL */
%si_apply_discounting(si_table_in=sand.MOE_ITL_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOE_ITL_events_disc);

/*MOE school */
%si_apply_discounting(si_table_in=sand.MOE_school_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOE_school_events_disc);

/*MOE tertiary */
%si_apply_discounting(si_table_in=sand.MOE_tertiary_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_MOE_tertiary_events_disc);


/*POL offender */
%si_apply_discounting(si_table_in=sand.POL_offender_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_POL_offender_events_disc);

/*POL victim */
%si_apply_discounting(si_table_in=sand.POL_victim_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_POL_victim_events_disc);


/*IRD revenue */
%si_apply_discounting(si_table_in=sand.IRD_revenue_events , si_id_col=snz_uid , si_amount_col=revenue, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_IRD_revenue_events_disc);

/*IRD costs */
%si_apply_discounting(si_table_in=sand.IRD_cost_events , si_id_col=snz_uid , si_amount_col=cost, si_amount_type =L, si_as_at_date = &si_as_at_date.,
			si_disc_rate = &si_discount_rate., si_out_table = hnz_IRD_cost_events_disc);


