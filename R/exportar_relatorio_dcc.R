#' Exporta relatório completo do DCC
#'
#' @param fit objeto da classe dcc_fit
#' @param arquivo nome do arquivo a ser salvo, sem extensão
#' @param formato "txt" ou "doc"
#' @param tipo_otimo NULL para não incluir ótimo, "min" para minimizar
#'   a resposta ou "max" para maximizar
#'
#' @return invisivelmente, o nome do arquivo gerado
#' @export
exportar_relatorio_dcc <- function(fit,
                                 arquivo = "Relatorio_DCC",
                                 formato = "txt",
                                 tipo_otimo = NULL) {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto precisa ser da classe 'dcc_fit'.")
  }

  if (!formato %in% c("txt", "doc")) {
    stop("O formato deve ser 'txt' ou 'doc'.")
  }

  if (!is.null(tipo_otimo) && !tipo_otimo %in% c("min", "max")) {
    stop("tipo_otimo deve ser NULL, 'min' ou 'max'.")
  }

  arq <- paste0(arquivo, ".", formato)

  fmt <- function(x, digits = 4) {
    format(round(x, digits), nsmall = digits, decimal.mark = ",")
  }

  # Estatísticas do modelo
  sm <- summary(fit$modelo)
  an <- as.data.frame(stats::anova(fit$modelo))
  co <- as.data.frame(sm$coefficients)

  # Organiza coeficientes
  co$Termo <- rownames(co)
  rownames(co) <- NULL
  co <- co[, c("Termo", "Estimate", "Std. Error", "t value", "Pr(>|t|)")]
  names(co) <- c("Termo", "Estimativa", "Erro_Padrao", "t", "p_valor")

  # Efeitos, sem intercepto
  efeitos <- co[co$Termo != "(Intercept)",
                c("Termo", "Estimativa", "Erro_Padrao", "t", "p_valor")]
  efeitos$Efeito <- 2 * efeitos$Estimativa
  efeitos <- efeitos[, c("Termo", "Efeito", "Estimativa", "Erro_Padrao", "t", "p_valor")]

  # ANOVA organizada
  an$Termo <- rownames(an)
  rownames(an) <- NULL
  an <- an[, c("Termo", "Df", "Sum Sq", "Mean Sq", "F value", "Pr(>F)")]

  # Equação ajustada
  beta <- stats::coef(fit$modelo)
  nomes <- names(beta)

  nomes_eq <- nomes
  nomes_eq[nomes_eq == "(Intercept)"] <- ""
  nomes_eq[nomes_eq == "AA"] <- "A²"
  nomes_eq[nomes_eq == "BB"] <- "B²"
  nomes_eq[nomes_eq == "AB"] <- "AB"

  eq <- paste0("Y = ", fmt(beta[1], 4))

  if (length(beta) > 1) {
    for (i in 2:length(beta)) {
      sinal <- ifelse(beta[i] >= 0, " + ", " - ")
      eq <- paste0(eq, sinal, fmt(abs(beta[i]), 4), "*", nomes_eq[i])
    }
  }

  # Ótimo previsto, opcional
  otimo_out <- NULL

  if (!is.null(tipo_otimo)) {
    fatores <- fit$fatores

    if (length(fatores) != 2) {
      warning("O cálculo do ótimo previsto está implementado apenas para 2 fatores.")
    } else {
      x1 <- fatores[1]
      x2 <- fatores[2]

      lim_inf <- c(min(fit$dados[[x1]]), min(fit$dados[[x2]]))
      lim_sup <- c(max(fit$dados[[x1]]), max(fit$dados[[x2]]))

      f_obj <- function(par) {
        novo <- data.frame(x = par[1], y = par[2])
        names(novo) <- c(x1, x2)

        novo$AA <- novo[[x1]]^2
        novo$BB <- novo[[x2]]^2
        novo$AB <- novo[[x1]] * novo[[x2]]

        pred <- stats::predict(fit$modelo, newdata = novo)

        if (tipo_otimo == "min") {
          pred
        } else {
          -pred
        }
      }

      inicio <- c(mean(c(lim_inf[1], lim_sup[1])),
                  mean(c(lim_inf[2], lim_sup[2])))

      res <- stats::optim(
        par = inicio,
        fn = f_obj,
        method = "L-BFGS-B",
        lower = lim_inf,
        upper = lim_sup
      )

      x_ot <- res$par[1]
      y_ot <- res$par[2]

      novo_ot <- data.frame(x = x_ot, y = y_ot)
      names(novo_ot) <- c(x1, x2)

      novo_ot$AA <- novo_ot[[x1]]^2
      novo_ot$BB <- novo_ot[[x2]]^2
      novo_ot$AB <- novo_ot[[x1]] * novo_ot[[x2]]

      resposta_prevista <- stats::predict(fit$modelo, newdata = novo_ot)

      otimo_out <- data.frame(
        Termo = c(x1, x2, fit$resposta),
        Valor = c(x_ot, y_ot, as.numeric(resposta_prevista))
      )
    }
  }

  sink(arq)
  on.exit(sink(), add = TRUE)

  cat("========================================\n")
  cat(" RELATÓRIO DO DELINEAMENTO COMPOSTO CENTRAL\n")
  cat("========================================\n\n")

  cat("Variável resposta: ", fit$resposta, "\n\n", sep = "")

  cat("----------------------------------------\n")
  cat("ESTATÍSTICAS DO MODELO\n")
  cat("----------------------------------------\n")
  cat("R² = ", fmt(sm$r.squared, 4), "\n", sep = "")
  cat("R² ajustado = ", fmt(sm$adj.r.squared, 4), "\n", sep = "")
  cat("Erro padrão residual = ", fmt(sm$sigma, 5), "\n\n", sep = "")

  cat("----------------------------------------\n")
  cat("ANOVA\n")
  cat("----------------------------------------\n")

  an_out <- an
  an_out$Df <- format(an_out$Df, trim = TRUE)
  an_out$`Sum Sq` <- fmt(an_out$`Sum Sq`, 6)
  an_out$`Mean Sq` <- fmt(an_out$`Mean Sq`, 6)
  an_out$`F value` <- ifelse(is.na(an_out$`F value`), "", fmt(an_out$`F value`, 4))
  an_out$`Pr(>F)` <- ifelse(is.na(an_out$`Pr(>F)`), "", fmt(an_out$`Pr(>F)`, 6))

  print(an_out, row.names = FALSE, right = TRUE)
  cat("\n")

  cat("----------------------------------------\n")
  cat("COEFICIENTES DO MODELO\n")
  cat("----------------------------------------\n")

  co_out <- co
  co_out$Termo[co_out$Termo == "AA"] <- "A²"
  co_out$Termo[co_out$Termo == "BB"] <- "B²"
  co_out$Estimativa <- fmt(co_out$Estimativa, 5)
  co_out$Erro_Padrao <- fmt(co_out$Erro_Padrao, 5)
  co_out$t <- fmt(co_out$t, 3)
  co_out$p_valor <- fmt(co_out$p_valor, 6)

  print(co_out, row.names = FALSE, right = TRUE)
  cat("\n")

  cat("----------------------------------------\n")
  cat("EFEITOS ESTIMADOS\n")
  cat("----------------------------------------\n")

  efeitos_out <- efeitos
  efeitos_out$Termo[efeitos_out$Termo == "AA"] <- "A²"
  efeitos_out$Termo[efeitos_out$Termo == "BB"] <- "B²"
  efeitos_out$Efeito <- fmt(efeitos_out$Efeito, 5)
  efeitos_out$Estimativa <- fmt(efeitos_out$Estimativa, 5)
  efeitos_out$Erro_Padrao <- fmt(efeitos_out$Erro_Padrao, 5)
  efeitos_out$t <- fmt(efeitos_out$t, 3)
  efeitos_out$p_valor <- fmt(efeitos_out$p_valor, 6)

  print(efeitos_out, row.names = FALSE, right = TRUE)
  cat("\n")

  if (!is.null(otimo_out)) {
    cat("----------------------------------------\n")
    cat("ÓTIMO PREVISTO PELO MODELO\n")
    cat("----------------------------------------\n")

    if (tipo_otimo == "min") {
      cat("Objetivo considerado: minimizar a resposta.\n\n")
    } else {
      cat("Objetivo considerado: maximizar a resposta.\n\n")
    }

    otimo_imp <- otimo_out
    otimo_imp$Valor <- fmt(otimo_imp$Valor, 5)

    print(otimo_imp, row.names = FALSE, right = TRUE)
    cat("\n")
  }

  cat("----------------------------------------\n")
  cat("EQUAÇÃO AJUSTADA\n")
  cat("----------------------------------------\n")
  cat(eq, "\n\n")

  cat("----------------------------------------\n")
  cat("INTERPRETAÇÃO BÁSICA\n")
  cat("----------------------------------------\n")
  cat("O modelo quadrático foi ajustado considerando efeitos lineares,\n")
  cat("quadráticos e de interação entre os fatores.\n")
  cat("A ANOVA permite verificar a contribuição de cada termo no modelo.\n")
  cat("Os coeficientes mostram a direção e a intensidade da influência dos fatores.\n")
  cat("Os efeitos estimados facilitam a interpretação prática da magnitude das mudanças.\n")
  if (!is.null(otimo_out)) {
    cat("O ponto ótimo previsto foi calculado dentro da região experimental.\n")
  }
  cat("\nRelatório gerado automaticamente pelo pacote DCC.\n")

  invisible(arq)
}
