## ===================================================================== ##
## Script: ps_weighting and balancing.r
##
## Purpose: This script computs the weights based on the propensity scores
##      and check balances between groups
## 
## Author: C MacCormick - SIU
## Date: 04/11/2016
## Review: May 2017 Ben Vandenbroucke
##
## Note:this script contains hard coded values (see lines 146-149) and
##      requires manual operations (see lines )
## ===================================================================== ##

library("survey", lib.loc="~/My-R-User-Libraries")
library(tableone)
library(gridExtra)

########################################0. Load function from script ###################################

source("../include/balanceMetrics.R");
source("../include/initbalancescript.R")

########################################1. Read in scored datasets ###################################
scored_set_XGB <- read.csv("../output/full_dataset_with_finalxgbmodel_predictions.csv")
scored_set_XGB$region_code <- as.factor(scored_set_XGB$region_code);
scored_set_XGB$primary_sex_code <- as.factor(scored_set_XGB$primary_sex_code);
scored_set_XGB$hnz_na_analy_score_afford_text <- as.factor(scored_set_XGB$hnz_na_analy_score_afford_text);
scored_set_XGB$hnz_na_analy_score_adeq_text <- as.factor(scored_set_XGB$hnz_na_analy_score_adeq_text);
scored_set_XGB$hnz_na_analy_score_suitably_text <- as.factor(scored_set_XGB$hnz_na_analy_score_suitably_text);
scored_set_XGB$hnz_na_analy_score_sustain_text <- as.factor(scored_set_XGB$hnz_na_analy_score_sustain_text);
scored_set_XGB$hnz_na_analy_score_access_text <- as.factor(scored_set_XGB$hnz_na_analy_score_access_text);

xvars <- c( 'appl_year_qtr'
            ,'hnz_na_analy_score_afford_text'
            ,'hnz_na_analy_score_adeq_text'
            ,'hnz_na_analy_score_suitably_text'
            ,'hnz_na_analy_score_sustain_text'
            ,'hnz_na_analy_score_access_text'
            ,'hnz_na_analysis_total_score_text'
            ,'hnz_na_main_reason_app_text'
            ,'hnz_na_hshd_size_nbr'
            ,'hnz_na_bedroom_required_cnt_nbr'
            ,'region_code',
            "P1_IRD_INC_BEN_CST",
            "P2_IRD_INC_BEN_CST",
            "P3_IRD_INC_BEN_CST",
            "P4_IRD_INC_BEN_CST",
            "P1_IRD_INC_W_S_CST",
            "P2_IRD_INC_W_S_CST",
            "P3_IRD_INC_W_S_CST",
            "P4_IRD_INC_W_S_CST",
            "P1_MSD_BEN_T2_AS_CST",
            "P2_MSD_BEN_T2_AS_CST",
            "P3_MSD_BEN_T2_AS_CST",
            "P4_MSD_BEN_T2_AS_CST",
            "P1_MSD_BEN_T2_CST",
            "P2_MSD_BEN_T2_CST",
            "P3_MSD_BEN_T2_CST",
            "P4_MSD_BEN_T2_CST",
            "P1_MSD_BEN_T3_CST",
            "P2_MSD_BEN_T3_CST",
            "P3_MSD_BEN_T3_CST",
            "P4_MSD_BEN_T3_CST",
            "P2_MOH_GMS_GMS_CST",
            "P1_MOH_GMS_GMS_CST",
            "P2_MOH_PFH_PFH_CST",
            "P1_MOH_PFH_PFH_CST",
            "P3_MOH_PFH_PFH_CST",
            "P4_MOH_PFH_PFH_CST",
            "P1_MOH_LAB_LAB_CST",
            "P2_MOH_LAB_LAB_CST",
            "P1_MSD_CYF_CNP_CST",
            "P2_MSD_CYF_CNP_CST",
            "P3_MSD_CYF_CNP_CST",
            "P4_MSD_CYF_CNP_CST",
            "P4_MSD_CYF_YJU_CST",
            "P1_MSD_CYF_YJU_CST",
            "P2_MSD_CYF_YJU_CST",
            "P3_MSD_CYF_YJU_CST",
            "P1_COR_MMP_SAR_CST",
            "P2_COR_MMP_SAR_CST",
            "P3_COR_MMP_SAR_CST",
            "P4_COR_MMP_SAR_CST",
            "P1_ACC_CLA_INJ_CST",
            "P4_ACC_CLA_INJ_CST",
            "P3_ACC_CLA_INJ_CST",
            "P2_ACC_CLA_INJ_CST",
            "P1_MOE_MOE_ENR_CST",
            "P2_MOE_MOE_ENR_CST",
            "P3_MOE_MOE_ENR_CST",
            "P4_MOE_MOE_ENR_CST",
            "P_MSD_CYF_ABE_CNT",
            "P_MOH_CAN_REG_CNT",
            "P_MOH_TKR_CCC_CNT",
            "P_MOE_STU_INT_DUR",
            "P_MOE_STU_INT_CNT"
            ,'P_young_child'
            ,'P_older_child'
            ,'P_wk_age_adult'
            ,'P_old_adult'
            ,'primary_sex_code'
            ,'primary_ethnicity'
            ,'primary_Y1_wage'
            ,'primary_Y2_wage'
            ,'primary_Y3_wage'
            ,'primary_Y4_wage'
            ,'ben_to_wage_log_ratio'
            ,'age_band'
)




