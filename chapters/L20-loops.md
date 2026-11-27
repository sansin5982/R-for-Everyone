Lesson 20: Repeating Work with Loops
================
Dr. Sandeep Kumar Singh

> **The real question for today:** The Pima data have four measurement
> columns (glucose, blood pressure, skin fold, BMI). For each one we
> want the same two facts: *how many values are missing, and what is the
> mean of the rest?* Writing the same two lines four times is tedious
> and error-prone. How do we tell R “do this for each column”?

------------------------------------------------------------------------

## 1. Why this lesson matters

Real analysis repeats itself: the same check on every column, the same
summary for every hospital, the same plot for every year. A **loop** is
R’s way of doing a task once for each item in a list while you write the
instructions only once. Fewer copies of the same code means fewer typing
mistakes and a script you can trust.

------------------------------------------------------------------------

## 2. The ideas, in plain words

### 2.1 The `for` loop: a ward round

Picture a doctor on a ward round. She walks to bed 1, does the check,
moves to bed 2, does the same check, and continues until the last bed.
In R:

    for (item in collection) {
      ...do the check on item...
    }

`collection` is the list of beds, `item` is the bed she is standing at
right now, and the code in the curly braces is the check. R runs that
code once per item, each time with `item` set to the next element.

### 2.2 Collecting the results

A loop that only prints is fine for looking, but usually we want the
answers **stored**. The tidy way is to prepare an empty container of the
right size *before* the loop (like laying out an empty results table)
and fill in one slot per round.

### 2.3 Skipping and stopping: `next` and `break`

`next` means *skip the rest of this round and go to the next item*.
`break` means *stop the whole loop now*. They are the loop’s version of
“nothing to see in this bed” and “we have found what we were looking
for”.

### 2.4 The `while` loop: repeat until a condition is met

A `for` loop knows in advance how many rounds there will be. A `while`
loop keeps going **as long as a test stays TRUE**, like “keep recruiting
until we have 3 cases”. The danger is a test that never turns FALSE,
which gives an endless loop.

------------------------------------------------------------------------

## 3. The code, line by line

### 3.1 The simplest loop: visiting three districts

John Snow’s 1854 cholera table has three districts. For each, we print
the death rate per 10,000 houses.

``` r
district <- c("Southwark & Vauxhall", "Lambeth", "Rest of London")
houses   <- c(40046, 26107, 256423)
cholera_deaths <- c(1263, 98, 1422)

for (i in 1:3) {
  rate <- cholera_deaths[i] / houses[i] * 10000
  cat(district[i], ": ", round(rate, 1), " deaths per 10,000 houses\n", sep = "")
}
```

    ## Southwark & Vauxhall: 315.4 deaths per 10,000 houses
    ## Lambeth: 37.5 deaths per 10,000 houses
    ## Rest of London: 55.5 deaths per 10,000 houses

**What each line does**

- The first three lines store Snow’s real numbers as vectors (Lesson 7).
  We call the deaths vector `cholera_deaths` because the MASS package
  already contains a dataset called `deaths`, and we do not want the two
  names to clash. Position 1 of every vector belongs to the same
  district.
- `for (i in 1:3)` creates the counter `i`. In round 1, `i` is 1; in
  round 2, `i` is 2; in round 3, `i` is 3.
- `cholera_deaths[i] / houses[i] * 10000` picks the i-th deaths and the
  i-th houses (Lesson 8 indexing) and calculates the rate. Without the
  loop we would copy this line three times.
- `cat(...)` prints text and numbers on one line (Lesson 18). `"\n"`
  ends the line, and `sep = ""` stops `cat` from adding extra spaces.

**How to read the output:** Southwark & Vauxhall had 315.4 cholera
deaths per 10,000 houses, Lambeth 37.5 and the rest of London 55.5. Same
code, three answers, and the 8-fold gap between the first two is the
heart of Snow’s argument about the Southwark & Vauxhall water supply.

### 3.2 Why `1:3` is risky, and `seq_along()` is safe

Typing `1:3` only works because we know there are exactly 3 districts.
If the vector later had 4 or 0 items, the loop would be wrong. Better:

``` r
for (i in seq_along(district)) {
  cat("Round", i, "->", district[i], "\n")
}
```

    ## Round 1 -> Southwark & Vauxhall 
    ## Round 2 -> Lambeth 
    ## Round 3 -> Rest of London

`seq_along(district)` means “the positions 1, 2, … up to the length of
`district`”, whatever that length is. It even handles an empty vector
correctly (zero rounds), where `1:length(x)` would wrongly count `1, 0`.
Get into the habit of `seq_along()`.

### 3.3 Looping over columns and storing the results

Now the question from the start of the lesson.

