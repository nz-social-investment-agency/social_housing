## ===================================================================== ##
## Script: postmodelling_tasks.r
##
## Purpose: This script retrains the gradient boosted tree model with selected 
##          subset of the full list of variables for social housing. 
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## Review: May 2017 Ben Vandenbroucke
## ===================================================================== ##

########################################1. Variables selection ###################################
# choose option for variable selection:

# option 1. keep top N variables based on importance
#variablecount <- 50 # number of variable to be retained in the model
#retainvars <- importance_matrix$Feature[1:variablecount];

# option 2. write custom list 
# in the present case, we are getting rid of LAB_TEST and GMS costs for year Y3 and Y4 (data availability issues)
retainvars <- c( "appl_year_qtr2005Q2",
                 "appl_year_qtr2005Q3",
                 "appl_year_qtr2005Q4",
                 "appl_year_qtr2006Q1",
                 "appl_year_qtr2006Q2",
                 "appl_year_qtr2006Q3",
                 "appl_year_qtr2006Q4",
                 "hnz_na_analy_score_afford_text",
                 "hnz_na_analy_score_adeq_text",
                 "hnz_na_analy_score_suitably_text",
                 "hnz_na_analy_score_sustain_text",
                 "hnz_na_analy_score_access_text",
                 "hnz_na_analysis_total_score_textB",
                 "hnz_na_analysis_total_score_textC",
                 "hnz_na_analysis_total_score_textD",
                 "hnz_na_main_reason_app_textBETTER UTIL",
                 "hnz_na_main_reason_app_textCUSTODY ACCS",
                 "hnz_na_main_reason_app_textDISCRIMINATN",
                 "hnz_na_main_reason_app_textEMP OPPORT",
                 "hnz_na_main_reason_app_textFAMILY REASN",
                 "hnz_na_main_reason_app_textFINANCIAL",
                 "hnz_na_main_reason_app_textFIRE DAMAGE",
                 "hnz_na_main_reason_app_textHEALTH",
                 "hnz_na_main_reason_app_textHNZ SERVICES",
                 "hnz_na_main_reason_app_textHOMELESSNESS",
                 "hnz_na_main_reason_app_textHOME SOLD",
                 "hnz_na_main_reason_app_textHSE FOR SALE",
                 "hnz_na_main_reason_app_textINADEQUATE",
                 "hnz_na_main_reason_app_textMODIFICATION",
                 "hnz_na_main_reason_app_textNEIGHBOUR IS",
                 "hnz_na_main_reason_app_textPERS SAFETY",
                 "hnz_na_main_reason_app_textSPECIAL NEED",
                 "hnz_na_main_reason_app_textTENANCY TERM",
                 "hnz_na_hshd_size_nbr",
                 "hnz_na_bedroom_required_cnt_nbr",
                 "region_code1",
                 "region_code3",
                 "region_code4",
                 "region_code5",
                 "region_code6",
                 "region_code7",
                 "region_code8",
                 "region_code9",
                 "region_code12",
                 "region_code13",
                 "region_code14",
                 "region_code15",
                 "region_code16",
                 "region_code17",
                 "region_code18",
                 "region_code98",
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
                 "P2_MSD_BEN_T2_AS_CST",
                 "P1_MSD_BEN_T2_CST",
                 "P2_MSD_BEN_T2_CST",
                 "P3_MSD_BEN_T2_CST",
                 "P2_MSD_BEN_T2_CST",
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
                 "P_MOE_STU_INT_CNT",
                 "P_young_child",
                 "P_older_child",
                 "P_wk_age_adult",
                 "P_old_adult",
                 "primary_sex_code2",
                 "primary_ethnicityA",
                 "primary_ethnicityM",
                 "primary_ethnicityO",
                 "primary_ethnicityP",
                 "primary_ethnicityZ",
                 "primary_Y1_wage",
                 "primary_Y2_wage",
                 "primary_Y3_wage",
                 "primary_Y4_wage",
                 "primary_total_ben",
                 "ben_to_wage_log_ratio",
                 "age_band24-29",
                 "age_band30-34",
                 "age_band35-40",
                 "age_band41-49",
                 "age_band50-64",
                 "age_band65_plus",
                 "hnz_na_main_reason_app_text_OVERCROWDING",
                 "region_code_2",
                 "primary_ethnicity_E",
                 "hnz_na_analysis_total_score_text_A"
);

# option 3. keep all variables - no further selection
#retainvars <- colnames(dtrain_temp);


dtrain_final_temp <- dtrain_temp[ ,colnames(dtrain_temp) %in% retainvars];
dvalid_final_temp <- dvalid_temp[ ,colnames(dtrain_temp) %in% retainvars];
dtrain_final <- xgb.DMatrix(data.matrix(dtrain_final_temp), label=as.integer(y_train$actual_class));
dvalid_final <- xgb.DMatrix(data.matrix(dvalid_final_temp), label=as.integer(y_valid$actual_class));

########################################2. Rebuild model ###################################

# Use the model parameters from the previous model. 
# No grid search to be used here for fear of introducing overfitting to training set.
final_param <- list(max_depth=opt_max_depth_val, eta=opt_eta_val, n_thread=4, silent=1, booster="gbtree",
                    subsample=opt_subsample_val,
                    colsample_bytree=opt_colsample_val
);
num_round <- opt_num_rounds;
final_model <- xgb.train(final_param, data = dtrain_final, nrounds = num_round, 
                         objective="binary:logistic", 
                         eval_metric="auc",
                         verbose=1,
                         maximize = FALSE
);

