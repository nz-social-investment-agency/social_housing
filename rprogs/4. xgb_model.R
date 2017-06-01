## ===================================================================== ##
## Script: xgb_model.r
##
## Purpose: This script fits a gradient boosted tree model for the application 
##          level data for households applying for social housing.
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## Review: May 2017 Ben Vandenbroucke
## ===================================================================== ##

print("Running xgb_model.R");

# Process the train and validation sets and make them ready for applying xgboost.
predlist <-names(X_train);
X_valid<- X_valid[ ,names(X_valid) %in% predlist];

# Convert all categorical covariates into one-hot encoding for xgboost.
dtrain_temp <- model.matrix(~., data=X_train)[,-1];
dvalid_temp <- model.matrix(~., data=X_valid)[,-1];
dtrain <- xgb.DMatrix(data.matrix(model.matrix(~., data=X_train)[,-1]), label=as.integer(y_train$actual_class));
dvalid <- xgb.DMatrix(data.matrix(model.matrix(~., data=X_valid)[,-1]), label=as.integer(y_valid$actual_class));

####################################1. grid search on parameters ############################################################

# Define parameter space, and do a grid search for best parameters in xgboost
xgb_grid <- expand.grid(
  max_depth = c(3, 5, 7),
  eta = c(0.1, 0.01, 0.001),
  subsample = c(0.75, 0.9),
  colsample_bytree = c(0.6, 0.8)
);

rmseErrorsHyperparameters <- apply(xgb_grid, 1, function(parameterList){
  # Extract parameters to use
  max_depth_val = parameterList[["max_depth"]];
  eta_val = parameterList[["eta"]];
  subsample_val = parameterList[["subsample"]];
  colsample_bytree_val =  parameterList[["colsample_bytree"]];
  
  bstcv <- xgb.cv(data = dtrain, nrounds = 500, nfold=10, showsd= TRUE,
                  objective="binary:logistic", 
                  metrics=list("auc", "error"),
                  verbose=1,
                  nthread=4,
                  max_depth = max_depth_val,
                  eta = eta_val,
                  subsample = subsample_val,
                  colsample_bytree = colsample_bytree_val,
                  early.stop.round=20,
                  maximize = FALSE,
                  seed=12345
  );
  

  xvalidationscores <- as.data.frame(bstcv$evaluation_log);
  errval <- tail(xvalidationscores$test_error_mean, 1);
  aucval <- tail(xvalidationscores$test_auc_mean, 1);
  best_iter <- which.max(xvalidationscores[, "test_auc_mean"]);
  
  return(c(max_depth_val, eta_val, subsample_val, colsample_bytree_val, best_iter, aucval, errval))
});

write.csv(rmseErrorsHyperparameters, "../output/xgb_hyperparameters_tuning.csv");

# getting best values for model (lowest MSE) 
opt_max_depth_val <- rmseErrorsHyperparameters[1 , which(rmseErrorsHyperparameters[6, ] == max(rmseErrorsHyperparameters[6, ]))];
opt_eta_val <- rmseErrorsHyperparameters[2 , which(rmseErrorsHyperparameters[6, ] == max(rmseErrorsHyperparameters[6, ]))];
opt_subsample_val <- rmseErrorsHyperparameters[3 , which(rmseErrorsHyperparameters[6, ] == max(rmseErrorsHyperparameters[6, ]))];
opt_colsample_val <- rmseErrorsHyperparameters[4 , which(rmseErrorsHyperparameters[6, ] == max(rmseErrorsHyperparameters[6, ]))];
opt_num_rounds <- rmseErrorsHyperparameters[5 , which(rmseErrorsHyperparameters[6, ] == max(rmseErrorsHyperparameters[6, ]))];


####################################2. building model using best parameters ############################################################
# Use the best model output from the hyperpaparmeter tuning using the max AUC and min error.
opt_param <- list(max_depth=opt_max_depth_val, 
                  eta=opt_eta_val, 
                  n_thread=4, silent=1, booster="gbtree",
                  subsample=opt_subsample_val,
                  colsample_bytree=opt_colsample_val
);
num_round <- opt_num_rounds;
opt_model <- xgb.train(opt_param, data = dtrain, nrounds = num_round,
              objective="binary:logistic", 
              eval_metric="auc",
              verbose=1,
              maximize = FALSE
);

