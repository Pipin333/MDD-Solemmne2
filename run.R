## run_all (Si.R)
cat('========================================\n')
cat('Pipeline OPTIMIZADO para 8 hilos\n')
cat('========================================\n\n')

# 1. Setup
cat('PASO 1: Cargando configuración...\n')
source('01_setup.R')
cat('✓ Configuración cargada\n\n')

# 2. Datos
cat('PASO 2: Cargando datos...\n')
source('02_load_prep.R')
cat('✓ Datos:', nrow(train_df), 'train,', nrow(test_df), 'test\n')
cat('✓ Problema:', problem_type, '\n\n')

# 3. Utils
cat('PASO 3: Configurando validación...\n')
source('03_utils.R')
cat('✓ CV:', cv_folds, 'folds (con', PARALLEL_CORES, 'núcleos)\n\n')

# 4. ENTRENAMIENTO
cat('========================================\n')
cat('PASO 4: Entrenamiento de Modelos\n')
cat('========================================\n\n')

SKIP_MODELS <- c('model_glm_lm')

if(exists('SKIP_TRAIN') && SKIP_TRAIN){
  cat('⚠ Cargando modelos desde RDS...\n\n')
  models_rds <- list.files(models_dir, pattern = '\\.rds$', full.names = TRUE)
  
  for(f in models_rds){
    nm <- tools::file_path_sans_ext(basename(f))
    if(!(nm %in% SKIP_MODELS || paste0('model_', nm) %in% SKIP_MODELS)){
      cat('  📂', nm, '\n')
      results[[nm]] <- readRDS(f)
    }
  }
  cat('\n✓', length(results), 'modelos cargados\n\n')
  
} else {
  model_files <- list.files('models', pattern = '^model_.*\\.R$', full.names = TRUE)
  model_files <- model_files[!tools::file_path_sans_ext(basename(model_files)) %in% SKIP_MODELS]
  
  cat('📋 Modelos a entrenar:', length(model_files), '\n')
  for(f in model_files) cat('   -', basename(f), '\n')
  cat('\n💡 Estrategia: Entrenamiento secuencial con paralelización interna\n')
  cat('   Cada modelo usa', PARALLEL_CORES, 'núcleos en validación cruzada\n\n')
  
  for(i in seq_along(model_files)) {
    f <- model_files[i]
    model_name <- tools::file_path_sans_ext(basename(f))
    model_key <- gsub('model_', '', model_name)
    
    cat('──────────────────────────────────────\n')
    cat('[', i, '/', length(model_files), '] ', model_name, '\n', sep='')
    cat('──────────────────────────────────────\n')
    
    # ⭐ FIX: Guardar memoria ANTES en variable protegida
    mem_info_before <- gc(verbose = FALSE)
    mem_before_val <- sum(mem_info_before[,2])
    cat('  RAM:', round(mem_before_val, 0), 'MB\n')
    
    # Entrenar
    tryCatch({
      source(f)
      
      if(model_key %in% names(results)){
        # Guardar inmediatamente
        if(SAVE_MODELS){
          rds_path <- file.path(models_dir, paste0(model_key, '.rds'))
          
          minimal_model <- list(
            model = results[[model_key]]$model,
            time_sec = results[[model_key]]$time_sec
          )
          
          saveRDS(minimal_model, rds_path, compress = 'xz')
          results[[model_key]] <- minimal_model
          rm(minimal_model)
          
          cat('  💾 Guardado\n')
        }
      }
      
    }, error = function(e){
      cat('  ❌ ERROR:', conditionMessage(e), '\n')
    })
    
    # ⭐ FIX: Agregar mem_before_val a lista de protegidos
    essential <- c('model_files', 'i', 'f', 'model_name', 'model_key',
                   'train_df', 'test_df', 'target_var', 'ctrl', 'cv_folds',
                   'preprocess_steps', 'train_and_time', 'models_dir',
                   'SAVE_MODELS', 'SKIP_MODELS', 'output_dir', 'problem_type',
                   'data_path', 'results', 'PARALLEL_CORES',
                   'mem_before_val', 'mem_info_before')  # ⭐ AGREGADO
    
    rm(list = setdiff(ls(), essential))
    
    # 2 pasadas de gc
    for(j in 1:2) gc(reset = TRUE, full = TRUE)
    
    mem_info_after <- gc(verbose = FALSE)
    mem_after_val <- sum(mem_info_after[,2])
    
    cat('  🧹 Liberado:', round(mem_before_val - mem_after_val, 0), 'MB\n')
    cat('  RAM actual:', round(mem_after_val, 0), 'MB\n\n')
    
    # Pausa breve
    if(i < length(model_files)) Sys.sleep(1)
  }
  
  cat('──────────────────────────────────────\n')
  cat('✓ Entrenamiento completado:', length(results), 'modelos\n')
  cat('──────────────────────────────────────\n\n')
}

# Limpieza pre-evaluación
cat('🧹 Limpieza antes de evaluación...\n')
gc(reset = TRUE, full = TRUE)

# 5. Evaluación
cat('\n========================================\n')
cat('PASO 5: Evaluación\n')
cat('========================================\n\n')

tryCatch({
  source('04_evaluate_and_plots.R')
  cat('\n✓ Evaluación completada\n')
}, error = function(e){
  cat('❌ ERROR:', conditionMessage(e), '\n')
})

# 6. Resumen
cat('\n========================================\n')
cat('🎉 PIPELINE COMPLETADO\n')
cat('========================================\n')
cat('📊 Resultados en:', output_dir, '\n\n')

cat('📈 Modelos entrenados:\n')
for(nm in names(results)){
  cat('   -', nm)
  if(!is.null(results[[nm]]$time_sec)){
    cat(' (', round(results[[nm]]$time_sec, 2), 's)')
  }
  cat('\n')
}

cat('\n✅ Revise outputs/ para archivos de presentación\n')
cat('========================================\n')

# Detener cluster paralelo
stopImplicitCluster()