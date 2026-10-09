Loops: for, while, and repeat
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 10, we used `if`, `else`, and `ifelse()` to make decisions.
We now learn how to **repeat** instructions. Repetition is central to
research: calculating a summary for each participant, checking every
variant, processing multiple chromosomes, and iteratively updating an
estimate.

A **loop** runs a block of code repeatedly. R provides three main loop
structures:

- `for`: repeat over a known sequence of items;
- `while`: repeat while a condition remains true;
- `repeat`: repeat indefinitely until an explicit `break`.

We will use **base R only**, with small, synthetic datasets and
reproducible examples. All executable chunks are intended to run
independently in chapter order. No external data or packages are needed.

## 11.1 Learning objectives

After this chapter, we should be able to:

1.  Explain the purpose and execution order of loops.
2.  Write `for` loops over vectors, indices, names, and list elements.
3.  Use `seq_along()` and `seq_len()` safely.
4.  Allocate result containers before looping.
5.  Use `next` to skip an iteration and `break` to exit a loop.
6.  Use `while` and `repeat` with explicit stopping conditions.
7.  Avoid infinite loops and off-by-one errors.
8.  Combine loops with conditional statements and missing-value checks.
9.  Understand nested loops and multidimensional indexing.
10. Compare explicit loops with vectorization and the apply family.
11. Develop practical biomedical and genomic quality-control workflows.
12. Validate loop outputs against known results.

------------------------------------------------------------------------

## 11.2 Why do we need loops?

Suppose systolic blood pressure (SBP) has been measured in five
participants:

``` r
sbp <- c(120, 150, 145, 115, 142)
sbp
```

    ## [1] 120 150 145 115 142

We could print every measurement separately:

``` r
print(sbp[1])
```

    ## [1] 120

``` r
print(sbp[2])
```

    ## [1] 150

``` r
print(sbp[3])
```

    ## [1] 145

``` r
print(sbp[4])
```

    ## [1] 115

``` r
print(sbp[5])
```

    ## [1] 142

But this approach does not scale to hundreds of participants. A loop
expresses the repetition once:

``` r
for (value in sbp) {
  print(value)
}
```

    ## [1] 120
    ## [1] 150
    ## [1] 145
    ## [1] 115
    ## [1] 142

R assigns each element of `sbp` to `value`, executes the block, and
moves to the next element.

**Key distinction:** A loop describes a *process*, whereas vectorized
functions often describe a *calculation* directly. We will learn both
approaches.

## 11.3 Anatomy of a `for` loop

The general syntax is:

``` r
for (item in sequence) {
  statements
}
```

Consider:

``` r
for (i in 1:4) {
  cat("Iteration:", i, "\n")
}
```

    ## Iteration: 1 
    ## Iteration: 2 
    ## Iteration: 3 
    ## Iteration: 4

Step-by-step:

1.  R creates the sequence `1, 2, 3, 4`.
2.  It assigns `1` to `i` and executes the body.
3.  It assigns `2` to `i` and executes the body again.
4.  It repeats for `3` and `4`.
5.  The loop ends when the sequence is exhausted.

The braces `{ }` enclose all statements belonging to the loop.

### A small arithmetic example

``` r
for (i in 1:5) {
  cat(i, "squared is", i^2, "\n")
}
```

    ## 1 squared is 1 
    ## 2 squared is 4 
    ## 3 squared is 9 
    ## 4 squared is 16 
    ## 5 squared is 25

The operator `^` performs exponentiation. Thus, $3^2=9$.

------------------------------------------------------------------------

## 11.4 Looping over values versus positions

There are two common ways to traverse a vector.

### Directly over values

``` r
sbp <- c(120, 150, 145, 115, 142)

for (reading in sbp) {
  cat("SBP:", reading, "mmHg\n")
}
```

    ## SBP: 120 mmHg
    ## SBP: 150 mmHg
    ## SBP: 145 mmHg
    ## SBP: 115 mmHg
    ## SBP: 142 mmHg

Here, `reading` is the measurement itself.

### Over positions

``` r
for (i in seq_along(sbp)) {
  cat("Position", i, "has SBP", sbp[i], "\n")
}
```

    ## Position 1 has SBP 120 
    ## Position 2 has SBP 150 
    ## Position 3 has SBP 145 
    ## Position 4 has SBP 115 
    ## Position 5 has SBP 142

Here, `i` is the **index**. This is useful when we need to refer to
another aligned vector, assign output values, or track patient IDs.

``` r
patient_id <- c("P001", "P002", "P003", "P004", "P005")

for (i in seq_along(sbp)) {
  cat(patient_id[i], ":", sbp[i], "mmHg\n")
}
```

    ## P001 : 120 mmHg
    ## P002 : 150 mmHg
    ## P003 : 145 mmHg
    ## P004 : 115 mmHg
    ## P005 : 142 mmHg

### When to use each form

Loop over values when only the values matter. Loop over indices when
positions, paired vectors, or output assignments matter.

------------------------------------------------------------------------

## 11.5 `seq_along()` versus `1:length()`

A subtle but important error occurs with empty vectors.

``` r
empty <- numeric(0)
length(empty)
```

    ## [1] 0

The expression `1:length(empty)` does **not** produce an empty sequence:

``` r
1:length(empty)
```

    ## [1] 1 0

It produces `1 0`, which can cause invalid indexing.

Use:

``` r
seq_along(empty)
```

    ## integer(0)

This produces `integer(0)` and executes no iterations.

``` r
for (i in seq_along(empty)) {
  print(i)
}
```

No output is expected.

### `seq_len()` when a count is known

``` r
seq_len(5)
```

    ## [1] 1 2 3 4 5

``` r
seq_len(0)
```

    ## integer(0)

For row-wise work:

``` r
for (i in seq_len(nrow(data))) {
  # Process row i
}
```

`seq_len(0)` is empty, unlike `1:0`.

**Research programming rule:** Prefer `seq_along(x)` for a vector and
`seq_len(n)` for a count.

------------------------------------------------------------------------

## 11.6 Saving results: preallocation

Printing is useful for demonstration, but research analysis generally
requires stored outputs.

Suppose we want pulse pressure:

$$PP_i = SBP_i - DBP_i.$$

``` r
sbp <- c(120, 150, 145, 115, 142)
dbp <- c(78, 94, 90, 75, 88)
```

First, create an output vector of the correct length:

``` r
pulse_pressure <- numeric(length(sbp))
pulse_pressure
```

    ## [1] 0 0 0 0 0

Then fill it:

``` r
for (i in seq_along(sbp)) {
  pulse_pressure[i] <- sbp[i] - dbp[i]
}

pulse_pressure
```

    ## [1] 42 56 55 40 54

We can verify the result using vectorized arithmetic:

``` r
stopifnot(identical(pulse_pressure, sbp - dbp))
```

### Why preallocate?

Growing a vector repeatedly can trigger memory reallocations and
copying:

``` r
result <- c()
for (i in seq_len(1000)) {
  result <- c(result, i^2)
}
```

This is a valid illustration but not the preferred pattern for large
computations.

Better:

``` r
squares <- numeric(1000)

for (i in seq_len(1000)) {
  squares[i] <- i^2
}

head(squares)
```

    ## [1]  1  4  9 16 25 36

``` r
tail(squares)
```

    ## [1]  990025  992016  994009  996004  998001 1000000

For a known number of results, preallocation improves clarity and can
improve performance.

------------------------------------------------------------------------

## 11.7 Choosing an appropriate output type

We should preallocate the type that matches the intended result.

``` r
numeric_result <- numeric(5)
logical_result <- logical(5)
character_result <- character(5)
integer_result <- integer(5)

typeof(numeric_result)
```

    ## [1] "double"

``` r
typeof(logical_result)
```

    ## [1] "logical"

``` r
typeof(character_result)
```

    ## [1] "character"

``` r
typeof(integer_result)
```

    ## [1] "integer"

For an output that may contain missing numeric values, initialize with
`NA_real_`:

``` r
result <- rep(NA_real_, 5)
result
```

    ## [1] NA NA NA NA NA

This is often more informative than initializing to zero because zero
may be a legitimate measurement.

------------------------------------------------------------------------

## 11.8 Combining `for` with `if` and `else`

We can classify each SBP measurement using the illustrative study
threshold of 140 mmHg.

``` r
sbp <- c(120, 150, 145, 115, 142)
status <- character(length(sbp))

for (i in seq_along(sbp)) {
  if (sbp[i] >= 140) {
    status[i] <- "Review"
  } else {
    status[i] <- "Below threshold"
  }
}

status
```

    ## [1] "Below threshold" "Review"          "Review"          "Below threshold"
    ## [5] "Review"

The loop handles one value at a time, so each `if` condition has length
one.

### Equivalent vectorized solution

``` r
status_vectorized <- ifelse(
  sbp >= 140,
  "Review",
  "Below threshold"
)

identical(status, status_vectorized)
```

    ## [1] TRUE

Both produce the same classification for these nonmissing values.

**Interpretation:** `"Review"` is a programming label, not a clinical
diagnosis.

------------------------------------------------------------------------

## 11.9 Missing values in a loop

Consider:

``` r
sbp_missing <- c(120, 150, NA, 115, 142)
```

This code would fail on the missing measurement:

``` r
for (i in seq_along(sbp_missing)) {
  if (sbp_missing[i] >= 140) {
    print("Review")
  }
}
```

The comparison `NA >= 140` is `NA`, but `if` requires exactly one
nonmissing logical value.

### Safe version

``` r
status_missing <- character(length(sbp_missing))

for (i in seq_along(sbp_missing)) {
  if (is.na(sbp_missing[i])) {
    status_missing[i] <- "Missing"
  } else if (sbp_missing[i] >= 140) {
    status_missing[i] <- "Review"
  } else {
    status_missing[i] <- "Below threshold"
  }
}

status_missing
```

    ## [1] "Below threshold" "Review"          "Missing"         "Below threshold"
    ## [5] "Review"

**Principle:** Decide how to handle missing data *before* evaluating
thresholds.

------------------------------------------------------------------------

## 11.10 Using `next`: skip an iteration

`next` immediately ends the current iteration and moves to the next one.

Suppose we want to calculate a mean only from observed values.

``` r
values <- c(10, NA, 20, 30, NA, 40)

total <- 0
count <- 0L

for (x in values) {
  if (is.na(x)) {
    next
  }

  total <- total + x
  count <- count + 1L
}

observed_mean <- total / count
observed_mean
```

    ## [1] 25

Check:

``` r
mean(values, na.rm = TRUE)
```

    ## [1] 25

``` r
stopifnot(isTRUE(all.equal(observed_mean, mean(values, na.rm = TRUE))))
```

### Why use `next`?

It makes an exclusion rule explicit. We skip missing observations
without adding them to the total or denominator.

### Edge case: all values missing

If `count` is zero, `total / count` would be undefined. A robust
implementation checks:

``` r
all_missing <- c(NA_real_, NA_real_)

total <- 0
count <- 0L

for (x in all_missing) {
  if (is.na(x)) next
  total <- total + x
  count <- count + 1L
}

safe_mean <- if (count == 0L) NA_real_ else total / count
safe_mean
```

    ## [1] NA

------------------------------------------------------------------------

## 11.11 Using `break`: exit the loop

`break` stops the entire loop immediately.

Suppose we want to locate the **first** SBP value at least 150 mmHg:

``` r
sbp <- c(120, 145, 152, 158, 130)
first_position <- NA_integer_

for (i in seq_along(sbp)) {
  if (sbp[i] >= 150) {
    first_position <- i
    break
  }
}

first_position
```

    ## [1] 3

``` r
sbp[first_position]
```

    ## [1] 152

Once R finds the first matching value, it stops searching.

### Difference between `next` and `break`

- `next`: skip the remainder of **this iteration**.
- `break`: stop **the whole loop**.

We should not confuse these operations.

------------------------------------------------------------------------

## 11.12 Looping over character values

Loops are not restricted to numbers.

``` r
tissues <- c("Brain_Cortex", "Whole_Blood", "Liver")

for (tissue in tissues) {
  cat("Processing tissue:", tissue, "\n")
}
```

    ## Processing tissue: Brain_Cortex 
    ## Processing tissue: Whole_Blood 
    ## Processing tissue: Liver

This pattern is useful when processing a fixed collection of study
sites, tissues, chromosomes, or analysis domains.

### Named vectors

``` r
sample_counts <- c(
  Brain_Cortex = 200,
  Whole_Blood = 500,
  Liver = 150
)

for (tissue in names(sample_counts)) {
  cat(tissue, "has", sample_counts[[tissue]], "samples\n")
}
```

    ## Brain_Cortex has 200 samples
    ## Whole_Blood has 500 samples
    ## Liver has 150 samples

