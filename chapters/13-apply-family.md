The Apply Family in R
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 11, we learned to repeat operations with loops. In Chapter
12, we created reusable functions. Now we combine these ideas using the
**apply family**: functions that apply a specified operation across
vectors, lists, matrices, arrays, and groups. All examples use **base
R** and synthetic biomedical, epidemiological, or genomic data. No
packages or external files are required.

The main question is not simply whether an apply function is shorter
than a loop. We must select a function whose **input structure, output
type, and grouping behavior** match the scientific task.

## 13.1 Learning objectives

After completing this chapter, we should be able to:

1.  Explain how the apply family relates to `for` loops and user-defined
    functions.
2.  Distinguish `apply()`, `lapply()`, `sapply()`, `vapply()`,
    `tapply()`, `mapply()`, and `Map()`.
3.  Use `apply()` with row and column margins of matrices and arrays.
4.  Recognize how `apply()` may coerce mixed-type data frames.
5.  Use `lapply()` to retain a list structure.
6.  Understand `sapply()` simplification and why it can be fragile.
7.  Use `vapply()` for type-safe, predictable outputs.
8.  Summarize observations by categorical groups with `tapply()`.
9.  Apply functions to corresponding elements with `mapply()` and
    `Map()`.
10. Work safely with missing values, empty groups, and heterogeneous
    outputs.
11. Construct practical workflows for biomarkers, participant data, gene
    expression, and GWAS summary statistics.
12. Check apply-family results against explicit loops and built-in
    alternatives.

------------------------------------------------------------------------

## 13.2 From loops to function application

Suppose five participants have systolic blood pressure measurements:

``` r
sbp <- c(120, 150, 145, 115, 142)
```

A loop can transform every measurement:

``` r
result_loop <- numeric(length(sbp))
for (i in seq_along(sbp)) {
  result_loop[i] <- sbp[i] - 120
}
result_loop
```

    ## [1]  0 30 25 -5 22

But vectorized arithmetic is simpler:

``` r
result_vectorized <- sbp - 120
stopifnot(identical(result_loop, result_vectorized))
```

When an operation is already vectorized, we usually do **not** need an
apply function. The apply family becomes particularly useful when an
operation must be performed separately for each list element, matrix
margin, or category.

## 13.3 A quick comparison

| Function | Typical input | Operation | Typical output |
|----|----|----|----|
| `apply()` | Matrix or array | Across rows, columns, or dimensions | Vector, matrix, or array; sometimes list |
| `lapply()` | List or vector | Each element | List |
| `sapply()` | List or vector | Each element | Simplified result if possible |
| `vapply()` | List or vector | Each element | Predetermined type and shape |
| `tapply()` | Vector and grouping factor(s) | Within groups | Array or list |
| `mapply()` | Multiple vectors or lists | Corresponding elements | Simplified result if possible |
| `Map()` | Multiple vectors or lists | Corresponding elements | List |

We will examine each in detail.

------------------------------------------------------------------------

# Part I — `apply()`

## 13.4 Understanding `apply(X, MARGIN, FUN)`

The main arguments are:

``` r
apply(X, MARGIN, FUN, ...)
```

- `X`: matrix or array.
- `MARGIN`: dimensions to retain while applying the function.
- `FUN`: function to apply.
- `...`: additional arguments passed to `FUN`.

For a two-dimensional matrix:

- `MARGIN = 1` means operate **across each row**.
- `MARGIN = 2` means operate **down each column**.

A useful mental model is: the margin identifies the dimension used to
**index the results**.

## 13.5 Create a biomarker matrix

Rows represent participants and columns represent repeated measurements.

``` r
biomarkers <- matrix(
  c(110, 120, 130,
    125, 135, 145,
    140, 150, 160,
    115, 125, 135),
  nrow = 4,
  byrow = TRUE,
  dimnames = list(
    c("P001", "P002", "P003", "P004"),
    c("Visit1", "Visit2", "Visit3")
  )
)
biomarkers
```

    ##      Visit1 Visit2 Visit3
    ## P001    110    120    130
    ## P002    125    135    145
    ## P003    140    150    160
    ## P004    115    125    135

### Mean across each participant’s visits

``` r
row_means <- apply(biomarkers, 1, mean)
row_means
```

    ## P001 P002 P003 P004 
    ##  120  135  150  125

For participant P001:

$$\bar{x}_{P001}=\frac{110+120+130}{3}=120.$$

### Mean across participants for each visit

``` r
column_means <- apply(biomarkers, 2, mean)
column_means
```

    ## Visit1 Visit2 Visit3 
    ##  122.5  132.5  142.5

For Visit1:

$$\bar{x}_{Visit1}=\frac{110+125+140+115}{4}=122.5.$$

### Validate with specialized functions

``` r
stopifnot(isTRUE(all.equal(row_means, rowMeans(biomarkers))))
stopifnot(isTRUE(all.equal(column_means, colMeans(biomarkers))))
```

For simple sums and means, `rowMeans()`, `colMeans()`, `rowSums()`, and
`colSums()` are often clearer and more efficient.

## 13.6 Apply different functions

``` r
apply(biomarkers, 1, min)
```

    ## P001 P002 P003 P004 
    ##  110  125  140  115

``` r
apply(biomarkers, 1, max)
```

    ## P001 P002 P003 P004 
    ##  130  145  160  135

``` r
apply(biomarkers, 1, sd)
```

    ## P001 P002 P003 P004 
    ##   10   10   10   10

