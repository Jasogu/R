# 필요한 패키지 설치 및 로드
if (!require("shiny")) install.packages("shiny")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("dplyr")) install.packages("dplyr")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("plotly")) install.packages("plotly")
if (!require("DT")) install.packages("DT")
if (!require("tidyquant")) install.packages("tidyquant")
if (!require("RColorBrewer")) install.packages("RColorBrewer")

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(tidyquant)

# 주식 데이터 가져오기 함수
get_stock_data <- function(symbols, start_date, end_date) {
  # 에러 처리 추가
  result <- tryCatch({
    # tidyquant를 사용하여 데이터 가져오기 (quantmod의 getSymbols 대신)
    stock_data <- tq_get(symbols, 
                        from = as.Date(start_date), 
                        to = as.Date(end_date), 
                        get = "stock.prices")
    
    # 필요한 형식으로 변환
    if(nrow(stock_data) > 0) {
      stock_data <- stock_data %>%
        select(date, symbol, close) %>%
        tidyr::pivot_wider(names_from = symbol, values_from = close) %>%
        rename(Date = date)
      
      return(stock_data)
    } else {
      stop("데이터를 찾을 수 없습니다.")
    }
  }, error = function(e) {
    # 오류 발생 시 메시지 출력 및 데모 데이터 반환
    warning(paste("주식 데이터를 가져오는데 실패했습니다:", e$message, "데모 데이터를 사용합니다."))
    
    # 데모 데이터 생성
    demo_dates <- seq(as.Date(start_date), as.Date(end_date), by = "day")
    demo_dates <- demo_dates[weekdays(demo_dates) != "토요일" & weekdays(demo_dates) != "일요일"]
    
    if(length(demo_dates) > 500) {
      demo_dates <- demo_dates[seq(1, length(demo_dates), length.out = 500)]
    }
    
    demo_data <- data.frame(Date = demo_dates)
    
    set.seed(123) # 재현 가능한 결과를 위한 시드 설정
    
    # 각 주식에 대한 가상 데이터 생성
    for(symbol in symbols) {
      start_price <- switch(symbol,
                           "AAPL" = 150,
                           "MSFT" = 300,
                           "AMZN" = 3400,
                           "GOOGL" = 2800,
                           "META" = 330,
                           100) # 기본값
      
      # 랜덤 워크로 가격 시뮬레이션
      n <- length(demo_dates)
      changes <- rnorm(n, mean = 0.0003, sd = 0.015)
      prices <- numeric(n)
      prices[1] <- start_price
      
      for(i in 2:n) {
        prices[i] <- prices[i-1] * (1 + changes[i])
      }
      
      demo_data[[symbol]] <- prices
    }
    
    return(demo_data)
  })
  
  return(result)
}

# 포트폴리오 성능 계산 함수
calculate_portfolio_performance <- function(stock_data, weights) {
  # 수익률 계산
  returns <- stock_data %>%
    select(-Date) %>%
    apply(2, function(x) diff(x) / x[-length(x)])
  
  # 포트폴리오 수익률
  portfolio_returns <- returns %*% weights
  
  # 누적 수익률
  cumulative_returns <- cumprod(1 + portfolio_returns) - 1
  
  # 성과 지표
  annualized_return <- mean(portfolio_returns) * 252
  annualized_volatility <- sd(portfolio_returns) * sqrt(252)
  sharpe_ratio <- annualized_return / annualized_volatility
  
  # 직접 최대 낙폭 계산
  equity_curve <- cumprod(1 + portfolio_returns)
  cummax_equity <- cummax(equity_curve)
  drawdowns <- (equity_curve - cummax_equity) / cummax_equity
  max_drawdown <- min(drawdowns)
  
  result <- list(
    returns = portfolio_returns,
    cumulative_returns = cumulative_returns,
    annualized_return = annualized_return,
    annualized_volatility = annualized_volatility,
    sharpe_ratio = sharpe_ratio,
    max_drawdown = max_drawdown
  )
  
  return(result)
}

