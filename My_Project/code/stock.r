#https://github.com/mrchypark/tqk
install.packages("remotes")
library(remotes)
install_github("mrchypark/tqk")
library(tqk)
library(dplyr)
install.packages("readxl")
library(readxl)

data <- code_get() #
View(data)

KOSPI <- subset(data, data$market == "KOSPI")
KOSDAQ <- subset(data, data$market == "KOSDAQ")
head(KOSPI)
head(KOSDAQ)

subset(data, data$name == "삼성전자")$code