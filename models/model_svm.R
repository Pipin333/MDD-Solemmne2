## models/model_svm.R
cat('Entrenando SVM...\n')

# Grid reducido para velocidad
tune_grid_svm <- expand.grid(
  C = 1,
  sigma = 0.1
)

# ⭐ Entrenar con manejo de errores
results[['svm']] <- tryCatch({
  suppressWarnings({
    train_and_time(
      method = 'svmRadial',
      tuneGrid = tune_grid_svm,
      metric = if(problem_type == 'classification') 'ROC' else 'RMSE'
    )
  })
}, error = function(e){
  cat('  ⚠ SVM falló:', conditionMessage(e), '\n')
  list(model = NULL, time_sec = 0)
})

if(!is.null(results[['svm']]$model)){
  cat('✓ SVM OK\n')
} else {
  cat('⚠ SVM omitido\n')
}

if(exists('SAVE_MODELS') && SAVE_MODELS){
  if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
  saveRDS(results$svm, file = file.path(models_dir, 'svm.rds'))
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)