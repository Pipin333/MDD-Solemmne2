## 02_load_prep.R
# Carga y preprocesamiento básico
if(!exists('data_path')) stop('Defina `data_path` en 01_setup.R antes de sourcear este archivo.')
df <- readr::read_csv(data_path, show_col_types = FALSE)
cat('Dimensiones del dataset:', nrow(df),'x', ncol(df), '\n')

# ⭐ REDUCIR A 20,000 FILAS
if(nrow(df) > 20000){
  cat('🚨 Dataset grande (', nrow(df), ' filas)\n')
  cat('   Reduciendo a 20,000 filas para balance velocidad/precisión...\n')
  set.seed(123)
  df <- df[sample(nrow(df), 20000), ]
  cat('✓ Dataset reducido a:', nrow(df), 'filas\n')
}

if(!(target_var %in% names(df))){
  stop(paste('La variable target', target_var, 'no existe en el dataset.'))
}

# Detectar tipo de problema
if(is.numeric(df[[target_var]]) && length(unique(df[[target_var]]))>6){
  problem_type <- 'regression'
} else {
  problem_type <- 'classification'
}
cat('Tipo de problema detectado:', problem_type, '\n')

# 1) Eliminar columnas con >50% NA
na_threshold <- 0.5
keep_cols <- names(df)[sapply(df, function(x) mean(is.na(x)) <= na_threshold)]
df <- df %>% select(all_of(keep_cols))

# Helper mode
getMode <- function(v){
  d <- sort(table(v), decreasing = TRUE)
  names(d)[1]
}

# 2) Rellenar NA
for(col in names(df)){
  if(is.numeric(df[[col]])) df[[col]][is.na(df[[col]])] <- median(df[[col]], na.rm = TRUE)
  else df[[col]][is.na(df[[col]])] <- getMode(df[[col]])
}

# 3) Convertir character a factor
for(col in names(df)) if(is.character(df[[col]])) df[[col]] <- as.factor(df[[col]])

# ⭐ 3.5) ELIMINAR COLUMNAS CONSTANTES Y CASI-CONSTANTES (CRÍTICO)
# Esto soluciona el problema de "zero variances" y nnet/rpart fallando
library(caret)

# Eliminar columnas con varianza cero
const_cols <- sapply(df, function(x) {
  if(is.factor(x)) length(levels(x)) <= 1
  else if(is.numeric(x)) var(x, na.rm = TRUE) == 0 || is.na(var(x, na.rm = TRUE))
  else FALSE
})

if(any(const_cols)){
  const_names <- names(df)[const_cols]
  # No eliminar el target
  const_names <- setdiff(const_names, target_var)
  if(length(const_names) > 0){
    cat('⚠ Eliminando', length(const_names), 'columna(s) constante(s)\n')
    df <- df %>% select(-all_of(const_names))
  }
}

# Eliminar columnas con varianza casi-cero (near-zero variance)
nzv <- nearZeroVar(df, saveMetrics = TRUE)
nzv_cols <- rownames(nzv)[nzv$nzv & rownames(nzv) != target_var]

if(length(nzv_cols) > 0){
  cat('⚠ Eliminando', length(nzv_cols), 'columna(s) con varianza casi-cero\n')
  df <- df %>% select(-all_of(nzv_cols))
}

# ⭐ 3.6) ELIMINAR FACTORES CON DEMASIADOS NIVELES (para modelos que no los soportan)
factor_cols <- sapply(df, is.factor)
high_card_factors <- names(df)[factor_cols][sapply(df[factor_cols], function(x) nlevels(x) > 53)]
high_card_factors <- setdiff(high_card_factors, target_var)

if(length(high_card_factors) > 0){
  cat('⚠ Eliminando', length(high_card_factors), 'columna(s) con >53 niveles (incompatible con algunos modelos):\n')
  cat('  ', paste(high_card_factors, collapse = ', '), '\n')
  df <- df %>% select(-all_of(high_card_factors))
}

# 4) Si clasificación y target es factor, asegurar factor
if(problem_type == 'classification') df[[target_var]] <- as.factor(df[[target_var]])

# 5) Crear train/test split
set.seed(123)
train_index <- caret::createDataPartition(df[[target_var]], p = 0.8, list = FALSE)
train_df <- df[train_index, ]
test_df  <- df[-train_index, ]

cat('Train/Test split creado:', nrow(train_df), 'train,', nrow(test_df), 'test\n')
cat('Columnas finales:', ncol(train_df), '(después de limpieza)\n')
