## models/model_rf.R
cat('Entrenando Random Forest...\n')

# Grid reducido
tune_grid_rf <- expand.grid(mtry = c(2, 3))

# ⭐ FIX: ntree NO es parte del tuneGrid, va aparte
results[['rf']] <- train_and_time(
  method = 'rf',
  tuneGrid = tune_grid_rf,
  metric = if(problem_type == 'classification') 'ROC' else 'RMSE'
)

# Modificar el modelo para reducir número de árboles (DESPUÉS de entrenar)
if(!is.null(results[['rf']]$model$finalModel)){
  # Limpiar objetos pesados
  results[['rf']]$model$finalModel$y <- NULL
  results[['rf']]$model$finalModel$predicted <- NULL
  results[['rf']]$model$finalModel$oob.times <- NULL
  results[['rf']]$model$finalModel$votes <- NULL
}

cat('✓ Random Forest OK\n')
gc(verbose = FALSE, full = TRUE)