Quantmod library 코드
================
김홍식

<br> <span style="background-color: #ffdce0"> 주의 : 불러온 주가
데이터의 변수명이 숫자로 시작하므로 사용할 때 \` (물결표 버튼)으로
감싸서 사용해야 한다. </span>

<br>

## 패키지 설치 및 로드

먼저 필요한 패키지를 설치(설치되어 있지 않은 경우) 및 로드하고, ggplot2
한글 깨짐 문제를 해결하기 위해 나눔고딕 폰트를 설정.

``` r
if (!requireNamespace("quantmod", quietly = TRUE)) {
   install.packages("quantmod")
}
library(quantmod)
library(tidyverse)
library(lubridate)
library(ggthemes)
theme_set(theme_grey(base_family='NanumGothic'))

#열 이름 변경
myfunc <- function(x) {
   colnames(x) <- c('open', 'high', 'low', 'close', 'volume', 'adjusted')
   invisible(x)
}
```

<br>

## Apple 주식 데이터 로드 및 확인

2020년 1월 1일부터 오늘까지의 Apple Inc. 주식 데이터 로드

``` r
getSymbols("AAPL", from = "2020-01-01", to = Sys.Date()-1)
```

    ## [1] "AAPL"

``` r
AAPL <- myfunc(AAPL)
head(AAPL)
```

    ##               open    high     low   close    volume adjusted
    ## 2020-01-02 74.0600 75.1500 73.7975 75.0875 135480400 72.71607
    ## 2020-01-03 74.2875 75.1450 74.1250 74.3575 146322800 72.00912
    ## 2020-01-06 73.4475 74.9900 73.1875 74.9500 118387200 72.58290
    ## 2020-01-07 74.9600 75.2250 74.3700 74.5975 108872000 72.24153
    ## 2020-01-08 74.2900 76.1100 74.2900 75.7975 132079200 73.40365
    ## 2020-01-09 76.8100 77.6075 76.5500 77.4075 170108400 74.96281

<br>

## 아래와 같이 두 개 이상 동시에 로드 가능

야후 파이낸스 데이터를 이용해 2023년 1월 1일부터 오늘까지
삼성전자(005930.KS)와 다른 종목(000660.KS) 데이터 로드

``` r
getSymbols(c("000660.KS", "005930.KS"), 
           src = "yahoo", 
           from = "2023-01-01", 
           to = Sys.Date())
```

    ## [1] "000660.KS" "005930.KS"

``` r
`000660.KS` <- myfunc(`000660.KS`)
`005930.KS` <- myfunc(`005930.KS`)
```

<br>

## Apple 주식 차트: 종가와 이동평균선(20일, 50일)

Apple의 주가 차트에 20일과 50일 이동평균선을 추가

``` r
chartSeries(AAPL['2024-07-01::2025-01-01'], name="Apple Inc. Stock Price",
            TA="addSMA(n=20); addSMA(n=50)")
```

![](data/images/주가%20데이터%20추출%20및%20차트그리기(R%20markdown)/apple-chart-1.png)<!-- -->

<br>

## 삼성전자 주식 데이터 로드 및 확인

2020년 1월 1일부터 오늘까지 삼성전자 데이터(005930.KS)를 가져옴

``` r
getSymbols("005930.KS", from = "2020-01-01", to = Sys.Date())
```

    ## [1] "005930.KS"

``` r
`005930.KS` <- myfunc(`005930.KS`)
head(`005930.KS`)
```

    ##             open  high   low close   volume adjusted
    ## 2020-01-02 55500 56000 55000 55200 12993228 48494.80
    ## 2020-01-03 56000 56600 54900 55500 15422255 48758.36
    ## 2020-01-06 54900 55600 54600 55500 10278951 48758.36
    ## 2020-01-07 55700 56400 55600 55800 10009778 49021.93
    ## 2020-01-08 56200 57400 55900 56800 23501171 49900.45
    ## 2020-01-09 58400 58600 57400 58600 24102579 51481.80

<br>

## 삼성전자 주식 차트: 종가와 이동평균선(20일, 50일)

삼성전자의 주가 차트에 MACD, 볼린저밴드, 이평선 5 20일선 추가

``` r
chartSeries(`005930.KS`['2024-07-01::2025-01-01'], name = "Samsung Electronics Stock Price")
addBBands()
addSMA(5);addSMA(20, col='Yellow');addMACD()
```

![](data/images/주가%20데이터%20추출%20및%20차트그리기(R%20markdown)/samsung-chart-daily-1.png)<!-- -->

<br>

## 주봉 및 월봉 데이터 변환과 차트(white theme)

삼성전자 데이터를 주봉, 월봉 데이터로 변환한 후 각각 이동평균선(5일,
10일)을 추가하여 차트를 그림

``` r
samsung_weekly <- to.weekly(`005930.KS`)
samsung_weekly <- myfunc(samsung_weekly)
chartSeries(samsung_weekly['2024-01-01::2025-01-01'], 
            name = "삼성전자 주봉 차트", 
            theme = chartTheme("white"),
            up.col = "red",
            dn.col = "blue",
            TA = "addSMA(n=5); addSMA(n=10); addVo()")
```

![](data/images/주가%20데이터%20추출%20및%20차트그리기(R%20markdown)/samsung-chart-weekly-1.png)<!-- -->

``` r
samsung_monthly <- to.monthly(`005930.KS`)
samsung_monthly <- myfunc(samsung_monthly)
chartSeries(samsung_monthly['2020-01-01::2025-01-01'], 
            name = "삼성전자 월봉 차트", 
            TA = "addSMA(n=5); addSMA(n=10)",
            up.col = "red",
            dn.col = "blue",
            theme = chartTheme('white'))
