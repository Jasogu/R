library(ggplot2)
library(gridExtra)
library(scatterplot3d)
library(rgl)

boxplot(final_data$wage~final_data$edu, data=final_data)
plot(final_data$wage~final_data$old, data=final_data)



model <- lm(wage~experience + edu + female + old, data=final_data)

summary(model)
plot(wage ~ old, data=final_data)
abline(model)


fem = data.frame()
man = data.frame()
for (i in 1:nrow(final_data)) {
  if (final_data$female[i] == 1) {
    fem <- rbind(fem, final_data[i, ])
  } else {
    man <- rbind(man, final_data[i, ])
  }
}

#학력, 평균 근속년수, 나이. 임금

#ggpolot 화면분할
grid.arrange(a, b, nrow =1, ncol = 2)

#평균 근속년수와 임금
a <- ggplot(fem) +
  aes(x = experience, y = wage, fill = edu, group = edu) +
  geom_point(size = 5, pch = fem$female*3+1 +20) +
  geom_line() +
  ggtitle("여성 - 평균 근속년수와 임금") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20)) 

b <- ggplot(man) +
  aes(x = experience, y = wage, fill = edu, group = edu) +
  geom_point(size = 5, pch = man$female*3+1 +20) +
  geom_line() +
  theme_minimal() +
  ggtitle("남성 - 평균 근속년수와 임금") +
  theme(plot.title = element_text(size = 20))

grid.arrange(a, b, nrow =1, ncol = 2)


#나이와 임금
c <- ggplot(fem) +
  aes(x = old, y = wage, fill = edu, group = edu) +
  geom_point(size = 5, pch = fem$female*3+1 +20) +
  geom_line() +
  ggtitle("여성 - 나이와 임금") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))

d <- ggplot(man) +
  aes(x = old, y = wage, fill = edu, group = edu) +
  geom_point(size = 5, pch = man$female*3+1 +20) +
  geom_line() +
  ggtitle("남성 - 나이와 임금") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))
  
grid.arrange(c, d, nrow =1, ncol = 2)

#학력과 임금 boxplot
par(mfrow = c(1, 2))
a <- boxplot(fem$wage~fem$edu, data=fem, main = "여성 - 임금과 학력의 관계", cex.main = 2, ylim = c(1500, 7000))
b <- boxplot(man$wage~man$edu, data=man, main = "남성 - 임금과 학력의 관계", cex.main = 2, ylim = c(1500, 7000))


#평균 근속년수과 나이
e <- ggplot(fem) +
  aes(x = old, y = experience, fill = edu, group = edu) +
  geom_point(size = 5, pch = fem$female*3+1 +20) +
  geom_line() +
  ggtitle("여성 - 나이와 평균 근속년수") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))

f <- ggplot(man) +
  aes(x = old, y = experience, fill = edu, group = edu) +
  geom_point(size = 5, pch = man$female*3+1 +20) +
  geom_line() +
  ggtitle("남성 - 나이와 평균 근속년수") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))

grid.arrange(e, f, nrow =1, ncol = 2)

cor(fem$old, fem$experience)
cor(man$old, man$experience)

test_fem <- fem[,c(3, 2, 8 )]
test_man <- man[, c(3, 2, 8)]

plot3d(test_fem, size = 7)
plot3d(test_man, size = 5)

