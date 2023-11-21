library(ggplot2)

g1 <- ggplot(labor_data) +
  aes(x = 시점, y = `* 관리자·전문가(1,2)`) +
  labs(y = "단위 : 천명", title = "* 관리자·전문가(1,2)") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`* 관리자·전문가(1,2)`)-100, NA)) +
"""
더미변수
eviews : ls gpi c gps recession81 gps_dummy
eviews : ls gpi c gps recession81

계절변동
genr error = sales - fitted_sales


install.packages("car")
library(car)

head(Prestige)
newdata <- Prestige[,c(1:4)]

edu <- lm(income~education, data=newdata)

mod1 <- lm(income ~ education + prestige + women, data = newdata)
summary(mod1)
plot(income ~ education, data=newdata)
abline(lm(income~education, data=newdata))
summary(edu)
"""

model <- lm(wage~work + edu + female + old, data=wage)
model <- lm(wage~old, data=wage)

summary(model)
plot(wage ~ old, data=wage)
abline(model)


point <- as.numeric(wage$edu)
ggplot(wage) +
  aes(x = old, y = wage) +
  geom_point(size = 5, shape = point) +
  theme_minimal()