``` r
apply(biomarkers, 2, median)
```

    ## Visit1 Visit2 Visit3 
    ##    120    130    140

`sd()` computes the **sample standard deviation** using denominator
$n-1$. We should distinguish within-participant variability across
visits from between-participant variability at one visit.

## 13.7 Pass extra arguments through `...`

Introduce missing observations:

``` r
biomarkers_na <- biomarkers
biomarkers_na[2, 2] <- NA_real_
biomarkers_na
```

    ##      Visit1 Visit2 Visit3
    ## P001    110    120    130
    ## P002    125     NA    145
    ## P003    140    150    160
    ## P004    115    125    135

Without missing-value handling:

``` r
apply(biomarkers_na, 1, mean)
```

    ## P001 P002 P003 P004 
    ##  120   NA  150  125

With missing-value handling:

``` r
apply(biomarkers_na, 1, mean, na.rm = TRUE)
```

    ## P001 P002 P003 P004 
    ##  120  135  150  125

Here, `na.rm = TRUE` is passed to `mean()`, not to `apply()` itself.

**Scientific caution:** Excluding missing observations changes the
effective number of measurements and does not guarantee an unbiased
estimate.

## 13.8 Apply a custom function

We may want the observed range for each participant:

$$R_i=\max_j(X_{ij})-\min_j(X_{ij}).$$

``` r
measurement_range <- function(x) {
  if (all(is.na(x))) return(NA_real_)
  max(x, na.rm = TRUE) - min(x, na.rm = TRUE)
}

apply(biomarkers_na, 1, measurement_range)
```

    ## P001 P002 P003 P004 
    ##   20   20   20   20

The explicit all-missing check prevents meaningless infinite endpoints.

## 13.9 Anonymous functions

An anonymous function is created without assigning a permanent name:

``` r
apply(biomarkers, 1, function(x) {
  mean(x) - x[1]
})
```

    ## P001 P002 P003 P004 
    ##   10   10   10   10

This computes each participant’s mean minus the first visit’s
measurement. Anonymous functions are useful for short, one-off
operations.

## 13.10 Applying functions to a three-dimensional array

Suppose a synthetic gene-expression array has dimensions **gene × sample
× tissue**.

``` r
expression_array <- array(
  seq(1, 24),
  dim = c(2, 3, 4),
  dimnames = list(
    Gene = c("Gene_A", "Gene_B"),
    Sample = c("S1", "S2", "S3"),
    Tissue = c("Cortex", "Blood", "Liver", "Muscle")
  )
)
```

### Mean across samples, retaining gene and tissue

``` r
gene_tissue_means <- apply(expression_array, c(1, 3), mean)
gene_tissue_means
```

    ##         Tissue
    ## Gene     Cortex Blood Liver Muscle
    ##   Gene_A      3     9    15     21
    ##   Gene_B      4    10    16     22

`MARGIN = c(1, 3)` retains the gene and tissue dimensions while reducing
the sample dimension.

### Mean for each tissue across genes and samples

``` r
apply(expression_array, 3, mean)
```

    ## Cortex  Blood  Liver Muscle 
    ##    3.5    9.5   15.5   21.5

### Mean for each gene across samples and tissues

``` r
apply(expression_array, 1, mean)
```

    ## Gene_A Gene_B 
    ##     12     13

The correct margin depends on the scientific question and the meaning of
each dimension.

## 13.11 Why `apply()` can be unsafe on mixed-type data frames

Consider:

``` r
clinical <- data.frame(
  id = c("P001", "P002", "P003"),
  age = c(35, 50, 60),
  sbp = c(120, 145, 150)
)
```

A mixed-type data frame may be coerced to a character matrix by
`apply()`:

``` r
clinical_matrix <- as.matrix(clinical)
typeof(clinical_matrix)
```

    ## [1] "character"

The following operation would therefore be inappropriate:

``` r
apply(clinical, 1, mean)
```

Select numerical columns explicitly:

``` r
numeric_clinical <- clinical[, c("age", "sbp"), drop = FALSE]
apply(numeric_clinical, 2, mean)
```

    ##       age       sbp 
    ##  48.33333 138.33333

However, taking a row mean across **age and SBP** would mix different
physical quantities and generally have no meaningful biomedical
interpretation. Numerical compatibility is not the same as scientific
comparability.

------------------------------------------------------------------------

# Part II — `lapply()`

## 13.12 The structure of `lapply()`

``` r
lapply(X, FUN, ...)
```

`lapply()` applies `FUN` to every element of `X` and **always returns a
list**.

Consider three tissues with different numbers of observations:

``` r
tissue_values <- list(
  Cortex = c(5.1, 6.2, 5.8),
  Blood = c(3.9, 4.2),
  Liver = c(7.0, 7.4, 7.2, 7.8)
)
str(tissue_values)
```

    ## List of 3
    ##  $ Cortex: num [1:3] 5.1 6.2 5.8
    ##  $ Blood : num [1:2] 3.9 4.2
    ##  $ Liver : num [1:4] 7 7.4 7.2 7.8

Calculate the mean of each element:

``` r
tissue_means_list <- lapply(tissue_values, mean)
tissue_means_list
```

    ## $Cortex
    ## [1] 5.7
    ## 
    ## $Blood
    ## [1] 4.05
    ## 
    ## $Liver
    ## [1] 7.35

``` r
class(tissue_means_list)
```

    ## [1] "list"

Every list element contains one mean, but the outer object remains a
list.

## 13.13 Return multiple statistics per element

