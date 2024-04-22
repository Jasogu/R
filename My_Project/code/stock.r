install.packages("remotes")
library(remotes)
install_github("mrchypark/tqk")
library(tqk)

data <- code_get()
View(data)

KOSPI <- subset(data, data$market == "KOSPI")
KOSDAQ <- subset(data, data$market == "KOSDAQ")
head(KOSPI)
head(KOSDAQ)
