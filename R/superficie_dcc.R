#' Gráfico de superfície de resposta para DCC
#'
#' @param fit objeto da classe dcc_fit.
#' @param x1 nome do primeiro fator.
#' @param x2 nome do segundo fator.
#' @param n número de pontos da grade.
#'
#' @return Invisivelmente, uma lista com grade e matriz de predições.
#' @export
superficie_dcc <- function(fit, x1, x2, n = 45) {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto fit precisa ser da classe 'dcc_fit'.")
  }

  if (missing(x1) || missing(x2)) {
    stop("Os argumentos 'x1' e 'x2' são obrigatórios.")
  }

  if (!all(c(x1, x2) %in% fit$fatores)) {
    stop("x1 e x2 precisam estar entre os fatores do modelo.")
  }

  if (x1 == x2) {
    stop("x1 e x2 devem ser diferentes.")
  }

  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 10) {
    stop("O argumento 'n' deve ser numérico e maior ou igual a 10.")
  }

  xs <- seq(
    min(fit$dados[[x1]], na.rm = TRUE),
    max(fit$dados[[x1]], na.rm = TRUE),
    length.out = n
  )

  ys <- seq(
    min(fit$dados[[x2]], na.rm = TRUE),
    max(fit$dados[[x2]], na.rm = TRUE),
    length.out = n
  )

  grade <- expand.grid(xs, ys, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  names(grade) <- c(x1, x2)

  outros_fatores <- setdiff(fit$fatores, c(x1, x2))

  if (length(outros_fatores) > 0) {
    for (f in outros_fatores) {
      grade[[f]] <- 0
    }
  }

  grade <- grade[, fit$fatores, drop = FALSE]

  z <- tryCatch(
    stats::predict(fit$modelo, newdata = grade),
    error = function(e) {
      stop("Não foi possível gerar as predições para o gráfico de superfície.")
    }
  )

  zmat <- matrix(z, nrow = n, ncol = n)
  zlim <- range(zmat, na.rm = TRUE)

  pal <- grDevices::colorRampPalette(
    c("darkgreen", "green3", "chartreuse3", "yellow2", "goldenrod1", "thistle3")
  )
  cols <- pal(160)

  nrz <- nrow(zmat)
  ncz <- ncol(zmat)

  zfacet <- zmat[-1, -1] + zmat[-1, -ncz] + zmat[-nrz, -1] + zmat[-nrz, -ncz]
  zfacet <- c(zfacet / 4, zlim)

  idx <- cut(zfacet, breaks = length(cols), include.lowest = TRUE, labels = FALSE)
  facetcol <- cols[idx]

  nome_resp <- if (!is.null(fit$nome_resposta) && nzchar(fit$nome_resposta)) {
    fit$nome_resposta
  } else {
    fit$resposta
  }

  # Permite desenhar fora das margens sem cortar os textos
  oldpar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(oldpar), add = TRUE)
  graphics::par(xpd = TRUE)

  # 1. GERA O GRÁFICO BASE
  res <- graphics::persp(
    x = xs, y = ys, z = zmat, zlim = zlim,
    theta = 55, phi = 24, r = 3.5, expand = 0.70,
    col = facetcol, border = grDevices::adjustcolor("black", alpha.f = 0.35),
    box = TRUE, axes = FALSE,
    shade = 0.5, ltheta = 50, lphi = 25,
    main = paste("Superfície de Resposta -", nome_resp)
  )

  # 2. DEFINIÇÃO DOS PONTOS (Baseados no plano fatorial vs axiais)
  xt_base <- pretty(xs, n = 5)
  xt_base <- xt_base[xt_base > min(xs) & xt_base < max(xs)] # Valores entre -1.0 e 1.0
  xt_ext  <- c(min(xs), max(xs)) # Apenas os axiais (-1.414 e 1.414)
  xt_all  <- c(xt_ext[1], xt_base, xt_ext[2])

  yt_base <- pretty(ys, n = 5)
  yt_base <- yt_base[yt_base > min(ys) & yt_base < max(ys)]
  yt_ext  <- c(min(ys), max(ys))
  yt_all  <- c(yt_ext[1], yt_base, yt_ext[2])

  zt <- pretty(zlim, n = 5)
  zt <- zt[zt >= min(zlim) & zt <= max(zlim)]

  fmt <- function(val) {
    s <- as.character(round(val, 3))
    s <- gsub("\\.", ",", s)
    s <- ifelse(grepl(",", s), s, paste0(s, ",0"))
    return(s)
  }

  dx <- (max(xs) - min(xs)) * 0.04
  dy <- (max(ys) - min(ys)) * 0.04

  # 3. CÁLCULO DOS ÂNGULOS DE PROJEÇÃO DA CAIXA
  p_origem <- grDevices::trans3d(min(xs), min(ys), min(zlim), res)
  p_x_fim  <- grDevices::trans3d(max(xs), min(ys), min(zlim), res)
  p_y_fim  <- grDevices::trans3d(max(xs), max(ys), min(zlim), res)

  ang_x <- atan2(p_x_fim$y - p_origem$y, p_x_fim$x - p_origem$x) * 180 / pi
  ang_y <- atan2(p_y_fim$y - p_x_fim$y, p_y_fim$x - p_x_fim$x) * 180 / pi

  # ---- Eixo X (Aresta Frontal-Esquerda) ----
  # Tracinhos para todos os pontos
  x_start <- grDevices::trans3d(xt_all, min(ys), min(zlim), res)
  x_end   <- grDevices::trans3d(xt_all, min(ys) - (dy * 0.25), min(zlim), res)
  graphics::segments(x_start$x, x_start$y, x_end$x, x_end$y)

  # Rótulos Base (Paralelos)
  x_lab_base <- grDevices::trans3d(xt_base, min(ys) - (dy * 1.2), min(zlim), res)
  graphics::text(x_lab_base$x, x_lab_base$y, labels = fmt(xt_base), cex = 0.85, srt = ang_x)

  # Rótulos Extremos (Perpendiculares - Rotacionados em 90 graus para fora)
  x_lab_ext <- grDevices::trans3d(xt_ext, min(ys) - (dy * 0.6), min(zlim), res)
  graphics::text(x_lab_ext$x, x_lab_ext$y, labels = fmt(xt_ext), cex = 0.85, srt = ang_x + 90, adj = c(1, 0.5))

  # Título
  x_title <- grDevices::trans3d(mean(xs), min(ys) - (dy * 4.5), min(zlim), res)
  graphics::text(x_title$x, x_title$y, labels = x1, cex = 1.0, srt = ang_x)

  # ---- Eixo Y (Aresta Frontal-Direita) ----
  # Tracinhos
  y_start <- grDevices::trans3d(max(xs), yt_all, min(zlim), res)
  y_end   <- grDevices::trans3d(max(xs) + (dx * 0.25), yt_all, min(zlim), res)
  graphics::segments(y_start$x, y_start$y, y_end$x, y_end$y)

  # Rótulos Base (Paralelos)
  y_lab_base <- grDevices::trans3d(max(xs) + (dx * 1.2), yt_base, min(zlim), res)
  graphics::text(y_lab_base$x, y_lab_base$y, labels = fmt(yt_base), cex = 0.85, srt = ang_y)

  # Rótulos Extremos (Perpendiculares - Rotacionados em -90 graus para fora)
  y_lab_ext <- grDevices::trans3d(max(xs) + (dx * 0.6), yt_ext, min(zlim), res)
  graphics::text(y_lab_ext$x, y_lab_ext$y, labels = fmt(yt_ext), cex = 0.85, srt = ang_y - 90, adj = c(0, 0.5))

  # Título
  y_title <- grDevices::trans3d(max(xs) + (dx * 4.5), mean(ys), min(zlim), res)
  graphics::text(y_title$x, y_title$y, labels = x2, cex = 1.0, srt = ang_y)

  # ---- Eixo Z (Ra - Coluna Extrema-Esquerda) ----
  z_start <- grDevices::trans3d(min(xs), min(ys), zt, res)
  z_end   <- grDevices::trans3d(min(xs) - (dx * 0.25), min(ys) - (dy * 0.25), zt, res)
  graphics::segments(z_start$x, z_start$y, z_end$x, z_end$y)

  # Eixo Z mantém-se ancorado normalmente
  z_lab <- grDevices::trans3d(min(xs) - (dx * 0.8), min(ys) - (dy * 0.8), zt, res)
  graphics::text(z_lab$x, z_lab$y, labels = fmt(zt), cex = 0.85, adj = c(1, 0.5))

  z_title <- grDevices::trans3d(min(xs) - (dx * 3.5), min(ys) - (dy * 3.5), mean(zlim), res)
  graphics::text(z_title$x, z_title$y, labels = nome_resp, cex = 1.0, srt = 90)

  invisible(list(x = xs, y = ys, z = zmat, grade = grade))
}