# Make prediction using the model with feature selection.
final_predprob_train <- predict(final_model, dtrain_final);
final_predclass_train <- as.numeric(final_predprob_train > 0.5);
final_pred_train <- NULL;
final_pred_train$rowval <-  rownames(X_train);
final_pred_train$actual_class <-  y_train$actual_class;
final_pred_train$predicted_class <-  final_predclass_train;
final_pred_train$predicted_prob <-  final_predprob_train;
final_acc_train <- mean(final_predclass_train == y_train$actual_class);
cat("Final Model Training Accuracy: ", final_acc_train);
final_train_confM <- confusionMatrix(final_predclass_train, y_train$actual_class, positive = "1");
png(file="../output/plots/finalxgbmodel_train_auc.png")
plot.roc(y_train$actual_class, final_predprob_train, print.auc=TRUE, print.auc.y=0.5, print.thres=TRUE, col="#1c61b6");
dev.off()

final_predprob_valid <- predict(final_model, dvalid_final);
print(head(final_predprob_valid));
final_predclass_valid <- as.numeric(final_predprob_valid > 0.5);
final_pred_valid <- NULL;
final_pred_valid$rowval <- rownames(X_valid);
final_pred_valid$actual_class <-  y_valid$actual_class;
final_pred_valid$predicted_class <-  final_predclass_valid;
final_pred_valid$predicted_prob <-  final_predprob_valid;
final_acc_valid <- mean(final_predclass_valid == y_valid);
print(final_acc_valid);
final_valid_confM <- confusionMatrix(final_predclass_valid, y_valid$actual_class, positive = "1");
png(file="../output/plots/finalxgbmodel_valid_auc.png");
plot.roc(y_valid$actual_class, final_predprob_valid, print.auc=TRUE, print.auc.y=0.5, print.thres=TRUE, col="#008600");
dev.off();  


# Dump the model to text file and plot the feature importance and first tree.
model <- xgb.dump(final_model, with_stats=T);
importance_matrix_final <- xgb.importance(colnames(dtrain_final_temp), model = final_model);
importance_matrix_dtl_final <- xgb.importance(colnames(dtrain_final_temp), model = final_model, data = dtrain_final_temp, label = y_train$actual_class);
xgb.plot.importance(importance_matrix_final, cex=0.7);
png(file="../output/plots/finalxgbmodel_first_tree.png");
xgb.plot.tree(feature_names=colnames(dtrain_final_temp), model=final_model, n_first_tree = 1);
dev.off();
  
d_temp <- model.matrix(~., data=X)[,-1];
dtrain <- xgb.DMatrix(data.matrix(model.matrix(~., data=X_train)[,-1]), label=as.integer(y_train$actual_class));
dvalid <- xgb.DMatrix(data.matrix(model.matrix(~., data=X_valid)[,-1]), label=as.integer(y_valid$actual_class));


final_pred_train$Group <- 'TRAIN'
final_pred_valid$Group <- 'VALID'
final_pred_total <- rbind(as.data.frame(final_pred_valid), as.data.frame(final_pred_train));
final_pred_total$decilerank <- cut(final_pred_total$predicted_prob, breaks=quantile(final_pred_total$predicted_prob, probs = seq(0, 1, length =11)), labels=1:10, include.lowest = TRUE)
final_total_confM <- confusionMatrix(final_pred_total$predicted_class, final_pred_total$actual_class, positive = "1");
png(file="../output/plots/finalxgbmodel_full_auc.png")
plot.roc(final_pred_total$actual_class, final_pred_total$predicted_prob, print.auc=TRUE, print.auc.y=0.5, print.thres=TRUE, col="#840000");  
dev.off();

# Merge back the predictions in the dataset
dataset$rowval <- NULL
dataset[dataset$Group=='TRAIN',"rowval"] <- rownames(dataset[dataset$Group=='TRAIN',])
dataset[dataset$Group=='VALID',"rowval"] <- rownames(dataset[dataset$Group=='VALID',])
full_dataset <- inner_join(dataset, final_pred_total, by=c("rowval","Group", "actual_class"));


# Write outputs.
write.csv(xgb.model.dt.tree(colnames(dtrain_temp), model = final_model, n_first_tree = 1), "../output/finalxgbmodel_first_tree.csv");
write.csv(importance_matrix_final, "../output/finalxgbmodel_importance_matrix.csv");
write.csv(importance_matrix_dtl_final, "../output/finalxgbmodel_importance_matrix_detailed.csv");
write.csv(final_pred_train, "../output/finalxgbmodel_training_predictions.csv");
write.csv(final_pred_valid, "../output/finalxgbmodel_validation_predictions.csv");
write.csv(final_pred_total, "../output/finalxgbmodel_total_predictions.csv");
write.csv(full_dataset, "../output/full_dataset_with_finalxgbmodel_predictions.csv");
save(final_train_confM, file="../output/finalxgbmodel_confusionmatrix_train.RData")
save(final_valid_confM, file="../output/finalxgbmodel_confusionmatrix_valid.RData")
save(final_total_confM, file="../output/finalxgbmodel_confusionmatrix_total.RData")

########################################################################################################################################

# Check the common balance
ggplot(full_dataset , aes(x=predicted_prob, fill=as.factor(actual_class))) + 
    geom_histogram(aes(y=..count..  ), position="dodge") + 
    scale_fill_siu() 
ggsave("../output/plots/balance_plot.png");

