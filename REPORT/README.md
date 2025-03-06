# 개인 프로젝트

## 1. 신용등급 예측 모델

코스피, 코스닥에 상장된 기업들의 재무데이터를 학습하여 신용등급을 예측하는 학습 알고리즘 만들기


FnGuide 에서 제공하는 신용등급 데이터를 토대로 분석
[출처 : 신용등급 데이터](https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701)

<br>

### 데이터 수집 및 전처리 설명
[전처리 코드](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%8B%A0%EC%9A%A9%EB%93%B1%EA%B8%89%20%EC%98%88%EC%B8%A1%20%EB%AA%A8%EB%8D%B8_%EB%8D%B0%EC%9D%B4%ED%84%B0%20%EC%A0%84%EC%B2%98%EB%A6%AC_FnGuide%20%ED%81%AC%EB%A1%A4%EB%A7%81.r)

1. 3개 신용평가사 중 가장 최하 등급을 기준으로 분석(col = Bond_Mean)

ex1) 각각 A, A, BBB+ 이면 BBB+로 분석함.

ex2) KIS에서 AAA, KR에서 AA+, NICE에서 평가하지 않았다면 AA+로 분석함.

1. 신용등급 데이터에서 중복된 회사 제거
1. 신용등급이 취소된 경우(CNAC, 취소) 분석에서 제거
1. 분석에 필요한 재무데이터를 추가(웹 크롤링 후 전처리)
1. 부동산 펀드 등 재무데이터가 일반적이지 않은 기업 제거

위 전처리 코드를 실행하면 아래와 같은 엑셀 데이터 파일이 만들어짐.

[전처리 데이터](https://docs.google.com/spreadsheets/d/1L92IEV94V0EKSrV6IHB3zg1XVqne0wZU/edit?usp=sharing&ouid=117590746085002044744&rtpof=true&sd=true)

<br>

### 분석 설명
[분석 코드](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%8B%A0%EC%9A%A9%EB%93%B1%EA%B8%89%20%EC%98%88%EC%B8%A1%20%EB%AA%A8%EB%8D%B8_%EB%B6%84%EC%84%9D.R)

1. 분석파트는 Claude 3.7 Sonnet을 활용하여 설계됨
1. RandomForest, Gradient Boosting Machine, Soft Vector Machine 3가지 모델을 사용하여 각자 분석 후 가장 좋은 결과값을 내는 모델 채택
1. 목적변수인 신용등급을 숫자형으로 변환 후 분석함
1. rmse, mae, 상관관계, R-squared를 평가지표로 사용
1. Winsorization, Z-score 이용하여 이상치 제어
1. 피처 스케일링 : Min-Max 정규화, 표준화
1. 데이터 중 80%를 학습용 데이터(train)로 사용, 20%를 예측용 데이터(test)로 사용함

<br>

### 분석 결과 시각화
![분석 결과](https://github.com/user-attachments/assets/08a7e404-9981-4939-bc49-8276d1113f93)

분석 결과 RandomForest(rf) 모델이 가장 좋은 결과를 보여주었다.

결정계수는 0.65로, 이 모델을 통해 기업의 신용등급을 65%가량 설명할 수 있다고 볼 수 있다.

MAE, RMSE를 고려할 때 대략 2~3단계의 신용등급 오차가 발생할 수 있음, ex) 실제 AA- 등급을 AA+로 예측할 수 있음

예측 모델 자체는 실제 기업의 신용등급의 많은 부분을 설명할 수 있으나, 신용등급을 정확하게 예측하지는 못한다(오차발생).

### 오차 발생 원인
1. 단순 재무데이터만을 가지고 분석을 했다. 기업의 보유 자산의 구체적인 가치평가 등의 분석을 하지 못했음
1. CEO, 산업 전망, 지배구조 등의 정성적 데이터는 분석 데이터에 넣지 못했다
1. 데이터가 너무 적다. 약 500개의 기업을 분석했으나 데이터가 너무 적고, 업종별로 나누면 데이터가 훨씬 더 적어진다.

### 결론
기업의 신용등급은 재무데이터만 넣으면 되는 단순한 작업이 아니다.

AI와 데이터 분석을 통해 단순히 데이터만 넣어서는 신용등급을 만들 수 없으므로 장기적으로도 인간의 손이 반드시 필요할 것으로 예상된다.

의의 : 기업의 신용등급 평가에서 재무데이터가 얼마나 큰 비중을 차지하는지, 어떤 재무과목(독립변수)가 신용등급 평가에서 가장 중요한 지 알 수 있었다.

### 느낀점

데이터 수집 및 웹크롤링, 전처리, 데이터 분석, AI활용을 종합적으로 연습해볼 수 있었다.

AI, 특히 Claude 3.7 Sonnet의 성능이 놀라울 정도로 뛰어나다.
다 지어놓은 아파트의 기둥을 옮기는 작업같은, 코드 수백줄을 읽고 하나하나 바꿔야 하는 작업을 순식간에 처리해버려서 중간중간 코드를 뒤엎을 때 시간이 말도 안되게 단축됐다.









<br><br><br>

## 1. 주가 데이터 조작 및 차트 그리기

### Quantmod

R의 Quantmod 라이브러리를 사용하면 주가 데이터를 불러올 수 있다.

원하는 시작날짜와 종료날짜, 일봉, 주봉, 월봉을 비롯하여 이평선, 볼린저밴드, RSI, MACD 등의 기술적 지표를 차트로 나타낼수 있다.

차트를 그릴 땐 dark 테마와 white 테마를 적용할 수 있고 상승봉과 하락봉의 색상 등 테마의 세부 요소들의 커스터마이징이 가능하다


![dark color theme](https://github.com/user-attachments/assets/c5f4d003-7c82-44c6-8cc7-fe711a7a0e86)

<br>

![white color theme](https://github.com/user-attachments/assets/1bf38888-c27f-4ceb-9fc9-b5bf2986cb8f)

<br>

![white color theme](https://github.com/user-attachments/assets/834394b3-c9f1-4de7-a528-5a8904caa84c)

<br>

### 주가 상승률 비교 차트

Apple과 삼성전자의 주가 상승률 비교 시각화. (첫날을 100%로 설정)

2020년을 기준으로 애플은 주가가 3배가 되었고 삼성의 주가는 상승하지 못했다.

![ggplot](https://github.com/user-attachments/assets/cdfad883-cfcf-49c4-978a-876406c5a8b8)

<details>
<summary>소스코드 펼치기</summary>


library(quantmod)
library(tidyverse)
library(lubridate)
library(ggthemes)
theme_set(theme_grey(base_family='NanumGothic'))


# 열 이름 변경
myfunc <- function(x) {
   colnames(x) <- c('open', 'high', 'low', 'close', 'volume', 'adjusted')
   invisible(x)
}

# 데이터 가져오기
getSymbols("AAPL", from = "2020-01-01", to = Sys.Date()-1)
AAPL <- myfunc(AAPL)

getSymbols("005930.KS", from = "2020-01-01", to = Sys.Date())

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

# 향상된 시각화
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

</details> 



<br><br><br>





<br><br><br>
# 업데이트 예정

<details>
<summary>접기/펼치기</summary>




</details> 
