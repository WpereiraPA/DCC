#' Ajustar modelo quadrático para DCC
#'
#' Ajusta um modelo quadrático completo para um delineamento composto central
#' com 2 fatores, gerando automaticamente os termos AA, BB e AB.
#'
#' @param dados data.frame com os dados experimentais.
#' @param resposta nome da coluna resposta.
#' @param fatores vetor com os nomes dos fatores.
#'
#' @return Um objeto da classe dcc_fit.
#' @export
dcc_fit <- function(dados, resposta, fatores = c("A", "B")) {

  if (!is.data.frame(dados)) {
    stop("dados deve ser um data.frame.")
  }

  if (!resposta %in% names(dados)) {
    stop("A coluna de resposta não foi encontrada nos dados.")
  }

  if (!all(fatores %in% names(dados))) {
    stop("Nem todos os fatores informados foram encontrados nos dados.")
  }

  dados <- dcc_terms(dados, fatores = fatores)

  dados[[resposta]] <- as.numeric(gsub(",", ".", dados[[resposta]]))

  formula_txt <- paste(
    resposta,
    "~",
    paste(c(fatores, "AA", "BB", "AB"), collapse = " + ")
  )

  formula_mod <- stats::as.formula(formula_txt)
  modelo <- stats::lm(formula_mod, data = dados)
  sm <- summary(modelo)

  tabela_coef <- as.data.frame(sm$coefficients)
  tabela_coef$Termo <- rownames(tabela_coef)
  rownames(tabela_coef) <- NULL
  tabela_coef <- tabela_coef[, c("Termo", setdiff(names(tabela_coef), "Termo"))]

  obj <- list(
    call = match.call(),
    dados = dados,
    resposta = resposta,
    fatores = fatores,
    formula = formula_mod,
    modelo = modelo,
    coeficientes = tabela_coef,
    r2 = unname(sm$r.squared),
    r2_ajustado = unname(sm$adj.r.squared),
    ajustados = stats::fitted(modelo),
    residuos = stats::resid(modelo),
    gl_residual = modelo$df.residual,
    sigma = sm$sigma
  )

  class(obj) <- "dcc_fit"
  return(obj)
}
