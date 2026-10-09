Functions in R: Creating Reusable Research Code
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 11, we learned to repeat operations with loops. A related
problem arises when the **same operation** must be performed in many
parts of a project. Rewriting the same calculations invites
inconsistencies: one copy may handle missing values correctly while
another does not. **Functions** solve this problem by packaging a task
into a named, reusable unit.

In biomedical research, we might need to calculate body mass index
(BMI), evaluate study eligibility, compute a summary statistic, validate
a genomic variant, or process multiple tissues. We can write each rule
once, test it, and reuse it with different inputs.

This chapter uses **base R only**. All data are synthetic, and
executable code chunks define the objects they need. We use **we**,
**us**, and **our** throughout the explanations, and focus on what a
beginner needs to understand before writing more complex research
pipelines.

## 12.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Explain why functions improve reproducibility and maintainability.
2.  Create functions using `function()` and assign meaningful names.
3.  Distinguish parameters, arguments, and return values.
4.  Use positional, named, and default arguments.
5.  Understand implicit returns and explicit `return()`.
6.  Explain local variables and lexical scoping.
7.  Validate argument types, lengths, ranges, and missingness.
8.  Distinguish scalar and vectorized functions.
9.  Write functions that handle `NA`, empty inputs, and invalid values.
10. Return multiple results using lists and data frames.
11. Compose functions, use them in loops, and apply them across groups.
12. Test functions using base R assertions.
13. Develop small, auditable biomedical and GWAS analysis utilities.

------------------------------------------------------------------------

## 12.2 Why write a function?

Suppose we calculate BMI for several participants:

$$BMI = \frac{\text{weight in kg}}{(\text{height in metres})^2}.$$

Without a function, we might repeat the expression:

``` r
bmi_a <- 70 / 1.70^2
bmi_b <- 82 / 1.78^2
bmi_c <- 61 / 1.62^2
c(bmi_a, bmi_b, bmi_c)
```

    ## [1] 24.22145 25.88057 23.24341

A function expresses the formula once:

``` r
calculate_bmi <- function(weight_kg, height_m) {
  weight_kg / height_m^2
}

calculate_bmi(70, 1.70)
```

    ## [1] 24.22145

``` r
calculate_bmi(82, 1.78)
```

    ## [1] 25.88057

``` r
calculate_bmi(61, 1.62)
```

    ## [1] 23.24341

If the calculation requires improved validation, we change one function
rather than editing every occurrence. A function is useful when a task
has a stable meaning and may be reused, tested, or documented.

## 12.3 Anatomy of a function

The general syntax is:

``` r
function_name <- function(parameter_1, parameter_2) {
  statements
  result
}
```

We can identify four parts:

- **Function name:** the object used to call the function.
- **Parameters (formal arguments):** names of the inputs in the function
  definition.
- **Body:** the instructions inside `{ }`.
- **Return value:** the result passed back to the caller.

``` r
add_two_numbers <- function(a, b) {
  total <- a + b
  total
}

add_two_numbers(4, 7)
```

    ## [1] 11

Here, `a` and `b` are parameters; `4` and `7` are the supplied
arguments. `total` is a local intermediate variable. The result is `11`.

### Function definition versus function call

Defining a function does not execute its body:

``` r
square_value <- function(x) {
  x^2
}
```

The body runs when we call it:

``` r
square_value(5)
```

    ## [1] 25

``` r
square_value(12)
```

    ## [1] 144

### A function is an object

``` r
class(square_value)
```

    ## [1] "function"

``` r
typeof(square_value)
```

    ## [1] "closure"

``` r
is.function(square_value)
```

    ## [1] TRUE

We can store a function in another name:

``` r
square_again <- square_value
square_again(6)
```

    ## [1] 36

------------------------------------------------------------------------

## 12.4 Parameters and arguments

Consider:

``` r
calculate_change <- function(baseline, followup) {
  followup - baseline
}

calculate_change(150, 138)
```

    ## [1] -12

The result is `-12` mmHg: follow-up minus baseline.

### Positional matching

``` r
calculate_change(150, 138)
```

    ## [1] -12

R matches the first supplied value to `baseline` and the second to
`followup`.

### Named matching

``` r
calculate_change(followup = 138, baseline = 150)
```

    ## [1] -12

Named arguments improve readability and reduce the risk of reversing
inputs.

### Why order matters

``` r
calculate_change(138, 150)
```

    ## [1] 12

This produces `12`, a different scientific interpretation. When
arguments have similar types, named arguments are especially valuable.

**Good practice:** Use explicit names for critical inputs such as
`effect_allele`, `reference_allele`, `baseline`, and `followup`.

------------------------------------------------------------------------

## 12.5 Default arguments

We can give a parameter a default value:

``` r
convert_temperature <- function(celsius, digits = 1) {
  fahrenheit <- (celsius * 9 / 5) + 32
  round(fahrenheit, digits = digits)
}

convert_temperature(37)
```

    ## [1] 98.6

``` r
convert_temperature(37, digits = 2)
```

    ## [1] 98.6

The parameter `digits` is optional because it has a default. The
`celsius` input is required.

### Defaults in statistical summaries

``` r
mean_measurement <- function(x, remove_missing = TRUE) {
  mean(x, na.rm = remove_missing)
}

measurements <- c(120, 135, NA, 142)
mean_measurement(measurements)
```

    ## [1] 132.3333

``` r
mean_measurement(measurements, remove_missing = FALSE)
```

    ## [1] NA

A default is a design decision. We should document it rather than
silently removing observations without explanation.

------------------------------------------------------------------------

## 12.6 Implicit and explicit returns

In R, the value of the last evaluated expression is returned
automatically:

``` r
mean_of_two <- function(a, b) {
  (a + b) / 2
}

mean_of_two(10, 20)
```

    ## [1] 15

We can instead use `return()`:

``` r
mean_of_two_explicit <- function(a, b) {
  result <- (a + b) / 2
  return(result)
}

mean_of_two_explicit(10, 20)
```

    ## [1] 15

Both functions give the same answer.

### Early returns

Explicit `return()` is useful for invalid or missing inputs:

``` r
classify_sbp_scalar <- function(sbp) {
  if (!is.numeric(sbp) || length(sbp) != 1L) {
    stop("sbp must be one numeric value")
  }
  if (is.na(sbp) || !is.finite(sbp)) {
    return("Missing or invalid")
  }
  if (sbp >= 140) {
    return("Review")
  }
  "Below threshold"
}

classify_sbp_scalar(152)
```

    ## [1] "Review"

``` r
classify_sbp_scalar(128)
```

    ## [1] "Below threshold"

``` r
classify_sbp_scalar(NA_real_)
```

    ## [1] "Missing or invalid"

The threshold is an illustrative study-screening rule, **not a
diagnosis**.

------------------------------------------------------------------------

## 12.7 Local variables and the function environment

Variables created inside a function generally remain local to that
function:

``` r
local_example <- function(x) {
  intermediate <- x * 2
  intermediate + 1
}

local_example(5)
```

    ## [1] 11

The object `intermediate` belongs to the function’s evaluation
environment. It is not automatically added to the global environment.

### Local and global names

``` r
value <- 100

use_local_value <- function(value) {
  value <- value + 10
  value
}

use_local_value(5)
```

    ## [1] 15

``` r
value
```

    ## [1] 100

The global `value` remains `100`. The function uses its own parameter
named `value`.

### Lexical scoping

R resolves names according to where functions were **defined**, not
merely where they were called. A function may refer to objects in an
enclosing environment:

``` r
make_multiplier <- function(factor) {
  function(x) {
    x * factor
  }
}

double <- make_multiplier(2)
triple <- make_multiplier(3)

double(5)
```

    ## [1] 10

``` r
triple(5)
```

    ## [1] 15

The inner functions retain access to their respective `factor` values.
This is called a **closure**.

For beginner research scripts, explicit arguments are usually preferable
to relying on changing global objects.

------------------------------------------------------------------------

## 12.8 Side effects and the `<<-` operator

A well-behaved analysis function generally receives inputs and returns
outputs without unexpectedly changing unrelated objects.

This example uses an ordinary local assignment:

``` r
count <- 10

local_counter <- function() {
  count <- 1
  count + 1
}

local_counter()
```

    ## [1] 2

``` r
count
```

    ## [1] 10

The global `count` remains `10`.

R also has `<<-`, which searches enclosing environments and can modify
an existing binding. This can create hard-to-debug state changes. We
should generally avoid it in introductory research pipelines.

**Preferred pattern:** Return a new value and assign it explicitly
outside the function.

------------------------------------------------------------------------

## 12.9 Vectorized functions

Our original BMI function uses vectorized arithmetic:

``` r
calculate_bmi <- function(weight_kg, height_m) {
  weight_kg / height_m^2
}

weights <- c(62, 84, 71)
heights <- c(1.62, 1.75, 1.66)

calculate_bmi(weights, heights)
```

    ## [1] 23.62445 27.42857 25.76571

R performs element-wise division. The first weight is paired with the
first height, the second with the second, and so on.

### Beware of recycling

If the input lengths differ, R may recycle values. This can silently
pair measurements incorrectly.

For research functions, we should enforce aligned lengths:

``` r
calculate_bmi_checked <- function(weight_kg, height_m) {
  if (!is.numeric(weight_kg) || !is.numeric(height_m)) {
    stop("Weight and height must be numeric")
  }
  if (length(weight_kg) != length(height_m)) {
    stop("Weight and height must have equal lengths")
  }
  if (any(!is.na(weight_kg) & (!is.finite(weight_kg) | weight_kg <= 0))) {
    stop("Observed weights must be finite and positive")
  }
  if (any(!is.na(height_m) & (!is.finite(height_m) | height_m <= 0))) {
    stop("Observed heights must be finite and positive")
  }
  weight_kg / height_m^2
}

calculate_bmi_checked(weights, heights)
```

    ## [1] 23.62445 27.42857 25.76571

The function preserves `NA` when either measurement is missing. It
rejects observed nonpositive or infinite measurements.

### What about an empty vector?

``` r
calculate_bmi_checked(numeric(0), numeric(0))
```

    ## numeric(0)

The result is empty. Whether empty input should be allowed is a design
choice; for some functions it is reasonable, while for others it should
produce an error.

------------------------------------------------------------------------

## 12.10 Scalar functions versus vectorized functions

The following function is intended for **one** SBP value:

``` r
classify_sbp_scalar <- function(sbp) {
  if (!is.numeric(sbp) || length(sbp) != 1L) {
    stop("Expected one numeric SBP value")
  }
  if (is.na(sbp)) return("Missing")
  if (!is.finite(sbp) || sbp <= 0) return("Invalid")
  if (sbp >= 140) return("Review")
  "Below threshold"
}
```

To classify several measurements, we can use `vapply()`:

``` r
sbp <- c(118, 152, NA, 145, -5)
labels <- vapply(sbp, classify_sbp_scalar, character(1))
labels
```

    ## [1] "Below threshold" "Review"          "Missing"         "Review"         
    ## [5] "Invalid"

`vapply()` applies the scalar function to each element and requires a
character result of length one.

Alternatively, we can write a vectorized function directly:

``` r
classify_sbp_vector <- function(sbp) {
  if (!is.numeric(sbp)) stop("SBP must be numeric")
  result <- rep("Below threshold", length(sbp))
  result[!is.na(sbp) & is.finite(sbp) & sbp >= 140] <- "Review"
  result[!is.na(sbp) & (!is.finite(sbp) | sbp <= 0)] <- "Invalid"
  result[is.na(sbp)] <- "Missing"
  result
}

classify_sbp_vector(sbp)
```

    ## [1] "Below threshold" "Review"          "Missing"         "Review"         
    ## [5] "Invalid"

For `NaN`, the final missing-value rule assigns `"Missing"`; for `Inf`,
the invalid rule assigns `"Invalid"`. These classifications are explicit
design choices.

Compare the two approaches on ordinary finite or `NA` inputs:

``` r
example_sbp <- c(118, 152, NA, 145, -5)
stopifnot(identical(
  unname(vapply(example_sbp, classify_sbp_scalar, character(1))),
  classify_sbp_vector(example_sbp)
))
```

------------------------------------------------------------------------

## 12.11 Input validation: types and lengths

A function should state its assumptions and check those that matter.