addVo()
```

![](data/images/주가%20데이터%20추출%20및%20차트그리기(R%20markdown)/samsung-chart-monthly-1.png)<!-- -->

<br>

## 데이터 프레임으로 변환 및 정규화

각 종목의 데이터를 날짜 포함 데이터 프레임으로 변환한 후, 종가만
추출하고 두 데이터를 날짜 기준으로 합침(교집합). 이후 첫날의 종가를
기준으로 정규화하여 비교

``` r
# 데이터 가져오기
getSymbols("AAPL", from = "2020-01-01", to = Sys.Date()-1)
```

    ## [1] "AAPL"

``` r
AAPL <- myfunc(AAPL)

getSymbols("005930.KS", from = "2020-01-01", to = Sys.Date())
```

    ## [1] "005930.KS"

``` r
# 주봉 데이터로 변환
AAPL_weekly <- to.weekly(AAPL)
AAPL_weekly <- myfunc(AAPL_weekly)

samsung_weekly <- to.weekly(`005930.KS`)
samsung_weekly <- myfunc(samsung_weekly)

# 데이터 프레임으로 변환
apple_df <- data.frame(date=index(AAPL_weekly), coredata(AAPL_weekly))
samsung_df <- data.frame(date=index(samsung_weekly), coredata(samsung_weekly))

# 종가만 추출 후 합치기
apple_df_close <- apple_df %>% select(1, 4) # 주봉에서는 close가 4번째 열
samsung_df_close <- samsung_df %>% select(1, 4)

data <- merge(apple_df_close, samsung_df_close, by = "date")
colnames(data) <- c("date", "AAPL", "samsung")

# 날짜 형식 변환
data$date <- as.Date(data$date)

# 데이터 정규화 (첫날의 종가 기준 = 1)
data_normalized <- data %>%
   mutate(AAPL_normalized = AAPL / first(AAPL),
          samsung_normalized = samsung / first(samsung))

# 데이터 정리: 길게 변환
data_long <- data_normalized %>%
   select(date, AAPL_normalized, samsung_normalized) %>%
   gather(key = "company", value = "price_normalized", -date)
```

<br>

## 정규화된 주가 상승률 비교 차트

정규화된 주가 데이터를 이용하여 Apple과 삼성전자의 주가 상승률 비교
시각화. (첫날을 100%로 설정)

``` r
ggplot(data_long, aes(x = date, y = price_normalized, color = company)) +
   geom_line(size = 1.2) +
   geom_point(data = subset(data_long, date == max(date)), 
              aes(x = date, y = price_normalized, color = company), size = 3) +
   scale_color_manual(values = c("AAPL_normalized" = "#E41A1C", "samsung_normalized" = "#377EB8"),
                      labels = c("Apple", "Samsung")) +
   labs(title = "Apple vs Samsung 주가 상승률 비교 (주간 데이터)",
        subtitle = paste0("2020년 초 대비 상승률 (", format(min(data$date), "%Y-%m-%d"), " = 100%)"),
        x = NULL,
        y = "상승률",
        color = NULL,
        caption = "데이터 출처: Yahoo Finance(Quantmod) | 작성일: 2025-03-07") +
   theme_economist_white() +
   theme(
      text = element_text(family = "NanumGothic"),
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "#555555", margin = margin(b = 20)),
      plot.caption = element_text(size = 9, color = "#555555", hjust = 1, margin = margin(t = 15)),
      plot.background = element_rect(fill = "#FFFFFF", color = NA),
      panel.background = element_rect(fill = "#F9F9F9"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#DDDDDD", linetype = "dotted"),
      legend.position = "bottom",
      legend.background = element_rect(fill = "#FFFFFF", color = NA),
      legend.key = element_rect(fill = "transparent"),
      legend.margin = margin(t = 10, b = 10),
      axis.title.y = element_text(margin = margin(r = 10), face = "bold"),
      axis.text = element_text(color = "#333333"),
      axis.ticks = element_line(color = "#555555")
   ) +
   scale_y_continuous(labels = scales::percent_format(accuracy = 1), 
                      breaks = seq(0, 3.5, by = 0.5),
                      limits = c(0.5, 3.5),
                      expand = c(0, 0)) +
   scale_x_date(date_breaks = "6 months", 
                date_labels = "%Y-%m",
                expand = c(0.01, 0)) +
   annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-12-31"), 
            ymin = 0.5, ymax = 3.5, alpha = 0.1, fill = "#FFD700") +
   annotate("text", x = as.Date("2022-07-01"), y = 0.6, 
            label = "2022년 글로벌 테크주 조정기", 
            size = 5, fontface = "bold", color = "#555555") +
   geom_hline(yintercept = 1, linetype = "dashed", color = "#555555", size = 0.7) +
   # 최종 값 라벨 추가
   geom_text(data = subset(data_long, date == max(date)),
             aes(label = scales::percent(price_normalized, accuracy = 1), color = company),
             hjust = -0.3, vjust = 0, fontface = "bold", size = 3.5) +
   # 중요 이벤트 표시
   annotate("segment", x = as.Date("2023-06-01"), xend = as.Date("2023-06-01"),
            y = 2.7, yend = 2.5, arrow = arrow(length = unit(0.3, "cm")), color = "#E41A1C") +
   annotate("text", x = as.Date("2023-06-01"), y = 2.8, 
            label = "Apple Vision Pro 발표", 
            size = 5, fontface = "italic", color = "#E41A1C")
```

![](data/images/주가%20데이터%20추출%20및%20차트그리기(R%20markdown)/normalized-chart-1.png)<!-- -->