We use `[[tissue]]` to access the value corresponding to the current
name.

------------------------------------------------------------------------

## 11.13 Looping through a data frame

A data frame is a list of equal-length columns. We can loop over rows or
columns.

``` r
patients <- data.frame(
  id = c("P001", "P002", "P003", "P004"),
  age = c(35, 52, 61, 44),
  sbp = c(120, 150, NA, 145),
  dbp = c(78, 92, 88, 90),
  consent = c(TRUE, TRUE, TRUE, FALSE)
)

patients
```

    ##     id age sbp dbp consent
    ## 1 P001  35 120  78    TRUE
    ## 2 P002  52 150  92    TRUE
    ## 3 P003  61  NA  88    TRUE
    ## 4 P004  44 145  90   FALSE

### Row-wise processing

``` r
patients$pp <- rep(NA_real_, nrow(patients))

for (i in seq_len(nrow(patients))) {
  if (!is.na(patients$sbp[i]) && !is.na(patients$dbp[i])) {
    patients$pp[i] <- patients$sbp[i] - patients$dbp[i]
  }
}

patients[, c("id", "sbp", "dbp", "pp")]
```

    ##     id sbp dbp pp
    ## 1 P001 120  78 42
    ## 2 P002 150  92 58
    ## 3 P003  NA  88 NA
    ## 4 P004 145  90 55

### Column-wise processing

Suppose we want missing-value counts for each column:

``` r
missing_counts <- integer(ncol(patients))
names(missing_counts) <- names(patients)

for (j in seq_along(patients)) {
  missing_counts[j] <- sum(is.na(patients[[j]]))
}

missing_counts
```

    ##      id     age     sbp     dbp consent      pp 
    ##       0       0       1       0       0       1

Compare with the vectorized built-in approach:

``` r
stopifnot(isTRUE(all.equal(
  unname(missing_counts),
  unname(colSums(is.na(patients)))
)))
```

For this task, `colSums(is.na(...))` is simpler. The loop teaches how
the calculation works.

------------------------------------------------------------------------

## 11.14 Looping through lists

Lists can contain objects of different types.

``` r
study_results <- list(
  Cortex = c(0.8, 0.9, 0.7),
  Blood = c(0.6, 0.5),
  Liver = c(0.75, 0.80, 0.85, 0.90)
)

means <- numeric(length(study_results))
names(means) <- names(study_results)

for (tissue in names(study_results)) {
  means[tissue] <- mean(study_results[[tissue]])
}

means
```

    ## Cortex  Blood  Liver 
    ##  0.800  0.550  0.825

The list elements can have different lengths, so a list is a natural
structure.

### Check with `sapply()`

``` r
sapply(study_results, mean)
```

    ## Cortex  Blood  Liver 
    ##  0.800  0.550  0.825

In Chapter 13, we will examine the apply family in detail.

------------------------------------------------------------------------

## 11.15 Nested loops: one loop inside another

A **nested loop** executes an inner loop for every iteration of an outer
loop.

Suppose we have three genes and two tissues:

``` r
genes <- c("Gene_A", "Gene_B", "Gene_C")
tissues <- c("Cortex", "Blood")
```

We want to print every gene–tissue combination:

``` r
for (gene in genes) {
  for (tissue in tissues) {
    cat(gene, "-", tissue, "\n")
  }
}
```

    ## Gene_A - Cortex 
    ## Gene_A - Blood 
    ## Gene_B - Cortex 
    ## Gene_B - Blood 
    ## Gene_C - Cortex 
    ## Gene_C - Blood

There are:

$$3 \times 2 = 6$$

combinations.

### Order of execution

The outer loop selects `Gene_A`. The inner loop processes both tissues.
Then the outer loop selects `Gene_B`, and the inner loop runs again.

Nested loops are useful for matrices, arrays, parameter grids, and
repeated analyses across groups.

------------------------------------------------------------------------

## 11.16 Filling a matrix with nested loops

Suppose rows represent genes and columns represent participants.

``` r
expr <- matrix(
  NA_real_,
  nrow = 3,
  ncol = 4,
  dimnames = list(
    Gene = c("G1", "G2", "G3"),
    Participant = c("P1", "P2", "P3", "P4")
  )
)
```

For demonstration, define a synthetic value:

$$X_{ij}=2i+j$$

where $i$ is the gene index and $j$ is the participant index.

``` r
for (i in seq_len(nrow(expr))) {
  for (j in seq_len(ncol(expr))) {
    expr[i, j] <- 2 * i + j
  }
}

expr
```

    ##     Participant
    ## Gene P1 P2 P3 P4
    ##   G1  3  4  5  6
    ##   G2  5  6  7  8
    ##   G3  7  8  9 10

For gene 2 and participant 3:

$$X_{2,3}=2(2)+3=7.$$

``` r
expr[2, 3]
```

    ## [1] 7

### Validate the result

``` r
stopifnot(expr[2, 3] == 7)
stopifnot(all(dim(expr) == c(3, 4)))
```

------------------------------------------------------------------------

## 11.17 Nested loops for three-dimensional arrays

An array can contain genes, participants, and visits.

``` r
measurements <- array(
  NA_real_,
  dim = c(2, 3, 2),
  dimnames = list(
    Gene = c("G1", "G2"),
    Participant = c("P1", "P2", "P3"),
    Visit = c("Baseline", "Followup")
  )
)
```

For teaching, let:

$$X_{ijk}=i+2j+3k.$$

``` r
for (i in seq_len(dim(measurements)[1])) {
  for (j in seq_len(dim(measurements)[2])) {
    for (k in seq_len(dim(measurements)[3])) {
      measurements[i, j, k] <- i + 2*j + 3*k
    }
  }
}

measurements
```

    ## , , Visit = Baseline
    ## 
    ##     Participant
    ## Gene P1 P2 P3
    ##   G1  6  8 10
    ##   G2  7  9 11
    ## 
    ## , , Visit = Followup
    ## 
    ##     Participant
    ## Gene P1 P2 P3
    ##   G1  9 11 13
    ##   G2 10 12 14

### Extract a visit

``` r
measurements[, , "Baseline"]
```

    ##     Participant
    ## Gene P1 P2 P3
    ##   G1  6  8 10
    ##   G2  7  9 11

