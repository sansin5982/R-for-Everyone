Introduction to R and RStudio
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

# Objects, Variables, and Basic Data Types in R

In the previous chapter, we became familiar with R and RStudio, used R
as a calculator, created simple objects, ran functions, and learned why
scripts are important for reproducible research. We now move to one of
the most fundamental ideas in R: **how information is represented and
stored**.

In biomedical research, we routinely work with age, participant ID, body
weight, disease status, genotype, laboratory measurements, and treatment
group. These variables may look similar in a spreadsheet, but they do
not necessarily represent the same kind of information.

``` text
Participant ID: P001
Age:            46
Sex:            Male
Weight:         82.0 kg
Diabetes:       No
```

R must store each value in an appropriate form. `"P001"` is text, age is
numeric, and a yes/no condition can often be represented logically as
`TRUE` or `FALSE`.

A central principle for this chapter is:

> **R works with the representation stored in an object; we remain
> responsible for its scientific meaning.**

## 2.1 Learning objectives

By the end of this chapter, we should be able to:

- explain objects and variables;
- create, copy, modify, and remove objects;
- understand numeric, integer, character, and logical data;
- distinguish `class()` from `typeof()`;
- inspect objects using `class()`, `typeof()`, `str()`, and `length()`;
- understand `NA`, `NaN`, `Inf`, `-Inf`, and `NULL`;
- detect missing and special values correctly;
- convert basic data types;
- understand automatic coercion;
- recognize common data-type problems in biomedical datasets;
- distinguish R storage type from scientific variable type.

# 2.2 From a scientific measurement to an R object

Suppose a participant weighs 75 kg. We can store the value as:

``` r
weight <- 75
weight
```

    ## [1] 75

Conceptually:

``` text
weight    <-    75
   ↑              ↑
object name      value
```

The assignment operator `<-` stores the value on the right under the
object name on the left.

``` text
Information → R object → calculation / function / analysis
```

# 2.3 Objects and variables

An **R object** is something stored in memory.

``` r
age <- 46
```

Here, `age` is an R object. Scientifically, age is also a **variable**
because it can vary between participants.

By contrast:

``` r
study_name <- "Cardiovascular Cohort"
```

`study_name` is an R object, but it is not necessarily a
participant-level research variable.

For introductory work, object and variable will sometimes appear in
closely related contexts, but this distinction becomes useful as
analyses become more complex.

# 2.4 Creating biomedical objects

``` r
patient_id <- "P001"
age <- 46
sex <- "Male"
weight <- 82
height <- 1.78
diabetes <- FALSE
```

We can inspect them by entering their names:

``` r
patient_id
```

    ## [1] "P001"

``` r
age
```

    ## [1] 46

``` r
sex
```

    ## [1] "Male"

``` r
weight
```

    ## [1] 82

``` r
height
```

    ## [1] 1.78

``` r
diabetes
```

    ## [1] FALSE

| Object       | Value    | Scientific meaning     |
|--------------|----------|------------------------|
| `patient_id` | `"P001"` | Participant identifier |
| `age`        | `46`     | Age in years           |
| `sex`        | `"Male"` | Sex category           |
| `weight`     | `82`     | Weight in kilograms    |
| `height`     | `1.78`   | Height in metres       |
| `diabetes`   | `FALSE`  | Diabetes status        |

# 2.5 Naming objects

Research scripts benefit from descriptive names:

``` r
fasting_glucose <- 105
systolic_bp <- 138
participant_id <- "P001"
```

Throughout this book, we will generally use **snake_case**.

R is case-sensitive:

``` r
age <- 46
Age <- 52
age
```

    ## [1] 46

``` r
Age
```

    ## [1] 52

`age`, `Age`, and `AGE` can therefore represent different objects.

Spaces should normally be avoided:

``` r
# Not appropriate ordinary syntax
fasting glucose <- 105

# Preferred
fasting_glucose <- 105
```

We should also avoid unnecessarily reusing familiar function names:

``` r
mean <- 25
```

A clearer name is:

``` r
mean_age <- 25
```

