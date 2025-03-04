# 개인 프로젝트

## 1. 신용등급 예측 모델

코스피, 코스닥에 상장된 기업들의 재무데이터를 학습하여 신용등급을 예측하는 학습 알고리즘 만들기


FnGuide 에서 제공하는 신용등급 데이터를 토대로 분석
[출처 : 신용등급 데이터](https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701)

<br>
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

[전처리 데이터](https://docs.google.com/spreadsheets/d/1L92IEV94V0EKSrV6IHB3zg1XVqne0wZU/edit?usp=sharing&ouid=117590746085002044744&rtpof=true&sd=true)

<br>
<br>

### 분석 설명
[분석 코드](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%8B%A0%EC%9A%A9%EB%93%B1%EA%B8%89%20%EC%98%88%EC%B8%A1%20%EB%AA%A8%EB%8D%B8_%EB%B6%84%EC%84%9D.R)

1. 분석파트는 Claude 3.7 Sonnet이 활용하여 설계됨
1. RandomForest, Gradient Boosting Machine, Soft Vector Machine 3가지 모델을 사용하여 각자 분석 후 가장 좋은 결과값을 내는 모델 채택
1. 목적변수인 신용등급을 숫자형으로 변환 후 분석함
1. rmse, mae, 상관관계, R-squared를 평가지표로 사용
1. Winsorization, Z-score 이용하여 이상치 제어
1. 피처 스케일링 : Min-Max 정규화, 표준화
1. 데이터 중 80%를 학습용 데이터로 사용, 20%를 예측용 데이터로 사용함
1.




# 업데이트 예정

<details>
<summary>접기/펼치기</summary>


</details> 
