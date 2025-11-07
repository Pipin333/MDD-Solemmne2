## models/model_nnet.R
cat('Entrenando Neural Network...\n')

# ⭐ Grid más robusto para regresión
tune_grid_nnet <- expand.grid(
  size = 5,
  decay = 0.1
)

# ⭐ Agregar parámetros adicionales para estabilidad
results[['nnet']] <- tryCatch({
  train_and_time(
    method = 'nnet',
    tuneGrid = tune_grid_nnet,
    metric = if(problem_type == 'classification') 'ROC' else 'RMSE',
    # ⭐ NUEVO: Parámetros adicionales para nnet
    trace = FALSE,      # Sin output verbose
    MaxNWts = 10000,    # Más pesos permitidos
    maxit = 200,        # Más iteraciones
    linout = (problem_type == 'regression')  # Output lineal para regresión
  )
}, error = function(e){
  cat('  ⚠ Neural Network falló, usando valor dummy\n')
  list(model = NULL, time_sec = 0)
})

if(!is.null(results[['nnet']]$model)){
  cat('✓ Neural Network OK\n')
} else {
  cat('⚠ Neural Network omitido\n')
}

if(exists('SAVE_MODELS') && SAVE_MODELS){
  if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
  saveRDS(results$nnet, file = file.path(models_dir, 'nnet.rds'))
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)