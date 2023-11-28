#API
serviceURL <- "https://api.odcloud.kr/api/" # api base url
operation <- "apnmOrg/v2/list"
page <- "?page=1" # ?로 시작해서 이후에 덧붙일 때 마다 &를 붙임
perPage <- "&perPage=10" #한 페이지에서 볼 데이터 수
serviceKey <- "&serviceKey=ugJS7dUCR3lsNvhaZr07p8MApFtFrWQQsAEzGXPDdKHMMuFaEsXEnpNFeLTFrTUNw0Fu2UugZZxPEmAgEa%2F%2Bfw%3D%3D" # &servicekey=내api값

requestUrl = paste0(serviceURL, operation, page, perPage, serviceKey) # paste0 : 공백없이 문자열 합. 0빼면 띄어쓰기 넣고 문자열 더함
requestUrl

library( jsonlite)
library(httr)

repos <- fromJSON(requestUrl) #연결 및 DataFrame으로의 변환, JSON 타입만 가능. XML은 GET코드 사용
repos <- data.frame(repos)
str(repos)
names(repos)

#군집화
mydata <- iris[,1:4] # 데이터 준비

fit <- kmeans(x=mydata, centers=3)
fit
fit$cluster # 각 데이터에 대한 군집 번호
fit$centers # 각 군집의 중심점 좌표

# 차원 축소 후 군집 시각화
library(cluster)
clusplot(mydata, fit$cluster, color=TRUE, shade=TRUE,
         labels=2, lines=0)
# 데이터에서 두 번째 군집의 데이터만 추출
subset(mydata, fit$cluster==2)
