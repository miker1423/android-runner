##########################################################################################
#############################   Green Lab-assignment3  ###################################
##########################################################################################

install.packages("dplyr")
install.packages("pastecs")
install.packages("psych")
install.packages("ggpubr")
install.packages("car")
install.packages("rlang")
install.packages("tidyverse")
install.packages("ggpubr") 
install.packages("ggplot2")
install.packages("PerformanceAnalytics")
library(pastecs) #this goes way more in depth 'stat.desc(data)'
library(psych) #to read easily
library(dplyr)# to group things
################################used for plotting#####################################
library(ggpubr)
library(car)
library(testthat)
library(tidyverse)
library(ggpubr)
library(ggplot2)
library(forcats) 
library(rstatix)
library(GGally)
library(PerformanceAnalytics)


#################################import the dataset#################################

dataset <- read.csv(file.choose())
View(dataset)

################################# histogram Density combo ##########################


#power
ss1 <- ggplot(data = dataset, aes(x = pow_10n))
ss1 + geom_histogram(aes(y = stat(density)), 
                   colour="black", fill="aquamarine3") +
  labs(x="Power usage", y = "Density") +
  geom_density(alpha = 0.2, fill = "palegreen4")+
  theme(text = element_text(size = 9)) 


#fcp
ss2 <- ggplot(data = dataset, aes(x = fcp_10n))
ss2 + geom_histogram(aes(y = stat(density)), 
                   colour="black", fill="lightsteelblue3") +
  labs(x="performance", y = "Density") +
  geom_density(alpha = 0.2, fill = "lightsteelblue")+
  theme(text = element_text(size = 9))


#################################Grouped comparative boxplot########################

#Grouped boxplot power
ggplot(dataset, aes(x=r_hint, y=pow_10n, fill=size)) + 
  geom_boxplot()+
  labs(x = "Resource hint", y = "Power Consumption")+
  theme(text = element_text(size = 9)) +
  theme(axis.text.x=element_text(angle = -90, hjust = 0))


#Grouped boxplot fcp
ggplot(dataset, aes(x=r_hint, y=fcp_10n, fill=size)) + 
  geom_boxplot()+
  labs(x = "Resource hints", y = "Performance")+
  theme(text = element_text(size = 9)) +
  theme(axis.text.x=element_text(angle = -90, hjust = 0))


################################## quantile plot #####################################

 
#Power
ggqqplot(dataset, x = "pow_10n",
         color = "blue")+
  theme(text = element_text(size = 9)) 
 
#fcp
ggqqplot(dataset, x = "fcp_10n",
         color = "blue")+
  theme(text = element_text(size = 9)) 


####################################  scatter plot ######################################
sc <- ggplot(data = dataset, aes(x = pow_10n, y = fcp_10n)) +geom_point() + geom_abline()
sc  + geom_smooth(method = "lm", se = FALSE) + facet_wrap(~r_hint)



p <- ggplot(data = dataset, aes(x = pow_10n, y = fcp_10n,color = size)) + geom_point() + geom_abline() + facet_wrap(~r_hint)
p



############################# Grouped boxplot power categorized by resource ##############


#img

dataset <- filter(dataset, r_type == 'img' |r_type =='none')

gg1 <- ggplot(dataset, aes(x=r_hint, y=pow_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="img", x = "Resource hint", y = "Power Consumption") +
  theme(text = element_text(size = 20))


#css

dataset <- filter(dataset, r_type == 'css' |r_type =='none')



gg2 <- ggplot(dataset, aes(x=r_hint, y=pow_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="css",x = "Resource hint", y = "Power Consumption")+
  theme(text = element_text(size = 20))

#scr

dataset <- filter(dataset, r_type == 'scr' |r_type =='none')

gg3 <- ggplot(dataset, aes(x=r_hint, y=pow_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="scr",x = "Resource hint", y = "Power Consumption")+
  theme(text = element_text(size = 20))

#url

dataset <- filter(dataset, r_type == 'url' |r_type =='none')

gg4 <- ggplot(dataset, aes(x=r_hint, y=pow_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="url",x = "Resource hint", y = "Power Consumption")+
  theme(text = element_text(size = 20))

#group four plot in one page  
p1 <- ggarrange(gg1, gg2, gg3 ,gg4 + font("x.text", size = 9),
                  ncol = 2, nrow = 2)
p1

########################## Grouped boxplot fcp categorized by resource #################


#img

dataset <- filter(dataset, r_type == 'img' |r_type =='none')

gg1 <- ggplot(dataset, aes(x=r_hint, y=fcp_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="img", x = "Resource hint", y = "FCP") +
  theme(text = element_text(size = 20))

gg1
#css

dataset <- filter(dataset, r_type == 'css' |r_type =='none')


gg2 <- ggplot(dataset, aes(x=r_hint, y=fcp_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="css",x = "Resource hint", y = "FCP")+
  theme(text = element_text(size = 20))
gg2
#scr

dataset <- filter(dataset, r_type == 'scr' |r_type =='none')

gg3 <- ggplot(dataset_sep3, aes(x=r_hint, y=fcp_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="scr",x = "Resource hint", y = "FCP")+
  theme(text = element_text(size = 20))

#url

dataset <- filter(dataset, r_type == 'url' |r_type =='none')

gg4 <- ggplot(dataset, aes(x=r_hint, y=fcp_10n, fill=size)) + 
  geom_boxplot(outlier.size=3)+ scale_fill_brewer(palette="Dark2") + theme(legend.position="none")+
  labs(title ="url",x = "Resource hint", y = "FCP")+
  theme(text = element_text(size = 20))

#group four plot in one page
p1 <- ggarrange(gg1, gg2, gg3 ,gg4 + font("x.text", size = 9),
                ncol = 2, nrow = 2)
p1

########################### Correlation plot split by group ##############################


cor1 <- ggscatter(heavyWebapps, x = "fcp_10n", y = "pow_10n", size = 1,title = "Heavy Webapps",
          color = "r_hint", palette = "jco",
          facet.by = "r_hint", #scales = "free_x",
          add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color = r_hint), method = "spearman", label.y = 4)

cor2 <- ggscatter(lightWebapps, x = "fcp_10n", y = "pow_10n", size = 1,title = "Light Webapps",
          color = "r_hint", palette = "jco",
          facet.by = "r_hint", #scales = "free_x",
          add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color = r_hint), method = "spearman", label.y = 5)+
  theme(legend.position = "none") 


#group two plots in one page
cor3 <- ggarrange(cor1, cor2 + font("x.text", size = 5),
                ncol = 1, nrow = 2)
cor3

##############Combined histogram and density plots for FCP and energy consumption###########

#power
pp1 <- ggplot(dataset, aes(x = pow_10n)) + 
  geom_histogram(aes(y = ..density..),
                 colour = 1, fill="aquamarine3") +
  geom_density()
pp2 <- pp1+facet_wrap(~r_hint,ncol = 4)


#fcp
pp3 <- ggplot(dataset, aes(x = fcp_10n)) + 
  geom_histogram(aes(y = ..density..),
                 colour = 1, fill="lightsteelblue3") +
  geom_density()
pp4 <- pp3+facet_wrap(~r_hint,ncol = 4)

#group two plots in one page
pp5 <- ggarrange(pp2, pp4 + font("x.text", size = 12),
                 ncol = 1, nrow = 2)
pp5

############################################################################################