``` r
library(MASS)
pima <- Pima.tr2

cols <- c("glu", "bp", "skin", "bmi")

n_missing <- numeric(length(cols))   # empty slots for the counts
col_mean  <- numeric(length(cols))   # empty slots for the means

for (i in seq_along(cols)) {
  x <- pima[[cols[i]]]                       # the i-th column as a vector
  n_missing[i] <- sum(is.na(x))              # how many are missing
  col_mean[i]  <- mean(x, na.rm = TRUE)      # mean of the rest
}

result <- data.frame(column = cols, n_missing = n_missing,
                     mean = round(col_mean, 2))
result
```

    ##   column n_missing   mean
    ## 1    glu         0 123.74
    ## 2     bp        13  72.32
    ## 3   skin        98  29.15
    ## 4    bmi         3  32.05

**What each line does**

- `cols` is the list of column **names** we want to visit.
- `numeric(length(cols))` makes a vector of four zeros, the empty slots
  prepared before the loop. Preparing the container first is faster and
  keeps the code tidy.
- `pima[[cols[i]]]` is the new piece. `cols[i]` is a name such as
  `"glu"`, and the **double square brackets** `[[ ]]` pull out the
  column with that name as a plain vector. (`pima$cols[i]` would not
  work, because `$` looks for a column literally called `cols`.)
- `sum(is.na(x))` counts missing values: `is.na()` gives TRUE/FALSE and
  `sum()` adds the TRUEs (Lesson 9).
- `mean(x, na.rm = TRUE)` is the mean with the missing values left out.
- Each result goes into slot `i` of its container with
  `n_missing[i] <-`.
- `data.frame(...)` finally gathers the three vectors into one tidy
  table (Lesson 14).

**How to read the output:** skin fold is missing for 98 of the 300
women, blood pressure for 13, BMI for 3 and glucose for none. That tells
us at once that any analysis using skin fold thickness will lose a third
of the women, something we should know **before** modelling.

### 3.4 `next`: skip the babies we do not care about

Among rows 126 to 140 of `birthwt`, list only the babies with low birth
weight, using `next` to skip everyone else.

``` r
for (i in 126:140) {
  if (birthwt$bwt[i] >= 2500) {
    next                                  # normal weight: skip to the next baby
  }
  cat("Baby in row", i, "weighed", birthwt$bwt[i], "g\n")
}
```

    ## Baby in row 131 weighed 709 g
    ## Baby in row 132 weighed 1021 g
    ## Baby in row 133 weighed 1135 g
    ## Baby in row 134 weighed 1330 g
    ## Baby in row 135 weighed 1474 g
    ## Baby in row 136 weighed 1588 g
    ## Baby in row 137 weighed 1588 g
    ## Baby in row 138 weighed 1701 g
    ## Baby in row 139 weighed 1729 g
    ## Baby in row 140 weighed 1790 g

**What happens:** for each baby R tests the weight. If it is 2500 g or
more, `next` ends that round immediately, so `cat` is never reached.
Only low birth weight babies get printed, and the five normal-weight
babies in rows 126 to 130 are skipped silently. Why do the skips stop
exactly at row 130? Because this dataset is **sorted**: rows 1 to 130
are the normal weight babies and rows 131 to 189 are the low birth
weight babies, each group in increasing order of weight. This is a
real-data lesson. The “first few rows” of a file are not always a random
sample, so never judge a dataset by `head()` alone.

### 3.5 `break`: stop when we find what we want

``` r
first_very_low <- NA

for (i in seq_len(nrow(birthwt))) {
  if (birthwt$bwt[i] < 1500) {
    first_very_low <- i
    break                                 # found one, stop the loop
  }
}

first_very_low
```

    ## [1] 131

``` r
birthwt$bwt[first_very_low]
```

    ## [1] 709

- `seq_len(nrow(birthwt))` is `1, 2, ... 189`, the safe way to say
  “every row” (`nrow` is the number of rows).
- We start with `NA` (“not found yet”). When the test finds a baby under
  1500 g, we save the row number and `break` ends the loop, so R does
  not waste time checking the remaining babies.

**How to read the output:** the loop stops at row 131, the very first
low birth weight baby in the sorted file, and the last line shows that
baby weighed 709 g, the lightest in the study. (Because the low group is
sorted lightest first, the first match is also the minimum.)

### 3.6 `while`: keep going until a target is reached

How many babies, taken in the order of the file, do we need to look at
until we have seen 10 low birth weight babies?

``` r
seen_low <- 0     # low birth weight babies seen so far
row      <- 0     # how many babies we have looked at

while (seen_low < 10) {
  row <- row + 1                          # look at the next baby
  if (birthwt$bwt[row] < 2500) {
    seen_low <- seen_low + 1
  }
}

row
```

    ## [1] 140

``` r
seen_low
```

    ## [1] 10

**What each line does**

- Two counters start at zero.
- `while (seen_low < 10)` means *repeat the braces as long as we have
  fewer than 10 low-weight babies*. R checks this test **before every
  round**.
