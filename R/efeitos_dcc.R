#' Efeitos estimados e significância no DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param alpha nível de significância.
#' @param digits casas decimais.
#'
#' @return tabela de efeitos com significância.
#' @export
efeitos_dcc <- function(obj, alpha = 0.05, digits = 4) {

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

  s <- summary(obj$modelo)

  tab <- as.data.frame(s$coefficients)

  tab$Termo <- rownames(tab)
  rownames(tab) <- NULL

  tab <- tab[tab$Termo != "(Intercept)", ]

  tab$Efeito <- 2 * tab$Estimate
  tab$Significativo <- ifelse(tab$`Pr(>|t|)` <= alpha, "Sim", "Nao")

  tab <- tab[, c("Termo", "Efeito", "Estimate", "Std. Error", "t value", "Pr(>|t|)", "Significativo")]

  tab <- tab[order(abs(tab$Efeito), decreasing = TRUE), ]

  cols_num <- sapply(tab, is.numeric)
  tab[cols_num] <- lapply(tab[cols_num], fmt)

  print(tab, row.names = FALSE)
  invisible(tab)
}