# 2.6 Assignment with `<-`

The conventional R assignment operator is `<-`:

``` r
glucose <- 105
```

R also permits:

``` r
cholesterol = 190
```

but we will generally use:

``` r
cholesterol <- 190
```

because it clearly communicates assignment.

# 2.7 Objects can change

``` r
weight <- 75
weight
```

    ## [1] 75

``` r
weight <- 78
weight
```

    ## [1] 78

The current value is now `78`. The earlier value has been overwritten.

# 2.8 Copying objects

``` r
baseline_weight <- 75
followup_weight <- baseline_weight

baseline_weight
```

    ## [1] 75

``` r
followup_weight
```

    ## [1] 75

Now change the first object:

``` r
baseline_weight <- 80

baseline_weight
```

    ## [1] 80

``` r
followup_weight
```

    ## [1] 75

`followup_weight` remains `75`. Assignment copied the value at that
point; it did not create a permanently linked relationship.

# 2.9 Derived objects do not automatically update

BMI is:

$$BMI=\frac{\text{weight}}{\text{height}^2}$$

``` r
weight <- 75
height <- 1.75
bmi <- weight / height^2
bmi
```

    ## [1] 24.4898

If weight changes:

``` r
weight <- 80
bmi
```

    ## [1] 24.4898

the previously stored `bmi` does not automatically recalculate. We must
run:

``` r
bmi <- weight / height^2
bmi
```

    ## [1] 26.12245

R executes instructions when they are run.

# 2.10 Basic data types

The four basic types needed first are:

``` text
numeric/double
integer
character
logical
```

More complex structures will be built from these later.

# 2.11 Numeric data

Biomedical measurements commonly use numeric values:

``` r
height <- 1.78
class(height)
```

    ## [1] "numeric"

``` r
typeof(height)
```

    ## [1] "double"

Typically:

``` text
class(height)  → "numeric"
typeof(height) → "double"
```

`class()` provides a higher-level R classification, while `typeof()`
describes the underlying storage type.

# 2.12 Whole numbers are usually doubles by default

``` r
age <- 46
class(age)
```

    ## [1] "numeric"

``` r
typeof(age)
```

    ## [1] "double"

Although `46` is a whole number, R normally stores a number written this
way as a double.

# 2.13 Integer data

An explicit integer uses `L`:

``` r
number_of_visits <- 5L
class(number_of_visits)
```

    ## [1] "integer"

``` r
typeof(number_of_visits)
```

    ## [1] "integer"

Compare:

``` r
x <- 5
y <- 5L

typeof(x)
```

    ## [1] "double"

``` r
typeof(y)
```

    ## [1] "integer"

The first is normally `"double"` and the second `"integer"`.

# 2.14 Character data

Character data represent text and identifiers:

``` r
patient_id <- "P001"
gene <- "HLA-DQB1"
snp_id <- "rs9273371"

class(patient_id)
```

    ## [1] "character"

``` r
typeof(patient_id)
```

    ## [1] "character"

Character values require quotation marks.

``` r
sex <- "Female"
```

Without quotes:

``` r
sex <- Female
```

R searches for an object named `Female`.

Single and double quotes are both valid, although we will generally use
double quotes:

``` r
diagnosis1 <- "Hypertension"
diagnosis2 <- 'Hypertension'
```

# 2.15 Numbers are not always quantitative variables

Participant IDs such as `"001"` should usually remain character values:

``` r
participant_id <- "001"
```

If stored as a number, leading zeros are lost and the identifier may be
mistaken for a quantitative measurement.

The same principle applies to genomic identifiers:

``` r
snp_id <- "rs9273371"
gene_id <- "ENSG00000179344"
```

A value containing digits is not automatically quantitative.

# 2.16 Logical data

Logical values are:

``` text
TRUE
FALSE
```

For example:

``` r
smoker <- TRUE
diabetes <- FALSE

class(smoker)
```

    ## [1] "logical"

``` r
typeof(smoker)
```

    ## [1] "logical"

Logical values are especially important because comparisons and
filtering operations produce `TRUE` and `FALSE`.

