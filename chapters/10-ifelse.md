Conditional Programming: `if`, `else`, and \`ifelse()
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 9, we learned to build and manipulate data frames. We used
expressions such as `sbp >= 140` to identify observations meeting a
criterion. In this chapter, we move from **asking whether a condition is
true** to **telling R what to do when it is true or false**.

This is the foundation of conditional programming. We will use examples
from biomedical research, epidemiology, and genomics. All code uses
**base R**, without external packages.

Consider a quality-control rule: a GWAS variant with a missing p-value
should be flagged for review; otherwise, it may proceed to a p-value
threshold check. Or imagine a research participant whose blood-pressure
reading must be verified before assigning a study-defined screening
category. Conditional statements allow us to express these decisions
transparently.

**Scope:** This chapter teaches programming decisions. It does not
establish clinical diagnoses, treatment recommendations, or biological
causality. Clinical and genomic thresholds in the examples are
illustrative or explicitly described.

## 10.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Explain what a logical condition is and why conditional execution is
    useful.
2.  Use `if` and `else` to control program flow.
3.  Construct multiple branches with `else if`.
4.  Combine conditions using `&`, `|`, `!`, `&&`, and `||`.
5.  Distinguish single-value decisions from vectorized classification.
6.  Use `ifelse()` and understand its missing-value behavior.
7.  Recognize when `ifelse()` can silently change data types or
    attributes.
8.  Handle `NA`, `NaN`, and invalid inputs safely.
9.  Use `%in%`, `is.na()`, `isTRUE()`, `any()`, and `all()`
    appropriately.
10. Apply decision logic to data frames and genomic variant QC.
11. Build a small, validated biomedical screening function.
12. Diagnose common conditional-programming errors.

------------------------------------------------------------------------

## 10.2 A condition produces a logical result

We begin with an expression that R can evaluate as `TRUE` or `FALSE`.

``` r
age <- 52
age >= 40
```

    ## [1] TRUE

Here, `age >= 40` is a logical condition.

Other comparisons include:

``` r
sbp <- 146

sbp > 140
```

    ## [1] TRUE

``` r
sbp >= 140
```

    ## [1] TRUE

``` r
sbp == 140
```

    ## [1] FALSE

``` r
sbp != 140
```

    ## [1] TRUE

``` r
sbp < 160
```

    ## [1] TRUE

Recall:

| Operator | Meaning                  |
|----------|--------------------------|
| `>`      | Greater than             |
| `>=`     | Greater than or equal to |
| `<`      | Less than                |
| `<=`     | Less than or equal to    |
| `==`     | Equal to                 |
| `!=`     | Not equal to             |

**Important:** `=` and `<-` are used in assignment contexts, while `==`
tests equality.

``` r
x <- 10
x == 10
```

    ## [1] TRUE

The condition is not itself a command to take an action. To act on the
result, we use a conditional statement.

## 10.3 Our first `if` statement

The basic syntax is:

``` r
if (condition) {
  statements_to_execute
}
```

Example:

``` r
sbp <- 146

if (sbp >= 140) {
  print("SBP meets the study screening threshold.")
}
```

    ## [1] "SBP meets the study screening threshold."

The condition is `TRUE`, so R executes the code inside the braces.

Now try a value below the threshold:

``` r
sbp <- 125

if (sbp >= 140) {
  print("SBP meets the study screening threshold.")
}
```

Nothing is printed because the condition is `FALSE`.

### How R interprets the statement

1.  Evaluate the expression inside parentheses.
2.  If the result is `TRUE`, execute the enclosed statements.
3.  If the result is `FALSE`, skip them.
4.  Continue executing subsequent code.

### Why braces matter

A simple `if` can contain one expression without braces, but braces make
the intended block clearer and are strongly recommended for teaching and
research scripts.

``` r
age <- 55

if (age >= 50) {
  print("Age criterion satisfied.")
  print("Continue to the next screening check.")
}
```

    ## [1] "Age criterion satisfied."
    ## [1] "Continue to the next screening check."

Both messages belong to the same branch.

------------------------------------------------------------------------

## 10.4 `if` and `else`: two possible actions

An `if` statement can specify an alternative action when its condition
is false.

``` r
if (condition) {
  action_when_true
} else {
  action_when_false
}
```

Example:

``` r
sbp <- 132

if (sbp >= 140) {
  print("Meets the SBP screening threshold.")
} else {
  print("Does not meet the SBP screening threshold.")
}
```

    ## [1] "Does not meet the SBP screening threshold."

Exactly one branch is executed when the condition is a valid single
`TRUE` or `FALSE`.

### Change the input

``` r
sbp <- 150

if (sbp >= 140) {
  print("Meets the SBP screening threshold.")
} else {
  print("Does not meet the SBP screening threshold.")
}
```

    ## [1] "Meets the SBP screening threshold."

The first branch now executes.

### Assigning a result

We often want to store the outcome rather than print it:

``` r
sbp <- 150

if (sbp >= 140) {
  screening_flag <- "Review"
} else {
  screening_flag <- "Below threshold"
}

screening_flag
```

    ## [1] "Review"

This is a study-screening label, not a hypertension diagnosis.

------------------------------------------------------------------------

## 10.5 The value returned by an `if` expression

In R, `if` is an expression. It can return a value:

``` r
age <- 42

age_group <- if (age >= 50) {
  "50 or older"
} else {
  "Under 50"
}

age_group
```

    ## [1] "Under 50"

For a short, scalar decision, this is concise and readable.

We will later compare this with `ifelse()`, which is designed to operate
across vectors.

------------------------------------------------------------------------

## 10.6 Multiple branches using `else if`

Some decisions have more than two outcomes.

``` r
if (condition_1) {
  action_1
} else if (condition_2) {
  action_2
} else {
  default_action
}
```

Consider a simple age-group classification:

``` r
age <- 46

if (age < 18) {
  group <- "Under 18"
} else if (age < 40) {
  group <- "18–39"
} else if (age < 65) {
  group <- "40–64"
} else {
  group <- "65 or older"
}

group
```

    ## [1] "40–64"

R evaluates the branches **from top to bottom** and executes the first
one whose condition is `TRUE`.

### Why branch order matters

Suppose we write:

``` r
age <- 70

if (age >= 40) {
  group <- "40 or older"
} else if (age >= 65) {
  group <- "65 or older"
} else {
  group <- "Under 40"
}

