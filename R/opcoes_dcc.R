#' Definir opcoes de exibicao do pacote DCC
#'
#' Controla a marca decimal usada na exibicao dos resultados.
#'
#' @param decimal Marca decimal a ser usada. Pode ser "virgula" ou "ponto".
#'
#' @return Invisivelmente, a marca decimal ativa.
#' @export
opcoes_dcc <- function(decimal = c("virgula", "ponto")) {
  decimal <- match.arg(decimal)

  if (decimal == "virgula") {
    options(DCC.decimal = ",")
  } else {
    options(DCC.decimal = ".")
  }

  invisible(getOption("DCC.decimal"))
}
