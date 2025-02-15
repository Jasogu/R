library(httr)
library(rvest)

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

# 예시 실행: 삼성전자 (코드 '005930')의 재무데이터 가져오기
tables_list <- get_fnguide("005930")
print(tables_list)

# 11:연결/전체 12:연결/연간 13:연결/분기, 14:별도/전체 15:별도/연간 16:별도/분기
tables_list[6] # CP 신용등급
tables_list[7] # Bond 신용등급
tables_list[12]

tables_list %>% View
