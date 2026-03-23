#' Tabela formatada de coeficientes do modelo DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param digits número de casas decimais.
#'
#' @return tabela formatada.
#' @export
coeficientes_dcc <- function(obj, digits = 4) {

  if (!inherits(obj, "dcc_fit")) {
    stop("O objeto deve ser da classe 'dcc_fit'.")
  }

  fmt <- function(x) {
    format(
      round(x, digits),
      decimal.mark = getOption("DCC.decimal", ","),
      nsmall = digits
    )
  }

  tab <- obj$coeficientes

  cols_num <- sapply(tab, is.numeric)
  tab[cols_num] <- lapply(tab[cols_num], fmt)

  print(tab, row.names = FALSE)
  invisible(tab)
}
