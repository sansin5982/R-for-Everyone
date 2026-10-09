Data Frames: The Main Structure for Data
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapters 4–8, we worked with vectors, factors, matrices, arrays, and
lists. In biomedical research, however, the most familiar data structure
is usually a **rectangular dataset**: each row describes an observation
and each column describes a variable.

Consider a small hypertension study. We may record a participant
identifier, age, sex, systolic blood pressure (SBP), fasting glucose,
and smoking status. These variables do not all have the same data type.
Patient identifiers are character strings, age and blood pressure are
numeric, and smoking status may be logical or categorical.

A matrix cannot preserve these mixed column types without coercion. A
**data frame** can.

A data frame is fundamentally a special kind of list: its elements are
columns of equal length. Each column can have its own type.

In this chapter, we will learn how to build, inspect, subset, modify,
and validate data frames using **base R only**. We will use synthetic
biomedical, epidemiological, and genomics examples. No external packages
or datasets are required.

## 9.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Explain how a data frame differs from a vector, matrix, array, and
    ordinary list.
2.  Create data frames using `data.frame()`.
3.  Inspect rows, columns, names, data types, and structure.
4.  Access columns with `$`, `[[ ]]`, and `[ , ]`.
5.  Select rows using numeric, character, and logical indices.
6.  Prevent unexpected simplification with `drop = FALSE`.
7.  Add, update, rename, and remove columns.
8.  Filter observations using clinical eligibility criteria.
9.  Sort records with `order()` while keeping columns aligned.
10. Identify and summarize missing values.
11. Detect duplicated identifiers and validate study data.
12. Combine compatible datasets by rows or columns.
13. Understand basic factor behavior and type conversion.
14. Build a small, reproducible biomedical data-processing workflow.
15. Recognize common data-frame mistakes that can corrupt analyses.

------------------------------------------------------------------------

## 9.2 Why data frames are central to research

A typical participant-level study dataset might look like this:

| patient_id | age | sex    | sbp | glucose | smoker |
|:-----------|----:|:-------|----:|--------:|:-------|
| P001       |  34 | Female | 118 |      92 | FALSE  |
| P002       |  57 | Male   | 152 |     128 | TRUE   |
| P003       |  49 | Female | 143 |     110 | FALSE  |
| P004       |  62 | Male   | 135 |     105 | TRUE   |
| P005       |  41 | Female | 125 |      99 | FALSE  |

Each **row** is one participant. Each **column** is one variable.

The table is easy to interpret because each variable has a name and an
appropriate data type.

We should distinguish this representation from a matrix. A matrix stores
one atomic type across all cells. A data frame stores different atomic
types in different columns.

``` r
patient_id <- c("P001", "P002", "P003", "P004", "P005")
age <- c(34, 57, 49, 62, 41)
sex <- c("Female", "Male", "Female", "Male", "Female")
sbp <- c(118, 152, 143, 135, 125)
glucose <- c(92, 128, 110, 105, 99)
smoker <- c(FALSE, TRUE, FALSE, TRUE, FALSE)
```

We will combine these vectors in the next section.

## 9.3 Creating our first data frame

``` r
patients <- data.frame(
  patient_id = patient_id,
  age = age,
  sex = sex,
  sbp = sbp,
  glucose = glucose,
  smoker = smoker
)

patients
```

    ##   patient_id age    sex sbp glucose smoker
    ## 1       P001  34 Female 118      92  FALSE
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE
    ## 4       P004  62   Male 135     105   TRUE
    ## 5       P005  41 Female 125      99  FALSE

The syntax is:

``` r
data.frame(
  column_1 = values_1,
  column_2 = values_2,
  ...
)
```

Every column should describe one variable, and all columns must have
compatible row counts.

### How many rows and columns?

``` r
nrow(patients)
```

    ## [1] 5

``` r
ncol(patients)
```

    ## [1] 6

``` r
dim(patients)
```

    ## [1] 5 6

The output of `dim()` is:

``` text
number of rows, number of columns
```

For our dataset, we have five participants and six variables.

### Total number of cells

``` r
nrow(patients) * ncol(patients)
```

    ## [1] 30

This is not the number of participants; it is the total number of table
cells.

------------------------------------------------------------------------

## 9.4 Inspecting a data frame

Before conducting any analysis, we should inspect the dataset.

``` r
class(patients)
```

    ## [1] "data.frame"

``` r
typeof(patients)
```

    ## [1] "list"

``` r
is.data.frame(patients)
```

    ## [1] TRUE

`class(patients)` is `"data.frame"`, whereas `typeof(patients)` is
`"list"`. This reflects the internal list-like storage of a data frame.

### Structure

``` r
str(patients)
```

    ## 'data.frame':    5 obs. of  6 variables:
    ##  $ patient_id: chr  "P001" "P002" "P003" "P004" ...
    ##  $ age       : num  34 57 49 62 41
    ##  $ sex       : chr  "Female" "Male" "Female" "Male" ...
    ##  $ sbp       : num  118 152 143 135 125
    ##  $ glucose   : num  92 128 110 105 99
    ##  $ smoker    : logi  FALSE TRUE FALSE TRUE FALSE

`str()` displays column names, types, and a preview of values.

### Column names

``` r
names(patients)
```

    ## [1] "patient_id" "age"        "sex"        "sbp"        "glucose"   
    ## [6] "smoker"

``` r
colnames(patients)
```

    ## [1] "patient_id" "age"        "sex"        "sbp"        "glucose"   
    ## [6] "smoker"

### Row names

``` r
rownames(patients)
```

    ## [1] "1" "2" "3" "4" "5"

The default row names are character representations of row positions.
For research datasets, a dedicated participant-ID column is usually
preferable to relying on row names.

### First and last rows

``` r
head(patients, 3)
```

    ##   patient_id age    sex sbp glucose smoker
    ## 1       P001  34 Female 118      92  FALSE
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE

``` r
tail(patients, 2)
```

    ##   patient_id age    sex sbp glucose smoker
    ## 4       P004  62   Male 135     105   TRUE
    ## 5       P005  41 Female 125      99  FALSE

### Basic summary

``` r
summary(patients)
```

    ##   patient_id             age           sex                 sbp       
    ##  Length:5           Min.   :34.0   Length:5           Min.   :118.0  
    ##  Class :character   1st Qu.:41.0   Class :character   1st Qu.:125.0  
    ##  Mode  :character   Median :49.0   Mode  :character   Median :135.0  
    ##                     Mean   :48.6                      Mean   :134.6  
    ##                     3rd Qu.:57.0                      3rd Qu.:143.0  
    ##                     Max.   :62.0                      Max.   :152.0  
    ##     glucose        smoker       
    ##  Min.   : 92.0   Mode :logical  
    ##  1st Qu.: 99.0   FALSE:3        
    ##  Median :105.0   TRUE :2        
    ##  Mean   :106.8                  
    ##  3rd Qu.:110.0                  
    ##  Max.   :128.0

For numeric columns, `summary()` reports statistics such as minimum,
median, mean, and maximum. For character and logical columns, its output
differs.

**Good habit:** Begin with `dim()`, `names()`, `str()`, `head()`, and
`summary()` before writing analysis code.

------------------------------------------------------------------------

## 9.5 Understanding column data types

Each column is an ordinary R vector.

``` r
class(patients$patient_id)
```

    ## [1] "character"

``` r
class(patients$age)
```

    ## [1] "numeric"

``` r
class(patients$sex)
```

    ## [1] "character"

``` r
class(patients$smoker)
```

    ## [1] "logical"

We can examine all column classes at once:

``` r
sapply(patients, class)
```

    ##  patient_id         age         sex         sbp     glucose      smoker 
    ## "character"   "numeric" "character"   "numeric"   "numeric"   "logical"

The `sapply()` function applies `class()` to each column. We introduced
lists in Chapter 8; a data frame is an especially important case of a
list whose elements are columns.

We can also inspect storage types:

``` r
sapply(patients, typeof)
```

    ##  patient_id         age         sex         sbp     glucose      smoker 
    ## "character"    "double" "character"    "double"    "double"   "logical"

### Why this matters

Suppose an age column was imported as character:

``` r
age_text <- c("34", "57", "49")
class(age_text)
```

    ## [1] "character"

The text `"34"` is not the same type as the number `34`. Numerical
analysis generally requires numeric values.

``` r
age_numeric <- as.numeric(age_text)
class(age_numeric)
```

    ## [1] "numeric"

