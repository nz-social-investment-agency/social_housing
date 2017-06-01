## ===================================================================== ##
## Script: cost estimate bootstrap.r
##
## Purpose: This script runs a bootstrap algorithm to estimate the total
##          costs per agency, subjec area and cohorts
## 
## Author: Antoine Merval - SIU
## Date: 31/07/2016
## Review: May 2017 Ben Vandenbroucke
## ===================================================================== ##

#######################0. Init. parameters####################################

# number of bootstrap samples
Nsamples <-  10000 ;

# initialise connection string
connstr <- set_conn_string(db="IDI_Sandpit")

#######################1. Extract dataset####################################

print("sql/Extracting dataset")

# Read the sql query file and create query
app_data_query <- file("../sql/source_data_query.sql", "r")
cost_data_query <- file("../sql/source_cost_table.sql", "r")

# Run Housing applications data query on the database and fetch data
applications_data <- as_tibble(read_sql_table(query_object = app_data_query, connection_string = connstr))

# Run Housing cost data query on the database and fetch data
hnz_cost <- as_tibble(read_sql_table(query_object = cost_data_query, connection_string = connstr))
# note: this data set contains the PS weights 

print("Completed extract of dataset")

# Note: modified definition of subject areas in agencies
mod_hnz <- hnz_cost 
mod_hnz$dept2 <- as.character(mod_hnz$department)
mod_hnz$subject_area <- as.character(mod_hnz$subject_area)
# CLM (claim) is in IRD table - should be in ACC
mod_hnz$dept2[mod_hnz$subject_area=="CLM"] <- "ACC"

# Tier 1 benefit costs should be read from IRD table (subject area: BEN)
#   rather than MSD (T1);
# Accomodation support is excluded from MSD costs here
mod_hnz$dept2[mod_hnz$subject_area=="BEN"] <- "MSD"
mod_hnz$subject_area[mod_hnz$subject_area=="BEN"] <- "T1_IRD"
mod_hnz$dept2[mod_hnz$subject_area=="T1"] <- "MSD_"
mod_hnz$dept2[mod_hnz$subject_area=="T2_AS"] <- "MSD_"

# IRD TAX not in the cost balance par agency
mod_hnz$dept2[mod_hnz$subject_area=="TAX"] <- "IRD_"

# NNP, PHA and PRM costs are excluded from MOH tables: these costs have not been
#   balanced before intervention (data issue) -so should not be compared after intervention
mod_hnz$dept2[mod_hnz$subject_area=="NNP"] <- "MOH_"
mod_hnz$dept2[mod_hnz$subject_area=="PHA"] <- "MOH_"
mod_hnz$dept2[mod_hnz$subject_area=="PRM"] <- "MOH_"

# CNP and YJU have to be CYF, not MSD
mod_hnz$dept2[mod_hnz$subject_area=="CNP"] <- "CYF"
mod_hnz$dept2[mod_hnz$subject_area=="YJU"] <- "CYF"


mod_hnz$dept2 <- as.factor(mod_hnz$dept2)
mod_hnz$subject_area <- as.factor(mod_hnz$subject_area)

#######################2. extracting relevant data###########################
print("Data cleansing & shaping");

## All we need here is id and class

dataset <- dplyr::select(applications_data,c(snz_legacy_application_uid,actual_class))
Nrows <- dim(dataset)[1]
# initialising indeces for housed/not housed
allind <- seq(1,Nrows)
indhoused <- allind[(dataset$actual_class==1)]
indnot <- allind[(dataset$actual_class==0)]
Nhoused <- length(indhoused)
Nnot <- Nrows-Nhoused

#######################3. start bootstrap####################################

# Holder for samples indexes 
Samplesind <- data.frame()
bootcostperag <- data.frame()
bootcostdiff <- data.frame()


