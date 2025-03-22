library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(caret)
library(viridis)
library(randomForest)
library(gbm)
library(e1071)
library(grid)
library(gridExtra)
# webshot2 패키지 추가 (없으면 자동 설치)
if(!require(webshot2)) install.packages("webshot2")

# 수치형 등급을 문자형 신용등급으로 변환하는 함수
convert_numeric_to_rating <- function(numeric_rating) {
  ratings <- c("D", "C", "CC", "CCC-", "CCC", "CCC+",
               "B-", "B", "B+", "BB-", "BB", "BB+", 
               "BBB-", "BBB", "BBB+", "A-", "A", "A+", 
               "AA-", "AA", "AA+", "AAA")
  
  # 값이 범위를 벗어나면 조정
  numeric_rating <- round(numeric_rating)
  if (numeric_rating < 1) numeric_rating <- 1
  if (numeric_rating > 22) numeric_rating <- 22
  
  return(ratings[numeric_rating])
}

# 저장된 모델 결과 로드
results <- readRDS("credit_model_results.rds")

# train_idx 변수 생성
set.seed(123)
train_idx <- createDataPartition(results$processed_data$Bond_Mean_Numeric, p = 0.8, list = FALSE)

# UI 정의
ui <- dashboardPage(
  dashboardHeader(title = "신용등급 예측 모델"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("대시보드 요약", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("모델 성능", tabName = "performance", icon = icon("chart-line")),
      menuItem("업종별 등급", tabName = "industry", icon = icon("building")),
      menuItem("분석 데이터", tabName = "data", icon = icon("table")), # 새로운 탭 추가
      menuItem("신규 기업 평가", tabName = "predict", icon = icon("search"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # 대시보드 요약 탭
      tabItem(tabName = "dashboard",
              fluidRow(
                valueBoxOutput("total_companies", width = 3),
                valueBoxOutput("r_squared", width = 3),
                valueBoxOutput("model_mae", width = 3),
                valueBoxOutput("model_corr", width = 3)
              ),
              fluidRow(
                box(title = "특성 중요도", status = "primary", plotOutput("feature_importance"), width = 6),
                box(title = "예측 vs 실제", status = "primary", plotOutput("pred_vs_actual"), width = 6)
              ),
              fluidRow(
                box(title = "오차 분포", status = "primary", plotOutput("error_dist"), width = 12)
              )
      ),
      
      # 모델 성능 탭
      tabItem(tabName = "performance",
              fluidRow(
                box(title = "평가 지표 상세", status = "primary", width = 12,
                    verbatimTextOutput("model_metrics"),
                    tags$head(tags$style("#model_metrics{font-size:14px;}")),
                    height = 500
                )
              )
      ),
      
      # 업종별 등급 탭
      tabItem(tabName = "industry",
              fluidRow(
                box(title = "업종별 평균 신용등급", status = "primary", width = 12,
                    plotOutput("industry_ratings"))
              ),
              fluidRow(
                box(title = "업종별 기업 수", status = "primary", width = 12,
                    plotOutput("industry_counts"))
              )
      ),
      
      # 분석 데이터 탭
      tabItem(tabName = "data",
              fluidRow(
                box(title = "데이터셋 정보", status = "primary", width = 12,
                    p("이 데이터셋은 기업들의 재무 정보와 신용등급을 포함하고 있습니다."),
                    p("데이터 출처: FnGuide")
                )
              ),
              fluidRow(
                box(title = "데이터 탐색", status = "primary", width = 12,
                    div(style = 'overflow-x: scroll', DT::dataTableOutput("credit_data_table")),
                    downloadButton("download_data", "데이터 다운로드", class = "btn-primary")
                )
              ),
              fluidRow(
                box(title = "데이터 요약", status = "primary", width = 12,
                    verbatimTextOutput("data_summary")
                )
              )
      ),
      
      # 신규 기업 평가 탭
      tabItem(tabName = "predict",
              fluidRow(
                box(title = "신규 기업 데이터 입력", status = "primary", width = 12,
                    uiOutput("dynamic_inputs"),
                    actionButton("predict_btn", "신용등급 예측", class = "btn-primary")
                )
              ),
              fluidRow(
                box(title = "예측 결과", status = "success", width = 12,
                    valueBoxOutput("predicted_rating", width = 12),
                    verbatimTextOutput("prediction_details"),
                    plotOutput("prediction_visual", height = 200)
                )
              )
      )
    )
  )
)


# 서버 로직 정의
server <- function(input, output, session) {
  # 만약 train_idx가 존재하지 않으면 생성
  if (!exists("train_idx")) {
    set.seed(123)
    train_idx <- createDataPartition(results$processed_data$Bond_Mean_Numeric, p = 0.8, list = FALSE)
  }
  
  # 모델 결과 요약 정보 표시
  output$total_companies <- renderValueBox({
    valueBox(
      nrow(results$raw_data),
      "분석 대상 기업 수",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  # 결정계수(R-squared) 표시
  output$r_squared <- renderValueBox({
    valueBox(
      sprintf("%.3f", results$test_evaluation$R_Squared),
      "결정계수 (R²)",
      icon = icon("chart-line"),
      color = "yellow"
    )
  })
  
  # MAE 표시
  output$model_mae <- renderValueBox({
    valueBox(
      sprintf("%.3f", results$test_evaluation$MAE),
      "모델 MAE",
      icon = icon("chart-bar"),
      color = "green"
    )
  })
  
  output$model_corr <- renderValueBox({
    valueBox(
      sprintf("%.3f", results$test_evaluation$Correlation),
      "예측-실제 상관계수",
      icon = icon("sync"),
      color = "purple"
    )
  })
  
  # 예측 vs 실제 그래프
  output$pred_vs_actual <- renderPlot({
    test_data <- results$processed_data[-train_idx, ]
    predictions <- predict(results$best_model, 
                         newdata = test_data %>% select(all_of(results$selected_features)))
    
    pred_vs_actual <- data.frame(
      Actual = test_data$Bond_Mean_Numeric,
      Predicted = predictions
    )
    
    ggplot(pred_vs_actual, aes(x = Actual, y = Predicted)) +
      geom_point(alpha = 0.6, color = "darkblue") +
      geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
      labs(title = "예측 vs 실제 신용등급",
           x = "실제 등급", y = "예측 등급") +
      theme_minimal() +
      annotate("text", x = min(pred_vs_actual$Actual), y = max(pred_vs_actual$Predicted),
               label = paste("상관계수:", round(results$test_evaluation$Correlation, 3)),
               hjust = 0, vjust = 1)
  })
  
  # 오차 분포 히스토그램
  output$error_dist <- renderPlot({
    test_data <- results$processed_data[-train_idx, ]
    predictions <- predict(results$best_model, 
                         newdata = test_data %>% select(all_of(results$selected_features)))
    
    error_data <- data.frame(
      Error = predictions - test_data$Bond_Mean_Numeric
    )
    
    ggplot(error_data, aes(x = Error)) +
      geom_histogram(bins = 20, fill = "steelblue", color = "white") +
      labs(title = "예측 오차 분포",
           x = "예측 오차 (예측값 - 실제값)", y = "빈도") +
      theme_minimal() +
      geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
      annotate("text", x = max(error_data$Error) * 0.8, y = 5,
               label = paste("평균 오차:", round(mean(error_data$Error), 3),
                             "\nMAE:", round(results$test_evaluation$MAE, 3)),
               hjust = 1)
  })
  
  # 모델 평가 지표 상세
  output$model_metrics <- renderPrint({
    cat("=================================================================\n")
    cat("                 신용등급 예측 모델 상세 분석 결과                 \n")
    cat("=================================================================\n\n")
    
    cat("1. 기본 모델 정보\n")
    cat("------------------\n")
    cat("최적 모델:", results$best_model_name, "\n")
    if (results$best_model_name == "rf") {
      cat("모델 타입: Random Forest (랜덤 포레스트)\n")
      cat("모델 특징: 다수의 의사결정 트리를 구성하여 예측 성능을 향상시킨 앙상블 모델\n")
    } else if (results$best_model_name == "gbm") {
      cat("모델 타입: Gradient Boosting Machine (그래디언트 부스팅 머신)\n")
      cat("모델 특징: 이전 모델의 오차를 보완하는 방식으로 모델을 순차적으로 학습하는 앙상블 기법\n")
    } else if (results$best_model_name == "svr") {
      cat("모델 타입: Support Vector Regression (서포트 벡터 회귀)\n")
      cat("모델 특징: 초평면을 이용하여 데이터를 분류하는 SVM의 회귀 버전\n")
    }
    cat("\n")
    
    cat("2. 모델 성능 평가 지표\n")
    cat("----------------------\n")
    cat("RMSE (Root Mean Squared Error):", round(results$test_evaluation$RMSE, 4), "\n")
    cat("  - 의미: 예측값과 실제값 차이의 제곱 평균에 대한 제곱근\n")
    cat("  - 해석: 낮을수록 좋음. 예측 오차의 크기를 원래 척도로 표현\n\n")
    
    cat("MAE (Mean Absolute Error):", round(results$test_evaluation$MAE, 4), "\n")
    cat("  - 의미: 예측값과 실제값 차이의 절대값 평균\n")
    cat("  - 해석: 낮을수록 좋음. 이 모델은 평균적으로 ", round(results$test_evaluation$MAE, 2), "등급 차이로 예측\n\n")
    
    cat("상관계수 (Correlation):", round(results$test_evaluation$Correlation, 4), "\n")
    cat("  - 의미: 예측값과 실제값 간의 선형 관계 강도\n")
    cat("  - 해석: -1에서 1 사이 값. 1에 가까울수록 좋음\n\n")
    
    cat("결정계수 (R²):", round(results$test_evaluation$R_Squared, 4), "\n")
    cat("  - 의미: 모델이 데이터 분산을 설명하는 비율\n")
    cat("  - 해석: 0에서 1 사이 값. 1에 가까울수록 좋음\n")
    cat("  - 해석: 모델이 데이터 변동성의 약 ", round(results$test_evaluation$R_Squared * 100, 1), "%를 설명함\n\n")
    
    cat("평균 노치 오차 (Mean Notch Error):", round(results$test_evaluation$Notch_Error, 4), "\n")
    cat("  - 의미: 신용등급 단계 기준 평균 오차\n")
    cat("  - 해석: 모델이 평균적으로 ", round(results$test_evaluation$Notch_Error, 2), "단계 차이로 신용등급을 예측\n\n")
    
    cat("3. 중요 특성 (Top 5)\n")
    cat("-------------------\n")
    # 변수 중요도 정보 추출
    if (inherits(results$best_model, "train")) {
      importance_data <- data.frame(varImp(results$best_model)$importance)
      importance_data$Feature <- rownames(importance_data)
      importance_data <- importance_data %>% 
        arrange(desc(Overall)) %>% 
        head(5)
      
      for (i in 1:nrow(importance_data)) {
        cat(sprintf("%d. %s (중요도: %.2f)\n", 
                  i, importance_data$Feature[i], importance_data$Overall[i]))
      }
    } else {
      cat("변수 중요도 정보를 추출할 수 없습니다.\n")
    }
    cat("\n")
    
    cat("4. 모델 활용 시 고려사항\n")
    cat("----------------------\n")
    cat("- 이 모델은 재무비율을 기반으로 신용등급을 예측하므로 기업의 질적 특성은 반영되지 않음\n")
    cat("- 모델의 예측값은 참고용으로 활용하고, 최종 결정에는 전문가의 검토가 필요함\n")
    cat("- 특히 예측된 신용등급과 실제 신용등급 간 약 ", 
        round(results$test_evaluation$Notch_Error, 1), "단계 차이가 날 수 있음을 고려\n")
    cat("\n")
    
    cat("5. 데이터셋 기초 통계\n")
    cat("------------------\n")
    cat("- 총 데이터 수: ", nrow(results$raw_data), "개\n")
    cat("- 사용된 특성 수: ", length(results$selected_features), "개\n")
    cat("- 훈련 데이터 비율: 80%\n")
    cat("- 테스트 데이터 비율: 20%\n")
  })
  
  # 특성 중요도 시각화
  output$feature_importance <- renderPlot({
    tryCatch({
      if (inherits(results$best_model, "train")) {
        importance_data <- varImp(results$best_model)$importance
        importance_data$Feature <- rownames(importance_data)
        importance_col <- "Overall"
      } else if (results$best_model_name == "rf" && "randomForest" %in% class(results$best_model)) {
        importance_data <- as.data.frame(randomForest::importance(results$best_model))
        importance_data$Feature <- rownames(importance_data)
        importance_col <- "%IncMSE"
      } else {
        # 특성 중요도를 가져올 수 없는 경우 선택된 특성으로 대체
        importance_data <- data.frame(
          Feature = results$selected_features,
          Importance = seq(length(results$selected_features), 1, -1)
        )
        importance_col <- "Importance"
      }
      
      # 그래프 생성
      ggplot(importance_data %>% 
               arrange(desc(!!sym(importance_col))) %>% 
               head(10), 
             aes(x = reorder(Feature, !!sym(importance_col)), 
                 y = !!sym(importance_col))) +
        geom_bar(stat = "identity", fill = "steelblue") +
        coord_flip() +
        labs(title = "특성 중요도 (상위 10개)",
             x = "", y = "중요도") +
        theme_minimal()
    }, error = function(e) {
      # 오류 발생 시 기본 특성 시각화
      selected_features <- data.frame(
        Feature = results$selected_features,
        Importance = seq(length(results$selected_features), 1, -1)
      )
      
      ggplot(selected_features, 
             aes(x = reorder(Feature, Importance), y = Importance)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        coord_flip() +
        labs(title = "선택된 특성",
             x = "", y = "선택 순서") +
        theme_minimal()
    })
  })
  
  # 업종별 평균 신용등급
  output$industry_ratings <- renderPlot({
    tryCatch({
      industry_ratings <- results$raw_data %>%
        group_by(업종) %>%
        summarise(
          평균등급 = mean(as.numeric(factor(Bond_Mean)), na.rm = TRUE),
          기업수 = n()
        ) %>%
        arrange(desc(평균등급)) %>%
        head(15)
      
      ggplot(industry_ratings, 
             aes(x = reorder(업종, 평균등급), y = 평균등급, fill = 기업수)) +
        geom_bar(stat = "identity") +
        coord_flip() +
        labs(title = "업종별 평균 신용등급 (상위 15개)",
             x = "", y = "평균 신용등급") +
        theme_minimal() +
        scale_fill_viridis_c(name = "기업 수")
    }, error = function(e) {
      # 오류 발생 시 더미 그래프
      ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = "업종별 데이터를 생성할 수 없습니다") +
        theme_void()
    })
  })
  
  # 업종별 기업 수
  output$industry_counts <- renderPlot({
    tryCatch({
      industry_counts <- results$raw_data %>%
        count(업종, name = "기업수") %>%
        arrange(desc(기업수)) %>%
        head(15)
      
      ggplot(industry_counts, 
             aes(x = reorder(업종, 기업수), y = 기업수)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        coord_flip() +
        labs(title = "업종별 기업 수 (상위 15개)",
             x = "", y = "기업 수") +
        theme_minimal()
    }, error = function(e) {
      # 오류 발생 시 더미 그래프
      ggplot() + 
        annotate("text", x = 0.5, y = 0.5, label = "업종별 데이터를 생성할 수 없습니다") +
        theme_void()
    })
  })
  
    # 데이터 테이블 출력 탭
    output$credit_data_table <- DT::renderDataTable({
    # credit data 파일 읽기
    credit_data <- readxl::read_excel("data/credit data.xlsx")
    DT::datatable(credit_data, options = list(pageLength = 5, scrollX = TRUE))
    })

    output$data_summary <- renderPrint({
    credit_data <- readxl::read_excel("data/credit data.xlsx")
    summary(credit_data)
    })

    output$download_data <- downloadHandler(
    filename = function() {
        "data/credit data.xlsx"
    },
    content = function(file) {
        file.copy("data/credit data.xlsx", file)
    }
    )
 
  # 동적 입력 UI 생성 - 업종 선택 제외
  output$dynamic_inputs <- renderUI({
    # 업종을 제외한 선택된 특성에 기반한 입력 필드 생성
    features <- results$selected_features[results$selected_features != "업종"]
    
    # 입력 필드 리스트 생성
    input_fields <- lapply(features, function(feat) {
      # 수치형 변수는 숫자 입력으로 처리
      # 기본값은 해당 변수의 평균값
      default_val <- mean(results$processed_data[[feat]], na.rm = TRUE)
      numericInput(feat, paste0(feat, ":"), value = round(default_val, 2))
    })
    
    # 입력 필드를 격자 레이아웃으로 배치
    do.call(fluidRow, lapply(input_fields, function(field) {
      column(width = 4, field)
    }))
  })
  
  # 예측값에 대한 시각화 추가
  output$prediction_visual <- renderPlot({
    req(input$predict_btn)
    
    # 신용등급 범위
    all_ratings <- c("D", "C", "CC", "CCC-", "CCC", "CCC+",
                    "B-", "B", "B+", "BB-", "BB", "BB+", "BBB-", "BBB", "BBB+",
                    "A-", "A", "A+", "AA-", "AA", "AA+", "AAA")
    
    # 기존 데이터의 등급 분포
    rating_distribution <- table(results$raw_data$Bond_Mean)
    rating_df <- data.frame(
      Rating = names(rating_distribution),
      Count = as.numeric(rating_distribution)
    )
    
    # 입력 데이터 수집 (업종 제외)
    features <- results$selected_features[results$selected_features != "업종"]
    new_data <- sapply(features, function(feat) {
      input[[feat]]
    })
    
    # 데이터프레임으로 변환
    new_data_df <- as.data.frame(t(new_data))
    colnames(new_data_df) <- features
    
    # 업종 추가
    if ("업종" %in% results$selected_features) {
      most_common_industry <- names(sort(table(results$raw_data$업종), decreasing = TRUE)[1])
      new_data_df$업종 <- most_common_industry
    }
    
    # 예측
    prediction <- results$predict_function(new_data_df)
    pred_rating <- prediction$rating
    
    # 예측 등급 시각화
    ggplot() +
      geom_bar(data = rating_df, aes(x = Rating, y = Count, fill = "기존 데이터"), stat = "identity", alpha = 0.5) +
      geom_vline(xintercept = which(all_ratings == pred_rating), color = "red", size = 1.5) +
      geom_text(aes(x = which(all_ratings == pred_rating), y = max(rating_df$Count) * 0.8, 
                   label = paste("예측 등급:", pred_rating)), color = "red", hjust = -0.1) +
      scale_fill_manual(values = c("기존 데이터" = "steelblue")) +
      labs(title = "신용등급 분포 및 예측 결과",
           x = "신용등급", y = "기업 수", fill = "") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # 예측 버튼 이벤트 처리
  observeEvent(input$predict_btn, {
    tryCatch({
      # 입력 데이터 수집 (업종 제외)
      features <- results$selected_features[results$selected_features != "업종"]
      new_data <- sapply(features, function(feat) {
        input[[feat]]
      })
      
      # 데이터프레임으로 변환
      new_data_df <- as.data.frame(t(new_data))
      colnames(new_data_df) <- features
      
      # 필요한 특성 확인
      missing_features <- setdiff(results$selected_features, c(names(new_data_df), "업종"))
      
      # 업종에 기본값 추가 (가장 많은 업종 사용)
      if ("업종" %in% results$selected_features) {
        most_common_industry <- names(sort(table(results$raw_data$업종), decreasing = TRUE)[1])
        new_data_df$업종 <- most_common_industry
      }
      
      # 누락된 다른 특성이 있으면 평균값 추가
      for (feat in missing_features) {
        if (feat != "업종") {
          new_data_df[[feat]] <- mean(results$processed_data[[feat]], na.rm = TRUE)
        }
      }
      
      # 신용등급 예측
      prediction <- results$predict_function(new_data_df)
      
      # 결과 표시
      output$predicted_rating <- renderValueBox({
        rating_color <- switch(
          substr(prediction$rating, 1, 1),
          "A" = "green",
          "B" = "blue",
          "C" = "yellow",
          "D" = "red",
          "purple"
        )
        
        valueBox(
          prediction$rating,
          "예측 신용등급",
          icon = icon("chart-line"),
          color = rating_color
        )
      })
      
      output$prediction_details <- renderPrint({
        cat("예측 신용등급:", prediction$rating, "\n")
        cat("수치형 등급:", round(prediction$numeric_rating, 3), "\n\n")
        cat("입력된 주요 특성:\n")
        
        # 중요도에 따른 특성 순서 (varImp로 가져올 수 있다면)
        important_features <- NULL
        if (inherits(results$best_model, "train")) {
          importance_data <- varImp(results$best_model)$importance
          importance_data$Feature <- rownames(importance_data)
          importance_data <- importance_data %>% 
            arrange(desc(Overall))
          important_features <- importance_data$Feature[1:min(5, nrow(importance_data))]
        } else {
          important_features <- features[1:min(5, length(features))]
        }
        
        for (feat in important_features) {
          if (feat %in% names(new_data_df)) {
            cat(feat, ":", round(new_data_df[[feat]], 4), "\n")
          }
        }
      })
    }, error = function(e) {
      output$prediction_details <- renderPrint({
        cat("예측 중 오류가 발생했습니다:", conditionMessage(e), "\n")
        cat("모든 필요한 입력값이 제대로 입력되었는지 확인하세요.")
      })
    })
  })
}

# Shiny 앱 실행
shinyApp(ui = ui, server = server)

# 메인 함수 내에서 결과 저장
saveRDS(results, "credit_model_results.rds")