We should never convert blindly: malformed entries, units, and
missing-value codes must be investigated first.

------------------------------------------------------------------------

## 9.6 Three ways to access a column

Data frames support several column-access methods.

### Method 1: `$`

``` r
patients$sbp
```

    ## [1] 118 152 143 135 125

This is convenient when the column name is known and syntactically
simple.

### Method 2: `[[ ]]`

``` r
patients[["sbp"]]
```

    ## [1] 118 152 143 135 125

This is useful when the column name is stored in another object:

``` r
variable_name <- "glucose"
patients[[variable_name]]
```

    ## [1]  92 128 110 105  99

### Method 3: `[ , ]`

``` r
patients[, "sbp"]
```

    ## [1] 118 152 143 135 125

For one selected column, this normally simplifies to a vector.

### Comparing the results

``` r
identical(patients$sbp, patients[["sbp"]])
```

    ## [1] TRUE

``` r
identical(patients$sbp, patients[, "sbp"])
```

    ## [1] TRUE

These methods return the same SBP values in this example, but they
differ in syntax and flexibility.

### A common mistake: `$` does not evaluate a variable name

``` r
column_name <- "sbp"
patients[[column_name]]
```

    ## [1] 118 152 143 135 125

This correctly uses the string stored in `column_name`.

The expression below is shown for comparison; it looks for a literal
column named `column_name` rather than the value `"sbp"`:

``` r
patients$column_name
```

It is not a dynamic column-selection method.

------------------------------------------------------------------------

## 9.7 Selecting rows and columns with `[rows, columns]`

A data frame uses two-dimensional indexing:

``` r
data[rows, columns]
```

### One row

``` r
patients[1, ]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 1       P001  34 Female 118      92  FALSE

### First three rows

``` r
patients[1:3, ]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 1       P001  34 Female 118      92  FALSE
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE

### One column

``` r
patients[, "age"]
```

    ## [1] 34 57 49 62 41

### Several columns

``` r
patients[, c("patient_id", "age", "sbp")]
```

    ##   patient_id age sbp
    ## 1       P001  34 118
    ## 2       P002  57 152
    ## 3       P003  49 143
    ## 4       P004  62 135
    ## 5       P005  41 125

### Rows and columns together

``` r
patients[
  c(2, 4),
  c("patient_id", "age", "glucose")
]
```

    ##   patient_id age glucose
    ## 2       P002  57     128
    ## 4       P004  62     105

### Excluding a column

``` r
patients[, -2]
```

    ##   patient_id    sex sbp glucose smoker
    ## 1       P001 Female 118      92  FALSE
    ## 2       P002   Male 152     128   TRUE
    ## 3       P003 Female 143     110  FALSE
    ## 4       P004   Male 135     105   TRUE
    ## 5       P005 Female 125      99  FALSE

This excludes the second column, `age`.

### Excluding a row

``` r
patients[-1, ]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE
    ## 4       P004  62   Male 135     105   TRUE
    ## 5       P005  41 Female 125      99  FALSE

This excludes the first participant.

**Important:** Negative indices specify exclusions by position. If
column order changes, `-2` may exclude a different variable. Selecting
columns by name is generally more robust.

------------------------------------------------------------------------

## 9.8 Preventing simplification with `drop = FALSE`

When we select one column, R usually returns a vector:

``` r
one_column <- patients[, "sbp"]
class(one_column)
```

    ## [1] "numeric"

But sometimes our code requires a data frame with one column:

``` r
one_column_df <- patients[, "sbp", drop = FALSE]
class(one_column_df)
```

    ## [1] "data.frame"

``` r
dim(one_column_df)
```

    ## [1] 5 1

The difference matters in reusable functions and data-processing
pipelines.

Compare:

``` r
str(one_column)
```

    ##  num [1:5] 118 152 143 135 125

``` r
str(one_column_df)
```

    ## 'data.frame':    5 obs. of  1 variable:
    ##  $ sbp: num  118 152 143 135 125

**Rule:** If subsequent code expects a data frame, use `drop = FALSE`
when selecting columns that might reduce to one.

------------------------------------------------------------------------

## 9.9 Selecting rows with logical conditions

We often need to identify participants who meet a clinical or study
criterion.

### SBP at least 140 mmHg

``` r
patients$sbp >= 140
```

    ## [1] FALSE  TRUE  TRUE FALSE FALSE

The result is a logical vector:

``` text
FALSE TRUE TRUE FALSE FALSE
```

We can use it to select rows:

``` r
patients[patients$sbp >= 140, ]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE

### Age at least 50 years

``` r
patients[patients$age >= 50, ]
```

    ##   patient_id age  sex sbp glucose smoker
    ## 2       P002  57 Male 152     128   TRUE
    ## 4       P004  62 Male 135     105   TRUE

### Multiple conditions: AND

Suppose we need participants aged at least 50 with SBP at least 140:

``` r
patients[
  patients$age >= 50 & patients$sbp >= 140,
]
```

    ##   patient_id age  sex sbp glucose smoker
    ## 2       P002  57 Male 152     128   TRUE

### Multiple conditions: OR

Select participants with SBP at least 140 **or** glucose at least 126:

``` r
patients[
  patients$sbp >= 140 | patients$glucose >= 126,
]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE

The glucose threshold here is a hypothetical selection criterion for
programming practice; diagnosis requires the appropriate clinical
context and confirmation.

### Negation

Select nonsmokers:

``` r
patients[!patients$smoker, ]
```

    ##   patient_id age    sex sbp glucose smoker
    ## 1       P001  34 Female 118      92  FALSE
    ## 3       P003  49 Female 143     110  FALSE
    ## 5       P005  41 Female 125      99  FALSE

### `%in%` for membership

Select two named participants:

``` r
patients[
  patients$patient_id %in% c("P002", "P004"),
]
```

    ##   patient_id age  sex sbp glucose smoker
    ## 2       P002  57 Male 152     128   TRUE
    ## 4       P004  62 Male 135     105   TRUE

This is often clearer than a long chain of equality comparisons.

------------------------------------------------------------------------

## 9.10 `subset()` as an alternative

Base R includes `subset()`:

``` r
subset(patients, sbp >= 140)
```

    ##   patient_id age    sex sbp glucose smoker
    ## 2       P002  57   Male 152     128   TRUE
    ## 3       P003  49 Female 143     110  FALSE

We can also choose columns:

``` r
subset(
  patients,
  subset = age >= 40,
  select = c(patient_id, age, sbp)
)
```

    ##   patient_id age sbp
    ## 2       P002  57 152
    ## 3       P003  49 143
    ## 4       P004  62 135
    ## 5       P005  41 125

For interactive exploration, `subset()` is readable. In reusable scripts
and functions, explicit indexing with `[ , ]` is often preferable
because it makes column references and evaluation rules clearer.

Both approaches are valid when used carefully.

------------------------------------------------------------------------

## 9.11 Adding new variables

A common task is to derive new measurements.

### Add pulse pressure

Pulse pressure is:

$$PP = SBP - DBP.$$

First, add diastolic blood pressure:

``` r
patients$dbp <- c(76, 94, 88, 84, 79)
```

Then calculate pulse pressure:

``` r
patients$pulse_pressure <- patients$sbp - patients$dbp
patients[, c("patient_id", "sbp", "dbp", "pulse_pressure")]
```

    ##   patient_id sbp dbp pulse_pressure
    ## 1       P001 118  76             42
    ## 2       P002 152  94             58
    ## 3       P003 143  88             55
    ## 4       P004 135  84             51
    ## 5       P005 125  79             46

### Add BMI

``` r
patients$weight_kg <- c(62, 84, 71, 79, 68)
patients$height_m <- c(1.62, 1.75, 1.66, 1.70, 1.64)

