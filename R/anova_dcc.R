#' ANOVA do modelo DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param digits número de casas decimais.
#'
#' @return tabela ANOVA formatada.
#' @export
anova_dcc <- function(obj, digits = 4) {

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

  tab <- as.data.frame(stats::anova(obj$modelo))
  tab$Termo <- rownames(tab)
  rownames(tab) <- NULL

  tab <- tab[, c("Termo", setdiff(names(tab), "Termo"))]

  cols_num <- sapply(tab, is.numeric)
  tab[cols_num] <- lapply(tab[cols_num], fmt)

  print(tab, row.names = FALSE)
  invisible(tab)
}
