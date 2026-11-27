Lesson 19: Making Decisions with Conditions
================
Dr. Sandeep Kumar Singh

> **The real question for today:** The 189 babies in the Baystate study
> have an exact birth weight in grams. A hospital, however, does not
> think in exact grams. It asks: is this baby *normal*, *low* or *very
> low* birth weight? And the 300 women in the Pima study have a BMI
> number, but a clinic asks: *underweight, normal, overweight or obese?*
> How do we teach R to turn a number into a decision?

------------------------------------------------------------------------

## 1. Why this lesson matters

Until now R has done exactly what we told it, line by line. Real
analysis needs **decisions**: “if this value is below a limit, label it
one way, otherwise label it another way.” Turning a measured number into
a category is one of the most common jobs in health data work, and the
tools in this lesson do it.

You already know the key ingredient from Lesson 8: a **logical test**
such as `bwt < 2500` that answers TRUE or FALSE. Today we use those
answers to make R choose.

------------------------------------------------------------------------

## 2. The ideas, in plain words

### 2.1 `if` and `else`: a fork in the road

Imagine a nurse at the weighing scale. She looks at one baby’s weight
and thinks: *if it is under 2500 g, I write “Low”; otherwise I write
“Normal”.* That is `if (condition) { do this } else { do that }`. It
works on **one value at a time**.

### 2.2 `ifelse()`: the same decision for a whole column

The nurse cannot do 189 babies one by one by hand, and neither should R.
`ifelse(test, yes, no)` runs the same decision on **every element of a
vector at once**, the “vectorised” idea from Lesson 7.

### 2.3 `cut()`: sorting numbers into ranges

When there are more than two outcomes (very low, low, normal), nesting
many `ifelse()` calls becomes messy. `cut()` takes the **cut points**
you choose and sorts every number into the range it belongs to, like
posting letters into labelled pigeon-holes.

### 2.4 `any()`, `all()` and `which()`: questions about the whole vector

Sometimes the decision is about the whole dataset: *Is there any baby
under 1000 g? Are all the mothers adults?* `any()` and `all()` answer
those with a single TRUE or FALSE, and `which()` tells you *where*.

------------------------------------------------------------------------

## 3. The code, line by line

### 3.1 A decision about one baby: `if` / `else`

``` r
library(MASS)                       # birthwt lives in the MASS package

baby_weight <- birthwt$bwt[1]       # birth weight of the first baby
baby_weight
```

    ## [1] 2523

``` r
if (baby_weight < 2500) {
  label <- "Low"
} else {
  label <- "Normal"
}
label
```

    ## [1] "Normal"

**What each line does**

- `library(MASS)` switches on the package that holds `birthwt` (Lesson
  5).
- `birthwt$bwt[1]` takes the first value of the birth-weight column
  (Lesson 8: `$` picks a column, `[1]` picks the first element).
- `if (baby_weight < 2500)` is the **test**. If it is TRUE, R runs the
  code inside the first pair of curly braces `{ }`. If FALSE, R skips to
  the braces after `else`.
- `label` is the object we created in whichever branch ran; printing it
  shows the decision.

**How to read the output:** this first baby weighed 2523 g, which is
*not* below 2500, so the `else` branch ran and the label is “Normal”.

### 3.2 Why `if` cannot handle a whole column

``` r
if (birthwt$bwt < 2500) {
  "Low"
}
```

    ## Error in `if (birthwt$bwt < 2500) ...`:
    ## ! the condition has length > 1

**Why we show this:** `birthwt$bwt < 2500` gives 189 answers, but `if`
can only follow **one** TRUE or FALSE. Since R 4.2 this stops with an
error instead of quietly using the first answer. When you see *“the
condition has length \> 1”*, the fix is almost always `ifelse()`.

### 3.3 `ifelse()` on every baby

``` r
lbw_label <- ifelse(birthwt$bwt < 2500, "Low", "Normal")

head(lbw_label, 10)        # the first 10 decisions
```

    ##  [1] "Normal" "Normal" "Normal" "Normal" "Normal" "Normal" "Normal" "Normal"
    ##  [9] "Normal" "Normal"

``` r
table(lbw_label)           # how many of each
```

    ## lbw_label
    ##    Low Normal 
    ##     59    130

**What each line does**

- `ifelse(birthwt$bwt < 2500, "Low", "Normal")` reads: *for each baby,
  if the test is TRUE give “Low”, otherwise “Normal”.* The result is a
  vector as long as the column, 189 labels.
- `head(..., 10)` shows only the first ten so the page stays short.
- `table()` counts each label (Lesson 10).