# Dump the model to text file and plot the feature importance and first tree.
model <- xgb.dump(opt_model, with_stats=T);
importance_matrix <- xgb.importance(colnames(dtrain_temp), model = opt_model);
importance_matrix_dtl <- xgb.importance(colnames(dtrain_temp), model = opt_model, data = dtrain_temp, label =y_train$actual_class);
xgb.plot.importance(importance_matrix, cex=0.7);
xgb.plot.tree(feature_names=colnames(dtrain_temp), model=opt_model, n_first_tree = 1);

# Based on the variable importance from the model, plot the feature-gain graph to determine ideal number of features.
write.csv(xgb.model.dt.tree(colnames(dtrain_temp), model = opt_model, n_first_tree = 1), "../output/xgbmodel_first_tree.csv");
write.csv(importance_matrix, "../output/xgbmodel_importance_matrix.csv");
write.csv(importance_matrix_dtl, "../output/xgbmodel_importance_matrix_detailed.csv");


# Predict the classification of training and validation set.
pred_train <- predict(opt_model, dtrain);
print(head(pred_train))
prediction <- as.numeric(pred_train > 0.5);
acc <- mean(prediction == y_train);
print(acc);
confM_train <- confusionMatrix(prediction, y_train$actual_class, positive = "1");
rocobj_train <- plot.roc(y_train$actual_class, pred_train, print.auc=TRUE, print.auc.y=0.5, print.thres=TRUE, col="#1c61b6");


# Do not use the below code - may introduce unconscious bias in model selection.
pred_valid <- predict(opt_model, dvalid);
print(head(pred_valid))
prediction <- as.numeric(pred_valid > 0.5);
acc <- mean(prediction == y_valid);
print(acc);
confM_valid <- confusionMatrix(prediction, y_valid$actual_class, positive = "1");
rocobj_valid <- plot.roc(y_valid$actual_class, pred_valid, print.auc=TRUE, print.auc.y=0.5, print.thres=TRUE, col="#008600");



#########################################3. checking performances ###############################################################

# Check performance of the model with incremental number of parameters based on the importance matrix.
accmatrix <- c();
aucmatrix <- c();
for (i in 5:nrow(importance_matrix)){
  print("loop"); print(i);
  feature_list <- c(importance_matrix$Feature[1:i]);
  #dtrain <- xgb.DMatrix(data.matrix(dtrain_temp[ , colnames(dtrain_temp) %in% feature_list]), label=as.integer(y_train));
  dtrain_check <- xgb.DMatrix(data.matrix(dvalid_temp[ , colnames(dvalid_temp) %in% feature_list]), label=as.integer(y_valid$actual_class));
  testmodel <- xgb.cv(data = dtrain_check, nrounds = num_round, nfold=10, showsd= TRUE,
                      objective="binary:logistic", 
                      metrics=list("auc", "error"),
                      verbose=1,
                      nthread=4,
                      max_depth = opt_max_depth_val,
                      eta = opt_eta_val,
                      subsample = opt_subsample_val,
                      colsample_bytree = opt_colsample_val,
                      early.stop.round=20,
                      maximize = FALSE   
  );
  
  testvalidationscores <- as.data.frame(testmodel$evaluation_log);
  err <- tail(testvalidationscores$test_error_mean, 1);
  auc <- tail(testvalidationscores$test_auc_mean, 1);
  #pred_train <- predict(testmodel, dtrain);
  #prediction <- as.numeric(pred_train > 0.5);
  #acc <- mean(prediction == y_valid);
  accmatrix[i] <- 1-err;
  aucmatrix[i] <- auc;
}

write.csv(accmatrix, "../output/xgbmodel_variable_incremental_accuracy.csv");
write.csv(aucmatrix, "../output/xgbmodel_variable_incremental_auc.csv");


####################################################################################################################################


print("Completed xgb_model.R");