- `row <- row + 1` moves to the next baby. This line is essential: it is
  what makes progress. If we forgot to change anything the test depends
  on, the loop would never end.
- Inside, an `if` adds 1 to `seen_low` whenever the baby is low.

**How to read the output:** R had to look at 140 babies to find 10
low-weight ones. Since rows 1 to 130 are all normal weight, the ten low
ones are rows 131 to 140, which is exactly what the sorted order from
the last section predicts. `seen_low` confirms we stopped at exactly 10.

### 3.7 When you do *not* need a loop

A beginner’s loop often does what R can do in one vectorised step.

``` r
colMeans(pima[, cols], na.rm = TRUE)    # same four means, no loop
```

    ##       glu        bp      skin       bmi 
    ## 123.74333  72.32056  29.15347  32.05286

``` r
colSums(is.na(pima[, cols]))            # same four missing counts, no loop
```

    ##  glu   bp skin  bmi 
    ##    0   13   98    3

Both lines give exactly what Section 3.3 gave, in one line each.
`colMeans()` and `colSums()` run the calculation down every column.

**The rule of thumb:** use a vectorised function when one exists. Use a
loop when each round **depends on the previous one** (like our `while`
counters), when you must **stop early** (`break`), or when each round
does something that has no ready-made vector function, such as reading a
different file each time. In the next two lessons you will meet tools
that make many loops unnecessary.

------------------------------------------------------------------------

## 4. Common errors and how to read them

| What you see | What it means | Fix |
|----|----|----|
| R keeps running and the console shows no prompt | An endless `while` loop: the test never became FALSE | Press **Esc** (RStudio stop button); make sure something inside the loop changes the tested value |
| `subscript out of bounds` or `NA` in the results | The counter went past the end of the data | Use `seq_along(x)` or `seq_len(n)` instead of typing the number |
| Results vector has `NA` for the first slots only | You forgot to fill all slots, or the loop started at the wrong number | Print `i` inside the loop to see what ran |
| `Error: object 'cols' not found` inside `pima$cols[i]` | `$` takes a literal name, not a variable | Use `pima[[cols[i]]]` |
| Loop prints nothing at the console | Inside a loop, results are **not** auto-printed | Use `print()` or `cat()` inside the loop |

------------------------------------------------------------------------

## 5. Practice

1.  Loop over the three Snow districts and print the **percentage of
    houses** that had a cholera death, `cholera_deaths / houses * 100`,
    rounded to 2 decimals.
2.  Using `birthwt`, loop over the columns `"age"`, `"lwt"` and `"bwt"`
    and print the **maximum** of each.
3.  Write a `while` loop that adds up birth weights, baby by baby, and
    stops once the total passes 50,000 g. How many babies were needed?
4.  Replace the loop in question 2 with a single vectorised line.

<details>

<summary>

Show answers
</summary>

``` r
# 1
for (i in seq_along(district)) {
  pct <- cholera_deaths[i] / houses[i] * 100
  cat(district[i], ":", round(pct, 2), "%\n")
}
```

    ## Southwark & Vauxhall : 3.15 %
    ## Lambeth : 0.38 %
    ## Rest of London : 0.55 %

``` r
# 2
for (v in c("age", "lwt", "bwt")) {
  cat(v, "max =", max(birthwt[[v]]), "\n")
}
```

    ## age max = 45 
    ## lwt max = 250 
    ## bwt max = 4990

``` r
# 3
total <- 0
n <- 0
while (total <= 50000) {
  n <- n + 1
  total <- total + birthwt$bwt[n]
}
n
```

    ## [1] 19

``` r
total
```

    ## [1] 50910

``` r
# 4
sapply(birthwt[, c("age", "lwt", "bwt")], max)   # a preview of Lesson 22
```

    ##  age  lwt  bwt 
    ##   45  250 4990

``` r
apply(birthwt[, c("age", "lwt", "bwt")], 2, max)
```

    ##  age  lwt  bwt 
    ##   45  250 4990

</details>

------------------------------------------------------------------------

## 6. Recap

- `for (item in collection) { ... }` repeats the same steps for each
  item; use `seq_along()` or `seq_len()` for the counter.
- Prepare an empty container first, fill one slot per round, then build
  a data frame.
- `[[ ]]` picks a column by a name stored in a variable.
- `next` skips a round; `break` ends the loop; `while` repeats until a
  test turns FALSE.
- If a vectorised function exists (`colMeans`, `colSums`), use it.

## 7. What comes next

Our loops are still copies of the same logic. In **Lesson 21** we wrap
logic into our own **functions**, so one named tool can be reused on any
column, any dataset and any district.

**My own idea for you:** take a script you have written in any language
and find one place where you copied the same lines more than twice. Try
turning that into a loop here, then into a function in Lesson 21. This
“spot the copy” habit is the quickest route from beginner to fluent.