patients$bmi <- patients$weight_kg / (patients$height_m ^ 2)
patients[, c("patient_id", "weight_kg", "height_m", "bmi")]
```

    ##   patient_id weight_kg height_m      bmi
    ## 1       P001        62     1.62 23.62445
    ## 2       P002        84     1.75 27.42857
    ## 3       P003        71     1.66 25.76571
    ## 4       P004        79     1.70 27.33564
    ## 5       P005        68     1.64 25.28257

Check that heights are positive:

``` r
stopifnot(all(patients$height_m > 0))
```

### Add a logical indicator

``` r
patients$high_sbp <- patients$sbp >= 140
patients[, c("patient_id", "sbp", "high_sbp")]
```

    ##   patient_id sbp high_sbp
    ## 1       P001 118    FALSE
    ## 2       P002 152     TRUE
    ## 3       P003 143     TRUE
    ## 4       P004 135    FALSE
    ## 5       P005 125    FALSE

This variable encodes a study-defined screening threshold, not a
complete clinical diagnosis.

------------------------------------------------------------------------

## 9.12 Updating existing columns

We can change one value:

``` r
patients$sbp[1] <- 120
patients[1, c("patient_id", "sbp")]
```

    ##   patient_id sbp
    ## 1       P001 120

Or update a value by patient identifier:

``` r
patients$sbp[patients$patient_id == "P001"] <- 118
```

Using an identifier is safer than assuming that the participant always
occupies row 1.

### Recalculate derived columns after modifying source data

``` r
patients$high_sbp <- patients$sbp >= 140
patients$pulse_pressure <- patients$sbp - patients$dbp
```

Derived variables do **not** automatically update when source columns
change. We must recompute them.

------------------------------------------------------------------------

## 9.13 Renaming columns

Inspect the current names:

``` r
names(patients)
```

    ##  [1] "patient_id"     "age"            "sex"            "sbp"           
    ##  [5] "glucose"        "smoker"         "dbp"            "pulse_pressure"
    ##  [9] "weight_kg"      "height_m"       "bmi"            "high_sbp"

Rename a column using `names()`:

``` r
names(patients)[names(patients) == "glucose"] <- "glucose_mg_dl"
```

Verify:

``` r
"glucose_mg_dl" %in% names(patients)
```

    ## [1] TRUE

For research data, informative names are valuable. Including units in
names or in a data dictionary reduces ambiguity.

### Renaming all columns

We can assign a complete name vector:

``` r
names(data) <- c("id", "age", "sex", "sbp")
```

The number of names must match the number of columns. We should avoid
overwriting all names unless that correspondence has been verified.

------------------------------------------------------------------------

## 9.14 Removing columns

To remove one column:

``` r
temporary <- patients
temporary$high_sbp <- NULL
"high_sbp" %in% names(temporary)
```

    ## [1] FALSE

Or select the columns to keep:

``` r
keep <- setdiff(names(patients), c("weight_kg", "height_m"))
smaller <- patients[, keep, drop = FALSE]
names(smaller)
```

    ##  [1] "patient_id"     "age"            "sex"            "sbp"           
    ##  [5] "glucose_mg_dl"  "smoker"         "dbp"            "pulse_pressure"
    ##  [9] "bmi"            "high_sbp"

`setdiff()` returns elements of the first vector that are not in the
second.

**Important:** `NULL` removes a data-frame column; `NA` is a missing
value inside a column. These are different operations.

------------------------------------------------------------------------

## 9.15 Sorting records with `order()`

In Chapter 4, we saw that `sort()` returns sorted values, whereas
`order()` returns their original positions.

``` r
sbp_example <- c(120, 150, 145, 115, 142)
sort(sbp_example)
```

    ## [1] 115 120 142 145 150

``` r
order(sbp_example)
```

    ## [1] 4 1 5 3 2

The index result is:

``` text
4 1 5 3 2
```

because 115 is at position 4, 120 at position 1, 142 at position 5, 145
at position 3, and 150 at position 2.

For a data frame, use the indices to reorder **entire rows**, not just
one column.

### Increasing SBP

``` r
patients[order(patients$sbp), ]
```

    ##   patient_id age    sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 1       P001  34 Female 118            92  FALSE  76             42        62
    ## 5       P005  41 Female 125            99  FALSE  79             46        68
    ## 4       P004  62   Male 135           105   TRUE  84             51        79
    ## 3       P003  49 Female 143           110  FALSE  88             55        71
    ## 2       P002  57   Male 152           128   TRUE  94             58        84
    ##   height_m      bmi high_sbp
    ## 1     1.62 23.62445    FALSE
    ## 5     1.64 25.28257    FALSE
    ## 4     1.70 27.33564    FALSE
    ## 3     1.66 25.76571     TRUE
    ## 2     1.75 27.42857     TRUE

### Decreasing SBP

``` r
patients[order(patients$sbp, decreasing = TRUE), ]
```

    ##   patient_id age    sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 2       P002  57   Male 152           128   TRUE  94             58        84
    ## 3       P003  49 Female 143           110  FALSE  88             55        71
    ## 4       P004  62   Male 135           105   TRUE  84             51        79
    ## 5       P005  41 Female 125            99  FALSE  79             46        68
    ## 1       P001  34 Female 118            92  FALSE  76             42        62
    ##   height_m      bmi high_sbp
    ## 2     1.75 27.42857     TRUE
    ## 3     1.66 25.76571     TRUE
    ## 4     1.70 27.33564    FALSE
    ## 5     1.64 25.28257    FALSE
    ## 1     1.62 23.62445    FALSE

### Sort by age, then SBP

``` r
patients[order(patients$age, patients$sbp), ]
```

    ##   patient_id age    sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 1       P001  34 Female 118            92  FALSE  76             42        62
    ## 5       P005  41 Female 125            99  FALSE  79             46        68
    ## 3       P003  49 Female 143           110  FALSE  88             55        71
    ## 2       P002  57   Male 152           128   TRUE  94             58        84
    ## 4       P004  62   Male 135           105   TRUE  84             51        79
    ##   height_m      bmi high_sbp
    ## 1     1.62 23.62445    FALSE
    ## 5     1.64 25.28257    FALSE
    ## 3     1.66 25.76571     TRUE
    ## 2     1.75 27.42857     TRUE
    ## 4     1.70 27.33564    FALSE

### Why sorting one column alone is dangerous

This is **incorrect** for maintaining patient-level records:

``` r
patients$sbp <- sort(patients$sbp)
```

It sorts SBP values while leaving patient IDs and other variables
unchanged. The measurements may then be attributed to the wrong people.

Instead:

``` r
patients_sorted <- patients[order(patients$sbp), ]
patients_sorted[, c("patient_id", "sbp")]
```

    ##   patient_id sbp
    ## 1       P001 118
    ## 5       P005 125
    ## 4       P004 135
    ## 3       P003 143
    ## 2       P002 152

The entire record moves together.

------------------------------------------------------------------------

## 9.16 Working with missing values

Create a separate dataset containing missing measurements:

``` r
patients_na <- patients
patients_na$sbp[3] <- NA
patients_na$glucose_mg_dl[5] <- NA
patients_na
```

    ##   patient_id age    sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 1       P001  34 Female 118            92  FALSE  76             42        62
    ## 2       P002  57   Male 152           128   TRUE  94             58        84
    ## 3       P003  49 Female  NA           110  FALSE  88             55        71
    ## 4       P004  62   Male 135           105   TRUE  84             51        79
    ## 5       P005  41 Female 125            NA  FALSE  79             46        68
    ##   height_m      bmi high_sbp
    ## 1     1.62 23.62445    FALSE
    ## 2     1.75 27.42857     TRUE
    ## 3     1.66 25.76571     TRUE
    ## 4     1.70 27.33564    FALSE
    ## 5     1.64 25.28257    FALSE

### Detect missing values

``` r
is.na(patients_na)
```

    ##      patient_id   age   sex   sbp glucose_mg_dl smoker   dbp pulse_pressure
    ## [1,]      FALSE FALSE FALSE FALSE         FALSE  FALSE FALSE          FALSE
    ## [2,]      FALSE FALSE FALSE FALSE         FALSE  FALSE FALSE          FALSE
    ## [3,]      FALSE FALSE FALSE  TRUE         FALSE  FALSE FALSE          FALSE
    ## [4,]      FALSE FALSE FALSE FALSE         FALSE  FALSE FALSE          FALSE
    ## [5,]      FALSE FALSE FALSE FALSE          TRUE  FALSE FALSE          FALSE
    ##      weight_kg height_m   bmi high_sbp
    ## [1,]     FALSE    FALSE FALSE    FALSE
    ## [2,]     FALSE    FALSE FALSE    FALSE
    ## [3,]     FALSE    FALSE FALSE    FALSE
    ## [4,]     FALSE    FALSE FALSE    FALSE
    ## [5,]     FALSE    FALSE FALSE    FALSE

This produces a logical matrix indicating which cells are missing.

### Total missing cells

``` r
sum(is.na(patients_na))
```

    ## [1] 2

### Missing cells per column

``` r
colSums(is.na(patients_na))
```

    ##     patient_id            age            sex            sbp  glucose_mg_dl 
    ##              0              0              0              1              1 
    ##         smoker            dbp pulse_pressure      weight_kg       height_m 
    ##              0              0              0              0              0 
    ##            bmi       high_sbp 
    ##              0              0

### Missing cells per row

``` r
rowSums(is.na(patients_na))
```

    ## [1] 0 0 1 0 1

### Proportion missing per column

``` r
colMeans(is.na(patients_na))
```

    ##     patient_id            age            sex            sbp  glucose_mg_dl 
    ##            0.0            0.0            0.0            0.2            0.2 
    ##         smoker            dbp pulse_pressure      weight_kg       height_m 
    ##            0.0            0.0            0.0            0.0            0.0 
    ##            bmi       high_sbp 
    ##            0.0            0.0

Logical values are treated as 1 for `TRUE` and 0 for `FALSE`, so the
mean gives the fraction missing.

### Missingness for SBP

``` r
sum(is.na(patients_na$sbp))
```

    ## [1] 1

``` r
mean(is.na(patients_na$sbp))
```

    ## [1] 0.2

### Mean SBP with and without missing-value removal

``` r
mean(patients_na$sbp)
```

    ## [1] NA

``` r
mean(patients_na$sbp, na.rm = TRUE)
```

    ## [1] 132.5

`na.rm = TRUE` excludes missing observations from the calculation; it
does not establish that the resulting estimate is unbiased.

------------------------------------------------------------------------

## 9.17 Missing values and row filtering: an important trap

Suppose we select high-SBP participants from a dataset containing
missing SBP values.

This expression contains `NA` where SBP is missing:

``` r
patients_na$sbp >= 140
```

    ## [1] FALSE  TRUE    NA FALSE FALSE

If we use that logical vector directly as a row index, R can produce an
`NA` row:

``` r
patients_na[patients_na$sbp >= 140, ]
```

    ##    patient_id age  sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 2        P002  57 Male 152           128   TRUE  94             58        84
    ## NA       <NA>  NA <NA>  NA            NA     NA  NA             NA        NA
    ##    height_m      bmi high_sbp
    ## 2      1.75 27.42857     TRUE
    ## NA       NA       NA       NA

For most clinical filtering tasks, we want to exclude rows whose
screening measurement is missing.

### Safe method

``` r
eligible_sbp <- !is.na(patients_na$sbp) &
  patients_na$sbp >= 140

