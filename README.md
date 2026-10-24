# Replication: Karlan and List (2007), did the match offer cause more giving?

A re-runnable replication, in R, of one question asked of the Karlan and List charity mailing: did the matching-gift offer cause more
people to give, and more money, than the same letter without it?

Karlan, D. and List, J. A. (2007). Does price matter in charitable giving? Evidence from a large-scale natural field experiment.
American Economic Review, 97(5).

Data: Dean Karlan and John A. List (2007), Does Price Matter in Charitable Giving?, Harvard Dataverse, doi:10.7910/DVN/27853, CC0.

## What this repository does
50,083 past donors were mailed at random: 16,687 got the plain letter and 33,396 got a letter with a match offer. We compare the two groups.

| result | value |
|---|---|
| gave, match-offer group | 736 of 33,396 (2.20%) |
| gave, plain-letter group | 298 of 16,687 (1.79%) |
| difference in the share who gave | +0.418 points (95% range 0.157 to 0.668), p 0.0019 |
| people to size a test of this lift | about 17,561 per group at 80% power, 5% significance |

In the randomized pooled comparison the match offer raised giving. The test is a pooled two-proportion z test, with a Newcombe
hybrid-score interval for the difference. Amount per letter uses a Welch t interval. Full output: `analyses/incrementality/results.txt`.

## Files
| file | what it is |
|---|---|
| `data/karlan_list_2007.dta` | the published data file, unchanged. sha256 `7d13b9c4394c567a663c9eed27e1212204b65fe284f64edc772d7f61bdb330b5` |
| `data/CREDIT.md` | citation and licence for the data |
| `analyses/incrementality/analysis.R` | the analysis |
| `analyses/incrementality/results.txt` | the expected output |
| `CITATION.cff` | how to cite this repository |
| `LICENSE` | data CC0 as published; our code MIT |

## Run it
```
Rscript analyses/incrementality/analysis.R
```
Needs R and the `haven` package. Run on 2026-10-24 with R 4.5.1 and haven 2.5.5. The script rewrites `results.txt` beside it; on a clean
clone, `git diff` shows no change. To check the data file is the published one: `shasum -a 256 data/karlan_list_2007.dta`.

## Limits
These are the study's public data and our analysis of them; conclusions about your own data need your own data. The control group still
received a letter, so this measures what the offer caused, not what mailing caused.

## Read more
- The business explanation: https://mcpanalytics.ai/articles/incrementality-measurement-did-the-campaign-actually-cause-anything
- A free tool that runs the same method on your own data: https://mcpanalytics.ai/incrementality-test

This repository holds the analysis script, the data and the expected output only.
