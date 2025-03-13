# 개인 프로젝트

## 1. 신용등급 예측 모델

코스피, 코스닥에 상장된 기업들의 재무데이터를 학습하여 신용등급을 예측하는 학습 알고리즘 만들기


FnGuide 에서 제공하는 신용등급 데이터를 토대로 분석
[출처 : 신용등급 데이터](https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701)

<br>

### 데이터 수집 및 전처리 설명
[전처리 코드 링크](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%8B%A0%EC%9A%A9%EB%93%B1%EA%B8%89%20%EC%98%88%EC%B8%A1%20%EB%AA%A8%EB%8D%B8_%EB%8D%B0%EC%9D%B4%ED%84%B0%20%EC%A0%84%EC%B2%98%EB%A6%AC_FnGuide%20%ED%81%AC%EB%A1%A4%EB%A7%81.r)

1. 3개 신용평가사 중 가장 최하 등급을 기준으로 분석(col = Bond_Mean)

ex1) 각각 A, A, BBB+ 이면 BBB+로 분석함.

ex2) KIS에서 AAA, KR에서 AA+, NICE에서 평가하지 않았다면 AA+로 분석함.

1. 신용등급 데이터에서 중복된 회사 제거
1. 신용등급이 취소된 경우(CNAC, 취소) 분석에서 제거
1. 분석에 필요한 재무데이터를 추가(웹 크롤링 후 전처리)
1. 부동산 펀드 등 재무데이터가 일반적이지 않은 기업 제거

위 전처리 코드를 실행하면 아래와 같은 엑셀 데이터 파일이 만들어짐.

