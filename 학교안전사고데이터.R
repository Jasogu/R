library(dplyr)
library(ggplot2)
library(readxl)
library(stringr)
theme_set(theme_grey(base_family='NanumGothic')) #나눔고딕 폰트 사용(ggplot2 한글 깨짐)

data_2019 <- read_excel("2019 to 2023 school data.xlsx", sheet = "2019") #연도별로 '구분' 맨 앞 글자 A, B, C, D, E 순서
data_2020 <- read_excel("2019 to 2023 school data.xlsx", sheet = "2020")
data_2021 <- read_excel("2019 to 2023 school data.xlsx", sheet = "2021")
data_2022 <- read_excel("2019 to 2023 school data.xlsx", sheet = "2022")
data_2023 <- read_excel("2019 to 2023 school data.xlsx", sheet = "2023")

data_2019 %>% is.na %>% table #NA 개수 확인
data_2019[!complete.cases(data_2019),] %>% View #NA인 행 모두 추출


data <- rbind(data_2019, data_2020)
data <- rbind(data, data_2021)
data <- rbind(data, data_2022)
if ("매개물" %in% colnames(data_2023)) data_2023 <- rename(data_2023, 사고매개물 = 매개물)
data <- rbind(data, data_2023)

test <- data %>% select(구분) %>% mutate(testing = str_sub(data$구분, 1, 1)) #구분의 맨 앞글자(연도) 추출
test %>% select(testing) %>% table #잘 합쳐졌는지 개수 확인
rm(test)

#data %>% filter(str_detect(구분, "^A")) %>% mutate(year = 2019)

data$year <- 0
data$year <- ifelse(str_sub(data$구분, 1, 1) == "A", 2019,
             ifelse(str_sub(data$구분, 1, 1) == "B", 2020,
             ifelse(str_sub(data$구분, 1, 1) == "C", 2021,
             ifelse(str_sub(data$구분, 1, 1) == "D", 2022,
             ifelse(str_sub(data$구분, 1, 1) == "E", 2023,
                    0)))))





data %>% head

   
data_2019 %>% dim
data_2019 %>% str




data_2019$연도 <- 2019
ggplot(data) +
 aes(x = 사고시간) +
 geom_bar(fill = "#112446")

test <- data %>% select(구분, 학교급, 지역, 설립유형, 사고자구분, 사고자성별, 사고자학년, 사고발생일, 사고발생요일,
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

