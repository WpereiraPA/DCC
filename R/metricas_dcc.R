#' Métricas do modelo DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param digits número de casas decimais.
#'
#' @return tabela formatada com métricas do modelo.
#' @export
metricas_dcc <- function(obj, digits = 4) {

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

  sigma <- summary(obj$modelo)$sigma

  tab <- data.frame(
    Metrica = c("R2", "R2 ajustado", "Erro padrao residual"),
    Valor = c(obj$r2, obj$r2_ajustado, sigma),
    stringsAsFactors = FALSE
  )

  tab$Valor <- fmt(tab$Valor)

  print(tab, row.names = FALSE)
  invisible(tab)
}
