/**********************************************************************
																		
 TITLE: sh_define_cohort.sas											
																		
 DESCRIPTION:  														
	This script creates the table hnz_hh_newapps_0506 showing the 		
	applications of interests, after cleansing							
	Selection and cleansing rules are detailed in the script			
	From the original define_cohort_part1.sql script					
																		
 INPUT: 																
 Requires only hnz_clean.* and concordance table						
																		
 OUTPUT:																
 Create household and individual tables   							
	- sand.hnz_ind_newapps_0506											
	- sand.hnz_hh_newapps_0506											
 																		
																		
 Author: Vinay Benny(SQL)												
 Date: Nov. 2016														
 Reviewed and SAS converted: April 2017 Ben Vandenbroucke				

HISTORY:
15 May 2017 BVandenbroucke : SQL converted to SAS
**********************************************************************/




/* All applications within our cohort period (34188)*/
%si_conditional_drop_table(si_cond_table_in=sand.all_cohort_apps);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.all_cohort_apps as 
	select * 

	from connection to odbc(

		select distinct snz_legacy_application_uid  

		from
		( 	select 
				new_app.snz_legacy_application_uid, 
				new_app_hh.snz_uid,
				new_app_hh.snz_msd_uid,
				regexit.[hnz_re_exit_status_text] as exit_status
			from [hnz_clean].[new_applications] new_app
			inner join [hnz_clean].[register_exit] regexit 
				on regexit.snz_legacy_application_uid = new_app.snz_legacy_application_uid
			inner join [hnz_clean].[new_applications_household] new_app_hh 
				on new_app.snz_legacy_application_uid  = new_app_hh.snz_legacy_application_uid
			where year(new_app.hnz_na_date_of_application_date) between &yearfrom. and &yearto.
			and regexit.[hnz_re_exit_date] between new_app.hnz_na_date_of_application_date and dateadd(yyyy, 2, new_app.hnz_na_date_of_application_date)
		)x;
	);

	disconnect from odbc;

quit;


/* Check how many individuals in these applications have multiple and distinct exit status*/
/* and get their applications. These would need to be dropped in the subsequent step.*/
/* 4089*/
%si_conditional_drop_table(si_cond_table_in=sand.dupappl);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.dupappl as 
	select * 

	from connection to odbc(

		select distinct new_app.snz_legacy_application_uid 
		from [IDI_Sandpit].[&si_proj_schema.].[all_cohort_apps] new_app
		inner join [hnz_clean].[new_applications_household] new_app_hh 
			on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
		where snz_uid in (
			select 
				snz_uid
			from [IDI_Sandpit].[&si_proj_schema.].[all_cohort_apps] new_app
			inner join [hnz_clean].[register_exit] regexit
				on regexit.snz_legacy_application_uid= new_app.snz_legacy_application_uid
			inner join [hnz_clean].[new_applications_household] new_app_hh 
				on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
			group by snz_uid having count(distinct regexit.hnz_re_exit_status_text)	> 1
		);
	);

	disconnect from odbc;

quit;



/* List of applications that remain (30099=34188-4089)*/
%si_conditional_drop_table(si_cond_table_in=sand.all_minus_dupappl);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.all_minus_dupappl as 
	select * 

	from connection to odbc(

		select * 
		from
		(select * from [IDI_Sandpit].[&si_proj_schema.].[all_cohort_apps]
		 except
		 select * from [IDI_Sandpit].[&si_proj_schema.].[dupappl]
		)x;
	);

	disconnect from odbc;

quit;



/*--so far we have removed applications for which individuals have multiple exit status.*/
/*--Some individuals may still remain, who have the same exit status for multiple applications.*/
/*--We need to pick their first application based on application date.*/
/*--If we find the same person with the same application date, pick the application with the larger ID. */
/*28605*/
%si_conditional_drop_table(si_cond_table_in=sand.all_minus_dupappl_minus_alldups);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.all_minus_dupappl_minus_alldups as 
	select * 

	from connection to odbc(

		select distinct snz_legacy_application_uid 
		from
		( select *  from (
				select
					new_app_hh.snz_uid,
					new_app.hnz_na_date_of_application_date,
					new_app_hh.snz_legacy_application_uid,
					rank() over (partition by snz_uid order by new_app.hnz_na_date_of_application_date asc, new_app_hh.snz_legacy_application_uid desc) as rnk
				from [IDI_Sandpit].[&si_proj_schema.].[all_minus_dupappl] allapps
				inner join [hnz_clean].new_applications new_app on (allapps.snz_legacy_application_uid=new_app.snz_legacy_application_uid)
				inner join [hnz_clean].[register_exit] regexit
					on regexit.snz_legacy_application_uid= new_app.snz_legacy_application_uid
				inner join [hnz_clean].[new_applications_household] new_app_hh 
					on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
					)x
			where rnk=1
		)y;

	);

	disconnect from odbc;