``` r
summarize_numeric <- function(x) {
  c(
    n = length(x),
    mean = mean(x),
    sd = sd(x),
    minimum = min(x),
    maximum = max(x)
  )
}

summary_list <- lapply(tissue_values, summarize_numeric)
summary_list
```

    ## $Cortex
    ##         n      mean        sd   minimum   maximum 
    ## 3.0000000 5.7000000 0.5567764 5.1000000 6.2000000 
    ## 
    ## $Blood
    ##        n     mean       sd  minimum  maximum 
    ## 2.000000 4.050000 0.212132 3.900000 4.200000 
    ## 
    ## $Liver
    ##        n     mean       sd  minimum  maximum 
    ## 4.000000 7.350000 0.341565 7.000000 7.800000

Here, `lapply()` is natural because each element returns a vector of
statistics.

## 13.14 Return data frames from `lapply()`

``` r
tissue_summary_rows <- lapply(names(tissue_values), function(tissue) {
  x <- tissue_values[[tissue]]
  data.frame(
    tissue = tissue,
    n = length(x),
    mean = mean(x),
    sd = sd(x)
  )
})

tissue_summary <- do.call(rbind, tissue_summary_rows)
rownames(tissue_summary) <- NULL
tissue_summary
```

    ##   tissue n mean        sd
    ## 1 Cortex 3 5.70 0.5567764
    ## 2  Blood 2 4.05 0.2121320
    ## 3  Liver 4 7.35 0.3415650

`do.call(rbind, ...)` supplies the list elements as arguments to
`rbind()`. This works because the returned data frames have compatible
columns.

## 13.15 Lists of heterogeneous results

``` r
qc_bundle <- list(
  variants = data.frame(ID = c("rs1", "rs2"), PVAL = c(1e-8, 0.2)),
  settings = list(threshold = 5e-8, genome_build = "hg38"),
  notes = "Synthetic teaching data"
)
```

We can inspect each element’s class:

``` r
lapply(qc_bundle, class)
```

    ## $variants
    ## [1] "data.frame"
    ## 
    ## $settings
    ## [1] "list"
    ## 
    ## $notes
    ## [1] "character"

The results have different lengths and meanings. A list is appropriate;
forced simplification would be unhelpful.

## 13.16 `lapply()` versus an explicit loop

``` r
loop_means <- vector("list", length(tissue_values))
names(loop_means) <- names(tissue_values)

for (i in seq_along(tissue_values)) {
  loop_means[[i]] <- mean(tissue_values[[i]])
}

stopifnot(identical(loop_means, tissue_means_list))
```

The two approaches express the same element-wise operation. Use
whichever makes the workflow easier to inspect and maintain.

------------------------------------------------------------------------

# Part III — `sapply()`

## 13.17 Simplification with `sapply()`

``` r
sapply(X, FUN, ...)
```

`sapply()` resembles `lapply()` but attempts to simplify the result.

``` r
tissue_means_vector <- sapply(tissue_values, mean)
tissue_means_vector
```

    ## Cortex  Blood  Liver 
    ##   5.70   4.05   7.35

``` r
class(tissue_means_vector)
```

    ## [1] "numeric"

The result is a named numeric vector rather than a list.

## 13.18 A matrix result from `sapply()`

When each call returns a vector of the same length, `sapply()` may
simplify to a matrix.

``` r
sapply(tissue_values, function(x) {
  c(mean = mean(x), median = median(x))
})
```

    ##        Cortex Blood Liver
    ## mean      5.7  4.05  7.35
    ## median    5.8  4.05  7.30

The output has statistics in rows and tissues in columns.

## 13.19 Simplification can depend on the data

Suppose some elements return one value and others return two:

``` r
irregular <- list(
  A = 1:3,
  B = 1:5
)

irregular_result <- sapply(irregular, function(x) {
  if (length(x) <= 3) {
    mean(x)
  } else {
    c(mean = mean(x), maximum = max(x))
  }
})

str(irregular_result)
```

    ## List of 2
    ##  $ A: num 2
    ##  $ B: Named num [1:2] 3 5
    ##   ..- attr(*, "names")= chr [1:2] "mean" "maximum"

Because the return lengths differ, the output remains a list.

This is why `sapply()` is convenient for interactive exploration but may
be risky in functions that require a stable output structure.

## 13.20 `simplify = FALSE`

``` r
sapply(tissue_values, mean, simplify = FALSE)
```

    ## $Cortex
    ## [1] 5.7
    ## 
    ## $Blood
    ## [1] 4.05
    ## 
    ## $Liver
    ## [1] 7.35

This preserves list-like output. When a list is explicitly desired,
`lapply()` usually communicates that intention more clearly.

------------------------------------------------------------------------

# Part IV — `vapply()`

## 13.21 Predictable output types

`vapply()` requires us to declare the expected output shape and type:

``` r
vapply(X, FUN, FUN.VALUE, ...)
```

For a single numeric mean:

``` r
tissue_means_safe <- vapply(
  tissue_values,
  mean,
  FUN.VALUE = numeric(1)
)

tissue_means_safe
```

    ## Cortex  Blood  Liver 
    ##   5.70   4.05   7.35

The output must conform to the specified prototype. This reduces
surprises when the function is used in a reusable research pipeline.

## 13.22 Other prototypes

``` r
vapply(tissue_values, length, FUN.VALUE = integer(1))
```

    ## Cortex  Blood  Liver 
    ##      3      2      4

``` r
vapply(tissue_values, function(x) all(x > 0), FUN.VALUE = logical(1))
```

    ## Cortex  Blood  Liver 
    ##   TRUE   TRUE   TRUE