patients_na[eligible_sbp, ]
```

    ##   patient_id age  sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 2       P002  57 Male 152           128   TRUE  94             58        84
    ##   height_m      bmi high_sbp
    ## 2     1.75 27.42857     TRUE

This explicitly requires an observed SBP.

Alternatively:

``` r
subset(patients_na, !is.na(sbp) & sbp >= 140)
```

    ##   patient_id age  sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 2       P002  57 Male 152           128   TRUE  94             58        84
    ##   height_m      bmi high_sbp
    ## 2     1.75 27.42857     TRUE

**Lesson:** Missing logical conditions need an explicit policy. We
should not silently treat missing data as satisfying or failing a study
criterion without justification.

------------------------------------------------------------------------

## 9.18 `complete.cases()`

`complete.cases()` identifies rows with no missing values across the
supplied variables.

``` r
complete.cases(patients_na)
```

    ## [1]  TRUE  TRUE FALSE  TRUE FALSE

Select fully observed rows:

``` r
patients_na[complete.cases(patients_na), ]
```

    ##   patient_id age    sex sbp glucose_mg_dl smoker dbp pulse_pressure weight_kg
    ## 1       P001  34 Female 118            92  FALSE  76             42        62
    ## 2       P002  57   Male 152           128   TRUE  94             58        84
    ## 4       P004  62   Male 135           105   TRUE  84             51        79
    ##   height_m      bmi high_sbp
    ## 1     1.62 23.62445    FALSE
    ## 2     1.75 27.42857     TRUE
    ## 4     1.70 27.33564    FALSE

However, requiring completeness across **every** column can discard
participants because of variables that are irrelevant to a particular
analysis.

For an SBP-and-age analysis, restrict the completeness check:

``` r
needed <- c("age", "sbp")
patients_na[
  complete.cases(patients_na[, needed, drop = FALSE]),
  c("patient_id", needed)
]
```

    ##   patient_id age sbp
    ## 1       P001  34 118
    ## 2       P002  57 152
    ## 4       P004  62 135
    ## 5       P005  41 125

This preserves participants who have the variables needed for the
specific task.

------------------------------------------------------------------------

## 9.19 Counting categories with `table()`

We can count observations by sex:

``` r
table(patients$sex)
```

    ## 
    ## Female   Male 
    ##      3      2

And by smoking status:

``` r
table(patients$smoker)
```

    ## 
    ## FALSE  TRUE 
    ##     3     2

### Cross-tabulation

``` r
table(patients$sex, patients$smoker)
```

    ##         
    ##          FALSE TRUE
    ##   Female     3    0
    ##   Male       0    2

### Include missing categories

``` r
sex_with_missing <- c("Female", "Male", NA, "Female")
table(sex_with_missing)
```

    ## sex_with_missing
    ## Female   Male 
    ##      2      1

``` r
table(sex_with_missing, useNA = "ifany")
```

    ## sex_with_missing
    ## Female   Male   <NA> 
    ##      2      1      1

These are descriptive counts. Later chapters will explore frequency
tables and statistical analysis in greater depth.

------------------------------------------------------------------------

## 9.20 Character columns versus factors

A character column contains text labels:

``` r
class(patients$sex)
```

    ## [1] "character"

A factor stores categorical levels:

``` r
patients$sex_factor <- factor(
  patients$sex,
  levels = c("Female", "Male")
)
```

Inspect:

``` r
class(patients$sex_factor)
```

    ## [1] "factor"

``` r
levels(patients$sex_factor)
```

    ## [1] "Female" "Male"

``` r
table(patients$sex_factor)
```

    ## 
    ## Female   Male 
    ##      3      2

Factors are useful for categorical variables, but their internal integer
codes should not be confused with numeric measurements.

### The factor-to-numeric trap

``` r
coded <- factor(c("10", "20", "10"))
as.numeric(coded)
```

    ## [1] 1 2 1

The result is the factor’s internal level codes, not the numbers 10 and
20.

To convert numeric-looking factor labels:

``` r
as.numeric(as.character(coded))
```

    ## [1] 10 20 10

This works only when the labels genuinely represent valid numeric
values.

------------------------------------------------------------------------

## 9.21 Duplicate participant identifiers

A participant-level dataset often requires unique IDs.

``` r
anyDuplicated(patients$patient_id)
```

    ## [1] 0

The result is zero when no duplicate is found.

We can check:

``` r
any(duplicated(patients$patient_id))
```

    ## [1] FALSE

And enforce uniqueness:

``` r
stopifnot(!anyDuplicated(patients$patient_id))
```

### Demonstration with a duplicate

``` r
duplicate_demo <- data.frame(
  patient_id = c("P001", "P002", "P002", "P003"),
  sbp = c(120, 140, 145, 130)
)

duplicate_demo[duplicated(duplicate_demo$patient_id), ]
```

    ##   patient_id sbp
    ## 3       P002 145

**Important:** Duplicate IDs are not automatically errors. In a
longitudinal dataset, the same participant may legitimately appear at
multiple visits. In that case, uniqueness may need to be checked on the
**combination** of participant ID and visit.

``` r
longitudinal_demo <- data.frame(
  patient_id = c("P001", "P001", "P002", "P002"),
  visit = c("Baseline", "Followup", "Baseline", "Followup"),
  sbp = c(140, 132, 150, 143)
)

key <- paste(
  longitudinal_demo$patient_id,
  longitudinal_demo$visit,
  sep = "::"
)

stopifnot(!anyDuplicated(key))
```

For production pipelines, we should ensure that our chosen separator
cannot create ambiguous combined keys, or use a more robust multi-column
duplicate check.

------------------------------------------------------------------------

## 9.22 Row names versus participant identifiers

R allows row names:

``` r
small <- data.frame(
  age = c(34, 57, 49),
  sbp = c(118, 152, 143)
)
rownames(small) <- c("P001", "P002", "P003")
small
```

    ##      age sbp
    ## P001  34 118
    ## P002  57 152
    ## P003  49 143

However, row names are not a substitute for a documented identifier
variable in most research workflows. They can be lost, reset, or changed
during data processing and file import/export.

Prefer:

``` r
small2 <- data.frame(
  patient_id = c("P001", "P002", "P003"),
  age = c(34, 57, 49),
  sbp = c(118, 152, 143)
)
small2
```

    ##   patient_id age sbp
    ## 1       P001  34 118
    ## 2       P002  57 152
    ## 3       P003  49 143

------------------------------------------------------------------------

## 9.23 Combining rows with `rbind()`

Suppose two study sites collected the same variables.

``` r
site_a <- data.frame(
  patient_id = c("A001", "A002"),
  age = c(35, 49),
  sbp = c(125, 142)
)

