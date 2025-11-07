## test_load.R
# Script ligero para probar la carga de modelos RDS en outputs/models.
# No entrena modelos ni ejecuta evaluación posterior.

# 1) Source setup para crear carpetas
source('01_setup.R')

# 2) Asegurar que existe la carpeta models
if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)

# 3) Si no hay RDS, crear un dummy para la prueba
rds_files <- list.files(models_dir, pattern = '\\.(rds|RDS)$', full.names = TRUE)
if(length(rds_files) == 0){
  cat('No se encontraron RDS en', models_dir, '\nCreando dummy_model.rds para la prueba...\n')
  dummy <- list(model = list(dummy = TRUE), time_sec = 0)
  saveRDS(dummy, file = file.path(models_dir, 'dummy_model.rds'))
  rds_files <- list.files(models_dir, pattern = '\\.(rds|RDS)$', full.names = TRUE)
}

# 4) Cargar todos los RDS en la lista results y mostrar un resumen
results <- list()
for(f in rds_files){
  nm <- tools::file_path_sans_ext(basename(f))
  cat('Cargando', f, '-> results$', nm, '\n')
  results[[nm]] <- readRDS(f)
}

cat('\nResumen de resultados cargados:\n')
print(names(results))
for(nm in names(results)){
  cat('\n---', nm, '---\n')
  print(str(results[[nm]]))
}

cat('\nPrueba de carga completada.\n')