``` r
vapply(tissue_values, function(x) paste(length(x), "observations"), FUN.VALUE = character(1))
```

    ##           Cortex            Blood            Liver 
    ## "3 observations" "2 observations" "4 observations"

`length()` returns an integer count, so `integer(1)` is appropriate.

## 13.23 Multiple outputs with `vapply()`

``` r
summary_matrix <- vapply(
  tissue_values,
  function(x) c(mean = mean(x), sd = sd(x)),
  FUN.VALUE = c(mean = 0, sd = 0)
)
summary_matrix
```

    ##         Cortex    Blood    Liver
    ## mean 5.7000000 4.050000 7.350000
    ## sd   0.5567764 0.212132 0.341565

The named numeric prototype declares two outputs, `mean` and `sd`.

## 13.24 Detecting unexpected results

The following intentionally incorrect code is not executed:

``` r
vapply(
  tissue_values,
  function(x) c(mean(x), sd(x)),
  FUN.VALUE = numeric(1)
)
```

Each function call returns two numbers, but `FUN.VALUE` specifies
exactly one. `vapply()` raises an error rather than silently changing
the output structure.

### Recommended practice

Use `vapply()` when a pipeline depends on a fixed scalar or fixed-length
result. Use `lapply()` for flexible, heterogeneous results. Use
`sapply()` when simplification is desirable and the output has been
checked.

------------------------------------------------------------------------

# Part V — `tapply()`

## 13.25 Summaries by groups

The syntax is:

``` r
tapply(X, INDEX, FUN, ...)
```

- `X`: the vector of measurements.
- `INDEX`: one grouping factor or a list of grouping factors.
- `FUN`: a function applied within each group.

Create synthetic participant-level data:

``` r
participants <- data.frame(
  id = paste0("P", sprintf("%03d", 1:8)),
  sex = c("Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male"),
  site = c("A", "A", "B", "B", "A", "B", "B", "A"),
  age = c(32, 55, 48, 61, 39, 50, 45, 57),
  sbp = c(118, 150, 140, 158, 125, 145, 138, 152)
)
participants
```

    ##     id    sex site age sbp
    ## 1 P001 Female    A  32 118
    ## 2 P002   Male    A  55 150
    ## 3 P003 Female    B  48 140
    ## 4 P004   Male    B  61 158
    ## 5 P005 Female    A  39 125
    ## 6 P006   Male    B  50 145
    ## 7 P007 Female    B  45 138
    ## 8 P008   Male    A  57 152

### Mean SBP by sex

``` r
tapply(participants$sbp, participants$sex, mean)
```

    ## Female   Male 
    ## 130.25 151.25

### Mean SBP by site

``` r
tapply(participants$sbp, participants$site, mean)
```

    ##      A      B 
    ## 136.25 145.25

### Count participants by group

``` r
tapply(participants$sbp, participants$sex, length)
```

    ## Female   Male 
    ##      4      4

For categorical counts alone, `table()` is simpler:

``` r
table(participants$sex)
```

    ## 
    ## Female   Male 
    ##      4      4

## 13.26 Grouping by two variables

``` r
tapply(
  participants$sbp,
  list(Sex = participants$sex, Site = participants$site),
  mean
)
```

    ##         Site
    ## Sex          A     B
    ##   Female 121.5 139.0
    ##   Male   151.0 151.5

The result is an array whose dimensions correspond to sex and site.

### Count records in each combination

``` r
table(participants$sex, participants$site)
```

    ##         
    ##          A B
    ##   Female 2 2
    ##   Male   2 2

## 13.27 Missing measurements and empty groups

``` r
participants_na <- participants
participants_na$sbp[3] <- NA_real_

tapply(participants_na$sbp, participants_na$sex, mean, na.rm = TRUE)
```

    ## Female   Male 
    ## 127.00 151.25

For a factor with a level containing no observations, a group summary
may be missing:

``` r
group <- factor(c("A", "A", "B"), levels = c("A", "B", "C"))
values <- c(10, 20, 30)
tapply(values, group, mean)
```

    ##  A  B  C 
    ## 15 30 NA

The absence of observations in group C is not evidence that its mean is
zero.

## 13.28 `tapply()` versus `aggregate()`

Base R also provides `aggregate()` for grouped summaries in a data-frame
format.

``` r
aggregate(sbp ~ sex, data = participants, FUN = mean)
```

    ##      sex    sbp
    ## 1 Female 130.25
    ## 2   Male 151.25

``` r
aggregate(sbp ~ sex + site, data = participants, FUN = mean)
```

    ##      sex site   sbp
    ## 1 Female    A 121.5
    ## 2   Male    A 151.0
    ## 3 Female    B 139.0
    ## 4   Male    B 151.5

We will study grouping and aggregation more fully in the
data-manipulation chapters.

------------------------------------------------------------------------

# Part VI — `mapply()` and `Map()`

## 13.29 Applying a function to corresponding inputs

Sometimes a function requires several arguments that change together.

Consider paired systolic and diastolic readings:

``` r
sbp <- c(120, 150, 145)
dbp <- c(78, 94, 90)
```

We could use vectorized subtraction:

``` r
sbp - dbp
```

    ## [1] 42 56 55

Or apply a function to corresponding pairs:

``` r
mapply(function(s, d) s - d, sbp, dbp)
```

    ## [1] 42 56 55

