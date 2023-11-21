#API
serviceURL <- "https://api.odcloud.kr/api/"
operation <- "apnmOrg/v2/list"
page <- "?page=1"
perPage <- "&perPage=10"
serviceKey <- "&serviceKey=ugJS7dUCR3lsNvhaZr07p8MApFtFrWQQsAEzGXPDdKHMMuFaEsXEnpNFeLTFrTUNw0Fu2UugZZxPEmAgEa%2F%2Bfw%3D%3D"

requestUrl = paste0(serviceURL, operation, page, perPage, serviceKey)
requestUrl

library( jsonlite)
library(httr)

repos <- fromJSON(requestUrl) #연결 및 DataFrame으로의 변환
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