[전처리 데이터 링크](https://docs.google.com/spreadsheets/d/1L92IEV94V0EKSrV6IHB3zg1XVqne0wZU/edit?usp=sharing&ouid=117590746085002044744&rtpof=true&sd=true)

<br>

전처리 데이터 예시(위에서 부터 10개)

| 종목코드 |   회사명   |        업종        |     시장     | Bond_Mean | 유동비율 |   당좌비율   |   부채비율   |    유보율   |  순차입금비율  | 이자보상배율 | 자산총계 |  매출액증가율  | 매출액 | EBITDA | 매출총이익률 |       ROA      |      ROE      |      ROIC     | 총자산회전율 | 총부채회전율 | 총자본회전율 | 순운전자본회전율 |
|:--------:|:----------:|:------------------:|:------------:|:---------:|:--------:|:------------:|:------------:|:-----------:|:--------------:|:------------:|:--------:|:--------------:|:------:|:------:|:------------:|:--------------:|:-------------:|:-------------:|:------------:|:------------:|:------------:|:----------------:|
| 095570   | AJ네트웍스 | 코스피 일반서비스  | 유가증권시장 | BBB+      |     44.9 | 0.4226269806 |  2.865141768 | 7.982905983 |    2.185132237 |  1.281045752 |    16222 |  -0.1605931138 |  10020 |   2460 |          100 |    0.010625966 | 0.04216713519 | 0.03879861238 | 0.6452859351 | 0.8629747653 |  2.558080163 |      1.180907484 |
| 006840   | AK홀딩스   | 코스피 금융        | 유가증권시장 | BBB       |     55.3 | 0.4324168498 |  3.106466816 | 7.824773414 |    1.371011357 |  2.229233227 |    53150 |   0.1826029567 |  44797 |   5239 |         24.5 |  0.02531940507 | 0.06164874552 | 0.06648570394 | 0.8698108811 |  1.157126621 |  3.503049734 |      6.786396001 |
| 027410   | BGF        | 코스피 금융        | 유가증권시장 | A+        |    331.6 |  2.852963818 | 0.1423760918 | 16.28944619 |  -0.1030727139 |           15 |    21713 |  0.01885057471 |   4432 |    941 |         32.3 |  0.03363185048 | 0.04808108275 |  0.1472718493 | 0.2157110873 |   1.87717069 | 0.2437039481 |      19.43859649 |
| 001040   | CJ         | 코스피 금융        | 유가증권시장 | AA-       |     93.3 | 0.7192592024 |  1.638139363 | 30.63184358 |   0.7607641062 |   2.24422188 |   472038 |  0.01045329372 | 413527 |  50988 |         27.6 |  0.01099490592 | 0.03642278855 | 0.03811835625 | 0.8665314393 |  1.382621895 |  2.321463858 |      6.966777297 |
| 079160   | CJ CGV     | 코스피 오락·문화   | 유가증권시장 | A-        |       46 | 0.4412590799 |  11.22894334 | 5.883986928 |    7.782542113 | 0.3351535836 |    31942 |   0.2141061891 |  15458 |   3477 |          100 | -0.03631761728 |  -0.241223671 |  0.0191490207 | 0.4549414327 | 0.5034031328 |  4.724327628 |     0.9571517028 |
| 000120   | CJ대한통운 | 코스피 운송·창고   | 유가증권시장 | AA-       |     94.9 | 0.9375357511 |  1.314461675 | 33.04995618 |   0.6722811704 |  3.136512084 |    93576 | -0.02990758983 | 117679 |  10594 |           11 |  0.02550024146 | 0.06266551445 | 0.05947567281 |  1.235423184 |   2.14480471 |  2.913784138 |      7.860463563 |
| 097950   | CJ제일제당 | 코스피 음식료·담배 | 유가증권시장 | AA        |    100.3 | 0.7078467077 |  1.513281097 | 87.54456654 |   0.7637501167 |  2.505528613 |   296063 | -0.03510696654 | 290235 |  28337 |         20.9 |  0.01876899543 |  0.0554964335 | 0.05015599118 | 0.9736227684 |  1.598624093 |  2.490325625 |      8.786479777 |
| 012030   | DB         | 코스피 IT 서비스   | 유가증권시장 | B         |     72.3 | 0.7199816682 |  1.225202429 | 3.209741551 | -0.06072874494 |  9.736842105 |     8794 |   0.1427859457 |   4586 |    437 |         18.5 |  0.03138042974 | 0.05970588235 |  -1.890322581 |  0.708919462 |  1.494784876 |  1.348426933 |     -5.971354167 |
| 000990   | DB하이텍   | 코스피 전기·전자   | 유가증권시장 | A-        |      467 |  4.297456857 | 0.1743003276 | 7.358939802 |  -0.3444629619 |  241.2727273 |    20434 |   -0.308655286 |  11542 |   3988 |         38.3 |   0.1261945719 |  0.1565129785 |  0.2675070028 | 0.5515099388 |  2.847767086 | 0.6840109043 |     -76.43708609 |

<br>
<br>

### 분석 설명
[분석 코드 링크](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%8B%A0%EC%9A%A9%EB%93%B1%EA%B8%89%20%EC%98%88%EC%B8%A1%20%EB%AA%A8%EB%8D%B8_%EB%B6%84%EC%84%9D.R)

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

![ ](https://github.com/user-attachments/assets/cdfad883-cfcf-49c4-978a-876406c5a8b8)

[소스 코드 링크](https://github.com/Jasogu/R/blob/main/REPORT/code/%EC%A3%BC%EA%B0%80%20%EB%8D%B0%EC%9D%B4%ED%84%B0%20%EC%B6%94%EC%B6%9C%20%EB%B0%8F%20%EC%B0%A8%ED%8A%B8%EA%B7%B8%EB%A6%AC%EA%B8%B0(R%20markdown).Rmd)


<br><br><br>

## 3. 심장질환 분석 모델

<br>

[데이터 구글시트 링크](https://docs.google.com/spreadsheets/d/1AhSACyLwqAcJndfFMgU_5jNOMqMdjXfWeMO9MhjkqTI/edit?usp=sharing)

[데이터 출처 링크](https://github.com/yc015/yida-r-visualization-portfolio-website)

1. 데이터의 70%는 훈련용 데이터로 사용하고, 30%는 테스트용 데이터로 사용
1. K-fold 교차검증(5-fold)과 RandomForest를 통해 분석
1. 클래스 가중치를 통한 불균형 처리 적용(심장병이 있는 경우가 훨씬 적은 것을 보정)

<br>

### 데이터 설명

| Variable           | Type                                                                              |
|--------------------|-----------------------------------------------------------------------------------|
| $ HeartDisease     | : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 2 1 1 1 1 ...                          |
| $ BMI              | : num 16.6 20.3 26.6 24.2 23.7 ...                                                |
| $ Smoking          | : Factor w/ 2 levels "No","Yes": 2 1 2 1 1 2 1 2 1 1 ...                          |
| $ AlcoholDrinking  | : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 1 1 ...                          |
| $ Stroke           | : Factor w/ 2 levels "No","Yes": 1 2 1 1 1 1 1 1 1 1 ...                          |
| $ PhysicalHealth   | : num 3 0 20 0 28 6 15 5 0 0 ...                                                  |
| $ MentalHealth     | : num 30 0 30 0 0 0 0 0 0 0 ...                                                   |
| $ DiffWalking      | : Factor w/ 2 levels "No","Yes": 1 1 1 1 2 2 1 2 1 2 ...                          |
| $ Sex              | : Factor w/ 2 levels "Female","Male": 1 1 2 1 1 1 1 1 1 2 ...                     |
| $ AgeCategory      | : Factor w/ 13 levels "18-24","25-29",..: 8 13 10 12 5 12 11 13 13 10 ...         |
| $ Race             | : Factor w/ 6 levels "American Indian/Alaskan Native",..: 6 6 6 6 6 3 6 6 6 6 ... |
| $ Diabetic         | : Factor w/ 4 levels "No","No, borderline diabetes",..: 3 1 3 1 1 1 1 3 2 1 ...   |
| $ PhysicalActivity | : Factor w/ 2 levels "No","Yes": 2 2 2 1 2 1 2 1 1 2 ...                          |
| $ GenHealth        | : Factor w/ 5 levels "Excellent","Fair",..: 5 5 2 3 5 2 2 3 2 3 ...               |
| $ SleepTime        | : num 5 7 8 6 8 12 4 9 5 10 ...                                                   |
| $ Asthma           | : Factor w/ 2 levels "No","Yes": 2 1 2 1 1 1 2 2 1 1 ...                          |
| $ KidneyDisease    | : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 2 1 ...                          |
| $ SkinCancer       | : Factor w/ 2 levels "No","Yes": 2 1 1 2 1 1 2 1 1 1 ...                          |


데이터에서 심장병(HeartDisease)의 비중은 다음과 같다.(Yes가 심장병에 걸린 경우)

No : 292422(91.4%) <br>
Yes : 27373(8.55%)

<br>

#### 범주형 변수에 대한 카이제곱 검정 결과:
|    | Variable             | P_Value       |
|----|----------------------|---------------|
| 1  | Smoking              | 0.000000e+00  |
| 2  | Stroke               | 0.000000e+00  |
| 3  | DiffWalking          | 0.000000e+00  |
| 4  | Sex                  | 0.000000e+00  |
| 5  | Diabetic             | 0.000000e+00  |
| 6  | PhysicalActivity     | 0.000000e+00  |
| 7  | GenHealth            | 0.000000e+00  |
| 8  | KidneyDisease        | 0.000000e+00  |
| 9  | SkinCancer           | 0.000000e+00  |
| 10 | Race 2.988613e-180   | 2.238614e-121 |
| 11 | Asthma 2.238614e-121 | 1.892352e-73  |
| 12 | AlcoholDrinking      | 1.892352e-73  |

모든 변수에서 카이제곱 검정 결과가 0.05보다 작으므로 유의미한 결과를 얻을 수 있다(귀무가설 기각)

<br>

#### 수치형 변수에 대한 t-test 결과:

| Variable         | P_Value      |              
|------------------|--------------|
| BMI 2.772150e-175| 2.772150e-175|
| PhysicalHealth   | 0.000000e+00 |
| MentalHealth     | 1.480102e-45 |
| SleepTime        | 1.133140e-04 |


수치형 변수에서도 모든 변수에서 p-value가 0.05보다 작으므로 유의미한 결과를 얻을 수 있다(귀무가설 기각)

<br>

#### 변수 간 강한 상관관계는 존재하지 않음
![](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/corplot.png)

<br>

### 탐색적 데이터 분석 결과 시각화

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/unnamed-chunk-1-1.png)

<br>

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/unnamed-chunk-1-2.png)

<br>

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/unnamed-chunk-1-4.png)

<br>

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/unnamed-chunk-1-3.png)

<br>

![](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/venn.png)

<br>
<br>

### 분석 결과
#### RandomForest 모델 결과

                  Reference
      Prediction  No    Yes 
              No  86430 7288           
             Yes  1296  923            
                                          
      Accuracy : 0.9105          
      95% CI : (0.9087, 0.9123)
      No Information Rate : 0.9144          
      P-Value [Acc > NIR] : 1               
      
      Kappa : 0.1459
                              
      Mcnemar's Test P-Value : <2          
                              
      Sensitivity : 0.9852       
      Specificity : 0.1124 
      Pos Pred Value : 0.9222 
      Neg Pred Value : 0.4160 
      Prevalence : 0.9144 
      Detection Rate : 0.9009   
      Detection Prevalence : 0.9769   
      Balanced Accuracy : 0.5488   

분석 결과, Accuracy는 91.05%로 나타났다.

Sensitive는 98.52%로 심장병이 없을 거라고 예측했을 때, 실제로 심장병이 없을 확률이 98.52%라는 의미로 상당히 유의미한 예측이 가능하다.

하지만 Specificity는 11.24%라는 상당히 낮은 수치이다.

심장병이 있을 거라고 예측했을 때, 실제로 심장병을 가지고 있을 확률이 11.24%라는 의미로 유의미한 예측이 불가능하다.

결론적으로 이 모델은 심장병이 있든지 없든지 무조건 No라고 예측하는 것과 비슷한 결과를 보여준다. 

<br>

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/ROC.png)

