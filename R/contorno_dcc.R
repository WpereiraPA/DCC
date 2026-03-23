#' Gráfico de contorno para DCC
#'
#' @param fit objeto da classe dcc_fit.
#' @param x1 nome do primeiro fator.
#' @param x2 nome do segundo fator.
#' @param n número de pontos da grade.
#'
#' @return Gráfico de contorno.
#' @export
contorno_dcc <- function(fit, x1, x2, n = 100) {

  if (!inherits(fit, "dcc_fit")) {
    stop("O objeto fit precisa ser da classe 'dcc_fit'.")
  }

  if (!all(c(x1, x2) %in% fit$fatores)) {
    stop("x1 e x2 precisam estar entre os fatores do modelo.")
  }

  if (x1 == x2) {
    stop("x1 e x2 devem ser diferentes.")
  }

  xs <- seq(min(fit$dados[[x1]]), max(fit$dados[[x1]]), length.out = n)
  ys <- seq(min(fit$dados[[x2]]), max(fit$dados[[x2]]), length.out = n)

  grade <- expand.grid(xs, ys)
  names(grade) <- c(x1, x2)

  grade$AA <- grade[[x1]]^2
  grade$BB <- grade[[x2]]^2
  grade$AB <- grade[[x1]] * grade[[x2]]

  z <- stats::predict(fit$modelo, newdata = grade)
  zmat <- matrix(z, nrow = n, ncol = n)

  pal <- grDevices::colorRampPalette(
    c("#004d00", "green3", "chartreuse3", "yellow2", "orange", "thistle3")
  )

  niveis_fill <- seq(0.95, 1.70, by = 0.05)
  niveis_rotulo <- seq(1.00, 1.60, by = 0.10)

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
    main = paste("Gráfico de Contorno da", fit$resposta),
    key.title = graphics::title(main = fit$resposta, cex.main = 0.82),
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

          if (cl$level >= 1.60) {
            i <- ok[max(1, round(length(ok) * 0.12))]
          } else if (cl$level >= 1.50) {
            i <- ok[max(1, round(length(ok) * 0.24))]
          } else if (cl$level >= 1.40) {
            i <- ok[max(1, round(length(ok) * 0.38))]
          } else if (cl$level >= 1.20) {
            i <- ok[max(1, round(length(ok) * 0.50))]
          } else if (cl$level == 1.10) {
            i <- ok[max(1, round(length(ok) * 0.55))]
          } else {
            i <- ok[max(1, round(length(ok) * 0.58))]
          }

          desloc <- if (cl$level >= 1.60) {
            0.060 * diff(range(ys))
          } else if (cl$level >= 1.50) {
            0.040 * diff(range(ys))
          } else if (cl$level >= 1.40) {
            0.022 * diff(range(ys))
          } else if (cl$level >= 1.20) {
            0.012 * diff(range(ys))
          } else if (cl$level == 1.10) {
            0.030 * diff(range(ys))
          } else {
            -0.010 * diff(range(ys))
          }

          graphics::text(
            x = cl$x[i],
            y = cl$y[i] + desloc,
            labels = format(round(cl$level, 2), nsmall = 2),
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

      graphics::box()
    }
  )
}