``` r
validate_age <- function(age) {
  if (!is.numeric(age)) stop("Age must be numeric")
  if (length(age) != 1L) stop("Age must have length one")
  if (is.na(age) || !is.finite(age)) stop("Age must be observed and finite")
  if (age < 0 || age > 120) stop("Age is outside this study's permitted range")
  TRUE
}

validate_age(45)
```

    ## [1] TRUE

The upper limit of 120 is a **study-specific demonstration**, not a
universal biological rule.

### `stop()`, `warning()`, and `message()`

- `stop()` interrupts execution when the function cannot safely proceed.
- `warning()` reports a concern but usually continues.
- `message()` communicates diagnostic or progress information.

``` r
report_measurement <- function(x) {
  if (!is.numeric(x)) stop("Expected numeric input")
  if (length(x) == 0L) {
    message("No measurements supplied")
    return(NA_real_)
  }
  if (anyNA(x)) {
    message("Missing values will be excluded")
  }
  mean(x, na.rm = TRUE)
}

report_measurement(c(10, NA, 20))
```

    ## Missing values will be excluded

    ## [1] 15

Messages should be useful rather than excessively verbose.

------------------------------------------------------------------------

## 12.12 Missing values and empty inputs

A function should define what happens when all observations are missing:

``` r
safe_mean <- function(x) {
  if (!is.numeric(x)) stop("x must be numeric")
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) return(NA_real_)
  mean(observed)
}

safe_mean(c(10, NA, 20))
```

    ## [1] 15

``` r
safe_mean(c(NA_real_, NA_real_))
```

    ## [1] NA

``` r
safe_mean(numeric(0))
```

    ## [1] NA

### What does `na.rm = TRUE` mean scientifically?

Removing missing observations changes the denominator. It does **not**
guarantee that the estimate is unbiased. The choice depends on the study
design, missing-data mechanism, and analysis plan.

### A more informative summary

``` r
summarize_measurement <- function(x) {
  if (!is.numeric(x)) stop("x must be numeric")
  observed <- x[!is.na(x)]
  list(
    n_total = length(x),
    n_observed = length(observed),
    n_missing = sum(is.na(x)),
    mean = if (length(observed) == 0L) NA_real_ else mean(observed),
    sd = if (length(observed) < 2L) NA_real_ else sd(observed)
  )
}

summarize_measurement(c(118, 145, NA, 152, 130))
```

    ## $n_total
    ## [1] 5
    ## 
    ## $n_observed
    ## [1] 4
    ## 
    ## $n_missing
    ## [1] 1
    ## 
    ## $mean
    ## [1] 136.25
    ## 
    ## $sd
    ## [1] 15.23975

`sd()` uses the sample standard deviation with denominator $n-1$. It is
undefined for fewer than two observed measurements.

------------------------------------------------------------------------

## 12.13 Returning multiple outputs

A function returns one R object, but that object can be a list
containing several results.

``` r
summary_stats <- function(x) {
  if (!is.numeric(x)) stop("x must be numeric")
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) {
    return(list(n = 0L, mean = NA_real_, median = NA_real_, sd = NA_real_))
  }
  list(
    n = length(observed),
    mean = mean(observed),
    median = median(observed),
    sd = if (length(observed) >= 2L) sd(observed) else NA_real_
  )
}

result <- summary_stats(c(120, 150, 145, NA, 142))
result
```

    ## $n
    ## [1] 4
    ## 
    ## $mean
    ## [1] 139.25
    ## 
    ## $median
    ## [1] 143.5
    ## 
    ## $sd
    ## [1] 13.25079

``` r
result$mean
```

    ## [1] 139.25

``` r
result[["sd"]]
```

    ## [1] 13.25079

### Returning a data frame

``` r
summary_row <- function(x, variable_name) {
  s <- summary_stats(x)
  data.frame(
    variable = variable_name,
    n = s$n,
    mean = s$mean,
    median = s$median,
    sd = s$sd,
    stringsAsFactors = FALSE
  )
}

summary_row(c(120, 150, NA, 145), "SBP")
```

    ##   variable n     mean median       sd
    ## 1      SBP 3 138.3333    145 16.07275

Use a list for heterogeneous outputs and a data frame for a rectangular
result that will be combined with similar results.

------------------------------------------------------------------------

## 12.14 Functions can call other functions

This is called **function composition**.

``` r
calculate_pp <- function(sbp, dbp) {
  if (!is.numeric(sbp) || !is.numeric(dbp)) stop("Inputs must be numeric")
  if (length(sbp) != length(dbp)) stop("Input lengths must match")
  sbp - dbp
}

summarize_pp <- function(sbp, dbp) {
  pp <- calculate_pp(sbp, dbp)
  summarize_measurement(pp)
}

summarize_pp(
  sbp = c(120, 150, 145),
  dbp = c(78, 94, 90)
)
```

    ## $n_total
    ## [1] 3
    ## 
    ## $n_observed
    ## [1] 3
    ## 
    ## $n_missing
    ## [1] 0
    ## 
    ## $mean
    ## [1] 51
    ## 
    ## $sd
    ## [1] 7.81025

The `summarize_pp()` function delegates the pulse-pressure calculation
to `calculate_pp()` and the descriptive summary to
`summarize_measurement()`.

This separation helps us test each part independently.

------------------------------------------------------------------------

## 12.15 Functions inside loops

Suppose we have three study sites:

``` r
study_sites <- list(
  Site_A = c(120, 145, 150),
  Site_B = c(132, NA, 148, 155),
  Site_C = c(118, 125)
)
```

We can reuse the same summary function for each site:

``` r
site_summaries <- vector("list", length(study_sites))
names(site_summaries) <- names(study_sites)

for (site in names(study_sites)) {
  site_summaries[[site]] <- summarize_measurement(study_sites[[site]])
}

site_summaries
```

    ## $Site_A
    ## $Site_A$n_total
    ## [1] 3
    ## 
    ## $Site_A$n_observed
    ## [1] 3
    ## 
    ## $Site_A$n_missing
    ## [1] 0
    ## 
    ## $Site_A$mean
    ## [1] 138.3333
    ## 
    ## $Site_A$sd
    ## [1] 16.07275
    ## 
    ## 
    ## $Site_B
    ## $Site_B$n_total
    ## [1] 4
    ## 
    ## $Site_B$n_observed
    ## [1] 3
    ## 
    ## $Site_B$n_missing
    ## [1] 1
    ## 
    ## $Site_B$mean
    ## [1] 145
    ## 
    ## $Site_B$sd
    ## [1] 11.78983
    ## 
    ## 
    ## $Site_C
    ## $Site_C$n_total
    ## [1] 2
    ## 
    ## $Site_C$n_observed
    ## [1] 2
    ## 
    ## $Site_C$n_missing
    ## [1] 0
    ## 
    ## $Site_C$mean
    ## [1] 121.5
    ## 
    ## $Site_C$sd
    ## [1] 4.949747

Or with `lapply()`:

``` r
site_summaries_apply <- lapply(study_sites, summarize_measurement)
stopifnot(identical(site_summaries, site_summaries_apply))
```

Functions and loops complement each other: the function defines **what
to do**, and the loop defines **which inputs to process**.

------------------------------------------------------------------------

## 12.16 Anonymous functions

A function does not always need a permanent name.

``` r
measurements <- list(
  A = c(10, 20, 30),
  B = c(15, NA, 25)
)

lapply(measurements, function(x) {
  mean(x, na.rm = TRUE)
})
```

    ## $A
    ## [1] 20
    ## 
    ## $B
    ## [1] 20

The function is created at the point where it is used.

### When to name a function

If the logic is scientifically meaningful, complicated, repeated, or
worth testing, give it a descriptive name. Anonymous functions are best
for short, local transformations.

------------------------------------------------------------------------

## 12.17 The `...` argument

Some functions accept additional arguments through `...` (pronounced
*dot-dot-dot*).

``` r
mean_with_options <- function(x, ...) {
  mean(x, ...)
}

mean_with_options(c(10, NA, 20), na.rm = TRUE)
```

    ## [1] 15

Here, `na.rm = TRUE` is passed to `mean()`.

This can be convenient, but excessive use of `...` can make an API
harder to understand. For beginner research utilities, explicitly named
parameters often improve clarity.

------------------------------------------------------------------------

## 12.18 Argument matching pitfalls

R can match arguments by exact name, position, and sometimes partial
name. Partial matching can make code fragile if a function’s parameters
change.

Prefer:

``` r
round(x = 3.14159, digits = 2)
```

    ## [1] 3.14

Rather than relying on abbreviated parameter names. Similarly, use named
arguments when several inputs are similar numeric vectors.

------------------------------------------------------------------------

## 12.19 Designing a biomedical eligibility function

We will create a scalar function for an **illustrative study protocol**.
Eligibility requires:

- age between 40 and 65 years, inclusive;
- observed SBP of at least 140 mmHg;
- informed consent recorded as `TRUE`;
- diabetes recorded as `FALSE`.

The function will return a **status string** rather than silently
treating missing information as a negative result.

``` r
screen_one <- function(age, sbp, consent, diabetes) {
  if (!is.numeric(age) || length(age) != 1L ||
      !is.numeric(sbp) || length(sbp) != 1L ||
      !is.logical(consent) || length(consent) != 1L ||
      !is.logical(diabetes) || length(diabetes) != 1L) {
    return("Invalid input")
  }

  if (is.na(age) || is.na(sbp) ||
      is.na(consent) || is.na(diabetes)) {
    return("Missing information")
  }

  if (!is.finite(age) || !is.finite(sbp) ||
      age < 0 || sbp <= 0) {
    return("Invalid input")
  }

  if (age >= 40 && age <= 65 && sbp >= 140 &&
      consent && !diabetes) {
    return("Eligible")
  }

  "Not eligible"
}

screen_one(52, 148, TRUE, FALSE)
```

    ## [1] "Eligible"

``` r
screen_one(52, NA_real_, TRUE, FALSE)
```

    ## [1] "Missing information"

``` r
screen_one(52, 148, FALSE, FALSE)
```

    ## [1] "Not eligible"

### Test boundary conditions

``` r
stopifnot(screen_one(40, 140, TRUE, FALSE) == "Eligible")
stopifnot(screen_one(65, 140, TRUE, FALSE) == "Eligible")
stopifnot(screen_one(39, 140, TRUE, FALSE) == "Not eligible")
stopifnot(screen_one(66, 140, TRUE, FALSE) == "Not eligible")
stopifnot(screen_one(50, -1, TRUE, FALSE) == "Invalid input")
```

### Apply to a participant table

``` r
participants <- data.frame(
  id = c("P001", "P002", "P003", "P004", "P005"),
  age = c(52, 39, 64, 45, 58),
  sbp = c(148, 150, NA, 145, 152),
  consent = c(TRUE, TRUE, TRUE, FALSE, TRUE),
  diabetes = c(FALSE, FALSE, FALSE, FALSE, TRUE)
)

participants$status <- vapply(
  seq_len(nrow(participants)),
  function(i) screen_one(
    age = participants$age[i],
    sbp = participants$sbp[i],
    consent = participants$consent[i],
    diabetes = participants$diabetes[i]
  ),
  character(1)
)

participants
```

    ##     id age sbp consent diabetes              status
    ## 1 P001  52 148    TRUE    FALSE            Eligible
    ## 2 P002  39 150    TRUE    FALSE        Not eligible
    ## 3 P003  64  NA    TRUE    FALSE Missing information
    ## 4 P004  45 145   FALSE    FALSE        Not eligible
    ## 5 P005  58 152    TRUE     TRUE        Not eligible

The output preserves missingness as a separate status and makes the
eligibility rule auditable. The thresholds do not establish clinical
diagnosis or treatment guidance.

------------------------------------------------------------------------

## 12.20 Designing a genomic QC function

GWAS summary-statistic pipelines often require repeated validation of
`BETA`, `SE`, and `PVAL`.

For a valid observed row, the Z statistic is:

$$Z = \frac{\beta}{SE}.$$

A zero or negative standard error makes this calculation invalid. We
will write a scalar function that returns both a QC status and the Z
statistic.