# 커스텀 CSS 스타일 정의 (www 폴더 없이 인라인으로 적용)
customCSS <- "
.content-wrapper {
  background-color: #f8f9fa;
}

.box {
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.1);
  border-radius: 5px;
}

.box-header {
  border-bottom: 1px solid #eee;
}

.sidebar-menu .active > a {
  border-left-color: #0275d8;
}

.value-box {
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.1);
}
"

# UI 정의
ui <- dashboardPage(
  dashboardHeader(title = "금융 포트폴리오 분석 대시보드"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("대시보드 개요", tabName = "overview", icon = icon("dashboard")),
      menuItem("주식 분석", tabName = "stock_analysis", icon = icon("chart-line")),
      menuItem("포트폴리오 성능", tabName = "portfolio_performance", icon = icon("chart-pie")),
      menuItem("리스크 분석", tabName = "risk_analysis", icon = icon("chart-area")),
      menuItem("데이터 테이블", tabName = "data_table", icon = icon("table"))
    ),
    
    dateRangeInput("date_range", "날짜 범위 선택:",
                  start = Sys.Date() - 365*2,
                  end = Sys.Date()),
    
    checkboxGroupInput("stock_selection", "주식 선택:",
                      choices = c("AAPL", "MSFT", "AMZN", "GOOGL", "META"),
                      selected = c("AAPL", "MSFT", "AMZN")),
    
    # 단일 슬라이더로 첫 번째 주식 가중치만 조정 (나머지는 균등 배분)
    sliderInput("first_weight", "첫 번째 주식 비중 (%):",
               min = 0, max = 100, value = 33, step = 1),
    helpText("나머지 주식들은 균등하게 배분됩니다.")
  ),
  
  dashboardBody(
    # 인라인 CSS 적용
    tags$head(tags$style(HTML(customCSS))),
    
    tabItems(
      # 대시보드 개요 탭
      tabItem(tabName = "overview",
        fluidRow(
          box(title = "포트폴리오 개요", width = 12,
              "이 대시보드는 선택한 주식들의 성과와 포트폴리오 분석을 제공합니다. 사이드바에서 원하는 주식과 날짜 범위를 설정하세요."
          )
        ),
        fluidRow(
          valueBoxOutput("return_box", width = 4),
          valueBoxOutput("volatility_box", width = 4),
          valueBoxOutput("sharpe_box", width = 4)
        ),
        fluidRow(
          box(title = "주식 가격 동향", width = 12,
              plotlyOutput("price_trend_plot", height = 400)
          )
        )
      ),
      
      # 주식 분석 탭
      tabItem(tabName = "stock_analysis",
        fluidRow(
          box(title = "개별 주식 성과", width = 6,
              plotlyOutput("stock_performance_plot", height = 400)
          ),
          box(title = "일일 수익률 분포", width = 6,
              plotlyOutput("returns_distribution_plot", height = 400)
          )
        ),
        fluidRow(
          box(title = "상관관계 히트맵", width = 12,
              plotlyOutput("correlation_heatmap", height = 350)
          )
        )
      ),
      
      # 포트폴리오 성능 탭
      tabItem(tabName = "portfolio_performance",
        fluidRow(
          box(title = "포트폴리오 누적 수익률", width = 12,
              plotlyOutput("portfolio_cumulative_plot", height = 400)
          )
        ),
        fluidRow(
          box(title = "자산 배분", width = 6,
              plotlyOutput("portfolio_allocation_plot", height = 350)
          ),
          box(title = "효율적 투자선", width = 6,
              plotlyOutput("efficient_frontier_plot", height = 350)
          )
        )
      ),
      
      # 리스크 분석 탭
      tabItem(tabName = "risk_analysis",
        fluidRow(
          box(title = "최대 낙폭", width = 6,
              plotlyOutput("drawdown_plot", height = 350)
          ),
          box(title = "VaR (Value at Risk)", width = 6,
              plotlyOutput("var_plot", height = 350)
          )
        ),
        fluidRow(
          box(title = "리스크 지표", width = 12,
              tableOutput("risk_metrics_table")
          )
        )
      ),
      
      # 데이터 테이블 탭
      tabItem(tabName = "data_table",
        fluidRow(
          box(title = "주식 데이터", width = 12,
              DTOutput("stock_data_table")
          )
        )
      )
    )
  )
)

