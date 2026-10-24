# Multiple comparisons: 36 versions of the match letter

The Karlan and List mailing sent the match letter in 36 versions: 3 match ratios x 4 caps x 3 suggested gifts, about 927 donors each. Each version is
compared with the plain letter on the share who gave. Three versions look like wins at 5% before any correction. After correcting for 36 tries with
Bonferroni, Holm or Benjamini-Hochberg, none remains.

Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse, doi:10.7910/DVN/27853, CC0.

| result | value |
|---|---|
| versions tested | 36, each against the plain letter (16,687 donors, 1.79% gave) |
| look like wins at 0.05, before correction | 3 of 36 |
| kept after Bonferroni, Holm, Benjamini-Hochberg | 0, 0, 0 |
| best-looking version | 1:1 match, $100,000 cap, suggested gift 1.25x: 3.13% gave, p 0.0047, 0.168 after Holm |

Each version is compared with the plain letter on the share who gave, using a standard test of two proportions with a continuity correction.
Without that correction seven versions look like wins before adjustment; none survives either way. Each version reached only about 927 donors, so a
single version has little power: "none survives" means we cannot tell the versions apart, not that the match offer failed.

## Run it
```
Rscript analyses/multiple-comparisons/analysis.R
```
Needs R and the `haven` package. The script rewrites `results.txt` and `pvalues.csv` (a label and a raw p-value per version) beside it.

## Read more
- The idea behind the correction: https://mcpanalytics.ai/articles/multiple-comparisons-problem
- A free tool that takes a list of your own tests' p-values: https://mcpanalytics.ai/free/standard_multiple_comparisons_v2