For simple subtraction, vectorization is preferable. `mapply()` becomes
useful when each corresponding pair requires a non-vectorized function
or multiple operations.

## 13.30 A named function with multiple arguments

``` r
classify_pair <- function(sbp, dbp) {
  if (is.na(sbp) || is.na(dbp)) return("Missing")
  if (sbp >= 140 || dbp >= 90) return("Review")
  "Below threshold"
}

mapply(classify_pair, sbp, dbp)
```

    ## [1] "Below threshold" "Review"          "Review"

The thresholds are illustrative programming criteria, not a clinical
diagnostic protocol.

## 13.31 `Map()` always returns a list

``` r
paired_results <- Map(function(s, d) {
  list(pulse_pressure = s - d, ratio = s / d)
}, sbp, dbp)

str(paired_results)
```

    ## List of 3
    ##  $ :List of 2
    ##   ..$ pulse_pressure: num 42
    ##   ..$ ratio         : num 1.54
    ##  $ :List of 2
    ##   ..$ pulse_pressure: num 56
    ##   ..$ ratio         : num 1.6
    ##  $ :List of 2
    ##   ..$ pulse_pressure: num 55
    ##   ..$ ratio         : num 1.61

This is useful when each iteration produces a complex object.

## 13.32 Recycling and alignment cautions

`mapply()` may recycle shorter inputs, depending on their lengths.
Recycling can produce scientifically incorrect pairings if participant
records are not aligned.

Before applying paired calculations, we should verify identifiers and
lengths:

``` r
id_sbp <- c("P001", "P002", "P003")
id_dbp <- c("P001", "P002", "P003")
stopifnot(identical(id_sbp, id_dbp))
stopifnot(length(sbp) == length(dbp))
```

Matching lengths alone does **not** prove that observations correspond
to the same participants.

------------------------------------------------------------------------

# Part VII — Biomedical and genomic applications

## 13.33 Practical 1: participant-level summaries

Create a repeated-measures matrix with some missing observations:

``` r
visits <- matrix(
  c(140, 135, 130,
    150, NA, 145,
    125, 120, 118,
    NA, NA, 155),
  nrow = 4,
  byrow = TRUE,
  dimnames = list(
    c("P001", "P002", "P003", "P004"),
    c("Baseline", "Month3", "Month6")
  )
)
visits
```

    ##      Baseline Month3 Month6
    ## P001      140    135    130
    ## P002      150     NA    145
    ## P003      125    120    118
    ## P004       NA     NA    155

### Number of observed visits

``` r
observed_visits <- apply(visits, 1, function(x) sum(!is.na(x)))
observed_visits
```

    ## P001 P002 P003 P004 
    ##    3    2    3    1

### Mean SBP per participant

``` r
mean_sbp <- apply(visits, 1, function(x) {
  if (all(is.na(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
})
mean_sbp
```

    ##  P001  P002  P003  P004 
    ## 135.0 147.5 121.0 155.0

### Baseline-to-Month6 change

``` r
change <- visits[, "Month6"] - visits[, "Baseline"]
change
```

    ## P001 P002 P003 P004 
    ##  -10   -5   -7   NA

The change is missing when either required measurement is missing. This
is preferable to inventing an outcome.

### Assemble a summary table

``` r
participant_summary <- data.frame(
  id = rownames(visits),
  n_observed = as.integer(observed_visits),
  mean_sbp = as.numeric(mean_sbp),
  change = as.numeric(change),
  row.names = NULL
)
participant_summary
```

    ##     id n_observed mean_sbp change
    ## 1 P001          3    135.0    -10
    ## 2 P002          2    147.5     -5
    ## 3 P003          3    121.0     -7
    ## 4 P004          1    155.0     NA

## 13.34 Practical 2: tissue-specific expression summaries

``` r
tissue_expression <- list(
  Cortex = c(5.1, 5.5, 6.0, NA),
  Blood = c(2.4, 2.8, 3.1),
  Liver = c(7.0, 7.2, 7.6, 7.9, 8.1)
)
```

Define a reusable function:

``` r
summarize_observed <- function(x) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) {
    return(c(n = 0, mean = NA_real_, sd = NA_real_))
  }
  c(
    n = length(observed),
    mean = mean(observed),
    sd = if (length(observed) >= 2L) sd(observed) else NA_real_
  )
}
```

Apply it with `vapply()`:

``` r
expression_summary <- vapply(
  tissue_expression,
  summarize_observed,
  FUN.VALUE = c(n = 0, mean = 0, sd = 0)
)
expression_summary
```

    ##        Cortex     Blood     Liver
    ## n    3.000000 3.0000000 5.0000000
    ## mean 5.533333 2.7666667 7.5600000
    ## sd   0.450925 0.3511885 0.4615192

The `n` row counts observed measurements. Standard deviation is missing
when fewer than two observations are available.

## 13.35 Practical 3: chromosome-specific GWAS QC

Create synthetic GWAS summary statistics:

``` r
gwas <- data.frame(
  CHROM = c(6L, 6L, 6L, 1L, 2L, 1L, 6L),
  POS = c(26295926L, 31298240L, 32626565L,
          1500000L, 2200000L, 1700000L, 33794605L),
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE", "rsF", "rsG"),
  BETA = c(0.05, -0.08, NA, 0.02, 0.03, -0.01, 0.10),
  SE = c(0.01, 0.02, 0.02, 0.01, 0, 0.02, 0.02),
  PVAL = c(2e-8, 3e-9, NA, 0.3, 0.04, 0.6, 1e-10)
)
```

These values are illustrative and are not real association results.

