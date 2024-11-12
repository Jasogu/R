#선그래프
month <- 1:12
late <- c(5, 8, 7, 9, 4, 6, 12, 13, 8, 6, 6, 4)
late2 <- c(4, 6, 5, 8, 7, 8, 10, 11, 6, 5, 7, 3)
plot(month, late, type="l")
lines(month, late2)

#데이터 전처리(결측값, 특이값, 데이터 정렬,분리와 선택,샘플링과 조합,집계와 병합)
#보통 결측값을 제거함
z <- c(1, 2, 3, NA, 5, NA, 8)
is.na(z)
is.na(z)
z1 <- as.vector(na.omit(z))
z1

x <- iris
x[1, 2] <- NA; x[1, 3] <- NA
head(x)

for (i in 1:ncol(x)) {
  this.na <- is.na(x[,i])
  cat(colnames(x)[i], "\t", sum(this.na), "\n")
}

col_na <- function(y) {
  return(sum(is.na(y)))
}
na_count <- apply(x, 2, FUN = col_na)
na_count

sum(is.na(z))

test <- boxplot(iris$Petal.Width~iris$Species)$out
iris[order(iris$Species, -iris$Petal.Length),]

sp <- split(iris, iris$Species)
sp$setosa

y <- sample(1:10, 10, TRUE)
table(y)
y

dim(iris)
combn(1:5, 3)

library(treemap)
data(GNI2014)
head(GNI2014)

library(ggplot2)
ggplot(data=iris, aes(y=Petal.Length, fill=Species)) +
  geom_boxplot()

subset(iris, iris$Sepal.Length > 7.6, select = c(Sepal.Length, Sepal.Width))
