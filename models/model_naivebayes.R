## models/model_naivebayes.R
if(!exists('train_and_time')) stop('Source 03_utils.R antes de ejecutar modelos')

if(exists('problem_type') && problem_type=='classification'){
  results$nb <- train_and_time('naive_bayes', metric=if(ctrl$summaryFunction==twoClassSummary) 'ROC' else 'Accuracy')
  if(exists('SAVE_MODELS') && SAVE_MODELS){
    if(!dir.exists(models_dir)) dir.create(models_dir, recursive = TRUE)
    saveRDS(results$nb, file = file.path(models_dir, 'nb.rds'))
  }
} else {
  # Naive Bayes no es habitual en regresión; omitimos o se puede usar como baseline
  cat('Naive Bayes normalmente se usa en clasificación; omitiendo para regresión.\n')
}

# Al final de model_knn.R, model_svm.R, etc.
gc(reset = TRUE, full = TRUE)