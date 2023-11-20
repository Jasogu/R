#주가 지수는 파이썬으로 엑셀 불러올 것

library(ggplot2)
library(readxl)
library(lubridate)
library(writexl)

if (!require('tqk')) {
  remotes::install_github("mrchypark/tqk")
  library(tqk)
}

hyundai <- tqk_get("005380", from='2018-01-01', to='2023-11-19')

ggplot(a) +
  aes(x = date, y = close) +
  geom_line(colour = "#112446") +
  theme_minimal()

hyundai

a <- hyundai[order(hyundai$date),]

order(hyundai$open)


#################
#write_xlsx(my, path = "my.xlsx")
#new_data <- data.frame(date = as.Date("2023-11-20"), change = -0.001)
#my <- rbind(my, new_data)   
my <- read_excel("my.xlsx")
my$date <- as.Date(my$date)
my

tqk_get()