# start bootstrap loop
for (iboot in seq(1,Nsamples)) {
    
    # Generate sample - witrh replacement
    indbooth <- sample(Nhoused,replace=TRUE)
    indbootn <- sample(Nnot,replace=TRUE)
    indboot <- c(indhoused[indbooth],indnot[indbootn])
    if (iboot==1) {Samplesind <- indboot}  else {Samplesind <- cbind(Samplesind,indboot)}
    
    # get associated weights
    currentids <- as.data.frame(dataset$snz_legacy_application_uid[indboot])
    colnames(currentids)[1] <- "uid2"
    tmp <- inner_join(currentids, mod_hnz, by="uid2")  
    # note: inner join used as some ids in dataset are missing in costs
    
    # compute weight factor (to ensure that the sum of not housed is the same number as housed)
    weightsiter <- tmp %>%
        group_by(actual_class) %>%
        summarise(sumw_ = sum(inv_wt_att_scaled)) %>%
        dplyr::mutate(sumw=sumw_/21) %>%
        dplyr::mutate(iter=iboot)
    
    weightfactor <- (weightsiter$sumw[weightsiter$actual_class==1])/(weightsiter$sumw[weightsiter$actual_class==0])
    current_nbhoused <- (weightsiter$sumw[weightsiter$actual_class==1])
    
    # total costs per agency per group
    costperag <- tmp %>%
        # IPTW applied
        mutate(weightedcost=inv_wt_att_scaled*cost) %>%
        group_by(dept2, actual_class) %>%
        summarise(totcost=sum(weightedcost)) %>%
        dplyr::mutate(iter=iboot)
    
    costh <- costperag %>% dplyr::filter(actual_class==1) %>%
        dplyr::rename(costhoused=totcost) %>%
        dplyr::select(-actual_class)
    costnh <- costperag %>% dplyr::filter(actual_class==0) %>%
        dplyr::rename(costnot=totcost) %>%
        # applying weight factor
        dplyr::mutate(adjusted_costnot=costnot*weightfactor) %>%
        dplyr::select(-actual_class)    
    
    allcostperag <- full_join(dplyr::select(costh,-iter), dplyr::select(costnh,-iter), by="dept2")
    
    # compute differences in costs between groups, per agency
    diffcostperag <- allcostperag %>% 
        dplyr::mutate(diffcost=costhoused-costnot,
                      adj_diffcost=costhoused-adjusted_costnot) %>%
        dplyr::mutate(iter=iboot)
    
    # costs per subject area per group
    # apply weights to costs
    costpersa <- tmp %>%
        mutate(weightedcost=inv_wt_att_scaled*cost) %>%
        group_by(dept2, datamart, subject_area, actual_class) %>%
        summarise(totcost=sum(weightedcost)) %>%
        dplyr::mutate(iter=iboot)
    
    costh <- costpersa %>% dplyr::filter(actual_class==1) %>%
        dplyr::rename(costhoused=totcost) %>%
        dplyr::select(-actual_class)
    costnh <- costpersa %>% dplyr::filter(actual_class==0) %>%
        dplyr::rename(costnot=totcost) %>%
        dplyr::mutate(adjusted_costnot=costnot*weightfactor) %>%
        dplyr::rename(dep=dept2) %>%
        dplyr::rename(dat=datamart) %>%
        dplyr::select(-actual_class)   
    
    # compute differences in costs
    allcostpersa <- full_join(select(costh,-iter), costnh, by="subject_area")
    diffcostpersa <- allcostpersa %>% 
        dplyr::mutate(diffcost=costhoused-costnot,
                      adj_diffcost=costhoused-adjusted_costnot)    
    
    # store results of current loop
    if (iboot==1) {
        bootcostperag <- costperag
        bootcostdiff <- diffcostperag
        bootcostpersa <- costpersa
        bootcostdiffsa <- diffcostpersa
        bootsumweight <- weightsiter
    }  else {
        bootcostperag <- rbind(bootcostperag,costperag)
        bootcostdiff <- rbind(bootcostdiff, diffcostperag)
        bootcostpersa <- rbind(bootcostpersa,costpersa)
        bootcostdiffsa <- rbind(bootcostdiffsa, diffcostpersa)   
        bootsumweight <- rbind(bootsumweight,weightsiter)
    }
    
} # end of bootstrap loop    
    