group
```

    ## [1] "40 or older"

The result is `"40 or older"` because the first condition is already
true. The `age >= 65` branch is never reached.

For mutually exclusive age groups, we should order thresholds carefully
or use non-overlapping intervals.

------------------------------------------------------------------------

## 10.7 Logical AND, OR, and NOT

In epidemiological screening, eligibility usually depends on several
criteria.

``` r
age <- 55
sbp <- 152
consent <- TRUE
```

### AND: all criteria must hold

``` r
age >= 40 & sbp >= 140 & consent
```

    ## [1] TRUE

### OR: at least one criterion must hold

``` r
sbp >= 140 | age >= 65
```

    ## [1] TRUE

### NOT: reverse a logical condition

``` r
diabetes <- FALSE
!diabetes
```

    ## [1] TRUE

We can use the combined condition in `if`:

``` r
if (age >= 40 & sbp >= 140 & consent & !diabetes) {
  print("Participant satisfies these illustrative criteria.")
} else {
  print("At least one criterion is not satisfied.")
}
```

    ## [1] "Participant satisfies these illustrative criteria."

### Parentheses improve clarity

``` r
(age >= 40 & age <= 65) & (sbp >= 140) & consent
```

    ## [1] TRUE

Parentheses help readers understand which rules belong together.

------------------------------------------------------------------------

## 10.8 `&` versus `&&`, and `|` versus `||`

This distinction is fundamental.

- `&` and `|` operate **element by element** and are commonly used with
  vectors.
- `&&` and `||` are **short-circuit** operators for a single decision.
  They evaluate only the first element of their operands and may skip
  the right-hand expression when the result is already determined.

### Element-wise comparison

``` r
ages <- c(28, 45, 62)
sbps <- c(120, 148, 155)

ages >= 40 & sbps >= 140
```

    ## [1] FALSE  TRUE  TRUE

The result has three logical values, one for each participant.

### A single decision

``` r
age <- 45
sbp <- 148

if (age >= 40 && sbp >= 140) {
  print("Both conditions satisfied.")
}
```

    ## [1] "Both conditions satisfied."

### Short-circuiting in practice

``` r
value <- NA_real_

if (!is.na(value) && value > 0) {
  print("Observed positive value.")
} else {
  print("Missing or nonpositive value.")
}
```

    ## [1] "Missing or nonpositive value."

Because `!is.na(value)` is false, R does not need to evaluate
`value > 0`.

### Common error: using a vector directly with `&&`

Do not use `&&` to filter multiple participants. It examines only the
first element of a logical vector.

``` r
ages >= 40 && sbps >= 140
```

This is **not** the correct way to classify all participants. In an `if`
statement, we also must not pass an entire logical vector as the
condition.

For vectorized comparisons, use:

``` r
ages >= 40 & sbps >= 140
```

    ## [1] FALSE  TRUE  TRUE

**Practical rule:** Use `&&` and `||` for scalar control-flow
conditions; use `&` and `|` for element-wise vector logic.

------------------------------------------------------------------------

## 10.9 A crucial restriction: `if` needs one logical value

Consider five participants:

``` r
sbp_values <- c(120, 150, 145, 115, 142)
sbp_values >= 140
```

    ## [1] FALSE  TRUE  TRUE FALSE  TRUE

This comparison returns five logical values.

The following code is deliberately **not executed**:

``` r
if (sbp_values >= 140) {
  print("Threshold reached.")
}
```

In modern R, `if` rejects a condition of length greater than one. It
cannot decide which participant’s result should control the branch.

### Correct option 1: ask a group-level question

``` r
if (any(sbp_values >= 140)) {
  print("At least one participant meets the threshold.")
}
```

    ## [1] "At least one participant meets the threshold."

### Correct option 2: require every participant to satisfy the criterion

``` r
if (all(sbp_values >= 140)) {
  print("Every participant meets the threshold.")
} else {
  print("Not every participant meets the threshold.")
}
```

    ## [1] "Not every participant meets the threshold."

### Correct option 3: classify each participant

Use a vectorized function such as `ifelse()`, introduced next.

------------------------------------------------------------------------

## 10.10 Introducing `ifelse()`

The syntax is:

``` r
ifelse(test, yes, no)
```

For each element:

- if `test` is `TRUE`, select the corresponding `yes` value;
- if `test` is `FALSE`, select the corresponding `no` value;
- if `test` is `NA`, the output at that position is ordinarily `NA`.

Example:

``` r
sbp_values <- c(120, 150, 145, 115, 142)

screening <- ifelse(
  sbp_values >= 140,
  "Review",
  "Below threshold"
)

screening
```

    ## [1] "Below threshold" "Review"          "Review"          "Below threshold"
    ## [5] "Review"

This returns five classifications, one per participant.

### Compare `if` and `ifelse()`

| Feature | `if` | `ifelse()` |
|----|----|----|
| Main purpose | Choose which code branch to execute | Select values across a vector |
| Condition length | Exactly one | One or more |
| Multiple statements | Yes | Not a replacement for a statement block |
| Common use | Validation, workflow decisions | Derived classification columns |
| Missing test | Must be handled explicitly | Typically yields missing output at that position |

**Important:** `ifelse()` is a value-selection function. It is not
simply a vectorized way to execute arbitrary blocks of commands.

------------------------------------------------------------------------

## 10.11 Understanding `ifelse()` element by element

Let:

``` r
ages <- c(25, 42, 68, 55, 17)
```

We want to label participants as `"Adult"` when age is at least 18 and
`"Minor"` otherwise.

``` r
age_label <- ifelse(ages >= 18, "Adult", "Minor")
age_label
```

    ## [1] "Adult" "Adult" "Adult" "Adult" "Minor"

The comparisons are:

| Age | Condition `age >= 18` | Result |
|----:|:---------------------:|:-------|
|  25 |         TRUE          | Adult  |
|  42 |         TRUE          | Adult  |
|  68 |         TRUE          | Adult  |
|  55 |         TRUE          | Adult  |
|  17 |         FALSE         | Minor  |

The output is a character vector because the selected values are
character strings.

### Numeric output

``` r
flag <- ifelse(ages >= 18, 1, 0)
flag
```

    ## [1] 1 1 1 1 0

``` r
typeof(flag)
```

    ## [1] "double"

### Logical output

If we need only a logical flag, `ifelse()` is unnecessary:

``` r
adult <- ages >= 18
adult
```

    ## [1]  TRUE  TRUE  TRUE  TRUE FALSE

The direct comparison is simpler and avoids unnecessary conversion.

------------------------------------------------------------------------

## 10.12 Nested `ifelse()` for multiple categories

We can classify a vector into several age groups:

``` r
ages <- c(12, 25, 43, 67)

