#list, vector, factor, matrix 

#vector
x1 <- c("a", "b", "c")
x2 <- seq(1, 7, 3)
x3 <- c(TRUE, FALSE, TRUE)
sum(x2)
sum(x2) == mean(x2)*length(x2)

#list
ds <- c(90, 85, 70, 84)
my.info <- list(name='Tom', age=60, status=TRUE, score=ds)
my.info
my.info$score

#factor
bt <- c("A", "B", "O", "AB", "A", "B", "A")
bt.new <- factor(bt)
bt.new
bt.new[8] = "AB"
bt.new
#matrix
q <- matrix(60:79, 4, 5, T)
rownames(q) <- c("a", "b", "c", "d")
colnames(q) <- c("meth", "eng", "kor", "soc", "eco")
q
