library(mlbench)
data("BostonHousing")
myds <- BostonHousing[, c("crim", "rm", "dis", "tax", "medv")] #5개 열을 추출하여 myds에 저장

grp <- c() #빈 벡터 생성
#medv 가 25이상이면 H, 17이하면 L, 그 사이면 H를 부여하고 이를 grp에 저장
for (i in 1:nrow(myds)) {
  if (myds$medv[i] >= 25.0) {
    grp[i] <- "H"
  } else if (myds$medv[i] <= 17.0) {
    grp[i] <- "L"
  } else {
    grp[i] <- "M"
  }
}

grp <- factor(grp) #grp를 팩터로 변경
grp <- factor(grp, levels = c("H", "M", "L")) #HLM 순서를 HML 로 변경
myds <- data.frame(myds, grp) #myds에 grp 열 추가

#화면을 2행3열로 분할 후 crim, rm 등 5개 열의 hist 생성, 각각에 맞는 제목 부여
par(mfrow = c(2, 3))
for(i in 1:5) {
  hist(myds[,i], main=colnames(myds)[i])
}
par(mfrow=c(1,1))

#화면분할 후 각 열의 boxplot 생성, 각각에 맞는 제목 부여
par(mfrow = c(2, 3))
for(i in 1:5) {
  boxplot(myds[,i], main = colnames(myds)[i])
}
par(mfrow=c(1, 1))

#2*2 화면분할 후 grp에 따른 각 열의 boxplot 생성
par(mfrow=c(2, 2))
boxplot(myds$crim~myds$grp, main="crim~grp")
boxplot(myds$rm~myds$grp, main="rm~grp")
boxplot(myds$dis~myds$grp, main="dis~grp")
boxplot(myds$tax~myds$grp, main="tax~grp")
par(mfrow=c(1, 1))

#위의 코드 for으로 구현
par(mfrow=c(2, 2))
for (i in 1:4) {
  boxplot(myds[, colnames(myds[i])] ~ myds[, 6], main = colnames(myds[i]), xlab="", ylab="")
}
par(mfrow=c(1, 1))

#HML을 빨강 초록 파랑으로 표현, 각 열들을 pairs로 구현
point <- as.integer(myds$grp)
color <- c("red", "green", "blue")
pairs(myds[, -6], pch = point, col = color[point])

#열들의 상관관계 분석
cor(myds[,1:5])

########################
#sample을 이용해 iris의 무작위 행, 열값을 NA로 바꾼후, na.omit을 활용해 NA값 제거
row <- nrow(iris)
col <- ncol(iris)

sample_row <- sample(row, size=5)
sample_col <- sample(col, size=5)

#iris에서 임의의 5개 (i, j)값을 NA로 변경해서 iris_test에 저장. NA값을 포함한 행들을 result에 저장
iris_test <- iris
for (i in 1:length(sample_row)){
  iris_test[sample_row[i], sample_col[i]] <- NA
  result[i,] <- iris_test[sample_row[i],]
}

#생성된 NA를 포함한 5개의 행과 열 프린트 후 제거
print(which(is.na(iris_test)==TRUE, arr=TRUE))
iris_test <- na.omit(iris_test)
dim(iris_test) # iris_test 가 (145, 5)로 변경됨을 확인하여 NA값 제거됨을 확인함


