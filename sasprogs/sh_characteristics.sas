/**********************************************************************
																		
 TITLE: sh_characteristics.sas											
																		
 DESCRIPTION:  														
	This script creates the personal char table for
	the considered cohort for SH	
																		
 INPUT: 																
 Requires the setup macro variables		
 sand.hnz_ind_newapps_0506	
																		
 OUTPUT:																				
 sand.&si_pop_table_out.(sand.pop_master_char)									
 updated sand.hnz_ind_newapps_0506	
																		
 Author: Ben Vandenbroucke											
 Date: May 2017														

**********************************************************************/

/* Create master characteristics table */
/*	- sand.pop_master_char             */
%si_conditional_drop_table(si_cond_table_in=sand.&si_pop_table_out.);

%sh_get_characteristics(si_char_proj_schema=&si_proj_schema., 
	si_char_table_in=hnz_ind_newapps_0506, 
	si_as_at_date=&si_as_at_date.,
	si_char_table_out=sand.&si_pop_table_out.);


/* In cases where primary applicant is not part of the actual application, */
/* use the eldest member of the application as the primary applicant.      */
/* 99 applications : 99 primary_snz_uid updated	in hnz_ind_newapps_0506    */
/* = 252 rows updated in hnz_ind_newapps_0506 */
proc sql; 
	create table prim_not_app as
	select a.snz_legacy_application_uid, b.snz_uid
		from sand.hnz_ind_newapps_0506 a
		inner join (select * from sand.&si_pop_table_out.
					group by snz_legacy_application_uid 
					having as_at_age=max(as_at_age) ) b
		on (a.snz_uid=b.snz_uid)
		where a.snz_legacy_application_uid in (
					select distinct snz_legacy_application_uid from sand.hnz_ind_newapps_0506
					except
					select distinct snz_legacy_application_uid from (
						select a.* from sand.hnz_ind_newapps_0506 a
						)x where x.primary_snz_uid = x.snz_uid )
		group by b.snz_legacy_application_uid having b.snz_uid=max(b.snz_uid)
	;
quit;
proc sql; 
	update sand.hnz_ind_newapps_0506 a
	set primary_snz_uid = 
	(select snz_uid as primary_snz_uid
		from prim_not_app b 
		where a.snz_legacy_application_uid=b.snz_legacy_application_uid )
	where exists 
	(select * 
	from prim_not_app b 
	where a.snz_legacy_application_uid=b.snz_legacy_application_uid )
	;
quit;