site_b <- data.frame(
  patient_id = c("B001", "B002"),
  age = c(53, 61),
  sbp = c(148, 155)
)
```

Combine by rows:

``` r
combined_sites <- rbind(site_a, site_b)
combined_sites
```

    ##   patient_id age sbp
    ## 1       A001  35 125
    ## 2       A002  49 142
    ## 3       B001  53 148
    ## 4       B002  61 155

This works because the columns correspond.

### Validate before combining

``` r
identical(names(site_a), names(site_b))
```

    ## [1] TRUE

``` r
sapply(site_a, class)
```

    ##  patient_id         age         sbp 
    ## "character"   "numeric"   "numeric"

``` r
sapply(site_b, class)
```

    ##  patient_id         age         sbp 
    ## "character"   "numeric"   "numeric"

Column names, types, coding schemes, and measurement units must be
harmonized before combining datasets.

For example, SBP measured in mmHg must not be combined with a different
unit without conversion.

------------------------------------------------------------------------

## 9.24 Combining columns with `cbind()`

Suppose participant-level variables are held in separate objects with
the **same row order**.

``` r
demographics <- data.frame(
  patient_id = c("P001", "P002", "P003"),
  age = c(34, 57, 49)
)

measurements <- data.frame(
  sbp = c(118, 152, 143),
  glucose = c(92, 128, 110)
)

cbind(demographics, measurements)
```

    ##   patient_id age sbp glucose
    ## 1       P001  34 118      92
    ## 2       P002  57 152     128
    ## 3       P003  49 143     110

`cbind()` combines by **position**, not by participant identifier.

If row orders differ, it can silently misalign records.

``` r
measurements_with_ids <- data.frame(
  patient_id = c("P003", "P001", "P002"),
  sbp = c(143, 118, 152)
)
```

Do **not** assume the first row of `measurements_with_ids` belongs to
the first row of `demographics`.

### Align with `match()`

``` r
positions <- match(
  demographics$patient_id,
  measurements_with_ids$patient_id
)

positions
```

    ## [1] 2 3 1

Use these positions to reorder:

``` r
aligned_measurements <- measurements_with_ids[positions, , drop = FALSE]

stopifnot(identical(
  demographics$patient_id,
  aligned_measurements$patient_id
))

combined_aligned <- data.frame(
  demographics,
  sbp = aligned_measurements$sbp
)

combined_aligned
```

    ##   patient_id age sbp
    ## 1       P001  34 118
    ## 2       P002  57 152
    ## 3       P003  49 143

This example demonstrates an important research principle: **record
alignment must be verified by identifiers, not assumed from row order**.

We will study joins and merges in detail in Chapter 27.

------------------------------------------------------------------------

## 9.25 `merge()` preview: combining by a key

Base R includes `merge()` for joining datasets by shared keys.

``` r
clinical <- data.frame(
  patient_id = c("P001", "P002", "P003"),
  sbp = c(118, 152, 143)
)

lab <- data.frame(
  patient_id = c("P003", "P001", "P002"),
  glucose = c(110, 92, 128)
)

merged <- merge(clinical, lab, by = "patient_id")
merged
```

    ##   patient_id sbp glucose
    ## 1       P001 118      92
    ## 2       P002 152     128
    ## 3       P003 143     110

This matches records using `patient_id`, not their original row
positions.

However, joins can create duplicated rows when keys are not unique. We
must verify key uniqueness and expected row counts.

``` r
stopifnot(!anyDuplicated(clinical$patient_id))
stopifnot(!anyDuplicated(lab$patient_id))
nrow(merged)
```

    ## [1] 3

We will cover join types, unmatched records, and many-to-many
relationships later in the book.

------------------------------------------------------------------------

## 9.26 The difference between a data frame and a matrix

Consider a mixed-type data frame:

``` r
mixed <- data.frame(
  id = c("P1", "P2"),
  age = c(35, 50),
  smoker = c(FALSE, TRUE)
)

str(mixed)
```

    ## 'data.frame':    2 obs. of  3 variables:
    ##  $ id    : chr  "P1" "P2"
    ##  $ age   : num  35 50
    ##  $ smoker: logi  FALSE TRUE

Convert it to a matrix:

``` r
mixed_matrix <- as.matrix(mixed)
typeof(mixed_matrix)
```

    ## [1] "character"

``` r
mixed_matrix
```

    ##      id   age  smoker 
    ## [1,] "P1" "35" "FALSE"
    ## [2,] "P2" "50" "TRUE"

Because the matrix must have one atomic type, the values are coerced to
character.

This matters when preparing inputs for statistical or machine-learning
functions that require numeric matrices. We should select and validate
numeric columns explicitly.

``` r
numeric_only <- mixed[, "age", drop = FALSE]
as.matrix(numeric_only)
```

    ##      age
    ## [1,]  35
    ## [2,]  50

------------------------------------------------------------------------

## 9.27 A data frame is a list of columns

We can inspect the list-like behavior directly:

``` r
is.list(patients)
```

    ## [1] TRUE

``` r
length(patients)
```

    ## [1] 13

``` r
ncol(patients)
```

    ## [1] 13

For a data frame, `length()` returns the number of **columns**, not
rows.

``` r
length(patients) == ncol(patients)
```

    ## [1] TRUE

Access a column by list index:

``` r
patients[[1]]
```

    ## [1] "P001" "P002" "P003" "P004" "P005"

Or retain it as a one-column data frame:

``` r
patients[1]
```

    ##   patient_id
    ## 1       P001
    ## 2       P002
    ## 3       P003
    ## 4       P004
    ## 5       P005

Compare:

``` r
class(patients[[1]])
```

    ## [1] "character"

``` r
class(patients[1])
```

    ## [1] "data.frame"

`[[1]]` extracts the underlying vector; `[1]` returns a one-column data
frame.

This distinction builds directly on Chapter 8 — Lists.

------------------------------------------------------------------------

## 9.28 Column selection using names

We may need only a subset of variables for an analysis.

``` r
analysis_vars <- c(
  "patient_id",
  "age",
  "sbp",
  "glucose_mg_dl"
)

analysis_data <- patients[, analysis_vars, drop = FALSE]
analysis_data
```

    ##   patient_id age sbp glucose_mg_dl
    ## 1       P001  34 118            92
    ## 2       P002  57 152           128
    ## 3       P003  49 143           110
    ## 4       P004  62 135           105
    ## 5       P005  41 125            99

Before selecting, check that every requested column exists:

``` r
stopifnot(all(analysis_vars %in% names(patients)))
```

Without validation, misspelled or absent names can stop an analysis or
produce unintended behavior.

### Selecting numeric columns

``` r
numeric_columns <- sapply(patients, is.numeric)
numeric_columns
```

    ##     patient_id            age            sex            sbp  glucose_mg_dl 
    ##          FALSE           TRUE          FALSE           TRUE           TRUE 
    ##         smoker            dbp pulse_pressure      weight_kg       height_m 
    ##          FALSE           TRUE           TRUE           TRUE           TRUE 
    ##            bmi       high_sbp     sex_factor 
    ##           TRUE          FALSE          FALSE

``` r
patients[, numeric_columns, drop = FALSE]
```

    ##   age sbp glucose_mg_dl dbp pulse_pressure weight_kg height_m      bmi
    ## 1  34 118            92  76             42        62     1.62 23.62445
    ## 2  57 152           128  94             58        84     1.75 27.42857
    ## 3  49 143           110  88             55        71     1.66 25.76571
    ## 4  62 135           105  84             51        79     1.70 27.33564
    ## 5  41 125            99  79             46        68     1.64 25.28257

This is convenient for exploration, but numeric columns can include
identifiers or categorical codes that should not be treated as
continuous measurements.

------------------------------------------------------------------------

## 9.29 Working with `NA`, `"NA"`, and blank strings

These values are not interchangeable:

``` r
values <- c(100, NA, 120)
is.na(values)
```

    ## [1] FALSE  TRUE FALSE

Now consider text:

``` r
text_values <- c("100", "NA", "", "120")
is.na(text_values)
```

    ## [1] FALSE FALSE FALSE FALSE

The string `"NA"` and the empty string `""` are not automatically
missing values in an existing character vector.

We can explicitly standardize documented missing-value codes:

``` r
text_values[text_values %in% c("NA", "")] <- NA_character_
text_values
```

    ## [1] "100" NA    NA    "120"

Only after confirming the data dictionary should we convert:

``` r
as.numeric(text_values)
```

    ## [1] 100  NA  NA 120

Different studies may use codes such as `"unknown"`, `"not collected"`,
`-9`, or `999`. Treating these as real measurements can produce serious
analytical errors.

------------------------------------------------------------------------

## 9.30 Validating clinical ranges

Data frames make it easy to check values against expected ranges.

``` r
range(patients$age)
```

    ## [1] 34 62

``` r
range(patients$sbp)
```

    ## [1] 118 152

``` r
range(patients$height_m)
```

    ## [1] 1.62 1.75

Suppose our study requires positive age, SBP, and height:

``` r
stopifnot(all(patients$age > 0))
stopifnot(all(patients$sbp > 0))
stopifnot(all(patients$height_m > 0))
```

With missing values, `all()` may return `NA`. We should decide whether
missingness is allowed:

``` r
all(!is.na(patients_na$sbp) & patients_na$sbp > 0)
```

    ## [1] FALSE

This returns `FALSE` if any SBP is missing or nonpositive.

Alternatively, inspect violations without assuming that missing values
are invalid:

``` r
bad_sbp <- !is.na(patients_na$sbp) &
  patients_na$sbp <= 0

