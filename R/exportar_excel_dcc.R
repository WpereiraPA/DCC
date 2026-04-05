#' Exporta resultados do DCC para Excel com abas e graficos
#'
#' @param fit objeto da classe dcc_fit
#' @param arquivo caminho completo do arquivo Excel
#' @param alpha nivel de significancia para destacar efeitos
#' @param fatores vetor opcional com os fatores a considerar nos graficos;
#'   se NULL, usa fit$fatores
#'
#' @return invisivelmente, o caminho do arquivo gerado
#' @export
exportar_excel_dcc <- function(fit,
                               arquivo = "C:/Users/Wanderley/Desktop/relatorio_dcc.xlsx",
                               alpha = 0.05,
                               fatores = NULL) {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto precisa ser da classe 'dcc_fit'.")
  }

  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Instale o pacote 'openxlsx' para usar esta função.")
  }

  if (is.null(fatores)) {
    fatores <- fit$fatores
  }

  fatores <- as.character(fatores)

  if (length(fatores) < 2) {
    stop("Sao necessarios pelo menos dois fatores para exportar superficies e contornos.")
  }

  if (!all(fatores %in% fit$fatores)) {
    stop("Todos os fatores informados precisam estar em fit$fatores.")
  }

  wb <- openxlsx::createWorkbook()

  # =======================
  # METRICAS
  # =======================
  met_df <- data.frame(
    Métrica = c("R²", "R² ajustado", "Erro padrão residual"),
    Valor = c(
      fit$r2,
      fit$r2_ajustado,
      summary(fit$modelo)$sigma
    ),
    check.names = FALSE
  )

  openxlsx::addWorksheet(wb, enc2utf8("Métricas"))
  openxlsx::writeData(wb, enc2utf8("Métricas"), met_df)
  openxlsx::freezePane(wb, enc2utf8("Métricas"), firstRow = TRUE)
  openxlsx::setColWidths(wb, enc2utf8("Métricas"), cols = 1:ncol(met_df), widths = "auto")

  # =======================
  # ANOVA
  # =======================
  anova_df <- as.data.frame(stats::anova(fit$modelo))
  anova_df$Termo <- rownames(anova_df)
  rownames(anova_df) <- NULL
  anova_df <- anova_df[, c("Termo", setdiff(names(anova_df), "Termo"))]

  openxlsx::addWorksheet(wb, "ANOVA")
  openxlsx::writeData(wb, "ANOVA", anova_df)
  openxlsx::freezePane(wb, "ANOVA", firstRow = TRUE)
  openxlsx::setColWidths(wb, "ANOVA", cols = 1:ncol(anova_df), widths = "auto")

  # =======================
  # COEFICIENTES
  # =======================
  coef_df <- fit$coeficientes

  openxlsx::addWorksheet(wb, enc2utf8("Coeficientes"))
  openxlsx::writeData(wb, enc2utf8("Coeficientes"), coef_df)
  openxlsx::freezePane(wb, enc2utf8("Coeficientes"), firstRow = TRUE)
  openxlsx::setColWidths(wb, enc2utf8("Coeficientes"), cols = 1:ncol(coef_df), widths = "auto")

  # =======================
  # EFEITOS
  # =======================
  s <- summary(fit$modelo)
  efeitos_df <- as.data.frame(s$coefficients, check.names = FALSE)
  efeitos_df$Termo <- rownames(efeitos_df)
  rownames(efeitos_df) <- NULL
  efeitos_df <- efeitos_df[efeitos_df$Termo != "(Intercept)", , drop = FALSE]

  efeitos_df$Significativo <- ifelse(efeitos_df$`Pr(>|t|)` <= alpha, "Sim", "Não")
  efeitos_df <- efeitos_df[, c("Termo", "Estimate", "Std. Error", "t value", "Pr(>|t|)", "Significativo")]
  efeitos_df$Termo <- as.character(efeitos_df$Termo)

  openxlsx::addWorksheet(wb, enc2utf8("Efeitos"))
  openxlsx::writeData(wb, enc2utf8("Efeitos"), efeitos_df)
  openxlsx::freezePane(wb, enc2utf8("Efeitos"), firstRow = TRUE)
  openxlsx::setColWidths(wb, enc2utf8("Efeitos"), cols = 1:ncol(efeitos_df), widths = "auto")

  style_sig <- openxlsx::createStyle(bgFill = "#C6EFCE")
  col_sig <- which(names(efeitos_df) == "Significativo")

  openxlsx::conditionalFormatting(
    wb,
    sheet = enc2utf8("Efeitos"),
    cols = 1:ncol(efeitos_df),
    rows = 2:(nrow(efeitos_df) + 1),
    rule = paste0("$", LETTERS[col_sig], '2="Sim"'),
    style = style_sig,
    type = "expression"
  )

  # =======================
  # PARETO
  # =======================
  tmp_pareto <- tempfile(fileext = ".png")
  grDevices::png(tmp_pareto, width = 2200, height = 1400, res = 220)
  graphics::par(cex = 1.35, cex.axis = 1.15, cex.lab = 1.2, cex.main = 1.3)
  pareto_dcc(fit)
  grDevices::dev.off()

  openxlsx::addWorksheet(wb, "Pareto")
  openxlsx::writeData(
    wb,
    "Pareto",
    enc2utf8("Gráfico de Pareto dos efeitos"),
    startRow = 1,
    startCol = 2
  )
  openxlsx::insertImage(
    wb, "Pareto", tmp_pareto,
    startRow = 3, startCol = 2,
    width = 11, height = 7, units = "in"
  )

  # =======================
  # SUPERFICIES E CONTORNOS
  # =======================
  pares <- utils::combn(fatores, 2, simplify = FALSE)
  arquivos_tmp <- character(0)

  nome_aba_seguro <- function(prefixo, f1, f2) {
    nome <- paste(prefixo, f1, "x", f2)
    nome <- gsub("[\\\\/:*?\\[\\]]", "_", nome)
    if (nchar(nome) > 31) {
      nome <- substr(nome, 1, 31)
    }
    nome
  }

  for (par_fatores in pares) {

    f1 <- par_fatores[1]
    f2 <- par_fatores[2]

    orientacoes <- list(
      c(f1, f2),
      c(f2, f1)
    )

    for (ori in orientacoes) {

      x_plot <- ori[1]
      y_plot <- ori[2]

      # -----------------------
      # SUPERFICIE
      # -----------------------
      tmp_sup <- tempfile(fileext = ".png")
      arquivos_tmp <- c(arquivos_tmp, tmp_sup)

      grDevices::png(tmp_sup, width = 2200, height = 1400, res = 220)

      superficie_dcc(fit, x1 = x_plot, x2 = y_plot)
      grDevices::dev.off()

      aba_sup <- nome_aba_seguro("Superf", x_plot, y_plot)
      openxlsx::addWorksheet(wb, aba_sup)
      openxlsx::writeData(
        wb,
        aba_sup,
        enc2utf8(paste0("Superfície de resposta: ", x_plot, " × ", y_plot)),
        startRow = 1,
        startCol = 2
      )
      openxlsx::insertImage(
        wb, aba_sup, tmp_sup,
        startRow = 3, startCol = 2,
        width = 11, height = 7, units = "in"
      )

      # -----------------------
      # CONTORNO
      # -----------------------
      tmp_cont <- tempfile(fileext = ".png")
      arquivos_tmp <- c(arquivos_tmp, tmp_cont)

      grDevices::png(tmp_cont, width = 2200, height = 1400, res = 220)
      graphics::par(cex = 1.25, cex.axis = 1.1, cex.lab = 1.15, cex.main = 1.2)
      contorno_dcc(fit, x1 = x_plot, x2 = y_plot)
      grDevices::dev.off()

      aba_cont <- nome_aba_seguro("Cont", x_plot, y_plot)
      openxlsx::addWorksheet(wb, aba_cont)
      openxlsx::writeData(
        wb,
        aba_cont,
        enc2utf8(paste0("Gráfico de contorno: ", x_plot, " × ", y_plot)),
        startRow = 1,
        startCol = 2
      )
      openxlsx::insertImage(
        wb, aba_cont, tmp_cont,
        startRow = 3, startCol = 2,
        width = 11, height = 7, units = "in"
      )
    }
  }

  # =======================
  # SALVAR
  # =======================
  openxlsx::saveWorkbook(wb, arquivo, overwrite = TRUE)

  arquivos_tmp <- unique(c(tmp_pareto, arquivos_tmp))
  arquivos_tmp <- arquivos_tmp[file.exists(arquivos_tmp)]

  if (length(arquivos_tmp) > 0) {
    unlink(arquivos_tmp, force = TRUE)
  }

  message("Arquivo Excel salvo em: ", arquivo)

  invisible(arquivo)
}
