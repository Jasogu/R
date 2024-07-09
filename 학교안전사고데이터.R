library(dplyr)
library(ggplot2)
theme_set(theme_grey(base_family='NanumGothic'))

data <- X_2019_2023_학교안전사고_데이터_수정

data %>% names
data$사고발생시각

library(ggplot2)

ggplot(data) +
 aes(x = 지역) +
 geom_bar(fill = "#112446") +
 theme_minimal()



