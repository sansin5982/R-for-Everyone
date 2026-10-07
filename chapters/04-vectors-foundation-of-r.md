Vectors: The Foundation of R
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In the previous chapters, we worked mainly with individual values and
then used short collections of values to introduce logical operations.
We now study those collections formally.

A **vector** is one of the most fundamental data structures in R.

When we record the ages of ten participants, systolic blood pressure
measurements from a cohort, p-values from a GWAS, or expression values
for a gene, we are usually working with vectors.

For example:

``` r
age <- c(34, 52, 46, 67, 29, 58)
age
```

    ## [1] 34 52 46 67 29 58

This single object contains six values.

A major reason R is powerful for biomedical research is that operations
can often be applied to an entire vector at once. We do not need to
calculate separately for every participant.

For example:

``` r
age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

R compares all six ages with 50 in one operation.

This idea—**vectorized computation**—is central to R.

------------------------------------------------------------------------

## 4.1 Learning objectives

By the end of this chapter, we should be able to:

- explain what a vector is;
- create vectors using `c()`;
- create sequences using `:`, `seq()`, and `rep()`;
- identify vector length, class, and internal type;
- understand the atomic nature of basic vectors;
- explain automatic coercion in mixed-type vectors;
- create and use named vectors;
- extract values using positive indexing;
- exclude values using negative indexing;
- select values using logical indexing;
- select named elements;
- perform vectorized arithmetic;
- understand vector recycling and its risks;
- compare vectors;
- identify values using `%in%` and `which()`;
- sort values and obtain ordering positions;
- identify unique and duplicated values;
- work safely with missing values;
- understand parallel vectors representing participant-level variables;
- apply vectors to biomedical, epidemiological, and genomic examples.

------------------------------------------------------------------------

# 4.2 What is a vector?

A vector is a one-dimensional collection of values.

Consider six systolic blood pressure measurements:

``` text
118, 145, 132, 155, 121, 142
```

We can store them in R as:

``` r
sbp <- c(118, 145, 132, 155, 121, 142)
sbp
```

    ## [1] 118 145 132 155 121 142

The function:

``` text
c()
```

means **combine** or **concatenate**.

It combines individual values into a vector.

Conceptually:

``` text
118   145   132   155   121   142
 │     │     │     │     │     │
 └─────┴─────┴─────┴─────┴─────┘
               ↓
             vector
```

------------------------------------------------------------------------

# 4.3 Why vectors matter in research

A study rarely contains only one age or one glucose measurement.

Instead, we may have:

``` text
Participant 1 → age 34
Participant 2 → age 52
Participant 3 → age 46
Participant 4 → age 67
Participant 5 → age 29
Participant 6 → age 58
```

Rather than creating six unrelated objects:

``` r
age1 <- 34
age2 <- 52
age3 <- 46
age4 <- 67
age5 <- 29
age6 <- 58
```

we can create one vector:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

This representation is much easier to analyze.

We can immediately calculate:

``` r
mean(age)
```

    ## [1] 47.66667

``` r
min(age)
```

    ## [1] 29

``` r
max(age)
```

    ## [1] 67

``` r
length(age)
```

    ## [1] 6

Vectors therefore allow us to move from individual observations to
datasets.

------------------------------------------------------------------------

# 4.4 Creating vectors with `c()`

The most common way to create a vector is:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

We can print it:

``` r
age
```

    ## [1] 34 52 46 67 29 58

R displays the elements in their stored order.

------------------------------------------------------------------------

# 4.5 Numeric vectors

``` r
weight <- c(65.2, 72.4, 81.0, 59.8, 76.3)

weight
```

    ## [1] 65.2 72.4 81.0 59.8 76.3

``` r
class(weight)
```

    ## [1] "numeric"

``` r
typeof(weight)
```

    ## [1] "double"

This is a numeric vector.

------------------------------------------------------------------------

# 4.6 Integer vectors

Explicit integer values use `L`:

``` r
visits <- c(1L, 2L, 3L, 2L, 4L)

visits
```

    ## [1] 1 2 3 2 4

``` r
typeof(visits)
```

    ## [1] "integer"

The underlying type is `"integer"`.

------------------------------------------------------------------------

# 4.7 Character vectors

Participant identifiers can be stored as:

``` r
participant_id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005"
)

participant_id
```

    ## [1] "P001" "P002" "P003" "P004" "P005"

This is a character vector.

Other examples include:

``` r
diagnosis <- c(
  "Control",
  "Case",
  "Case",
  "Control",
  "Case"
)

diagnosis
```

    ## [1] "Control" "Case"    "Case"    "Control" "Case"

and genomic identifiers:

``` r
snp_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004"
)

snp_id
```

    ## [1] "rs1001" "rs1002" "rs1003" "rs1004"

------------------------------------------------------------------------

# 4.8 Logical vectors

Logical vectors contain `TRUE` and `FALSE`.

``` r
smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE,
  TRUE
)

smoker
```

    ## [1] FALSE  TRUE  TRUE FALSE  TRUE

Logical vectors frequently arise from comparisons:

``` r
age <- c(34, 52, 46, 67, 29)

age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE

The result itself is a logical vector.

------------------------------------------------------------------------

# 4.9 Vectors are atomic

The basic vectors studied in this chapter are **atomic vectors**.

An atomic vector stores elements of a common basic type.

For example:

``` r
x <- c(10, 20, 30)
typeof(x)
```

    ## [1] "double"

All values are numeric.

Likewise:

``` r
x <- c("A", "B", "C")
typeof(x)
```

    ## [1] "character"

All values are character.

This common-type requirement explains **coercion**.

------------------------------------------------------------------------

# 4.10 Coercion in mixed vectors

Consider:

``` r
x <- c(10, 20, "30")

x
```

    ## [1] "10" "20" "30"

``` r
typeof(x)
```

    ## [1] "character"

R converts all elements to character.

The vector becomes conceptually:

``` text
"10" "20" "30"
```

A simplified coercion hierarchy is:

``` text
logical
   ↓
integer
   ↓
double
   ↓
character
```

For example:

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

The final vector must use a type capable of representing every element.

------------------------------------------------------------------------

# 4.11 Why coercion matters in biomedical data

Suppose glucose values are entered as:

``` r
glucose <- c(
  95,
  105,
  110,
  "Not measured"
)

glucose
```

    ## [1] "95"           "105"          "110"          "Not measured"

``` r
typeof(glucose)
```

    ## [1] "character"

Because one value is character, the entire vector becomes character.

Now:

``` r
mean(glucose)
```

cannot produce the intended numerical mean.

A better representation for a genuinely missing measurement is:

``` r
glucose <- c(
  95,
  105,
  110,
  NA
)

typeof(glucose)
```

    ## [1] "double"

The vector remains numeric.

------------------------------------------------------------------------

# 4.12 Inspecting vectors

Useful functions include:

``` r
age <- c(34, 52, 46, 67, 29, 58)

length(age)
```

    ## [1] 6

``` r
class(age)
```

    ## [1] "numeric"

``` r
typeof(age)
```

    ## [1] "double"

``` r
str(age)
```

    ##  num [1:6] 34 52 46 67 29 58

These tell us:

``` text
length() → number of elements
class()  → broad R classification
typeof() → internal storage type
str()    → compact structural description
```

------------------------------------------------------------------------

# 4.13 Vector length

``` r
age <- c(34, 52, 46, 67, 29, 58)

length(age)
```

    ## [1] 6

The result is:

``` text
6
```

There are six elements.

For participant-level variables, equal lengths are often important.

