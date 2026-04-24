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

  # Geração do Gráfico com ajuste de distância no zlab
  graphics::persp(
    x = xs,
    y = ys,
    z = zmat,
    zlim = zlim,
    theta = 55,
    phi = 24,
    r = 3.5,
    expand = 0.70,
    col = facetcol,
    border = grDevices::adjustcolor("black", alpha.f = 0.35),
    ticktype = "detailed",
    shade = 0.5,
    ltheta = 50,
    lphi = 25,
    xlab = x1,
    ylab = x2,
    zlab = paste0("\n", nome_resp), # Apenas uma quebra de linha agora
    cex.lab = 1.0,
    cex.axis = 0.85,
    main = paste("Superfície de Resposta -", nome_resp)
  )

  invisible(
    list(
      x = xs,
      y = ys,
      z = zmat,
      grade = grade
    )
  )
}