age_group <- ifelse(
  ages < 18,
  "Under 18",
  ifelse(
    ages < 40,
    "18–39",
    ifelse(ages < 65, "40–64", "65 or older")
  )
)

age_group
```

    ## [1] "Under 18"    "18–39"       "40–64"       "65 or older"

This works, but nested `ifelse()` statements become difficult to read
when there are many branches.

For numeric intervals, `cut()` can be clearer:

``` r
age_group_cut <- cut(
  ages,
  breaks = c(-Inf, 18, 40, 65, Inf),
  right = FALSE,
  labels = c("Under 18", "18–39", "40–64", "65 or older")
)

age_group_cut
```

    ## [1] Under 18    18–39       40–64       65 or older
    ## Levels: Under 18 18–39 40–64 65 or older

Notice that `cut()` returns a **factor**. We studied factors in Chapter
5.

For a small number of explicit rules, nested `ifelse()` is acceptable.
For more complex classification, we should consider clearer alternatives
and validate boundary cases.

------------------------------------------------------------------------

## 10.13 Missing values inside conditions

Missing data are common in research.

``` r
sbp_values <- c(120, 150, NA, 135, 145)
sbp_values >= 140
```

    ## [1] FALSE  TRUE    NA FALSE  TRUE

The comparison produces `NA` for the missing measurement.

### What happens with `ifelse()`?

``` r
ifelse(sbp_values >= 140, "Review", "Below threshold")
```

    ## [1] "Below threshold" "Review"          NA                "Below threshold"
    ## [5] "Review"

The missing SBP remains unclassified.

This is often appropriate because we do not know whether the participant
meets the threshold.

### Explicitly label missing values

``` r
screening <- ifelse(
  is.na(sbp_values),
  "Missing measurement",
  ifelse(
    sbp_values >= 140,
    "Review",
    "Below threshold"
  )
)

screening
```

    ## [1] "Below threshold"     "Review"              "Missing measurement"
    ## [4] "Below threshold"     "Review"

The order of the checks is important. We handle missingness before
evaluating the threshold.

------------------------------------------------------------------------

## 10.14 Why `if (NA)` fails

The following code is deliberately not executed:

``` r
sbp <- NA

if (sbp >= 140) {
  print("Review")
} else {
  print("Below threshold")
}
```

The condition `sbp >= 140` is `NA`, not `TRUE` or `FALSE`. R cannot
choose a branch and raises an error.

### Safe scalar handling

``` r
sbp <- NA_real_

if (is.na(sbp)) {
  result <- "Missing measurement"
} else if (sbp >= 140) {
  result <- "Review"
} else {
  result <- "Below threshold"
}

result
```

    ## [1] "Missing measurement"

### Why missing does not mean false

A missing SBP does not imply that the participant has low SBP. It means
we do not have the necessary measurement.

This distinction matters in eligibility screening, clinical registries,
and GWAS quality control.

------------------------------------------------------------------------

## 10.15 `isTRUE()` for scalar decisions

`isTRUE()` returns `TRUE` only when its argument is exactly a single
non-missing logical `TRUE`.

``` r
isTRUE(TRUE)
```

    ## [1] TRUE

``` r
isTRUE(FALSE)
```

    ## [1] FALSE

``` r
isTRUE(NA)
```

    ## [1] FALSE

``` r
isTRUE(NULL)
```

    ## [1] FALSE

Consider:

``` r
sbp <- NA_real_

if (isTRUE(sbp >= 140)) {
  print("Observed SBP meets threshold.")
} else {
  print("Threshold not confirmed.")
}
```

    ## [1] "Threshold not confirmed."

This code is safe from a missing-condition error. However, the `else`
branch means **not confirmed**, not necessarily **below threshold**.

For research data, an explicit missing-data branch is often more
informative.

------------------------------------------------------------------------

## 10.16 `any()` and `all()` with missing values

Suppose we have:

``` r
qc_flags <- c(TRUE, NA, FALSE)
```

Compare:

``` r
any(qc_flags)
```

    ## [1] TRUE

``` r
all(qc_flags)
```

    ## [1] FALSE

Now:

``` r
qc_flags2 <- c(FALSE, NA)
any(qc_flags2)
```

    ## [1] NA

``` r
all(qc_flags2)
```

    ## [1] FALSE

The result can be `NA` when missingness prevents a definitive
conclusion.

We can use `na.rm = TRUE`:

``` r
any(qc_flags2, na.rm = TRUE)
```

    ## [1] FALSE

``` r
all(qc_flags2, na.rm = TRUE)
```

    ## [1] FALSE

But this changes the question: we are now evaluating only observed
flags.

### An empty-vector caution

``` r
all(logical(0))
```

    ## [1] TRUE

``` r
any(logical(0))
```

    ## [1] FALSE

`all(logical(0))` is `TRUE`, while `any(logical(0))` is `FALSE`. This
follows R’s logical identities but may surprise us in QC pipelines.

For example, if an analysis unexpectedly selects zero variants,
`all(selected_variants_pass)` may return `TRUE` simply because there are
no elements.

We should separately verify that the expected number of records exists.

------------------------------------------------------------------------

## 10.17 `NA`, `NaN`, and `NULL` in decisions

Recall these distinctions:

- `NA`: a missing value;
- `NaN`: a numerical result that is not a valid number, such as `0/0`;
- `NULL`: absence of an object or element, often of length zero.

``` r
x <- NA_real_
y <- NaN
z <- NULL

is.na(x)
```

    ## [1] TRUE

``` r
is.nan(y)
```

    ## [1] TRUE

``` r
is.null(z)
```

    ## [1] TRUE

Both `NA` and `NaN` are detected by `is.na()`:

``` r
is.na(NaN)
```

    ## [1] TRUE

`is.nan()` is more specific.

### Safe numeric input validation

``` r
measurement <- NaN

if (length(measurement) != 1L) {
  status <- "Invalid length"
} else if (is.na(measurement)) {
  status <- "Missing or undefined"
} else if (!is.finite(measurement)) {
  status <- "Non-finite value"
} else {
  status <- "Finite observed value"
}

status
```

    ## [1] "Missing or undefined"

`is.finite()` distinguishes ordinary finite numbers from infinite or
undefined values.

------------------------------------------------------------------------

## 10.18 Validating inputs before using `if`

A robust scalar decision should confirm the expected input shape and
type.

``` r
age <- 48

