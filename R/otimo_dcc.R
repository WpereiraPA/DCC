#' Ponto ótimo previsto para DCC
#'
#' @param fit objeto da classe dcc_fit.
#' @param tipo "min" para minimizar a resposta ou "max" para maximizar.
#'
#' @return data.frame com o ponto ótimo previsto e o valor estimado da resposta.
#' @export
otimo_dcc <- function(fit, tipo = c("min", "max")) {

  tipo <- match.arg(tipo)

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto fit precisa ser da classe 'dcc_fit'.")
  }

  fatores <- fit$fatores

  if (length(fatores) != 2) {
    stop("Nesta versão, otimo_dcc() foi preparado para 2 fatores.")
  }

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

    if (tipo == "min") pred else -pred
  }

  inicio <- c(mean(lim_inf[1:2]), mean(lim_sup[1:2]))
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

  out <- data.frame(
    Fator = c(x1, x2, fit$resposta),
    Valor = c(x_ot, y_ot, as.numeric(resposta_prevista))
  )

  out
}
