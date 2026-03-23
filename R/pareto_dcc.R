#' Grafico de Pareto dos efeitos padronizados no DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param alpha nivel de significancia.
#'
#' @return Invisivelmente, a tabela usada no grafico.
#' @export
pareto_dcc <- function(obj, alpha = 0.05) {

  if (!inherits(obj, "dcc_fit")) {
    stop("O objeto deve ser da classe 'dcc_fit'.")
  }

  s <- summary(obj$modelo)

  tab <- as.data.frame(s$coefficients)
  tab$Termo <- rownames(tab)
  rownames(tab) <- NULL

  tab <- tab[tab$Termo != "(Intercept)", , drop = FALSE]

  A <- obj$fatores[1]
  B <- obj$fatores[2]

  tab$TermoBonito <- tab$Termo
  tab$TermoBonito[tab$Termo == A] <- A
  tab$TermoBonito[tab$Termo == B] <- B
  tab$TermoBonito[tab$Termo == "AA"] <- paste0(A, "\u00B2")
  tab$TermoBonito[tab$Termo == "BB"] <- paste0(B, "\u00B2")
  tab$TermoBonito[tab$Termo == "AB"] <- paste0(A, "\u00D7", B)

  tab$EfeitoPadronizado <- abs(tab$`t value`)

  tab <- tab[order(tab$EfeitoPadronizado), , drop = FALSE]

  linha_sig <- stats::qt(1 - alpha / 2, df = obj$gl_residual)

  old_mar <- graphics::par("mar")
  on.exit(graphics::par(mar = old_mar))

  graphics::par(mar = c(5, 7, 5, 2))

  bp <- graphics::barplot(
    tab$EfeitoPadronizado,
    names.arg = tab$TermoBonito,
    horiz = TRUE,
    col = "cornflowerblue",
    border = "white",
    las = 1,
    xlab = "Efeitos padronizados (|t|)",
    ylab = "Termos",
    main = paste0(
      "Pareto dos Efeitos Padronizados\n(",
      obj$resposta, "; \u03B1 = ", alpha, ")"
    )
  )

  graphics::abline(v = linha_sig, col = "red", lwd = 2, lty = 2)

  xmax <- max(tab$EfeitoPadronizado)

  graphics::text(
    x = linha_sig,
    y = graphics::par("usr")[4] + (graphics::par("usr")[4] - graphics::par("usr")[3]) * 0.018,
    labels = format(
      round(linha_sig, 3),
      decimal.mark = getOption("DCC.decimal", ",")
    ),
    col = "red",
    cex = 1.1,
    font = 2,
    xpd = NA
  )

  invisible(tab)
}