``` r
measurements[, , "Followup"]
```

    ##     Participant
    ## Gene P1 P2 P3
    ##   G1  9 11 13
    ##   G2 10 12 14

### Check a value manually

For $i=2$, $j=3$, and $k=2$:

$$X_{2,3,2}=2+2(3)+3(2)=14.$$

``` r
stopifnot(measurements[2, 3, 2] == 14)
```

In real expression data, we do not invent values with a formula; the
example simply illustrates indexing.

------------------------------------------------------------------------

## 11.18 The `while` loop

A `while` loop repeats **as long as** its condition is true.

``` r
while (condition) {
  statements
}
```

Example:

``` r
counter <- 1L

while (counter <= 5L) {
  cat("Counter:", counter, "\n")
  counter <- counter + 1L
}
```

    ## Counter: 1 
    ## Counter: 2 
    ## Counter: 3 
    ## Counter: 4 
    ## Counter: 5

The loop ends when `counter` becomes 6.

### Why the update is essential

If we never update `counter`, the condition may remain true
indefinitely.

This code is **not executed**:

``` r
counter <- 1
while (counter <= 5) {
  print(counter)
  # Missing counter update: infinite loop
}
```

**Safety rule:** Every `while` loop needs a credible path to a false
condition, preferably with a maximum-iteration safeguard for research
computations.

------------------------------------------------------------------------

## 11.19 A biomedical `while` example: threshold crossing

Suppose a synthetic biomarker starts at 100 units and decreases by 10%
per iteration. We want to know how many iterations are required to fall
below 50 units.

The update rule is:

$$B_{t+1}=0.9B_t.$$

``` r
biomarker <- 100
iteration <- 0L
max_iterations <- 100L

while (biomarker >= 50 && iteration < max_iterations) {
  biomarker <- biomarker * 0.9
  iteration <- iteration + 1L
}

iteration
```

    ## [1] 7

``` r
biomarker
```

    ## [1] 47.82969

Check:

``` r
stopifnot(biomarker < 50)
stopifnot(iteration <= max_iterations)
```

This is a mathematical teaching model, **not** a model of actual drug
response or clinical biomarker kinetics.

### Why add `max_iterations`?

Even if the threshold is never reached, the loop will terminate after a
defined maximum number of iterations.

------------------------------------------------------------------------

## 11.20 The `repeat` loop

A `repeat` loop continues until `break` is executed.

``` r
repeat {
  statements
  if (stopping_condition) {
    break
  }
}
```

Example:

``` r
counter <- 0L

repeat {
  counter <- counter + 1L
  cat("Iteration", counter, "\n")

  if (counter >= 4L) {
    break
  }
}
```

    ## Iteration 1 
    ## Iteration 2 
    ## Iteration 3 
    ## Iteration 4

Unlike `while`, `repeat` does not test a condition before the first
iteration.

### When is `repeat` useful?

It is useful when the stopping condition is naturally evaluated
**after** an update, such as iterative optimization.

We should always include a clear termination condition.

------------------------------------------------------------------------

## 11.21 Iterative estimation example

Suppose we want to approximate $\sqrt{2}$ using Newton’s method:

$$x_{t+1}=\frac{1}{2}\left(x_t+\frac{2}{x_t}\right).$$

Start with $x_0=1$ and stop when the absolute change is less than
$10^{-8}$, or when 100 iterations have occurred.

``` r
estimate <- 1
tolerance <- 1e-8
max_iterations <- 100L
iteration <- 0L

repeat {
  new_estimate <- 0.5 * (estimate + 2 / estimate)
  iteration <- iteration + 1L

  if (abs(new_estimate - estimate) < tolerance) {
    estimate <- new_estimate
    break
  }

  estimate <- new_estimate

  if (iteration >= max_iterations) {
    warning("Maximum iterations reached before convergence.")
    break
  }
}

estimate
```

    ## [1] 1.414214

``` r
iteration
```

    ## [1] 5

Verify:

``` r
stopifnot(isTRUE(all.equal(estimate, sqrt(2), tolerance = 1e-7)))
```

This introduces an important idea used in statistical algorithms:
**iterative updates plus a convergence criterion**.

------------------------------------------------------------------------

## 11.22 Choosing between `for`, `while`, and `repeat`

| Structure | Main question | Typical use |
|----|----|----|
| `for` | Which items must be processed? | Participants, variants, chromosomes, tissues |
| `while` | Is the condition still true? | Iterate until a threshold or limit |
| `repeat` | Should we stop after this update? | Iterative numerical algorithms |

For most introductory data-processing tasks, `for` is the simplest
choice.

------------------------------------------------------------------------

## 11.23 Accumulators and running totals

An **accumulator** stores a running result.

``` r
values <- c(2, 4, 6, 8)
running_total <- 0

for (x in values) {
  running_total <- running_total + x
  cat("Current total:", running_total, "\n")
}
```

    ## Current total: 2 
    ## Current total: 6 
    ## Current total: 12 
    ## Current total: 20

``` r
running_total
```

    ## [1] 20

Mathematically:

$$S_n=\sum_{i=1}^{n}x_i.$$

Verify:

``` r
stopifnot(running_total == sum(values))
```

### Running means

``` r
values <- c(10, 20, 30, 40)
running_mean <- numeric(length(values))
total <- 0

for (i in seq_along(values)) {
  total <- total + values[i]
  running_mean[i] <- total / i
}

running_mean
```

    ## [1] 10 15 20 25

The result is 10, 15, 20, and 25.

``` r
stopifnot(identical(running_mean, c(10, 15, 20, 25)))
```

------------------------------------------------------------------------

## 11.24 Counting events

Suppose we want to count SBP readings meeting an illustrative threshold.

``` r
sbp <- c(120, 150, 145, 115, 142)
count_high <- 0L

for (x in sbp) {
  if (x >= 140) {
    count_high <- count_high + 1L
  }
}

count_high
```

    ## [1] 3

Check against a vectorized expression:

``` r
sum(sbp >= 140)
```

    ## [1] 3

``` r
stopifnot(count_high == sum(sbp >= 140))
```

### With missing values

``` r
sbp <- c(120, 150, NA, 115, 142)
count_high <- 0L

for (x in sbp) {
  if (is.na(x)) next
  if (x >= 140) count_high <- count_high + 1L
}

count_high
```

    ## [1] 2

Again, we explicitly decide to exclude missing values from this count.

------------------------------------------------------------------------

## 11.25 Creating a result table from a loop

