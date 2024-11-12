#problem 1
library(dplyr)
attach(data)
roes = roe*roe
lm(log(salary) ~ log(sales) + roe + roes) %>% summary
#roe^2 의 t값은 -0.293으로 통계적으로 유의미하지 않다

#problem 4-(ii)
#(ii) Given or fixed "educ", what is the change in return to education if "pareduc" is changed from 24 to 32? *given or fixed는 편미분을 의미
attach(data)
pareduc = meduc + feduc
lm(log(wage) ~ educ + educ*pareduc + exper + tenure -pareduc)
#log(wage) = 5.65 + 0.47*educ + 0.00078*educ*pareduc + 0.19*exper + 0.010*tenure
#만일 educ가 주어져있다면 educ로 편미분함을 의미, 0.47 + 0.00078*pareduc 가 된다. 0.47+0.00078*32 - 0.47+0.00078*24 = 0.04368, 4.368% 임금이 상승한다.


#problem 4-(iii)
#(iii) Test if the coefficient of the interaction term is zero or not. *interaction term 서로 다른 독립변수의 곱으로 이루어진 항
lm(log(wage) ~ educ + pareduc +educ*pareduc + exper + tenure) %>% summary
lm(log(wage) ~ educ + pareduc + exper + tenure) %>% summary
#interaction term을 넣고 회귀분석 했을 경우 pareduc와 educ*pareduc가 t값이 낮아 통계적으로 유의미하지 않으나
#interaction term을 빼고 회귀분석을 하면 모든 계수가 별표 3개로 통계적으로 의미있으므로 빼고 분석해야한다

#C2
attach(data)
lm(sat ~ hsize + hsizesq) %>% summary

#(i)sat = 997.981 + 19.814*hsize - 2.131*hsizesq, 모든 계수가 통계적으로 의미있다(***)

#(ii) hsize가 5일 때 1043.776으로 가장 크므로(1부터 10까지 자연수 대입시) 5를 택할것이다. 
for(i in 1:10){
  print(997.981 + 19.814*i - 2.131*i*i)
}

#(iii)모델의 계수가 통계적으로 유의하지만 결정계수가 0.007로 매우 낮은것으로 보아 더 다양한 독립변수를 통한 분석이 필요하다


#(iv)종속변수에 로그를 씌워도 결과는 바뀌지 않는다
lm(log(sat) ~ hsize + hsizesq) %>% summary
for(i in 1:10){
  print(6.896 + 0.0196*i - 0.0021*i*i)
}





