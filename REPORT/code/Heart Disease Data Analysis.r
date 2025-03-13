# 심장 질환 데이터 분석 (R 언어)
# 이 스크립트는 HeartDisease를 목표 변수로 하여 heart_2020_cleaned.csv 데이터셋을 분석

# 필요한 패키지 로드
library(tidyverse)
library(corrplot)
library(ggplot2)
library(caret)
library(randomForest)
library(pROC)
library(doParallel)
library(ggVennDiagram)
library(ggplot2)

#devtools::install_github("gaospecial/ggVennDiagram")

# 병렬 처리 설정 (더 강력한 접근 방식)
n_cores <- parallel::detectCores() - 1
cl <- makeCluster(n_cores)
registerDoParallel(cl)

# 재현성을 위한 난수 시드 설정
set.seed(123)

# 데이터셋 읽기
heart_data <- read.csv("data/heart_2020_cleaned.csv", stringsAsFactors = TRUE)
#heart_data <- heart_2020_cleaned

# 1. 탐색적 데이터 분석
# 데이터셋 구조 표시
str(heart_data)

# 요약 통계
summary(heart_data)

# 결측치 확인
missing_values <- colSums(is.na(heart_data))
print("열별 결측치:")
print(missing_values)

# HeartDisease를 요인으로 변환 (아직 변환되지 않은 경우)
heart_data$HeartDisease <- as.factor(heart_data$HeartDisease)
# 목표 변수의 클래스 분포 확인
table(heart_data$HeartDisease)
prop.table(table(heart_data$HeartDisease)) * 100

# 2. 데이터 시각화

# 연령 카테고리별 심장 질환 분포
ggplot(heart_data, aes(x = AgeCategory, fill = HeartDisease)) +
   geom_bar(position = "fill") +
   theme_minimal() +
   labs(title = "연령 카테고리별 심장 질환 비율",
        x = "연령 카테고리", 
        y = "비율") +
   theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 성별에 따른 심장 질환 분포
ggplot(heart_data, aes(x = Sex, fill = HeartDisease)) +
   geom_bar(position = "fill") +
   theme_minimal() +
   labs(title = "성별에 따른 심장 질환 비율",
        x = "성별", 
        y = "비율")

# BMI에 따른 심장 질환 분포 (박스플롯 사용)
ggplot(heart_data, aes(x = HeartDisease, y = BMI)) +
   geom_boxplot() +
   theme_minimal() +
   labs(title = "심장 질환 상태에 따른 BMI 분포",
        x = "심장 질환", 
        y = "BMI")

# 흡연 상태에 따른 심장 질환 분포
ggplot(heart_data, aes(x = Smoking, fill = HeartDisease)) +
   geom_bar(position = "fill") +
   theme_minimal() +
   labs(title = "흡연 상태에 따른 심장 질환 비율",
        x = "흡연 상태", 
        y = "비율")


# 벤다이어 그램 생성
# 데이터 준비
heart_disease <- which(heart_data$HeartDisease == 1 | heart_data$HeartDisease == "Yes")
stroke <- which(heart_data$Stroke == 1 | heart_data$Stroke == "Yes")
diabetic <- which(heart_data$Diabetic == 1 | heart_data$Diabetic == "Yes")

# 리스트 생성
disease_data <- list(
   "Heart Disease" = heart_disease,
   "Stroke" = stroke, 
   "Diabetic" = diabetic
)

# 벤다이어 그램 시각기능 추가
venn_plot <- ggVennDiagram(
   disease_data,
   label_alpha = 0.7,
   category.names = c("심장병", "뇌졸증", "당뇨병"),
   set_size = 10
) +
   scale_fill_gradient(
      low = "#E6F5FF", 
      high = "#3498DB",
      name = "Count"
   ) +
   scale_color_manual(values = c("#2C3E50", "#2C3E50", "#2C3E50")) +
   theme(
      legend.position = "right",
      panel.background = element_rect(fill = "white"),
      plot.background = element_rect(fill = "white", color = NA),
      plot.title = element_text(hjust = 0.5, size = 30, face = "bold")
   ) +
   labs(
      title = "심장병, 뇌졸중, 당뇨병 벤다이어 그램"
   )

# 출력
venn_plot

# 3. 수치형 변수에 대한 상관관계 분석
# 상관관계 분석을 위해 수치형 변수만 선택
numeric_vars <- heart_data %>% 
   select_if(is.numeric)

