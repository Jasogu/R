library(ggplot2)

if (!require('tqk')) {
  remotes::install_github("mrchypark/tqk")
  library(tqk)
}

DX <- tqk_get("022100", from='2022-01-01', to='2022-06-30')

ggplot(DX) +
  aes(x = date, y = close) +
  geom_line(colour = "#112446") +
  theme_minimal()

#데스크탑에서 업로드 함