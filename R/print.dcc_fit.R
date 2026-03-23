#' Imprimir objeto ajustado do tipo dcc_fit
#'
#' @param x objeto da classe dcc_fit.
#' @param ... argumentos adicionais.
#'
#' @return Invisivelmente, o próprio objeto.
#' @export
print.dcc_fit <- function(x, ...) {
  cat("Modelo DCC ajustado\n")
  cat("Resposta:", x$resposta, "\n")
  cat("Fatores:", paste(x$fatores, collapse = ", "), "\n")
  cat("Fórmula:", deparse(x$formula), "\n")
  cat("R2:", round(x$r2, 4), "\n")
  cat("R2 ajustado:", round(x$r2_ajustado, 4), "\n")
  invisible(x)
}
