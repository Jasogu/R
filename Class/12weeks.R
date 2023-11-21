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


#1