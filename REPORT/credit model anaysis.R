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
   saveRDS(best_model, "best_credit_rating_model.rds")
   saveRDS(selected_features, "selected_features.rds")
   saveRDS(modeling_df, "model_reference_data.rds")
   
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