patients_na[bad_sbp, ]
```

    ##  [1] patient_id     age            sex            sbp            glucose_mg_dl 
    ##  [6] smoker         dbp            pulse_pressure weight_kg      height_m      
    ## [11] bmi            high_sbp      
    ## <0 rows> (or 0-length row.names)

The clinically plausible range depends on population, instrument, and
study protocol. Our examples are basic structural checks, not
comprehensive clinical QC rules.

------------------------------------------------------------------------

## 9.31 Data frames in genomics: GWAS summary statistics

GWAS summary statistics are commonly stored in rectangular tables.

Create a small synthetic example:

``` r
gwas <- data.frame(
  CHROM = c(6L, 6L, 6L, 1L, 2L),
  POS = c(26295926L, 31298240L, 32626565L, 1234567L, 7654321L),
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE"),
  A1 = c("A", "C", "G", "T", "A"),
  A2 = c("G", "T", "A", "C", "C"),
  BETA = c(0.05, -0.08, 0.12, 0.02, -0.03),
  SE = c(0.01, 0.02, 0.02, 0.02, 0.01),
  PVAL = c(2e-8, 3e-9, 5e-12, 0.30, 0.01)
)

str(gwas)
```

    ## 'data.frame':    5 obs. of  8 variables:
    ##  $ CHROM: int  6 6 6 1 2
    ##  $ POS  : int  26295926 31298240 32626565 1234567 7654321
    ##  $ ID   : chr  "rsA" "rsB" "rsC" "rsD" ...
    ##  $ A1   : chr  "A" "C" "G" "T" ...
    ##  $ A2   : chr  "G" "T" "A" "C" ...
    ##  $ BETA : num  0.05 -0.08 0.12 0.02 -0.03
    ##  $ SE   : num  0.01 0.02 0.02 0.02 0.01
    ##  $ PVAL : num  2e-08 3e-09 5e-12 3e-01 1e-02

``` r
gwas
```

    ##   CHROM      POS  ID A1 A2  BETA   SE  PVAL
    ## 1     6 26295926 rsA  A  G  0.05 0.01 2e-08
    ## 2     6 31298240 rsB  C  T -0.08 0.02 3e-09
    ## 3     6 32626565 rsC  G  A  0.12 0.02 5e-12
    ## 4     1  1234567 rsD  T  C  0.02 0.02 3e-01
    ## 5     2  7654321 rsE  A  C -0.03 0.01 1e-02

These are illustrative values, not real association results.

### Select chromosome 6

``` r
chr6 <- gwas[gwas$CHROM == 6, ]
chr6
```

    ##   CHROM      POS  ID A1 A2  BETA   SE  PVAL
    ## 1     6 26295926 rsA  A  G  0.05 0.01 2e-08
    ## 2     6 31298240 rsB  C  T -0.08 0.02 3e-09
    ## 3     6 32626565 rsC  G  A  0.12 0.02 5e-12

### Select an example genomic interval

``` r
region <- gwas[
  gwas$CHROM == 6 &
    gwas$POS >= 25000000 &
    gwas$POS <= 34000000,
]

region
```

    ##   CHROM      POS  ID A1 A2  BETA   SE  PVAL
    ## 1     6 26295926 rsA  A  G  0.05 0.01 2e-08
    ## 2     6 31298240 rsB  C  T -0.08 0.02 3e-09
    ## 3     6 32626565 rsC  G  A  0.12 0.02 5e-12

### Select variants below a p-value threshold

``` r
significant <- gwas[
  !is.na(gwas$PVAL) & gwas$PVAL < 5e-8,
]

significant
```

    ##   CHROM      POS  ID A1 A2  BETA   SE  PVAL
    ## 1     6 26295926 rsA  A  G  0.05 0.01 2e-08
    ## 2     6 31298240 rsB  C  T -0.08 0.02 3e-09
    ## 3     6 32626565 rsC  G  A  0.12 0.02 5e-12

### Calculate a Z statistic

$$Z=\frac{\beta}{SE}$$

``` r
gwas$Z <- gwas$BETA / gwas$SE
gwas[, c("ID", "BETA", "SE", "Z")]
```

    ##    ID  BETA   SE  Z
    ## 1 rsA  0.05 0.01  5
    ## 2 rsB -0.08 0.02 -4
    ## 3 rsC  0.12 0.02  6
    ## 4 rsD  0.02 0.02  1
    ## 5 rsE -0.03 0.01 -3

We must verify that `SE` is positive and that `BETA` and `SE` correspond
to the same effect allele.

``` r
stopifnot(all(gwas$SE > 0))
```

### Sort by p-value

``` r
gwas[order(gwas$PVAL), c("ID", "CHROM", "POS", "PVAL")]
```

    ##    ID CHROM      POS  PVAL
    ## 3 rsC     6 32626565 5e-12
    ## 2 rsB     6 31298240 3e-09
    ## 1 rsA     6 26295926 2e-08
    ## 5 rsE     2  7654321 1e-02
    ## 4 rsD     1  1234567 3e-01

### Important genomic cautions

A GWAS table is not automatically harmonized. Before combining summary
statistics from different studies, we must check genome build,
chromosome and position representation, allele definitions, variant IDs,
duplicate variants, and effect-allele orientation. These issues are
covered in later genomics chapters.

------------------------------------------------------------------------

## 9.32 A small epidemiology example: follow-up records

A longitudinal dataset can have more than one row per participant.

``` r
followup <- data.frame(
  patient_id = c("P001", "P001", "P002", "P002", "P003", "P003"),
  visit = c("Baseline", "Month6", "Baseline", "Month6",
            "Baseline", "Month6"),
  sbp = c(146, 138, 152, 147, 135, 131)
)

followup
```

    ##   patient_id    visit sbp
    ## 1       P001 Baseline 146
    ## 2       P001   Month6 138
    ## 3       P002 Baseline 152
    ## 4       P002   Month6 147
    ## 5       P003 Baseline 135
    ## 6       P003   Month6 131

In this format, the unit of observation is a **participant-visit
record**, not a unique participant.

### Select baseline records

``` r
followup[followup$visit == "Baseline", ]
```

    ##   patient_id    visit sbp
    ## 1       P001 Baseline 146
    ## 3       P002 Baseline 152
    ## 5       P003 Baseline 135

### Select follow-up records

``` r
followup[followup$visit == "Month6", ]
```

    ##   patient_id  visit sbp
    ## 2       P001 Month6 138
    ## 4       P002 Month6 147
    ## 6       P003 Month6 131

### Count rows per participant

``` r
table(followup$patient_id)
```

    ## 
    ## P001 P002 P003 
    ##    2    2    2

### Check uniqueness of participant-visit combinations

``` r
duplicated(followup[c("patient_id", "visit")])
```

    ## [1] FALSE FALSE FALSE FALSE FALSE FALSE

Each participant appears twice, but no participant-visit combination is
duplicated.

We will learn to reshape between wide and long representations in
Chapter 28.

------------------------------------------------------------------------

## 9.33 Guided practical: build a hypertension screening dataset

We will work through a complete small example.

### Step 1: create the study data

``` r
screening <- data.frame(
  id = c("S001", "S002", "S003", "S004", "S005", "S006"),
  age = c(42, 58, 35, 64, 51, 47),
  sbp = c(148, 155, 128, 142, NA, 150),
  dbp = c(92, 96, 80, 88, 90, 94),
  diabetes = c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE),
  consent = c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE)
)