**How to read the output:** `table` shows 59 low and 130 normal babies.
These match the ready-made `low` column in the data, which is a good
check of our logic:

``` r
table(lbw_label, birthwt$low)
```

    ##          
    ## lbw_label   0   1
    ##    Low      0  59
    ##    Normal 130   0

The diagonal agrees completely: every “Low” baby has `low = 1`.

### 3.4 Missing values inside a decision

``` r
pima <- Pima.tr2                      # 300 women, some BMI values missing

bmi_flag <- ifelse(pima$bmi >= 30, "Obese range", "Below 30")
table(bmi_flag, useNA = "ifany")
```

    ## bmi_flag
    ##    Below 30 Obese range        <NA> 
    ##         113         184           3

**Why the `NA`:** In Lesson 9 we learned that a comparison with a
missing value gives `NA`, not TRUE or FALSE. `ifelse()` passes that `NA`
straight through, which is the honest answer: *we cannot decide for a
woman whose BMI was not measured.* `useNA = "ifany"` makes `table()`
show those cases instead of hiding them.

### 3.5 More than two outcomes with `cut()`

The WHO describes birth weight as *very low* (under 1500 g), *low* (1500
to 2499 g) and *normal* (2500 g or more).

``` r
bwt_class <- cut(
  birthwt$bwt,
  breaks = c(0, 1500, 2500, Inf),
  labels = c("Very low", "Low", "Normal"),
  right  = FALSE
)

table(bwt_class)
```

    ## bwt_class
    ## Very low      Low   Normal 
    ##        5       54      130

**What each argument does**

- `birthwt$bwt` is the numbers to sort.
- `breaks = c(0, 1500, 2500, Inf)` are the **cut points**. Four numbers
  make three ranges. `Inf` means infinity, so “2500 and above” has no
  upper limit.
- `labels` gives each range a readable name, in the same order.
- `right = FALSE` decides which side of each range is closed. With
  `FALSE`, a range includes its **left** end and excludes its right end:
  `[1500, 2500)`. A baby weighing exactly 2500 g is therefore
  **Normal**, as the WHO definition requires. With the default
  (`right = TRUE`) a 2500 g baby would be wrongly called Low.

**How to read the output:** 5 very low, 54 low and 130 normal. Notice
that 5 + 54 = 59, the same 59 low birth weight babies we found in Lesson
18.

### 3.6 BMI categories for the Pima women

``` r
bmi_class <- cut(
  pima$bmi,
  breaks = c(0, 18.5, 25, 30, Inf),
  labels = c("Underweight", "Normal", "Overweight", "Obese"),
  right  = FALSE
)

table(bmi_class, useNA = "ifany")
```

    ## bmi_class
    ## Underweight      Normal  Overweight       Obese        <NA> 
    ##           2          41          70         184           3

``` r
round(100 * prop.table(table(bmi_class)), 1)
```

    ## bmi_class
    ## Underweight      Normal  Overweight       Obese 
    ##         0.7        13.8        23.6        62.0

**What the new lines do**

- `prop.table()` turns counts into proportions of the total.
- `100 * ...` turns them into percentages and `round(..., 1)` keeps one
  decimal place.

**How to read the output:** among the 297 women with a BMI, 184 (about
62%) fall in the obese range. This is a hospital-based sample of women
at risk of diabetes, so it is not a picture of the general population.
That is a useful habit: *always ask who the data describe.*

### 3.7 Whole-vector questions: `any()`, `all()`, `which()`

``` r
any(birthwt$bwt < 1000)         # is there at least one baby under 1000 g?
```

    ## [1] TRUE

``` r
all(birthwt$age >= 14)          # are all mothers 14 or older?
```

    ## [1] TRUE

``` r
sum(birthwt$age < 20)           # how many mothers are teenagers?
```

    ## [1] 51

``` r
which(birthwt$bwt < 1000)       # row numbers of babies under 1000 g
```

    ## [1] 131

``` r
birthwt$bwt[birthwt$bwt < 1000] # their actual weights
```

    ## [1] 709

**What each line does**

- `any()` is TRUE if at least one element is TRUE; `all()` is TRUE only
  if every element is TRUE.
- `sum()` of TRUE/FALSE counts the TRUEs (TRUE is 1, FALSE is 0, from
  Lesson 6).
- `which()` returns the **positions** of the TRUEs.
- The last line uses those positions the Lesson 8 way to pull out the
  weights themselves.

### 3.8 Two conditions together: `&` and `|`

``` r
young_smoker <- birthwt$age < 20 & birthwt$smoke == 1   # BOTH must be TRUE
young_or_smoker <- birthwt$age < 20 | birthwt$smoke == 1 # EITHER is enough

sum(young_smoker)
```

    ## [1] 23

