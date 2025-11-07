## models/model_glm_lm.R
# Entrena regresión lineal (regression) o regresión logística (classification)
if(!exists('train_df')) stop('Cargue los datos antes (source 02_load_prep.R)')
if(!exists('train_and_time')) stop('Source 03_utils.R antes de ejecutar modelos')

if(exists('problem_type') && problem_type=='regression'){
  results$lm <- train_and_time('lm', metric = 'RMSE')
  if(exists('SAVE_MODELS') && SAVE_MODELS){
    if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
    saveRDS(results$lm, file = file.path(models_dir, 'lm.rds'))
  }
} else {
  results$glm <- train_and_time('glm', metric = if(ctrl$summaryFunction==twoClassSummary) 'ROC' else 'Accuracy')
  if(exists('SAVE_MODELS') && SAVE_MODELS){
    if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
    saveRDS(results$glm, file = file.path(models_dir, 'glm.rds'))
  }
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)