if (!is.numeric(age) || length(age) != 1L) {
  stop("Age must be a single numeric value.")
} else if (is.na(age) || !is.finite(age)) {
  stop("Age must be observed and finite.")
} else if (age < 0) {
  stop("Age cannot be negative.")
} else {
  print("Age passed basic validation.")
}
```

    ## [1] "Age passed basic validation."

The checks are ordered to prevent later expressions from operating on
unsuitable values.

**Note:** A number can pass these checks yet still be biologically
implausible or invalid for a particular study. Input validation should
reflect the protocol and data dictionary.

### `stop()` and `warning()`

``` r
x <- 10

if (x > 100) {
  warning("Value is unusually high.")
}

if (x < 0) {
  stop("Value cannot be negative.")
}
```

Here, neither condition is met, so knitting continues normally.

- `warning()` reports a potential issue and usually allows execution to
  continue.
- `stop()` raises an error and interrupts execution.

We should reserve errors for conditions under which continuing would be
unsafe or meaningless.

------------------------------------------------------------------------

## 10.19 Building a small scalar screening function

In Chapter 12, we will study functions in detail. Here, we use one
simple function to combine conditional rules.

``` r
classify_sbp <- function(sbp) {
  if (!is.numeric(sbp) || length(sbp) != 1L) {
    stop("sbp must be one numeric value.")
  }

  if (is.na(sbp) || !is.finite(sbp)) {
    return("Missing or invalid")
  }

  if (sbp >= 140) {
    return("Review")
  } else {
    return("Below threshold")
  }
}
```

Try several inputs:

``` r
classify_sbp(152)
```

    ## [1] "Review"

``` r
classify_sbp(128)
```

    ## [1] "Below threshold"

``` r
classify_sbp(NA_real_)
```

    ## [1] "Missing or invalid"

The `return()` statement ends the function and supplies its result.

This example deliberately avoids making a diagnosis. It implements a
transparent threshold-based programming rule.

------------------------------------------------------------------------

## 10.20 Using `ifelse()` with data frames

Create a small synthetic dataset:

``` r
patients <- data.frame(
  id = c("P001", "P002", "P003", "P004", "P005"),
  age = c(35, 58, 49, 62, 41),
  sbp = c(118, 152, NA, 145, 125),
  consent = c(TRUE, TRUE, TRUE, FALSE, TRUE),
  diabetes = c(FALSE, TRUE, FALSE, FALSE, FALSE)
)

patients
```

    ##     id age sbp consent diabetes
    ## 1 P001  35 118    TRUE    FALSE
    ## 2 P002  58 152    TRUE     TRUE
    ## 3 P003  49  NA    TRUE    FALSE
    ## 4 P004  62 145   FALSE    FALSE
    ## 5 P005  41 125    TRUE    FALSE

### Create a classification column

``` r
patients$sbp_status <- ifelse(
  is.na(patients$sbp),
  "Missing",
  ifelse(patients$sbp >= 140, "Review", "Below threshold")
)

patients[, c("id", "sbp", "sbp_status")]
```

    ##     id sbp      sbp_status
    ## 1 P001 118 Below threshold
    ## 2 P002 152          Review
    ## 3 P003  NA         Missing
    ## 4 P004 145          Review
    ## 5 P005 125 Below threshold

### Create a logical eligibility flag

For this illustrative study, eligibility requires:

- age between 40 and 65, inclusive;
- observed SBP at least 140;
- consent;
- no diabetes.

``` r
patients$eligible <-
  !is.na(patients$sbp) &
  patients$age >= 40 &
  patients$age <= 65 &
  patients$sbp >= 140 &
  patients$consent &
  !patients$diabetes

patients[, c("id", "eligible")]
```

    ##     id eligible
    ## 1 P001    FALSE
    ## 2 P002    FALSE
    ## 3 P003    FALSE
    ## 4 P004    FALSE
    ## 5 P005    FALSE

For a logical flag, direct vectorized comparisons are generally clearer
than `ifelse(condition, TRUE, FALSE)`.

### Select eligible records

``` r
patients[patients$eligible, , drop = FALSE]
```

    ## [1] id         age        sbp        consent    diabetes   sbp_status eligible  
    ## <0 rows> (or 0-length row.names)

### Count eligible participants

``` r
sum(patients$eligible)
```

    ## [1] 0

This works because `TRUE` is treated as 1 and `FALSE` as 0 in arithmetic
summaries.

------------------------------------------------------------------------

## 10.21 Avoiding missing rows during filtering

If we use:

``` r
patients$sbp >= 140
```

    ## [1] FALSE  TRUE    NA  TRUE FALSE

the result includes `NA` where SBP is missing.

The following may produce an unwanted row of missing values:

``` r
patients[patients$sbp >= 140, ]
```

    ##      id age sbp consent diabetes sbp_status eligible
    ## 2  P002  58 152    TRUE     TRUE     Review    FALSE
    ## NA <NA>  NA  NA      NA       NA       <NA>       NA
    ## 4  P004  62 145   FALSE    FALSE     Review    FALSE

Instead, define an observed-value condition:

``` r
keep <- !is.na(patients$sbp) & patients$sbp >= 140

patients[keep, , drop = FALSE]
```

    ##     id age sbp consent diabetes sbp_status eligible
    ## 2 P002  58 152    TRUE     TRUE     Review    FALSE
    ## 4 P004  62 145   FALSE    FALSE     Review    FALSE

This is not merely a coding convenience. It makes our policy for missing
measurements explicit.

------------------------------------------------------------------------

## 10.22 Conditions based on text values

Research data often contain character labels.

``` r
sex <- "Female"

if (sex == "Female") {
  print("Female category recorded.")
} else {
  print("Another category recorded.")
}
```

    ## [1] "Female category recorded."

This example demonstrates exact string matching, not an inference about
biological sex or gender identity.

### Membership with `%in%`

``` r
study_site <- "Site_B"

if (study_site %in% c("Site_A", "Site_B", "Site_C")) {
  print("Recognized study site.")
} else {
  print("Unrecognized study site.")
}
```

    ## [1] "Recognized study site."

`%in%` is useful for checking whether a value belongs to an approved
list.

### Case sensitivity

``` r
"yes" == "Yes"
```

    ## [1] FALSE

``` r
tolower("Yes") == "yes"
```

    ## [1] TRUE

Real datasets may require consistent capitalization and whitespace
handling.

``` r
consent_text <- " Yes "
clean_consent <- tolower(trimws(consent_text))
clean_consent
```

    ## [1] "yes"

We should standardize categories according to a documented coding
scheme.

------------------------------------------------------------------------

## 10.23 `ifelse()` and data-type coercion

`ifelse()` can coerce results when the `yes` and `no` values have
different types.

``` r
x <- c(10, 20, 30)

