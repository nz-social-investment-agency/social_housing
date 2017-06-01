## ===================================================================== ##
## Script: main_part1.r
##
## Purpose: Check Correlations, collinearity and experiment with feature 
##          selections on the data and make visualizations.
## 
## Author: Vinay Benny - SIU
## Date: 31/07/2016
## Review: May 2017 Ben Vandenbroucke
## ===================================================================== ##


print("Running check_correlations.R");

# Set global variables
correlation_cutoff_absvalue = 0.7;

####################################1. Check correlations ###############################################################

get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)] <- NA
  return( cormat);
}

X_num <- X[ ,sapply(X, is.numeric)];

# Check correlations and plot correlation matrix
correlationMatrix <- cor(X_num);
upper_tri <- get_upper_tri(correlationMatrix);
melted_cormat <- melt(correlationMatrix);

ggplot(data = melted_cormat, aes(Var2, Var1, fill = value)) + geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1,1), 
                       space = "Lab", name="Pearson\nCorrelation") + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1)) +
  coord_fixed();
ggsave(filename = paste("../output/plots/correlationmatrix.tiff"), device=tiff);

# Find candidate attributes to remove
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=correlation_cutoff_absvalue);
print(names(X_num)[highlyCorrelated]);

# COMMENT OUT AS REQUIRED !! Drop the variables not required from the dataset on the basis of correlation.
dropcols <- names(X_num)[highlyCorrelated];
dropcols <- dropcols[!dropcols %in% c("hhld_size")]; # Preserve hhld_size variable
X_train <- X_train[ ,!names(X_train) %in% dropcols];

# correlation matrix plot
par(mfrow=c(1,1))
corrplot(correlationMatrix, method="color", type="lower",tl.cex=0.5)

write.csv(correlationMatrix, "../output/correlationmatrix.csv");


print("Completed check_correlations.R");
