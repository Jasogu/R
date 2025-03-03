library(readxl)
library(MASS)
library(tidyverse)
library(stringr)
library(readr)
library(randomForest)
library(gbm) 
library(nnet)
library(e1071)
library(caret)



select <- dplyr::select

df <- read_excel("credit data.xlsx")


# Function to handle outliers in financial data
handle_outliers <- function(df, cols, method = "winsorize", threshold = 3) {
   for (col in cols) {
      if (method == "winsorize") {
         # Winsorization - cap extreme values at specified quantiles
         q_low <- quantile(df[[col]], 0.05, na.rm = TRUE)
         q_high <- quantile(df[[col]], 0.95, na.rm = TRUE)
         df[[col]] <- ifelse(df[[col]] < q_low, q_low, df[[col]])
         df[[col]] <- ifelse(df[[col]] > q_high, q_high, df[[col]])
      } else if (method == "z-score") {
         # Z-score method - remove or cap values beyond threshold standard deviations
         z_scores <- scale(df[[col]])
         df[[col]] <- ifelse(abs(z_scores) > threshold, 
                             sign(z_scores) * threshold * sd(df[[col]], na.rm = TRUE) + mean(df[[col]], na.rm = TRUE), 
                             df[[col]])
      }
   }
   return(df)
}

# Function to evaluate model performance
evaluate_model <- function(actual, predicted, print_results = TRUE) {
   # Convert predicted values to the same scale as actual if necessary
   if (is.factor(actual) && is.numeric(predicted)) {
      predicted_factor <- cut(predicted, 
                              breaks = c(0, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 
                                         11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5, 18.5, 19.5, 
                                         20.5, 21.5, 22.5),
                              labels = levels(actual))
      confusion_matrix <- confusionMatrix(predicted_factor, actual)
   } else {
      # For regression evaluation
      rmse <- sqrt(mean((actual - predicted)^2))
      mae <- mean(abs(actual - predicted))
      correlation <- cor(actual, predicted)
      r_squared <- cor(actual, predicted)^2
      
      # For ordinal outcomes, calculate weighted Kappa
      if (is.factor(actual) && is.factor(predicted)) {
         wk <- weighted.kappa(actual, predicted)
      } else {
         wk <- NA
      }
      
      # Calculate mean absolute error in terms of rating notches
      if (is.numeric(actual) && is.numeric(predicted)) {
         notch_error <- mean(abs(round(predicted) - actual))
      } else {
         notch_error <- NA
      }
      
      results <- list(
         RMSE = rmse,
         MAE = mae,
         Correlation = correlation,
         R_Squared = r_squared,
         Weighted_Kappa = wk,
         Notch_Error = notch_error
      )
      
      if (print_results) {
         cat("Model Evaluation Results:\n")
         cat("RMSE:", rmse, "\n")
         cat("MAE:", mae, "\n")
         cat("Correlation:", correlation, "\n")
         cat("R-Squared:", r_squared, "\n")
         if (!is.na(wk)) cat("Weighted Kappa:", wk, "\n")
         if (!is.na(notch_error)) cat("Mean Notch Error:", notch_error, "\n")
      }
      
      return(results)
   }
}

# Function to perform feature selection
select_features <- function(df, target_col, method = "correlation", threshold = 0.1) {
   if (method == "correlation") {
      # Correlation-based feature selection
      correlations <- sapply(df %>% select(-all_of(target_col)), function(x) {
         if (is.numeric(x)) {
            return(abs(cor(x, df[[target_col]], use = "pairwise.complete.obs")))
         } else {
            return(0)
         }
      })
      
      selected_features <- names(correlations[correlations > threshold])
      return(selected_features)
      
   } else if (method == "random_forest") {
      # Random Forest feature importance
      rf_model <- randomForest(as.formula(paste(target_col, "~ .")), 
                               data = df, 
                               ntree = 100, 
                               importance = TRUE)
      
      importance <- importance(rf_model)
      selected_features <- rownames(importance)[order(importance[, "%IncMSE"], decreasing = TRUE)[1:min(10, nrow(importance))]]
      return(selected_features)
   }
}

