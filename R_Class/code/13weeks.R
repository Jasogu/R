#선형회귀분석
head(cars)
plot(dist~speed, data=cars) # 산점도를 통해 선형 관계 확인

model <- lm(dist~speed, data = cars) # 회귀모델 구하기
model

abline(model) # 회귀선을 산점도 위에 표시
coef(model)[1] # b 값 출력
coef(model)[2] # W 값 출력


b <- coef(model)[1]
W <- coef(model)[2]

speed <- 30 # 주행속도
dist <- W*speed + b
dist # 제동거리

speed <- 35 # 주행속도
dist <- W*speed + b
dist # 제동거리

speed <- 40 # 주행속도
dist <- W*speed + b
dist # 제동거리

#다중선형회귀분석
library(car)
head(Prestige)
newdata <- Prestige[,c(1:4)] # 회귀식 작성을 위한 데이터 준비
plot(newdata, pch=16, col="blue", # 산점도를 통해 변수 간 관계 확인
     main="Matrix Scatterplot")
mod1 <- lm(income ~ education + prestige + # 회귀식 도출
             women, data=newdata)
summary(mod1)

#의미없는 변수를 찾아서 제거해줌
library(MASS)
newdata2 <- Prestige[,c(1:5)]
mod2 <- lm(income ~ education + prestige + women + census, data = newdata2)
mod3 <- stepAIC(mod2)
summary(mod3) #최적의 변수만 선택한 것을 보여줌

#로지스틱 회귀분석
iris.new <- iris
iris.new$Species <- as.integer(iris.new$Species) # 범주형 자료를 정수로 변환
head(iris.new)
mod.iris <- glm(Species ~., data= iris.new) # 로지스틱 회귀모델 도출
summary(mod.iris) # 회귀모델의 상세 내용 확인

mod.iris <- glm(Species ~., data = iris.new) #마침표 : 모든 변수 대입

# 예측 대상 데이터 생성(데이터프레임)
unknown <- data.frame(rbind(c(5.1, 3.5, 1.4, 0.2)))
names(unknown) <- names(iris)[1:4]
unknown # 예측 대상 데이터
pred <- predict(mod.iris, unknown) # 품종 예측 함수 predict
pred # 예측 결과 출력
round(pred,0) # 예측 결과 출력(소수 첫째 자리에서 반올림)
# 실제 품종명 알아보기
pred <- round(pred,0)
pred
levels(iris$Species)
levels(iris$Species)[pred]