``` r
qc_variant <- function(beta, se, pval) {
  inputs <- list(beta = beta, se = se, pval = pval)

  valid_shape <- all(vapply(
    inputs,
    function(x) is.numeric(x) && length(x) == 1L,
    logical(1)
  ))

  if (!valid_shape) {
    return(list(status = "Invalid input", z = NA_real_))
  }
  if (anyNA(c(beta, se, pval))) {
    return(list(status = "Missing essential value", z = NA_real_))
  }
  if (!all(is.finite(c(beta, se, pval)))) {
    return(list(status = "Non-finite value", z = NA_real_))
  }
  if (se <= 0) {
    return(list(status = "Invalid standard error", z = NA_real_))
  }
  if (pval < 0 || pval > 1) {
    return(list(status = "Invalid p-value", z = NA_real_))
  }
  list(status = "Pass", z = beta / se)
}

qc_variant(0.08, 0.02, 2e-9)
```

    ## $status
    ## [1] "Pass"
    ## 
    ## $z
    ## [1] 4

``` r
qc_variant(0.08, 0, 2e-9)
```

    ## $status
    ## [1] "Invalid standard error"
    ## 
    ## $z
    ## [1] NA

``` r
qc_variant(NA_real_, 0.02, 2e-9)
```

    ## $status
    ## [1] "Missing essential value"
    ## 
    ## $z
    ## [1] NA

### Apply QC to a data frame

``` r
gwas <- data.frame(
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE"),
  CHROM = c(6L, 6L, 6L, 1L, 6L),
  POS = c(26295926L, 31298240L, 32626565L, 1500000L, 33794605L),
  BETA = c(0.05, -0.08, NA, 0.02, 0.10),
  SE = c(0.01, 0.02, 0.02, 0, 0.02),
  PVAL = c(2e-8, 3e-9, NA, 0.4, 5e-12)
)

qc_results <- lapply(seq_len(nrow(gwas)), function(i) {
  qc_variant(gwas$BETA[i], gwas$SE[i], gwas$PVAL[i])
})

gwas$QC <- vapply(qc_results, function(x) x$status, character(1))
gwas$Z <- vapply(qc_results, function(x) x$z, numeric(1))

gwas
```

    ##    ID CHROM      POS  BETA   SE  PVAL                      QC  Z
    ## 1 rsA     6 26295926  0.05 0.01 2e-08                    Pass  5
    ## 2 rsB     6 31298240 -0.08 0.02 3e-09                    Pass -4
    ## 3 rsC     6 32626565    NA 0.02    NA Missing essential value NA
    ## 4 rsD     1  1500000  0.02 0.00 4e-01  Invalid standard error NA
    ## 5 rsE     6 33794605  0.10 0.02 5e-12                    Pass  5

### Validate the outputs

``` r
passed <- gwas$QC == "Pass"
stopifnot(all(is.finite(gwas$Z[passed])))
stopifnot(all(is.na(gwas$Z[!passed])))
stopifnot(!anyDuplicated(gwas$ID))
```

This is **introductory QC**, not full GWAS harmonization. Real pipelines
also require genome-build checks, allele orientation, sample size,
imputation quality, variant identity, and other study-specific rules.

------------------------------------------------------------------------

## 12.21 Returning an entire processed data frame

We can wrap a transformation in a function and return the modified table
rather than altering a global object.

``` r
add_z_scores <- function(data) {
  if (!is.data.frame(data)) stop("Expected a data frame")
  required <- c("BETA", "SE")
  if (!all(required %in% names(data))) {
    stop("Required columns: BETA and SE")
  }
  if (!is.numeric(data$BETA) || !is.numeric(data$SE)) {
    stop("BETA and SE must be numeric")
  }

  output <- data
  output$Z <- rep(NA_real_, nrow(output))
  good <- !is.na(output$BETA) & !is.na(output$SE) &
    is.finite(output$BETA) & is.finite(output$SE) & output$SE > 0
  output$Z[good] <- output$BETA[good] / output$SE[good]
  output
}

example_gwas <- data.frame(
  ID = c("rs1", "rs2", "rs3"),
  BETA = c(0.05, NA, -0.10),
  SE = c(0.01, 0.02, 0)
)

processed_gwas <- add_z_scores(example_gwas)
processed_gwas
```

    ##    ID  BETA   SE  Z
    ## 1 rs1  0.05 0.01  5
    ## 2 rs2    NA 0.02 NA
    ## 3 rs3 -0.10 0.00 NA

``` r
example_gwas
```

    ##    ID  BETA   SE
    ## 1 rs1  0.05 0.01
    ## 2 rs2    NA 0.02
    ## 3 rs3 -0.10 0.00

Notice that the original `example_gwas` has no `Z` column. The function
returns a new data frame.

------------------------------------------------------------------------

## 12.22 Errors, warnings, and defensive programming

We should decide whether unexpected input should stop execution or
produce a documented missing result.

For example, an invalid standard error should not produce an infinite Z
statistic. The QC function returns an explicit failure status.

### Catching errors with `tryCatch()`

Sometimes we want to process many independent records without stopping
the entire workflow when one record fails.

``` r
safe_divide <- function(a, b) {
  if (!is.numeric(a) || !is.numeric(b) ||
      length(a) != 1L || length(b) != 1L) {
    stop("Inputs must be numeric scalars")
  }
  if (is.na(a) || is.na(b) || !is.finite(a) || !is.finite(b)) {
    stop("Inputs must be observed and finite")
  }
  if (b == 0) stop("Division by zero")
  a / b
}

attempt <- tryCatch(
  safe_divide(10, 0),
  error = function(e) {
    paste("Caught error:", conditionMessage(e))
  }
)

attempt
```

    ## [1] "Caught error: Division by zero"

**Important:** `tryCatch()` should not be used to silently hide
data-quality problems. We should record errors and investigate their
causes.

------------------------------------------------------------------------

## 12.23 Documenting functions

Even short functions benefit from documentation. We should state:

- what the function does;
- input names, types, units, and expected lengths;
- the meaning of defaults;
- missing-value and invalid-input policies;
- the return type and interpretation;
- important scientific assumptions.

Example:

``` r
# Calculate pulse pressure in mmHg.
# sbp: numeric vector of systolic blood pressure measurements (mmHg)
# dbp: numeric vector of diastolic blood pressure measurements (mmHg)
# Both vectors must have the same length.
# Missing input values propagate to missing output values.
# Returns: numeric vector of pulse pressure (mmHg).
calculate_pulse_pressure <- function(sbp, dbp) {
  if (!is.numeric(sbp) || !is.numeric(dbp)) {
    stop("SBP and DBP must be numeric")
  }
  if (length(sbp) != length(dbp)) {
    stop("SBP and DBP must have the same length")
  }
  sbp - dbp
}

calculate_pulse_pressure(c(120, 150), c(80, 95))
```

    ## [1] 40 55

Documentation is part of reproducibility: another researcher should be
able to understand the intended behavior without reconstructing it from
the implementation.

------------------------------------------------------------------------

## 12.24 Testing functions with base R

A function is more trustworthy when we test **ordinary**, **boundary**,
**missing**, and **invalid** inputs.

### Exact checks with `stopifnot()`

``` r
stopifnot(calculate_pulse_pressure(120, 80) == 40)
stopifnot(identical(calculate_pulse_pressure(numeric(0), numeric(0)), numeric(0)))
stopifnot(is.na(calculate_pulse_pressure(NA_real_, 80)))
```

### Floating-point checks with `all.equal()`

Computers represent many decimal numbers approximately. For calculated
numeric values, use a tolerance-aware comparison:

``` r
observed <- calculate_bmi_checked(70, 1.70)
expected <- 70 / (1.70^2)
stopifnot(isTRUE(all.equal(observed, expected)))
```

### Test an expected error

``` r
error_happened <- inherits(
  try(calculate_bmi_checked(c(70, 80), 1.70), silent = TRUE),
  "try-error"
)
stopifnot(error_happened)
```

### Test important boundaries

``` r
stopifnot(screen_one(40, 140, TRUE, FALSE) == "Eligible")
stopifnot(screen_one(65, 140, TRUE, FALSE) == "Eligible")
stopifnot(screen_one(39, 140, TRUE, FALSE) == "Not eligible")
stopifnot(screen_one(40, 139.9, TRUE, FALSE) == "Not eligible")
```

Tests do not prove that a scientific model is correct, but they help
verify that code implements the stated rules.

------------------------------------------------------------------------

## 12.25 A function for a small epidemiological summary

Suppose we want a summary of a participant-level measurement, with the
observed count and missingness clearly reported.

``` r
summarize_study_variable <- function(data, variable) {
  if (!is.data.frame(data)) stop("data must be a data frame")
  if (!is.character(variable) || length(variable) != 1L || is.na(variable)) {
    stop("variable must be one column name")
  }
  if (!variable %in% names(data)) stop("Column not found")
  x <- data[[variable]]
  if (!is.numeric(x)) stop("Selected column must be numeric")

  observed <- x[!is.na(x)]
  data.frame(
    variable = variable,
    n_total = length(x),
    n_observed = length(observed),
    n_missing = sum(is.na(x)),
    mean = if (length(observed)) mean(observed) else NA_real_,
    sd = if (length(observed) >= 2L) sd(observed) else NA_real_,
    stringsAsFactors = FALSE
  )
}

clinical <- data.frame(
  id = c("P1", "P2", "P3", "P4"),
  sbp = c(120, 145, NA, 150),
  glucose = c(92, 110, 125, NA)
)

summarize_study_variable(clinical, "sbp")
```

    ##   variable n_total n_observed n_missing     mean       sd
    ## 1      sbp       4          3         1 138.3333 16.07275

``` r
summarize_study_variable(clinical, "glucose")
```

    ##   variable n_total n_observed n_missing mean       sd
    ## 1  glucose       4          3         1  109 16.52271

### Summarize several variables

``` r
variables <- c("sbp", "glucose")
summary_rows <- lapply(variables, function(v) {
  summarize_study_variable(clinical, v)
})

summary_table <- do.call(rbind, summary_rows)
rownames(summary_table) <- NULL
summary_table
```

    ##   variable n_total n_observed n_missing     mean       sd
    ## 1      sbp       4          3         1 138.3333 16.07275
    ## 2  glucose       4          3         1 109.0000 16.52271

`do.call(rbind, ...)` combines a list of compatible data frames by rows.

------------------------------------------------------------------------

## 12.26 Function design and reproducible research

A good research function generally has the following characteristics:

1.  **One clear responsibility:** its purpose is easy to state.
2.  **Explicit inputs:** required variables and units are documented.
3.  **Predictable outputs:** return types and shapes are stable.
4.  **Validation:** malformed inputs are handled intentionally.
5.  **Minimal hidden state:** results do not depend on accidental global
    variables.
6.  **Testability:** known cases and boundaries can be checked.
7.  **Scientific transparency:** thresholds and assumptions are visible.

We should resist the temptation to create one enormous function that
imports files, cleans data, fits models, creates figures, and writes
outputs. Smaller functions are easier to test and reuse.

------------------------------------------------------------------------

## 12.27 Common mistakes

### Mistake 1: defining a function but never calling it

``` r
my_function <- function(x) x * 2
```

This defines a function. We must call `my_function(5)` to obtain a
result.

### Mistake 2: confusing parameter names and supplied values

In `calculate_change(baseline = 150, followup = 138)`, `baseline` is a
parameter name and `150` is the argument value.

### Mistake 3: relying on global variables

A function that reads an undeclared global object may produce different
results in different sessions.

### Mistake 4: forgetting to return the intended value

The last evaluated expression becomes the return value unless we use
`return()`.

### Mistake 5: using scalar `if` on a vector

`if (x > 0)` is invalid when `x > 0` has length greater than one. Use a
vectorized expression or iterate over scalar values.

### Mistake 6: ignoring unequal vector lengths

Recycling can misalign participant measurements. Validate lengths or
identifiers.

### Mistake 7: ignoring `NA`, `NaN`, or `Inf`

Define what the function should do with missing and non-finite inputs.

### Mistake 8: returning different types unpredictably

If the same function sometimes returns a number and sometimes a
character string, downstream code may become fragile. Consider returning
a structured list with a status and a value.

### Mistake 9: using `<<-` unnecessarily

Unexpected global state changes make pipelines difficult to reproduce.

### Mistake 10: treating tests as scientific validation

A passing test verifies implementation against a stated expectation; it
does not validate the underlying clinical or genomic assumptions.

------------------------------------------------------------------------

