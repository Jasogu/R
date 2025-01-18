#problems 1 - (i)
#오차항에는 모델에 포함된 설명변수들을 제외한 모든 것들이 포함될 수 있으며 남편의 학력, woman의 소득 등이 이에 해당할 수 있다
#또한 생략된 설명변수들은 모델의 종속변수와 설명변수와 상관관계가 나타날 수 있다.

#problems 1 - (ii)
#설명변수의 수가 1개이므로 ceteris paribus가 의미가 없으며 설명변수의 개수가 너무 적어 유의미한 분석이 불가능할 것이다.


#problems 4
attach(data)
ana <- lm(bwght ~ cigs)

#problems 4 - (i)
zero <- 119.77 - 0.514*0 #cigs = 0
two <- 119.77 - 0.514*20 #cigs = 20
zero - two #담배를 안 필경우 20개비 필 때보다 10.28만큼 birth weight이 큼

#problems 4 - (ii)
cor(cigs, bwght) # -0.15의 매우 약한 음의 상관관계를 가지고 있어 인과관계를 판단하기 어렵다.
summary(ana) # 모델은 유효하나, R-squared 가 약 0.02로 너무 낮아 확실한 인과관계가 있다고 판단하기 힘들다.

#problems 4 - (iii)
#모델에 따르면 cigs가 음수여야 bwght의 값이 119.77보다 클 수 있으므로 분석 불가능하다

#problems 4 - (iv)
#85%의 표본이 cigs=0 이므로, 85%의 bwght가 119.77이 나와 유의미한 분석이 불가능함


#C2 - (i)
attach(data)
mean(data$salary) #865.864
mean(data$comten) #22.503

#C2 - (ii)
ceoten[ceoten==0] #5개
max(ceoten) #37

#C2 - (iii)
lm(lsalary ~ ceoten) #log(salary) = 6.505 + 0.00972*ceoten
#ceoten이 1단위 오르면 salary가 0.972%가 오름



#C4 - (i)
attach(data)
mean(wage) #957.946
mean(IQ) #101.282
sd(IQ) #15.053

#C4 - (ii)
ana <- lm(wage ~ IQ) # wage = 116.992 + 8.303*IQ, IQ가 1단위 상승하면, wage는 8.303단위 상승한다
names(summary(ana))
summary(ana)$r.squared #결정계수 값 0.09, IQ는 임금 변동의 대부분을 설명하지 못한다
cor(wage, IQ) #결정계수 값 0.09와 상관관계값 0.309인 것을 감안하면 IQ를 제외한 설명변수를 추가해 분석할 필요가 있다고 보인다.

#C4 - (iii)
re <- lm(log(wage) ~ IQ)
summary(re) #log(Wage) = 5.887 + 0.0088*IQ, 15단위 만큼 IQ가 증가하면 wage는 0.0088*15% 증가한다
plot(IQ, log(wage))
abline(re)
