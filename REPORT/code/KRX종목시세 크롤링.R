library(httr)
library(rvest)
library(readr)
library(dplyr)

# KRX정보데이터시스템 - 기본통계 - 주식 - 종목시세 - 전종목 시세
# http://data.krx.co.kr/contents/MDC/MDI/mdiLoader/index.cmd?menuId=MDC0201

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

# 다운로드 성공 여부 확인
if (response$status_code == 200) {
   cat("KRX Excel 파일이 성공적으로 다운로드되었습니다:", custom_file_name, "\n")
} else {
   cat("KRX Excel 파일 다운로드 실패. HTTP 상태 코드:", response$status_code, "\n")
}

firm_names <- read_excel("firm_names.xlsx", sheet = "Sheet1")
file.remove('firm_names.xlsx')