# 2.17 Logical values versus text

Compare:

``` r
x <- TRUE
y <- "TRUE"

class(x)
```

    ## [1] "logical"

``` r
class(y)
```

    ## [1] "character"

`TRUE` is logical; `"TRUE"` is character.

Likewise, `"Yes"` and `"No"` are character values:

``` r
smoking_status <- "Yes"
class(smoking_status)
```

    ## [1] "character"

R does not automatically interpret `"Yes"` as logical `TRUE`.

# 2.18 Inspecting objects

Useful inspection functions include:

``` r
fasting_glucose <- 108

class(fasting_glucose)
```

    ## [1] "numeric"

``` r
typeof(fasting_glucose)
```

    ## [1] "double"

``` r
str(fasting_glucose)
```

    ##  num 108

``` r
length(fasting_glucose)
```

    ## [1] 1

| Function   | Main question                           |
|------------|-----------------------------------------|
| `class()`  | How does R classify the object?         |
| `typeof()` | What is its underlying storage type?    |
| `str()`    | What is its compact internal structure? |
| `length()` | How many elements does it contain?      |

`str()` becomes especially valuable as objects become larger.

# 2.19 Testing types

``` r
age <- 46
patient_id <- "P001"
smoker <- FALSE
visits <- 5L

is.numeric(age)
```

    ## [1] TRUE

``` r
is.character(patient_id)
```

    ## [1] TRUE

``` r
is.logical(smoker)
```

    ## [1] TRUE

``` r
is.integer(visits)
```

    ## [1] TRUE

Type checking matters because imported values may not be stored as
expected.

For example, `"105"` looks numeric to us but is character data to R:

``` r
glucose <- "105"
class(glucose)
```

    ## [1] "character"

# 2.20 Special values

Real research data contain missing measurements and unusual
computational results. R provides:

``` text
NA
NaN
Inf
-Inf
NULL
```

They have different meanings.

# 2.21 `NA`: a missing value

``` r
fasting_glucose <- NA
```

This means the glucose value is unavailable.

It does **not** mean:

``` r
fasting_glucose <- 0
```

and it does not mean:

``` r
fasting_glucose <- "NA"
```

Compare:

``` r
x <- NA
y <- "NA"

is.na(x)
```

    ## [1] TRUE

``` r
is.na(y)
```

    ## [1] FALSE

Only `x` is genuinely missing.

# 2.22 Detecting missing values

We use:

``` r
glucose <- NA
is.na(glucose)
```

    ## [1] TRUE

We should not use:

``` r
glucose == NA
```

The rule is:

``` text
Incorrect: x == NA
Correct:   is.na(x)
```

# 2.23 Missing values propagate through calculations

``` r
x <- NA
x + 10
```

    ## [1] NA

``` r
x * 2
```

    ## [1] NA

Both remain `NA` because the original value is unknown.

A short vector preview is useful:

``` r
glucose <- c(95, 105, NA, 110)

mean(glucose)
```

    ## [1] NA

``` r
mean(glucose, na.rm = TRUE)
```

    ## [1] 103.3333

`na.rm = TRUE` tells the function to remove missing observations **for
that calculation**. It does not modify the original object.

Missing values can be counted using:

``` r
sum(is.na(glucose))
```

    ## [1] 1

Vectors receive full treatment in Chapter 4.

# 2.24 `NaN`: Not a Number

An undefined numerical calculation can produce `NaN`:

``` r
x <- 0 / 0
x
```

    ## [1] NaN

``` r
is.nan(x)
```

    ## [1] TRUE

``` r
is.na(x)
```

    ## [1] TRUE

`NaN` is a special numerical missing result. `is.na(NaN)` is also
`TRUE`.

However:

``` r
is.nan(NA)
```

    ## [1] FALSE

is `FALSE`.

# 2.25 `Inf` and `-Inf`

``` r
1 / 0
```

    ## [1] Inf

``` r
-1 / 0
```

    ## [1] -Inf

produce positive and negative infinity.

We can test:

``` r
x <- Inf
is.infinite(x)
```

    ## [1] TRUE

