## ===================================================================== ##
## Script: premodelling_tasks.r
##
## Purpose: Code for pre-tests on data, transformations, split into 
##          train/validation and visualizations.
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## Modified: 08/11/2016     
## Review: May 2017 Ben Vandenbroucke
## ===================================================================== ##


print("Running premodelling_tasks.R");

#########################0. Init ##################################################
# enter proportion for validation set -see comment in code below
validation_size <-  0.3;

# Define dataset level variables here.
id = "snz_legacy_application_uid";
ycol = "actual_class";
groupval = "Group"

irrelevant_cols <- c("hnz_re_exit_status_text",
                     "primary_age",
                     "P3_MOH_LAB_LAB_CST",
                     "P4_MOH_LAB_LAB_CST",
                     "P3_MOH_GMS_GMS_CST",
                     "P4_MOH_GMS_GMS_CST"
);

dataset <- applications_data;

##########################1. Data Cleaning #################################################

# Add variable transformations required
dataset$region_code <- as.factor(dataset$region_code);
dataset$primary_sex_code <- as.factor(dataset$primary_sex_code);

# Relevel app_main_reason to OVERCROWDING as base level
dataset$hnz_na_main_reason_app_text <- relevel(dataset$hnz_na_main_reason_app_text, "OVERCROWDING");
data.frame(levels=unique(dataset$hnz_na_main_reason_app_text), value=as.numeric(unique(dataset$hnz_na_main_reason_app_text)))
dataset$hnz_na_main_reason_app_text_OVERCROWDING <- 0;
dataset[dataset$hnz_na_main_reason_app_text %in% c("OVERCROWDING"), "hnz_na_main_reason_app_text_OVERCROWDING"] <- 1;

# Relevel curr_hnz_region_code to 02 (Auckland) as base level
dataset$region_code <- relevel(dataset$region_code, "2");
data.frame(levels=unique(dataset$region_code), value=as.numeric(unique(dataset$region_code)));
dataset$region_code_2 <- 0;
dataset[dataset$region_code %in% c("2") , "region_code_2"] <- 1; 

# Relevel primary_ethnic_ind to "E" as base level
dataset$primary_ethnicity <- relevel(dataset$primary_ethnicity, "E");
data.frame(levels=unique(dataset$primary_ethnicity), value=as.numeric(unique(dataset$primary_ethnicity)));
dataset$primary_ethnicity_E <- 0;
dataset[dataset$primary_ethnicity %in% c("E") , "primary_ethnicity_E"] <- 1; 
dataset$hnz_na_analysis_total_score_text_A <- 0;
dataset[dataset$hnz_na_analysis_total_score_text %in% c("A") , "hnz_na_analysis_total_score_text_A"] <- 1; 


# Drop columns that are not to be used in the model
if (length(irrelevant_cols) > 0) {
  dataset <- dataset[ ,!names(dataset) %in% irrelevant_cols];
}

# Validate the structure and format of dataset
str(dataset);

# Drop NaNs from dataset or impute it. Apply decisions here. 
names(dataset)[colSums(is.na(dataset)) > 0]; # Print columns with NA
dataset <- na.omit(dataset);
# Validate that there are no "NA" values in the data
checkdata <- dataset[rowSums(is.na(dataset)) > 0, ]
ifelse(nrow(checkdata) > 0, print("Rows with Missing data found"), print("No Missing Data") );

# Split labels and covariates into different dataframes.
y <- dataset[ , ycol];

# Remove target
X <- dataset[, !names(dataset) %in% c(id)];


# Remove all columns where std deviation is zero, ie, there is no variation, and
# print the columns dropped.
X_num <- X[ ,sapply(X, is.numeric)]
fullcols <- as.list(names(X_num));
X_num <- X_num[, apply(X_num, 2, function(x){sd(x)!=0} )];
dropcols <- fullcols[!fullcols %in% as.list(names(X_num))];
X <- X[ ,!names(X) %in% dropcols];

# Train-Validation split
# note: the data contans a column indicating the group (train or test) already
# otherwise, use commented lines below
X_train <- X[X$Group %in% c("TRAIN"), ];
y_train <- X[X$Group %in% c("TRAIN"), ycol ];
X_train <- X_train[, !names(X_train) %in% c(ycol, groupval)];
X_valid <- X[X$Group %in% c("VALID"), ];
y_valid <- X[X$Group %in% c("VALID"), ycol ];
X_valid <- X_valid[, !names(X_valid) %in% c(ycol, groupval)];

# if train / test split not performed already ... 
# ... use lines below instead
#train_indices <- createDataPartition(y, times =1, p=(1-validation_size), list=TRUE);
#X_train <- X[train_indices$Resample1, ];
#y_train <- y[train_indices$Resample1];
#X_valid <- X[-train_indices$Resample1, ];
#y_valid <- y[-train_indices$Resample1];



##########################2. Visualizations and descr. stats #############################################

# Separate out the numeric/int variables from categorical, for correlations analysis
dataset$exit_status <- dataset$actual_class
num <- sapply(dataset, is.numeric);
apps_data_num <- dataset[ , num];
fac <- sapply(dataset, is.factor);
apps_data_fac <- dataset[ , fac];
apps_data_fac$actual_class <- as.factor(dataset$actual_class);

# Function to create and save histograms for all numeric variables in the dataset
create_hist <- function(data) {
  cols <- colnames(data);
  
  for(i in 1:ncol(data)){
    ggplot(data, aes(x=data[ , i], fill=as.factor(exit_status))) + 
          geom_histogram(aes(y=..count..  ), position="dodge") + 
          xlab(as.character(cols[i])) + scale_colour_siu() ;
    ggsave(filename = paste("../output/plots/hist_", as.character(cols[i]),".tiff"), device="tiff");
  }
}
create_hist(apps_data_num);

data_desc <- psych::describe(X_num);
data_desc_by_exitstatus <- psych::describeBy(apps_data_num, group = ycol);
write.xlsx(data_desc, file="../output/numeric_variables_descriptive_stats.xlsx", sheetName="All", append=TRUE);
write.xlsx(as.data.frame(data_desc_by_exitstatus[1]), file="../output/numeric_variables_descriptive_stats.xlsx", sheetName="NotHoused", append=TRUE);
write.xlsx(as.data.frame(data_desc_by_exitstatus[2]), file="../output/numeric_variables_descriptive_stats.xlsx", sheetName="Housed", append=TRUE);


# Chi-Squared test with outcome for categorical variables
col <- names(apps_data_fac[ ,!names(apps_data_fac) %in% c(id, ycol)]);
chisqdata <- matrix(nrow=length(col), ncol=4);
for (i in 1:length(col)){
    chidata <- chisq.test(apps_data_fac[ , col[i]], apps_data_fac$actual_class);
    chisqdata[i,1] <- col[i];
    chisqdata[i,2] <- chidata$statistic[[1]];
    chisqdata[i,3] <- chidata$parameter[[1]];
    chisqdata[i,4] <- chidata$p.value[[1]];

   # write.xlsx(as.data.frame(apps_data_fac %>% group_by(actual_class, apps_data_fac[,col[i]]) %>% summarize(n() )), 
    #           file="../output/categorical_variables_descriptive_stats.xlsx", sheetName= col[i], append=TRUE);
}
write.csv(chisqdata, '../output/categorical_variables_chisquared_target.csv') ;

print("Completed premodelling_tasks.R")

