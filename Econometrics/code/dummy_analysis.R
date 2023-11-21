g1 <- ggplot(labor_data) +
  aes(x = 시점, y = `* 관리자·전문가(1,2)`) +
  labs(y = "단위 : 천명", title = "* 관리자·전문가(1,2)") +
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
  coord_cartesian(ylim = c(min(labor_data$`* 관리자·전문가(1,2)`)-100, NA)) +

