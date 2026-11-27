Lesson 21: Writing Your Own Functions
================
Dr. Sandeep Kumar Singh

> **The real question for today:** In Snow’s table we calculated a death
> rate per 10,000 houses. Tomorrow a colleague wants a rate per 1,000
> *people* for another outbreak. Next week the same calculation is
> needed for a different disease. Do we copy and edit the same line
> again and again, or do we build **one reliable tool** and reuse it
> everywhere?

------------------------------------------------------------------------

## 1. Why this lesson matters

Every function you have used so far (`mean`, `table`, `cut`) was written
by someone else. Writing your own gives you three things at once:

- **Less repetition.** The logic lives in one place.
- **Fewer mistakes.** Fix a bug once and it is fixed everywhere.
- **Readable scripts.** `rate_per(cases, population)` tells the reader
  what is happening; a long formula does not.

------------------------------------------------------------------------

## 2. The ideas, in plain words

### 2.1 A function is a machine you build

In Lesson 4 we pictured a function as a machine: ingredients go in
(**arguments**), something happens inside, and a result comes out (the
**return value**). Now we build the machine ourselves. Think of a recipe
card for chapati dough: *flour, water, salt* are the arguments, the
steps are the body, and the dough is the result. Anyone with the card
can make dough without knowing who wrote it.

### 2.2 The anatomy

    name <- function(argument1, argument2 = default) {
      ...steps...
      result          # the last value is what the function returns
    }

- `name <-` stores the function like any other object (Lesson 3).
- `function(...)` lists the arguments, the inputs.
- An argument written `argument2 = default` is **optional**: if you do
  not supply it, the default is used.
- The curly braces hold the steps. The **last line** is the value that
  comes back; `return(value)` does the same thing explicitly.

### 2.3 Scope: the kitchen rule

Everything created *inside* a function lives in its own small kitchen.
When the function finishes, the kitchen is cleared away. Only the
returned result leaves. This protects your main workspace from stray
temporary objects.

### 2.4 Guard rails: checking the input

A good function complains clearly when given something silly, such as
text where numbers are required. `stop("message")` ends the function
with an error message you wrote yourself.

------------------------------------------------------------------------

## 3. The code, line by line

### 3.1 Our first function: a rate

``` r
rate_per <- function(cases, population, per = 10000) {
  cases / population * per
}

rate_per(1263, 40046)
```

    ## [1] 315.3873

**What each line does**

- `rate_per <- function(cases, population, per = 10000)` creates the
  function. It has three arguments; `per` has the default 10000, so it
  is optional.
- `cases / population * per` is the calculation. It is the last (and
  only) line, so its value is returned.
- `rate_per(1263, 40046)` **calls** the function. R matches the values
  to the arguments by position: 1263 is `cases`, 40046 is `population`,
  and `per` uses its default.

**How to read the output:** 315.39 deaths per 10,000 houses in Southwark
& Vauxhall (the 315.4 of Lesson 20, which we had rounded), but now in
one short call.

### 3.2 Named arguments and changing a default

``` r
rate_per(cases = 98, population = 26107, per = 1000)   # all named
```

    ## [1] 3.753783

``` r
rate_per(98, 26107, per = 1000)                        # first two by position
```

    ## [1] 3.753783

When you write `argument = value`, the order no longer matters and the
code explains itself. The two calls above give the same answer: 3.75
deaths per 1,000 houses in Lambeth. Use names for anything beyond the
first one or two arguments.

### 3.3 It works on whole vectors too

``` r
houses         <- c(40046, 26107, 256423)
cholera_deaths <- c(1263, 98, 1422)

rate_per(cholera_deaths, houses)
```

    ## [1] 315.38730  37.53783  55.45524

Because `/` and `*` are vectorised (Lesson 7), our function handles
three districts in one call, with no loop. Writing functions out of
vectorised pieces gives you this for free.

### 3.4 The rate ratio, a function that calls a function

``` r
rate_ratio <- function(cases1, pop1, cases2, pop2) {
  rate_per(cases1, pop1) / rate_per(cases2, pop2)
}

round(rate_ratio(1263, 40046, 98, 26107), 1)
```

    ## [1] 8.4

A function can use another function. This one divides the Southwark &
Vauxhall rate by the Lambeth rate: houses supplied by one water company
had about **8.4 times** the death rate of houses supplied by the other.
Building small tools and combining them is how large analyses stay
understandable.

### 3.5 A function for percentages, handling missing values

Many questions have the form “what percentage of rows satisfy a test?”

``` r
percent <- function(test) {
  round(100 * mean(test, na.rm = TRUE), 1)
}

library(MASS)
percent(birthwt$bwt < 2500)            # % low birth weight
```

    ## [1] 31.2

