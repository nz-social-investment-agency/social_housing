## ===================================================================== ##
## Script: main_part1.r
##
## Purpose: This script acts as the wrapper script that runs all specific
##    components to load the data and build the propensity score model 
##    (gradient boosting).
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## 
## Review: Ben VdB
## Date: 10/05/2017
## ===================================================================== ##

# Update the path below to reflect your environment
setwd("~/Network-Shares/Datalab-MA/MAA2016-15 Supporting the Social Investment Unit/github_social_housing_v2/rprogs");

# load SIU setup parameters
source("../include/siu_setup.R");

# Set seed for repeatabilit
set.seed(12345);

# Load libraries required for the model (versions used are given)
library(RODBC); # 1.3-14
library(caret); # 6.0-76
library(ggplot2); # 2.2.1
library(stringr); # 1.2.0
library(psych); # 1.7.3.21
library(reshape2); # 1.4.2
library(mlbench); # 2.1-1
library(e1071); # 1.6-8
library(pROC); # 1.9.1
library(randomForest); # 4.6-12
library(xgboost); # 0.6-4
library(knitr); # 1.15.1
library(dplyr); # 0.5.0
library(DiagrammeR); # 0.9.0
library(Ckmeans.1d.dp); # 4.0.1
library(vcd); # 1.4-3
library(readr); # 1.1.0
library(tidyr); # 0.6.1
library(tibble); # 1.2
library(xlsx); # 0.5.7
library(corrplot); # 0.77
library(survey); # 3.31-5

# 1. Load data sets
source("1. extract_dataset.R");

# 2. data preparation
source("2. premodelling_tasks.R");
source("3. check_correlations.R");

# 3. Gradient-boosting model
# 3.1 Grid search on parameters - find optimal ones
source("4. xgb_model.R");

# 3.2 Buildng final model - use optimal param. + variable selection
source("5. postmodelling_tasks.R");

# 4. Compute weights and check balance
source("6. ps_weighting_and_balancing.R");