<br>

#### ROC 최적 임계값 적용 모델 결과
Confusion Matrix and Statistics

                   Reference
      Prediction   No     Yes
             No    63445  2114
            Yes    24281  6097
                                 
               Accuracy : 0.7249         
                 95% CI : (0.722, 0.7277)
    No Information Rate : 0.9144         
    P-Value [Acc > NIR] : 1              
                                 
                  Kappa : 0.2095 
                                 
      Mcnemar's Test P-Value : <2e-16 
                                 
            Sensitivity : 0.7232         
            Specificity : 0.7425         
         Pos Pred Value : 0.9678         
         Neg Pred Value : 0.2007         
             Prevalence : 0.9144         
         Detection Rate : 0.6613         
      Detection Prevalence : 0.6834         
      Balanced Accuracy : 0.7329         
                                 
      'Positive' Class : No      

<br>

#### 교차 검증 모델 성능:

| mtry | ROC | Sens | Spec | ROCSD | SensSD | SpecSD |
|------|-----|------|------|-------|--------|--------|
| 2  | 0.7737728 | 0.9987884 | 0.02588456 | 0.003132079 | 0.0003342991 | 0.002130767 |
| 9  | 0.8047359 | 0.9853246 | 0.11637595 | 0.002206424 | 0.0004457536 | 0.005630109 |
| 17 | 0.7983929 | 0.9793792 | 0.13114472 | 0.002797976 | 0.0007140436 | 0.007927933 |

<br>

![ ](https://raw.githubusercontent.com/Jasogu/R/refs/heads/main/REPORT/images/Heart%20Disease%20Data%20Analysis/Feature.png)

<br>
<br>

### 결론
최적 임계값을 적용한 모델의 정확도는 72.49%로 나타났다.

실제로 심장병이 없는 경우(No)인 63445+24281=87726건 중 63445건을 정확하게 예측했으며(72.3%)

실제로 심장병이 있는 경우(Yes)인 2114+6097=8211건 중 6097건을 정확하게 예측했다.(74.3%)

[소스 코드 링크](https://github.com/Jasogu/R/blob/main/REPORT/code/Heart%20Disease%20Data%20Analysis.r)










<br><br><br>
# 업데이트 예정

<details>
<summary>접기/펼치기</summary>




</details> 
