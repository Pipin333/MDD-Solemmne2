# Proyecto: Análisis supervisado (scripts separados)

Resumen
-------
Este repositorio contiene un conjunto de scripts R para preparar datos, entrenar varios modelos y generar tablas/plots listos para insertar en diapositivas. Los scripts están separados para facilitar su uso en presentaciones y ejecución por etapas.

Estructura de archivos
----------------------
- `01_setup.R` : paquetes, rutas y flags globales (edita `target_var`, `SKIP_TRAIN`, `SAVE_MODELS`).
- `02_load_prep.R` : carga del CSV y preprocesamiento (imputación simple, encoding, split train/test).
- `03_utils.R` : control de validación (caret) y `train_and_time()`.
- `models/` : scripts por modelo que entrenan y (si `SAVE_MODELS=TRUE`) guardan RDS en `outputs/models/`.
- `04_evaluate_and_plots.R` : genera métricas, tablas y gráficos a `outputs/`.
- `Si.R` : orquestador que ejecuta las etapas en orden. Actúa como `run_all.R`.
- `test_load.R` : script de prueba que simula la carga de RDS desde `outputs/models/` (no entrena ni evalúa).
- `Congestion_Santiago_05_2025.csv` : dataset (colócalo en la raíz del proyecto).

Configuración inicial
---------------------
1. Abrir `01_setup.R` y editar `target_var <- '...'` con el nombre real de la columna objetivo.
2. Opciones clave en `01_setup.R`:
   - `SKIP_TRAIN <- FALSE` (por defecto): se entrenan los modelos ejecutando `Si.R`.
   - `SKIP_TRAIN <- TRUE` : cargará modelos desde `outputs/models/*.rds` en lugar de re-entrenar.
   - `SAVE_MODELS <- TRUE` : guarda la salida de cada entrenamiento en `outputs/models/`.

Ejecución recomendada
---------------------
- En RStudio: abrir `Si.R` y hacer Source (esto ejecuta todo el pipeline).
- Desde la terminal (si `Rscript` está en PATH):

```powershell
Rscript -e "source('Si.R')"
```

Prueba de carga (sin entrenar)
------------------------------
Si quieres verificar la carga de modelos RDS sin entrenar nada, usa `test_load.R`. Este script:
1. Sourcing `01_setup.R` para crear `outputs/` y `outputs/models/` si no existen.
2. Si no hay RDS en `outputs/models/`, crea un RDS dummy (`dummy_model.rds`).
3. Carga todos los RDS encontrados y muestra un resumen de `results`.

Ejecutar la prueba (PowerShell):

```powershell
Rscript -e "source('test_load.R')"
```

Si `Rscript` no está disponible, abre R/RStudio y en la consola:

```r
source('test_load.R')
```

Notas y buenas prácticas
-----------------------
- Antes de ejecutar el pipeline real, asegúrate de que `target_var` esté correctamente establecido.
- Ajusta `ctrl` en `03_utils.R` si necesitas métricas específicas o validación temporal.
- Guardar modelos (`SAVE_MODELS=TRUE`) facilita generar reportes sin re-entrenar.
- Los archivos de salida se guardan en `outputs/` (CSV, PNG, TXT) y los modelos en `outputs/models/`.

¿Algo más?
----------
Si quieres que guarde además metadatos de cada modelo (JSON con fecha, tiempo, parámetros), o que añada un `Makefile`/`ps1` para automatizar, lo implemento rápido.
