#11.14

library(stringr)
v1 <- c('aa', 'ba', 'ccb', 'Ab', 'Bbc', 'aBa')

#정규표현식
v1[str_detect(v1,'a')] # 순서 상관없이 a가 들어가는 것
str_detect(v1,'^a')  #'a'로 시작하는 원소
v1[str_detect(v1,'^a')] #'a'로 시작하는 원소 출력
v1[str_detect(v1,'^[aA]')] #대소 상관 없이 'a'로 시작하는 원소 출력
v1[str_detect(v1,'^[aAbB]')] #대소 상관 없이 'a' 혹은 'b'로 시작하는 원소 출력
v1[str_detect(v1,'^[aA][bB]')] #대소 상관없이 'a'로 시작, 두 번째로 대소 상관없이 'b'로 시작하는 원소 출력
v1[str_detect(v1, '[B][aA]$')] #'B' 다음 대소 상관없이 'a'로 끝나는 원소 출력

str_length(v1)
#########
str_replace('apple','p','*')

str_replace('apple','p','**')

str_replace_all('apple','p','*')

v4 <- c('1,100', '2,300', '3,900')
v4 <- str_replace(v4,',','')
v4
as.numeric(v4) + 100

v4 <- c('1,100,200', '1,002,300', '1,003,900')
v4 <- str_replace_all(v4,',','')
v4
as.numeric(v4) + 100

#문자열 분리, 추출
animal <- "pig/dog/cat"
a <- str_split(animal, '/')
a

a <- str_sub(animal, start = 2, end = 5)
a

animal <- "pig/dog/cat  "
a <- str_trim(animal)
b <- str_trim(animal, side = "right")
b

#실습
library(stringr)


table(iris$Species[str_detect(iris$Species, 'a')])

table(str_replace(iris$Species, 'a', '*'))

table(iris$Species[str_detect(iris$Species, '[ic]')])

table(str_replace(iris$Species, '[ic]', '??'))

time <- date()
time <- str_replace(time, ':', '시 ')
time <- str_replace(time, ":", '분 ')
time <- str_replace(time, '14', '14일')
time <- str_replace(time, '2023', '2023년')
time