result <- ifelse(x >= 20, "High", 0)
result
```

    ## [1] "0"    "High" "High"

``` r
typeof(result)
```

    ## [1] "character"

Because one branch contains character values, the output becomes
character where those branches are used.

### Factors require special attention

``` r
group <- factor(c("Control", "Case", "Control"))
group
```

    ## [1] Control Case    Control
    ## Levels: Case Control

Using `ifelse()` to choose between factor values can return underlying
integer codes or lose factor attributes.

For categorical recoding, it is often safer to produce explicit
character labels and then construct a factor:

``` r
group_label <- ifelse(
  as.character(group) == "Case",
  "Case",
  "Control"
)

group_factor <- factor(
  group_label,
  levels = c("Control", "Case")
)

group_factor
```

    ## [1] Control Case    Control
    ## Levels: Control Case

### Dates also require care

`ifelse()` may strip class attributes from date-like objects.

``` r
dates <- as.Date(c("2026-01-01", "2026-01-15"))
class(dates)
```

    ## [1] "Date"

For this reason, we should not assume `ifelse()` preserves classes. We
will cover dates and times in Chapter 26.

------------------------------------------------------------------------

## 10.24 When not to use `ifelse()`

`ifelse()` is convenient for selecting values, but it is not the best
tool for every task.

Avoid using it when:

- we need to execute several statements conditionally;
- we need a scalar workflow decision;
- output types or attributes must be preserved carefully;
- conditions are complex enough that nested expressions become
  unreadable;
- a direct logical comparison is sufficient.

For example:

``` r
ages <- c(18, 22, 16, 65)
is_adult <- ages >= 18
is_adult
```

    ## [1]  TRUE  TRUE FALSE  TRUE

This is better than:

``` r
ifelse(ages >= 18, TRUE, FALSE)
```

The direct expression is shorter and communicates the same meaning.

------------------------------------------------------------------------

## 10.25 A genomic QC example: variant-level rules

GWAS summary-statistic QC frequently uses several logical conditions. We
will work with a small synthetic dataset.

``` r
gwas <- data.frame(
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE", "rsF"),
  CHROM = c(6L, 6L, 6L, 1L, 6L, 6L),
  POS = c(26295926L, 31298240L, 32626565L,
          1500000L, 33794605L, 29000000L),
  BETA = c(0.05, -0.08, 0.12, 0.01, NA, 0.03),
  SE = c(0.01, 0.02, 0.02, 0.01, 0.02, 0),
  PVAL = c(2e-8, 3e-9, 5e-12, 0.30, NA, 1e-6)
)

gwas
```

    ##    ID CHROM      POS  BETA   SE  PVAL
    ## 1 rsA     6 26295926  0.05 0.01 2e-08
    ## 2 rsB     6 31298240 -0.08 0.02 3e-09
    ## 3 rsC     6 32626565  0.12 0.02 5e-12
    ## 4 rsD     1  1500000  0.01 0.01 3e-01
    ## 5 rsE     6 33794605    NA 0.02    NA
    ## 6 rsF     6 29000000  0.03 0.00 1e-06

These are illustrative teaching values, not results from a real GWAS.

### Step 1: identify missing essential fields

``` r
gwas$missing_essential <-
  is.na(gwas$BETA) |
  is.na(gwas$SE) |
  is.na(gwas$PVAL)

gwas[, c("ID", "missing_essential")]
```

    ##    ID missing_essential
    ## 1 rsA             FALSE
    ## 2 rsB             FALSE
    ## 3 rsC             FALSE
    ## 4 rsD             FALSE
    ## 5 rsE              TRUE
    ## 6 rsF             FALSE

### Step 2: check standard errors

``` r
gwas$valid_se <- !is.na(gwas$SE) & gwas$SE > 0
```

A zero or negative standard error is invalid for the Z-statistic
calculation.

### Step 3: check p-value range

``` r
gwas$valid_p <- !is.na(gwas$PVAL) &
  gwas$PVAL >= 0 &
  gwas$PVAL <= 1
```

A p-value must lie between zero and one. Very small p-values can be
represented as zero due to numerical underflow in some outputs; such
cases require appropriate handling.

### Step 4: create a basic QC flag

``` r
gwas$qc_pass <-
  !gwas$missing_essential &
  gwas$valid_se &
  gwas$valid_p

gwas[, c("ID", "missing_essential", "valid_se", "valid_p", "qc_pass")]
```

    ##    ID missing_essential valid_se valid_p qc_pass
    ## 1 rsA             FALSE     TRUE    TRUE    TRUE
    ## 2 rsB             FALSE     TRUE    TRUE    TRUE
    ## 3 rsC             FALSE     TRUE    TRUE    TRUE
    ## 4 rsD             FALSE     TRUE    TRUE    TRUE
    ## 5 rsE              TRUE     TRUE   FALSE   FALSE
    ## 6 rsF             FALSE    FALSE    TRUE   FALSE

### Step 5: calculate Z only for passing variants

``` r
gwas$Z <- NA_real_

pass <- which(gwas$qc_pass)

gwas$Z[pass] <- gwas$BETA[pass] / gwas$SE[pass]

gwas[, c("ID", "BETA", "SE", "Z")]
```

    ##    ID  BETA   SE  Z
    ## 1 rsA  0.05 0.01  5
    ## 2 rsB -0.08 0.02 -4
    ## 3 rsC  0.12 0.02  6
    ## 4 rsD  0.01 0.01  1
    ## 5 rsE    NA 0.02 NA
    ## 6 rsF  0.03 0.00 NA

This prevents division by a zero standard error.

### Step 6: select an xMHC-style region

For a teaching interval on chromosome 6:

``` r
gwas$in_region <-
  gwas$CHROM == 6 &
  gwas$POS >= 25000000 &
  gwas$POS <= 34000000

gwas[gwas$in_region, c("ID", "CHROM", "POS")]
```

    ##    ID CHROM      POS
    ## 1 rsA     6 26295926
    ## 2 rsB     6 31298240
    ## 3 rsC     6 32626565
    ## 5 rsE     6 33794605
    ## 6 rsF     6 29000000

### Step 7: combine region and QC criteria

``` r
selected <- gwas[
  gwas$in_region & gwas$qc_pass,
  ,
  drop = FALSE
]

