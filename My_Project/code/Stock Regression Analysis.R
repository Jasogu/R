#상관분석행렬, 회귀분석
#코스피 = S&P500+상하이종합+유로50+니케이225+금+미국채10년물+한국시장금리+달러인덱스+원화/달러
#한국 시장금리 : 한국은행 경제통계시스템 - 금리 - 시장금리(일별) - 통안증권(91일)
#^IXIC=나스닥, ^KS11=코스피, ^GSOC=S&P500, 000001.SS=상해종합지수, ^N225=니케이225, GC=F :금, ^STOXX50E=유로50지수
#BTC-USD:비트코인, DX-Y.NYB:달러인덱스, KRW=X :원화인덱스, JPY=X :엔화인덱스
#국내 주가 코드, 코스피:KS, 코스닥:KQ
#https://finance.yahoo.com/world-indices/ 야후 파이낸스 인덱스 티커목록

#독립변수 후보들 : GDP성장률, 실업률, 인플레이션율, 이자율, 국채 수익률, 신용 스프레드, 금가격, 원유가격, 원자재 지수, VIX지수, 시장거래량, 미국 달러인덱스, 환율

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