### Split by chromosome

``` r
gwas_by_chr <- split(gwas, gwas$CHROM)
names(gwas_by_chr)
```

    ## [1] "1" "2" "6"

### Define a basic QC function

``` r
qc_chromosome <- function(dat) {
  valid <- !is.na(dat$BETA) & is.finite(dat$BETA) &
    !is.na(dat$SE) & is.finite(dat$SE) & dat$SE > 0 &
    !is.na(dat$PVAL) & is.finite(dat$PVAL) &
    dat$PVAL >= 0 & dat$PVAL <= 1

  dat$qc_pass <- valid
  dat$Z <- rep(NA_real_, nrow(dat))
  dat$Z[valid] <- dat$BETA[valid] / dat$SE[valid]
  dat
}
```

### Apply QC to every chromosome

``` r
qc_by_chr <- lapply(gwas_by_chr, qc_chromosome)
```

### Summarize passing variants

``` r
qc_summary <- data.frame(
  chromosome = names(qc_by_chr),
  n_variants = vapply(qc_by_chr, nrow, integer(1)),
  n_pass = vapply(qc_by_chr, function(x) sum(x$qc_pass), integer(1)),
  row.names = NULL
)
qc_summary
```

    ##   chromosome n_variants n_pass
    ## 1          1          2      2
    ## 2          2          1      0
    ## 3          6          4      3

### Validate that records were not lost

``` r
stopifnot(sum(qc_summary$n_variants) == nrow(gwas))
stopifnot(sum(qc_summary$n_pass) <= nrow(gwas))
```

This demonstrates list processing and quality-control bookkeeping. Real
GWAS QC requires additional checks, including genome build,
effect-allele definitions, allele harmonization, imputation quality, and
study-specific sample-size criteria.

## 13.36 Practical 4: gene-by-tissue array analysis

``` r
expr3d <- array(
  seq(2, 25),
  dim = c(3, 2, 4),
  dimnames = list(
    Gene = c("G1", "G2", "G3"),
    Sample = c("S1", "S2"),
    Tissue = c("Cortex", "Blood", "Liver", "Muscle")
  )
)
```

Compute mean expression for each gene–tissue pair:

``` r
mean_by_gene_tissue <- apply(expr3d, c(1, 3), mean)
mean_by_gene_tissue
```

    ##     Tissue
    ## Gene Cortex Blood Liver Muscle
    ##   G1    3.5   9.5  15.5   21.5
    ##   G2    4.5  10.5  16.5   22.5
    ##   G3    5.5  11.5  17.5   23.5

Compute tissue-level medians across all genes and samples:

``` r
tissue_medians <- apply(expr3d, 3, median)
tissue_medians
```

    ## Cortex  Blood  Liver Muscle 
    ##    4.5   10.5   16.5   22.5

These are synthetic values. Real expression comparisons require
appropriate normalization, quality control, and attention to sample
composition.

------------------------------------------------------------------------

# Part VIII — Robustness and common mistakes

## 13.37 Empty vectors and lists

``` r
empty_list <- list()
lapply(empty_list, mean)
```

    ## list()

``` r
vapply(empty_list, mean, numeric(1))
```

    ## numeric(0)

Both return empty outputs of their respective types. Downstream code
should verify that the expected number of groups was present.

## 13.38 All-missing groups

``` r
all_missing <- list(A = c(NA_real_, NA_real_), B = c(2, 4))
```

A naive mean with `na.rm = TRUE` returns `NaN` for an all-missing group:

``` r
lapply(all_missing, mean, na.rm = TRUE)
```

    ## $A
    ## [1] NaN
    ## 
    ## $B
    ## [1] 3

A deliberate policy can return `NA_real_`:

``` r
safe_mean <- function(x) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) return(NA_real_)
  mean(observed)
}

vapply(all_missing, safe_mean, numeric(1))
```

    ##  A  B 
    ## NA  3

## 13.39 Mixed return types

``` r
heterogeneous <- list(A = c(1, 2), B = character(0))
```

For a mixed-type result, use `lapply()` rather than assuming
simplification:

``` r
lapply(heterogeneous, function(x) {
  list(n = length(x), type = typeof(x))
})
```

    ## $A
    ## $A$n
    ## [1] 2
    ## 
    ## $A$type
    ## [1] "double"
    ## 
    ## 
    ## $B
    ## $B$n
    ## [1] 0
    ## 
    ## $B$type
    ## [1] "character"

## 13.40 Named output and ordering

Apply functions generally preserve the traversal order of input
elements. However, group ordering from factors or `split()` may follow
factor levels rather than original appearance order.

``` r
group_factor <- factor(c("B", "A", "B"), levels = c("A", "B"))
split(c(10, 20, 30), group_factor)
```

    ## $A
    ## [1] 20
    ## 
    ## $B
    ## [1] 10 30

When order matters scientifically, verify names and align results
explicitly.

## 13.41 Frequent mistakes

1.  **Confusing `MARGIN = 1` and `MARGIN = 2`.** Rows correspond to
    margin 1; columns to margin 2.
2.  **Using `apply()` on mixed-type data frames.** Coercion may turn
    numeric data into character strings.
3.  **Assuming `sapply()` always returns a vector.** Its result can be a
    matrix or list.
4.  **Using `vapply()` with the wrong prototype.** Match expected output
    length and type.
5.  **Ignoring all-missing groups.** `mean(numeric(0))` and all-missing
    means require a policy.
6.  **Treating missing group summaries as zeros.** No observations do
    not imply a zero mean.