screening
```

    ##     id age sbp dbp diabetes consent
    ## 1 S001  42 148  92    FALSE    TRUE
    ## 2 S002  58 155  96     TRUE    TRUE
    ## 3 S003  35 128  80    FALSE    TRUE
    ## 4 S004  64 142  88    FALSE   FALSE
    ## 5 S005  51  NA  90    FALSE    TRUE
    ## 6 S006  47 150  94    FALSE    TRUE

### Step 2: inspect structure and missingness

``` r
dim(screening)
```

    ## [1] 6 6

``` r
str(screening)
```

    ## 'data.frame':    6 obs. of  6 variables:
    ##  $ id      : chr  "S001" "S002" "S003" "S004" ...
    ##  $ age     : num  42 58 35 64 51 47
    ##  $ sbp     : num  148 155 128 142 NA 150
    ##  $ dbp     : num  92 96 80 88 90 94
    ##  $ diabetes: logi  FALSE TRUE FALSE FALSE FALSE FALSE
    ##  $ consent : logi  TRUE TRUE TRUE FALSE TRUE TRUE

``` r
colSums(is.na(screening))
```

    ##       id      age      sbp      dbp diabetes  consent 
    ##        0        0        1        0        0        0

### Step 3: validate identifiers

``` r
stopifnot(!anyDuplicated(screening$id))
stopifnot(all(!is.na(screening$id)))
```

### Step 4: calculate pulse pressure

``` r
screening$pulse_pressure <- screening$sbp - screening$dbp
```

The participant with missing SBP also has missing pulse pressure.

### Step 5: define eligibility

For this hypothetical study, require:

- age between 40 and 65 inclusive;
- SBP at least 140 mmHg;
- no diabetes;
- consent given;
- SBP observed.

``` r
screening$eligible <-
  !is.na(screening$sbp) &
  screening$age >= 40 &
  screening$age <= 65 &
  screening$sbp >= 140 &
  !screening$diabetes &
  screening$consent
```

### Step 6: inspect eligibility

``` r
screening[, c("id", "age", "sbp", "diabetes", "consent", "eligible")]
```

    ##     id age sbp diabetes consent eligible
    ## 1 S001  42 148    FALSE    TRUE     TRUE
    ## 2 S002  58 155     TRUE    TRUE    FALSE
    ## 3 S003  35 128    FALSE    TRUE    FALSE
    ## 4 S004  64 142    FALSE   FALSE    FALSE
    ## 5 S005  51  NA    FALSE    TRUE    FALSE
    ## 6 S006  47 150    FALSE    TRUE     TRUE

### Step 7: extract eligible participants

``` r
eligible_participants <- screening[
  screening$eligible,
  ,
  drop = FALSE
]

eligible_participants
```

    ##     id age sbp dbp diabetes consent pulse_pressure eligible
    ## 1 S001  42 148  92    FALSE    TRUE             56     TRUE
    ## 6 S006  47 150  94    FALSE    TRUE             56     TRUE

### Step 8: sort by SBP

``` r
eligible_participants[
  order(eligible_participants$sbp, decreasing = TRUE),
  c("id", "age", "sbp", "pulse_pressure")
]
```

    ##     id age sbp pulse_pressure
    ## 6 S006  47 150             56
    ## 1 S001  42 148             56

### Step 9: summarize

``` r
nrow(screening)
```

    ## [1] 6

``` r
sum(screening$eligible)
```

    ## [1] 2

``` r
mean(screening$eligible)
```

    ## [1] 0.3333333

The mean of a logical indicator is the proportion `TRUE`, provided there
are no missing indicator values.

### Step 10: verify the screening result

``` r
stopifnot(!anyNA(screening$eligible))
stopifnot(all(eligible_participants$consent))
stopifnot(all(!eligible_participants$diabetes))
stopifnot(all(eligible_participants$sbp >= 140))
```

This workflow illustrates a reproducible sequence: create, inspect,
validate, derive, filter, sort, and summarize.

------------------------------------------------------------------------

## 9.34 Common mistakes

### Mistake 1: confusing rows and columns

``` r
data[2, 3]
```

means row 2, column 3.

### Mistake 2: assuming `length(data)` counts participants

For a data frame, `length(data)` counts columns. Use `nrow(data)` for
the number of rows.

### Mistake 3: sorting one column independently

Sorting only SBP can destroy its alignment with patient IDs. Reorder
whole rows with `data[order(data$sbp), ]`.

### Mistake 4: forgetting `drop = FALSE`

Selecting one column may return a vector instead of a data frame.

### Mistake 5: filtering with missing logical values

`data[data$sbp >= 140, ]` can include an `NA` row if SBP is missing. Use
`!is.na(data$sbp) & ...` when the criterion requires an observed value.

### Mistake 6: converting a factor directly to numeric

`as.numeric(factor(c("10", "20")))` returns factor codes, not the
intended numbers.

### Mistake 7: treating patient IDs as ordinary numeric measurements

Identifiers such as `"00125"` may lose leading zeros if converted to
numeric.

### Mistake 8: using `cbind()` without checking row order

Equal row counts do not establish that records correspond to the same
participants.

### Mistake 9: assuming duplicate IDs always mean errors

In longitudinal data, participant IDs repeat across visits. Validate the
appropriate composite key.

### Mistake 10: assuming derived columns update automatically

If SBP changes, a previously calculated `high_sbp` column must be
recomputed.

### Mistake 11: confusing `NA`, `"NA"`, and `NULL`

`NA` is a missing value; `"NA"` is text; assigning `NULL` to a
data-frame column removes it.

### Mistake 12: failing to check units and coding schemes

Two columns named `glucose` may use different units or missing-value
codes. Matching names alone does not establish comparability.

------------------------------------------------------------------------

## 9.35 Independent exercises: clinical dataset

Create the following dataset:

``` r
exercise_data <- data.frame(
  id = c("P01", "P02", "P03", "P04", "P05", "P06"),
  age = c(25, 46, 61, 38, 55, 49),
  sex = c("Female", "Male", "Female", "Male", "Female", "Male"),
  sbp = c(116, 148, 157, 130, NA, 143),
  dbp = c(74, 92, 96, 82, 88, 90),
  glucose = c(88, 109, 132, 96, 118, 104),
  smoker = c(FALSE, TRUE, FALSE, FALSE, TRUE, FALSE)
)
```

Complete the following tasks independently:

1.  Display the data frame.
2.  Find the number of rows and columns.
3.  Display all column names.
4.  Identify the class of every column.
5.  Extract the `sbp` column as a vector.
6.  Extract `sbp` as a one-column data frame.
7.  Select rows 2, 4, and 6.
8.  Select `id`, `age`, and `glucose`.
9.  Select participants older than 45.
10. Select participants who are smokers.
11. Select participants with observed SBP at least 140.
12. Calculate pulse pressure.
13. Create a logical column indicating glucose at least 126.
14. Count missing values in each column.
15. Calculate mean SBP using available observations.
16. Sort all records by age.
17. Sort all records by decreasing SBP; consider how missing values are
    handled.
18. Count participants by sex.
19. Count smokers by sex.
20. Verify that participant IDs are unique.
21. Rename `glucose` to `glucose_mg_dl`.
22. Create a data frame containing only `id`, `age`, `sbp`, and
    `glucose_mg_dl`.
23. Explain why sorting `exercise_data$sbp` alone is unsafe.
24. Explain the difference between `exercise_data["age"]` and
    `exercise_data[["age"]]`.
25. Explain why the number of rows is not always the number of unique
    participants in longitudinal studies.

------------------------------------------------------------------------

## 9.36 Independent exercises: genomics dataset

Use the following synthetic GWAS table:

``` r
gwas_exercise <- data.frame(
  CHROM = c(6L, 6L, 6L, 1L, 3L, 6L),
  POS = c(27000000L, 29000000L, 32500000L,
          1500000L, 2000000L, 34000000L),
  ID = c("rs1", "rs2", "rs3", "rs4", "rs5", "rs6"),
  BETA = c(0.04, -0.07, 0.10, 0.02, -0.03, 0.06),
  SE = c(0.01, 0.02, 0.02, 0.02, 0.02, 0.015),
  PVAL = c(1e-8, 2e-9, 1e-12, 0.20, 0.03, 7e-7)
)
```

Tasks:

1.  Inspect dimensions and column types.
2.  Select chromosome 6 variants.
3.  Select variants in chromosome 6 from 28,000,000 to 33,000,000,
    inclusive.
4.  Select variants with `PVAL < 5e-8`.
5.  Calculate `Z = BETA / SE`.
6.  Identify variants with negative effect estimates.
7.  Sort by ascending p-value.
8.  Check for duplicate variant IDs.
9.  Check for nonpositive standard errors.
10. Explain why allele information and genome build would be required
    before integrating these results with another GWAS.

------------------------------------------------------------------------

## 9.37 Challenge: validate and clean a messy dataset

Consider:

``` r
messy <- data.frame(
  patient_id = c("001", "002", "002", "004", "005"),
  age = c("34", "58", "58", "unknown", "46"),
  sbp = c(118, 152, 152, -9, 145),
  consent = c("Yes", "Yes", "Yes", "No", "Yes")
)

