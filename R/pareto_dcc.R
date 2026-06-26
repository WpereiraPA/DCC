#' Gráfico de Pareto dos efeitos padronizados no DCC
#'
#' @param obj objeto da classe dcc_fit.
#' @param alpha nível de significância.
#'
#' @return Invisivelmente, a tabela usada no gráfico.
#' @export
pareto_dcc <- function(obj, alpha = 0.05) {

  if (!inherits(obj, "dcc_fit")) {
    stop("O objeto deve ser da classe 'dcc_fit'.")
  }

  if (!is.numeric(alpha) || length(alpha) != 1 || is.na(alpha) || alpha <= 0 || alpha >= 1) {
    stop("O argumento 'alpha' deve ser numérico entre 0 e 1.")
  }

  s <- summary(obj$modelo)

  tab <- as.data.frame(s$coefficients)
  tab$Termo <- rownames(tab)
  rownames(tab) <- NULL

  tab <- tab[tab$Termo != "(Intercept)", , drop = FALSE]

  formatar_termo <- function(x) {
    x <- as.character(x)

    x <- gsub(":", " × ", x, fixed = TRUE)
    x <- gsub("I\\(([^\\)]+)\\^2\\)", "\\1²", x)

    x
  }

  tab$TermoBonito <- vapply(tab$Termo, formatar_termo, character(1))

  tab$EfeitoPadronizado <- abs(tab$`t value`)

  tab <- tab[order(tab$EfeitoPadronizado), , drop = FALSE]

  linha_sig <- stats::qt(1 - alpha / 2, df = obj$gl_residual)

  nome_resp <- if (!is.null(obj$nome_resposta) && nzchar(obj$nome_resposta)) {
    obj$nome_resposta
  } else if (!is.null(obj$resposta) && nzchar(obj$resposta)) {
    obj$resposta
  } else {
    "Resposta"
  }

  old_mar <- graphics::par("mar")
  on.exit(graphics::par(mar = old_mar))

  graphics::par(mar = c(5, 8, 5, 2))

  bp <- graphics::barplot(
    tab$EfeitoPadronizado,
    names.arg = tab$TermoBonito,
    horiz = TRUE,
    col = "cornflowerblue",
    border = "white",
    las = 1,
    xlab = "Efeitos padronizados (|t|)",
    main = paste0(
      "Pareto dos Efeitos Padronizados\n(",
      nome_resp, "; α = ", alpha, ")"
    )
  )

  graphics::abline(v = linha_sig, col = "red", lwd = 2, lty = 2)

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
