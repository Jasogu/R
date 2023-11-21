
library(ggplot2)
"""
labs(y = "단위 : 천명", title = "관리자 전문가") +
 geom_col(fill = "steelblue") +
 theme(
   plot.title = element_text(size = 30L,
                             face = "bold",
                             hjust = 0.5),
   plot.caption = element_text(face = "bold",
                               hjust = 0.5),
   axis.title.y = element_text(size = 15L, hjust = 1),
   axis.text.x=element_text(angle=90, hjust=1)
 ) +
"""

# * 관리자·전문가(1,2)
ggplot(labor_data) +
 aes(x = 시점, y = `* 관리자·전문가(1,2)`) +
 labs(y = "단위 : 천명", title = "관리자 전문가") +
 geom_col(fill = "steelblue") +
 theme_minimal() +
 theme(
   plot.title = element_text(size = 30L,
                             face = "bold",
                             hjust = 0.5),
   plot.caption = element_text(face = "bold",
                               hjust = 0.5),
   axis.title.y = element_text(size = 15L, hjust = 1),
   axis.text.x=element_text(angle=90, hjust=1)
 ) +
 coord_cartesian(ylim = c(min(labor_data$`* 관리자·전문가(1,2)`)-100, NA))

# 3 사무 종사자
ggplot(labor_data) +
  aes(x = 시점, y = `3 사무 종사자`) +
  labs(y = "단위 : 천명", title = "3 사무 종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal()+
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`3 사무 종사자`)-100, NA))

# 4 서비스 종사자
ggplot(labor_data) +
  aes(x = 시점, y = `4 서비스 종사자`) +
  labs(y = "단위 : 천명", title = "4 서비스 종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`4 서비스 종사자`)-100, NA))

# 5 판매 종사자
ggplot(labor_data) +
  aes(x = 시점, y = `5 판매 종사자`) +
  labs(y = "단위 : 천명", title = "5 판매 종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`5 판매 종사자`)-100, NA))

# 6 농림어업 숙련 종사자
# 분석 X
ggplot(labor_data) +
  aes(x = 시점, y = `6 농림어업 숙련 종사자자`) +
  labs(y = "단위 : 천명", title = "6 농림어업 숙련 종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`6 농림어업 숙련 종사자`)-100, NA))

# 7 기능원 및 관련 기능종사자
# 분석 X
ggplot(labor_data) +
  aes(x = 시점, y = `7 기능원 및 관련 기능종사자`) +
  labs(y = "단위 : 천명", title = "7 기능원 및 관련 기능종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`7 기능원 및 관련 기능종사자`)-100, NA))

# 8 장치,기계조작 및 조립종사자
ggplot(labor_data) +
  aes(x = 시점, y = `8 장치,기계조작 및 조립종사자`) +
  labs(y = "단위 : 천명", title = "8 장치,기계조작 및 조립종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`8 장치,기계조작 및 조립종사자`)-100, NA))

# 9 단순노무 종사자
ggplot(labor_data) +
  aes(x = 시점, y = `9 단순노무 종사자`) +
  labs(y = "단위 : 천명", title = "9 단순노무 종사자") +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 30L,
                              face = "bold",
                              hjust = 0.5),
    plot.caption = element_text(face = "bold",
                                hjust = 0.5),
    axis.title.y = element_text(size = 15L, hjust = 1),
    axis.text.x=element_text(angle=90, hjust=1)
  ) +
  coord_cartesian(ylim = c(min(labor_data$`9 단순노무 종사자`)-100, NA))
