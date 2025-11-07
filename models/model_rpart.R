## models/model_rpart.R
cat('Entrenando Decision Tree (rpart)...\n')

# Grid para CP (complexity parameter)
tune_grid_rpart <- expand.grid(cp = c(0.001, 0.01, 0.1))

# ⭐ Entrenar con manejo de errores
results[['rpart']] <- tryCatch({
  train_and_time(
    method = 'rpart',
    tuneGrid = tune_grid_rpart,
    metric = if(problem_type == 'classification') 'ROC' else 'RMSE'
  )
}, error = function(e){
  cat('  ⚠ rpart falló:', conditionMessage(e), '\n')
  cat('  Intentando con parámetros por defecto...\n')
  
  # Intento con parámetros simples
  train_and_time(
    method = 'rpart',
    tuneGrid = expand.grid(cp = 0.01),
    metric = if(problem_type == 'classification') 'ROC' else 'RMSE'
  )
})

cat('✓ Decision Tree OK\n')

if(exists('SAVE_MODELS') && SAVE_MODELS){
  if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
  saveRDS(results$rpart, file = file.path(models_dir, 'rpart.rds'))
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)