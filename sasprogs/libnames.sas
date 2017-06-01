/****************************************************
TITLE: libnames.sas

DESCRIPTION: loads all libraries relevant to our project

INPUT:	none

OUTPUT:	none

NOTES: 
You need to have the corresponding access rights

****************************************************/

/*libname data ODBC dsn=idi_clean_archive_srvprd schema=data;*/
libname data ODBC dsn=&IDIrefresh. schema=data;
/*DoL*/
libname dol ODBC dsn=&IDIrefresh. schema=dol_clean;

/*HLFS*/
libname hlfs ODBC dsn=&IDIrefresh. schema=hlfs_clean;

/*LEED*/
libname leed ODBC dsn=&IDIrefresh. schema=from_leed_clean;

/*MoE*/
libname moe ODBC dsn=&IDIrefresh. schema=moe_clean;

/*MSD*/
libname msd_leed ODBC dsn=&IDIrefresh. schema=from_leed_clean;

libname msd ODBC dsn=&IDIrefresh. schema=msd_clean;

/*SLA*/
libname sla ODBC dsn=&IDIrefresh. schema=sla_clean;

/*MoE School*/
/*libname moe ODBC dsn=idi_clean_archive_srvprd schema=data;*/

libname moe ODBC dsn=&IDIrefresh. schema=moe_clean;

/*MoE Tertiary Provider*/
/*libname moe ODBC dsn=idi_clean_archive_srvprd schema=data;*/

libname moe ODBC dsn=&IDIrefresh. schema=moe_clean;

/*MoE Tertiary Workplace*/
/*??????*/
/*libname moe ODBC dsn=idi_clean_archive_srvprd schema=data;*/

libname moe ODBC dsn=&IDIrefresh. schema=moe_clean;

/*MoE NSI*/
/*libname moe ODBC dsn=idi_clean_archive_srvprd schema=data;*/

/*COR*/
libname cor ODBC dsn=&IDIrefresh. schema=cor_clean;

/*MOJ*/
libname moj ODBC dsn=&IDIrefresh. schema=moj_clean;

/*ACC*/
/*libname acc ODBC dsn=&IDIrefresh. schema=acc_clean;*/
/* May 2017 refresh not complete (data from 2014 only)  */
/* Using the previous refresh then */
libname acc ODBC dsn=idi_clean_20160715_srvprd schema=acc_clean;


/*CUS*/
libname cus ODBC dsn=&IDIrefresh. schema=cus_clean;

/*LISNZ*/
libname lisnz ODBC dsn=&IDIrefresh. schema=lisnz_clean;

/*MS*/
libname ms ODBC dsn=&IDIrefresh. schema=ms_clean;

/*SOFIE*/
libname sofie ODBC dsn=&IDIrefresh. schema=sofie_clean;

/*DBH*/
libname dbh ODBC dsn=&IDIrefresh. schema=dbh_clean;

/*IR_restrict*/
libname ir ODBC dsn=&IDIrefresh. schema=ir_clean;

/*WFF*/
libname wff ODBC dsn=&IDIrefresh. schema=wff_clean;

/*BR*/
libname br ODBC dsn=&IDIrefresh. schema=br_clean;

/*CYF*/
libname cyf ODBC dsn=&IDIrefresh. schema=cyf_clean;

/*DIA*/
libname dia ODBC dsn=&IDIrefresh. schema=dia_clean;

/*POL*/
libname pol ODBC dsn=&IDIrefresh. schema=pol_clean;

/*MOH*/
libname moh ODBC dsn=&IDIrefresh. schema=moh_clean;

/*CEN*/
libname cen ODBC dsn=&IDIrefresh. schema=cen_clean;

/*HNZ*/
libname hnz ODBC dsn= &IDIrefresh. schema=hnz_clean;

libname hnz_s ODBC dsn=idi_sandpit_srvprd schema=clean_read_hnz;

/*YST*/
libname yst ODBC dsn= &IDIrefresh. schema=yst_clean;

/*HES*/
libname hes ODBC dsn= &IDIrefresh. schema=hes_clean;

libname class ODBC dsn=idi_metadata_srvprd schema=clean_read_CLASSIFICATIONS;
/*libname idi_meta ODBC dsn=idi_clean_archive_srvprd  schema=metadata;*/

libname sandwff ODBC dsn=idi_sandpit_srvprd schema="clean_read_wff";
libname sandDIA ODBC dsn=idi_sandpit_srvprd schema="clean_read_DIA";
libname sandmoh1 ODBC dsn=idi_sandpit_srvprd schema="clean_read_MOH_b4sc";
libname sandmoh2 ODBC dsn=idi_sandpit_srvprd schema="clean_read_MOH_nir";
libname sandmoh3 ODBC dsn=idi_sandpit_srvprd schema="clean_read_MOH_PHARMACEUTICAL";
libname sandmoh4 ODBC dsn=idi_sandpit_srvprd schema="clean_read_MOH_health_tracker";
libname sandmoh5 ODBC dsn=idi_sandpit_srvprd schema="clean_read_MOH_maternity";
libname sandind ODBC dsn=idi_sandpit_srvprd schema="clean_read_INDICATORS";
libname sandcen ODBC dsn=idi_sandpit_srvprd schema="clean_read_cen";
libname sandcyf ODBC dsn=idi_sandpit_srvprd schema="clean_read_cyf";
libname sandmoe ODBC dsn=idi_sandpit_srvprd schema="clean_read_moe";

/* personal area for tables */
libname al "\\WPRDFS08\Datalab-MA\MAA2016-15 Supporting the Social Investment Unit\Analytical layer\Events\R";
