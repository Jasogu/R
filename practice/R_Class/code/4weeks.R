iris
iris[1:5,]
dim(iris)
head(iris, 10)
tail(iris, 7)
str(iris)
colSums(iris[,-5])

IR.1 <- subset(iris, Species == "setosa")
IR.1
IR.2 <- subset(iris, "Species"=="setosa")
IR.2

class(iris)

state.x77
iris
iris["Species"]
str(iris)
iris$Species

a <- 10
b <- 20
c <- ifelse(a > b, a, b)
c

sum <- 0
for(i in 1:100) {
  sum <- sum + i }
print(sum)

#iris 의 Petal.Length 의 길이에 따라 L M H 세 가지 형태로 나누고 자료로 저장하는 프로그래밍
norow <- nrow(iris) #iris의 행 개수를 norow에 저장
mylabel <- c() #mylabel 이라는 비어있는 벡터 자료형 생성
for(i in 1:norow) {   #norow의 행 갯수, 150 번 실행
  if (iris$Petal.Length[i] <= 1.6) {  #iris의 Petal.Length의 i번째 자료가 1.6이하 라면
    mylabel[i] <- 'L' #mylabel에 i번째 행에 문자열 L 저장
  } else if (iris$Petal.Length[i] >= 5.1) { #Petal.Length의 i번째 자료가 5.1 이상이라면
    mylabel[i] <- 'H' #mylabel의 i번째 행에 문자열 H 저장
  } else { #1.6이하, 5.1이상이 아니라면, 1.6< Petal.Length[i] < 5.1 이라면
    mylabel[i] <- 'M' #mylabel의 i번째 행에 문자열 M 저장
  }
}
print(mylabel) 
newds <- data.frame(iris$Petal.Length, mylabel) #Petal.length와 mylabel을 가진 데이터 프레임 생성
head(newds) #newds 를 위에서부터 6개까지 보여줌

