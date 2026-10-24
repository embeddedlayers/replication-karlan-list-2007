# Incrementality on Karlan and List (2007): did the matching-gift OFFER cause more people to give, and more money,
# than the same letter without it?
# Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse,
# doi:10.7910/DVN/27853, CC0. The file is in ../../data/ unchanged.
# Treatment = any match offer (all ratios, caps and suggested gifts pooled); control = the standard letter. The control still
# got a letter, so this measures what the offer caused, not what mailing caused.
# Intervals: Newcombe hybrid-score interval for a difference of rates, Welch t interval for amount per person.
# Usage:  Rscript analysis.R [path/to/karlan_list_2007.dta]   (writes results.txt beside this script)
# Needs R and the 'haven' package.
suppressPackageStartupMessages(library(haven))
here <- dirname(normalizePath(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))))
args <- commandArgs(TRUE)
f <- if (length(args)) args[1] else file.path(here, "../../data/karlan_list_2007.dta")
if (!file.exists(f)) stop("data file not found: ", f)
d <- as.data.frame(zap_labels(read_dta(f)))
stopifnot(all(c("treatment", "gave", "amount") %in% names(d)))
d <- d[!is.na(d$treatment) & !is.na(d$gave), ]
d$group <- ifelse(d$treatment == 1, "Match offer", "Control")
t <- d[d$group == "Match offer", ]; ctl <- d[d$group == "Control", ]

z <- qnorm(0.975)
wilson <- function(x, m) { ph <- x / m; den <- 1 + z^2 / m; ctr <- (ph + z^2 / (2 * m)) / den
  half <- z * sqrt(ph * (1 - ph) / m + z^2 / (4 * m^2)) / den; c(ctr - half, ctr + half) }
rate_lift <- function(x1, n1, x0, n0) {
  p1 <- x1 / n1; p0 <- x0 / n0; w1 <- wilson(x1, n1); w0 <- wilson(x0, n0)
  se <- sqrt(p1 * (1 - p1) / n1 + p0 * (1 - p0) / n0)
  pp <- (x1 + x0) / (n1 + n0)
  c(lift = p1 - p0, lo = p1 - p0 - sqrt((p1 - w1[1])^2 + (w0[2] - p0)^2),
    hi = p1 - p0 + sqrt((w1[2] - p1)^2 + (p0 - w0[1])^2), rel = (p1 - p0) / p0,
    p = 2 * pnorm(-abs((p1 - p0) / sqrt(pp * (1 - pp) * (1 / n1 + 1 / n0)))))
  # p: pooled two-proportion z test
}
gv <- rate_lift(sum(t$gave), nrow(t), sum(ctl$gave), nrow(ctl))
w <- t.test(t$amount, ctl$amount)
am <- c(lift = unname(diff(rev(w$estimate))), lo = w$conf.int[1], hi = w$conf.int[2], rel = unname(diff(rev(w$estimate)) / w$estimate[2]), p = w$p.value)
givers <- sum(t$gave); anyway <- nrow(t) * mean(ctl$gave); caused <- givers - anyway
need <- ceiling(power.prop.test(p1 = mean(ctl$gave), p2 = mean(t$gave), sig.level = 0.05, power = 0.8)$n)

sink(file.path(here, "results.txt"), split = TRUE)
cat("INCREMENTALITY on Karlan and List (2007). Input:", basename(f), "rows", nrow(d), "\n")
cat("Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse, doi:10.7910/DVN/27853, CC0\n\n")
cat(sprintf("GROUPS: Match offer n %d, gave %d (%.3f%%), amount per letter $%.3f | Control n %d, gave %d (%.3f%%), amount per letter $%.3f\n",
            nrow(t), sum(t$gave), 100 * mean(t$gave), mean(t$amount), nrow(ctl), sum(ctl$gave), 100 * mean(ctl$gave), mean(ctl$amount)))
