library(tidyverse)
library(ggpubr)
library(rstatix)
library(coin)
library(effsize)

########
#Subsets
########

#subset the data in no resource and resource hints
n_rhint= subset(dataset, r_hint=="none")
n_rhint

y_rhint = subset(dataset, r_hint=="css-prefetch" | r_hint=="css-preload" |
                   r_hint=="img-prefetch" | r_hint=="img-preload" |
                   r_hint=="scr-prefetch" | r_hint=="scr-preload" |
                   r_hint=="url-preconnect")
y_rhint

#subset the data in heavy and light websites
h_size= subset(dataset, size=="heavy")
l_size= subset(dataset, size=="light")

#verify if correct
n_rhint$pow_10n
n_rhint$fcp_10n
y_rhint$pow_10n
y_rhint$fcp_10n
h_size$fcp_10n
h_size$pow_10n
l_size$fcp_10n
l_size$pow_10n


#######################
#Descriptive Statistics
#######################

#average of power over each combination
dataset %>%
  group_by(r_hint) %>%
  get_summary_stats(pow_10n, type = "mean_sd")

#average of fcp over each combination
dataset %>%
  group_by(r_hint) %>%
  get_summary_stats(fcp_10n, type = "mean_sd")

#average of power over each combination (with size)
dataset %>% 
  group_by(r_hint, size) %>%
  get_summary_stats(pow_10n, type = "mean_sd")

#average of fcp over each combination (with size)
dataset %>% 
  group_by(r_hint, size) %>%
  get_summary_stats(fcp_10n, type = "mean_sd")

########################
#TESTS FOR NON-NORMALITY
########################

#kruskall of power over each combination
hints.kruskal_pow =  kruskal.test(pow_10n ~ r_hint, data= dataset)
hints.kruskal_pow

#effect size kruskall of power over each combination
dataset %>% kruskal_effsize(pow_10n ~ r_hint)

#kruskall of fcp over each combination
hints.kruskal_fcp = kruskal.test(fcp_10n ~ r_hint, data= dataset)
hints.kruskal_fcp

#effect size kruskall of fcp over each combination
dataset %>% kruskal_effsize(fcp_10n ~ r_hint)

#wilcox for power over resource hints
wilcox_pow <- dataset  %>%
  wilcox_test(pow_10n ~ r_hint, paired = TRUE) %>%
  add_significance()
wilcox_pow

#wilcox effect size for power over resource hints
dataset  %>%
  wilcox_effsize(pow_10n ~ r_hint, paired = TRUE)

#wilcox for fcp over resource hints
wilcox_fcp <- dataset  %>%
  wilcox_test(fcp_10n ~ r_hint, paired = TRUE) %>%
  add_significance()
wilcox_fcp

#wilcox effect size for fcp over resource hints
dataset  %>%
  wilcox_effsize(fcp_10n ~ r_hint, paired = TRUE)

#spearman correlation coeficient between power and fcp (heavy websites)
spear_h <- cor.test(x=h_size$pow_10n, y=h_size$fcp_10n, method = 'spearman', exact=FALSE)
spear_h
#spearman correlation coeficient between power and fcp (light websites)
spear_l <- cor.test(x=l_size$pow_10n, y=l_size$fcp_10n, method = 'spearman',exact=FALSE)
spear_l

#cliff's delta for power (none vs resource hints)
cliff.delta(n_rhint$pow_10n,y_rhint$pow_10n)

#cliff's delta for fcp (none vs resource hints)
cliff.delta(n_rhint$fcp_10n,y_rhint$fcp_10n)