We can calculate participant-level BMI using:

$$BMI=\frac{\text{weight (kg)}}{[\text{height (m)}]^2}.$$

``` r
participants <- data.frame(
  id = c("P001", "P002", "P003", "P004"),
  weight_kg = c(62, 84, 71, 79),
  height_m = c(1.62, 1.75, 1.66, 1.70)
)

participants$bmi <- rep(NA_real_, nrow(participants))

for (i in seq_len(nrow(participants))) {
  weight <- participants$weight_kg[i]
  height <- participants$height_m[i]

  if (is.na(weight) || is.na(height) || height <= 0) {
    next
  }

  participants$bmi[i] <- weight / height^2
}

participants
```

    ##     id weight_kg height_m      bmi
    ## 1 P001        62     1.62 23.62445
    ## 2 P002        84     1.75 27.42857
    ## 3 P003        71     1.66 25.76571
    ## 4 P004        79     1.70 27.33564

Validate against vectorization:

``` r
expected_bmi <- participants$weight_kg / participants$height_m^2
stopifnot(isTRUE(all.equal(participants$bmi, expected_bmi)))
```

The loop is pedagogical. In routine R code, direct vectorized arithmetic
is usually preferable for this calculation.

------------------------------------------------------------------------

## 11.26 Loops and the apply family

In Chapter 8, we used `lapply()` and `sapply()`. We can compare them
with a loop.

``` r
tissue_values <- list(
  Cortex = c(5, 6, 7),
  Blood = c(3, 4, 5),
  Liver = c(8, 9, 10)
)
```

### Explicit loop

``` r
loop_means <- numeric(length(tissue_values))
names(loop_means) <- names(tissue_values)

for (name in names(tissue_values)) {
  loop_means[name] <- mean(tissue_values[[name]])
}

loop_means
```

    ## Cortex  Blood  Liver 
    ##      6      4      9

### `sapply()`

``` r
apply_means <- sapply(tissue_values, mean)
apply_means
```

    ## Cortex  Blood  Liver 
    ##      6      4      9

Check:

``` r
stopifnot(identical(loop_means, apply_means))
```

Neither method is universally better. The apply family is concise for
straightforward transformations; loops can be clearer when there are
multiple operations, branches, or explicit state updates.

------------------------------------------------------------------------

## 11.27 Vectorization versus loops

R supports operations on entire vectors:

``` r
x <- 1:5
x^2
```

    ## [1]  1  4  9 16 25

This avoids writing:

``` r
out <- numeric(length(x))
for (i in seq_along(x)) {
  out[i] <- x[i]^2
}
out
```

    ## [1]  1  4  9 16 25

For many simple numerical operations, vectorized expressions are more
concise and often faster.

### When a loop is still appropriate

Loops are valuable when:

- each iteration involves several steps;
- decisions depend on earlier results;
- a numerical algorithm requires convergence checks;
- files must be processed one by one;
- each iteration produces a complex result;
- explicit control flow improves readability.

We should not replace clear, validated loops with complicated
vectorization merely to avoid the word `for`.

------------------------------------------------------------------------

## 11.28 A genomics example: filtering by chromosome

Suppose a synthetic GWAS dataset contains variants from several
chromosomes.

``` r
gwas <- data.frame(
  CHROM = c(1L, 6L, 2L, 6L, 1L, 6L, 2L),
  POS = c(120000L, 26295926L, 220000L,
          31298240L, 150000L, 32626565L, 250000L),
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5", "rs6", "rs7"),
  BETA = c(0.01, 0.05, -0.02, -0.08, 0.03, 0.12, 0.02),
  SE = c(0.01, 0.01, 0.02, 0.02, 0.01, 0.02, 0.02),
  PVAL = c(0.2, 2e-8, 0.3, 3e-9, 0.04, 5e-12, 0.5)
)

gwas
```

    ##   CHROM      POS  ID  BETA   SE  PVAL
    ## 1     1   120000 rs1  0.01 0.01 2e-01
    ## 2     6 26295926 rs2  0.05 0.01 2e-08
    ## 3     2   220000 rs3 -0.02 0.02 3e-01
    ## 4     6 31298240 rs4 -0.08 0.02 3e-09
    ## 5     1   150000 rs5  0.03 0.01 4e-02
    ## 6     6 32626565 rs6  0.12 0.02 5e-12
    ## 7     2   250000 rs7  0.02 0.02 5e-01

These values are illustrative and not actual association results.

We want a list of chromosome-specific tables.

``` r
chromosomes <- sort(unique(gwas$CHROM))
by_chr <- vector("list", length(chromosomes))
names(by_chr) <- paste0("chr", chromosomes)

for (i in seq_along(chromosomes)) {
  chr <- chromosomes[i]
  by_chr[[i]] <- gwas[
    gwas$CHROM == chr,
    ,
    drop = FALSE
  ]
}

names(by_chr)
```

    ## [1] "chr1" "chr2" "chr6"

``` r
sapply(by_chr, nrow)
```

    ## chr1 chr2 chr6 
    ##    2    2    3

Inspect chromosome 6:

``` r
by_chr[["chr6"]]
```

    ##   CHROM      POS  ID  BETA   SE  PVAL
    ## 2     6 26295926 rs2  0.05 0.01 2e-08
    ## 4     6 31298240 rs4 -0.08 0.02 3e-09
    ## 6     6 32626565 rs6  0.12 0.02 5e-12

### Validate

``` r
stopifnot(sum(sapply(by_chr, nrow)) == nrow(gwas))
stopifnot(all(by_chr[["chr6"]]$CHROM == 6))
```

This structure is useful when downstream analysis must run separately
for each chromosome.

------------------------------------------------------------------------

## 11.29 A genomics example: QC for each variant

We will check whether each variant has valid values for `BETA`, `SE`,
and `PVAL`.

``` r
gwas_qc <- data.frame(
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE"),
  BETA = c(0.05, -0.08, NA, 0.03, 0.10),
  SE = c(0.01, 0.02, 0.02, 0, 0.02),
  PVAL = c(2e-8, 3e-9, NA, 1e-5, 2e-10)
)

gwas_qc$qc_status <- character(nrow(gwas_qc))
gwas_qc$Z <- rep(NA_real_, nrow(gwas_qc))
```

Apply checks in a specified order:

