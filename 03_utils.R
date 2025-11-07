## 03_utils.R
# Control de validación y funciones comunes
if(!exists('train_df')) stop('Ejecute 02_load_prep.R primero')

# ⭐ CONFIGURACIÓN BALANCEADA
cv_folds <- 7  # 7 folds = buen balance entre velocidad y validación

ctrl <- caret::trainControl(
  method = 'cv', 
  number = cv_folds,
  savePredictions = FALSE,     # No guardar predicciones (ahorra RAM)
  returnData = FALSE,          # No guardar datos (ahorra RAM)
  returnResamp = 'none',       # No guardar resamples (ahorra RAM)
  classProbs = (exists('problem_type') && problem_type=='classification'),
  summaryFunction = if(exists('problem_type') && problem_type=='classification') twoClassSummary else defaultSummary,
  allowParallel = TRUE,        # ⭐ HABILITAR paralelización INTERNA
  trim = TRUE,                 # Recortar objetos innecesarios
  verboseIter = FALSE
)

if(exists('problem_type') && problem_type=='classification' && length(levels(train_df[[target_var]]))>2){
  ctrl$summaryFunction <- defaultSummary
}

preprocess_steps <- c('center','scale')

# ⭐ FIX: Aceptar ... para parámetros adicionales del modelo
train_and_time <- function(method, tuneGrid = NULL, metric = NULL, ...){
  # Limpieza antes
  gc(verbose = FALSE, full = FALSE)
  
  cat('  Entrenando:', method, '...')
  
  t0 <- Sys.time()
  
  m <- suppressWarnings({
    caret::train(
      as.formula(paste(target_var, '~ .')),
      data = train_df,
      method = method,
      preProcess = preprocess_steps,
      trControl = ctrl,
      tuneGrid = tuneGrid,
      metric = metric,
      ...  # ⭐ NUEVO: Pasar argumentos extra (trace, MaxNWts, etc.)
    )
  })
  
  t1 <- Sys.time()
  duration <- as.numeric(difftime(t1,t0,units='secs'))
  
  # Limpiar modelo para ahorrar RAM
  m$control$indexOut <- NULL
  m$control$index <- NULL
  m$trainingData <- NULL
  
  # Limpiar modelos específicos
  if(!is.null(m$finalModel)){
    if(inherits(m$finalModel, 'randomForest')){
      m$finalModel$y <- NULL
      m$finalModel$predicted <- NULL
      m$finalModel$oob.times <- NULL
      m$finalModel$votes <- NULL
    }
    if(inherits(m$finalModel, 'ksvm')){
      # ⭐ FIX: No intentar limpiar kcall si causa error
      tryCatch({
        m$finalModel@kcall <- NULL
      }, error = function(e) {})
    }
  }
  
  cat(' ✓ (', round(duration, 1), 's)\n', sep='')
  
  result <- list(model = m, time_sec = duration)
  
  # Limpieza después
  rm(m)
  gc(verbose = FALSE, full = FALSE)
  
  return(result)
}

results <- list()