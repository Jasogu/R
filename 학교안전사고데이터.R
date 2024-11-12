library(dplyr)
library(ggplot2)
theme_set(theme_grey(base_family='NanumGothic')) #나눔고딕 폰트 사용(ggplot2 한글 깨짐)

data <- X_2019_2023_학교안전사고_데이터_수정

data %>% names
data$사고발생시각


ggplot(data) +
 aes(x = 사고시간) +
 geom_bar(fill = "#112446")

test <- data %>% select(학교급, 지역, 설립유형, 사고자구분, 사고자성별, 사고자학년, 사고발생일, 사고발생요일,
                        사고발생시각, 사고시간, 사고장소, 사고부위, 사고형태, 사고당시활동, 매개물)
test %>% View()

data_table <- data$사고자구분 %>% table
data_table/nrow(data) #사고 발생의 97%가 일반학생

ggplot(data) +
  aes(x = 사고당시활동) +
  geom_bar(fill = "#112446")

data$사고자성별 %>% table
table(data$사고자성별)/nrow(data)

girl <- data %>% select(사고당시활동, 사고자성별) %>% filter(사고자성별=="여") %>% table
girl/sum(girl)

boy <- data %>% select(사고당시활동, 사고자성별) %>% filter(사고자성별=="남") %>% table
boy/sum(boy)


ggplot(data) +
  aes(x = 사고시간) +
  geom_bar(fill = "#112446")

