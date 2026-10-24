# Multiple comparisons on Karlan and List (2007): 36 versions of the match letter, each against the plain letter.
# Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse,
# doi:10.7910/DVN/27853, CC0. The file is in ../../data/ unchanged.
# The match letter came in 36 versions: match ratio (1:1, 2:1, 3:1) x match cap ($25,000, $50,000, $100,000, none stated) x
# suggested gift (the donor's highest past gift x 1, x 1.25, x 1.5), each sent to about 927 donors at random. Each version is
# compared with the plain letter (no match, 16,687 donors) on the share who gave: a two-sample test of proportions (prop.test,
# with a continuity correction), 36 tests. The family is then corrected three ways with base R p.adjust: Bonferroni, Holm and
# Benjamini-Hochberg.
# All 36 share one plain-letter group, so the tests are positively dependent. Bonferroni and Holm hold under any dependence;
# Benjamini-Hochberg is proven under positive dependence, which tests against a shared control have.
# Usage:  Rscript analysis.R [path/to/karlan_list_2007.dta]   (writes results.txt and pvalues.csv beside this script)
# Needs R and the 'haven' package.
suppressPackageStartupMessages(library(haven))
here <- dirname(normalizePath(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))))
args <- commandArgs(TRUE)
f <- if (length(args)) args[1] else file.path(here, "../../data/karlan_list_2007.dta")
d <- as.data.frame(zap_labels(read_dta(f)))
alpha <- 0.05
cap <- ifelse(d$size25 == 1, "$25,000 cap", ifelse(d$size50 == 1, "$50,000 cap", ifelse(d$size100 == 1, "$100,000 cap",
       ifelse(d$sizeno == 1, "no cap stated", NA))))
ask <- ifelse(d$askd1 == 1, "suggested gift 1x", ifelse(d$askd2 == 1, "suggested gift 1.25x", ifelse(d$askd3 == 1, "suggested gift 1.5x", NA)))
d$version <- ifelse(d$treatment == 1, sprintf("%d:1 match, %s, %s", as.integer(d$ratio), cap, ask), NA)
ctl <- d[d$treatment == 0, ]
x0 <- sum(ctl$gave); n0 <- nrow(ctl)
lv <- c(outer(outer(c("1:1", "2:1", "3:1"), c("$25,000 cap", "$50,000 cap", "$100,000 cap", "no cap stated"),
        paste, sep = " match, "), c("suggested gift 1x", "suggested gift 1.25x", "suggested gift 1.5x"), paste, sep = ", "))
stopifnot(length(lv) == 36, all(lv %in% d$version), sum(!is.na(d$version)) == sum(d$treatment == 1))
rows <- lapply(lv, function(v) {
  s <- d[d$version %in% v, ]; x1 <- sum(s$gave); n1 <- nrow(s)
  data.frame(test_label = v, n_letters = n1, gave = x1, rate = x1 / n1, rate_plain = x0 / n0,
             p_value = prop.test(c(x1, x0), c(n1, n0))$p.value, stringsAsFactors = FALSE)
})
r <- do.call(rbind, rows)
r$p_bonferroni <- p.adjust(r$p_value, "bonferroni")
r$p_holm <- p.adjust(r$p_value, "holm")
r$p_bh <- p.adjust(r$p_value, "BH")
r <- r[order(r$p_value), ]
m <- nrow(r)
k <- c(raw = sum(r$p_value < alpha), bonferroni = sum(r$p_bonferroni < alpha), holm = sum(r$p_holm < alpha),
       bh = sum(r$p_bh < alpha))
write.csv(r[, c("test_label", "p_value")], file.path(here, "pvalues.csv"), row.names = FALSE)
beat <- sum(r$rate > r$rate_plain)
exp_false <- alpha * m

sink(file.path(here, "results.txt"))
cat("MULTIPLE COMPARISONS on Karlan and List (2007). Input:", basename(f), "rows", nrow(d), "\n")
cat("Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse, doi:10.7910/DVN/27853, CC0.\n")
cat(sprintf("Family: %d letter versions (3 match ratios x 4 caps x 3 suggested gifts), each vs the plain letter (n %s, %d gave, %.2f%%); share who gave, prop.test; alpha %.2f\n",
            m, format(n0, big.mark = ","), x0, 100 * x0 / n0, alpha))
cat(sprintf("Letters per version: %d to %d\n", min(r$n_letters), max(r$n_letters)))
cat(sprintf("Versions with a higher giving rate than the plain letter: %d of %d\n", beat, m))
cat(sprintf("Look like wins at %.2f, uncorrected: %d of %d\n", alpha, k["raw"], m))
cat(sprintf("By chance alone, %d tests at %.2f would show about %.1f false wins\n", m, alpha, exp_false))
cat(sprintf("Kept by Bonferroni: %d\nKept by Holm: %d\nKept by Benjamini-Hochberg (5%% false discoveries): %d\n", k["bonferroni"], k["holm"], k["bh"]))
cat(sprintf("Dropped by Holm: %d of the %d apparent wins\n", k["raw"] - k["holm"], k["raw"]))
cat(sprintf("Smallest p-value: %.3g (%s, %.2f%% gave), Holm-adjusted %.3g, BH-adjusted %.3g\n",
            r$p_value[1], r$test_label[1], 100 * r$rate[1], r$p_holm[1], r$p_bh[1]))
cat(sprintf("Bonferroni threshold: %.3g (alpha / %d)\n\n", alpha / m, m))
o <- r; o$rate <- sprintf("%.2f%%", 100 * o$rate);
print(o[, c("test_label", "n_letters", "gave", "rate", "p_value", "p_bonferroni", "p_holm", "p_bh")],
      row.names = FALSE, digits = 4)
sink()
