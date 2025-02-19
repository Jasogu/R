library(readxl)
library(tidyverse)
library(stringr)
library(readr)
library(httr)
library(rvest)

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


#https://comp.fnguide.com/SVO2/ASP/SVD_main.asp?pGB=1&gicode=A005930&cID=&MenuYn=Y&ReportGB=&NewMenuID=11&stkGb=&strResearchYN=
get_fnguide <- function(code) {
   # 파라미터 목록 작성
   params <- list(
      pGB = 1,
      gicode = sprintf("A%s", code),  # "A"와 입력받은 code 결합
      cID = "",
      MenuYn = "Y",
      ReportGB = "",
      NewMenuID = 101,
      stkGb = 701
   )
   
   # 기본 URL 지정
   base_url <- "http://comp.fnguide.com/SVO2/ASP/SVD_Main.asp"
   
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




# 전처리 시작-----------------
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



# 예시 실행: 삼성전자 (코드 '005930')의 재무데이터 가져오기
data_snap_raw <- get_fnguide("005930")
data_ratio_raw <- get_fnguide_ratio("005930")

# 11:연결/전체 12:연결/연간 13:연결/분기, 14:별도/전체 15:별도/연간 16:별도/분기
data_snap_raw[[6]] # CP 신용등급
data_snap_raw[[7]] # Bond 신용등급

#열 이름 중복 제거 및 추정분기 제거, 계정과목 선택 후 이름변경
data_ratio <- data_ratio_raw[[1]][c(2, 5, 8, 11, 14, 17, 22, 24, 25, 34, 40, 52, 55, 58, 62, 65, 68, 71),c(-6)]
data_ratio[1:18,1] <- c("유동비율", "당좌비율", "부채비율", "유보율", "순차입금비율",
                        "이자보상배율", "자산총계", "매출액증가율", "매출액", "EBITDA",
                        "매출총이익률", "ROA", "ROE", "ROIC", "총자산회전율",
                        "총부채회전율", "총자본회전율", "순운전자본회전율")

# 분석에 사용할 수 있게 문자형을 숫자형태로 변환
data_ratio <- data_ratio %>%
   mutate(across(2:5, ~ as.numeric(gsub(",", "", .))))


# 순차입금비율이 음수일 경우 NA로 되는 경우(삼성전자), 식을 직접 대입해 음수로 표기. (순차입부채/자본총계)*100
borrowings <- data_ratio_raw[[1]][c(15, 21),-6]
borrowings <- borrowings %>%
   mutate(across(2:5, ~ as.numeric(gsub(",", "", .))))
borrowings_ratio <- (borrowings[1,-1] / borrowings[2,-1])*100
borrowings_ratio[,1]

data <- data_ratio %>%
   mutate(
      `2020/12` = replace_na(`2020/12`, borrowings_ratio[,1]),
      `2021/12` = replace_na(`2021/12`, borrowings_ratio[,2]),
      `2022/12` = replace_na(`2022/12`, borrowings_ratio[,3]),
      `2023/12` = replace_na(`2023/12`, borrowings_ratio[,4])
   )

print(data)

#업데이트 예정






# 행렬 전환
data_ratio_transposed <- data_ratio %>% 
   pivot_longer(cols = -`IFRS(연결)`, names_to = "날짜", values_to = "값") %>% 
   pivot_wider(names_from = `IFRS(연결)`, values_from = 값)

to_add <- colnames(data_ratio_transposed)
new_columns <- setNames(vector("list", length(to_add)), to_add)

# df에 열변수에 계정과목 추가
for (col in to_add) {
   df[[col]] <- NA
}

df %>% head



#업데이트 예정.삼성전자 순차입금비율 음수라서 데이터 없는 것 수정해야 함 + df에 열변수 18개 추가 후 데이터 크롤링해서 데이터 채우는 거 반복문 추가해야 함