## 12.28 Guided practical: a reusable biomedical analysis toolkit

We will combine three small functions into a workflow.

### Step 1: create a study dataset

``` r
study <- data.frame(
  id = c("P001", "P002", "P003", "P004", "P005"),
  age = c(45, 58, 39, 62, 52),
  weight_kg = c(70, 84, 62, 78, 69),
  height_m = c(1.70, 1.75, 1.62, 1.68, 1.64),
  sbp = c(150, 145, 130, NA, 148),
  dbp = c(92, 90, 82, 88, 94),
  consent = c(TRUE, TRUE, TRUE, TRUE, FALSE),
  diabetes = c(FALSE, TRUE, FALSE, FALSE, FALSE)
)
```

### Step 2: calculate derived variables

``` r
study$bmi <- calculate_bmi_checked(study$weight_kg, study$height_m)
study$pulse_pressure <- calculate_pulse_pressure(study$sbp, study$dbp)
```

### Step 3: apply screening logic

``` r
study$eligibility <- vapply(
  seq_len(nrow(study)),
  function(i) screen_one(
    study$age[i], study$sbp[i],
    study$consent[i], study$diabetes[i]
  ),
  character(1)
)
```

### Step 4: summarize measurements

``` r
study_summary <- do.call(rbind, lapply(
  c("bmi", "pulse_pressure", "sbp"),
  function(v) summarize_study_variable(study, v)
))
rownames(study_summary) <- NULL
study_summary
```

    ##         variable n_total n_observed n_missing      mean       sd
    ## 1            bmi       5          5         0  25.71298 1.818758
    ## 2 pulse_pressure       5          4         1  53.75000 4.193249
    ## 3            sbp       5          4         1 143.25000 9.069179

### Step 5: inspect the final data

``` r
study[, c("id", "bmi", "pulse_pressure", "eligibility")]
```

    ##     id      bmi pulse_pressure         eligibility
    ## 1 P001 24.22145             58            Eligible
    ## 2 P002 27.42857             55        Not eligible
    ## 3 P003 23.62445             48        Not eligible
    ## 4 P004 27.63605             NA Missing information
    ## 5 P005 25.65437             54        Not eligible

### Step 6: validate

``` r
stopifnot(!anyDuplicated(study$id))
stopifnot(nrow(study_summary) == 3L)
stopifnot(length(study$eligibility) == nrow(study))
stopifnot(all(study$bmi > 0, na.rm = TRUE))
```

This workflow separates calculations, eligibility decisions, and
summaries into independently testable functions.

------------------------------------------------------------------------

## 12.29 Independent exercises: function fundamentals

1.  Write `square_number(x)` to return $x^2$.
2.  Write `cube_number(x)` to return $x^3$.
3.  Write `average_two(a, b)` and call it with positional and named
    arguments.
4.  Write `convert_cm_to_m(cm)`.
5.  Write `calculate_bmi(weight_kg, height_m)` and explain each
    parameter.
6.  Add an input check that height is positive.
7.  Explain the difference between a function definition and a function
    call.
8.  Explain implicit versus explicit return values.
9.  Create a function with a default `digits = 2` argument.
10. Explain why a function should not depend on an undeclared global
    variable.
11. Use a function on a vector and identify whether its operations are
    vectorized.
12. Write a function that rejects inputs of unequal lengths.
13. Explain why missingness policies should be documented.
14. Return a list containing both a mean and an observed count.
15. Write at least four tests for a function using `stopifnot()`.

------------------------------------------------------------------------

## 12.30 Independent exercises: biomedical and epidemiological data

Use:

``` r
exercise_patients <- data.frame(
  id = c("S1", "S2", "S3", "S4", "S5", "S6"),
  age = c(28, 45, 62, 53, 39, 70),
  sbp = c(120, 150, 145, NA, 142, 160),
  dbp = c(78, 94, 90, 85, 88, 96),
  weight_kg = c(60, 75, 82, 68, 72, 86),
  height_m = c(1.65, 1.72, 1.70, 1.63, 1.68, 1.76),
  consent = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE),
  diabetes = c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
)
```

Tasks:

1.  Write a function to calculate pulse pressure.
2.  Apply it to the whole data frame.
3.  Write a BMI function that checks equal vector lengths.
4.  Add BMI to the data frame.
5.  Write a scalar eligibility function for age 40–65, observed SBP at
    least 140, consent, and no diabetes.
6.  Apply the function to every row using `vapply()` or a loop.
7.  Preserve missing SBP as a separate screening status.
8.  Write a function returning observed count, missing count, mean, and
    standard deviation.
9.  Summarize both SBP and BMI.
10. Verify the number of output rows and the uniqueness of IDs.
11. Test eligibility at ages 40 and 65.
12. Explain why eligibility is not a diagnosis.

------------------------------------------------------------------------

## 12.31 Independent exercises: genomics

Use this synthetic GWAS table:

``` r
exercise_gwas <- data.frame(
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5", "rs6"),
  CHROM = c(6L, 6L, 1L, 6L, 2L, 6L),
  POS = c(27000000L, 31000000L, 1000000L,
          32600000L, 2000000L, 34000000L),
  BETA = c(0.04, -0.07, 0.02, NA, 0.03, 0.08),
  SE = c(0.01, 0.02, 0.01, 0.02, 0, 0.02),
  PVAL = c(1e-8, 2e-9, 0.2, NA, 0.04, 7e-10)
)
```

Tasks:

1.  Write `calculate_z(beta, se)` with appropriate validation.
2.  Return `NA_real_` when required values are missing.
3.  Reject nonpositive standard errors.
4.  Write `qc_variant(beta, se, pval)` returning status and Z.
5.  Apply the function to every row.
6.  Write a function selecting variants from a named chromosome and
    interval.
7.  Verify that the selected variants belong to the requested interval.
8.  Write a function returning the number of QC-passing variants.
9.  Test a missing p-value, a zero standard error, and an out-of-range
    p-value.
10. Explain why allele orientation and genome build are not handled by
    this introductory function.

------------------------------------------------------------------------

## 12.32 Challenge: a mini research utility library

Create a standalone R script named `research_utils.R` containing at
least four documented functions:

