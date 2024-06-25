#상관분석행렬, 회귀분석

#코스피 = S&P500+상하이종합+유로50+니케이225+금+미국채10년물+한국시장금리+달러인덱스+원화/달러
#BTC-USD:비트코인, DX-Y.NYB:달러인덱스, KRW=X :원화인덱스, JPY=X :엔화인덱스, 

library(quantmod)
library(dplyr)
library(caret)
library(randomForest)
library(lubridate)

Close_date <- function(x) {
  date <- index(x)
  x <- as.data.frame(x)
  x$date <- date
  x <- x %>% select(6, 7)
  return(x)
} #날짜, 종가 뽑아내기

#Ticker_ymd(20211030, 20240530)
Ticker_ymd <- function(b, c=today()) {
  NASDAQ <<- getSymbols('^IXIC', from=ymd(b), to=ymd(c), auto.assign = FALSE)
  GOLD <<- getSymbols('GC=F', from=ymd(b), to=ymd(c), auto.assign = FALSE)
  CHINA <<- getSymbols('000001.SS', from=ymd(b), to=ymd(c), auto.assign = FALSE)
  BITCOIN <<- getSymbols('BTC-USD', from=ymd(b), to=ymd(c), auto.assign = FALSE)
  DOLLAR <<- getSymbols('DX-Y.NYB', from=ymd(b), to=ymd(c), auto.assign = FALSE)
  APPLE <<- getSymbols('AAPL', from=ymd(b), to=ymd(c), auto.assign = FALSE)
}
Ticker_ymd(20211030, 20240530)

#가격 추출
#APPLE <- getSymbols("AAPL", from='2021-10-30', '2024-05-30' ,src = "yahoo", auto.assign = FALSE)
#NASDAQ <- getSymbols("^IXIC", from='2021-10-30', '2024-05-30' ,src = "yahoo", auto.assign = FALSE)
#GOLD <- getSymbols('GC=F', from='2021-10-30', '2024-05-30', auto.assign = FALSE)
#CHINA <- getSymbols('000001.SS', from='2021-10-30', '2024-05-30', auto.assign = FALSE)
#Bitcoin <- getSymbols("BTC-USD", from='2021-10-30', '2024-05-30' , auto.assign = FALSE)
#DOLLAR <- getSymbols("DX-Y.NYB", from='2021-10-30', '2024-05-30' , auto.assign = FALSE)
DGS10 <- getSymbols('DGS10', from='2021-10-30', to='2024-05-30', src='FRED',auto.assign=FALSE) #src='FRED '필수

#종합지수 전처리
APPLE <- Close_date(APPLE)
NASDAQ <- Close_date(NASDAQ)
GOLD <- Close_date(GOLD)
CHINA <- Close_date(CHINA)

#10년물 전처리
date <- index(DGS10)
DGS10 <- as.data.frame(DGS10)
DGS10$date <- date

#데이터 병합
data <- merge(APPLE, NASDAQ)
data <- merge(data, GOLD, by='date')
data <- merge(data, CHINA, by='date')
data <- merge(data, DGS10, by='date')
colnames(data) <- c('date', 'APPLE', 'NASDAQ', 'GOLD', 'CHINA', 'BOND10')

#결측값처리
data <- na.omit(data)

#MinMax Scaling
model_minmax <- preProcess(data[,-1], method = 'range')
pred_minmax <- predict(model_minmax, data)
data_minmax <- as.data.frame(pred_minmax)

#Standardization
model_sd <- preProcess(data[,-1], method = 'scale')
pred_sd <- predict(model_sd, data)
data_sd <- as.data.frame(pred_sd)

#상관행렬
cor(data[,-1])

#회귀분석
result_sd <- lm(APPLE ~ NASDAQ + GOLD + CHINA + BOND10, data=data_sd) #표준화
result_minmax <- lm(APPLE ~ NASDAQ + GOLD + CHINA + BOND10, data=data_minmax)

result <- lm(APPLE ~ NASDAQ + GOLD + BOND10 + CHINA+ I(NASDAQ*NASDAQ), data=data)

result %>% names
plot(result$residuals)
summary(result)

