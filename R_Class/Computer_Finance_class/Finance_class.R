#2주차 lms R_function PDF 참고
setwd("/Users/hong/Desktop/Data Sets-R")
na.omit(data$fatheduc)
attach(data) #앞으로 data$ 표기 없이 사용가능함, detach(data)로 제거가능
mean(na.omit(data$fatheduc))
mean(na.omit(fatheduc))
rm(list=ls()) #데이터 말소

dim(data) #행렬 크기 알려줌
nrow(data)
ncol(data)
subset(data, 조건1, 조건2...)

a <- c(1:10)
a^2
seq(1, 9, 3)

length(data)
str(data)
dim(data)
a<5
sqrt(2)

plot(sin(seq(0, 2*pi, length=100)))
plot(density(na.omit(fatheduc)))

#4주차 3월 25일 월요일
#problem 3 : 마이너스 관계

#c1 exercise, file:wage1
attach(data)
mean(educ)
a <- c(1:10, NA, 12)
mean(a, na.rm=TRUE)
summary(educ)
hist(educ)
names(data)
mean(wage)
summary(wage)

mean(a)
summary(a)
mean(na.omit(a))
length(female) #전체 인원수
sum(female)  #여자 수
length(female)-sum(female) #남자 숫자


length(female[female==1])
length(data$female[data$female == 1]) #대괄호 활용

#4주차 3월 25일 월요일, c2, file : bwght, cig : cigarette, 임산부들에 대한 데이터
attach(data)
dim(data)
length(cigs[cigs>0])
hist(cigs[cigs>0]) #담배를 피는 사람들이 담배를 몇 개 피는지

summary(cigs)

#(ii) 담배를 피지 않는 임산부들이 대부분이므로 임산부가 평균 2개비의 담배를 핀다는 건 오류가 있음
#(iii) hist(cigs[cigs>0]) 흡연 임산부들은 대부분 20개 이하를 핀다

summary(data$fatheduc)
mean(fatheduc, na.rm=TRUE)
sd(data$faminc)
mean(fatheduc[cigs>0], na.rm=TRUE)

#c6 file : countymurder.r, 1996년 자료만 이용할 것
cm <- read.csv("countymurders.r")
names(cm)
dim(cm)
head(cm)


cm1996 <- cm[cm$year==1996,]
cm1996<-subset(cm, year==1996)
attach(cm1996)
cor(murders, execs) #execs : 사형집행
length(unique(cm1996$countyid)) #unique : 중복값 제거
detach(cm1996)

#file : fertile2
attach(data)
summary(children)
summary(electric)
sum(electric, na.rm=TRUE)/nrow(data)

mean(children[electric==1], na.rm=TRUE)
summary(children[electric==1])
summary(children[electric==0])
hist(children)

length(na.omit(data$electric))


#4월 1일 수업, file : countymurders.r, y : murders, x : execs
cm <- read.csv("countymurders.r")
cm1996 <- subset(cm, year=1996)
reg <- lm(murders ~ execs)
names(reg)
length(reg$residuals)  
sum(reg$residuals) #잔차의 합은 0이다. ols
sum(reg$residuals*execs) #잔차*x 의 합은 0이다.

b0 <- reg$coefficients[1] #추정 베타0값
b1 <- reg$coefficients[2] #추정 베타1값
x_bar <- mean(execs)
y_bar <- mean(murders) #y의 평균 = 베타0 + 베타1*(x1평균)

y_bar
as.numeric(b0) + as.numeric(b1)*x_bar

summary(reg)
head(murders) - head(reg$fitted.values) #y - y^
head(reg$residuals) #residuals
summary(reg)$r.square #결정계수



     