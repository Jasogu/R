sum <- 0
i <- 1
while(i <= 100) {
  sum <- sum +i
  i <- i +1
}
print(sum)
##########################################
apply(iris[,1:4], 2, mean) #1=row, 2=col

mymax <- function(x,y) {
num.max <- x
if (y > x) {
  num.max <- y
}
return(num.max)
}

a <- mymax(20,10)
a
###############
cars.new <- cars
cars.new[,2]
boxplot(cars.new[,2])