``` r
sum(young_or_smoker)
```

    ## [1] 102

`&` means **and**, `|` means **or**. They work element by element, so
they are the ones to use inside `ifelse()` and filters. The doubled
forms `&&` and `||` look at a single TRUE/FALSE only, so they belong
inside `if ( )`, not in column work.

### 3.9 Picking an action by name: `switch()`

``` r
describe_centre <- function(type, x) {
  switch(type,
         mean   = mean(x, na.rm = TRUE),
         median = median(x, na.rm = TRUE),
         stop("type must be 'mean' or 'median'"))
}

describe_centre("mean",   birthwt$bwt)
```

    ## [1] 2944.587

``` r
describe_centre("median", birthwt$bwt)
```

    ## [1] 2977

`switch()` looks at the word you give it and runs the matching line; the
last, unnamed line is what happens if nothing matches. (The
`function(...)` line is a preview of Lesson 21; for now just read it as
“a small tool that chooses between two calculations.”)

------------------------------------------------------------------------

## 4. Common errors and how to read them

| What you see | What it means | Fix |
|----|----|----|
| `the condition has length > 1` | You gave `if` a whole vector of TRUE/FALSE | Use `ifelse()`, or reduce with `any()` / `all()` |
| `missing value where TRUE/FALSE needed` | The test returned `NA` inside `if` | Handle missing values first, e.g. `is.na(x)` or `na.rm = TRUE` |
| A baby of exactly 2500 g labelled “Low” | `cut()` default `right = TRUE` | Add `right = FALSE` |
| `'breaks' are not unique` | Two cut points are the same number | Make the cut points strictly increasing |
| `unexpected 'else'` in a script | `else` started a new line after the closing `}` at top level | Write `} else {` on the same line |

------------------------------------------------------------------------

## 5. Practice

Use `birthwt` or `Pima.tr2`. Answers are hidden; try first.

1.  Create `young_mother`, a vector that is `"Under 20"` or
    `"20 or over"` for each mother in `birthwt`. How many are under 20?
2.  Using `cut()`, sort mother’s age into `"Under 20"`, `"20-29"`,
    `"30 and over"`. How many are in each group?
3.  In `Pima.tr2`, how many women have `bmi` of 40 or more? Remember
    missing values.
4.  Is there any woman in `Pima.tr2` with a `glu` (glucose) above 190?
    Which rows are they, and what is their `type` (diabetes status)?

<details>

<summary>

Show answers
</summary>

``` r
# 1
young_mother <- ifelse(birthwt$age < 20, "Under 20", "20 or over")
table(young_mother)
```

    ## young_mother
    ## 20 or over   Under 20 
    ##        138         51

``` r
# 2
age_group <- cut(birthwt$age, breaks = c(0, 20, 30, Inf),
                 labels = c("Under 20", "20-29", "30 and over"),
                 right = FALSE)
table(age_group)
```

    ## age_group
    ##    Under 20       20-29 30 and over 
    ##          51         111          27

``` r
# 3  (na.rm = TRUE ignores the 3 missing BMIs)
sum(pima$bmi >= 40, na.rm = TRUE)
```

    ## [1] 34

``` r
# 4
any(pima$glu > 190)
```

    ## [1] TRUE

``` r
which(pima$glu > 190)
```

    ## [1]   2   8  50 135 153 157 173 212 265

``` r
pima[which(pima$glu > 190), c("glu", "type")]
```

    ##     glu type
    ## 2   195  Yes
    ## 8   193   No
    ## 50  199  Yes
    ## 135 191   No
    ## 153 198  Yes
    ## 157 197  Yes
    ## 173 194  Yes
    ## 212 195  Yes
    ## 265 197  Yes

</details>

------------------------------------------------------------------------

## 6. Recap

- `if / else` decides for **one** value; `ifelse()` decides for a
  **whole vector**.
- `cut()` turns numbers into ordered categories; `right = FALSE` keeps
  the lower limit inside each range.
- `NA` in, `NA` out: missing values stay missing through decisions.
- `any()`, `all()`, `which()` and `sum()` answer questions about the
  whole vector.
- Use `&` and `|` for columns, `&&` and `||` inside `if`.

## 7. What comes next

Decisions let R choose. In **Lesson 20** we teach R to **repeat** work:
loops that run the same steps over every column, every group, every
file.

**My own idea for you:** before moving on, write down the definition of
one real clinical category you know (for example anaemia by haemoglobin
level) and code it with `cut()`. Making the code agree with a published
definition, including who falls exactly on the cut point, is the best
habit you can build here.
