pkg = c('magrittr', 'quantmod', 'rvest', 'httr', 'jsonlite',
        'readr', 'readxl', 'stringr', 'lubridate', 'dplyr',
        'tidyr', 'ggplot2', 'corrplot', 'dygraphs',
        'highcharter', 'plotly', 'PerformanceAnalytics',
        'nloptr', 'quadprog', 'RiskPortfolios', 'cccp',
        'timetk', 'broom', 'stargazer', 'timeSeries')

new.pkg = pkg[!(pkg %in% installed.packages()[, "Package"])]
if (length(new.pkg)) {
  install.packages(new.pkg, dependencies = TRUE)}

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