# 상관관계 행렬 계산
cor_matrix <- cor(numeric_vars, use = "complete.obs")

# 상관관계 행렬 시각화
corrplot(cor_matrix, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45)

# 4. 위험 요인 분석

# 범주형 변수를 요인으로 변환 (아직 변환되지 않은 경우)
categorical_vars <- c("Smoking", "AlcoholDrinking", "Stroke", "DiffWalking", 
                      "Sex", "Race", "Diabetic", "PhysicalActivity", 
                      "GenHealth", "Asthma", "KidneyDisease", "SkinCancer")

for(var in categorical_vars) {
   heart_data[[var]] <- as.factor(heart_data[[var]])
}

# 범주형 변수에 대한 카이제곱 검정 - future_lapply 대신 lapply 사용
chi_square_results <- lapply(categorical_vars, function(var) {
   test_result <- chisq.test(table(heart_data[[var]], heart_data$HeartDisease))
   return(data.frame(Variable = var, P_Value = test_result$p.value))
})
chi_square_results <- do.call(rbind, chi_square_results)
chi_square_results <- chi_square_results %>% arrange(P_Value)

print("범주형 변수에 대한 카이제곱 검정 결과:")
print(chi_square_results)

# 수치형 변수에 대한 t-검정 - future_lapply 대신 lapply 사용
numeric_vars_names <- names(numeric_vars)
t_test_results <- lapply(numeric_vars_names, function(var) {
   tryCatch({
      test_result <- t.test(heart_data[[var]] ~ heart_data$HeartDisease)
      return(data.frame(Variable = var, P_Value = test_result$p.value))
   }, error = function(e) {
      message(paste("변수에 대한 t-검정 오류:", var))
      message(e$message)
      return(data.frame(Variable = var, P_Value = NA))
   })
})
t_test_results <- do.call(rbind, t_test_results)

print("수치형 변수에 대한 t-검정 결과:")
print(t_test_results)

# 5. 예측 모델링
# 데이터를 훈련 및 테스트 세트로 분할
set.seed(123)  # 재현성을 위해 시드 다시 설정
train_indices <- createDataPartition(heart_data$HeartDisease, p = 0.7, list = FALSE)
train_data <- heart_data[train_indices, ]
test_data <- heart_data[-train_indices, ]

# 모델 적합 전 훈련 데이터의 NA 값 확인
if(any(is.na(train_data))) {
   print("경고: 훈련 데이터에 NA 값이 포함되어 있습니다. 결측치를 대체합니다...")
   preProc <- preProcess(train_data, method = c("knnImpute"))
   train_data <- predict(preProc, train_data)
   test_data <- predict(preProc, test_data)
}

# 클래스 불균형을 가중치로 처리하는 강력한 방법
# 클래스 가중치를 적절히 계산
class_weights <- if(is.factor(train_data$HeartDisease)) {
   classCounts <- table(train_data$HeartDisease)
   setNames(classCounts[1] / classCounts, names(classCounts))
} else {
   warning("HeartDisease가 요인이 아닙니다. 이진 가중치를 생성합니다.")
   c("No" = 1, "Yes" = sum(train_data$HeartDisease == "No") / sum(train_data$HeartDisease == "Yes"))
}

# 훈련용 모델 가중치 생성
model_weights <- ifelse(train_data$HeartDisease == "Yes", 
                        class_weights["Yes"], 
                        class_weights["No"])

# 교차 검증 설정
ctrl <- trainControl(
   method = "cv",
   number = 5,
   classProbs = TRUE,
   summaryFunction = twoClassSummary,  # 분류를 위해 twoClassSummary로 변경
   allowParallel = TRUE,
   savePredictions = "final"
)

# 교차 검증과 적절한 메트릭을 사용하여 랜덤 포레스트 훈련
print("교차 검증을 통한 랜덤 포레스트 모델 훈련 중...")
rf_model_cv <- try(
   train(
      x = train_data %>% select(-HeartDisease),
      y = train_data$HeartDisease,
      method = "rf",
      metric = "ROC",  # 불균형 데이터를 위해 Accuracy에서 ROC로 변경
      weights = model_weights,
      trControl = ctrl,
      tuneLength = 3,  # 처리 속도를 높이기 위해 튜닝 길이 감소
      ntree = 300      # 처리 속도를 높이기 위해 트리 수 감소
   )
)