# 서버 로직
server <- function(input, output, session) {
  
  # 반응형 데이터: 선택된 주식 데이터
  stock_data <- reactive({
    req(input$stock_selection)
    validate(need(length(input$stock_selection) > 0, "적어도 하나의 주식을 선택하세요"))
    
    get_stock_data(input$stock_selection, input$date_range[1], input$date_range[2])
  })
  
  # 포트폴리오 가중치 계산 수정
  weights <- reactive({
    stocks <- input$stock_selection
    n <- length(stocks)
    
    if(n == 0) return(NULL)
    
    if(n == 1) {
      w <- 1
      names(w) <- stocks
      return(w)
    }
    
    # 첫 번째 주식 가중치
    first_w <- input$first_weight / 100
    
    # 나머지 주식들의 가중치 (균등 배분)
    other_w <- (1 - first_w) / (n - 1)
    
    w <- c(first_w, rep(other_w, n-1))
    names(w) <- stocks
    
    return(w)
  })
  
  # 포트폴리오 성능
  portfolio_performance <- reactive({
    req(stock_data())
    calculate_portfolio_performance(stock_data(), weights())
  })
  
  # 대시보드 개요 탭 출력물
  output$return_box <- renderValueBox({
    perf <- portfolio_performance()
    valueBox(
      paste0(round(perf$annualized_return * 100, 2), "%"),
      "연간 수익률",
      icon = icon("dollar-sign"),
      color = if(perf$annualized_return > 0) "green" else "red"
    )
  })
  
  output$volatility_box <- renderValueBox({
    perf <- portfolio_performance()
    valueBox(
      paste0(round(perf$annualized_volatility * 100, 2), "%"),
      "연간 변동성",
      icon = icon("chart-line"),
      color = "orange"
    )
  })
  
  output$sharpe_box <- renderValueBox({
    perf <- portfolio_performance()
    valueBox(
      round(perf$sharpe_ratio, 2),
      "샤프 비율",
      icon = icon("balance-scale"),
      color = if(perf$sharpe_ratio > 1) "blue" else "yellow"
    )
  })
  
  output$price_trend_plot <- renderPlotly({
    data <- stock_data()
    
    plot_data <- data %>%
      tidyr::pivot_longer(cols = -Date, names_to = "Stock", values_to = "Price")
    
    p <- ggplot(plot_data, aes(x = Date, y = Price, color = Stock)) +
      geom_line() +
      labs(title = "주식 가격 동향", x = "날짜", y = "종가") +
      theme_minimal()
    
    ggplotly(p) %>%
      layout(hovermode = "x unified")
  })
  
  # 주식 분석 탭 출력물
  output$stock_performance_plot <- renderPlotly({
    data <- stock_data()
    start_prices <- data[1, -1]
    
    normalized_data <- data
    for (col in names(data)[-1]) {
      normalized_data[[col]] <- data[[col]] / start_prices[[col]]
    }
    
    plot_data <- normalized_data %>%
      tidyr::pivot_longer(cols = -Date, names_to = "Stock", values_to = "NormalizedPrice")
    
    p <- ggplot(plot_data, aes(x = Date, y = NormalizedPrice, color = Stock)) +
      geom_line() +
      labs(title = "정규화된 주식 성과 (시작=1)", x = "날짜", y = "정규화된 가격") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$returns_distribution_plot <- renderPlotly({
    data <- stock_data()
    
    # 수익률 계산
    returns_data <- data.frame(Date = data$Date[-1])
    for (col in names(data)[-1]) {
      prices <- data[[col]]
      returns_data[[col]] <- c(diff(prices) / prices[-length(prices)])
    }
    
    plot_data <- returns_data %>%
      tidyr::pivot_longer(cols = -Date, names_to = "Stock", values_to = "Return")
    
    p <- ggplot(plot_data, aes(x = Return, fill = Stock)) +
      geom_histogram(alpha = 0.6, position = "identity", bins = 30) +
      labs(title = "일일 수익률 분포", x = "수익률", y = "빈도") +
      theme_minimal() +
      xlim(-0.1, 0.1)
    
    ggplotly(p)
  })
  
  output$correlation_heatmap <- renderPlotly({
    data <- stock_data()
    
    # 수익률로 상관관계 계산
    returns <- data %>%
      select(-Date) %>%
      apply(2, function(x) diff(x) / x[-length(x)])
    
    cor_matrix <- cor(returns)
    
    plot_ly(
      z = cor_matrix,
      x = colnames(cor_matrix),
      y = colnames(cor_matrix),
      type = "heatmap",
      colorscale = "RdBu"
    ) %>%
      layout(title = "주식 수익률 상관관계")
  })
  
  # 포트폴리오 성능 탭 출력물
  output$portfolio_cumulative_plot <- renderPlotly({
    perf <- portfolio_performance()
    data <- stock_data()
    
    plot_data <- data.frame(
      Date = data$Date[-1],
      CumulativeReturn = perf$cumulative_returns
    )
    
    p <- ggplot(plot_data, aes(x = Date, y = CumulativeReturn)) +
      geom_line(color = "blue") +
      labs(title = "포트폴리오 누적 수익률", x = "날짜", y = "누적 수익률") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$portfolio_allocation_plot <- renderPlotly({
    stocks <- input$stock_selection
    w <- weights()
    
    # RColorBrewer 팔레트 대신 직접 색상 정의
    pie_colors <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F")
    
    plot_data <- data.frame(
      Stock = stocks,
      Weight = w
    )
    
    plot_ly(plot_data, labels = ~Stock, values = ~Weight, type = 'pie',
           textinfo = 'label+percent',
           marker = list(colors = pie_colors[1:length(stocks)])) %>%
      layout(title = "포트폴리오 자산 배분")
  })
  
  output$efficient_frontier_plot <- renderPlotly({
    data <- stock_data()
    
    # 수익률 계산
    returns <- data %>%
      select(-Date) %>%
      apply(2, function(x) diff(x) / x[-length(x)])
    
    # 평균 수익률과 변동성
    mean_returns <- colMeans(returns) * 252
    cov_matrix <- cov(returns) * 252
    
    # 효율적 투자선을 위한 포트폴리오 시뮬레이션
    n_portfolios <- 500
    n_assets <- length(input$stock_selection)
    
    # 결과 저장용 데이터 프레임
    results <- data.frame(Return = numeric(n_portfolios),
                         Risk = numeric(n_portfolios),
                         SharpeRatio = numeric(n_portfolios))
    
    set.seed(123)
    for (i in 1:n_portfolios) {
      weights <- runif(n_assets)
      weights <- weights / sum(weights)
      
      portfolio_return <- sum(weights * mean_returns)
      portfolio_std_dev <- sqrt(t(weights) %*% cov_matrix %*% weights)
      
      results$Return[i] <- portfolio_return
      results$Risk[i] <- portfolio_std_dev
      results$SharpeRatio[i] <- portfolio_return / portfolio_std_dev
    }
    
    # 현재 포트폴리오 추가
    current_weights <- weights()
    current_return <- sum(current_weights * mean_returns)
    current_risk <- sqrt(t(current_weights) %*% cov_matrix %*% current_weights)
    
    # 플롯
    p <- plot_ly() %>%
      add_trace(
        data = results,
        x = ~Risk,
        y = ~Return,
        color = ~SharpeRatio,
        type = "scatter",
        mode = "markers",
        marker = list(size = 5, opacity = 0.5),
        name = "시뮬레이션된 포트폴리오"
      ) %>%
      add_trace(
        x = current_risk,
        y = current_return,
        type = "scatter",
        mode = "markers",
        marker = list(size = 12, color = "red"),
        name = "현재 포트폴리오"
      ) %>%
      layout(
        title = "효율적 투자선",
        xaxis = list(title = "리스크 (연간 표준편차)"),
        yaxis = list(title = "수익률 (연간)"),
        showlegend = TRUE
      )
    
    p
  })
  
  # 리스크 분석 탭 출력물
  output$drawdown_plot <- renderPlotly({
    perf <- portfolio_performance()
    data <- stock_data()
    
    # 최대 낙폭 계산
    equity_curve <- cumprod(1 + perf$returns)
    cummax_equity <- cummax(equity_curve)
    drawdown <- (equity_curve - cummax_equity) / cummax_equity
    
    plot_data <- data.frame(
      Date = data$Date[-1],
      Drawdown = drawdown
    )
    
    p <- ggplot(plot_data, aes(x = Date, y = Drawdown)) +
      geom_area(fill = "red", alpha = 0.5) +
      labs(title = "포트폴리오 낙폭", x = "날짜", y = "낙폭 (%)") +
      theme_minimal() +
      scale_y_continuous(labels = scales::percent)
    
    ggplotly(p)
  })
  
  output$var_plot <- renderPlotly({
    perf <- portfolio_performance()
    
    # 일일 수익률 분포 
    returns <- perf$returns
    
    # 히스토그램 데이터
    hist_data <- hist(returns, breaks = 30, plot = FALSE)
    
    # VaR 계산 (95%, 99%)
    var_95 <- quantile(returns, 0.05)
    var_99 <- quantile(returns, 0.01)
    
    p <- plot_ly() %>%
      add_histogram(x = returns, nbinsx = 30, name = "수익률 분포") %>%
      add_segments(x = var_95, xend = var_95, y = 0, yend = max(hist_data$counts)/2,
                  line = list(color = 'red', width = 2, dash = 'solid'),
                  name = paste("95% VaR:", round(var_95*100, 2), "%")) %>%
      add_segments(x = var_99, xend = var_99, y = 0, yend = max(hist_data$counts)/2,
                  line = list(color = 'darkred', width = 2, dash = 'dash'),
                  name = paste("99% VaR:", round(var_99*100, 2), "%")) %>%
      layout(title = "Value at Risk (VaR) 분석",
             xaxis = list(title = "일일 수익률"),
             yaxis = list(title = "빈도"),
             showlegend = TRUE)
    
    p
  })
  
  output$risk_metrics_table <- renderTable({
    perf <- portfolio_performance()
    
    # 다양한 리스크 지표 계산
    returns <- perf$returns
    
    # VaR 계산
    var_95 <- quantile(returns, 0.05)
    var_99 <- quantile(returns, 0.01)
    
    # CVaR 계산 (Conditional VaR / Expected Shortfall)
    cvar_95 <- mean(returns[returns <= var_95])
    cvar_99 <- mean(returns[returns <= var_99])
    
    # 리스크 지표 테이블
    risk_metrics <- data.frame(
      Metric = c("연간 변동성", "최대 낙폭", "VaR (95%)", "CVaR (95%)", 
                "VaR (99%)", "CVaR (99%)", "샤프 비율"),
      Value = c(
        paste0(round(perf$annualized_volatility * 100, 2), "%"),
        paste0(round(abs(perf$max_drawdown) * 100, 2), "%"),
        paste0(round(abs(var_95) * 100, 2), "%"),
        paste0(round(abs(cvar_95) * 100, 2), "%"),
        paste0(round(abs(var_99) * 100, 2), "%"),
        paste0(round(abs(cvar_99) * 100, 2), "%"),
        round(perf$sharpe_ratio, 2)
      )
    )
    
    risk_metrics
  })
  
  # 데이터 테이블 탭 출력물
  output$stock_data_table <- renderDT({
    data <- stock_data()
    DT::datatable(data, 
                 options = list(pageLength = 15, 
                               autoWidth = TRUE,
                               scrollX = TRUE),
                 caption = "주식 가격 데이터")
  })
}

# 앱 실행
shinyApp(ui, server)
 
