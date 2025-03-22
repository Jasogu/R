library(readxl)
library(MASS)
library(tidyverse)
library(stringr)
library(readr)
library(httr)
library(rvest)
library(randomForest)
library(gbm) #gradient boost
library(nnet) #ann
library(e1071) #svd
library(caret)

select <- dplyr::select


# 분석 시 백분율은 0~1 사이로 전환

# 신용등급 데이터 FnGuide : https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701

df <- read_excel("credit_raw_data.xlsx", sheet = "Sheet1")
df$Bond_Mean <- 0
colnames(df)[1] <- "회사명"

# 함수선언 ----
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
# 함수선언 종료



# 종목코드 추출 ------
gen_otp_url <- 'http://data.krx.co.kr/comm/fileDn/GenerateOTP/generate.cmd'
gen_otp_data <- list(
   locale = 'ko_KR',
   mktId = 'ALL',
   trdDd = '20250220',
   share = '1',
   money = '1',
   csvxls_isNo = 'false',
   name = 'fileDown',
   url = 'dbms/MDC/STAT/standard/MDCSTAT01501',
   format = 'xlsx'  # 파일 형식을 xlsx로 지정
)

# 2. OTP 생성 요청 및 코드 추출
otp <- POST(gen_otp_url, query = gen_otp_data) %>%
   read_html() %>%
   html_text()

cat("OTP Code:", otp, "\n")  # OTP 코드 확인

# 3. 실제 데이터 다운로드 URL
down_url <- 'http://data.krx.co.kr/comm/fileDn/download_excel/download.cmd'

# 4. 다운로드 요청 및 파일 저장
down_data <- list(
   code = otp  # OTP 코드 전달
)

# 5. HTTP 요청 헤더 설정 (User-Agent, Referer)
headers = c(
   `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36",
   `Referer` = "http://data.krx.co.kr/contents/MDC/STAT/standard/MDCSTAT01501.jsp"  # 변경된 URL
)

# 원하는 파일 이름 지정
custom_file_name <- "firm_names.xlsx"

# 파일 다운로드 부분 수정
response <- POST(down_url, query = down_data, add_headers(.headers=headers),
                 write_disk(custom_file_name, overwrite = TRUE))

firm_names <- read_excel("firm_names.xlsx", sheet = "Sheet1")
file.remove('firm_names.xlsx')
# 종목코드 추출 종료




# 신용등급 비교 및 Bond_Mean 채우기----
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

# 신용등급 엑셀 전처리
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



# 반복문 -----
# Fnguide 에서 재무비율, 재무데이터 크롤링 후 df에 대입
for (i in 1:nrow(df)){
   suppressWarnings({  # 경고 메시지 억제 시작
      firm_raw <- get_fnguide_ratio(df[i,1])
      if (nrow(firm_raw[[1]]) != 73) {
         cat("Warning: Insufficient data for company", df[i,1], ". Skipping.\n")
         next  # 다음 반복으로 넘어감
      }
      firm <- firm_raw[[1]][c(2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 22, 24, 25, 26, 34, 40, 41, 42, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73),]
      firm <- firm %>% select(-6) %>% mutate(across(2:5, ~ as.numeric(gsub(",", "", .))))
      firm[c(1, 2, 5, 8, 11, 14, 17, 18, 19, 21, 22, 25, 28, 31, 34, 37, 40, 43), 1] <- c("유동비율", "당좌비율", "부채비율", "유보율", "순차입금비율",
                                                                                                  "이자보상배율", "자산총계", "매출액증가율", "매출액", "EBITDA",
                                                                                                  "매출총이익률", "ROA", "ROE", "ROIC", "총자산회전율",
                                                                                                  "총부채회전율", "총자본회전율", "순운전자본회전율")
      
      firm <- firm %>% mutate(across(where(is.numeric), ~ifelse(. == 0, 0.01, .))) # 0인 값은 0.01로 바꿈(Inf 문제)
      finance_100 <- which(firm[, 1] %>% pull %in% c("당좌비율", "부채비율", "유보율", "순차입금비율", "매출총이익율", "ROA", "ROE", "ROIC"))
      finance_1 <- which(firm[, 1] %>% pull %in% c("이자보상배율", "총자산회전율", "총부채회전율", "총자본회전율", "순운전자본회전율"))
      finance_sales <- which(firm[, 1] %>% pull %in% "매출액증가율") # ((매출액 / 매출액(전년)) -1)
      
      for (a in finance_100){
         firm[a, -1] <- (firm[a+1, -1] / firm[a+2, -1])
      }
      for (b in finance_1){
         firm[b, -1] <- (firm[b+1, -1] / firm[b+2, -1])
      }
      firm[finance_sales, -1] <- ((firm[finance_sales+1, -1] / firm[finance_sales+2, -1])-1)
      firm <- firm[which(firm$`IFRS(연결)` %in% c("유동비율", "당좌비율", "부채비율", "유보율", "순차입금비율",
                                                "이자보상배율", "자산총계", "매출액증가율", "매출액", "EBITDA",
                                                "매출총이익률", "ROA", "ROE", "ROIC", "총자산회전율",
                                                "총부채회전율", "총자본회전율", "순운전자본회전율")), ][-12, ]
      
      # df에 데이터 집어넣기
      for (k in 1:18){
         df[i, k+5] <- firm[k, 5] # 6부터 시작(유동비율)
      }
      Sys.sleep(0.1)  # 0.1초 동안 대기
   }) # 경고 메시지 억제 종료
}

# 금융, 보험, 부동산 펀드 등 제외. OCI 제외(신규)
df[!complete.cases(df), ] %>% head # NA값들 확인
df <- df[complete.cases(df), ]

writexl::write_xlsx(df, "data/credit data.xlsx")