quit;



/*--we still find people repeated within applications. (1722 app with dup snz_uid)*/
/*--Create a list of these applications and remove them in the subsequent step*/
%si_conditional_drop_table(si_cond_table_in=sand.apps_with_dup_snzuid);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.apps_with_dup_snzuid as 
	select * 

	from connection to odbc(

		select distinct a.snz_legacy_application_uid 
		from [IDI_Sandpit].[&si_proj_schema.].[all_minus_dupappl_minus_alldups] a
			inner join [hnz_clean].[new_applications_household] b 
		on a.snz_legacy_application_uid=b.snz_legacy_application_uid
		where b.snz_uid in (
			select new_app_hh.snz_uid from [IDI_Sandpit].[&si_proj_schema.].[all_minus_dupappl_minus_alldups] allnodups
			inner join [hnz_clean].new_applications new_app on (allnodups.snz_legacy_application_uid=new_app.snz_legacy_application_uid)
			inner join [hnz_clean].[new_applications_household] new_app_hh 
						on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
			group by new_app_hh.snz_uid having count(*) > 1
		);
	);

	disconnect from odbc;

quit;

/*Removing duplicates snz_uid*/
/*26883*/
%si_conditional_drop_table(si_cond_table_in=sand.final_app_ids);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.final_app_ids as 
	select * 

	from connection to odbc(
		select * 
		from(
			select * 
			from [IDI_Sandpit].[&si_proj_schema.].[all_minus_dupappl_minus_alldups]  
			except 
			select * from [IDI_Sandpit].[&si_proj_schema.].[apps_with_dup_snzuid]
		)x;
	);
	disconnect from odbc;

quit;

/* Check: the table created by the following lines should have no records */
/************************************************************************************
select new_app_hh.snz_uid 
from [hnz_clean].[new_applications] new_app
	inner join IDI_Sandpit.[DL-MAA2016-15].final_app_ids cohort_apps 
	on (new_app.snz_legacy_application_uid = cohort_apps.snz_legacy_application_uid)
	inner join [hnz_clean].[new_applications_household] new_app_hh 
	on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
group by new_app_hh.snz_uid 
having count(distinct new_app.snz_legacy_application_uid) > 1
************************************************************************************/


/*--Now we find all applications in which at least 1 individual in the application is not linked */
/*--	to the concordance, and remove those applications in the subsequent step*/
/*4995*/
%si_conditional_drop_table(si_cond_table_in=sand.unlinked_ind_apps);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.unlinked_ind_apps as 
	select * 

	from connection to odbc(

		select distinct snz_legacy_application_uid  
		from
		(
			select 
				new_app.snz_legacy_application_uid, 
				new_app_hh.snz_uid,
				new_app_hh.snz_msd_uid,
				regexit.[hnz_re_exit_status_text] as exit_status
			from [IDI_Sandpit].[&si_proj_schema.].[final_app_ids] final_app_ids
			inner join [hnz_clean].[new_applications] new_app 
				on (final_app_ids.snz_legacy_application_uid = new_app.snz_legacy_application_uid )
			inner join [hnz_clean].[register_exit] regexit 
				on regexit.snz_legacy_application_uid = new_app.snz_legacy_application_uid
			inner join [hnz_clean].[new_applications_household] new_app_hh 
				on new_app.snz_legacy_application_uid  = new_app_hh.snz_legacy_application_uid
			where year(new_app.hnz_na_date_of_application_date) between &yearfrom. and &yearto.
				and regexit.[hnz_re_exit_date] between new_app.hnz_na_date_of_application_date 
				and dateadd(yyyy, 2, new_app.hnz_na_date_of_application_date)
				and not exists (
					select snz_uid 
					from security.concordance concord 
					where snz_spine_uid is not null and concord.snz_uid=new_app_hh.snz_uid
					)
		)x;
	);
	disconnect from odbc;

quit;


/* Keep only those applications which are linked to the concordance*/
/* Final number of applications = 21888 */
%si_conditional_drop_table(si_cond_table_in=sand.linked_ind_apps);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.linked_ind_apps as 
	select * 

	from connection to odbc(

		select * 
		from (
			select * 
			from [IDI_Sandpit].[&si_proj_schema.].[final_app_ids]
			except 
			select * from [IDI_Sandpit].[&si_proj_schema.].[unlinked_ind_apps]
		)x;

	);
	disconnect from odbc;

quit;