# Function to train and compare multiple models
train_compare_models <- function(df, target_col, features, n_folds = 5, n_repeats = 10) {
   # Create formula
   formula_str <- paste(target_col, "~", paste(features, collapse = " + "))
   formula_obj <- as.formula(formula_str)
   
   # Setup repeated cross-validation
   ctrl <- trainControl(
      method = "repeatedcv",
      number = n_folds,
      repeats = n_repeats,
      verboseIter = FALSE
   )
   
   # Train multiple models
   models <- list()
   
   # Random Forest
   rf_grid <- expand.grid(
      mtry = c(floor(sqrt(length(features))), floor(length(features)/3), floor(length(features)/2))
   )
   
   models$rf <- train(
      formula_obj,
      data = df,
      method = "rf",
      tuneGrid = rf_grid,
      trControl = ctrl,
      importance = TRUE
   )
   
   # Gradient Boosting
   gbm_grid <- expand.grid(
      n.trees = c(100, 200),
      interaction.depth = c(3, 5),
      shrinkage = 0.1,
      n.minobsinnode = 10
   )
   
   models$gbm <- train(
      formula_obj,
      data = df,
      method = "gbm",
      tuneGrid = gbm_grid,
      trControl = ctrl,
      verbose = FALSE
   )
   
   # Support Vector Regression
   svr_grid <- expand.grid(
      C = c(0.1, 1, 10),
      sigma = c(0.01, 0.1)
   )
   
   models$svr <- train(
      formula_obj,
      data = df,
      method = "svmRadial",
      tuneGrid = svr_grid,
      trControl = ctrl
   )
   
   # Compare models
   resamps <- resamples(models)
   summary <- summary(resamps)
   
   # Return models and comparison results
   return(list(
      models = models,
      comparison = summary
   ))
}

# Main workflow
main <- function() {
   # Handle outliers in financial ratios
   financial_cols <- colnames(df)[6:23]
   df <- handle_outliers(df, financial_cols, method = "winsorize")
   
   # Save raw processed data
   df_raw <- df
   
   # Prepare data for modeling
   df$Bond_Mean <- factor(df$Bond_Mean, levels = c("D", "C", "CC", "CCC-", "CCC", "CCC+",
                                                   "B-","B","B+","BB-","BB","BB+","BBB-","BBB","BBB+",
                                                   "A-","A","A+","AA-","AA","AA+","AAA"), 
                          ordered = TRUE)
   
   df$업종 <- as.factor(df$업종)
   
   # Select features and prepare modeling dataset
   modeling_df <- df %>% select(-종목코드, -회사명, -시장)
   
   # Convert ordered factor to numeric for regression
   modeling_df$Bond_Mean_Numeric <- as.numeric(modeling_df$Bond_Mean)
   
   # Scale features
   modeling_df_scaled <- modeling_df %>% 
      mutate(across(-c(Bond_Mean, Bond_Mean_Numeric, 업종), 
                    ~ (. - min(., na.rm = TRUE)) / 
                       (max(., na.rm = TRUE) - min(., na.rm = TRUE))))
   
   # Standardize features
   modeling_df_standardized <- modeling_df_scaled %>%
      mutate(across(-c(Bond_Mean, Bond_Mean_Numeric, 업종), 
                    ~ (. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)))
   
   modeling_df_for_selection <- modeling_df_standardized %>% 
      select(-업종, -Bond_Mean) %>% 
      rename(target = Bond_Mean_Numeric)
   
   # Feature selection
   selected_features <- select_features(
      modeling_df_standardized %>% select(-Bond_Mean) %>% rename(target = Bond_Mean_Numeric),
      "target", 
      method = "random_forest"
   )
   
   cat("Selected features:", paste(selected_features, collapse = ", "), "\n")
   
   # Split data for validation
   set.seed(123)
   train_idx <- createDataPartition(modeling_df_standardized$Bond_Mean_Numeric, p = 0.8, list = FALSE)
   train_data <- modeling_df_standardized[train_idx, ]
   test_data <- modeling_df_standardized[-train_idx, ]
   
   # Train and compare models
   model_results <- train_compare_models(
      train_data %>% select(c(selected_features, "Bond_Mean_Numeric")) %>% rename(target = Bond_Mean_Numeric),
      "target",
      selected_features
   )
   
   # Print model comparison
   print(model_results$comparison)
   
   # Evaluate best model on test data
   best_model_name <- names(model_results$models)[which.min(sapply(model_results$models, function(x) min(x$results$RMSE)))]
   best_model <- model_results$models[[best_model_name]]
   
   cat("Best model:", best_model_name, "\n")
   
   # Make predictions on test data
   predictions <- predict(best_model, newdata = test_data %>% select(all_of(selected_features)))
   
   # Evaluate predictions
   evaluation <- evaluate_model(test_data$Bond_Mean_Numeric, predictions)
   
   # Create a function for predicting new companies
   predict_credit_rating <- function(new_data) {
      # Preprocess new data
      new_data_processed <- new_data
      
      # Scale and standardize
      for (col in selected_features) {
         if (col %in% colnames(new_data_processed)) {
            # Scale
            new_data_processed[[col]] <- (new_data_processed[[col]] - min(modeling_df[[col]], na.rm = TRUE)) / 
               (max(modeling_df[[col]], na.rm = TRUE) - min(modeling_df[[col]], na.rm = TRUE))
            
            # Standardize
            new_data_processed[[col]] <- (new_data_processed[[col]] - mean(modeling_df_scaled[[col]], na.rm = TRUE)) / 
               sd(modeling_df_scaled[[col]], na.rm = TRUE)
         }
      }
      
      # Make prediction
      pred_numeric <- predict(best_model, newdata = new_data_processed %>% select(all_of(selected_features)))
      
      # Convert numeric prediction to rating
      pred_rounded <- round(pred_numeric)
      pred_rating <- sapply(pred_rounded, function(x) {
         if (x < 1) x <- 1
         if (x > 22) x <- 22
         convert_numeric_to_rating(x)
      })
      
      return(list(
         numeric_rating = pred_numeric,
         rating = pred_rating
      ))
   }
   
   # Save models and functions for later use
   #saveRDS(best_model, "best_credit_rating_model.rds")
   #saveRDS(selected_features, "selected_features.rds")
   #saveRDS(modeling_df, "model_reference_data.rds")
   
   # Return results
   return(list(
      raw_data = df_raw,
      processed_data = modeling_df_standardized,
      model_comparison = model_results$comparison,
      best_model = best_model,
      best_model_name = best_model_name,
      selected_features = selected_features,
      test_evaluation = evaluation,
      predict_function = predict_credit_rating
   ))
}

