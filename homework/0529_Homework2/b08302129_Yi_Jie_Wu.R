# Clear R environment
rm(list=ls(all=TRUE))

# get the path for Working directory
getwd()

# Set the working directory
setwd("C:/Users/jwutw/OneDrive/桌面/大四下資料/勞動經濟學/Git/LaborTopicTermPaper/workData")


# Library packages
library(haven)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(hdm)

### 1. Research Question and Read Data ###
# Read Data (dta, STATA)
SH_divorce <- read_dta("SH_divorce_outcome2009_outcome2015.dta")


### 2. Examine Data ###
summary.data.frame(SH_divorce)

### 3. Create Sample ###
SH_divorce <- mutate(SH_divorce, priv_cap = hs_private * hs_capital)
divorce_sum <- summarize(group_by(SH_divorce, divorce, hs_capital), average_year = mean(work_year_2009,na.rm = TRUE), average_wage = mean(wage_level_2009,na.rm = TRUE))
SH_divorce_1 <- full_join(SH_divorce ,divorce_sum , by = c("hs_capital", "divorce"))

### 4. visualize data ###
setwd("C:/Users/jwutw/OneDrive/桌面/大四下資料/勞動經濟學/Git/LaborTopicTermPaper/0529_Homework2/Tex")

univ_graph <- ggplot(data = SH_divorce_1, aes(x = divorce, y = university)) + geom_bar(stat = "summary", fun = "mean", width = 0.3)
univ_graph
ggsave("univ_graph.png", width=3.25,height =3.25)


workyear_graph <- ggplot(data = SH_divorce_1, aes(x = divorce, y = average_year)) + geom_bar(stat = "summary", fun = "mean", width = 0.3)
workyear_graph
ggsave("workyear_graph.png", width=3.25,height =3.25)

wagelevel_graph <- ggplot(data = SH_divorce_1, aes(x = divorce, y = average_wage)) + geom_bar(stat = "summary", fun = "mean", width = 0.3)
wagelevel_graph
ggsave("wagelevel_graph.png", width=3.25,height =3.25)

### 5. Empirical analysis ###
pdslasso <- read_dta("C:/Users/jwutw/OneDrive/桌面/大四下資料/勞動經濟學/Git/LaborTopicTermPaper/0529_Homework2/SH_pds.dta")

y1 = pdslasso[, 14]
y2 = pdslasso[, 15, drop = F]
y3 = pdslasso[, 17, drop = F]
y4 = pdslasso[, 19, drop = F]

d = pdslasso[, 5]
X = data.matrix(pdslasso[, -c(1, 5,6,14:20)])
varnames = colnames(pdslasso)

university_pds <- rlassoEffect(X, y1, d, method = "double selection")
summary(university_pds)


public_pds <- rlassoEffect(X, y2, d, method = "double selection")
summary(public_pds)

wage2009_pds <- rlassoEffect(X, y3, d, method = "double selection")
summary(wage2009_pds)

work2009_pds <- rlassoEffect(X, y4, d, method = "double selection")
summary(work2009_pds)