########################################2. Computes weights using propensity score ###################################

psVar <- scored_set_XGB$predicted_prob

# for ATT: weight = 1 for treatment group, ps/(1-ps) for comparison group
scored_set_XGB$inv_wt_att <- ifelse(scored_set_XGB$actual_class == 1, 1, (psVar)/(1-psVar))

write.csv(scored_set_XGB, "../output/full_data_with_propensity_weights.csv");


########################################3. Check balance of covariates post weighting ###################################

###Run in 4 chunks -- hardcoded (not ideal!!)
###Make sure to check the length of xvars and amend where necessary!!
xvars1 <- xvars[1:20]
xvars2 <- xvars[21:40]
xvars3 <- xvars[41:60]
xvars4 <- xvars[61:76]

# the lines below create 4 CSV files
# These 4 files have to be manually collated and formatted; the resulting file
#       must b named 'std_diff_for_plot.csv'
# -see pre_and_post_balance_metrics_EXAMPLE.csv and std_diff_for_plot_EXAMPLE.csv
#       in the ../output folder for example
df1 <- balanceMetrics(inSet = scored_set_XGB, weightVar = scored_set_XGB$inv_wt_att,
               outPath = "../output/pre_and_post_balance_metrics_XGB1.csv",
               Xvars = xvars1, target = "actual_class")
df2 <- balanceMetrics(inSet = scored_set_XGB, weightVar = scored_set_XGB$inv_wt_att,
               outPath = "../output/pre_and_post_balance_metrics_XGB2.csv",
               Xvars = xvars2, target = "actual_class")
df3 <- balanceMetrics(inSet = scored_set_XGB, weightVar = scored_set_XGB$inv_wt_att,
               outPath = "../output/pre_and_post_balance_metrics_XGB3.csv",
               Xvars = xvars3, target = "actual_class")
df4 <- balanceMetrics(inSet = scored_set_XGB, weightVar = scored_set_XGB$inv_wt_att,
               outPath = "../output/pre_and_post_balance_metrics_XGB4.csv",
               Xvars = xvars4, target = "actual_class")

#### Collate the csv files manually (>>> or write a script !!)


####Plots

grid.arrange(
  ggplot(data = scored_set_XGB, aes(predicted_prob, colour=as.factor(actual_class))) + geom_freqpoly(bins = 50),
  ggplot(data = scored_set_XGB, aes(predicted_prob, colour=as.factor(actual_class), weight = inv_wt_att)) + geom_freqpoly(bins = 50)
)

# read computed std diff
# Uncomment the following line for deeper analysis of the std differences.
# balanceDS <- read.csv("../output/std_diff_for_plot.csv")

balancePlot <- ggplot(data = balanceDS, 
                      mapping = aes(x = reorder(var, std_diff), 
                                    y = std_diff, color = pre_post))

balancePlot + geom_point() + 
    scale_color_manual(values = c("Weighted" = siuGreen, "Unweighted" = siuOrange)) + coord_flip() +
    geom_hline(yintercept = 0.1, color = siuDarkBlue2, linetype = "dashed") +
    ylab("Standardised Mean Difference") + 
    xlab("Variable Name") + 
    theme(legend.title = element_blank(), legend.position = "bottom", 
          text = element_text(colour = siuGreen2, family = 'Century Gothic'))

ggsave(filename = paste("../output/plots/balanceplot.tiff"), device="tiff");

