#' Exporta a matriz experimental DCC
#'
#' @param matriz data.frame gerado pela funcao matriz_dcc().
#' @param arquivo nome do arquivo de saida, sem extensao.
#' @param remover_ensaio logical. Se TRUE, remove a coluna Ensaio antes da exportacao.
#'
#' @return Invisivelmente, o nome do arquivo gerado.
#' @export

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
