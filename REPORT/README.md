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

## 2. 주가 데이터 조작 및 차트 그리기

### Quantmod

R의 Quantmod 라이브러리를 사용하면 주가 데이터를 불러올 수 있다.

원하는 시작날짜와 종료날짜, 일봉, 주봉, 월봉을 비롯하여 이평선, 볼린저밴드, RSI, MACD 등의 기술적 지표를 차트로 나타낼수 있다.


![dark color theme](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/%EC%A3%BC%EA%B0%80%20%EB%8D%B0%EC%9D%B4%ED%84%B0%20%EC%B6%94%EC%B6%9C%20%EB%B0%8F%20%EC%B0%A8%ED%8A%B8%EA%B7%B8%EB%A6%AC%EA%B8%B0(R%20markdown)/samsung-chart-daily-1.png)

<br>

![white color theme](images/주가 데이터 추출 및 차트그리기(R markdown)/samsung-chart-weekly-1.png)

<br>

![white color theme](images/주가 데이터 추출 및 차트그리기(R markdown)/samsung-chart-monthly-1.png)

<br>

### 주가 상승률 비교 차트

Apple과 삼성전자의 주가 상승률 비교 시각화. (첫날을 100%로 설정)

2020년을 기준으로 애플은 주가가 3배가 되었고 삼성의 주가는 상승하지 못했다.

![](images/주가 데이터 추출 및 차트그리기(R markdown)/normalized-chart-1.png)



<br><br><br>





<br><br><br>
# 업데이트 예정

<details>
<summary>접기/펼치기</summary>

1. 신용등급 예측 모델 업데이트
1. Quantmod library
1. 통계청 자료를 통해 알아보는 한국의 임금결정 모델 분석
1. 웹 크롤링

</details> 
