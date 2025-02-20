library(readxl)
library(tidyverse)
library(stringr)
library(readr)
library(httr)
library(rvest)

# 신용등급 데이터 FnGuide : https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701

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


#https://comp.fnguide.com/SVO2/ASP/SVD_FinanceRatio.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=104&stkGb=701
get_fnguide_ratio <- function(code) {
   # 파라미터 목록 작성
   params <- list(
      pGB = 1,
      gicode = sprintf("A%s", code),  # "A"와 입력받은 code 결합
      cID = "",
      MenuYn = "Y",
      ReportGB = "",
      NewMenuID = 104,
      stkGb = 701
   )
   
   # 기본 URL 지정
   base_url <- "https://comp.fnguide.com/SVO2/ASP/SVD_FinanceRatio.asp"
   
   # httr의 modify_url()로 파라미터가 붙은 최종 URL 생성
   url <- modify_url(base_url, query = params)
   
   # GET 요청 시 User-Agent를 지정하면 서버 접근에 도움이 될 수 있음
   response <- GET(url, user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)"))
   
   # HTML 파싱
   page <- read_html(response)
   
   # 테이블 추출 (fill = TRUE로 누락된 셀 채움)
   tables <- html_table(page, fill = TRUE)
   
   return(tables)
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




# 신용등급 엑셀 전처리 시작-----------------
df <- df %>% select(회사명, 업종, 시장, Bond_Mean)

# Bond_Mean이 NA, CANC인 행 제거
df <- df[!is.na(df$Bond_Mean),]
df <- df %>% filter(Bond_Mean != "CANC")

# 중복된 회사명 확인
multiple <- unique(df$회사명[duplicated(df$회사명)])
multiple_names <- data.frame()
for (i in 1:length(multiple)) {
   multiple_names <- rbind(multiple_names,df %>% filter(회사명 == multiple[i]))
}
multiple_names

#중복된 회사 제거
df <- df[-which(df$회사명 == multiple_names$회사명[1])[2],]
df <- df[-which(df$회사명 == multiple_names$회사명[3])[2],]

#중복된 회사 제거된 것 확인
unique(df$회사명[duplicated(df$회사명)])

# df에 종목코드, 계정과목 추가
df <- cbind(종목코드 = NA, df)
df$종목코드 <- firm_names$종목코드[match(df$회사명, firm_names$종목명)]
new_columns <- c("유동비율", "당좌비율", "부채비율", "유보율", "순차입금비율",
                 "이자보상배율", "자산총계", "매출액증가율", "매출액", "EBITDA",
                 "매출총이익률", "ROA", "ROE", "ROIC", "총자산회전율",
                 "총부채회전율", "총자본회전율", "순운전자본회전율")
df <- cbind(df, setNames(data.frame(matrix(NA, nrow = nrow(df), ncol = length(new_columns))), new_columns))
# 신용등급 엑셀 전처리 끝------------------------








#업데이트 예정, R markdown 제작 예정. df 계정과목 데이터 채우는 거 반복문 추가해야 함

