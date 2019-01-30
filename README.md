# Social Housing Analysis v1.0.0
Repository for the code required to run the Social Housing analysis end-to-end.

Note the coding style of this test case has been critiqued. You can read the blog [here](https://github.com/nz-social-investment-agency/sia_analytical_processes).


## Overview
This repository contains all the code required to run the analysis accompanying the [Social Housing Report](https://sia.govt.nz/assets/Uploads/sh-technical-report.pdf), published by the Social Investment Unit dated 02 June 2017.

## License for Social Housing Content
[![License: CC BY SA 4.0](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-sa/4.0/)

Crown copyright ©. This copyright work is licensed under the Creative Commons Attribution 4.0 International licence. In essence, you are free to copy, distribute and adapt the work, as long as you attribute the work to the New Zealand Government and abide by the other licence terms. 

To view a copy of this licence, visit [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/). 

Please note that neither the New Zealand Government emblem nor the New Zealand Government logo may be used in any way which infringes any provision of the [Flags, Emblems, and Names Protection Act 1981](http://www.legislation.govt.nz/act/public/1981/0047/latest/whole.html) or would infringe such provision if the relevant use occurred within New Zealand. Attribution to the New Zealand Government should be in written form and not by reproduction of any emblem or the New Zealand Government logo.

## License for Social Housing Code Base
GNU GPLv3 License

Crown copyright (c) 2017, Social Investment Agency on behalf of the New Zealand Government.

See ![LICENSE.md](https://github.com/nz-social-investment-agency/social_housing/blob/master/LICENSE) for more details.


## Pre-requisites
* The social_housing repository requires you to have access to the Integrated Data Infrastructure (IDI). Within the IDI, you would require a project folder to store all the required code, and a project schema in IDI_Sandpit to store all the data from the social housing analysis.
* You need access to the following IDI_Clean schemas-
	* moh_clean
	* moe_clean
	* msd_clean
	* acc_clean
	* cyf_clean
	* cor_clean
	* moj_clean
	* data
	
* The Social Investment Analytical Layer (SIAL) should be available in the project schema. Refer to [social investment analytical layer](https://github.com/nz-social-investment-unit/social_investment_analytical_layer) repository for instructions on how to get this installed. This version of the social housing repository is compatible with social investment analytical layer version 1.1.0.  
* The SI Data Foundation also needs to be downloaded and available for use in your project folder. You do not need to run this code explicitly, but there are components from this repository that are being used in the social housing analysis. Download the [si_data_foundation](https://github.com/nz-social-investment-unit/social_investment_data_foundation) repository and keep it in the project folder.  This version of the social housing repository is compatible with si_data_foundation version 1.0.0.  
 

## Executing the Code

The Social Housing Analysis code consists of SAS programs and macros (in `./sasprog/` and `./sasauto/` folders), R programs (in `./rprogs/`) and SQL scripts (in `./sql/`). The code execution is divided into 12 discrete chunks as listed in the sh_main.sas script. Following are the steps required to execute the code end-to-end. This 12-step process has to be run in 4 parts, switching between SAS and R:  
	* SAS: sh_main.sas from 1 to the step 9 (create train/test dataset)  
	* R: main_part1.R (propensity model)  
	* SAS: sh_main.sas from 10 to step 11 (import scores and create cost table)  
	* R: main_part2.R (cost analysis)  

The steps to execute the code are-

1. Ensure that the prerequisites are all available in your project folder and schema- 
	* You need to have downloaded the [social investment analytical layer (SIAL)](https://github.com/nz-social-investment-unit/social_investment_analytical_layer) which is a framework of tables and views that the social housing code uses to perform the analysis. These SIAL tables and views should be available in your project schema prior to running the social housing analysis code. Refer to the README in the social investment analytical layer repository for instructions on how to download and install the SIAL on your project schema. **Important: When you run the social investment analytical layer installation, ensure that it uses the same IDI refresh version that the social housing analysis is to be performed on.** For example, if you want the social housing analysis to run on the `IDI_Clean_20161020`, then the social_investment_analytical_layer should also use `IDI_Clean_20161020`. 
	* You need to have downloaded the [si_data_foundation](https://github.com/nz-social-investment-unit/social_investment_data_foundation) and it should be available for use in your project folder. You do not need to run this code; just ensure that these are stored somewhere in the project folder alloted to you in the IDI.
2. Download the social_housing repository on Github, and email the zipped file to access2microdata@stats.govt.nz and ask them to move it into your project folder on the IDI.
3. Unzip the files into your project folder.
4. Navigate to the `sasautos` folder under social_housing, and find the SAS script named `sh_si_setup.sas`. Open this script in SAS Enterprise Guide. This is the script that is used to set up some universal parameters for the analysis.
	* Find the variable named `si_proj_schema`. This should be assigned the target schema name, where the output tables of the social housing analysis would be written into.  
	* There are other parameters like the discounting rates, windowing parameters (profile and forecasting periods) and whether inflation should be applied to costs and so on. You can either use the default values already supplied for these, or edit these to choose your own values. Use this set of parameters to customise the analysis to your needs.
5. Navigate to the `sql` folder under social_housing, and open `source_data_query.sql` and `source_cost_table.sql`. Replace the reference to <target_schema> with your project schema name.
6. Navigate to the `sasprogs` folder under social_housing, and find the script called `sh_main.sas`. This is the main script that runs the analysis end-to-end. Open this script in SAS Enterprise Guide. Notice that the main script has named sections, each of which perform a specific task.
	* Go to the section named `1.SET UP VARIABLES AND MACROS`. This is where you will set up the required variables for your analysis. 
	* Supply the values for the variables named `sasdir` and `sasdirgen`, which are the paths to the social housing analysis code and the si data foundation code respectively. There are examples given in the code comments for your reference. 
	* Supply the value for the `IDIrefresh` variable. This variable tells the code to point to the required IDI Refresh version. By default, this value is `IDI_Clean`, which ensures that the analysis is done on the latest refresh version available. If you want the analysis to run on older iterations of IDI data, then supply the name of the IDI refresh version that you require. Whatever refresh version you provide here should be the same as the one you used for the social_investment_analytical_layer installation.
	* Execute the section `1.SET UP VARIABLES AND MACROS`. This initialises the parameters of the analysis.
7. Next, you define the social housing population that you are interested in. 
	* Go to the section named `2.DEFINE THE COHORT (2005/2006 HNZ APPLICATIONS)`, and provide the cohort that you are interested in. The variables `yearfrom` and `yearto` are used for this purpose. For example, if you are interested in the individuals/households that applied for social housing between the years 2005 to 2006 (01 Jan 2005 to 31 Dec 2006), use `yearfrom = 2005` and `yearto = 2006`.
	* Execute the section `2.DEFINE THE COHORT (2005/2006 HNZ APPLICATIONS)` to create the population of interest.
8. Now you are ready to create all the variables required for the analysis. Execute steps 3 to 9 sequentially to create the final analysis-ready dataset.
9. Next, you need to perform the propensity matching to identify the treatment and control groups for the analysis. For this, navigate to the `rprogs` folder under the project, and find the script named `main_part1.R`. This executes all the required analysis to create the weighted and matched treatment and control groups to perform a comparative analysis between those who receive social housing and those who applied but did not receive it. Note that the weighting is only performed for the control group, as the intended analysis for this dataset is to perform the Average Treatment Effect for the Treated(ATET).
10. Next, you are going to construct the weighted costs that are the point of comparison between the treatment and control groups after the treatment. Go back to `sh_main.sas`, and look at step 10. This loads the output from propensity matching model into SAS. Execute step 10 and 11 for creating the costs for both groups after the treatment application. 
11. Step 12 creates several bootstrap samples to estimate the confidence intervals for the differences in costs between the treatment and control groups. Go to `rprogs` and find the script named `main_part2.R`. Execute this R script to get the confidence intervals for the differences in costs between the two groups.

## Output
Final results, cost tables and plots would be available in the folder `./output/`. Detailed outputs for each step in the execution can be obtained from [Social_Housing_Code_Notes.docx](https://github.com/nz-social-investment-unit/social_housing/blob/master/Social_Housing_Code_Notes.docx)
	
## Getting Help:
For more help/guidance in running the SIAL, email info@siu.govt.nz

Tracking number: 