bal <- intersect(c("mrm2", "hpa", "freq", "years", "year5", "female", "couple", "dormant"), names(d))
if (length(bal)) { cat("\nBALANCE (before the mailing, group means)\n"); print(round(sapply(bal, function(v) tapply(d[[v]], d$group, mean, na.rm = TRUE)), 3)) }
cat(sprintf("\nGAVE: +%.3f pts (95%% CI %.3f to %.3f), relative +%.0f%%, p %.2g\n", 100*gv[1], 100*gv[2], 100*gv[3], 100*gv[4], gv[5]))
cat(sprintf("AMOUNT per letter: +$%.3f (95%% CI %.3f to %.3f), relative +%.0f%%, p %.2g\n", am[1], am[2], am[3], 100*am[4], am[5]))
cat(sprintf("CREDIT vs CAUSE: %d people who got the offer gave; %.0f would have given anyway; about %.0f caused (95%% range %.0f to %.0f; %.0f%% of the givers)\n",
            givers, anyway, caused, gv[["lo"]] * nrow(t), gv[["hi"]] * nrow(t), 100 * caused / givers))
cat(sprintf("HOLDOUT SIZE: to detect this lift in giving at 80%% power (alpha 0.05), about %s people per group\n", format(need, big.mark = ",")))
cat(sprintf("EXTRA MONEY: $%.0f across the offer group, $%.0f per 1,000 letters\n", am[1] * nrow(t), 1000 * am[1]))
sink()
# Giving rate by arm and by match ratio (Wilson 95% intervals), and gift size among givers; appended to results.txt.
arms <- list("Control" = ctl, "Match offer (all)" = t, "Match 1:1" = d[d$treatment == 1 & d$ratio == 1, ],
             "Match 2:1" = d[d$treatment == 1 & d$ratio == 2, ], "Match 3:1" = d[d$treatment == 1 & d$ratio == 3, ])
rates <- do.call(rbind, lapply(names(arms), function(a) { x <- arms[[a]]; ci <- wilson(sum(x$gave), nrow(x))
  data.frame(arm = a, n = nrow(x), gave = sum(x$gave), rate_pct = 100 * mean(x$gave), lo_pct = 100 * ci[1], hi_pct = 100 * ci[2]) }))
bands <- c(0, 10, 20, 25, 50, 100, Inf); labs <- c("$1-9", "$10-19", "$20-24", "$25-49", "$50-99", "$100+")
gt <- t$amount[t$gave == 1]; gc <- ctl$amount[ctl$gave == 1]
share <- function(v) as.numeric(table(cut(v, bands, labs, right = FALSE))) / length(v) * 100
gifts <- data.frame(band = labs, offer_n = as.numeric(table(cut(gt, bands, labs, right = FALSE))), offer_pct = share(gt),
                    control_n = as.numeric(table(cut(gc, bands, labs, right = FALSE))), control_pct = share(gc))
wg <- t.test(gt, gc)
sink(file.path(here, "results.txt"), append = TRUE, split = TRUE)
cat("\nCHART DATA\n")
cat("GIVING RATE BY ARM (Wilson 95% interval):\n")
for (i in seq_len(nrow(rates))) with(rates[i, ], cat(sprintf("  %-18s n %6d gave %4d  %.2f%% (95%% CI %.2f to %.2f)\n", arm, n, gave, rate_pct, lo_pct, hi_pct)))
cat(sprintf("GIFT SIZE AMONG GIVERS: offer median $%.0f, mean $%.2f (n %d) | control median $%.0f, mean $%.2f (n %d); difference in mean gift $%.2f (95%% CI %.2f to %.2f, Welch)\n",
            median(gt), mean(gt), length(gt), median(gc), mean(gc), length(gc), mean(gt) - mean(gc), wg$conf.int[1], wg$conf.int[2]))
cat("GIFT BANDS, share of givers (offer | control):\n")
for (i in seq_len(nrow(gifts))) with(gifts[i, ], cat(sprintf("  %-7s %5.1f%% (%d) | %5.1f%% (%d)\n", band, offer_pct, offer_n, control_pct, control_n)))
cat(sprintf("MONEY INTERVAL (for the chart): extra gift money per 1,000 letters $%.0f, 95%% CI $%.0f to $%.0f; zero is inside\n", 1000 * am[1], 1000 * am[2], 1000 * am[3]))
sink()