``` r
is.finite(x)
```

    ## [1] FALSE

Another example is:

``` r
log(0)
```

    ## [1] -Inf

which returns `-Inf`.

Infinite values can therefore arise during data transformations and
should not automatically be treated as ordinary measurements.

# 2.26 `NULL`: absence rather than a missing observation

``` r
x <- NULL
is.null(x)
```

    ## [1] TRUE

``` r
length(x)
```

    ## [1] 0

`length(NULL)` is zero.

Compare:

``` r
length(NA)
```

    ## [1] 1

which is one.

A useful distinction is:

``` text
NA   → a value is expected, but its value is missing
NULL → no value/component is present
```

For biomedical measurements, ordinary missing observations should
normally use `NA`, not `NULL`.

A common use of `NULL` is an optional function argument:

``` r
analyze_glucose <- function(glucose, cutoff = NULL) {
  if (is.null(cutoff)) {
    cutoff <- 126
  }
  glucose >= cutoff
}
```

Here `cutoff = NULL` means that no custom cutoff was supplied.

Lists will make `NULL` even clearer later:

``` r
patient <- list(
  id = "P001",
  age = 52,
  glucose = 108,
  genetic_test = NULL
)
```

# 2.27 Comparing special values

| Value  | Meaning                      |
|--------|------------------------------|
| `NA`   | Missing or unavailable value |
| `NaN`  | Undefined numerical result   |
| `Inf`  | Positive infinity            |
| `-Inf` | Negative infinity            |
| `NULL` | Absence of a value/component |

# 2.28 Explicit type conversion

Useful conversion functions include:

``` text
as.numeric()
as.integer()
as.character()
as.logical()
```

Example:

``` r
glucose_text <- "105"
glucose_numeric <- as.numeric(glucose_text)

class(glucose_text)
```

    ## [1] "character"

``` r
class(glucose_numeric)
```

    ## [1] "numeric"

# 2.29 Conversion warnings matter

``` r
x <- "high"
as.numeric(x)
```

    ## Warning: NAs introduced by coercion

    ## [1] NA

R returns `NA` and normally warns:

``` text
NAs introduced by coercion
```

The warning tells us that conversion failed. We should investigate why
rather than simply suppressing it.

A realistic example is:

``` r
glucose_raw <- c("95", "105", "Not measured", "110")
as.numeric(glucose_raw)
```

    ## Warning: NAs introduced by coercion

    ## [1]  95 105  NA 110

The text `"Not measured"` cannot be converted numerically.

In real research, we should understand the coding convention before
deciding that such a value represents missingness.

# 2.30 Other conversions

Numeric to character:

``` r
age <- 46
age_text <- as.character(age)

age_text
```

    ## [1] "46"

``` r
class(age_text)
```

    ## [1] "character"

Numeric to integer:

``` r
as.integer(5.8)
```

    ## [1] 5

``` r
round(5.8)
```

    ## [1] 6

`as.integer()` truncates toward zero; it is not a rounding function.

Logical to numeric:

``` r
as.numeric(TRUE)
```

    ## [1] 1

``` r
as.numeric(FALSE)
```

    ## [1] 0

gives 1 and 0.

Numeric to logical:

``` r
as.logical(1)
```

    ## [1] TRUE

``` r
as.logical(0)
```

    ## [1] FALSE

gives `TRUE` and `FALSE`.

Character strings `"TRUE"` and `"FALSE"` can be converted:

``` r
as.logical("TRUE")
```

    ## [1] TRUE

``` r
as.logical("FALSE")
```

    ## [1] FALSE

but `"Yes"` and `"No"` are not automatically interpreted as logical
values.

# 2.31 Automatic coercion

Atomic vectors require a common basic type.

``` r
x <- c(10, 20, "30")
x
```

    ## [1] "10" "20" "30"

``` r
typeof(x)
```

    ## [1] "character"

The whole vector becomes character.

A useful simplified hierarchy is:

``` text
logical → integer → double → character
```

Examples:

``` r
c(TRUE, 5L)
```

    ## [1] 1 5

