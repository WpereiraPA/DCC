#' Ler dados copiados da planilha para DCC
#'
#' Lê do clipboard uma tabela copiada do Excel, esperando colunas
#' com os fatores codificados e a resposta.
#'
#' @return Um data.frame com os dados lidos do clipboard.
#' @export
read_clipboard_dcc <- function() {
  df <- utils::read.table(
    "clipboard",
    header = TRUE,
    sep = "\t",
    dec = ",",
    check.names = FALSE
  )

  as.data.frame(df)
}
