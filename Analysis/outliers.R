library(pastecs) 
library(psych)
library(dplyr)
library(ggpubr)
library(car)
library(tidyverse)
library(ggpubr)
library(rstatix)

#Make sure data is numeric
as.numeric(out_h$V4)
as.numeric(out_l$V6)
as.numeric(out_h$V6)
as.numeric(out_l$V4)

#The removal of the outliers is done using the Interquartie Method

#Q1, Q2 and interquaertile of the variables for light websites
q1.FCP_l = quantile(out_l$V6, .25)
q1.pow_10n_l = quantile(out_l$V4, .25)
q3.FCP_l = quantile(out_l$V6, .75)
q3.pow_10n_l = quantile(out_l$V4, .75)
iqr.FCP_l = IQR(out_l$V6)
iqr.pow_10n_l = IQR(out_l$V4)

#Q1, Q2 and interquaertile of the variables for heavy websites
q1.FCP_h = quantile(out_h$V6, .25)
q1.pow_10n_h = quantile(out_h$V4, .25)
q3.FCP_h = quantile(out_h$V6, .75)
q3.pow_10n_h = quantile(out_h$V4, .75)
iqr.FCP_h = IQR(out_h$V6)
iqr.pow_10n_h = IQR(out_h$V4)

#removes values that are not within 1.5*IQR of Q1 and Q3 for light websites
remove_outliers_fcp_l = subset(out_l, out_l$V6> (q1.FCP_l - 1.5*iqr.FCP_l) & out_l$V6< (q1.FCP_l + 1.5*iqr.FCP_l))
remove_outliers_pow_10n_l = subset(out_l, out_l$V4> (q1.pow_10n_l - 1.5*iqr.pow_10n_l) & out_l$V4< (q3.pow_10n_l + 1.5*iqr.pow_10n_l))
#removes values that are not within 1.5*IQR of Q1 and Q3 for heavy websites
remove_outliers_fcp_h = subset(out_h, out_h$V6> (q1.FCP_h - 1.5*iqr.FCP_h) & out_h$V6< (q1.FCP_h + 1.5*iqr.FCP_h))
remove_outliers_pow_10n_h = subset(out_h, out_h$V4> (q1.pow_10n_h - 1.5*iqr.pow_10n_h) & out_h$V4< (q3.pow_10n_h + 1.5*iqr.pow_10n_h))

#Since some rows will be removed we need to save the new datasets
#This datasets will then be used to remove further websites that don't 
#have all the combinations after the outlier removal
#The final product will be a dataset without outliers, and with a
#balanced number of heavy and light websites.

#Saves all the datasets
write.csv(remove_outliers_pow_10n_l,"C:\\Users\\andre\\Desktop\\remove_outliers_pow_10n_l.csv", row.names = FALSE)
write.csv(remove_outliers_pow_10n_h,"C:\\Users\\andre\\Desktop\\remove_outliers_pow_10n_h.csv", row.names = FALSE)
write.csv(remove_outliers_fcp_l,"C:\\Users\\andre\\Desktop\\remove_outliers_fcp_l.csv", row.names = FALSE)
write.csv(remove_outliers_fcp_h,"C:\\Users\\andre\\Desktop\\remove_outliers_fcp_h.csv", row.names = FALSE)
