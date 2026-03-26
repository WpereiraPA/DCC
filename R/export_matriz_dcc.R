export_matriz_dcc <- function(matriz,
                              arquivo = "Matriz_DCC",
                              remover_ensaio = FALSE) {

  if (!is.data.frame(matriz)) {
    stop("Forneça uma matriz gerada por matriz_dcc().")
  }

  m <- matriz

  if (remover_ensaio && "Ensaio" %in% names(m)) {
    m$Ensaio <- NULL
  }

  nome_arq <- paste0(arquivo, ".csv")

  utils::write.csv2(m,
             file = nome_arq,
             row.names = FALSE)

  cat("Arquivo exportado corretamente para Excel:", nome_arq, "\n")

  invisible(nome_arq)
}