selected
```

    ##    ID CHROM      POS  BETA   SE  PVAL missing_essential valid_se valid_p
    ## 1 rsA     6 26295926  0.05 0.01 2e-08             FALSE     TRUE    TRUE
    ## 2 rsB     6 31298240 -0.08 0.02 3e-09             FALSE     TRUE    TRUE
    ## 3 rsC     6 32626565  0.12 0.02 5e-12             FALSE     TRUE    TRUE
    ##   qc_pass  Z in_region
    ## 1    TRUE  5      TRUE
    ## 2    TRUE -4      TRUE
    ## 3    TRUE  6      TRUE

**Important limitation:** These are introductory programming checks.
Full GWAS QC requires many additional considerations, including allele
orientation, genome build, imputation quality, sample size, variant
identifiers, and study-specific filtering rules.

------------------------------------------------------------------------

## 10.26 Classifying genomic records with explicit reasons

Sometimes a single pass/fail flag is not enough. We want to know *why* a
record failed.

We can use nested `ifelse()` for a small example:

``` r
gwas$qc_reason <- ifelse(
  gwas$missing_essential,
  "Missing essential value",
  ifelse(
    !gwas$valid_se,
    "Invalid standard error",
    ifelse(
      !gwas$valid_p,
      "Invalid p-value",
      "Pass"
    )
  )
)

gwas[, c("ID", "qc_reason")]
```

    ##    ID               qc_reason
    ## 1 rsA                    Pass
    ## 2 rsB                    Pass
    ## 3 rsC                    Pass
    ## 4 rsD                    Pass
    ## 5 rsE Missing essential value
    ## 6 rsF  Invalid standard error

The order determines which reason is assigned when more than one issue
exists. This structure records the **first applicable reason**, not
necessarily every QC issue.

For comprehensive QC, separate logical columns for each failure mode are
usually more informative.

------------------------------------------------------------------------

## 10.27 Conditions in reproducible research workflows

Conditional programming is useful beyond participant or variant
classification.

For example, a script may need to confirm that a required file exists
before trying to read it.

``` r
example_path <- "study_data.csv"

if (file.exists(example_path)) {
  print("The file is available.")
} else {
  print("The file is not present at this path.")
}
```

    ## [1] "The file is not present at this path."

This example does not attempt to read the file, so it is safe to knit
whether or not the file exists.

A real analysis may choose to stop when a required input is missing:

``` r
if (!file.exists(input_path)) {
  stop("Required input file not found.")
}
```

We will explore project paths and file handling in Chapters 14–19.

------------------------------------------------------------------------

## 10.28 Common errors and how to fix them

### Error 1: using `=` instead of `==`

Incorrect:

``` r
if (age = 50) {
  print("Age is 50")
}
```

Correct:

``` r
age <- 50

if (age == 50) {
  print("Age is 50")
}
```

    ## [1] "Age is 50"

### Error 2: passing a vector to `if`

Incorrect:

``` r
if (c(120, 150, 145) >= 140) {
  print("Review")
}
```

Correct for a group-level question:

``` r
if (any(c(120, 150, 145) >= 140)) {
  print("At least one value meets the threshold.")
}
```

    ## [1] "At least one value meets the threshold."

Correct for per-value classification:

``` r
ifelse(c(120, 150, 145) >= 140, "Review", "Below")
```

    ## [1] "Below"  "Review" "Review"

### Error 3: using `&&` for vectorized filtering

Incorrect:

``` r
ages >= 40 && sbps >= 140
```

Correct:

``` r
ages <- c(35, 45, 55)
sbps <- c(125, 148, 155)
ages >= 40 & sbps >= 140
```

    ## [1] FALSE  TRUE  TRUE

### Error 4: forgetting missing values

Incorrect for missing scalar input:

``` r
if (sbp >= 140) {
  print("Review")
}
```

Safer:

``` r
sbp <- NA_real_

if (is.na(sbp)) {
  print("SBP is missing.")
} else if (sbp >= 140) {
  print("Review")
} else {
  print("Below threshold")
}
```

    ## [1] "SBP is missing."

### Error 5: incorrectly ordering `else if` branches

More general conditions placed first may prevent specific branches from
executing.

### Error 6: assuming `ifelse()` preserves factor classes

Convert to character labels first and reconstruct factors when
necessary.

### Error 7: assuming `NA` means `FALSE`

Missing information is not equivalent to a negative finding.

### Error 8: forgetting that `all(logical(0))` is `TRUE`

Validate the expected number of observations before interpreting
aggregate QC results.

### Error 9: making rules without checking units

A numerical threshold is meaningless without the correct measurement
units and coding.

### Error 10: mixing data validation and scientific interpretation

A value can pass a basic programming check without being biologically
plausible or clinically meaningful.

------------------------------------------------------------------------

## 10.29 Guided practical: participant eligibility screening

We will build a complete screening workflow using a synthetic dataset.

### Step 1: create the data

``` r
screening <- data.frame(
  patient_id = c("P001", "P002", "P003", "P004", "P005", "P006"),
  age = c(45, 58, 39, 67, 52, 47),
  sbp = c(150, 145, 155, 148, NA, 142),
  diabetes = c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE),
  consent = c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE)
)

screening
```

    ##   patient_id age sbp diabetes consent
    ## 1       P001  45 150    FALSE    TRUE
    ## 2       P002  58 145     TRUE    TRUE
    ## 3       P003  39 155    FALSE    TRUE
    ## 4       P004  67 148    FALSE    TRUE
    ## 5       P005  52  NA    FALSE    TRUE
    ## 6       P006  47 142    FALSE   FALSE

### Step 2: inspect the dataset

``` r
str(screening)
```

    ## 'data.frame':    6 obs. of  5 variables:
    ##  $ patient_id: chr  "P001" "P002" "P003" "P004" ...
    ##  $ age       : num  45 58 39 67 52 47
    ##  $ sbp       : num  150 145 155 148 NA 142
    ##  $ diabetes  : logi  FALSE TRUE FALSE FALSE FALSE FALSE
    ##  $ consent   : logi  TRUE TRUE TRUE TRUE TRUE FALSE

``` r
colSums(is.na(screening))
```

    ## patient_id        age        sbp   diabetes    consent 
    ##          0          0          1          0          0

### Step 3: define a screening status with three outcomes

``` r
screening$sbp_status <- ifelse(
  is.na(screening$sbp),
  "Missing",
  ifelse(screening$sbp >= 140, "Review", "Below threshold")
)

