## ===================================================================== ##
## Script: balanceMetrics.r
##
## Purpose: This function computes balance metrics
## 
## Author: C MacCormick - SIU
## Date: 04/11/2016
## 
## ===================================================================== ##

balanceMetrics <- function(inSet = scored_set, weightVar = scored_set$inv_wt_att, outPath = "./pre_and_post_balance_metrics.csv",
                           Xvars = xvars, target = "actual_class", outputDF = df1){
    
    ###Pre IPTW standardised mean differences and hypothesis tests
    tabUnweighted <- CreateTableOne(vars = Xvars, strata = target, test = FALSE, data = inSet)
    
    tabUnweighted2 <- print(tabUnweighted, smd = TRUE, test = FALSE)#[,-c(3:4)] #remove column 4 which is blank
    print("2")
    colnames(tabUnweighted2) <- c("NSH (pre)", "SH (pre)", "Std Mean Diff (pre)")
    
    # colnames(tabUnweighted2) <- c("NSH (pre)", "SH (pre)", "p-value (pre)", "Std Mean Diff (pre)")
    
    ###Post IPTW standardised mean differences - svydesign() used to weight up using inv_wt_norm_att
    tabWeighted <- svydesign(ids = ~ 0, weights = ~weightVar, data = inSet)
    
    ###This line takes a little while to run
    tabWeighted2 <- svyCreateTableOne(vars = Xvars, strata = target, test = FALSE, data = tabWeighted)
    
    tabWeighted3 <- print(tabWeighted2, smd = TRUE, test = FALSE)#[,-c(3:4)] #remove column 4 which is blank
    
    colnames(tabWeighted3) <- c("NSH (post)", "SH (post)", "Std Mean Diff (post)")
    
    # colnames(tabWeighted3) <- c("NSH (post)", "SH (post)", "p-value (post)", "Std Mean Diff (post)")
    
    ###Write joint results to CSV
    write.csv(cbind(tabUnweighted2, "", tabWeighted3), outPath)
    
    outputDF <- cbind(tabUnweighted2, "", tabWeighted3)
    return(outputDF)
    
}