``` r
for (i in seq_len(nrow(gwas_qc))) {
  beta <- gwas_qc$BETA[i]
  se <- gwas_qc$SE[i]
  p <- gwas_qc$PVAL[i]

  if (is.na(beta) || is.na(se) || is.na(p)) {
    gwas_qc$qc_status[i] <- "Missing essential value"
    next
  }

  if (!is.finite(beta) || !is.finite(se) || !is.finite(p)) {
    gwas_qc$qc_status[i] <- "Non-finite value"
    next
  }

  if (se <= 0) {
    gwas_qc$qc_status[i] <- "Invalid standard error"
    next
  }

  if (p < 0 || p > 1) {
    gwas_qc$qc_status[i] <- "Invalid p-value"
    next
  }

  gwas_qc$qc_status[i] <- "Pass"
  gwas_qc$Z[i] <- beta / se
}

gwas_qc
```

    ##    ID  BETA   SE  PVAL               qc_status  Z
    ## 1 rsA  0.05 0.01 2e-08                    Pass  5
    ## 2 rsB -0.08 0.02 3e-09                    Pass -4
    ## 3 rsC    NA 0.02    NA Missing essential value NA
    ## 4 rsD  0.03 0.00 1e-05  Invalid standard error NA
    ## 5 rsE  0.10 0.02 2e-10                    Pass  5

### Why `next` is helpful

When a variant fails a check, we record the first failure reason and
move to the next variant. This prevents division by zero and avoids
calculating Z from missing inputs.

### Validation

``` r
pass <- gwas_qc$qc_status == "Pass"
stopifnot(all(is.finite(gwas_qc$Z[pass])))
stopifnot(all(is.na(gwas_qc$Z[!pass])))
```

**Scientific limitation:** Real GWAS QC also requires allele
harmonization, genome-build verification, imputation-quality assessment,
sample-size checks, and other study-specific criteria. This example
teaches loop control, not a complete QC protocol.

------------------------------------------------------------------------

## 11.30 Nested loops: gene-by-tissue summary

Consider a small gene-expression array:

``` r
expression <- array(
  c(5.1, 6.2, 5.5, 6.4,
    4.8, 6.0, 5.2, 6.1,
    7.0, 8.1, 7.3, 8.2),
  dim = c(2, 2, 3),
  dimnames = list(
    Gene = c("G1", "G2"),
    Sample = c("S1", "S2"),
    Tissue = c("Cortex", "Blood", "Liver")
  )
)
```

For each gene and tissue, calculate the mean across samples.

``` r
gene_tissue_mean <- matrix(
  NA_real_,
  nrow = dim(expression)[1],
  ncol = dim(expression)[3],
  dimnames = list(
    Gene = dimnames(expression)[[1]],
    Tissue = dimnames(expression)[[3]]
  )
)

for (g in seq_len(dim(expression)[1])) {
  for (t in seq_len(dim(expression)[3])) {
    gene_tissue_mean[g, t] <- mean(
      expression[g, , t],
      na.rm = TRUE
    )
  }
}

gene_tissue_mean
```

    ##     Tissue
    ## Gene Cortex Blood Liver
    ##   G1    5.3  5.00  7.15
    ##   G2    6.3  6.05  8.15

Compare with `apply()`:

``` r
apply_result <- apply(expression, c(1, 3), mean, na.rm = TRUE)
stopifnot(isTRUE(all.equal(gene_tissue_mean, apply_result)))
```

**Note:** This synthetic array assumes that its sample dimension is
meaningful across tissues. Real multi-tissue datasets often require more
complex structures and sample harmonization.

------------------------------------------------------------------------

## 11.31 Iterating over file names without external files

In a real workflow, we may need to process several chromosome-specific
files.

Here we will **construct file names only**. No external files are
required.

``` r
chromosomes <- 1:5
filenames <- character(length(chromosomes))

for (i in seq_along(chromosomes)) {
  filenames[i] <- paste0(
    "chr", chromosomes[i], "_summary_stats.tsv.gz"
  )
}

filenames
```

    ## [1] "chr1_summary_stats.tsv.gz" "chr2_summary_stats.tsv.gz"
    ## [3] "chr3_summary_stats.tsv.gz" "chr4_summary_stats.tsv.gz"
    ## [5] "chr5_summary_stats.tsv.gz"

A real script would validate existence with `file.exists()` and then
read each file. We should not assume files exist merely because names
have been constructed.

``` r
file.exists(filenames)
```

    ## [1] FALSE FALSE FALSE FALSE FALSE

The result will depend on the working directory. This chapter does not
attempt to open any of these files.

------------------------------------------------------------------------

## 11.32 Progress reporting

For long-running work, progress messages help identify where an analysis
stopped.

``` r
tasks <- c("Load", "Validate", "Filter", "Summarize")

for (i in seq_along(tasks)) {
  cat(
    sprintf("Step %d of %d: %s\n",
            i, length(tasks), tasks[i])
  )
}
```

    ## Step 1 of 4: Load
    ## Step 2 of 4: Validate
    ## Step 3 of 4: Filter
    ## Step 4 of 4: Summarize

`sprintf()` formats a string; `%d` represents an integer and `%s`
represents text.

In production scripts, progress reporting should not expose sensitive
participant-level information.

------------------------------------------------------------------------

## 11.33 Common mistakes and corrections

### Mistake 1: using `1:length(x)` for an empty vector

Use `seq_along(x)`.

### Mistake 2: growing output vectors unnecessarily

Preallocate with `numeric()`, `character()`, `logical()`, or
`vector("list", n)`.

### Mistake 3: forgetting to update a `while` loop counter

Ensure that the condition can become false, and include a
maximum-iteration safeguard.

### Mistake 4: forgetting `break` in a `repeat` loop

Every `repeat` loop needs an explicit exit path.

### Mistake 5: confusing `next` with `break`

`next` skips the current iteration; `break` ends the loop.

### Mistake 6: failing to handle `NA` before an `if` test

Use `is.na()` or another appropriate missingness policy.

### Mistake 7: indexing past the end of a vector

Prefer `seq_along(x)` or `seq_len(n)` and validate lengths.

### Mistake 8: accidentally overwriting an input object

Use descriptive names for loop variables and outputs. Avoid reusing a
dataset name as a temporary scalar.

### Mistake 9: forgetting `drop = FALSE`

When subsetting a data frame to one column, or a matrix to one row, the
result may simplify unexpectedly.

### Mistake 10: comparing misaligned vectors

Ensure participant IDs, gene names, and other identifiers correspond
before applying element-wise calculations.

