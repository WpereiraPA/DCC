#' Sumario geral da analise DCC
#'
#' Reune em uma unica funcao os principais resultados nao graficos
#' da analise de um Delineamento Composto Central.
#'
#' @param fit objeto da classe dcc_fit.
#' @param incluir_otimo logical. Se TRUE, tenta incluir o ponto otimo.
#' @param imprimir logical. Se TRUE, imprime os resultados no console.
#'
#' @return Invisivelmente, uma lista com os resultados da analise.
#' @export
sumario_dcc <- function(fit, incluir_otimo = TRUE, imprimir = TRUE) {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto precisa ser da classe 'dcc_fit'.")
  }

  resultado <- list(
    resumo = summary(fit$modelo),
    anova = invisible(utils::capture.output(anova_res <- anova_dcc(fit))),
    coeficientes = invisible(utils::capture.output(coef_res <- coeficientes_dcc(fit))),
    efeitos = invisible(utils::capture.output(efeitos_res <- efeitos_dcc(fit)))
  )

  resultado$anova <- anova_res
  resultado$coeficientes <- coef_res
  resultado$efeitos <- efeitos_res

  if (incluir_otimo) {
    resultado$otimo <- tryCatch(
      otimo_dcc(fit),
      error = function(e) NULL
    )
  } else {
    resultado$otimo <- NULL
  }

  if (imprimir) {
    cat("========================================\n")
    cat("SUMARIO DA ANALISE DCC\n")
    cat("========================================\n\n")

    cat("Resumo do ajuste\n")
    cat("----------------------------------------\n")
    print(resultado$resumo)

    cat("\nANOVA\n")
    cat("----------------------------------------\n")
    print(resultado$anova)

    cat("\nCoeficientes\n")
    cat("----------------------------------------\n")
    print(resultado$coeficientes)

    cat("\nEfeitos\n")
    cat("----------------------------------------\n")
    print(resultado$efeitos)

    if (!is.null(resultado$otimo)) {
      cat("\nPonto otimo\n")
      cat("----------------------------------------\n")
      print(resultado$otimo)
    }
  }

  invisible(resultado)
}