Suppose:

``` r
id <- c("P001", "P002", "P003")
age <- c(34, 52, 46)
```

Then:

``` r
length(id)
```

    ## [1] 3

``` r
length(age)
```

    ## [1] 3

Both equal three, so each ID can correspond to one age.

------------------------------------------------------------------------

# 4.14 Empty vectors

We can create an empty vector of a specified type.

Examples:

``` r
numeric(0)
```

    ## numeric(0)

``` r
character(0)
```

    ## character(0)

``` r
logical(0)
```

    ## logical(0)

``` r
integer(0)
```

    ## integer(0)

These have length zero.

For example:

``` r
x <- numeric(0)

length(x)
```

    ## [1] 0

``` r
typeof(x)
```

    ## [1] "double"

Empty vectors become useful later when building results
programmatically.

------------------------------------------------------------------------

# 4.15 Creating sequences with `:`

The colon operator creates simple integer sequences.

``` r
1:10
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

produces:

``` text
1 2 3 4 5 6 7 8 9 10
```

We can store it:

``` r
participant_number <- 1:10
participant_number
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

Descending sequences also work:

``` r
5:1
```

    ## [1] 5 4 3 2 1

------------------------------------------------------------------------

# 4.16 Creating sequences with `seq()`

`seq()` provides more control.

``` r
seq(
  from = 1,
  to = 10,
  by = 1
)
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

A sequence increasing by 5:

``` r
seq(
  from = 0,
  to = 50,
  by = 5
)
```

    ##  [1]  0  5 10 15 20 25 30 35 40 45 50

A sequence of exactly six values:

``` r
seq(
  from = 0,
  to = 1,
  length.out = 6
)
```

    ## [1] 0.0 0.2 0.4 0.6 0.8 1.0

------------------------------------------------------------------------

# 4.17 Why `seq()` is useful

Suppose follow-up visits occur every three months:

``` r
followup_month <- seq(
  from = 0,
  to = 24,
  by = 3
)

followup_month
```

    ## [1]  0  3  6  9 12 15 18 21 24

This produces:

``` text
0 3 6 9 12 15 18 21 24
```

Such sequences are useful for time points, simulation parameters,
plotting coordinates, and repeated measurements.

------------------------------------------------------------------------

# 4.18 Repeating values with `rep()`

`rep()` repeats values.

``` r
rep("Control", 5)
```

    ## [1] "Control" "Control" "Control" "Control" "Control"

We can also repeat a pattern:

``` r
rep(
  c("Case", "Control"),
  times = 3
)
```

    ## [1] "Case"    "Control" "Case"    "Control" "Case"    "Control"

Result:

``` text
"Case" "Control" "Case" "Control" "Case" "Control"
```

------------------------------------------------------------------------

# 4.19 `times` versus `each`

Compare:

``` r
rep(
  c("A", "B"),
  times = 3
)
```

    ## [1] "A" "B" "A" "B" "A" "B"

with:

``` r
rep(
  c("A", "B"),
  each = 3
)
```

    ## [1] "A" "A" "A" "B" "B" "B"

The first repeats the entire pattern:

``` text
A B A B A B
```

The second repeats each element:

``` text
A A A B B B
```

This distinction is useful when generating treatment groups or repeated
labels.

------------------------------------------------------------------------

# 4.20 Combining existing vectors

Suppose:

``` r
group1_age <- c(35, 42, 51)
group2_age <- c(48, 57, 63)
```

We can combine them:

``` r
all_age <- c(
  group1_age,
  group2_age
)

all_age
```

    ## [1] 35 42 51 48 57 63

The result is one longer vector.

------------------------------------------------------------------------

# 4.21 Adding elements to a vector

Suppose:

``` r
age <- c(34, 52, 46)
```

Add another age:

``` r
age <- c(age, 67)

age
```

    ## [1] 34 52 46 67

Now the vector has four elements.

Check:

``` r
length(age)
```

    ## [1] 4

This works well for small examples, although repeatedly growing large
objects inside loops can be inefficient. We will revisit efficient
programming later.

------------------------------------------------------------------------

# 4.22 Named vectors

Vector elements can have names.

``` r
sbp <- c(
  P001 = 118,
  P002 = 145,
  P003 = 132,
  P004 = 155
)

sbp
```

    ## P001 P002 P003 P004 
    ##  118  145  132  155

Now each blood pressure measurement has a participant label.

Inspect the names:

``` r
names(sbp)
```

    ## [1] "P001" "P002" "P003" "P004"

------------------------------------------------------------------------

# 4.23 Adding names after vector creation

We can also write:

``` r
sbp <- c(118, 145, 132, 155)

names(sbp) <- c(
  "P001",
  "P002",
  "P003",
  "P004"
)

sbp
```

    ## P001 P002 P003 P004 
    ##  118  145  132  155

Named vectors can make small analyses easier to interpret.

------------------------------------------------------------------------

# 4.24 Names are labels, not separate data columns

A named vector is still one vector.

``` r
class(sbp)
```

    ## [1] "numeric"

``` r
length(sbp)
```

    ## [1] 4

The names are metadata associated with its elements.

For full datasets containing several variables, data frames will
eventually be more appropriate. We study them later.

------------------------------------------------------------------------

# 4.25 Vector indexing

**Indexing** means selecting particular elements from a vector.

R uses square brackets:

``` text
vector[index]
```

Suppose:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

The first element is:

``` r
age[1]
```

    ## [1] 34

The second is:

``` r
age[2]
```

    ## [1] 52

------------------------------------------------------------------------

# 4.26 R indexing starts at 1

This is important.

The first element is:

``` r
age[1]
```

not:

``` r
age[0]
```

Check:

``` r
age[0]
```

    ## numeric(0)

This returns an empty vector rather than the first value.

R uses **1-based indexing**.

------------------------------------------------------------------------

# 4.27 Selecting several positions

We can provide a vector of positions:

``` r
age[c(1, 3, 6)]
```

    ## [1] 34 46 58

This returns the first, third, and sixth elements.

The index itself is a vector:

``` r
c(1, 3, 6)
```

This illustrates how vectors are used throughout R—even to select
elements from other vectors.

------------------------------------------------------------------------

# 4.28 Selecting a range

``` r
age[2:5]
```

    ## [1] 52 46 67 29

This selects positions 2 through 5.

Equivalent:

``` r
age[c(2, 3, 4, 5)]
```

    ## [1] 52 46 67 29

------------------------------------------------------------------------

# 4.29 Repeating positions during indexing

``` r
age[c(1, 1, 3)]
```

    ## [1] 34 34 46

The first value appears twice because position 1 was requested twice.

Indexing does not require unique positions.

------------------------------------------------------------------------

# 4.30 Negative indexing

Negative indices exclude positions.

``` r
age[-1]
```

    ## [1] 52 46 67 29 58

returns every element except the first.

Exclude positions 2 and 4:

``` r
age[-c(2, 4)]
```

    ## [1] 34 46 29 58

This can be read as:

> Return all values except positions 2 and 4.

------------------------------------------------------------------------

# 4.31 Positive and negative indices should not be mixed

An expression such as:

``` r
age[c(1, -2)]
```

is not a valid ordinary way to mix inclusion and exclusion.

We should decide whether we are:

``` text
selecting positions
or
excluding positions
```

and construct the index accordingly.

------------------------------------------------------------------------

# 4.32 Selecting by names

For a named vector:

``` r
sbp <- c(
  P001 = 118,
  P002 = 145,
  P003 = 132,
  P004 = 155
)
```

we can select:

``` r
sbp["P002"]
```

    ## P002 
    ##  145

or several:

``` r
sbp[c("P001", "P004")]
```

    ## P001 P004 
    ##  118  155

This can be easier to interpret than positional indexing.

------------------------------------------------------------------------

# 4.33 Logical indexing

Logical indexing is one of the most important ideas in R.

Suppose:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

The comparison:

``` r
age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

