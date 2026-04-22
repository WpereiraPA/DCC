#' @export
print.otimo_dcc <- function(x, digits = 4, ...) {

  cat("\nPonto ótimo do modelo DCC\n\n")

  objetivo_txt <- if (x$objetivo == "min") "Minimização" else "Maximização"
  cat("Objetivo:", objetivo_txt, "\n\n")

  cat("Coordenadas codificadas:\n")
  ponto <- unlist(x$ponto)

  for (i in seq_along(ponto)) {
    cat(names(ponto)[i], "=", format(round(ponto[i], digits), nsmall = digits), "\n")
  }

  cat("\nResposta estimada:\n")
  nome_resp <- if (!is.null(x$nome_resposta) && nzchar(x$nome_resposta)) {
    x$nome_resposta
  } else {
    "Resposta"
  }
  cat(nome_resp, "=", format(round(x$resposta, digits), nsmall = digits), "\n\n")

  cat("Status:\n")
  status <- ifelse(x$convergencia == 0,
                   "Convergência obtida com sucesso.",
                   "Falha na convergência.")
  cat(status, "\n")

  invisible(x)
}
