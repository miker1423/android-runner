library(tidyverse)
library(ggpubr)
library(rstatix)
library(ggpubr)
library(car)
library(dplyr)
library(psych)
library(pastecs)

########
#DATASET
########

#Verify if size is balanced
dataset %>% 
  count(size)

#Factors size into heavy and light websites
dataset$size<-factor(dataset$size, levels=c("light","heavy"))

#Descriptive statistics of the dataset
describe(dataset)

#Show the head of the list with all combinations
head(dataset,8)

#Means of power and fcp for light and heavy websites
dataset %>%
  group_by(size) %>%
  summarise_at(vars(pow_10n),list(pow_10n_mean = mean))
dataset %>%
  group_by(size) %>%
  summarise_at(vars(fcp_10n),list(fcp_10n_mean = mean)) 

################
#NORMALITY CHECK
################

#shapiro
#power
shapiro.test(dataset$pow_10n)
#fcp
shapiro.test(dataset$fcp_10n)

#Visual tests are in the 'visualization.r' script

#Provides the log, squareroot and reciprocate of the variables in dataset
#and updates the dataset with new collumns
dataset = dataset %>%
  mutate(log_fcp_10n = log(fcp_10n),
         log_pow_10n = log(pow_10n),
         sq_fcp_10n = sqrt(fcp_10n),
         sq_pow_10n = sqrt(pow_10n),
         re_fcp_10n = 1/fcp_10n,
         re_pow_10n = 1/pow_10n)

plot_cols= c('fcp_10n', 'log_fcp_10n', 'sq_fcp_10n', 're_fcp_10n', 'pow_10n', 'log_pow_10n', 'sq_pow_10n', 're_pow_10n')
par(mfrow=c(2,2))
mapply(hist, dataset[plot_cols], main=paste('Distribution of', plot_cols), xlab= plot_cols)

#Verify normality again with the shapiro test
#power
shapiro.test(dataset$log_pow_10n)
shapiro.test(dataset$sq_pow_10n)
shapiro.test(dataset$re_fcp_10n)
#fcp
shapiro.test(dataset$log_fcp_10n)
shapiro.test(dataset$sq_fcp_10n)
shapiro.test(dataset$re_pow_10n)


#VERY IMPORTANT
#IF ONE OF LOG SQRT OR RECPIP WORK RUN THE LINE BELOW:
#THIS WILL CREATE A CSV WITH THE NEW VARS FOR THE dataset RQ2 and RQ3
#YOU NEED TO CHANGE THE DIRECTORY