- `calculate_bmi_checked()`;
- `calculate_pulse_pressure()`;
- `summarize_study_variable()`;
- `qc_variant()`.

Then create a second script that loads the functions with
`source("research_utils.R")`, constructs synthetic study data, processes
them, and validates results with `stopifnot()`.

**Challenge questions:**

1.  Which functions are scalar and which are vectorized?
2.  Which return numbers, character strings, lists, or data frames?
3.  What happens with missing, empty, and invalid inputs?
4.  Which outputs depend on scientifically defined thresholds?
5.  How could we test the functions independently of the full workflow?

We will discuss organizing code into separate files in later chapters.
No external script is required to knit this chapter.

------------------------------------------------------------------------

## 12.33 Complete standalone practice script

This consolidated script is for independent practice and is not executed
during knitting because the examples above have already demonstrated the
methods.

``` r
# ============================================================
# Chapter 12: Functions in R
# Base R only
# ============================================================

calculate_bmi <- function(weight_kg, height_m) {
  if (!is.numeric(weight_kg) || !is.numeric(height_m)) {
    stop("Inputs must be numeric")
  }
  if (length(weight_kg) != length(height_m)) {
    stop("Lengths must match")
  }
  if (any(!is.na(height_m) & height_m <= 0)) {
    stop("Height must be positive")
  }
  weight_kg / height_m^2
}

summarize_numeric <- function(x) {
  if (!is.numeric(x)) stop("Expected numeric vector")
  observed <- x[!is.na(x)]
  list(
    n_total = length(x),
    n_observed = length(observed),
    mean = if (length(observed)) mean(observed) else NA_real_,
    sd = if (length(observed) >= 2L) sd(observed) else NA_real_
  )
}

qc_variant <- function(beta, se, pval) {
  if (anyNA(c(beta, se, pval))) {
    return(list(status = "Missing", z = NA_real_))
  }
  if (se <= 0 || pval < 0 || pval > 1) {
    return(list(status = "Invalid", z = NA_real_))
  }
  list(status = "Pass", z = beta / se)
}

study <- data.frame(
  id = c("P1", "P2", "P3"),
  weight_kg = c(62, 84, 71),
  height_m = c(1.62, 1.75, 1.66),
  sbp = c(118, 152, NA)
)

study$bmi <- calculate_bmi(study$weight_kg, study$height_m)
print(study)
print(summarize_numeric(study$sbp))

variants <- data.frame(
  ID = c("rs1", "rs2", "rs3"),
  BETA = c(0.05, NA, 0.10),
  SE = c(0.01, 0.02, 0),
  PVAL = c(1e-8, NA, 1e-9)
)

qc <- lapply(seq_len(nrow(variants)), function(i) {
  qc_variant(variants$BETA[i], variants$SE[i], variants$PVAL[i])
})

variants$status <- vapply(qc, function(x) x$status, character(1))
variants$Z <- vapply(qc, function(x) x$z, numeric(1))
print(variants)

stopifnot(nrow(study) == 3L)
stopifnot(!anyDuplicated(study$id))
stopifnot(all(study$bmi > 0))
```

------------------------------------------------------------------------

## 12.34 Essential functions and syntax

| Function or syntax      | Purpose                                       |
|-------------------------|-----------------------------------------------|
| `function(...) { ... }` | Define a function                             |
| `return(x)`             | Explicitly return a value                     |
| `stop()`                | Raise an error                                |
| `warning()`             | Issue a warning                               |
| `message()`             | Report information                            |
| `is.numeric()`          | Check numeric type                            |
| `is.logical()`          | Check logical type                            |
| `is.data.frame()`       | Check data-frame class                        |
| `length()`              | Check input length                            |
| `is.na()` / `anyNA()`   | Detect missing values                         |
| `is.finite()`           | Detect finite numeric values                  |
| `stopifnot()`           | Assert expected behavior                      |
| `all.equal()`           | Compare floating-point results                |
| `try()` / `tryCatch()`  | Handle errors intentionally                   |
| `lapply()`              | Apply a function and return a list            |
| `vapply()`              | Apply a function with a specified output type |
| `do.call()`             | Call a function with a list of arguments      |
| `source()`              | Execute code from another R script            |
| `...`                   | Forward additional arguments                  |

------------------------------------------------------------------------

## 12.35 Chapter review questions

1.  Why are functions useful in research projects?
2.  What is the difference between a parameter and an argument?
3.  How do positional and named arguments differ?
4.  What is a default argument?
5.  What is the difference between implicit and explicit returns?
6.  When is an early return helpful?
7.  What is a local variable?
8.  Why can reliance on global variables reduce reproducibility?
9.  What does lexical scoping mean?
10. Why should we avoid `<<-` in most introductory analysis functions?
11. How can vector recycling corrupt biomedical calculations?
12. What is the difference between a scalar and vectorized function?
13. Why is `vapply()` useful for scalar functions?
14. How can a function return several related results?
15. How should we handle missing or empty numeric inputs?
16. Why are type and length checks important?
17. What is the difference between `stop()`, `warning()`, and
    `message()`?
18. How do we test floating-point results?
19. What is a boundary test?
20. Why does a passing unit test not establish scientific validity?

## 12.36 Key takeaways

- A function packages a task into a reusable, named unit.
- Parameters describe inputs; arguments supply values when the function
  is called.
- R returns the last evaluated expression unless we use an explicit
  `return()`.
- Functions have local environments and follow lexical scoping rules.
- We should validate input types, lengths, units, and missingness
  policies.
- Scalar and vectorized functions serve different purposes.
- Lists and data frames can carry multiple results from one function.
- Functions can be composed and used in loops or apply-family calls.
- Clear documentation and boundary tests improve maintainability.
- Scientific interpretation must remain separate from the correctness of
  the code implementation.

> **Reusable research code is most valuable when its assumptions are
> explicit, its outputs are predictable, and its behavior can be
> independently tested.**

## 12.37 Looking ahead: Chapter 13 — The Apply Family

We have already used `lapply()` and `vapply()` to run functions over
collections of data. In **Chapter 13**, we will study `apply()`,
`lapply()`, `sapply()`, `vapply()`, `tapply()`, and related approaches
systematically. We will learn which functions preserve output structure,
which simplify results, and how to apply them safely to biomedical and
genomic datasets.
