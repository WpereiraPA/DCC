#' Gera a matriz do Delineamento Composto Central
#'
#' @param k número de fatores, de 2 a 5.
#' @param alpha valor de alpha ou "rotacional".
#' @param aleatorizar lógico. Se TRUE, embaralha a ordem dos ensaios.
#' @param seed valor opcional para reprodutibilidade da aleatorização.
#' @param nome_resposta nome da coluna de resposta.
#' @param incluir_tipo_ponto lógico. Se TRUE, inclui a coluna Tipo_ponto.
#'
#' @return data.frame com a matriz do DCC.
#' @export
matriz_dcc <- function(k = 2,
                       alpha = "rotacional",
                       aleatorizar = FALSE,
                       seed = NULL,
                       nome_resposta = "Resposta",
                       incluir_tipo_ponto = TRUE) {

  if (!is.numeric(k) || length(k) != 1 || k %% 1 != 0 || k < 2 || k > 5) {
    stop("k deve ser um número inteiro entre 2 e 5.")
  }

  if (!is.logical(aleatorizar) || length(aleatorizar) != 1) {
    stop("aleatorizar deve ser TRUE ou FALSE.")
  }

  if (!is.null(seed) && (!is.numeric(seed) || length(seed) != 1)) {
    stop("seed deve ser NULL ou um único valor numérico.")
  }

  if (!is.character(nome_resposta) || length(nome_resposta) != 1) {
    stop("nome_resposta deve ser um texto.")
  }

  if (!is.logical(incluir_tipo_ponto) || length(incluir_tipo_ponto) != 1) {
    stop("incluir_tipo_ponto deve ser TRUE ou FALSE.")
  }

  # número de pontos centrais sugeridos automaticamente
  n0 <- switch(as.character(k),
               "2" = 5,
               "3" = 6,
               "4" = 7,
               "5" = 10)

  # alpha rotacional
  if (is.character(alpha)) {
    if (length(alpha) != 1 || alpha != "rotacional") {
      stop("alpha deve ser 'rotacional' ou um valor numérico.")
    }
    alpha_val <- (2^k)^(1/4)
  } else if (is.numeric(alpha) && length(alpha) == 1 && alpha > 0) {
    alpha_val <- alpha
  } else {
    stop("alpha deve ser 'rotacional' ou um valor numérico positivo.")
  }

  # nomes dos fatores
  nomes_fatores <- LETTERS[1:k]

  # parte fatorial
  fatorial <- expand.grid(rep(list(c(-1, 1)), k))
  names(fatorial) <- nomes_fatores
  tipo_fatorial <- rep("Fatorial", nrow(fatorial))

  # parte axial
  axial <- matrix(0, nrow = 2 * k, ncol = k)
  for (i in seq_len(k)) {
    axial[2 * i - 1, i] <- -alpha_val
    axial[2 * i, i] <- alpha_val
  }
  axial <- as.data.frame(axial)
  names(axial) <- nomes_fatores
  tipo_axial <- rep("Axial", nrow(axial))

  # pontos centrais
  central <- as.data.frame(matrix(0, nrow = n0, ncol = k))
  names(central) <- nomes_fatores
  tipo_central <- rep("Central", nrow(central))

  # junta tudo
  matriz <- rbind(fatorial, axial, central)
  tipo_ponto <- c(tipo_fatorial, tipo_axial, tipo_central)

  # coluna resposta vazia
  matriz[[nome_resposta]] <- NA

  # coluna tipo
  if (incluir_tipo_ponto) {
    matriz$Tipo_ponto <- tipo_ponto
  }

  # aleatorização opcional
  if (aleatorizar) {
    if (!is.null(seed)) {
      set.seed(seed)
    }
    idx <- sample(seq_len(nrow(matriz)))
    matriz <- matriz[idx, , drop = FALSE]
  }

  # coluna ensaio
  matriz$Ensaio <- seq_len(nrow(matriz))

  # reorganiza colunas
  if (incluir_tipo_ponto) {
    matriz <- matriz[, c("Ensaio", "Tipo_ponto", nomes_fatores, nome_resposta)]
  } else {
    matriz <- matriz[, c("Ensaio", nomes_fatores, nome_resposta)]
  }

  rownames(matriz) <- NULL

  return(matriz)
}