``` r
c(TRUE, 5)
```

    ## [1] 1 5

``` r
c(5, "Male")
```

    ## [1] "5"    "Male"

R moves toward a type capable of representing all values.

# 2.32 Why coercion matters scientifically

Consider:

``` r
glucose <- c(95, 105, 110, "Not measured")
typeof(glucose)
```

    ## [1] "character"

The entire vector becomes character.

A better representation for a genuinely missing measurement is:

``` r
glucose <- c(95, 105, 110, NA)
typeof(glucose)
```

    ## [1] "double"

The vector remains numeric.

This is one reason proper missing-value coding matters.

# 2.33 R storage type versus scientific variable type

Suppose:

``` r
disease_code <- 1
```

R sees a number.

Scientifically, the coding may mean:

``` text
0 = Control
1 = Case
```

Disease status is therefore categorical even though its current storage
is numeric.

Likewise:

``` r
stage <- 3
```

may represent:

``` text
1 = Mild
2 = Moderate
3 = Severe
```

This is an ordinal category rather than necessarily a continuous
quantitative measurement.

> **R can tell us how data are stored; it cannot infer the scientific
> meaning of a coding scheme.**

# 2.34 Genomic example

A GWAS record might contain:

``` r
chromosome <- 6
position <- 32626565
snp_id <- "rs9273371"
effect_allele <- "A"
other_allele <- "G"
beta <- 0.08
standard_error <- 0.015
p_value <- 2.4e-09
```

Inspect:

``` r
class(chromosome)
```

    ## [1] "numeric"

``` r
class(position)
```

    ## [1] "numeric"

``` r
class(snp_id)
```

    ## [1] "character"

``` r
class(effect_allele)
```

    ## [1] "character"

``` r
class(beta)
```

    ## [1] "numeric"

``` r
class(p_value)
```

    ## [1] "numeric"

These values belong to the same record but have different meanings:

``` text
chromosome     → chromosome identifier
position       → genomic coordinate
snp_id         → variant identifier
effect_allele  → allele label
other_allele   → allele label
beta           → effect estimate
p_value        → statistical result
```

Scientific notation such as:

``` text
2.4e-09
```

means:

$$2.4\times10^{-9}$$

This is ordinary numeric data in R.

# 2.35 Complete participant example

``` r
participant_id <- "P001"
age <- 54
sex <- "Female"
height_m <- 1.68
weight_kg <- 72
fasting_glucose <- 108
smoker <- FALSE
disease_status <- "Control"
```

Inspect:

``` r
class(participant_id)
```

    ## [1] "character"

``` r
class(age)
```

    ## [1] "numeric"

``` r
class(sex)
```

    ## [1] "character"

``` r
class(height_m)
```

    ## [1] "numeric"

``` r
class(weight_kg)
```

    ## [1] "numeric"

``` r
class(fasting_glucose)
```

    ## [1] "numeric"

``` r
class(smoker)
```

    ## [1] "logical"

``` r
class(disease_status)
```

    ## [1] "character"

Calculate BMI:

``` r
bmi <- weight_kg / height_m^2
round(bmi, 2)
```

    ## [1] 25.51

If glucose was not measured:

``` r
fasting_glucose <- NA
is.na(fasting_glucose)
```

    ## [1] TRUE

# 2.36 Developing a data-auditing mindset

For every new variable, we should ask:

``` text
What does the variable mean scientifically?
             ↓
How is it stored in R?
             ↓
Is that representation appropriate?
             ↓
Are missing values represented correctly?
             ↓
Can the intended analysis be performed safely?
```

For example:

``` r
age <- "54"
```

may occur in raw imported data, but character storage is inappropriate
for numerical age calculations.

Likewise:

``` r
smoker <- "TRUE"
```

is text rather than a logical value.

Before calculating, we should understand the representation.

# 2.37 Common mistakes

### Mistake 1: forgetting quotation marks

``` r
patient_id <- P001
```

Correct:

``` r
patient_id <- "P001"
```

### Mistake 2: treating an identifier as a measurement

Prefer:

