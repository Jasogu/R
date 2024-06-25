pkg = c('magrittr', 'quantmod', 'rvest', 'httr', 'jsonlite',
        'readr', 'readxl', 'stringr', 'lubridate', 'dplyr',
        'tidyr', 'ggplot2', 'corrplot', 'dygraphs',
        'highcharter', 'plotly', 'PerformanceAnalytics',
        'nloptr', 'quadprog', 'RiskPortfolios', 'cccp',
        'timetk', 'broom', 'stargazer', 'timeSeries')

new.pkg = pkg[!(pkg %in% installed.packages()[, "Package"])]
if (length(new.pkg)) {
  install.packages(new.pkg, dependencies = TRUE)}



#^IXIC=나스닥, ^KS11=코스피, ^GSOC=S&P500, 000001.SS=상해종합지수, ^N225=니케이225, GC=F :금, ^STOXX50E=유로50지수

#https://hyunyulhenry.github.io/quant_cookbook/api%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EC%88%98%EC%A7%91.html

library(quantmod) #주가 https://hyunyulhenry.github.io/quant_cookbook/api%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EC%88%98%EC%A7%91.html
library(dplyr)
library(ggplot2)

getSymbols(c('AAPL', 'NVDA'))

data = getSymbols('AAPL',
                  from = '2000-01-01', to = '2018-12-31',
                  auto.assign = FALSE) #auto.assign : 티커명이 아닌 원하는 변수명에 데이터를 저장할 수 있음(FALSE로 할 시)
chart_Series(Ad(AAPL))
AAPL <- as.data.frame(AAPL) #dataframe으로 변환

getSymbols('DGS10', src='FRED') #미국채 10년물 금리
chart_Series(DGS10)

AAPL %>% quantmod::chartSeries(
  subset="2024-01-01::2024-06-22",
  theme = quantmod::chartTheme("white", up.col = "red", dn.col = "blue")) #차트 시각화

samsung <- getSymbols('005930.KS', from = '2000-01-01', to = '2024-06-25', auto.assign = FALSE) #국내 주가 코드, 코스피:KS, 코스닥:KQ
colnames(samsung) <- c('open', 'high', 'low', 'close', 'volume', 'adjusted')
samsung

getSymbols("^IXIC", src = "yahoo") %>% as.data.frame 

GOLD <- getSymbols('GC=F', auto.assign = FALSE) %>% as.data.frame
arrange(desc(GOLD))

GOLD %>% tail

