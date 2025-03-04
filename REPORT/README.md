# 개인 프로젝트

## 1. 신용등급 예측 모델

코스피, 코스닥에 상장된 기업들의 재무데이터를 학습하여 신용등급을 예측하는 학슴 알고리즘 만들기


FnGuide 에서 제공하는 신용등급 데이터를 토대로 분석
[신용등급 데이터](https://comp.fnguide.com/SVO2/ASP/SVD_CreditScore.asp?pGB=1&gicode=A196170&cID=&MenuYn=Y&ReportGB=&NewMenuID=501&stkGb=701)

아래 코드를 통해 데이터 전처리(크롤링 생략)

<details>
<summary>소스코드 접기/펼치기</summary>

for (i in 1:nrow(df)) {
   # 각 신용등급을 숫자로 변환
   kis <- convert_rating(df$KIS_Bond[i])
   kr <- convert_rating(df$KR_Bond[i])
   nice <- convert_rating(df$NICE_Bond[i])
   
   # NA 값 처리: NA가 있을 경우 0으로 처리하여 비교에서 제외
   kis <- ifelse(is.na(kis), 0, kis)
   kr <- ifelse(is.na(kr), 0, kr)
   nice <- ifelse(is.na(nice), 0, nice)
   
   
   # 가장 낮은 신용등급 찾기
   max_rating_numeric <- max(kis, kr, nice, na.rm = TRUE)
   
   # 만약 세 개의 신용등급이 모두 NA라면, Bond_Mean도 NA로 설정
   if (is.na(df$KIS_Bond[i]) && is.na(df$KR_Bond[i]) && is.na(df$NICE_Bond[i])) {
      df$Bond_Mean[i] <- NA
   } else {
      # 가장 낮은 신용등급에 해당하는 문자열을 Bond_Mean에 채우기
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
</details> 


### 전처리 설명
1. 3개 신용평가사 중 가장 최하 등급을 기준으로 분석
ex1, 각각 A, A, BBB+ 이면 BBB+로 분석함.
ex2, KIS에서 AAA, KR에서 AA+, NICE에서 평가하지 않았다면 AA+로 분석함.

1. 신용등급 데이터에서 중복된 회사 제거
1. 신용등급이 취소된 경우(CNAC, 취소) 분석에서 제거
1. 분석에 필요한 재무데이터를 추가(웹 크롤링 후 전처리)
1. 부동산 펀드, 은행 등 재무데이터가 일반적이지 않은 기업 제거

[전처리 데이터](https://github.com/Jasogu/R/blob/main/REPORT/code/data/credit%20data.xlsx)





# 업데이트 예정

<details>
<summary>접기/펼치기</summary>


</details> 