``` r
participant_id <- "001"
```

rather than treating the identifier as a quantitative number.

### Mistake 3: confusing `"TRUE"` with `TRUE`

``` r
class("TRUE")
```

    ## [1] "character"

``` r
class(TRUE)
```

    ## [1] "logical"

### Mistake 4: using `"NA"` instead of `NA`

``` r
is.na("NA")
```

    ## [1] FALSE

``` r
is.na(NA)
```

    ## [1] TRUE

### Mistake 5: using `== NA`

Use:

``` r
x <- NA
is.na(x)
```

    ## [1] TRUE

### Mistake 6: assuming a whole number is an integer

``` r
typeof(5)
```

    ## [1] "double"

``` r
typeof(5L)
```

    ## [1] "integer"

### Mistake 7: blindly converting dirty data

``` r
glucose <- "Not measured"
as.numeric(glucose)
```

    ## Warning: NAs introduced by coercion

    ## [1] NA

A warning should trigger investigation.

### Mistake 8: assuming numeric coding means a continuous variable

A disease code of `0/1` may be stored numerically while remaining
scientifically categorical.

# 2.38 Guided exercise: participant information

``` r
participant_id <- "BIO001"
age <- 48
sex <- "Female"
height_m <- 1.64
weight_kg <- 68
smoker <- FALSE
fasting_glucose <- 102
```

Inspect:

``` r
class(participant_id)
```

    ## [1] "character"

``` r
class(age)
```

    ## [1] "numeric"

``` r
class(sex)
```

    ## [1] "character"

``` r
class(height_m)
```

    ## [1] "numeric"

``` r
class(weight_kg)
```

    ## [1] "numeric"

``` r
class(smoker)
```

    ## [1] "logical"

``` r
class(fasting_glucose)
```

    ## [1] "numeric"

``` r
typeof(age)
```

    ## [1] "double"

``` r
typeof(height_m)
```

    ## [1] "double"

``` r
typeof(smoker)
```

    ## [1] "logical"

Calculate BMI:

``` r
bmi <- weight_kg / height_m^2
round(bmi, 2)
```

    ## [1] 25.28

Make glucose missing and test it:

``` r
fasting_glucose <- NA
is.na(fasting_glucose)
```

    ## [1] TRUE

# 2.39 Guided exercise: incorrect types

Suppose raw values are:

``` r
participant_id <- 1001
age <- "52"
sex <- "Female"
height <- "1.70"
smoker <- "TRUE"
```

Inspect:

``` r
class(participant_id)
```

    ## [1] "numeric"

``` r
class(age)
```

    ## [1] "character"

``` r
class(sex)
```

    ## [1] "character"

``` r
class(height)
```

    ## [1] "character"

``` r
class(smoker)
```

    ## [1] "character"

Before conversion, we should ask what each variable means and how the
study protocol defines it.

One reasonable representation is:

``` r
participant_id <- "1001"
age <- as.numeric(age)
height <- as.numeric(height)
smoker <- as.logical(smoker)
```

The principle is more important than the specific conversion:

> **Conversion should follow scientific meaning and documented coding.**

# 2.40 Independent exercise

Create objects for:

``` text
Participant ID:      P025
Age:                 61 years
Sex:                 Male
Height:              1.72 m
Weight:              84 kg
Current smoker:      Yes
Fasting glucose:     Missing
Disease group:       Case
Number of visits:    3
```

Then:

1.  choose an appropriate R representation for every value;
2.  inspect each object with `class()`;
3.  inspect age, ID, smoking status, and visits with `typeof()`;
4.  store visits explicitly as an integer;
5.  test whether glucose is missing;
6.  calculate BMI;
7.  convert age to character;
8.  convert visits to numeric and compare `typeof()` before and after;
9.  explain why participant ID is not a quantitative measurement;
10. explain why disease group remains categorical even if coded as `0`
    and `1`.

# 2.41 Debugging exercise

Find the problems:

``` r
Patient ID <- P001
age <- "54"
Sex <- Female
height <- "1.68"
smoker <- "TRUE"
glucose <- "NA"
```

