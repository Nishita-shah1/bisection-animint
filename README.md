# Bisection Method — animint2 Port

An interactive visualization of the Bisection Method for root-finding, built with [animint2](https://github.com/tdhock/animint2) as part of the GSoC 2026 application.

**Live demo:** https://Nishita-shah1.github.io/bisection-animint/

**Wiki entry:** [Ports of animation examples](https://github.com/tdhock/animint/wiki/Ports-of-animation-examples)

**Original:** [animation::bisection.method()](https://yihui.org/animation/example/bisection-method/)

---

## What this shows

The bisection method finds the root of `f(x) = x² - 4` on the interval `[-1, 10]` by repeatedly halving the bracket containing the root.

Three linked interactive plots:

**Plot 1 — Bisection Main Plot**
Shows the function curve with the current bracket endpoints (red dashed lines) and midpoint (blue solid line) at each iteration. A blue dot marks `f(midpoint)` on the curve. The label shows the current midpoint and f(mid) value.

**Plot 2 — |f(midpoint)| vs Iteration**
Shows how close we are to the root at each step on a log scale. The red dashed line marks the tolerance threshold (0.001). The label shows the exact |f(mid)| value.

**Plot 3 — Bracket Width vs Iteration**
Confirms the bracket halves each step — a straight line on log scale. The label shows the exact bracket width.

Clicking any gold bar in any plot jumps all three plots to that iteration. The animation plays automatically at 1500ms per step.

---

## Algorithm details

```
f(x)  = x² - 4
root  = 2  (since f(2) = 0)
interval: [-1, 10]
tolerance: 0.001
iterations: 12
root found: 1.999756
```

The bisection algorithm:
1. Start with interval [l, u] where f(l) and f(u) have opposite signs
2. Compute midpoint c = (l + u) / 2
3. If f(l) × f(c) > 0, root is in [c, u], set l = c
4. Otherwise root is in [l, c], set u = c
5. Repeat until |f(c)| < tolerance

---

## How it was built

The base R `while` loop and `abline()` calls from `animation::bisection.method()` were translated into three data.frames:

- `curve_df` — 400-point grid of the function curve
- `intervals_df` + `vlines_df` — per-iteration bracket endpoints and midpoint for the vertical lines
- `convergence_df` — per-iteration `|f(midpoint)|` and bracket width

animint2 features used:
- `clickSelects = "iteration"` — gold bars are clickable
- `showSelected = "iteration"` — shows only the selected iteration's lines, point, and label
- `time = list(variable = "iteration", ms = 1500)` — drives auto-playback

---

## Source

- Source code: [bisection_animint.R](https://github.com/Nishita-shah1/bisection-animint/blob/main/bisection_animint.R)
- Part of GSoC 2026 application for the [animint2](https://github.com/tdhock/animint2) project

---

## How to run locally

```r
install.packages("remotes")
remotes::install_github("tdhock/animint2")

library(animint2)
source("bisection_animint.R")
```