# compute mean and stand. dev. for costs
# per agency
hh_stats <- bootcostperag %>%
    group_by(dept2, actual_class) %>% 
    summarise(meancost=mean(totcost),sdcost=sd(totcost)) %>% 
    # compute confidence intervals
    mutate(CIlow = meancost - 1.96*sdcost, CIhigh = meancost + 1.96*sdcost)
diff_stats <- bootcostdiff %>%
    group_by(dept2) %>% 
    summarise(meandiff=mean(diffcost),sddiff=sd(diffcost),
              meanadjdiff=mean(adj_diffcost),sdadjdiff=sd(adj_diffcost)) %>% 
    # compute confidence intervals
    mutate(CIlow = meandiff - 1.96*sddiff, CIhigh = meandiff + 1.96*sddiff,
           CIlowadj = meanadjdiff - 1.96*sdadjdiff, CIhighadj = meanadjdiff + 1.96*sdadjdiff)
# per subject area
hh_stats_sa <- bootcostpersa %>%
    group_by(subject_area, actual_class) %>% 
    summarise(meancost=mean(totcost),sdcost=sd(totcost)) %>%
    mutate(CIlow = meancost - 1.96*sdcost, CIhigh = meancost + 1.96*sdcost)
diff_stats_sa <- bootcostdiffsa %>%
    group_by(subject_area) %>% 
    summarise(meandiff=mean(diffcost),sddiff=sd(diffcost),
              meanadjdiff=mean(adj_diffcost),sdadjdiff=sd(adj_diffcost)) %>%
    mutate(CIlow = meandiff - 1.96*sddiff, CIhigh = meandiff + 1.96*sddiff,
           CIlowadj = meanadjdiff - 1.96*sddiff, CIhighadj = meanadjdiff + 1.96*sddiff)

# outputing results
# csv files will show both total (weighted) costs pe agency / s.a. 
#   and differences in costs - as well as confiden intervals
write.csv(hh_stats,file="../output/costsperagdata.csv",row.names=FALSE)
write.csv(diff_stats,file="../output/weightedcostsdiffdata.csv",row.names=FALSE)
write.csv(hh_stats_sa,file="../output/costspersadata.csv",row.names=FALSE)
write.csv(diff_stats_sa,file="../output/weightedcostsdiffpersadata.csv",row.names=FALSE)

#######################4. plot and save #######################

# distribution of costs for the two groups
sub <- levels(bootcostpersa$subject_area)
for (ii in seq(1,length(sub))) {
    sa <- sub[ii]
    ggplot(filter(bootcostpersa,subject_area==sa) , aes(x=totcost, fill=as.factor(actual_class))) + 
        geom_histogram(aes(y=..count..  ), position="dodge") 
    ggsave(filename = paste("../output/plots/hist_", as.character(sa),".tiff"), device="tiff");
}

# boxplots of costs differences
ggplot(diff_stats_sa, 
       aes(subject_area, meandiff, ymin=CIlow, ymax=CIhigh, colour=subject_area)) + 
    geom_crossbar() +
    ggtitle("Cost differences per subject area") +
    xlab("Subj. Area") + 
    ylab("Mean cost difference")
ggsave(filename = paste("../output/plots/cost_per_sa.tiff"), device="tiff");

#######################5. double check CI by other method####################
quant <- c(0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975)
sa <- levels(bootcostdiffsa$subject_area)
CIs <- data.frame()
for (ii in seq(1:length(sa))) {
    tt <- bootcostdiffsa$diffcost[bootcostdiffsa$subject_area==sa[ii]]
    CIplus <- data.frame(subja=sa[ii], 
                         lowCI=quantile(tt,quant)[1], 
                         med=quantile(tt,quant)[5],
                         highCI=quantile(tt,quant)[9])
    CIs <- rbind(CIs,CIplus)
}