One appropriate correction is:

``` r
patient_id <- "P001"
age <- 54
sex <- "Female"
height <- 1.68
smoker <- TRUE
glucose <- NA
```

Verify:

``` r
class(patient_id)
```

    ## [1] "character"

``` r
class(age)
```

    ## [1] "numeric"

``` r
class(sex)
```

    ## [1] "character"

``` r
class(height)
```

    ## [1] "numeric"

``` r
class(smoker)
```

    ## [1] "logical"

``` r
class(glucose)
```

    ## [1] "logical"

# 2.42 Challenge: dirty laboratory values

``` r
glucose_raw <- c(
  "95",
  "108",
  "Not measured",
  "126",
  "110"
)

class(glucose_raw)
```

    ## [1] "character"

``` r
typeof(glucose_raw)
```

    ## [1] "character"

``` r
glucose_numeric <- as.numeric(glucose_raw)
```

    ## Warning: NAs introduced by coercion

``` r
glucose_numeric
```

    ## [1]  95 108  NA 126 110

The warning occurs because `"Not measured"` cannot be converted
numerically.

A safer conceptual workflow is:

``` text
Raw values
    ↓
Identify special text codes
    ↓
Convert documented missing codes to NA
    ↓
Convert remaining values to numeric
    ↓
Verify the result
```

Systematic cleaning will be covered later.

# 2.43 Mini genomic exercise

``` r
chromosome <- 6
position <- 32626565
snp_id <- "rs9273371"
effect_allele <- "A"
other_allele <- "G"
beta <- 0.08
standard_error <- 0.015
p_value <- 2.4e-09
```

Inspect:

``` r
class(chromosome)
```

    ## [1] "numeric"

``` r
class(position)
```

    ## [1] "numeric"

``` r
class(snp_id)
```

    ## [1] "character"

``` r
class(effect_allele)
```

    ## [1] "character"

``` r
class(other_allele)
```

    ## [1] "character"

``` r
class(beta)
```

    ## [1] "numeric"

``` r
class(standard_error)
```

    ## [1] "numeric"

``` r
class(p_value)
```

    ## [1] "numeric"

Questions:

1.  Which objects are character data?
2.  Which are numeric?
3.  Why is `snp_id` character even though it contains digits?
4.  What does `2.4e-09` mean?
5.  Would chromosome `6` and chromosome `"6"` necessarily differ
    scientifically?
6.  Could inconsistent storage types still create problems during
    merging or filtering?

The last point is important: two fields can mean the same thing
scientifically and still fail to match computationally if their
representations differ.

# 2.44 Complete Chapter 2 practice script

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 2: Objects, Variables, and Basic Data Types
# ============================================================

# Basic objects
participant_id <- "P001"
age <- 46
sex <- "Male"
weight_kg <- 82
height_m <- 1.78
diabetes <- FALSE

# Inspect objects
class(participant_id)
class(age)
class(sex)
class(weight_kg)
class(height_m)
class(diabetes)

typeof(participant_id)
typeof(age)
typeof(diabetes)

str(age)
length(age)

# Numeric versus integer
x <- 5
y <- 5L
typeof(x)
typeof(y)

# Derived variable
bmi <- weight_kg / height_m^2
round(bmi, 2)

# Missing value
fasting_glucose <- NA
is.na(fasting_glucose)

# Special numerical values
0 / 0
1 / 0
-1 / 0

is.nan(NaN)
is.infinite(Inf)
is.finite(100)

# NULL
optional_result <- NULL
is.null(optional_result)
length(optional_result)
length(NA)

# Type conversion
glucose_text <- "105"
glucose_numeric <- as.numeric(glucose_text)

class(glucose_text)
class(glucose_numeric)

# Logical conversion
as.numeric(TRUE)
as.numeric(FALSE)
as.logical(1)
as.logical(0)

# Coercion
mixed_values <- c(10, 20, "30")
mixed_values
typeof(mixed_values)

# Genomic example
chromosome <- 6
position <- 32626565
snp_id <- "rs9273371"
effect_allele <- "A"
other_allele <- "G"
beta <- 0.08
standard_error <- 0.015
p_value <- 2.4e-09