# Stop the cluster when done
# on.exit(stopCluster(cl))

# Run the main workflow
results <- main()

# Print a summary of results
cat("\n===== Credit Rating Prediction Model Summary =====\n")
cat("Data dimensions:", dim(results$raw_data)[1], "companies,", dim(results$raw_data)[2], "variables\n")
cat("Selected features:", paste(results$selected_features, collapse = ", "), "\n")
cat("Best model:", results$best_model_name, "\n")
cat("Test RMSE:", results$test_evaluation$RMSE, "\n")
cat("Test correlation:", results$test_evaluation$Correlation, "\n")
cat("Mean notch error:", results$test_evaluation$Notch_Error, "\n")
cat("=================================================\n")

# Example of how to use the prediction function
# new_company <- data.frame(
#   유동비율 = 1.5,
#   당좌비율 = 1.2,
#   부채비율 = 1.8,
#   ...
# )
# prediction <- results$predict_function(new_company)
# print(prediction$rating)




# 결과 시각화 함수
visualize_results <- function(results) {
   library(ggplot2)
   library(gridExtra)
   library(viridis)
   library(caret) # varImp 함수를 위해 추가
   
   # 1. 모델 성능 비교 시각화
   resamps <- results$model_comparison
   
   # 리샘플링 결과 데이터 준비
   resamps_data <- as.data.frame(resamps$values)
   metrics_long <- resamps_data %>%
      pivot_longer(cols = everything(),
                   names_to = c("Model", "Metric"),
                   names_pattern = "([^.]+)\\.(.*)",
                   values_to = "Value")
   
   
   # 2. 특성 중요도 시각화 - 다양한 모델 유형 처리
   # 변수 중요도를 얻는 안전한 방법
   tryCatch({
      if (inherits(results$best_model, "train")) {
         # caret 모델인 경우
         importance_data <- varImp(results$best_model)$importance
         importance_data$Feature <- rownames(importance_data)
         importance_col <- "Overall"
      } else if (results$best_model_name == "rf" && "randomForest" %in% class(results$best_model)) {
         # randomForest 패키지 모델인 경우
         importance_data <- as.data.frame(randomForest::importance(results$best_model))
         importance_data$Feature <- rownames(importance_data)
         importance_col <- "%IncMSE"
      } else {
         # 다른 모델 유형이거나 중요도를 얻을 수 없는 경우
         importance_data <- NULL
      }
      
      if (!is.null(importance_data) && importance_col %in% colnames(importance_data)) {
         
         p2 <- ggplot(importance_data %>% 
                         arrange(desc(!!sym(importance_col))) %>% 
                         head(10), 
                      aes(x = reorder(Feature, !!sym(importance_col)), 
                          y = !!sym(importance_col), 
                          fill = !!sym(importance_col))) +
            geom_bar(stat = "identity") +
            coord_flip() +
            labs(title = "특성 중요도",
                 x = "", y = "중요도") +
            theme_minimal() +
            theme(legend.position = "none") +
            scale_fill_viridis_c()
      } else {
         # 선택된 특성 시각화 (중요도 정보가 없는 경우)
         selected_features <- data.frame(
            Feature = results$selected_features,
            Importance = seq(length(results$selected_features), 1, -1)
         )
         
         p2 <- ggplot(selected_features, 
                      aes(x = reorder(Feature, Importance), y = Importance, fill = Importance)) +
            geom_bar(stat = "identity") +
            coord_flip() +
            labs(title = "선택된 특성",
                 x = "", y = "선택 순서") +
            theme_minimal() +
            theme(legend.position = "none") +
            scale_fill_viridis_c()
      }
   }, error = function(e) {
      # 오류 발생 시 기본 특성 시각화
      selected_features <- data.frame(
         Feature = results$selected_features,
         Importance = seq(length(results$selected_features), 1, -1)
      )
      
      p2 <<- ggplot(selected_features, 
                    aes(x = reorder(Feature, Importance), y = Importance, fill = Importance)) +
         geom_bar(stat = "identity") +
         coord_flip() +
         labs(title = "선택된 특성",
              x = "", y = "선택 순서") +
         theme_minimal() +
         theme(legend.position = "none") +
         scale_fill_viridis_c()
   })
   
   # 3. 예측 vs 실제 값 산점도
   # train_idx가 정의되지 않은 경우 처리
   if (!exists("train_idx") && "train_indices" %in% names(results)) {
      train_idx <- results$train_indices
   } else if (!exists("train_idx")) {
      # 임의로 70% 훈련 데이터 생성
      set.seed(123)
      train_idx <- sample(1:nrow(results$processed_data), 
                          size = floor(0.7 * nrow(results$processed_data)))
   }
   
   test_data <- results$processed_data[-train_idx, ]
   
   # 예측 수행
   tryCatch({
      predictions <- predict(results$best_model, 
                             newdata = test_data %>% select(all_of(results$selected_features)))
      
      pred_vs_actual <- data.frame(
         Actual = test_data$Bond_Mean_Numeric,
         Predicted = predictions
      )
      
      p3 <- ggplot(pred_vs_actual, aes(x = Actual, y = Predicted)) +
         geom_point(alpha = 0.6, color = "darkblue") +
         geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
         labs(title = "예측 vs 실제 신용등급",
              x = "실제 등급", y = "예측 등급") +
         theme_minimal() +
         annotate("text", x = min(pred_vs_actual$Actual), y = max(pred_vs_actual$Predicted),
                  label = paste("상관계수:", round(results$test_evaluation$Correlation, 3)),
                  hjust = 0, vjust = 1)
      
      # 4. 오차 분포 히스토그램
      error_data <- data.frame(
         Error = predictions - test_data$Bond_Mean_Numeric
      )
      
      p4 <- ggplot(error_data, aes(x = Error)) +
         geom_histogram(bins = 20, fill = "steelblue", color = "white") +
         labs(title = "예측 오차 분포",
              x = "예측 오차 (예측값 - 실제값)", y = "빈도") +
         theme_minimal() +
         geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
         annotate("text", x = max(error_data$Error) * 0.8, y = 5,
                  label = paste("평균 오차:", round(mean(error_data$Error), 3),
                                "\nMAE:", round(results$test_evaluation$MAE, 3)),
                  hjust = 1)
   }, error = function(e) {
      # 예측 오류 시 더미 그래프 생성
      p3 <<- ggplot() + 
         annotate("text", x = 0.5, y = 0.5, label = "예측 데이터를 생성할 수 없습니다") +
         theme_void()
      
      p4 <<- ggplot() + 
         annotate("text", x = 0.5, y = 0.5, label = "오차 데이터를 생성할 수 없습니다") +
         theme_void()
   })
   
   # 5. 업종별 신용등급 분포
   tryCatch({
      industry_ratings <- results$raw_data %>%
         group_by(업종) %>%
         summarise(
            평균등급 = mean(as.numeric(factor(Bond_Mean)), na.rm = TRUE),
            기업수 = n()
         ) %>%
         arrange(desc(평균등급))
      
      p5 <- ggplot(industry_ratings %>% head(15), 
                   aes(x = reorder(업종, 평균등급), y = 평균등급, fill = 기업수)) +
         geom_bar(stat = "identity") +
         coord_flip() +
         labs(title = "업종별 평균 신용등급 (상위 15개)",
              x = "", y = "평균 신용등급") +
         theme_minimal() +
         scale_fill_viridis_c(name = "기업 수")
   }, error = function(e) {
      p5 <<- ggplot() + 
         annotate("text", x = 0.5, y = 0.5, label = "업종별 데이터를 생성할 수 없습니다") +
         theme_void()
   })
   
   # 그래프 배치 및 출력
   grid.arrange(p2, p3, p4, p5, ncol = 2)
   
}

visualize_results(results)

# results$best_model