screening[, c("patient_id", "sbp", "sbp_status")]
```

    ##   patient_id sbp sbp_status
    ## 1       P001 150     Review
    ## 2       P002 145     Review
    ## 3       P003 155     Review
    ## 4       P004 148     Review
    ## 5       P005  NA    Missing
    ## 6       P006 142     Review

### Step 4: apply the full eligibility rule

Require age 40–65 inclusive, observed SBP at least 140, no diabetes, and
consent.

``` r
screening$eligible <-
  !is.na(screening$sbp) &
  screening$age >= 40 &
  screening$age <= 65 &
  screening$sbp >= 140 &
  !screening$diabetes &
  screening$consent

screening[, c("patient_id", "eligible")]
```

    ##   patient_id eligible
    ## 1       P001     TRUE
    ## 2       P002    FALSE
    ## 3       P003    FALSE
    ## 4       P004    FALSE
    ## 5       P005    FALSE
    ## 6       P006    FALSE

### Step 5: select eligible participants

``` r
eligible <- screening[
  screening$eligible,
  ,
  drop = FALSE
]

eligible
```

    ##   patient_id age sbp diabetes consent sbp_status eligible
    ## 1       P001  45 150    FALSE    TRUE     Review     TRUE

### Step 6: calculate the eligible proportion

``` r
sum(screening$eligible)
```

    ## [1] 1

``` r
mean(screening$eligible)
```

    ## [1] 0.1666667

The second result is the fraction of all screened records that meet the
programmed criteria. It is not a population prevalence estimate.

### Step 7: validate the outcome

``` r
stopifnot(!anyNA(screening$eligible))
stopifnot(all(eligible$age >= 40 & eligible$age <= 65))
stopifnot(all(!is.na(eligible$sbp)))
stopifnot(all(eligible$sbp >= 140))
stopifnot(all(!eligible$diabetes))
stopifnot(all(eligible$consent))
```

### Step 8: interpret

We have implemented a clear set of rules. The code can be audited
because each criterion is explicit. In real studies, eligibility rules
must come from the approved protocol and must be reviewed for
missing-data policies and unit consistency.

------------------------------------------------------------------------

## 10.30 Independent exercises: basic conditional logic

Complete the following exercises without consulting the solutions.

**Exercise 1.** Create `age <- 52`. Write an `if` statement that prints
`"Age criterion met"` when age is at least 50.

**Exercise 2.** Create `sbp <- 132`. Write an `if`/`else` statement that
assigns `"Review"` when SBP is at least 140 and `"Below threshold"`
otherwise.

**Exercise 3.** Write an `else if` chain that categorizes an age into:
under 18, 18–39, 40–64, and 65 or older. Test boundary ages 17, 18, 39,
40, 64, and 65.

**Exercise 4.** Explain why `if (c(TRUE, FALSE))` is invalid.

**Exercise 5.** Explain the difference between `&` and `&&` using a
three-element vector.

**Exercise 6.** Create `x <- c(5, 10, 15, 20)`. Use `ifelse()` to assign
`"High"` when a value is at least 15 and `"Low"` otherwise.

**Exercise 7.** Create `x <- c(5, NA, 15)`. Write a classification that
returns `"Missing"` for `NA`, `"High"` for values at least 10, and
`"Low"` otherwise.

**Exercise 8.** Predict the results of `any(c(FALSE, NA))` and
`all(c(TRUE, NA))`. Explain the uncertainty.

**Exercise 9.** Explain why `isTRUE(NA)` returns `FALSE`, and why that
does not mean the missing value is a negative finding.

**Exercise 10.** Write a scalar conditional check that rejects a
negative BMI value with an error message.

------------------------------------------------------------------------

## 10.31 Independent exercises: epidemiological screening

Use this dataset:

``` r
practice_patients <- data.frame(
  id = c("S1", "S2", "S3", "S4", "S5", "S6"),
  age = c(28, 45, 62, 53, 39, 70),
  sbp = c(120, 150, 145, NA, 142, 160),
  smoker = c(FALSE, TRUE, FALSE, FALSE, TRUE, FALSE),
  consent = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE)
)
```

Tasks:

1.  Create an `adult` logical column for age at least 18.
2.  Create an `sbp_status` column with values `"Missing"`, `"Review"`,
    and `"Below threshold"`.
3.  Select participants aged 40–65 inclusive.
4.  Select participants with observed SBP at least 140.
5.  Create an eligibility flag requiring age 40–65, observed SBP at
    least 140, and consent.
6.  Count eligible participants.
7.  Calculate the proportion eligible.
8.  Verify that the eligibility flag contains no `NA`.
9.  Create a text column explaining whether a participant is missing
    SBP, does not consent, or meets the screening criteria. Explain how
    the order of conditions affects the first reason recorded.
10. Explain why `if (practice_patients$sbp >= 140)` cannot classify the
    entire dataset.

------------------------------------------------------------------------

## 10.32 Independent exercises: genomic QC

Use this synthetic dataset:

``` r
practice_gwas <- data.frame(
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5"),
  CHROM = c(6L, 6L, 6L, 1L, 6L),
  POS = c(27000000L, 31000000L, 33000000L, 1500000L, 34000000L),
  BETA = c(0.05, -0.07, NA, 0.02, 0.08),
  SE = c(0.01, 0.02, 0.02, 0, 0.01),
  PVAL = c(1e-8, 2e-9, NA, 0.4, 7e-10)
)
```

Tasks:

1.  Create a logical column for missing `BETA`, `SE`, or `PVAL`.
2.  Create a flag for valid standard errors (`SE > 0` and observed).
3.  Create a flag for valid p-values (observed and between 0 and 1).
4.  Create a combined `qc_pass` flag.
5.  Calculate Z scores only for passing variants.
6.  Select variants on chromosome 6 between 25,000,000 and 34,000,000
    inclusive.
7.  Select variants satisfying both the region condition and `qc_pass`.
8.  Create a first-failure-reason column.
9.  Explain why this QC workflow is not sufficient for real GWAS
    harmonization.
10. Explain why we should avoid dividing by `SE = 0`.

------------------------------------------------------------------------

## 10.33 Challenge: create a reusable screening function

Write a function named `screen_one()` that accepts four arguments:

``` r
screen_one(age, sbp, consent, diabetes)
```

The function should:

1.  Require each input to have length one.
2.  Check that age and SBP are numeric.
3.  Return `"Missing information"` when a required input is missing.
4.  Return `"Invalid input"` for impossible values such as negative age
    or nonpositive SBP.
5.  Require age 40–65 inclusive.
6.  Require SBP at least 140.
7.  Require consent to be `TRUE`.
8.  Require diabetes to be `FALSE`.
9.  Return `"Eligible"` if all rules are met and `"Not eligible"`
    otherwise.
10. Test boundary values and missing values.

**Design question:** Should missing data be treated as ineligible, or
should they produce a separate status? Explain why this is a protocol
decision.

------------------------------------------------------------------------

## 10.34 Complete Chapter 10 practice script

The script below consolidates the principal examples. It is not executed
during knitting because the chapter has already demonstrated its
components.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 10: Conditional Programming
# Base R only
# ============================================================

# Scalar decisions
age <- 52
sbp <- 150

if (age >= 40 && sbp >= 140) {
  print("Both criteria met.")
} else {
  print("At least one criterion not met.")
}

# Multiple branches
age_group <- if (age < 18) {
  "Under 18"
} else if (age < 40) {
  "18-39"
} else if (age < 65) {
  "40-64"
} else {
  "65 or older"
}

print(age_group)

# Vectorized classification
sbp_values <- c(120, 150, NA, 135, 145)

sbp_status <- ifelse(
  is.na(sbp_values),
  "Missing",
  ifelse(sbp_values >= 140, "Review", "Below threshold")
)

print(sbp_status)

# Data-frame screening
patients <- data.frame(
  id = c("P1", "P2", "P3", "P4"),
  age = c(45, 58, 39, 62),
  sbp = c(150, 145, NA, 148),
  consent = c(TRUE, TRUE, TRUE, FALSE),
  diabetes = c(FALSE, TRUE, FALSE, FALSE)
)

patients$eligible <-
  !is.na(patients$sbp) &
  patients$age >= 40 &
  patients$age <= 65 &
  patients$sbp >= 140 &
  patients$consent &
  !patients$diabetes

eligible <- patients[patients$eligible, , drop = FALSE]
print(eligible)

stopifnot(!anyNA(patients$eligible))

# Basic GWAS QC
gwas <- data.frame(
  ID = c("rsA", "rsB", "rsC"),
  BETA = c(0.05, NA, 0.10),
  SE = c(0.01, 0.02, 0),
  PVAL = c(1e-8, NA, 1e-9)
)

gwas$qc_pass <-
  !is.na(gwas$BETA) &
  !is.na(gwas$SE) &
  gwas$SE > 0 &
  !is.na(gwas$PVAL) &
  gwas$PVAL >= 0 &
  gwas$PVAL <= 1

gwas$Z <- NA_real_
pass <- which(gwas$qc_pass)
gwas$Z[pass] <- gwas$BETA[pass] / gwas$SE[pass]

print(gwas)
```

