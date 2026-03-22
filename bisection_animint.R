install.packages("remotes")
remotes::install_github("tdhock/animint2")
# Bisection Method - animint2 port
# animation package original: https://yihui.org/animation/example/bisection-method/
# GSoC 2026 - animint2 medium task
# Nishita Shah

library(animint2)

# using the same default function and interval as animation::bisection.method
FUN <- function(x) x^2 - 4
rg <- c(-1, 10)
tol <- 0.001


# Step 1: build data.frames
# the idea is to replace the while loop + base plot calls with tidy
# data that animint can use

x_vals <- seq(min(rg), max(rg), length.out = 400)
curve_df <- data.frame(
  x = x_vals,
  y = FUN(x_vals)
)


l <- min(rg)
u <- max(rg)

# sanity check - f(l) and f(u) should have opposite signs
if (FUN(l) * FUN(u) > 0) stop("f(l) and f(u) must have opposite signs")

iter_list <- list()
i <- 1

while (i <= 30) {
  mid   <- (l + u) / 2
  f_mid <- FUN(mid)
  f_l   <- FUN(l)
  
  iter_list[[i]] <- data.frame(
    iteration = i,
    lower     = l,
    upper     = u,
    midpoint  = mid,
    f_lower   = f_l,
    f_upper   = FUN(u),
    f_mid     = f_mid,
    abs_f_mid = abs(f_mid)
  )
  
  if (abs(f_mid) <= tol) break
  
  # which half contains the root?
  if (f_l * f_mid > 0) {
    l <- mid
  } else {
    u <- mid
  }
  
  i <- i + 1
}


intervals_df <- do.call(rbind, iter_list)


vlines_df <- rbind(
  data.frame(iteration = intervals_df$iteration,
             x = intervals_df$lower,
             color = "lower", linetype = "boundary"),
  data.frame(iteration = intervals_df$iteration,
             x = intervals_df$upper,
             color = "upper", linetype = "boundary"),
  data.frame(iteration = intervals_df$iteration,
             x = intervals_df$midpoint,
             color = "midpoint", linetype = "midpoint")
)

y_lo <- min(curve_df$y)
y_hi <- max(curve_df$y)
vlines_df$y_start <- y_lo
vlines_df$y_end   <- y_hi

# convergence_df: tracks |f(mid)| and bracket width across iterations

convergence_df <- data.frame(
  iteration = intervals_df$iteration,
  abs_f_mid = intervals_df$abs_f_mid,
  width     = intervals_df$upper - intervals_df$lower,
  midpoint  = intervals_df$midpoint
)


# Step 2: ggplots


# plot 1 - main bisection plot
# shows the curve, the bracket endpoints (red dashed) and midpoint (blue)


p_bisect <- ggplot() +
  geom_tallrect(
    data = convergence_df,
    aes(xmin = iteration - 0.5, xmax = iteration + 0.5),
    clickSelects = "iteration",
    alpha = 0.2,
    fill = "gold"
  ) +
  geom_line(
    data = curve_df,
    aes(x = x, y = y),
    color = "black",
    size = 1
  ) +
  geom_hline(yintercept = 0, color = "gray60", linetype = "dashed") +
  geom_segment(
    data = vlines_df,
    aes(x = x, xend = x, y = y_start, yend = y_hi,
        color = color, linetype = linetype),
    showSelected = "iteration"
  ) +
  geom_point(
    data = intervals_df,
    aes(x = midpoint, y = f_mid),
    showSelected = "iteration",
    color = "blue",
    size = 4
  ) +
  scale_color_manual(
    values = c("lower" = "red", "upper" = "red", "midpoint" = "blue"),
    name = ""
  ) +
  scale_linetype_manual(
    values = c("boundary" = "dashed", "midpoint" = "solid"),
    name = ""
  ) +
  labs(
    title = "Bisection Method",
    x = "x",
    y = "f(x)"
  ) +
  theme_bw()

# plot 2 - |f(midpoint)| vs iteration
# the red dashed line is the tolerance threshold
# orange dot shows which iteration is currently selected

p_convergence <- ggplot() +
  geom_tallrect(
    data = convergence_df,
    aes(xmin = iteration - 0.5, xmax = iteration + 0.5),
    clickSelects = "iteration",
    alpha = 0.2,
    fill = "gold"
  ) +
  geom_line(
    data = convergence_df,
    aes(x = iteration, y = abs_f_mid),
    color = "steelblue",
    size = 1
  ) +
  geom_point(
    data = convergence_df,
    aes(x = iteration, y = abs_f_mid),
    color = "steelblue",
    size = 2
  ) +
  geom_point(
    data = convergence_df,
    aes(x = iteration, y = abs_f_mid),
    showSelected = "iteration",
    color = "orange",
    size = 5
  ) +
  geom_hline(yintercept = tol, color = "red", linetype = "dashed") +
  scale_y_log10() +
  labs(
    title = "|f(midpoint)| vs Iteration",
    x = "Iteration",
    y = "|f(midpoint)| (log scale)"
  ) +
  theme_bw()

# plot 3 - bracket width vs iteration



p_width <- ggplot() +
  geom_tallrect(
    data = convergence_df,
    aes(xmin = iteration - 0.5, xmax = iteration + 0.5),
    clickSelects = "iteration",
    alpha = 0.2,
    fill = "gold"
  ) +
  geom_line(
    data = convergence_df,
    aes(x = iteration, y = width),
    color = "darkgreen",
    size = 1
  ) +
  geom_point(
    data = convergence_df,
    aes(x = iteration, y = width),
    showSelected = "iteration",
    color = "orange",
    size = 5
  ) +
  scale_y_log10() +
  labs(
    title = "Bracket Width vs Iteration",
    x = "Iteration",
    y = "upper - lower (log scale)"
  ) +
  theme_bw()


# Step 3: animint list


viz <- animint(
  bisect      = p_bisect,
  convergence = p_convergence,
  width       = p_width,
  time        = list(variable = "iteration", ms = 1500),
  title       = "Bisection Method"
)


animint2dir(viz, out.dir = "bisection_animint_out")


cat("Iterations completed:", nrow(intervals_df), "\n")
cat("Root found:", intervals_df$midpoint[nrow(intervals_df)], "\n")
cat("f(root):", intervals_df$f_mid[nrow(intervals_df)], "\n")