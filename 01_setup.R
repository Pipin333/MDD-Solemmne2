## 01_setup.R
# Paquetes y parámetros globales
required_pkgs <- c(
  'tidyverse', 'caret', 'e1071', 'nnet', 'naivebayes',
  'rpart', 'rpart.plot', 'randomForest', 'pROC', 'ROCR',
  'class', 'gridExtra', 'lubridate',
  'parallel', 'doParallel'  # ⭐ Para paralelización
)
install_if_missing <- function(pkgs){
  for(p in pkgs) if(!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
install_if_missing(required_pkgs)

library(tidyverse)
library(caret)
library(e1071)
library(nnet)
library(naivebayes)
library(rpart)
library(rpart.plot)
library(randomForest)
library(pROC)
library(ROCR)
library(class)
library(gridExtra)
library(lubridate)
library(parallel)
library(doParallel)

# ⭐ LIMPIEZA INICIAL
gc(reset = TRUE, full = TRUE)

# Configuración
data_path <- 'Congestion_Santiago_05_2025.csv'
output_dir <- file.path(getwd(), 'outputs')
if(!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

models_dir <- file.path(output_dir, 'models')
if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)

target_var <- 'Duration_hrs'

# ⭐ CONFIGURACIÓN DE PARALELIZACIÓN ÓPTIMA
SKIP_TRAIN <- FALSE
SAVE_MODELS <- TRUE

# Usar 7 núcleos (dejar 1 libre para el sistema)
PARALLEL_CORES <- 7
registerDoParallel(cores = PARALLEL_CORES)

cat('========================================\n')
cat('Setup cargado\n')
cat('  data_path:', data_path, '\n')
cat('  output_dir:', output_dir, '\n')
cat('  target_var:', target_var, '\n')
cat('  Núcleos registrados:', PARALLEL_CORES, '\n')
cat('========================================\n')