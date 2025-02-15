library(readxl)
library(tidyverse)
library(stringr)
library(readr)

df <- read_excel("credit_raw_data.xlsx", sheet = "Sheet1")
df$Bond_Mean <- 0
colnames(df)[1] <- "회사명"


convert_rating <- function(rating) {
   if (is.na(rating)) {
      return(NA)  # NA 값 처리
   }
   switch(rating,
          "AAA" = 1,
          "AA+" = 2, "AA" = 3, "AA-" = 4,
          "A+" = 5, "A" = 6, "A-" = 7,
          "BBB+" = 8, "BBB" = 9, "BBB-" = 10,
          "BB+" = 11, "BB" = 12, "BB-" = 13,
          "B+" = 14, "B" = 15, "B-" = 16,
          "CCC+" = 17, "CCC" = 18, "CCC-" = 19,
          "CC" = 20, "C" = 21, "D" = 22,
          "취소" = 23, # Cancelled 등급 추가
          NA  # 매칭되는 등급이 없을 경우 NA 반환
   )
}

# 숫자 신용등급을 문자열로 변환하는 함수 정의
convert_numeric_to_rating <- function(numeric_rating) {
   switch(as.character(numeric_rating),
          "1" = "AAA",
          "2" = "AA+", "3" = "AA", "4" = "AA-",
          "5" = "A+", "6" = "A", "7" = "A-",
          "8" = "BBB+", "9" = "BBB", "10" = "BBB-",
          "11" = "BB+", "12" = "BB", "13" = "BB-",
          "14" = "B+", "15" = "B", "16" = "B-",
          "17" = "CCC+", "18" = "CCC", "19" = "CCC-",
          "20" = "CC", "21" = "C", "22" = "D", "23" = "CANC",
          NA  # 매칭되는 등급이 없을 경우 NA 반환
   )
}

# 신용등급 비교 및 Bond_Mean 채우기
for (i in 1:nrow(df)) {
   # 각 신용등급을 숫자로 변환
   kis <- convert_rating(df$KIS_Bond[i])
   kr <- convert_rating(df$KR_Bond[i])
   nice <- convert_rating(df$NICE_Bond[i])
   
   # NA 값 처리: NA가 있을 경우 0으로 처리하여 비교에서 제외
   kis <- ifelse(is.na(kis), 0, kis)
   kr <- ifelse(is.na(kr), 0, kr)
   nice <- ifelse(is.na(nice), 0, nice)
   
   
   # 가장 높은 신용등급 찾기
   max_rating_numeric <- max(kis, kr, nice, na.rm = TRUE)
   
   # 만약 세 개의 신용등급이 모두 NA라면, Bond_Mean도 NA로 설정
   if (is.na(df$KIS_Bond[i]) && is.na(df$KR_Bond[i]) && is.na(df$NICE_Bond[i])) {
      df$Bond_Mean[i] <- NA
   } else {
      # 가장 높은 신용등급에 해당하는 문자열을 Bond_Mean에 채우기
      df$Bond_Mean[i] <- convert_numeric_to_rating(max_rating_numeric)
   }
}

df <- df %>% select(회사명, 업종, 시장, Bond_Mean)

# 중복된 회사명 확인
unique(df$회사명[duplicated(df$회사명)])

# Bond_Mean이 NA, CANC인 행 제거
df <- df[!is.na(df$Bond_Mean),]
df <- df %>% filter(Bond_Mean != "CANC")

# 보험, 금융, 증권, 부동산 업종 제외
df <- df %>% filter(!str_detect(업종, "보험|금융|증권|부동산|은행"))

#df_fs 재무상태표, df_pl 손익계산서 불러오기 및 정리
df_bs <- read_tsv("2023_bs.txt", locale = locale(encoding = "CP949"))
df_bs <- df_bs %>% select(-"...16")
df_pl <- read_tsv("2023_pl.txt", locale = locale(encoding = "CP949"))
df_pl <- df_pl %>% select(-c("...13", "...15", "...16", "...19"))

# 신용등급 엑셀표에 없는 기업들 제거
df_bs <- df_bs %>% filter(회사명 %in% df$회사명)
df_pl <- df_pl %>% filter(회사명 %in% df$회사명)

#각각의 기업 숫자
df_bs$회사명 %>% unique %>% length()
df_pl$회사명 %>% unique %>% length()
df$회사명 %>% unique %>% length()

# 재무상태표와 손익계산서 차집합(재무상태표는 있는데 손익계산서엔 없음)
setdiff(df_bs$회사명, df_pl$회사명)

# 재무상태표와 손익계산서의 교집합을 포함하지 않는 기업 제거 후 통일
fs_name <- intersect(df_bs$회사명, df_pl$회사명)
df <- df %>% filter(회사명 %in% fs_name)
df_bs <- df_bs %>% filter(회사명 %in% fs_name)
df_pl <- df_pl %>% filter(회사명 %in% fs_name)

df_bs %>% select(종목코드, 회사명, 업종명, 항목명, 당기, 전기, 전전기) %>% head
df_pl %>% select(종목코드, 회사명, 업종명, 항목명, 당기, 전기, 전전기) %>% head

df_bs$항목명 <- gsub(" ", "", df_bs$항목명)
df_pl$항목명 <- gsub(" ", "", df_pl$항목명)

df_bs$항목명 %>% table %>% .[.>100] %>% sort


# 업데이트 예정
# 유동비율, 부채비율, ROA, ROE, 자산총액, 매출액, 매출 성장률, 이자보상비율(영업이익/이자비용), 매출액영업이익률