``` r
percent(birthwt$smoke == 1)            # % mothers who smoked
```

    ## [1] 39.2

``` r
percent(Pima.tr2$bmi >= 30)            # % obese range, NAs ignored
```

    ## [1] 62

**What each line does**

- `test` is expected to be a vector of TRUE/FALSE, such as the result of
  `bwt < 2500`.
- `mean(test)` of TRUE/FALSE is the **proportion of TRUEs** (TRUE counts
  as 1, FALSE as 0), so `100 * mean(...)` is a percentage.
- `na.rm = TRUE` drops the missing values first, which matters for BMI.
- `round(..., 1)` keeps one decimal place.
- Each call passes in a *different* test; the same machine answers three
  different questions.

**How to read the output:** 31.2% of babies were low birth weight, 39.2%
of mothers smoked, and 62.0% of the women with a measured BMI were in
the obese range. The first matches Lesson 18.

### 3.6 Returning several results at once

A function returns **one** object, but that object can hold many values.

``` r
describe <- function(x) {
  c(n       = length(x),
    missing = sum(is.na(x)),
    mean    = round(mean(x, na.rm = TRUE), 2),
    sd      = round(sd(x, na.rm = TRUE), 2),
    median  = median(x, na.rm = TRUE))
}

describe(birthwt$bwt)
```

    ##       n missing    mean      sd  median 
    ##  189.00    0.00 2944.59  729.21 2977.00

``` r
describe(Pima.tr2$skin)
```

    ##       n missing    mean      sd  median 
    ##  300.00   98.00   29.15   11.68   29.00

- `c(...)` builds a vector (Lesson 7) and each piece is **named**
  (`n =`, `missing =`, …), so the output labels itself.
- `length(x)` counts all values, `sum(is.na(x))` counts the missing
  ones, and the rest are the summary numbers from Lesson 10.

**How to read the output:** for birth weight there are 189 values, none
missing, mean 2944.59 g, SD 729.21 g and median 2977 g. For skin fold
there are 300 values, 98 missing, and the summaries are based on the 202
that remain. The function makes that fact impossible to overlook.

### 3.7 Guard rails with `stop()`

``` r
describe_safe <- function(x) {
  if (!is.numeric(x)) {
    stop("describe_safe() needs numbers, but x is of class ", class(x)[1])
  }
  describe(x)
}

describe_safe(birthwt$bwt)        # fine
```

    ##       n missing    mean      sd  median 
    ##  189.00    0.00 2944.59  729.21 2977.00

``` r
describe_safe(Pima.tr2$type)      # a factor: should stop with our message
```

    ## Error in `describe_safe()`:
    ## ! describe_safe() needs numbers, but x is of class factor

**What each line does**

- `is.numeric(x)` is TRUE for numbers. The `!` in front **flips** TRUE
  and FALSE, so the `if` fires when `x` is *not* numeric.
- `stop("...", class(x)[1])` ends the function and prints our message,
  joining the text with the actual class of the input.
- The first call works; the second one, `type`, is a factor (diabetes
  yes/no), so R stops with a clear explanation instead of a confusing
  error or a meaningless mean.

### 3.8 Scope: the kitchen is cleared

``` r
double_it <- function(x) {
  temp <- x * 2          # temp exists only inside the function
  temp
}

double_it(21)
```

    ## [1] 42

``` r
temp                     # the kitchen has been cleared away
```

    ## Error:
    ## ! object 'temp' not found

`temp` was created inside `double_it`. Once the function finished it
disappeared, so asking for it at the console gives *object ‘temp’ not
found*. That is **good**: temporary objects cannot pollute or overwrite
your real data. (A function can *read* objects from outside, but it
should receive them as arguments so the code is easy to follow.)

### 3.9 Using our function in a loop

Combining Lessons 20 and 21: a summary table for the four Pima
measurement columns, using one function call per column.

``` r
cols <- c("glu", "bp", "skin", "bmi")

summary_table <- matrix(NA, nrow = length(cols), ncol = 5,
                        dimnames = list(cols,
                          c("n", "missing", "mean", "sd", "median")))

for (i in seq_along(cols)) {
  summary_table[i, ] <- describe(Pima.tr2[[cols[i]]])
}

summary_table
```

    ##        n missing   mean    sd median
    ## glu  300       0 123.74 30.01    121
    ## bp   300      13  72.32 11.70     72
    ## skin 300      98  29.15 11.68     29
    ## bmi  300       3  32.05  6.49     32

