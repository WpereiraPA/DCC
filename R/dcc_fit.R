#' Ajustar modelo quadrático para DCC
#'
#' Ajusta um modelo quadrático completo para um delineamento composto central
#' com 2 fatores, gerando automaticamente os termos AA, BB e AB.
#'
#' @param dados data.frame com os dados experimentais.
#' @param resposta nome da coluna resposta entre aspas.
#' @param fatores vetor com os nomes dos fatores. Padrão \code{c("A", "B")}.
#'
#' @return Um objeto da classe \code{dcc_fit}.
#' @export
dcc_fit <- function(dados, resposta, fatores = c("A", "B")) {

  if (missing(dados) || !is.data.frame(dados)) {
    stop("O argumento 'dados' deve ser um data.frame.")
  }

  if (missing(resposta) || !is.character(resposta) || length(resposta) != 1 || is.na(resposta) || trimws(resposta) == "") {
    stop("O argumento 'resposta' deve ser uma string não vazia.")
  }

  if (!resposta %in% names(dados)) {
    stop("A coluna de resposta não foi encontrada nos dados.")
  }

  if (missing(fatores) || !is.character(fatores) || length(fatores) != 2 || any(is.na(fatores)) || any(trimws(fatores) == "")) {
    stop("O argumento 'fatores' deve ser um vetor de duas strings não vazias.")
  }

  if (!all(fatores %in% names(dados))) {
    stop("Nem todos os fatores informados foram encontrados nos dados.")
  }

  dados[[resposta]] <- as.numeric(gsub(",", ".", as.character(dados[[resposta]])))

  if (anyNA(dados[[resposta]])) {
    stop("A coluna de resposta contém valores ausentes ou não numéricos após conversão.")
  }

  for (f in fatores) {
    dados[[f]] <- as.numeric(gsub(",", ".", as.character(dados[[f]])))
  }

  if (any(vapply(dados[fatores], function(x) anyNA(x), logical(1)))) {
    stop("Um ou mais fatores contêm valores ausentes ou não numéricos após conversão.")
  }

  termo_linear <- paste(fatores, collapse = " + ")

  interacoes <- utils::combn(fatores, 2, function(x) paste(x, collapse = ":"))
  termo_interacao <- paste(interacoes, collapse = " + ")

  quadrados <- paste0("I(", fatores, "^2)")
  termo_quadratico <- paste(quadrados, collapse = " + ")

  formula_txt <- paste(
    resposta, "~",
    termo_linear, "+",
    termo_interacao, "+",
    termo_quadratico
  )

  formula_mod <- stats::as.formula(formula_txt)
  modelo <- stats::lm(formula_mod, data = dados)
  sm <- summary(modelo)

  if (is.null(sm$coefficients)) {
    stop("Não foi possível extrair os coeficientes do modelo ajustado.")
  }

  tabela_coef <- as.data.frame(sm$coefficients)
  tabela_coef$Termo <- rownames(tabela_coef)
  rownames(tabela_coef) <- NULL
  tabela_coef <- tabela_coef[, c("Termo", setdiff(names(tabela_coef), "Termo")), drop = FALSE]

  names(tabela_coef)[1:5] <- c("Termo", "Estimativa", "Erro_Padrao", "t_valor", "p_valor")

  aviso <- NULL

  if (any(is.na(stats::coef(modelo)))) {
    aviso <- c(
      aviso,
      "O modelo apresentou coeficientes não estimáveis. Verifique colinearidade, estrutura dos dados ou excesso de termos."
    )
  }

  if (sum(stats::resid(modelo)^2) < 1e-10) {
    aviso <- c(
      aviso,
      "Ajuste essencialmente perfeito. A interpretação inferencial do modelo pode ser instável."
    )
  }

  obj <- list(
    call = match.call(),
    dados = dados,
    resposta = resposta,
    nome_resposta = resposta,
    fatores = fatores,
    formula = formula_mod,
    modelo = modelo,
    coeficientes = tabela_coef,
    r2 = unname(sm$r.squared),
    r2_ajustado = unname(sm$adj.r.squared),
    ajustados = stats::fitted(modelo),
    residuos = stats::resid(modelo),
    gl_residual = modelo$df.residual,
    sigma = sm$sigma,
    aviso = aviso
  )

  class(obj) <- "dcc_fit"
  return(obj)
}
