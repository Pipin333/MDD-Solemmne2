## models/model_knn.R
if(!exists('train_and_time')) stop('Source 03_utils.R antes de ejecutar modelos')

if(exists('problem_type') && problem_type=='regression'){
  results$knn <- train_and_time('knn', tuneGrid = expand.grid(k = c(3,5,7)), metric='RMSE')
} else {
  results$knn <- train_and_time('knn', tuneGrid = expand.grid(k = c(3,5,7)), metric=if(ctrl$summaryFunction==twoClassSummary) 'ROC' else 'Accuracy')
}
if(exists('SAVE_MODELS') && SAVE_MODELS){
  if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
  saveRDS(results$knn, file = file.path(models_dir, 'knn.rds'))
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)