The loop body is now a single line, because the hard work lives in
`describe()`. Compare this with Lesson 20, where the loop had to contain
every calculation. In Lesson 22 you will see how to do even this without
writing the loop.

### 3.10 Keeping functions in their own file: `source()`

When a function proves useful, save it in a plain `.R` file and load it
at the top of every script, the way you load a package.

``` r
helper_file <- file.path(tempdir(), "helpers.R")   # a temporary file for the demo

writeLines(c(
  "rate_per <- function(cases, population, per = 10000) {",
  "  cases / population * per",
  "}"
), helper_file)

rm(rate_per)                  # delete our function from the workspace
exists("rate_per")            # FALSE: it is gone
```

    ## [1] FALSE

``` r
source(helper_file)           # read the file and run it
exists("rate_per")            # TRUE: it is back
```

    ## [1] TRUE

``` r
rate_per(98, 26107)
```

    ## [1] 37.53783

In a real project the file would sit in your `scripts/` folder (Lesson
17) and you would write `source("scripts/helpers.R")`. All your analyses
then share exactly the same, tested version of each function.

------------------------------------------------------------------------

## 4. Common errors and how to read them

| What you see | What it means | Fix |
|----|----|----|
| `could not find function "rate_per"` | The function has not been created in this session | Run the code that defines it, or `source()` its file |
| `argument "population" is missing, with no default` | You did not supply a required argument | Give it, or add a default in the definition |
| `object 'temp' not found` after calling a function | Objects created inside a function are local | Return what you need as the last line |
| `unused argument (per = 100)` | The name you typed is not in the function’s argument list | Check the spelling in `function(...)` |
| Function runs but returns nothing useful | The last line is an assignment, e.g. `x <- ...` | End with the value itself, or `return(x)` |

------------------------------------------------------------------------

## 5. Practice

1.  Write `lbw_flag(bwt, cutoff = 2500)` that returns TRUE for babies
    below the cutoff. Use it to count low birth weight babies in
    `birthwt`, then again with `cutoff = 1500`.
2.  Write
    `risk_ratio(cases_exposed, total_exposed, cases_unexposed, total_unexposed)`
    that divides the risk (cases ÷ total) in the exposed group by the
    risk in the unexposed group. In `birthwt`, 30 of the 74 smoking
    mothers and 29 of the 115 non-smoking mothers had a low birth weight
    baby. What is the risk ratio?
3.  Check those counts using `table(birthwt$smoke, birthwt$low)`.
4.  Write `bmi_group(bmi)` that returns the four WHO categories from
    Lesson 19, and use it on `Pima.tr2$bmi`.

<details>

<summary>

Show answers
</summary>

``` r
# 1
lbw_flag <- function(bwt, cutoff = 2500) bwt < cutoff
sum(lbw_flag(birthwt$bwt))
```

    ## [1] 59

``` r
sum(lbw_flag(birthwt$bwt, cutoff = 1500))
```

    ## [1] 5

``` r
# 2
risk_ratio <- function(cases_exposed, total_exposed,
                       cases_unexposed, total_unexposed) {
  (cases_exposed / total_exposed) / (cases_unexposed / total_unexposed)
}
round(risk_ratio(30, 74, 29, 115), 2)
```

    ## [1] 1.61

``` r
# 3
table(birthwt$smoke, birthwt$low)
```

    ##    
    ##      0  1
    ##   0 86 29
    ##   1 44 30

``` r
# 4
bmi_group <- function(bmi) {
  cut(bmi, breaks = c(0, 18.5, 25, 30, Inf),
      labels = c("Underweight", "Normal", "Overweight", "Obese"),
      right = FALSE)
}
table(bmi_group(Pima.tr2$bmi), useNA = "ifany")
```

    ## 
    ## Underweight      Normal  Overweight       Obese        <NA> 
    ##           2          41          70         184           3

</details>

------------------------------------------------------------------------

## 6. Recap

- `name <- function(arguments) { steps }` builds a reusable tool; the
  last value is returned.
- Arguments can have defaults; use `name = value` when calling.
- Variables made inside a function stay inside.
- `stop("message")` adds a guard rail against bad input.
- Save useful functions in an `.R` file and load them with `source()`.

## 7. What comes next

We have loops and functions. **Lesson 22** brings them together with the
**apply family**: `sapply()`, `lapply()`, `tapply()` and `apply()` run a
function over every column, group or row in a single clear line, which
replaces most of the loops you have written so far.

**My own idea for you:** build a personal `helpers.R` with the three
functions you will use in every project (a `percent()`, a `describe()`
and a `rate_per()`), keep it in a folder you always copy, and `source()`
it at the top of each script. Within a month it becomes your own small
package.