class(chromosome)
class(position)
class(snp_id)
class(effect_allele)
class(beta)
class(p_value)
```

# 2.45 Essential functions

| Task                  | Function or syntax |
|-----------------------|--------------------|
| Assign value          | `x <- value`       |
| Inspect class         | `class(x)`         |
| Inspect internal type | `typeof(x)`        |
| Inspect structure     | `str(x)`           |
| Determine length      | `length(x)`        |
| Test numeric          | `is.numeric(x)`    |
| Test integer          | `is.integer(x)`    |
| Test character        | `is.character(x)`  |
| Test logical          | `is.logical(x)`    |
| Test missingness      | `is.na(x)`         |
| Test `NaN`            | `is.nan(x)`        |
| Test infinity         | `is.infinite(x)`   |
| Test finite value     | `is.finite(x)`     |
| Test `NULL`           | `is.null(x)`       |
| Convert to numeric    | `as.numeric(x)`    |
| Convert to integer    | `as.integer(x)`    |
| Convert to character  | `as.character(x)`  |
| Convert to logical    | `as.logical(x)`    |
| List objects          | `ls()`             |
| Remove object         | `rm(x)`            |

# 2.46 Concept map

``` text
Scientific information
        │
        ↓
     R object
        │
        ├───────────────┬──────────────┬──────────────┐
        ↓               ↓              ↓              ↓
     numeric         integer       character       logical
        │               │              │              │
        └───────────────┴──────────────┴──────────────┘
                                │
                                ↓
                         inspect with
                class() / typeof() / str()
                                │
                                ↓
                        special values
                   NA / NaN / Inf / NULL
                                │
                                ↓
                       type conversion
             as.numeric() / as.character() / ...
                                │
                                ↓
                          coercion rules
                                │
                                ↓
                    scientifically valid data
```

# 2.47 Chapter review

Before moving forward, we should be able to answer:

1.  What is the difference between `age <- 50` and `age <- "50"`?
2.  Why is `participant_id <- "00125"` usually preferable to storing the
    ID numerically?
3.  What is the difference between `TRUE` and `"TRUE"`?
4.  What is the difference between `NA` and `"NA"`?
5.  Why do we use `is.na(x)` rather than `x == NA`?
6.  What is the difference between `NA` and `NULL`?
7.  Why does `typeof(5)` normally return `"double"`?
8.  How does `typeof(5L)` differ?
9.  What happens when we run `c(10, 20, "30")`, and why?
10. If disease status is coded as `0 = Control` and `1 = Case`, does
    numeric storage make it a continuous variable?

The answer to the final question is **no**. Scientific interpretation
depends on what the values represent, not merely on how R stores them.

# 2.48 Key takeaways

1.  R stores information in **objects**.
2.  Objects have names and values.
3.  Basic values may be numeric, integer, character, or logical.
4.  `class()` and `typeof()` provide related but different information.
5.  Character values require quotation marks.
6.  Identifiers containing numbers are often still character variables.
7.  `TRUE` and `FALSE` are logical values, not text.
8.  `NA` represents missing data.
9.  `NaN`, `Inf`, and `NULL` have distinct meanings.
10. Missingness is tested with `is.na()`, not `== NA`.
11. Data types can be explicitly converted.
12. R can also perform automatic coercion.
13. Automatic coercion can create unexpected research-data problems.
14. Storage type is not the same as scientific or statistical meaning.

The central principle remains:

> **R understands representation; we are responsible for scientific
> meaning.**

# 2.49 Looking ahead

So far, we have learned how individual values are represented and
stored. Next, we need to ask questions such as:

``` text
Is age at least 50?
Is systolic blood pressure greater than 140?
Is a participant both a smoker and hypertensive?
Is a genotype one of several variants of interest?
Is a laboratory value missing?
```

To express these questions in R, we need operators, comparisons, and
logical expressions.

The next chapter is:

**Chapter 3 — Operators, Expressions, and Logical Conditions in R**