### Mistake 11: ignoring empty groups

A loop may encounter a group with zero observations. Check length before
calculating statistics that require data.

### Mistake 12: assuming loops are always slower or always worse

Clear, preallocated loops can be effective. Use vectorized functions
where they express the calculation naturally.

------------------------------------------------------------------------

## 11.34 Guided practical: longitudinal blood-pressure change

We will analyze a small synthetic dataset with baseline and follow-up
SBP measurements.

### Step 1: create the dataset

``` r
followup <- data.frame(
  id = c("P001", "P002", "P003", "P004", "P005"),
  baseline_sbp = c(150, 142, 155, 138, 160),
  followup_sbp = c(142, 139, NA, 132, 148)
)

followup
```

    ##     id baseline_sbp followup_sbp
    ## 1 P001          150          142
    ## 2 P002          142          139
    ## 3 P003          155           NA
    ## 4 P004          138          132
    ## 5 P005          160          148

### Step 2: preallocate changes and labels

``` r
followup$change <- rep(NA_real_, nrow(followup))
followup$direction <- character(nrow(followup))
```

### Step 3: calculate changes in a loop

Define:

$$\Delta SBP_i=SBP_{i,\mathrm{followup}}-SBP_{i,\mathrm{baseline}}.$$

``` r
for (i in seq_len(nrow(followup))) {
  baseline <- followup$baseline_sbp[i]
  later <- followup$followup_sbp[i]

  if (is.na(baseline) || is.na(later)) {
    followup$direction[i] <- "Missing"
    next
  }

  delta <- later - baseline
  followup$change[i] <- delta

  if (delta < 0) {
    followup$direction[i] <- "Decrease"
  } else if (delta > 0) {
    followup$direction[i] <- "Increase"
  } else {
    followup$direction[i] <- "No change"
  }
}

followup
```

    ##     id baseline_sbp followup_sbp change direction
    ## 1 P001          150          142     -8  Decrease
    ## 2 P002          142          139     -3  Decrease
    ## 3 P003          155           NA     NA   Missing
    ## 4 P004          138          132     -6  Decrease
    ## 5 P005          160          148    -12  Decrease

### Step 4: summarize the observed changes

``` r
mean(followup$change, na.rm = TRUE)
```

    ## [1] -7.25

``` r
sum(followup$direction == "Decrease")
```

    ## [1] 4

``` r
table(followup$direction)
```

    ## 
    ## Decrease  Missing 
    ##        4        1

### Step 5: validate against vectorized arithmetic

``` r
expected_change <- followup$followup_sbp -
  followup$baseline_sbp

stopifnot(isTRUE(all.equal(
  followup$change,
  expected_change
)))
```

### Interpretation

These are descriptive within-person differences. Without a suitable
study design and analysis, we cannot attribute them to an intervention.

------------------------------------------------------------------------

## 11.35 Independent exercises: fundamentals

Use:

``` r
practice_sbp <- c(118, 145, NA, 152, 130, 160)
practice_dbp <- c(76, 90, 84, 96, 82, 98)
```

1.  Print every SBP value using a `for` loop.
2.  Print the position and value of every SBP measurement.
3.  Explain why `seq_along(practice_sbp)` is preferable to
    `1:length(practice_sbp)`.
4.  Preallocate a numeric vector for pulse pressure.
5.  Calculate pulse pressure with a loop; preserve `NA` where SBP is
    missing.
6.  Count observed SBP values at least 140 using a loop.
7.  Find the position of the first observed SBP at least 150; use
    `break`.
8.  Use `next` to skip missing measurements.
9.  Create a character vector with `"Missing"`, `"Review"`, or
    `"Below threshold"`.
10. Verify the classification using `ifelse()`.
11. Calculate the mean of observed SBP values with an accumulator.
12. Compare the result with `mean(practice_sbp, na.rm = TRUE)`.

------------------------------------------------------------------------

## 11.36 Independent exercises: `while` and `repeat`

1.  Use `while` to print integers from 1 through 10.
2.  Use `while` to calculate the sum of integers 1 through 100.
3.  Explain what makes a `while` loop infinite.
4.  Start with 200 and multiply by 0.8 each iteration until the value is
    below 50.
5.  Add a maximum of 100 iterations to the previous task.
6.  Use `repeat` to print the numbers 1 through 5.
7.  Use `repeat` to update $x_{t+1}=(x_t+3/x_t)/2$ until convergence.
8.  Compare the resulting estimate with `sqrt(3)`.
9.  Explain why a tolerance and a maximum-iteration limit are both
    useful.
10. Explain one situation where `for` is more suitable than `while`.

------------------------------------------------------------------------

## 11.37 Independent exercises: genomics

Use:

``` r
practice_gwas <- data.frame(
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5", "rs6"),
  CHROM = c(6L, 6L, 1L, 6L, 2L, 6L),
  POS = c(27000000L, 31000000L, 1000000L,
          32600000L, 2000000L, 34000000L),
  BETA = c(0.04, -0.07, 0.02, NA, 0.03, 0.08),
  SE = c(0.01, 0.02, 0.01, 0.02, 0, 0.02),
  PVAL = c(1e-8, 2e-9, 0.2, NA, 0.04, 7e-10)
)
```

1.  Loop over all rows and print variant IDs.
2.  Count variants on chromosome 6 using a loop.
3.  Create a logical flag for variants within chr6:25–34 Mb inclusive.
4.  Preallocate a `Z` column initialized with `NA_real_`.
5.  Calculate `Z = BETA/SE` only when `BETA`, `SE`, and `PVAL` are
    observed and `SE > 0`.
6.  Record a QC failure reason for every variant not meeting these
    criteria.
7.  Use `next` to skip invalid variants.
8.  Split the table into a named list by chromosome.
9.  Verify that the total number of rows across the list equals the
    original row count.
10. Explain why this exercise does not replace full GWAS QC and
    harmonization.

------------------------------------------------------------------------

## 11.38 Challenge: a small iterative QC pipeline

Develop a script that processes a list of three synthetic study tables:

``` r
study_tables <- list(
  Study_A = data.frame(id = c("A1", "A2"), sbp = c(120, 145)),
  Study_B = data.frame(id = c("B1", "B2", "B3"), sbp = c(NA, 150, 138)),
  Study_C = data.frame(id = c("C1"), sbp = 160)
)
```

Requirements:

1.  Loop over study names.
2.  Validate that each table contains `id` and `sbp`.
3.  Count total rows, observed SBP values, and missing SBP values.
4.  Count observed SBP values at least 140.
5.  Store one summary row per study.
6.  Combine summaries into a single data frame.
7.  Verify that the sum of study-level counts equals the corresponding
    totals across all records.
8.  Handle a study with zero rows without using `1:nrow(data)`.
9.  Explain why the screening threshold is not equivalent to a clinical
    diagnosis.
10. Compare the loop approach with `lapply()`.

------------------------------------------------------------------------

## 11.39 Complete standalone practice script

The following script consolidates the main techniques. It is **not
executed during knitting**, since the individual examples already run
above.

``` r
# Chapter 11 — Loops: for, while, repeat
# Base R only

# 1. Preallocated loop
sbp <- c(120, 150, NA, 115, 142)
dbp <- c(78, 94, 90, 75, 88)

pp <- rep(NA_real_, length(sbp))
status <- character(length(sbp))

for (i in seq_along(sbp)) {
  if (is.na(sbp[i]) || is.na(dbp[i])) {
    status[i] <- "Missing"
    next
  }

  pp[i] <- sbp[i] - dbp[i]

  if (sbp[i] >= 140) {
    status[i] <- "Review"
  } else {
    status[i] <- "Below threshold"
  }
}

print(pp)
print(status)

# 2. First matching observation
first_high <- NA_integer_

for (i in seq_along(sbp)) {
  if (is.na(sbp[i])) next

  if (sbp[i] >= 150) {
    first_high <- i
    break
  }
}

print(first_high)

# 3. while loop
value <- 100
iteration <- 0L

while (value >= 50 && iteration < 100L) {
  value <- value * 0.9
  iteration <- iteration + 1L
}

print(c(value = value, iterations = iteration))

# 4. repeat loop
estimate <- 1
iteration <- 0L

repeat {
  updated <- 0.5 * (estimate + 2 / estimate)
  iteration <- iteration + 1L

  if (abs(updated - estimate) < 1e-8) {
    estimate <- updated
    break
  }

  estimate <- updated

  if (iteration >= 100L) break
}

print(estimate)

# 5. Genomic QC
gwas <- data.frame(
  ID = c("rs1", "rs2", "rs3"),
  BETA = c(0.05, NA, 0.1),
  SE = c(0.01, 0.02, 0),
  PVAL = c(1e-8, NA, 1e-9)
)

gwas$Z <- rep(NA_real_, nrow(gwas))
gwas$QC <- character(nrow(gwas))

for (i in seq_len(nrow(gwas))) {
  if (anyNA(gwas[i, c("BETA", "SE", "PVAL")])) {
    gwas$QC[i] <- "Missing"
    next
  }

  if (gwas$SE[i] <= 0) {
    gwas$QC[i] <- "Invalid SE"
    next
  }

  gwas$QC[i] <- "Pass"
  gwas$Z[i] <- gwas$BETA[i] / gwas$SE[i]
}

print(gwas)
```

------------------------------------------------------------------------

## 11.40 Essential functions and keywords

| Syntax                      | Purpose                               |
|-----------------------------|---------------------------------------|
| `for (x in items) { ... }`  | Iterate over items                    |
| `while (condition) { ... }` | Repeat while true                     |
| `repeat { ... }`            | Repeat until explicitly stopped       |
| `break`                     | Exit a loop                           |
| `next`                      | Skip to the next iteration            |
| `seq_along(x)`              | Safe index sequence for a vector      |
| `seq_len(n)`                | Safe sequence of `n` indices          |
| `numeric(n)`                | Preallocate numeric output            |
| `character(n)`              | Preallocate character output          |
| `logical(n)`                | Preallocate logical output            |
| `vector("list", n)`         | Preallocate list output               |
| `length(x)`                 | Count vector elements                 |
| `nrow(x)`                   | Count data-frame or matrix rows       |
| `is.na(x)`                  | Detect missing values                 |
| `which(x)`                  | Return positions of true elements     |
| `cat()`                     | Print formatted text                  |
| `sprintf()`                 | Format strings                        |
| `stopifnot()`               | Assert assumptions                    |
| `lapply()` / `sapply()`     | Apply a function over list elements   |
| `apply()`                   | Apply a function across array margins |

------------------------------------------------------------------------

## 11.41 Chapter review

We should now be able to explain:

1.  What a loop does and when it is useful.
2.  The difference between looping over values and indices.
3.  Why `seq_along()` is safer than `1:length()`.
4.  How to preallocate results.
5.  Why preallocation can reduce repeated memory allocation.
6.  What `next` and `break` do.
7.  How to handle missing measurements in an `if` statement inside a
    loop.
8.  How a `while` loop stops.
9.  Why `repeat` requires `break`.
10. How a maximum-iteration safeguard works.
11. How to calculate a running total and mean.
12. How nested loops map to matrices and arrays.
13. How to loop over a list of tissue-specific measurements.
14. How to loop over a data frame by rows or columns.
15. How to split GWAS records by chromosome.
16. How to store variant-level QC reasons.
17. When vectorized operations are preferable.
18. When explicit loops are clearer.
19. Why scientific identifiers must remain aligned.
20. How to validate loop output against a known reference result.

## 11.42 Key takeaways

- A `for` loop is appropriate when the sequence of items is known.
- A `while` loop repeats until its condition becomes false.
- A `repeat` loop needs an explicit `break`.
- Use `seq_along()` and `seq_len()` for safe indexing, including empty
  inputs.
- Preallocate output containers before large loops.
- Use `next` to skip a record and `break` to stop processing.
- Handle missing data and invalid values explicitly.
- Nested loops can process matrices, arrays, and parameter combinations.
- Vectorization and apply functions are often concise alternatives, but
  explicit loops remain useful.
- Every loop-based research workflow should have clear stopping rules,
  validated inputs, and checked outputs.

> **A reliable loop is not merely one that finishes. It is one that
> processes the intended observations, preserves their identities,
> handles exceptional cases, and produces verifiable results.**

## 11.43 Looking ahead: Chapter 12 — Functions

Loops help us repeat code. But repeating the *same logic in several
parts of a project* creates another problem: code duplication.

In **Chapter 12 — Functions**, we will learn to package reusable
analysis steps into functions with inputs, outputs, defaults, and
validation. We will create functions for BMI calculation, participant
screening, summary statistics, and genomic quality control.