returns:

``` text
FALSE TRUE FALSE TRUE FALSE TRUE
```

We can place that logical vector inside brackets:

``` r
age[age >= 50]
```

    ## [1] 52 67 58

R returns only the values whose corresponding condition is `TRUE`.

Result:

``` text
52 67 58
```

------------------------------------------------------------------------

# 4.34 How logical indexing works

Conceptually:

``` text
Age:        34     52     46     67     29     58
            ↓      ↓      ↓      ↓      ↓      ↓
Condition: FALSE   TRUE   FALSE  TRUE   FALSE  TRUE
                   ↓             ↓             ↓
Selected:          52            67            58
```

This pattern appears throughout R:

``` r
x[condition]
```

------------------------------------------------------------------------

# 4.35 Selecting participant IDs using another vector

Suppose:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)

age <- c(
  34,
  52,
  46,
  67,
  29,
  58
)
```

Identify IDs for participants aged 50 or older:

``` r
id[age >= 50]
```

    ## [1] "P002" "P004" "P006"

The condition comes from `age`, but the selected values come from `id`.

This works because both vectors have the same length and corresponding
positions refer to the same participants.

------------------------------------------------------------------------

# 4.36 Parallel vectors

Consider:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004"
)

age <- c(
  34,
  52,
  46,
  67
)

smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE
)
```

The positions correspond:

``` text
Position    ID      Age     Smoker
1           P001    34      FALSE
2           P002    52      TRUE
3           P003    46      TRUE
4           P004    67      FALSE
```

These are **parallel vectors**.

For example:

``` r
id[smoker]
```

    ## [1] "P002" "P003"

returns IDs of smokers.

And:

``` r
age[smoker]
```

    ## [1] 52 46

returns their ages.

------------------------------------------------------------------------

# 4.37 Why equal lengths matter

Check:

``` r
length(id)
```

    ## [1] 4

``` r
length(age)
```

    ## [1] 4

``` r
length(smoker)
```

    ## [1] 4

For participant-level parallel vectors, equal length is essential.

If one vector accidentally contains fewer observations, positional
correspondence may be lost.

This is one reason data frames become important: they organize related
variables into rows and columns. Until we reach that chapter, parallel
vectors provide a useful way to understand the underlying logic.

------------------------------------------------------------------------

# 4.38 Multiple logical conditions

Suppose:

``` r
age <- c(34, 52, 46, 67, 29, 58)

smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE,
  FALSE,
  TRUE
)
```

Select ages of smokers aged at least 50:

``` r
age[(age >= 50) & smoker]
```

    ## [1] 52 58

Identify their IDs:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)

id[(age >= 50) & smoker]
```

    ## [1] "P002" "P006"

This combines Chapter 3 logical conditions with vector indexing.

------------------------------------------------------------------------

# 4.39 Vectorized arithmetic

R performs arithmetic element by element.

Suppose weight is measured at baseline and follow-up:

``` r
baseline_weight <- c(
  70,
  82,
  65,
  90
)

followup_weight <- c(
  68,
  79,
  66,
  85
)
```

Calculate change:

``` r
weight_change <- followup_weight - baseline_weight

weight_change
```

    ## [1] -2 -3  1 -5

R calculates:

``` text
Participant 1: 68 - 70
Participant 2: 79 - 82
Participant 3: 66 - 65
Participant 4: 85 - 90
```

all at once.

------------------------------------------------------------------------

# 4.40 Vectorized BMI calculation

Suppose:

``` r
weight_kg <- c(
  68,
  82,
  75,
  60
)

height_m <- c(
  1.65,
  1.78,
  1.72,
  1.60
)
```

Calculate BMI for every participant:

``` r
bmi <- weight_kg / height_m^2

bmi
```

    ## [1] 24.97704 25.88057 25.35154 23.43750

Round:

``` r
round(bmi, 2)
```

    ## [1] 24.98 25.88 25.35 23.44

No loop is needed.

------------------------------------------------------------------------

# 4.41 Vectorized transformations

Suppose glucose is measured in mg/dL and we want a simple unit
conversion to mmol/L using the common approximate divisor 18:

``` r
glucose_mg_dl <- c(
  90,
  108,
  126,
  144
)

glucose_mmol_l <- glucose_mg_dl / 18

glucose_mmol_l
```

    ## [1] 5 6 7 8

Every element is divided by 18.

------------------------------------------------------------------------

# 4.42 Arithmetic between a vector and one value

Consider:

``` r
age <- c(34, 52, 46, 67)
```

Add one year:

``` r
age + 1
```

    ## [1] 35 53 47 68

R applies the single value to every element.

Conceptually:

``` text
34 + 1
52 + 1
46 + 1
67 + 1
```

This is a simple and useful form of vectorization.

------------------------------------------------------------------------

# 4.43 Arithmetic between equal-length vectors

``` r
baseline <- c(120, 135, 142)
followup <- c(115, 130, 138)

change <- followup - baseline
change
```

    ## [1] -5 -5 -4

The elements are paired by position.

This is why the ordering of parallel vectors must be correct.

------------------------------------------------------------------------

# 4.44 Recycling

R can repeat a shorter vector when operating with a longer vector.

For example:

``` r
x <- c(10, 20, 30, 40)
y <- c(1, 2)

x + y
```

    ## [1] 11 22 31 42

R effectively uses:

``` text
x: 10 20 30 40
y:  1  2  1  2
```

and returns:

``` text
11 22 31 42
```

This behavior is called **recycling**.

------------------------------------------------------------------------

# 4.45 Recycling can be useful

Suppose a pattern alternates between two adjustments:

``` r
measurement <- c(
  100,
  110,
  120,
  130
)

adjustment <- c(
  1,
  -1
)

measurement + adjustment
```

    ## [1] 101 109 121 129

R repeats the adjustment pattern.

However, recycling should be used deliberately.

------------------------------------------------------------------------

# 4.46 Recycling can also create mistakes

Consider:

``` r
x <- c(10, 20, 30, 40, 50)
y <- c(1, 2)

x + y
```

    ## Warning in x + y: longer object length is not a multiple of shorter object
    ## length

    ## [1] 11 22 31 42 51

The longer vector has length 5 and the shorter has length 2.

Because 5 is not an exact multiple of 2, R typically produces a warning
about object lengths.

Warnings about recycling should be investigated.

For participant-level research data, unexpected unequal vector lengths
are often evidence of a data problem.

------------------------------------------------------------------------

# 4.47 Safe thinking about vector lengths

Before combining parallel variables, we can check:

``` r
length(id)
```

    ## [1] 6

``` r
length(age)
```

    ## [1] 4

``` r
length(smoker)
```

    ## [1] 6

Or test:

``` r
length(id) == length(age)
```

    ## [1] FALSE

For three vectors:

``` r
length(id) == length(age) &
  length(age) == length(smoker)
```

    ## [1] FALSE

This introduces a simple data-validation habit.

------------------------------------------------------------------------

# 4.48 Vectorized comparisons

Comparisons are also vectorized.

``` r
sbp <- c(
  118,
  145,
  132,
  155,
  121,
  142
)

sbp >= 140
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

The result is a logical vector.

