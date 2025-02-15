library(httr)
library(rvest)
library(tidyverse)

#삼성전자 순차입금비율 데이터없음(음수)

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

# 예시 실행: 삼성전자 (코드 '005930')의 재무데이터 가져오기
data_snap <- get_fnguide("005930")
data_ratio <- get_fnguide_ratio("005930")

# 11:연결/전체 12:연결/연간 13:연결/분기, 14:별도/전체 15:별도/연간 16:별도/분기
data_snap[[6]] # CP 신용등급
data_snap[[7]] # Bond 신용등급


#열 이름 중복 제거 및 추정분기 제거
data_ratio <- data_ratio[[1]][c(2, 5, 8, 11, 14, 17, 22, 24, 25, 34, 40, 52, 55, 58, 62, 65, 68, 71),c(-6)]
data_ratio[1:18,1] <- c("유동비율", "당좌비율", "부채비율", "유보율", "순차입금비율",
                          "이자보상배율", "자산총계", "매출액증가율", "매출액", "EBITDA",
                          "매출총이익률", "ROA", "ROE", "ROIC", "총자산회전율",
                          "총부채회전율", "총자본회전율", "순운전자본회전율")

# 분석에 사용할 수 있게 문자형을 숫자형태로 변환
data <- data_ratio %>%
   mutate(across(2:5, ~ as.numeric(gsub(",", "", .))))

data_2023 <- data %>% select(1, 5)


data_ratio_transposed <- data_ratio %>% 
   pivot_longer(cols = -`IFRS(연결)`, names_to = "날짜", values_to = "값") %>% 
   pivot_wider(names_from = `IFRS(연결)`, values_from = 값)

to_add <- colnames(data_ratio_transposed)
new_columns <- setNames(vector("list", length(to_add)), to_add)

for (col in to_add) {
   df[[col]] <- NA
}

