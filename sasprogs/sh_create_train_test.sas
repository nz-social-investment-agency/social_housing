/****************************************************
TITLE: create_train_test.sas

DESCRIPTION: creates train / test partition of the cohort
	+ adds few variables (age band, appl. year/quarter...) 

INPUT:	all_hh_variables_cohort_0506

OUTPUT:	sh_pop_0506 

NOTES: 

AUTHOR: 
E Walsh

DATE: 02 Nov 2016

HISTORY:
09 May 2017 BV: only use of the all_hh_variables_cohort_0506 (already joined)
27 Mar 2017 AM: added creation of joined_hnz_tables
07 Mar 2017 AM QA, comments
02 Nov 2016 EW v1
****************************************************/

%si_conditional_drop_table(si_cond_table_in=sand.sh_pop_0506);

data sand.sh_pop_0506 (drop=ran_num);
	set sand.all_hh_variables_cohort_0506;
	length age_band $ 7;
	call streaminit(12345);
	ran_num = rand("Uniform");

	if 0 <= primary_age <= 23 then
		age_band = "0-23";
	else if  24 <= primary_age <= 29  then
		age_band = "24-29";
	else if 30 <= primary_age <= 34 then
		age_band = "30-34";
	else if 35 <= primary_age <= 40 then
		age_band = "35-40";
	else if 41 <= primary_age <= 49 then
		age_band = "41-49";
	else if 50 <= primary_age <= 64 then
		age_band = "50-64";
	else if primary_age > 64 then
		age_band = "65_plus";
	else age_band=primary_age;

	appl_year_qtr = put(datepart(hnz_na_date_of_application_date),yyq6.);

	if (ran_num <0.7) then group = "TRAIN";
	else group = "VALID";
run;