Count:

``` r
sum(sbp >= 140)
```

    ## [1] 3

Proportion:

``` r
mean(sbp >= 140)
```

    ## [1] 0.5

Select values:

``` r
sbp[sbp >= 140]
```

    ## [1] 145 155 142

------------------------------------------------------------------------

# 4.49 `which()` and positions

``` r
which(sbp >= 140)
```

    ## [1] 2 4 6

returns positions where the condition is `TRUE`.

Compare:

``` r
sbp[sbp >= 140]
```

    ## [1] 145 155 142

with:

``` r
which(sbp >= 140)
```

    ## [1] 2 4 6

The first returns **values**.

The second returns **positions**.

------------------------------------------------------------------------

# 4.50 Membership with `%in%`

Suppose:

``` r
diagnosis <- c(
  "Control",
  "Diabetes",
  "Hypertension",
  "Asthma",
  "Dyslipidemia"
)
```

Select cardiometabolic conditions from a teaching set:

``` r
diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
)
```

    ## [1] FALSE  TRUE  TRUE FALSE  TRUE

Use the condition for selection:

``` r
diagnosis[
  diagnosis %in% c(
    "Diabetes",
    "Hypertension",
    "Dyslipidemia"
  )
]
```

    ## [1] "Diabetes"     "Hypertension" "Dyslipidemia"

------------------------------------------------------------------------

# 4.51 Membership for IDs

Suppose:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005"
)
```

and:

``` r
selected_ids <- c(
  "P002",
  "P005"
)
```

Test:

``` r
id %in% selected_ids
```

    ## [1] FALSE  TRUE FALSE FALSE  TRUE

Select:

``` r
id[id %in% selected_ids]
```

    ## [1] "P002" "P005"

This pattern becomes extremely important when matching samples,
variants, genes, or other identifiers.

------------------------------------------------------------------------

# 4.52 Sorting vectors

Suppose:

``` r
age <- c(
  52,
  34,
  67,
  46,
  29
)
```

Sort ascending:

``` r
sort(age)
```

    ## [1] 29 34 46 52 67

Sort descending:

``` r
sort(
  age,
  decreasing = TRUE
)
```

    ## [1] 67 52 46 34 29

------------------------------------------------------------------------

# 4.53 `sort()` changes the order of returned values

The original vector remains unchanged unless we assign the result:

``` r
age
```

    ## [1] 52 34 67 46 29

To store the sorted version:

``` r
age_sorted <- sort(age)

age_sorted
```

    ## [1] 29 34 46 52 67

Or overwrite:

``` r
age <- sort(age)
```

We should overwrite only when that is intentional.

------------------------------------------------------------------------

# 4.54 `order()` returns positions

Suppose:

``` r
age <- c(
  52,
  34,
  67,
  46,
  29
)
```

Run:

``` r
order(age)
```

    ## [1] 5 2 4 1 3

This does not return the sorted ages.

It returns the positions that would place `age` in ascending order.

Use those positions:

``` r
age[order(age)]
```

    ## [1] 29 34 46 52 67

This gives the same ordering as:

``` r
sort(age)
```

    ## [1] 29 34 46 52 67

------------------------------------------------------------------------

# 4.55 Why `order()` is especially useful

Suppose:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005"
)

age <- c(
  52,
  34,
  67,
  46,
  29
)
```

If we sort only `age`:

``` r
sort(age)
```

    ## [1] 29 34 46 52 67

we lose direct correspondence with the IDs.

Instead:

``` r
age_order <- order(age)

id[age_order]
```

    ## [1] "P005" "P002" "P004" "P001" "P003"

``` r
age[age_order]
```

    ## [1] 29 34 46 52 67

Now both vectors are reordered consistently.

This is a fundamental principle when working with parallel vectors.

------------------------------------------------------------------------

# 4.56 Descending order with `order()`

``` r
age_order_desc <- order(
  age,
  decreasing = TRUE
)

id[age_order_desc]
```

    ## [1] "P003" "P001" "P004" "P002" "P005"

``` r
age[age_order_desc]
```

    ## [1] 67 52 46 34 29

This identifies participants from oldest to youngest.

------------------------------------------------------------------------

# 4.57 Minimum and maximum

``` r
age <- c(
  52,
  34,
  67,
  46,
  29
)

min(age)
```

    ## [1] 29

``` r
max(age)
```

    ## [1] 67

``` r
range(age)
```

    ## [1] 29 67

`range()` returns both minimum and maximum.

------------------------------------------------------------------------

# 4.58 Positions of minimum and maximum

Use:

``` r
which.min(age)
```

    ## [1] 5

``` r
which.max(age)
```

    ## [1] 3

These return positions.

For example:

``` r
id[which.max(age)]
```

    ## [1] "P003"

returns the ID corresponding to the maximum age.

This illustrates how positional functions can connect parallel vectors.

------------------------------------------------------------------------

# 4.59 Unique values

Suppose:

``` r
diagnosis <- c(
  "Control",
  "Case",
  "Case",
  "Control",
  "Case"
)
```

Find distinct values:

``` r
unique(diagnosis)
```

    ## [1] "Control" "Case"

This is useful for inspecting categorical coding.

For example, a variable expected to contain only:

``` text
Case
Control
```

might unexpectedly contain:

``` text
case
Control
CASE
Unknown
```

`unique()` helps reveal such inconsistencies.

------------------------------------------------------------------------

# 4.60 Identifying duplicates

Suppose:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P002",
  "P005"
)
```

Run:

``` r
duplicated(id)
```

    ## [1] FALSE FALSE FALSE  TRUE FALSE

R returns a logical vector indicating later occurrences of values
already seen.

Count duplicated occurrences:

``` r
sum(duplicated(id))
```

    ## [1] 1

Display them:

``` r
id[duplicated(id)]
```

    ## [1] "P002"

------------------------------------------------------------------------

# 4.61 Understanding `duplicated()`

For:

``` text
P001
P002
P003
P002
P005
```

the first `P002` is not marked as duplicated because it is the first
occurrence.

The second `P002` is marked `TRUE`.

This is useful for detecting repeated participant IDs or variant
identifiers.

------------------------------------------------------------------------

# 4.62 Finding all values involved in duplication

Suppose we want to display every occurrence of duplicated IDs, including
the first occurrence.

One useful pattern is:

``` r
id[
  duplicated(id) |
  duplicated(id, fromLast = TRUE)
]
```

    ## [1] "P002" "P002"

This returns all elements participating in duplication.

We will use more systematic duplicate checks later during data cleaning.

------------------------------------------------------------------------

# 4.63 Removing duplicates with `unique()`

``` r
unique(id)
```

    ## [1] "P001" "P002" "P003" "P005"

returns each distinct ID once.

However, removing duplicate participant records should never be done
blindly.

A duplicated ID may represent:

- accidental duplication;
- repeated visits;
- multiple samples;
- legitimate longitudinal records;
- data-entry problems.

The scientific design must determine what constitutes a true duplicate.

------------------------------------------------------------------------

# 4.64 Missing values in vectors

Suppose:

``` r
glucose <- c(
  95,
  105,
  NA,
  110,
  NA,
  126
)
```

Identify missing positions:

``` r
is.na(glucose)
```

    ## [1] FALSE FALSE  TRUE FALSE  TRUE FALSE

Count:

``` r
sum(is.na(glucose))
```

    ## [1] 2

Count observed values:

``` r
sum(!is.na(glucose))
```

    ## [1] 4

------------------------------------------------------------------------

# 4.65 Selecting observed values

``` r
glucose[!is.na(glucose)]
```

    ## [1]  95 105 110 126

This returns only recorded measurements.

The original vector is unchanged.

------------------------------------------------------------------------

# 4.66 Selecting missing positions

``` r
which(is.na(glucose))
```

    ## [1] 3 5

returns the positions of missing measurements.

If we have parallel IDs:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)
```