7.  **Applying statistics across incompatible units.** Numerical
    operations must be scientifically meaningful.
8.  **Failing to check grouping levels.** Unused factor levels can
    create empty groups.
9.  **Assuming paired vectors are aligned.** Match by participant or
    variant identifiers.
10. **Using an apply function where vectorization is simpler.** For
    `sbp - dbp`, direct subtraction is preferable.
11. **Dropping identifiers during simplification.** Preserve names or
    return a keyed data frame.
12. **Assuming the apply family automatically parallelizes.** Base
    `apply()` functions do not imply parallel execution.
13. **Assuming apply functions always outperform loops.** Benchmark only
    when performance matters.
14. **Ignoring output shape when a single group remains.** Test edge
    cases in reusable functions.
15. **Using a function with side effects without considering execution
    order.** Prefer explicit returned values for reproducibility.

------------------------------------------------------------------------

# Part IX — Guided exercises

## 13.42 Exercise dataset A: repeated blood-pressure readings

``` r
exercise_bp <- matrix(
  c(120, 125, 130,
    145, NA, 150,
    138, 140, 142,
    155, 148, 146,
    118, 120, 119),
  nrow = 5,
  byrow = TRUE,
  dimnames = list(
    paste0("P", 1:5),
    c("V1", "V2", "V3")
  )
)
```

Tasks:

1.  Calculate mean SBP for each participant using `apply()`.
2.  Calculate mean SBP at each visit using `apply()`.
3.  Repeat both using `rowMeans()` and `colMeans()`.
4.  Calculate each participant’s maximum observed SBP.
5.  Calculate each participant’s range.
6.  Count observed measurements in each row.
7.  Count missing measurements in each column.
8.  Explain why `na.rm = TRUE` changes the number of measurements used.
9.  Calculate each participant’s first-to-last change, preserving
    missingness.
10. Validate at least two results against manual calculations.

## 13.43 Exercise dataset B: tissue-specific values

``` r
exercise_tissues <- list(
  Cortex = c(4.2, 4.8, 5.1),
  Blood = c(2.1, NA, 2.7, 2.5),
  Liver = c(6.3, 6.7),
  Kidney = numeric(0)
)
```

Tasks:

1.  Use `lapply()` to find the length of every element.
2.  Use `sapply()` to find the number of observed values.
3.  Use `vapply()` to calculate means, with an explicit empty-group
    policy.
4.  Use `lapply()` to return a list of mean, median, and SD.
5.  Explain why the empty Kidney group needs special handling.
6.  Create a data frame containing tissue, observed sample count, and
    mean.
7.  Compare `lapply()` and `sapply()` output types.
8.  Construct a `vapply()` prototype for two numeric statistics.
9.  Verify that every tissue name is preserved.
10. Explain which function is best for returning a complex result per
    tissue.

## 13.44 Exercise dataset C: epidemiology

``` r
exercise_epi <- data.frame(
  id = paste0("E", 1:8),
  sex = c("Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male"),
  site = c("A", "A", "A", "B", "B", "B", "A", "B"),
  age = c(35, 52, 47, 60, 42, 55, 39, 49),
  sbp = c(120, 145, 138, 152, 130, NA, 125, 149)
)
```

Tasks:

1.  Calculate mean SBP by sex using `tapply()`.
2.  Calculate mean SBP by site.
3.  Calculate mean SBP by sex and site.
4.  Count records in each sex–site combination.
5.  Use `aggregate()` to produce a data-frame summary.
6.  Explain how missing SBP values affect means.
7.  Count missing SBP values within each site.
8.  Explain why the result does not establish sex-specific or
    site-specific causal effects.
9.  Compare `tapply()` and `aggregate()` output structures.
10. Validate the group counts against `table()`.

## 13.45 Exercise dataset D: genomic summary statistics

``` r
exercise_gwas <- data.frame(
  CHROM = c(6L, 6L, 1L, 2L, 6L, 1L),
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5", "rs6"),
  BETA = c(0.04, NA, 0.02, -0.03, 0.10, 0.01),
  SE = c(0.01, 0.02, 0.01, 0, 0.02, 0.02),
  PVAL = c(1e-8, NA, 0.2, 0.04, 1e-10, 0.6)
)
```

Tasks:

1.  Split the table by chromosome.
2.  Use `lapply()` to report row counts.
3.  Use `vapply()` to count missing p-values.
4.  Write a QC function requiring observed finite `BETA`, positive
    finite `SE`, and a valid finite p-value.
5.  Apply QC to each chromosome.
6.  Calculate Z scores only for passing variants.
7.  Combine chromosome summaries into one table.
8.  Verify that the sum of group row counts equals the original row
    count.
9.  Explain why a complete GWAS harmonization workflow needs allele
    information.
10. Explain why chromosome-specific QC results must preserve variant
    identifiers.

## 13.46 Challenge: build a reusable summary engine

Develop a function `summarize_groups(data, value_col, group_col)` using
base R that:

1.  Checks that `data` is a data frame.
2.  Verifies that both named columns exist.
3.  Verifies that the measurement column is numeric.
4.  Splits the values by group.
5.  Counts observed measurements per group.
6.  Computes the mean and SD, handling zero or one observed value.
7.  Returns a data frame with one row per group.
8.  Preserves group names.
9.  Works with one group, multiple groups, and missing measurements.
10. Compares its output against a known manual example.

**Extension:** Investigate how missing group labels should be handled.
This is a data-management decision, not merely a programming choice.

