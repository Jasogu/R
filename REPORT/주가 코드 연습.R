# quantmod 패키지 설치 및 로드
if (!requireNamespace("quantmod", quietly = TRUE)) {
   install.packages("quantmod")
}
library(quantmod)
library(tidyverse)
library(lubridate)
theme_set(theme_grey(base_family='NanumGothic')) #나눔고딕 폰트 사용(ggplot2 한글 깨짐)

getSymbols("AAPL", from = "2020-01-01", to = Sys.Date())
AAPL %>% head

getSymbols(c("000660.KS", "005930.KS"), 
           src = "yahoo", 
           from = "2023-01-01", 
           to = Sys.Date())

# 종가 차트와 이동평균선(20일 및 50일) 시각화
chartSeries(AAPL, name="Apple Inc. Stock Price", TA="addSMA(n=20); addSMA(n=50)")

# 삼성전자 주식 데이터 불러오기
getSymbols("005930.KS", from = "2020-01-01", to = Sys.Date())
`005930.KS` %>% head

# 종가 차트와 이동평균선 시각화
chartSeries(`005930.KS`, name = "Samsung Electronics Stock Price", TA = "addSMA(n=20); addSMA(n=50)")

# 주봉 데이터로 변환 후 차트 그리기
samsung_weekly <- to.weekly(`005930.KS`)
chartSeries(samsung_weekly, 
            name = "삼성전자 주봉 차트", 
            TA = "addSMA(n=5); addSMA(n=10)")

# 월봉 데이터로 변환 후 차트 그리기
samsung_monthly <- to.monthly(`005930.KS`)
chartSeries(samsung_monthly, 
            name = "삼성전자 월봉 차트", 
            TA = "addSMA(n=5); addSMA(n=10)")