then:

``` r
id[is.na(glucose)]
```

    ## [1] "P003" "P005"

identifies participants with missing glucose.

------------------------------------------------------------------------

# 4.67 Summary functions and missing values

``` r
mean(glucose)
```

    ## [1] NA

returns `NA` because the vector contains missing values.

Use:

``` r
mean(
  glucose,
  na.rm = TRUE
)
```

    ## [1] 109

Similarly:

``` r
min(
  glucose,
  na.rm = TRUE
)
```

    ## [1] 95

``` r
max(
  glucose,
  na.rm = TRUE
)
```

    ## [1] 126

``` r
median(
  glucose,
  na.rm = TRUE
)
```

    ## [1] 107.5

The argument `na.rm = TRUE` means:

> Remove missing values for this calculation.

It does not modify the vector.

------------------------------------------------------------------------

# 4.68 `NA` in logical indexing

Consider:

``` r
glucose >= 110
```

    ## [1] FALSE FALSE    NA  TRUE    NA  TRUE

Because some glucose values are missing, the logical result includes
`NA`.

If we use:

``` r
glucose[glucose >= 110]
```

    ## [1]  NA 110  NA 126

the output can retain missing positions as `NA`.

A safer explicit condition is:

``` r
glucose[
  !is.na(glucose) &
  glucose >= 110
]
```

    ## [1] 110 126

This asks for:

``` text
recorded glucose
AND
glucose at least 110
```

------------------------------------------------------------------------

# 4.69 Replacing selected values

Vector indexing can also modify elements.

Suppose:

``` r
glucose <- c(
  95,
  105,
  -999,
  110
)
```

If the study documentation confirms that `-999` is a missing-value code,
we can replace it:

``` r
glucose[glucose == -999] <- NA

glucose
```

    ## [1]  95 105  NA 110

This pattern is common in data cleaning.

The replacement should only be performed after confirming the coding
convention.

------------------------------------------------------------------------

# 4.70 Replacing values by position

``` r
x <- c(10, 20, 30, 40)

x[2] <- 25

x
```

    ## [1] 10 25 30 40

The second value changes from `20` to `25`.

Several positions can be modified:

``` r
x[c(1, 4)] <- c(11, 44)

x
```

    ## [1] 11 25 30 44

------------------------------------------------------------------------

# 4.71 Replacing values using logical conditions

Suppose:

``` r
age <- c(
  34,
  52,
  -5,
  46,
  145
)
```

If values below 0 or above 120 have been verified as invalid data-entry
values, we can first identify them:

``` r
invalid_age <- age < 0 | age > 120

invalid_age
```

    ## [1] FALSE FALSE  TRUE FALSE  TRUE

Then replace:

``` r
age[invalid_age] <- NA

age
```

    ## [1] 34 52 NA 46 NA

The scientific verification step should precede replacement.

------------------------------------------------------------------------

# 4.72 Character vector cleaning preview

Suppose:

``` r
sex <- c(
  "Male",
  "Female",
  "female",
  "Male"
)
```

Inspect:

``` r
unique(sex)
```

    ## [1] "Male"   "Female" "female"

R sees:

``` text
"Female"
"female"
```

as different strings.

Later chapters will cover systematic character cleaning. For now,
`unique()` gives us an immediate audit tool.

------------------------------------------------------------------------

# 4.73 Concatenating character vectors

``` r
first_ids <- c(
  "P001",
  "P002"
)

second_ids <- c(
  "P003",
  "P004"
)

all_ids <- c(
  first_ids,
  second_ids
)

all_ids
```

    ## [1] "P001" "P002" "P003" "P004"

The same `c()` function works across basic vector types.

------------------------------------------------------------------------

# 4.74 Parallel biomedical vectors: a complete example

Create:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)

age <- c(
  34,
  52,
  46,
  67,
  29,
  58
)

sex <- c(
  "Female",
  "Male",
  "Female",
  "Male",
  "Female",
  "Male"
)

sbp <- c(
  118,
  145,
  132,
  155,
  121,
  142
)

glucose <- c(
  92,
  105,
  NA,
  130,
  88,
  128
)

smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE,
  FALSE,
  TRUE
)
```

Check lengths:

``` r
length(id)
```

    ## [1] 6

``` r
length(age)
```

    ## [1] 6

``` r
length(sex)
```

    ## [1] 6

``` r
length(sbp)
```

    ## [1] 6

``` r
length(glucose)
```

    ## [1] 6

``` r
length(smoker)
```

    ## [1] 6

All should equal six.

------------------------------------------------------------------------

# 4.75 Selecting participants by age

``` r
id[age >= 50]
```

    ## [1] "P002" "P004" "P006"

Select their ages:

``` r
age[age >= 50]
```

    ## [1] 52 67 58

Select their systolic BP:

``` r
sbp[age >= 50]
```

    ## [1] 145 155 142

The same logical condition can be applied to different parallel vectors.

------------------------------------------------------------------------

# 4.76 Selecting smokers aged at least 50

``` r
selected <- age >= 50 & smoker

selected
```

    ## [1] FALSE  TRUE FALSE FALSE FALSE  TRUE

Then:

``` r
id[selected]
```

    ## [1] "P002" "P006"

``` r
age[selected]
```

    ## [1] 52 58

``` r
sbp[selected]
```

    ## [1] 145 142

Saving the condition once can make code clearer.

------------------------------------------------------------------------

# 4.77 Selecting participants with recorded high glucose

For a programming example, define:

``` r
high_glucose <- !is.na(glucose) &
  glucose >= 126
```

Then:

``` r
id[high_glucose]
```

    ## [1] "P004" "P006"

``` r
glucose[high_glucose]
```

    ## [1] 130 128

The threshold is being used here to demonstrate vector logic, not as a
complete clinical diagnostic rule.

------------------------------------------------------------------------

# 4.78 Finding the participant with the highest SBP

``` r
which.max(sbp)
```

    ## [1] 4

Use that position:

``` r
id[which.max(sbp)]
```

    ## [1] "P004"

``` r
sbp[which.max(sbp)]
```

    ## [1] 155

This demonstrates the relationship between a vector and its parallel
identifiers.

------------------------------------------------------------------------

# 4.79 Ordering participants by SBP

``` r
sbp_order <- order(
  sbp,
  decreasing = TRUE
)

id[sbp_order]
```

    ## [1] "P004" "P002" "P006" "P003" "P005" "P001"

``` r
sbp[sbp_order]
```

    ## [1] 155 145 142 132 121 118

The same ordering can be applied to all parallel vectors:

``` r
age[sbp_order]
```

    ## [1] 67 52 58 46 29 34

``` r
sex[sbp_order]
```

    ## [1] "Male"   "Male"   "Male"   "Female" "Female" "Female"

This preserves correspondence.

------------------------------------------------------------------------

# 4.80 A genomic vector example

Suppose we have five variants:

``` r
snp_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004",
  "rs1005"
)

chromosome <- c(
  6,
  6,
  6,
  5,
  6
)

position <- c(
  27500000,
  28900000,
  32600000,
  32000000,
  34100000
)

effect_allele <- c(
  "A",
  "G",
  "T",
  "C",
  "A"
)

