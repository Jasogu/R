library(ggplot2)
library(lubridate)

head(data)
date <- ymd(data$시점)

# 맨 뒤의 두 자리와 그 앞의 "-"를 제거
modified_date <- sub("-\\d{2}$", "", date)
data$시점 <- modified_date


ggplot(data) +
  aes(x = 시점, y = data$`*자영업자`) +
  geom_col(fill = "#112446") +
  theme_minimal() +
  coord_cartesian(ylim = c(1000, NA)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))