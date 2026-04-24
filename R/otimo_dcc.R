#' Ponto ótimo previsto para DCC
#'
#' @param fit objeto da classe dcc_fit.
#' @param objetivo "min" para minimizar a resposta ou "max" para maximizar.
#'
#' @return Lista com o ponto ótimo previsto, resposta estimada,
#' convergência, valor otimizado e objetivo.
#' @export
otimo_dcc <- function(fit, objetivo = c("min", "max")) {

  if (missing(fit)) {
    stop("O argumento 'fit' é obrigatório.")
  }

  if (!inherits(fit, "dcc_fit") || is.null(fit$modelo) || is.null(fit$fatores)) {
    stop("O objeto 'fit' precisa ser da classe 'dcc_fit'.")
  }

  objetivo <- match.arg(objetivo)

  fatores <- fit$fatores
  k <- length(fatores)

  if (k < 2) {
    stop("O modelo precisa ter pelo menos dois fatores.")
  }

  lim_inf <- vapply(fatores, function(f) min(fit$dados[[f]], na.rm = TRUE), numeric(1))
  lim_sup <- vapply(fatores, function(f) max(fit$dados[[f]], na.rm = TRUE), numeric(1))

  f_obj <- function(par) {
    novo <- as.data.frame(as.list(par))
    names(novo) <- fatores
    novo <- novo[, fatores, drop = FALSE]

    pred <- tryCatch(
      as.numeric(stats::predict(fit$modelo, newdata = novo)),
      error = function(e) NA_real_
    )

    if (is.na(pred) || !is.finite(pred)) {
      return(Inf)
    }

    if (objetivo == "min") pred else -pred
  }

  inicio <- (lim_inf + lim_sup) / 2

  res <- tryCatch(
    stats::optim(
      par = inicio,
      fn = f_obj,
      method = "L-BFGS-B",
      lower = lim_inf,
      upper = lim_sup
    ),
    error = function(e) NULL
  )

  if (is.null(res) || is.null(res$par) || any(!is.finite(res$par))) {

    ponto_otimo <- stats::setNames(rep(NA_real_, k), fatores)
    resposta_prevista <- NA_real_
    convergencia <- 1
    valor_otimizado <- NA_real_

  } else {

    ponto_otimo <- res$par
    names(ponto_otimo) <- fatores

    novo_ot <- as.data.frame(as.list(ponto_otimo))
    novo_ot <- novo_ot[, fatores, drop = FALSE]

    resposta_prevista <- tryCatch(
      as.numeric(stats::predict(fit$modelo, newdata = novo_ot)),
      error = function(e) NA_real_
    )

    convergencia <- res$convergence
    valor_otimizado <- if (objetivo == "min") res$value else -res$value
  }

  resultado <- list(
    ponto = ponto_otimo,
    resposta = resposta_prevista,
    convergencia = convergencia,
    valor_otimizado = valor_otimizado,
    objetivo = objetivo,
    nome_resposta = fit$nome_resposta
  )

  class(resultado) <- "otimo_dcc"

  return(resultado)
}