------------------------------------------------------------------------

# Part X — Consolidated practice script

## 13.47 Complete standalone script

The following script can be copied into a separate `.R` file. It is not
executed during knitting because the examples have already been
demonstrated.

``` r
# Chapter 13 — The Apply Family (base R)

# 1. Matrix operations
x <- matrix(c(120, 130, 140, 150, 160, 170), nrow = 2, byrow = TRUE)
apply(x, 1, mean)
apply(x, 2, mean)
rowMeans(x)
colMeans(x)

# 2. List operations
values <- list(Cortex = c(4, 5, 6), Blood = c(2, NA, 3))
lapply(values, function(v) mean(v, na.rm = TRUE))
sapply(values, function(v) mean(v, na.rm = TRUE))
vapply(values, function(v) mean(v, na.rm = TRUE), numeric(1))

# 3. Group summaries
study <- data.frame(
  group = c("A", "A", "B", "B"),
  sbp = c(120, 130, 145, 155)
)
tapply(study$sbp, study$group, mean)
aggregate(sbp ~ group, data = study, FUN = mean)

# 4. Paired arguments
sbp <- c(120, 150, 145)
dbp <- c(78, 94, 90)
mapply(function(s, d) s - d, sbp, dbp)

# 5. Chromosome-specific QC
stats <- data.frame(
  CHROM = c(1L, 6L, 6L),
  ID = c("rsA", "rsB", "rsC"),
  BETA = c(0.02, 0.05, NA),
  SE = c(0.01, 0.01, 0.02),
  PVAL = c(0.2, 1e-8, NA)
)

qc <- function(d) {
  pass <- !is.na(d$BETA) & is.finite(d$BETA) &
    !is.na(d$SE) & is.finite(d$SE) & d$SE > 0 &
    !is.na(d$PVAL) & is.finite(d$PVAL) &
    d$PVAL >= 0 & d$PVAL <= 1
  d$pass <- pass
  d$Z <- rep(NA_real_, nrow(d))
  d$Z[pass] <- d$BETA[pass] / d$SE[pass]
  d
}

by_chr <- lapply(split(stats, stats$CHROM), qc)
counts <- vapply(by_chr, nrow, integer(1))
stopifnot(sum(counts) == nrow(stats))
print(by_chr)
```

------------------------------------------------------------------------

## 13.48 Function reference

| Function | Primary role | Output caution |
|----|----|----|
| `apply()` | Rows, columns, array margins | May simplify or coerce data |
| `lapply()` | Elements of list/vector | Always list |
| `sapply()` | Elements of list/vector | Simplification varies |
| `vapply()` | Type-safe element-wise application | Requires correct prototype |
| `tapply()` | Grouped summaries | May include empty groups |
| `mapply()` | Corresponding multiple inputs | May recycle inputs |
| `Map()` | Corresponding multiple inputs | Always list |
| `split()` | Partition data by groups | Factor-level order matters |
| `aggregate()` | Grouped data-frame summaries | Check missingness and grouping |
| `rowMeans()` | Fast row means | Numeric matrix/data frame expected |
| `colMeans()` | Fast column means | Numeric matrix/data frame expected |
| `rowSums()` | Fast row sums | Numeric input expected |
| `colSums()` | Fast column sums | Numeric input expected |
| `do.call()` | Call function with list of arguments | Argument structures must agree |

## 13.49 Chapter review questions

1.  Why is the apply family related to loops?
2.  What does `MARGIN = 1` mean for a matrix?
3.  What does `MARGIN = c(1, 3)` mean for a three-dimensional array?
4.  Why might `apply()` coerce a mixed-type data frame?
5.  When are `rowMeans()` and `colMeans()` preferable to `apply()`?
6.  What does `lapply()` always return?
7.  When can `sapply()` return a matrix?
8.  Why can `sapply()` be fragile in reusable code?
9.  What is the purpose of `FUN.VALUE` in `vapply()`?
10. How does `vapply()` help enforce output contracts?
11. What does `tapply()` do with a grouping factor?
12. How can two grouping factors be supplied to `tapply()`?
13. What is the difference between `tapply()` and `aggregate()`?
14. Why can an all-missing group require special handling?
15. What is the difference between `mapply()` and `Map()`?
16. Why is paired-data alignment essential before using `mapply()`?
17. How can `split()` and `lapply()` support chromosome-wise GWAS QC?
18. Why should a QC function preserve variant identifiers?
19. When should we prefer direct vectorization over an apply function?
20. How can we verify that an apply-family workflow did not lose
    observations?

## 13.50 Key takeaways

- `apply()` operates across margins of matrices and arrays.
- `lapply()` returns a list and supports heterogeneous results.
- `sapply()` simplifies when possible, so its output structure can vary.
- `vapply()` enforces an expected output type and shape.
- `tapply()` calculates statistics within groups.
- `mapply()` and `Map()` combine corresponding elements from multiple
  inputs.
- `split()` plus `lapply()` is useful for grouped research workflows.
- Missing values, empty groups, factor levels, and type coercion require
  explicit handling.
- The most concise code is not necessarily the most reliable code;
  correctness, interpretability, and validation come first.

> **Choose the apply function by the structure of the data and the
> required output—not by the desire to avoid writing a loop.**

## 13.51 Looking ahead: Chapter 14 — Working with Files and Directories in R

In the next chapter, we will move beyond objects created inside scripts
and begin working with research files and folders. We will examine
working directories, file paths, file existence checks, and reproducible
project organization before progressing to data import and export.