/*Some checks below */
/************************************************************************************
--Next, we check if we have captured all applications such that the primary applicant is also part of the concordance table
select distinct new_app.snz_legacy_application_uid, concord.snz_uid as primary_snz_uid 
from [hnz_clean].[new_applications] new_app
	inner join IDI_Sandpit.[DL-MAA2016-15].linked_ind_apps x 
	on (new_app.snz_legacy_application_uid=x.snz_legacy_application_uid)
	inner join [hnz_clean].[new_applications_household] new_app_hh 
	on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
	left join security.concordance concord 
	on (concord.snz_msd_uid=new_app_hh.primary_snz_msd_uid)
where concord.snz_spine_uid is null
--so, 8 applications do not have the primary snz_uid linked to concordance
--but we dont care that the primary applicant is not in concordance, provided that all of the applicants are.

--all applications in which primary applicant is in multiple applications
select distinct new_app.snz_legacy_application_uid 
from [hnz_clean].[new_applications] new_app
	inner join IDI_Sandpit.[DL-MAA2016-15].linked_ind_apps x 
	on (new_app.snz_legacy_application_uid=x.snz_legacy_application_uid)
	inner join [hnz_clean].[new_applications_household] new_app_hh 
	on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
	inner join security.concordance concord 
	on (concord.snz_msd_uid=new_app_hh.primary_snz_msd_uid)
		and  concord.snz_uid in (
			select concord.snz_uid as primary_snz_uid 
			from [hnz_clean].[new_applications] new_app
			inner join IDI_Sandpit.[DL-MAA2016-15].linked_ind_apps x 
				on (new_app.snz_legacy_application_uid=x.snz_legacy_application_uid)
			inner join [hnz_clean].[new_applications_household] new_app_hh 
				on new_app.snz_legacy_application_uid = new_app_hh.snz_legacy_application_uid
			inner join security.concordance concord 
				on (concord.snz_msd_uid=new_app_hh.primary_snz_msd_uid)
			where concord.snz_spine_uid is not null
			group by concord.snz_uid having count(distinct new_app.snz_legacy_application_uid)>1
		)
--12 applications- but if the primary applicant is not part of the actual application, we still dont care about removing these
-- We will update these applications with a new primary snz_uid based on eldest member of the application in a subsequent step.
************************************************************************************/


/* Create the household and individual tables*/
/* We also get the primary snz_uid for applications using the concordance table*/
/* 50205 individuals */
%si_conditional_drop_table(si_cond_table_in=sand.hnz_ind_newapps_0506);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.hnz_ind_newapps_0506 as 
	select * 

	from connection to odbc(
		select coalesce(cast(a.snz_application_uid as varchar(10)), '')  + '_' + coalesce(cast(a.snz_legacy_application_uid as varchar(10)),'') as app_id,
			b.*, 
			a.hnz_na_date_of_application_date, 
			regexit.hnz_re_exit_date, 
			regexit.hnz_re_exit_reason_text, 
			regexit.hnz_re_exit_status_text, 
			concord.snz_uid as primary_snz_uid
		from [hnz_clean].[new_applications] a
			inner join [IDI_Sandpit].[&si_proj_schema.].[linked_ind_apps] x 
				on (a.snz_legacy_application_uid=x.snz_legacy_application_uid)
			inner join [hnz_clean].[new_applications_household] b 
				on (a.snz_legacy_application_uid=b.snz_legacy_application_uid)
			inner join [hnz_clean].[register_exit] regexit 
				on regexit.snz_legacy_application_uid= a.snz_legacy_application_uid
			inner join security.concordance concord 
				on (concord.snz_msd_uid=b.primary_snz_msd_uid)
		where year(a.hnz_na_date_of_application_date) between &yearfrom. and &yearto.
			and regexit.[hnz_re_exit_date] between a.hnz_na_date_of_application_date 
			and dateadd(yyyy, 2, a.hnz_na_date_of_application_date)
			and a.snz_application_uid is null;
	);
	disconnect from odbc;

quit;

/*21888 Applications*/
%si_conditional_drop_table(si_cond_table_in=sand.hnz_hh_newapps_0506);

proc sql;

	connect to odbc(dsn=idi_clean_archive_srvprd);

	create table sand.hnz_hh_newapps_0506 as 
	select * 

	from connection to odbc(

		select coalesce(cast(a.snz_application_uid as varchar(10)), '')  + '_' + coalesce(cast(a.snz_legacy_application_uid as varchar(10)),'') as app_id,
			a.*, 
			regexit.hnz_re_exit_date, 
			regexit.hnz_re_exit_reason_text, 
			regexit.hnz_re_exit_status_text
		from [hnz_clean].[new_applications] a
			inner join [IDI_Sandpit].[&si_proj_schema.].[linked_ind_apps] x 
				on (a.snz_legacy_application_uid=x.snz_legacy_application_uid)
			inner join [hnz_clean].[register_exit] regexit 
				on regexit.snz_legacy_application_uid= a.snz_legacy_application_uid
		where year(a.hnz_na_date_of_application_date) between &yearfrom. and &yearto.
			and regexit.[hnz_re_exit_date] between a.hnz_na_date_of_application_date 
			and dateadd(yyyy, 2, a.hnz_na_date_of_application_date)
			and a.snz_application_uid is null;
	);
	disconnect from odbc;

quit;