------------------------------------------------------------------------

## 10.35 Essential functions and operators

| Tool                 | Purpose                                  |
|----------------------|------------------------------------------|
| `if`                 | Execute code when one condition is true  |
| `else`               | Execute an alternative branch            |
| `else if`            | Test additional conditions in order      |
| `ifelse()`           | Select values element by element         |
| `&`                  | Element-wise AND                         |
| `|`                  | Element-wise OR                          |
| `!`                  | Logical NOT                              |
| `&&`                 | Short-circuit scalar AND                 |
| `||`                 | Short-circuit scalar OR                  |
| `==`, `!=`           | Equality and inequality                  |
| `<`, `<=`, `>`, `>=` | Numerical comparisons                    |
| `%in%`               | Test membership in a set                 |
| `is.na()`            | Identify missing values                  |
| `is.nan()`           | Identify `NaN` values                    |
| `is.finite()`        | Identify finite numeric values           |
| `isTRUE()`           | Check for exactly one non-missing `TRUE` |
| `any()`              | Test whether at least one value is true  |
| `all()`              | Test whether all values are true         |
| `which()`            | Return positions of true elements        |
| `stop()`             | Stop execution with an error             |
| `warning()`          | Report a warning                         |
| `stopifnot()`        | Enforce program assumptions              |
| `cut()`              | Classify numeric values into intervals   |

------------------------------------------------------------------------

## 10.36 Chapter review

We should now be able to explain:

1.  What happens when an `if` condition evaluates to `TRUE`, `FALSE`, or
    `NA`.
2.  Why `if` requires one logical value.
3.  Why `ifelse()` is suitable for classifying a vector.
4.  How `else if` branches are evaluated.
5.  Why branch order changes the result.
6.  The difference between `&` and `&&`.
7.  The difference between `|` and `||`.
8.  How short-circuit evaluation can avoid an invalid second test.
9.  Why `ifelse()` is not a substitute for arbitrary multi-statement
    control flow.
10. Why direct logical expressions can be better than
    `ifelse(..., TRUE, FALSE)`.
11. How missing values propagate through comparisons.
12. How to use `any()` and `all()` safely.
13. Why `all(logical(0))` deserves attention.
14. How `isTRUE()` differs from a complete missing-data policy.
15. Why factors and dates require care with `ifelse()`.
16. How to validate inputs before applying decision rules.
17. How to create eligibility flags in a data frame.
18. How to prevent invalid standard errors from entering GWAS Z-score
    calculations.
19. Why QC flags should preserve failure reasons.
20. Why technically correct code still requires scientific validation.

## 10.37 Key takeaways

- **`if` and `else` control which code runs** for a single logical
  decision.
- **`else if` provides multiple branches**, evaluated in order.
- **`ifelse()` selects values across vectors**, making it useful for
  data-frame columns.
- **`&` and `|` are element-wise**, while **`&&` and `||` are scalar
  short-circuit operators**.
- **Missing data are not equivalent to false conditions**; they need an
  explicit policy.
- **Branch order, input type, and input length** are critical to
  reliable programs.
- **`any()` and `all()` summarize logical vectors**, but their behavior
  with `NA` and empty vectors must be understood.
- **`ifelse()` can change types or strip attributes**, so inspect the
  output.
- **Conditional rules should be auditable and validated**, especially in
  clinical and genomic pipelines.

> A robust research program does not merely make a decision; it makes
> the conditions, assumptions, and handling of missing or invalid inputs
> explicit.

## 10.38 Looking ahead: Chapter 11 — Loops

So far, we have used conditional statements to decide what should happen
in one step. But what if we need to repeat a quality-control check for
hundreds of files, evaluate a sequence of parameters, or process
multiple chromosomes?

In **Chapter 11 — Loops**, we will learn how to repeat operations using
`for`, `while`, and `repeat`, and how to combine loops with conditional
statements. We will also discuss when vectorization is preferable to
explicit loops.