other_allele <- c(
  "G",
  "A",
  "C",
  "T",
  "C"
)

beta <- c(
  0.03,
  -0.08,
  0.12,
  0.02,
  -0.04
)

p_value <- c(
  1e-4,
  2e-9,
  4e-10,
  3e-8,
  0.02
)
```

These vectors are parallel: position 1 in every vector describes the
same variant.

------------------------------------------------------------------------

# 4.81 Checking genomic vector lengths

``` r
length(snp_id)
```

    ## [1] 5

``` r
length(chromosome)
```

    ## [1] 5

``` r
length(position)
```

    ## [1] 5

``` r
length(beta)
```

    ## [1] 5

``` r
length(p_value)
```

    ## [1] 5

All should agree.

A compact logical check is:

``` r
length(snp_id) == length(chromosome) &
  length(chromosome) == length(position) &
  length(position) == length(beta) &
  length(beta) == length(p_value)
```

    ## [1] TRUE

------------------------------------------------------------------------

# 4.82 Selecting chromosome 6 variants

``` r
chr6 <- chromosome == 6

snp_id[chr6]
```

    ## [1] "rs1001" "rs1002" "rs1003" "rs1005"

``` r
position[chr6]
```

    ## [1] 27500000 28900000 32600000 34100000

------------------------------------------------------------------------

# 4.83 Selecting variants in a genomic interval

Define a teaching interval:

``` r
in_region <- chromosome == 6 &
  position >= 27000000 &
  position <= 34000000
```

Select IDs:

``` r
snp_id[in_region]
```

    ## [1] "rs1001" "rs1002" "rs1003"

Select positions:

``` r
position[in_region]
```

    ## [1] 27500000 28900000 32600000

------------------------------------------------------------------------

# 4.84 Selecting statistically significant variants

For a programming example:

``` r
significant <- p_value < 5e-8

snp_id[significant]
```

    ## [1] "rs1002" "rs1003" "rs1004"

``` r
p_value[significant]
```

    ## [1] 2e-09 4e-10 3e-08

Again, our focus here is vector logic.

------------------------------------------------------------------------

# 4.85 Combining genomic conditions

``` r
selected <- in_region & significant

snp_id[selected]
```

    ## [1] "rs1002" "rs1003"

``` r
position[selected]
```

    ## [1] 28900000 32600000

``` r
beta[selected]
```

    ## [1] -0.08  0.12

``` r
p_value[selected]
```

    ## [1] 2e-09 4e-10

The same logical vector selects corresponding elements from every
parallel vector.

This is exactly the same principle used earlier with participant-level
data.

------------------------------------------------------------------------

# 4.86 Sorting variants by p-value

``` r
p_order <- order(p_value)

snp_id[p_order]
```

    ## [1] "rs1003" "rs1002" "rs1004" "rs1001" "rs1005"

``` r
p_value[p_order]
```

    ## [1] 4e-10 2e-09 3e-08 1e-04 2e-02

The smallest p-value appears first.

We can also reorder effect sizes:

``` r
beta[p_order]
```

    ## [1]  0.12 -0.08  0.02  0.03 -0.04

Because the same ordering is used, variant correspondence remains
intact.

------------------------------------------------------------------------

# 4.87 Checking allele values

Suppose valid single-nucleotide alleles are:

``` r
valid_effect_allele <- effect_allele %in%
  c("A", "C", "G", "T")

valid_other_allele <- other_allele %in%
  c("A", "C", "G", "T")

valid_effect_allele
```

    ## [1] TRUE TRUE TRUE TRUE TRUE

``` r
valid_other_allele
```

    ## [1] TRUE TRUE TRUE TRUE TRUE

Check whether all are valid:

``` r
all(valid_effect_allele)
```

    ## [1] TRUE

``` r
all(valid_other_allele)
```

    ## [1] TRUE

This is a simple genomic QC example.

------------------------------------------------------------------------

# 4.88 Duplicate variant IDs

Suppose:

``` r
variant_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1002",
  "rs1005"
)
```

Check:

``` r
duplicated(variant_id)
```

    ## [1] FALSE FALSE FALSE  TRUE FALSE

Count:

``` r
sum(duplicated(variant_id))
```

    ## [1] 1

Display duplicated IDs:

``` r
variant_id[duplicated(variant_id)]
```

    ## [1] "rs1002"

As with participant IDs, duplicate variant IDs should be investigated
rather than automatically removed.

------------------------------------------------------------------------

# 4.89 Common mistakes with vectors

## Mistake 1: forgetting `c()`

Incorrect:

``` r
age <- 34, 52, 46
```

Correct:

``` r
age <- c(34, 52, 46)
```

------------------------------------------------------------------------

## Mistake 2: assuming vectors can freely mix types

``` r
x <- c(10, 20, "Missing")
typeof(x)
```

    ## [1] "character"

The entire vector becomes character.

------------------------------------------------------------------------

## Mistake 3: using position zero as the first element

``` r
age[0]
```

    ## numeric(0)

R uses 1-based indexing.

The first value is:

``` r
age[1]
```

    ## [1] 34

------------------------------------------------------------------------

## Mistake 4: confusing positions with values

``` r
which(age >= 50)
```

    ## [1] 2

returns positions.

``` r
age[age >= 50]
```

    ## [1] 52

returns values.

------------------------------------------------------------------------

## Mistake 5: sorting one parallel vector alone

If IDs and ages correspond by position, sorting only age breaks visible
alignment with IDs.

Instead:

``` r
idx <- order(age)

id[idx]
```

    ## [1] "P001" "P003" "P002"

``` r
age[idx]
```

    ## [1] 34 46 52

The same ordering should be applied to every related vector.

------------------------------------------------------------------------

## Mistake 6: ignoring unequal vector lengths

Unexpected recycling can silently produce incorrect calculations or
warnings.

Check:

``` r
length(id)
```

    ## [1] 6

``` r
length(age)
```

    ## [1] 3

before combining parallel data when consistency is uncertain.

------------------------------------------------------------------------

## Mistake 7: using arbitrary text inside a numeric vector

Instead of:

``` r
glucose <- c(
  95,
  105,
  "Missing",
  110
)
```

a genuinely missing numerical measurement should normally be:

``` r
glucose <- c(
  95,
  105,
  NA,
  110
)
```

------------------------------------------------------------------------

## Mistake 8: removing duplicates without understanding them

``` r
id <- unique(id)
```

may remove information if repeated IDs represent legitimate longitudinal
observations.

We should first determine why duplication exists.

------------------------------------------------------------------------

# 4.90 Guided practical: participant vectors

Create:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006",
  "P007",
  "P008"
)

age <- c(
  34,
  52,
  46,
  67,
  29,
  58,
  41,
  63
)

weight_kg <- c(
  68,
  82,
  75,
  90,
  61,
  79,
  70,
  85
)

height_m <- c(
  1.65,
  1.78,
  1.72,
  1.80,
  1.60,
  1.75,
  1.69,
  1.77
)

sbp <- c(
  118,
  145,
  132,
  155,
  121,
  142,
  128,
  150
)

glucose <- c(
  92,
  105,
  NA,
  130,
  88,
  128,
  99,
  135
)

smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE,
  FALSE,
  TRUE,
  FALSE,
  TRUE
)
```

## Step 1: verify vector lengths

``` r
length(id)
```

    ## [1] 8

``` r
length(age)
```

    ## [1] 8

``` r
length(weight_kg)
```

    ## [1] 8

``` r
length(height_m)
```

    ## [1] 8

``` r
length(sbp)
```

    ## [1] 8

