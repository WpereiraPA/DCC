#' Gráfico de contorno para DCC
#'
#' @param fit objeto da classe dcc_fit.
#' @param x1 nome do primeiro fator.
#' @param x2 nome do segundo fator.
#' @param n número de pontos da grade.
#' @param mostrar_otimo se TRUE, exibe o ponto ótimo no gráfico.
#' @param mostrar_estacionario se TRUE, exibe o ponto estacionário no gráfico.
#' @param objetivo objetivo da otimização: "max" para maximizar ou "min" para minimizar.
#'
#' @return Gráfico de contorno.
#' @export
contorno_dcc <- function(fit,
                         x1,
                         x2,
                         n = 100,
                         mostrar_otimo = TRUE,
                         mostrar_estacionario = TRUE,
                         objetivo = "max") {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto fit precisa ser da classe 'dcc_fit'.")
  }

  if (missing(x1) || missing(x2)) {
    stop("Os argumentos 'x1' e 'x2' são obrigatórios.")
  }

  if (!is.character(x1) || length(x1) != 1 || is.na(x1) || trimws(x1) == "") {
    stop("O argumento 'x1' deve ser uma string não vazia.")
  }

  if (!is.character(x2) || length(x2) != 1 || is.na(x2) || trimws(x2) == "") {
    stop("O argumento 'x2' deve ser uma string não vazia.")
  }

  if (!all(c(x1, x2) %in% fit$fatores)) {
    stop("x1 e x2 precisam estar entre os fatores do modelo.")
  }

  if (x1 == x2) {
    stop("x1 e x2 devem ser diferentes.")
  }

  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 20) {
    stop("O argumento 'n' deve ser numérico e maior ou igual a 20.")
  }

  if (!is.character(objetivo) || length(objetivo) != 1 || is.na(objetivo)) {
    stop("O argumento 'objetivo' deve ser uma string: 'max' ou 'min'.")
  }

  objetivo <- tolower(trimws(objetivo))

  if (objetivo %in% c("max", "maximizar", "máximo", "maximo")) {
    objetivo <- "max"
  } else if (objetivo %in% c("min", "minimizar", "mínimo", "minimo")) {
    objetivo <- "min"
  } else {
    stop("O argumento 'objetivo' deve ser 'max' ou 'min'.")
  }

  n <- as.integer(n)

  xs <- seq(min(fit$dados[[x1]], na.rm = TRUE), max(fit$dados[[x1]], na.rm = TRUE), length.out = n)
  ys <- seq(min(fit$dados[[x2]], na.rm = TRUE), max(fit$dados[[x2]], na.rm = TRUE), length.out = n)

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
      stop("Não foi possível gerar as predições para o gráfico de contorno.")
    }
  )

  zmat <- matrix(z, nrow = n, ncol = n)

  zmin <- min(zmat, na.rm = TRUE)
  zmax <- max(zmat, na.rm = TRUE)

  niveis_fill <- seq(zmin, zmax, length.out = 13)
  niveis_rotulo <- pretty(c(zmin, zmax), n = 7)

  pal <- grDevices::colorRampPalette(
    c("#004d00", "green3", "chartreuse3", "yellow2", "orange", "thistle3")
  )

  cls <- grDevices::contourLines(
    x = xs,
    y = ys,
    z = zmat,
    levels = niveis_rotulo
  )

  xlim_inf <- min(xs)
  xlim_sup <- max(xs)
  ylim_inf <- min(ys)
  ylim_sup <- max(ys)

  nome_resp <- if (!is.null(fit$nome_resposta) && nzchar(fit$nome_resposta)) {
    fit$nome_resposta
  } else {
    "Resposta"
  }

  ot <- NULL
  if (isTRUE(mostrar_otimo)) {
    ot <- tryCatch(
      otimo_dcc(fit, objetivo = objetivo),
      error = function(e) NULL
    )
  }

  pe <- NULL
  if (isTRUE(mostrar_estacionario)) {
    pe <- tryCatch(
      ponto_estacionario_dcc(fit),
      error = function(e) NULL
    )
  }

  oldpar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(oldpar))

  graphics::par(mar = c(5.2, 5.2, 4.2, 8.5))

  graphics::filled.contour(
    x = xs,
    y = ys,
    z = zmat,
    levels = niveis_fill,
    color.palette = pal,
    xlab = x1,
    ylab = x2,
    main = paste("Gráfico de Contorno -", nome_resp),
    key.title = graphics::title(main = nome_resp, cex.main = 0.82),
    key.axes = graphics::axis(4, cex.axis = 0.9),
    plot.axes = {
      graphics::axis(1, cex.axis = 0.9)
      graphics::axis(2, cex.axis = 0.9)

      graphics::contour(
        x = xs,
        y = ys,
        z = zmat,
        levels = niveis_rotulo,
        add = TRUE,
        drawlabels = FALSE,
        col = "gray10",
        lwd = 1.2
      )

      for (cl in cls) {
        ok <- which(
          cl$x > (xlim_inf + 0.10 * diff(range(xs))) &
            cl$x < (xlim_sup - 0.02 * diff(range(xs))) &
            cl$y > (ylim_inf + 0.08 * diff(range(ys))) &
            cl$y < (ylim_sup - 0.04 * diff(range(ys)))
        )

        if (length(ok) > 0) {
          i <- ok[max(1, round(length(ok) * 0.5))]

          graphics::text(
            x = cl$x[i],
            y = cl$y[i],
            labels = format(round(cl$level, 2), nsmall = 2, decimal.mark = ","),
            cex = 0.85,
            col = "black"
          )
        }
      }

      graphics::points(
        fit$dados[[x1]],
        fit$dados[[x2]],
        pch = 15,
        cex = 0.7,
        col = "black"
      )

      legend_labels <- c("Pontos experimentais")
      legend_cols <- c("black")
      legend_pch <- c(15)

      if (!is.null(ot) && all(is.finite(ot$ponto))) {
        graphics::points(
          ot$ponto[x1],
          ot$ponto[x2],
          pch = 19,
          cex = 1.5,
          col = "red"
        )

        graphics::text(
          ot$ponto[x1],
          ot$ponto[x2],
          labels = "Ótimo",
          pos = 4,
          cex = 0.9,
          col = "red"
        )

        legend_labels <- c(legend_labels, "Ótimo")
        legend_cols <- c(legend_cols, "red")
        legend_pch <- c(legend_pch, 19)
      }

      if (!is.null(pe) && all(is.finite(as.numeric(pe$ponto)))) {
        px <- as.numeric(pe$ponto[[x1]])
        py <- as.numeric(pe$ponto[[x2]])

        graphics::points(
          px,
          py,
          pch = 17,
          cex = 1.5,
          col = "blue"
        )

        rotulo_est <- if (!is.null(pe$classificacao) && tolower(pe$classificacao) == "sela") {
          "Estacionário (sela)"
        } else {
          "Estacionário"
        }

        graphics::text(
          px,
          py,
          labels = rotulo_est,
          pos = 4,
          cex = 0.9,
          col = "blue"
        )

        legend_labels <- c(legend_labels, rotulo_est)
        legend_cols <- c(legend_cols, "blue")
        legend_pch <- c(legend_pch, 17)
      }

      graphics::legend(
        "topright",
        legend = legend_labels,
        col = legend_cols,
        pch = legend_pch,
        bty = "n",
        cex = 0.9
      )

      graphics::box()
    }
  )

  invisible(
    list(
      x = xs,
      y = ys,
      z = zmat,
      grade = grade,
      otimo = ot,
      estacionario = pe
    )
  )
}