# 교차 검증 모델이 실패하면 더 간단한 모델로 대체
if(inherits(rf_model_cv, "try-error")) {
   warning("교차 검증 모델이 실패했습니다. 더 간단한 모델로 대체합니다.")
   
   # 기본 랜덤 포레스트 모델 훈련
   rf_model <- randomForest(
      HeartDisease ~ ., 
      data = train_data, 
      importance = TRUE,
      ntree = 300,
      classwt = class_weights
   )
} else {
   # 교차 검증이 성공하면 해당 모델 사용
   print("교차 검증 성공.")
   print(rf_model_cv)
   rf_model <- rf_model_cv$finalModel
}

# 예측 수행
if(exists("rf_model_cv") && !inherits(rf_model_cv, "try-error")) {
   rf_predictions <- predict(rf_model_cv, test_data, type = "prob")[, "Yes"]
} else {
   rf_predictions <- predict(rf_model, test_data, type = "prob")[, "Yes"]
}

# 모델 평가
predicted_class <- ifelse(rf_predictions > 0.5, "Yes", "No")
predicted_class <- factor(predicted_class, levels = levels(test_data$HeartDisease))

# 혼동 행렬 생성
confusion_matrix <- confusionMatrix(predicted_class, test_data$HeartDisease)
print("랜덤 포레스트 모델 평가:")
print(confusion_matrix)

# ROC 곡선
roc_curve <- roc(as.numeric(test_data$HeartDisease == "Yes"), rf_predictions)
auc_value <- auc(roc_curve)
print(paste("AUC:", auc_value))

# ROC 곡선 그리기
plot(roc_curve, main = "심장 질환 예측을 위한 ROC 곡선")

# 최적 임계값 찾기
optimal_threshold <- coords(roc_curve, "best", best.method = "closest.topleft")$threshold
print(paste("최적 임계값:", optimal_threshold))

# 최적 임계값으로 예측
optimal_predicted_class <- ifelse(rf_predictions > optimal_threshold, "Yes", "No")
optimal_predicted_class <- factor(optimal_predicted_class, levels = levels(test_data$HeartDisease))
optimal_confusion_matrix <- confusionMatrix(optimal_predicted_class, test_data$HeartDisease)
print("최적 임계값을 적용한 랜덤 포레스트 모델 평가:")
print(optimal_confusion_matrix)

# 6. 특성 중요도
importance_df <- as.data.frame(importance(rf_model))
importance_df$Variable <- rownames(importance_df)

# 중요도별 정렬
importance_df <- importance_df %>% 
   arrange(desc(MeanDecreaseGini))

# 특성 중요도 시각화
ggplot(importance_df, aes(x = reorder(Variable, MeanDecreaseGini), y = MeanDecreaseGini)) +
   geom_bar(stat = "identity", fill = "steelblue") +
   coord_flip() +
   theme_minimal() +
   labs(title = "심장 질환 예측을 위한 특성 중요도",
        x = "변수", 
        y = "중요도 (지니 계수 평균 감소)")

# 7. 분석 결과 요약
cat("\n\n=== 분석 결과 요약 ===\n")
cat("1. 클래스 분포: \n")
print(prop.table(table(heart_data$HeartDisease)) * 100)

cat("\n2. 가장 중요한 위험 요인: \n")
print(head(chi_square_results, 5))
print(head(importance_df, 5))

cat("\n3. 모델 성능: \n")
print(paste("정확도:", confusion_matrix$overall["Accuracy"]))
print(paste("민감도:", confusion_matrix$byClass["Sensitivity"]))
print(paste("특이도:", confusion_matrix$byClass["Specificity"]))
print(paste("AUC:", auc_value))

cat("\n4. 최적 임계값을 적용한 모델 성능: \n")
print(paste("정확도:", optimal_confusion_matrix$overall["Accuracy"]))
print(paste("민감도:", optimal_confusion_matrix$byClass["Sensitivity"]))
print(paste("특이도:", optimal_confusion_matrix$byClass["Specificity"]))

# 교차 검증 결과가 있는 경우 표시
if(exists("rf_model_cv") && !inherits(rf_model_cv, "try-error")) {
   cat("\n5. 교차 검증 모델 성능: \n")
   print(rf_model_cv$results)
}

# 스크립트 종료 시 클러스터 중지
stopCluster(cl)