``` r
length(glucose)
```

    ## [1] 8

``` r
length(smoker)
```

    ## [1] 8

------------------------------------------------------------------------

## Step 2: calculate BMI for all participants

``` r
bmi <- weight_kg / height_m^2

round(bmi, 2)
```

    ## [1] 24.98 25.88 25.35 27.78 23.83 25.80 24.51 27.13

------------------------------------------------------------------------

## Step 3: identify participants aged 50 or older

``` r
older <- age >= 50

id[older]
```

    ## [1] "P002" "P004" "P006" "P008"

``` r
age[older]
```

    ## [1] 52 67 58 63

------------------------------------------------------------------------

## Step 4: identify smokers aged 50 or older

``` r
selected <- age >= 50 & smoker

id[selected]
```

    ## [1] "P002" "P006" "P008"

------------------------------------------------------------------------

## Step 5: identify missing glucose

``` r
is.na(glucose)
```

    ## [1] FALSE FALSE  TRUE FALSE FALSE FALSE FALSE FALSE

``` r
id[is.na(glucose)]
```

    ## [1] "P003"

------------------------------------------------------------------------

## Step 6: calculate mean observed glucose

``` r
mean(
  glucose,
  na.rm = TRUE
)
```

    ## [1] 111

------------------------------------------------------------------------

## Step 7: identify the highest SBP

``` r
which.max(sbp)
```

    ## [1] 4

``` r
id[which.max(sbp)]
```

    ## [1] "P004"

``` r
sbp[which.max(sbp)]
```

    ## [1] 155

------------------------------------------------------------------------

## Step 8: order participants by SBP

``` r
sbp_order <- order(
  sbp,
  decreasing = TRUE
)

id[sbp_order]
```

    ## [1] "P004" "P008" "P002" "P006" "P003" "P007" "P005" "P001"

``` r
sbp[sbp_order]
```

    ## [1] 155 150 145 142 132 128 121 118

------------------------------------------------------------------------

# 4.91 Independent exercise

Use:

``` r
id <- c(
  "S001", "S002", "S003", "S004", "S005",
  "S006", "S007", "S008", "S009", "S010"
)

age <- c(
  45, 62, 38, 51, 29,
  67, 55, 43, 59, 36
)

weight_kg <- c(
  72, 84, 65, 78, 59,
  91, 80, 69, 83, 64
)

height_m <- c(
  1.70, 1.75, 1.68, 1.72, 1.60,
  1.82, 1.76, 1.66, 1.74, 1.69
)

sbp <- c(
  122, 148, 130, 142, 115,
  155, 138, 128, 145, 120
)

glucose <- c(
  95, 130, 105, NA, 88,
  145, 110, 99, 128, NA
)

smoker <- c(
  FALSE, TRUE, TRUE, FALSE, FALSE,
  TRUE, FALSE, TRUE, TRUE, FALSE
)
```

Complete the following tasks:

1.  verify that all vectors have equal length;
2.  calculate BMI for all participants;
3.  round BMI to two decimal places;
4.  identify IDs of participants aged at least 50;
5.  count participants aged at least 50;
6.  calculate the proportion aged at least 50;
7.  identify smokers aged at least 50;
8.  identify participants with missing glucose;
9.  calculate mean glucose using observed values only;
10. identify the participant with the highest SBP;
11. order IDs from highest to lowest SBP;
12. display ages in the same SBP ordering;
13. find the positions where glucose is missing;
14. select recorded glucose values of at least 126;
15. use `range()` to obtain the age range.

------------------------------------------------------------------------

# 4.92 Challenge: duplicate IDs and dirty measurements

Consider:

``` r
id <- c(
  "P001",
  "P002",
  "P003",
  "P002",
  "P005",
  "P006"
)

glucose <- c(
  95,
  110,
  -999,
  108,
  130,
  -999
)
```

Tasks:

1.  identify duplicated IDs;
2.  count duplicated occurrences;
3.  display all IDs involved in duplication;
4.  inspect unique IDs;
5.  assuming study documentation confirms `-999` means missing, replace
    it with `NA`;
6.  count missing glucose values after replacement;
7.  calculate mean observed glucose;
8.  explain why duplicate IDs should not automatically be deleted.

------------------------------------------------------------------------

# 4.93 Challenge: genomic vectors

Use:

``` r
snp_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004",
  "rs1005",
  "rs1006",
  "rs1007",
  "rs1008"
)

chromosome <- c(
  6, 6, 6, 5,
  6, 6, 6, 7
)

position <- c(
  27500000,
  28900000,
  32600000,
  32000000,
  34100000,
  31200000,
  33500000,
  29000000
)

effect_allele <- c(
  "A", "G", "T", "C",
  "A", "G", "X", "T"
)

other_allele <- c(
  "G", "A", "C", "T",
  "C", "A", "C", "G"
)

beta <- c(
  0.03,
  -0.08,
  0.12,
  0.02,
  -0.04,
  0.09,
  -0.02,
  0.01
)

p_value <- c(
  1e-4,
  2e-9,
  4e-10,
  3e-8,
  0.02,
  8e-12,
  0.001,
  0.40
)
```

Tasks:

1.  verify equal vector lengths;
2.  identify chromosome 6 variants;
3.  select chromosome 6 variants between 27,000,000 and 34,000,000;
4.  identify variants with `p_value < 5e-8`;
5.  identify variants satisfying both the region and p-value conditions;
6.  sort variants from smallest to largest p-value;
7.  display beta values in the same p-value ordering;
8.  test effect alleles against `A`, `C`, `G`, and `T`;
9.  identify any invalid effect allele;
10. use `all()` to determine whether all effect alleles are valid.

------------------------------------------------------------------------

# 4.94 Complete Chapter 4 practice script

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 4: Vectors — The Foundation of R
# ============================================================


# ------------------------------------------------------------
# 1. Create vectors
# ------------------------------------------------------------

age <- c(
  34,
  52,
  46,
  67,
  29,
  58
)

age


# ------------------------------------------------------------
# 2. Inspect vector
# ------------------------------------------------------------

length(age)
class(age)
typeof(age)
str(age)


# ------------------------------------------------------------
# 3. Different vector types
# ------------------------------------------------------------

visits <- c(
  1L,
  2L,
  3L
)

participant_id <- c(
  "P001",
  "P002",
  "P003"
)

smoker <- c(
  FALSE,
  TRUE,
  FALSE
)

typeof(visits)
typeof(participant_id)
typeof(smoker)


# ------------------------------------------------------------
# 4. Sequences
# ------------------------------------------------------------

1:10

seq(
  from = 0,
  to = 24,
  by = 3
)

rep(
  c("Case", "Control"),
  times = 3
)


# ------------------------------------------------------------
# 5. Indexing
# ------------------------------------------------------------

age[1]
age[2]
age[c(1, 3, 6)]
age[2:5]
age[-1]
age[-c(2, 4)]


# ------------------------------------------------------------
# 6. Logical indexing
# ------------------------------------------------------------

age >= 50

age[age >= 50]


# ------------------------------------------------------------
# 7. Parallel vectors
# ------------------------------------------------------------

id <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)

smoker <- c(
  FALSE,
  TRUE,
  TRUE,
  FALSE,
  FALSE,
  TRUE
)

id[age >= 50]

id[
  (age >= 50) &
  smoker
]


# ------------------------------------------------------------
# 8. Vectorized arithmetic
# ------------------------------------------------------------

weight_kg <- c(
  68,
  82,
  75,
  90,
  61,
  79
)