messy
```

    ##   patient_id     age sbp consent
    ## 1        001      34 118     Yes
    ## 2        002      58 152     Yes
    ## 3        002      58 152     Yes
    ## 4        004 unknown  -9      No
    ## 5        005      46 145     Yes

Tasks:

1.  Identify the type of every column.
2.  Detect duplicated participant IDs.
3.  Explain why `"001"` should remain character.
4.  Convert age to numeric after handling `"unknown"` as missing.
5.  Treat `-9` as missing **only if** the study codebook defines it as a
    missing-value code.
6.  Convert consent into a logical variable with `TRUE` for `"Yes"` and
    `FALSE` for `"No"`.
7.  Count missing values by column.
8.  Identify participants aged at least 40 with observed SBP at least
    140 and consent.
9.  Explain whether the duplicated row should be removed automatically.
10. Write at least three validation checks for the cleaned dataset.

**Research reasoning:** Duplicate IDs may reflect accidental duplicate
records, repeated visits, or conflicting source entries. We should
investigate before deleting records.

------------------------------------------------------------------------

## 9.38 Complete standalone practice script

The following consolidated script is provided for independent practice.
It is not executed when knitting this chapter because the individual
examples have already been demonstrated.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 9: Data Frames
# Base R only
# ============================================================

# 1. Create a participant dataset
study <- data.frame(
  id = c("P001", "P002", "P003", "P004"),
  age = c(34, 57, 49, 62),
  sbp = c(118, 152, NA, 135),
  dbp = c(76, 94, 88, 84),
  smoker = c(FALSE, TRUE, FALSE, TRUE)
)

# 2. Inspect
dim(study)
names(study)
str(study)
head(study)
summary(study)

# 3. Select columns and rows
study$sbp
study[["sbp"]]
study[, "sbp", drop = FALSE]
study[1:2, c("id", "age", "sbp")]

# 4. Derive a variable
study$pulse_pressure <- study$sbp - study$dbp

# 5. Missingness
colSums(is.na(study))
mean(study$sbp, na.rm = TRUE)

# 6. Safe filtering
keep <- !is.na(study$sbp) & study$sbp >= 140
study[keep, , drop = FALSE]

# 7. Sort whole records
study_sorted <- study[order(study$sbp), ]
study_sorted

# 8. Validate identifiers
stopifnot(!anyDuplicated(study$id))
stopifnot(all(!is.na(study$id)))

# 9. Build a synthetic GWAS table
gwas <- data.frame(
  CHROM = c(6L, 6L, 1L),
  POS = c(31298240L, 32626565L, 1000000L),
  ID = c("rsA", "rsB", "rsC"),
  BETA = c(0.05, -0.08, 0.01),
  SE = c(0.01, 0.02, 0.01),
  PVAL = c(1e-8, 2e-10, 0.3)
)

stopifnot(all(gwas$SE > 0))
gwas$Z <- gwas$BETA / gwas$SE

chr6 <- gwas[gwas$CHROM == 6, ]
significant <- gwas[
  !is.na(gwas$PVAL) & gwas$PVAL < 5e-8,
]

print(chr6)
print(significant)
```

------------------------------------------------------------------------

## 9.39 Essential functions reference

| Purpose                     | Function or syntax                |
|-----------------------------|-----------------------------------|
| Create data frame           | `data.frame()`                    |
| Check structure             | `str()`                           |
| View dimensions             | `dim()`, `nrow()`, `ncol()`       |
| Column names                | `names()`, `colnames()`           |
| Row names                   | `rownames()`                      |
| Preview records             | `head()`, `tail()`                |
| Summary                     | `summary()`                       |
| Extract a column            | `$`, `[[ ]]`                      |
| Subset rows and columns     | `[rows, columns]`                 |
| Preserve a data frame       | `drop = FALSE`                    |
| Filter interactively        | `subset()`                        |
| Sort row indices            | `order()`                         |
| Count missing values        | `is.na()`, `colSums()`            |
| Identify complete rows      | `complete.cases()`                |
| Count categories            | `table()`                         |
| Identify duplicates         | `duplicated()`, `anyDuplicated()` |
| Combine rows                | `rbind()`                         |
| Combine columns by position | `cbind()`                         |
| Match identifiers           | `match()`                         |
| Join on a key               | `merge()`                         |
| Remove a column             | `data$column <- NULL`             |
| Check membership            | `%in%`                            |
| Validate assumptions        | `stopifnot()`                     |

------------------------------------------------------------------------

## 9.40 Chapter review questions

Before proceeding, we should be able to answer the following without
consulting the examples:

1.  What makes a data frame different from a matrix?
2.  Why does `typeof(data_frame)` return `"list"`?
3.  What does `length(data_frame)` count?
4.  How do `$`, `[[ ]]`, and `[ , ]` differ?
5.  When is `drop = FALSE` necessary?
6.  How do we select rows satisfying multiple conditions?
7.  What happens when a filtering condition contains `NA`?
8.  How do we count missing values by column?
9.  How do we create and update derived variables?
10. Why must an entire data frame be reordered when sorting SBP?
11. How can we detect duplicated patient identifiers?
12. Why are duplicated patient IDs sometimes valid in longitudinal data?
13. Why can `cbind()` produce scientifically incorrect results?
14. How can `match()` help align participant records?
15. Why should we verify measurement units and coding schemes before
    combining datasets?
16. What additional metadata would we need before combining GWAS summary
    statistics?
17. Why is a dedicated participant-ID column preferable to relying on
    row names?
18. What is the difference between `NA`, `"NA"`, and `NULL`?
19. Why might a factor-to-numeric conversion produce unexpected numbers?
20. What checks should we perform before interpreting a newly imported
    dataset?

## 9.41 Key takeaways

- A data frame stores observations in rows and variables in columns.
- Different columns can have different data types.
- Internally, a data frame is a list of equal-length columns.
- Use `nrow()` for the number of observations and `ncol()` for the
  number of variables.
- Use `$` or `[[ ]]` to extract column vectors.
- Use `[rows, columns, drop = FALSE]` to preserve a rectangular
  structure.
- Apply logical conditions carefully, especially when values may be
  missing.
- Sort entire rows to preserve the association between patient IDs and
  measurements.
- Validate identifiers, types, units, ranges, and missing-value codes.
- Combine datasets by verified identifiers, not assumed row order.
- A technically valid data frame can still contain scientifically
  invalid or misaligned data.

> **The most important principle is not merely to store data correctly
> in R, but to preserve the meaning of each observation and variable
> throughout the analysis.**

## 9.42 Looking ahead: Chapter 10 — Conditional Programming

We have already used logical expressions such as:

``` r
age >= 40 & sbp >= 140
```

So far, these expressions have helped us select rows. In **Chapter 10 —
Conditional Programming: `if`, `else`, and `ifelse()`**, we will learn
how to make R execute different actions depending on whether conditions
are satisfied.

For example, we will develop simple, transparent rules for data-quality
checks and research screening decisions. We will distinguish conditions
applied to one value from conditions applied across a vector or an
entire dataset, and learn to avoid common logical-programming errors.
