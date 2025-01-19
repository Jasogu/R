#install.packages("gridExtra")
#install.packages("scatterplot3d")
#install.packages("rgl")
#font_import(pattern = "MalgunGothic")

library(dplyr)
library(ggplot2)
library(gridExtra)
library(scatterplot3d)
library(rgl)
library(readxl)


final_data <- read_excel("~/R/REPORT/Econometrics report/final_data.xlsx")

model <- lm(wage~experience + edu + female + old, data=final_data)
par(mfrow = c(2, 2))
plot(model)
summary(model)

plot(wage ~ old, data=final_data)
abline(lm(wage ~ old, data=final_data))
lm(wage ~ old, data=final_data) %>% summary

model <- lm(wage~experience + old + female, data=final_data)
model %>% summary
par(mfrow = c(2, 2))
plot(model)


fem = data.frame()
man = data.frame()
for (i in 1:nrow(final_data)) {
  if (final_data$female[i] == 1) {
    fem <- rbind(fem, final_data[i, ])
  } else {
    man <- rbind(man, final_data[i, ])
  }
}

fem$edu <- fem$edu %>% as.factor
man$edu <- man$edu %>% as.factor

#학력, 평균 근속년수, 나이. 임금
#평균 근속년수와 임금
a <- ggplot(fem) +
  aes(x = experience, y = wage, color = edu, group = edu) +
  geom_point(size = 5, shape = "triangle") +
  geom_line() +
  xlim(0, 15) +
  ylim(1500, 6800) +
  ggtitle("여성 - 평균 근속년수와 임금") +
  xlab("평균근속년수") +
  ylab("임금") +
  annotate(geom="text", x=9, y=4200, label="대졸여성", size=6) +
  annotate(geom="text", x=9, y=2800, label="고졸여성", size=6) +
  annotate(geom="text", x=8, y=2400, label="중졸여성", size=6) +
  annotate(geom="text", x=8, y=2000, label="중졸미만여성", size=6) +
  scale_color_discrete(name = "학력", labels = c("중졸미만여성", "중졸여성", "고졸여성", "대졸여성")) + #범례 제목이랑 항목이름 바꾸기. factor여야 범례가 제대로 설정됨
  guides(colour = guide_legend(reverse = TRUE)) + #범례항목 순서 거꾸로 정렬
  theme_minimal() +
  theme(plot.title = element_text(size = 20),
        axis.text=element_text(size=12),
        axis.title.x = element_text(size = 20, face = "bold"),
        axis.title.y = element_text(size = 20))

b <- ggplot(man) +
  aes(x = experience, y = wage, group = edu, color = edu) +
  geom_point(size = 5, shape = "circle") +
  geom_line() +
  xlab("평균근속년수") +
  ylab("임금") +
  xlim(0, 15) +
  ylim(1500, 6800) +
  ggtitle("남성 - 평균 근속년수와 임금") +
  scale_color_discrete(name = "학력", labels = c("중졸미만남성", "중졸남성", "고졸남성", "대졸남성")) +
  guides(colour = guide_legend(reverse = TRUE)) +
  theme_minimal() +
  theme(plot.title = element_text(size = 20),
        axis.text=element_text(size=12),
        axis.title.x = element_text(size = 20, face = "bold"),
        axis.title.y = element_text(size = 20))
   
#ggpolot 화면분할
grid.arrange(a, b, nrow =1, ncol = 2)


#나이와 임금
c <- ggplot(fem) +
  aes(x = old, y = wage, color = edu, group = edu) +
  geom_point(size = 5, shape = "triangle") +
  geom_line() +
  xlim(20, 60) +
  ylim(1500, 6800) +
  ggtitle("여성 - 나이와 임금") +
  scale_color_discrete(name = "학력", labels = c("중졸미만여성", "중졸여성", "고졸여성", "대졸여성")) + #범례 제목이랑 항목이름 바꾸기. factor여야 범례가 제대로 설정됨
  guides(colour = guide_legend(reverse = TRUE)) + #범례항목 순서 거꾸로 정렬
  xlab("나이") +
  ylab("임금") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20),
         axis.text=element_text(size=12),
         axis.title.x = element_text(size = 20, face = "bold"),
         axis.title.y = element_text(size = 20))

d <- ggplot(man) +
  aes(x = old, y = wage, color = edu, group = edu) +
  geom_point(size = 5, shape = "circle") +
  geom_line() +
  xlim(20, 60) +
  ylim(1500, 6800) +
  ggtitle("남성 - 나이와 임금") +
  scale_color_discrete(name = "학력", labels = c("중졸미만남성", "중졸남성", "고졸남성", "대졸남성")) +
  guides(colour = guide_legend(reverse = TRUE)) +
  theme_minimal() +
  xlab("나이") +
  ylab("임금") +
  theme(plot.title = element_text(size = 20),
         axis.text=element_text(size=12),
         axis.title.x = element_text(size = 20, face = "bold"),
         axis.title.y = element_text(size = 20))

grid.arrange(c, d, nrow =1, ncol = 2)

#학력과 임금 boxplot
par(mfrow = c(1, 2))
a <- boxplot(fem$wage~fem$edu, data=fem, main = "여성 - 임금과 학력의 관계", cex.main = 2, ylim = c(1500, 7000), names = c("중졸미만","중졸", "고졸", "대졸이상"),
             xlab = "학력", ylab = "임금", cex.axis=1.5, cex.lab=2)

b <- boxplot(man$wage~man$edu, data=man, main = "남성 - 임금과 학력의 관계", cex.main = 2, ylim = c(1500, 7000), names = c("중졸미만","중졸", "고졸", "대졸이상"),
             xlab = "학력", ylab = "임금", cex.lab = 2, cex.axis=1.5)