height_m <- c(
  1.65,
  1.78,
  1.72,
  1.80,
  1.60,
  1.75
)

bmi <- weight_kg / height_m^2

round(
  bmi,
  2
)


# ------------------------------------------------------------
# 9. Missing values
# ------------------------------------------------------------

glucose <- c(
  92,
  105,
  NA,
  130,
  88,
  128
)

is.na(glucose)

sum(
  is.na(glucose)
)

glucose[
  !is.na(glucose)
]

mean(
  glucose,
  na.rm = TRUE
)


# ------------------------------------------------------------
# 10. Sorting and ordering
# ------------------------------------------------------------

sort(age)

age_order <- order(age)

id[age_order]
age[age_order]


# ------------------------------------------------------------
# 11. Minimum and maximum
# ------------------------------------------------------------

min(age)
max(age)
range(age)

id[
  which.max(age)
]


# ------------------------------------------------------------
# 12. Unique and duplicated values
# ------------------------------------------------------------

diagnosis <- c(
  "Control",
  "Case",
  "Case",
  "Control",
  "Case"
)

unique(diagnosis)

duplicate_test <- c(
  "P001",
  "P002",
  "P003",
  "P002",
  "P005"
)

duplicated(
  duplicate_test
)

duplicate_test[
  duplicated(duplicate_test)
]


# ------------------------------------------------------------
# 13. Membership
# ------------------------------------------------------------

selected_ids <- c(
  "P002",
  "P005"
)

id %in% selected_ids


# ------------------------------------------------------------
# 14. Genomic example
# ------------------------------------------------------------

snp_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004",
  "rs1005"
)

chromosome <- c(
  6,
  6,
  6,
  5,
  6
)

position <- c(
  27500000,
  28900000,
  32600000,
  32000000,
  34100000
)

p_value <- c(
  1e-4,
  2e-9,
  4e-10,
  3e-8,
  0.02
)

in_region <- chromosome == 6 &
  position >= 27000000 &
  position <= 34000000

significant <- p_value < 5e-8

selected <- in_region &
  significant

snp_id[selected]

p_order <- order(p_value)

snp_id[p_order]
p_value[p_order]
```

------------------------------------------------------------------------

# 4.95 Essential vector functions and syntax

| Task                    | R syntax           |
|-------------------------|--------------------|
| Create vector           | `c(...)`           |
| Create integer sequence | `1:10`             |
| Flexible sequence       | `seq()`            |
| Repeat values           | `rep()`            |
| Vector length           | `length(x)`        |
| Inspect class           | `class(x)`         |
| Inspect internal type   | `typeof(x)`        |
| Inspect structure       | `str(x)`           |
| Element names           | `names(x)`         |
| Select position         | `x[1]`             |
| Select positions        | `x[c(1, 3)]`       |
| Exclude position        | `x[-1]`            |
| Logical selection       | `x[condition]`     |
| Named selection         | `x["name"]`        |
| Sort values             | `sort(x)`          |
| Ordering positions      | `order(x)`         |
| Minimum                 | `min(x)`           |
| Maximum                 | `max(x)`           |
| Range                   | `range(x)`         |
| Position of minimum     | `which.min(x)`     |
| Position of maximum     | `which.max(x)`     |
| Unique values           | `unique(x)`        |
| Duplicate test          | `duplicated(x)`    |
| Membership              | `x %in% values`    |
| Missing-value test      | `is.na(x)`         |
| Positions               | `which(condition)` |
| Any TRUE                | `any(condition)`   |
| All TRUE                | `all(condition)`   |

------------------------------------------------------------------------

# 4.96 Concept map

``` text
Individual values
       │
       ↓
      c()
       │
       ↓
     Vector
       │
       ├──────────────┬──────────────┬──────────────┐
       ↓              ↓              ↓              ↓
    numeric        integer       character       logical
       │
       ↓
  common type
  / coercion
       │
       ↓
   indexing
       │
       ├──────────────┬──────────────┬──────────────┐
       ↓              ↓              ↓              ↓
   positive        negative        logical         names
       │
       ↓
 vectorized operations
       │
       ├──────────────┬──────────────┬──────────────┐
       ↓              ↓              ↓              ↓
 arithmetic       comparison      sorting       membership
       │
       ↓
 parallel research variables
       │
       ├───────────────────┐
       ↓                   ↓
participant data      genomic data
```

------------------------------------------------------------------------

# 4.97 Chapter review

Before moving forward, we should be able to answer:

1.  What is a vector?
2.  What does `c()` do?
3.  Why are basic vectors described as atomic?
4.  What happens when numeric and character values are combined?
5.  What is the difference between `1:10` and `seq()`?
6.  How does `rep(..., times=)` differ from `rep(..., each=)`?
7.  What does `length()` tell us?
8.  Why does R use `x[1]` rather than `x[0]` for the first element?
9.  What is positive indexing?
10. What is negative indexing?
11. What is logical indexing?
12. What does `x[x >= 50]` mean?
13. What are parallel vectors?
14. Why should parallel vectors usually have equal lengths?
15. What is vectorized arithmetic?
16. What is recycling?
17. Why can unexpected recycling be dangerous?
18. What is the difference between `sort()` and `order()`?
19. What does `unique()` return?
20. What does `duplicated()` identify?
21. How do we identify missing values in a vector?
22. Why can `x[x >= threshold]` behave unexpectedly when `x` contains
    `NA`?
23. How can a logical vector derived from one variable select
    corresponding values from another vector?
24. How can vector operations be used to select genomic variants?

------------------------------------------------------------------------

# 4.98 Key takeaways

1.  A vector is a one-dimensional collection of values.
2.  `c()` is the most common way to construct a vector.
3.  Basic vectors are atomic and therefore have a common underlying
    type.
4.  Mixing types can trigger automatic coercion.
5.  `length()`, `class()`, `typeof()`, and `str()` help us inspect
    vectors.
6.  `:`, `seq()`, and `rep()` efficiently generate repeated or
    sequential values.
7.  Square brackets provide vector indexing.
8.  R uses 1-based indexing.
9.  Positive indices select positions; negative indices exclude them.
10. Logical indexing selects elements according to `TRUE` and `FALSE`.
11. Named vectors allow selection by element names.
12. Arithmetic and comparisons are usually vectorized.
13. Recycling repeats shorter vectors, but unexpected recycling can
    cause errors.
14. Parallel vectors depend on positional correspondence.
15. `sort()` returns sorted values, while `order()` returns ordering
    positions.
16. `unique()` and `duplicated()` help audit repeated values.
17. `is.na()` identifies missing observations.
18. Proper handling of missing values is essential during vector
    selection.
19. The same vector logic applies to participant data and genomic data.
20. Vectors form the computational foundation for many higher-level R
    structures.

The central idea is:

> **Instead of processing one observation at a time, R allows us to
> express an operation once and apply it across an entire vector.**

------------------------------------------------------------------------

# 4.99 Looking ahead

Vectors contain values of one common basic type. Real biomedical
datasets, however, contain different kinds of variables:

``` text
Participant ID → character
Age            → numeric
Sex            → categorical
Smoking        → categorical
Glucose        → numeric
Disease group  → categorical
```

Before combining these variables into full datasets, we need to
understand how R represents **categorical information**.

A variable such as:

``` text
Control
Case
Case
Control
```

is scientifically categorical, but simply storing the labels as
character data does not capture every feature needed for statistical
modeling.

R provides a dedicated structure for categorical variables: the
**factor**.

The next chapter is:

**Chapter 5 — Factors and Categorical Variables**
