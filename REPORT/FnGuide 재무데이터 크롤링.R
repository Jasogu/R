library(readxl)
library(tidyverse)
library(stringr)
library(readr)
library(httr)
library(rvest)


#FnGuide SnapShot 크롤링
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

#Fnguide 재무비율 크롤링
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



# 예시 실행: 삼성전자 (코드 '005930')의 SnapShot(신용등급, 재무데이터) 가져오기
data_snap_raw <- get_fnguide("005930")

# 11:연결/전체 12:연결/연간 13:연결/분기, 14:별도/전체 15:별도/연간 16:별도/분기
data_snap_raw[[6]] # CP 신용등급
data_snap_raw[[7]] # Bond 신용등급


data_snap <- data_snap_raw[[12]] %>%
   `colnames<-`(.[1,]) %>%  # 첫 번째 행을 열 이름으로 설정
   .[-1,] # 첫 번째 행 제거 (이미 열 이름으로 사용됨)

# 빈 문자열을 NA로 변환
data_snap <- data_snap %>% 
   mutate(across(everything(), ~ ifelse(. == "", NA, .)))

data_snap <- data_snap %>% mutate(across(-1, ~ as.numeric(gsub(",", "", .))))  # 첫 번째 열을 제외한 모든 열에 대해 숫자 변환

# 추정치 년도 열 이름 변경
colnames(data_snap)[1] <- colnames(data_snap_raw[[9]])[2]
colnames(data_snap)[7:ncol(data_snap)] <- c(colnames(data_snap)[7] %>% substr(nchar(colnames(data_snap)[7])-9, nchar(colnames(data_snap)[7])),
                                            colnames(data_snap)[8] %>% substr(nchar(colnames(data_snap)[8])-9, nchar(colnames(data_snap)[8])),
                                            colnames(data_snap)[9] %>% substr(nchar(colnames(data_snap)[9])-9, nchar(colnames(data_snap)[9])))

print(data_snap)