#평균 근속년수과 나이
e <- ggplot(fem) +
  aes(x = old, y = experience, color = edu, group = edu) +
  geom_point(size = 5, shape = "triangle") +
  geom_line() +
  xlim(20, 60) +
  ylim(0, 15) +
  ggtitle("여성 - 나이와 평균 근속년수") +
  scale_color_discrete(name = "학력", labels = c("중졸미만여성", "중졸여성", "고졸여성", "대졸여성")) +
  guides(colour = guide_legend(reverse = TRUE)) +
  theme_minimal() +
  xlab("나이") +
  ylab("평균 근속년수") +
  theme(plot.title = element_text(size = 20),
         axis.text=element_text(size=12),
         axis.title.x = element_text(size = 20, face = "bold"),
         axis.title.y = element_text(size = 20))

f <- ggplot(man) +
  aes(x = old, y = experience, color = edu, group = edu) +
  geom_point(size = 5, shape = "circle") +
  geom_line() +
  xlim(20, 60) +
  ylim(0, 15) +
  ggtitle("남성 - 나이와 평균 근속년수") +
  scale_color_discrete(name = "학력", labels = c("중졸미만남성", "중졸남성", "고졸남성", "대졸남성")) +
  guides(colour = guide_legend(reverse = TRUE)) +
  xlab("나이") +
  ylab("평균 근속년수") +
  theme(plot.title = element_text(size = 20),
         axis.text=element_text(size=12),
         axis.title.x = element_text(size = 20, face = "bold"),
         axis.title.y = element_text(size = 20)) +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))

grid.arrange(e, f, nrow =1, ncol = 2)

cor(fem$old, fem$experience)
cor(man$old, man$experience)

test_fem <- fem[,c(3, 2, 8 )] #edu, wage, experience 추출
test_man <- man[, c(3, 2, 8)]


fem$edu <- fem$edu %>% as.factor()

fem_j <- fem[fem$edu == 9,c(3, 2, 8)]
fem_h <- fem[fem$edu == 12,c(3, 2, 8)]
fem_c <- fem[fem$edu == 14,c(3, 2, 8)]
fem_u <- fem[fem$edu == 16,c(3, 2, 8)]
man_j <- man[man$edu == 9,c(3, 2, 8)]
man_h <- man[man$edu == 12,c(3, 2, 8)]
man_c <- man[man$edu == 14,c(3, 2, 8)]
man_u <- man[man$edu == 16,c(3, 2, 8)]


d3 = scatterplot3d(fem$edu, fem$wage, fem$experience, type = 'h', color = 'red', main = '여성 - 임금, 학력, 평균 근속년수',
                   xlab = "학력", ylab = "임금", zlab = "평균 근속년수",
                   cex.lab = 1.5,
                   x.ticklabs = c("중졸미만", "","중졸", "","고졸", "","대졸이상"))
d3$points3d(fem_j$edu, fem_j$wage, fem_j$experience, bg='orange', pch=21, cex=2)
d3$points3d(fem_j$edu, fem_j$wage, fem_j$experience, type = 'l', lwd = 2)
d3$points3d(fem_h$edu, fem_h$wage, fem_h$experience, bg='blue', pch=21, cex=2)
d3$points3d(fem_h$edu, fem_h$wage, fem_h$experience, type='l', lwd = 2)
d3$points3d(fem_c$edu, fem_c$wage, fem_c$experience, bg='green', pch=21, cex=2) 
d3$points3d(fem_c$edu, fem_c$wage, fem_c$experience, type = 'l', lwd = 2) 
d3$points3d(fem_u$edu, fem_u$wage, fem_u$experience, bg='black', pch=21, cex=2)
d3$points3d(fem_u$edu, fem_u$wage, fem_u$experience, type = 'l', lwd = 2)

d4 = scatterplot3d(man$edu, man$wage, man$experience, type ='h', color = "blue", main = '남성 - 임금, 학력, 평균 근속년수',
                   xlab = "학력", ylab = "임금", zlab = "평균 근속년수",
                   cex.lab = 1.5,
                   x.ticklabs = c("중졸미만", "","중졸", "","고졸", "", "대졸이상"))
d4$points3d(man_j$edu, man_j$wage, man_j$experience, bg='orange', pch=21, cex=2)
d4$points3d(man_j$edu, man_j$wage, man_j$experience, type = 'l', lwd = 2)
d4$points3d(man_h$edu, man_h$wage, man_h$experience, bg='blue', pch=21, cex=2)
d4$points3d(man_h$edu, man_h$wage, man_h$experience, type = 'l', lwd = 2)
d4$points3d(man_c$edu, man_c$wage, man_c$experience, bg='green', pch=21, cex=2)
d4$points3d(man_c$edu, man_c$wage, man_c$experience, type = 'l', lwd = 2)
d4$points3d(man_u$edu, man_u$wage, man_u$experience, bg='black', pch=21, cex=2)
d4$points3d(man_u$edu, man_u$wage, man_u$experience, type = 'l', lwd = 2)


plot3d(test_fem, size = 10, col = c(rep('orange', 7), rep('blue', 7), rep('steelblue', 7), rep('black', 7)))
plot3d(test_man, size = 10, col = c(rep('orange', 7), rep('blue', 7), rep('steelblue', 7), rep('black', 7)))

c(rep('red', nrow(test_fem)), rep('blue', nrow(test_fem)), rep('green', nrow(test_fem)))

# ls wage c experience edu_c edu_h edu_u experience*edu_c*female experience*edu_h*female experience*edu_u*female experience*edu_c experience*edu_h experience*edu_u
