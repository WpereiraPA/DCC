#' Gerar termos quadráticos e de interação para DCC
#'
#' @param dados data.frame com os dados experimentais.
#' @param fatores vetor com os nomes dos fatores.
#'
#' @return data.frame organizado com AA, BB e AB antes da resposta.
#' @export
dcc_terms <- function(dados, fatores) {

  if (!is.data.frame(dados)) {
    stop("dados deve ser um data.frame.")
  }

  if (length(fatores) != 2) {
    stop("Nesta primeira versão o pacote aceita apenas 2 fatores.")
  }

  A <- fatores[1]
  B <- fatores[2]

  if (!all(c(A, B) %in% names(dados))) {
    stop("Os fatores informados não estão presentes nos dados.")
  }

  # converter para numérico com segurança
  dados[[A]] <- as.numeric(gsub(",", ".", dados[[A]]))
  dados[[B]] <- as.numeric(gsub(",", ".", dados[[B]]))

  # gerar termos
  dados$AA <- dados[[A]]^2
  dados$BB <- dados[[B]]^2
  dados$AB <- dados[[A]] * dados[[B]]

  # reorganizar colunas
  resposta <- setdiff(names(dados), c("Ensaio", A, B, "AA", "BB", "AB"))

  dados <- dados[, c("Ensaio", A, B, "AA", "BB", "AB", resposta)]

  return(dados)
}
