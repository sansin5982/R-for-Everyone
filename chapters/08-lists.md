Lists: Organizing Different Types of Research Data
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 7, we learned that arrays organize measurements across
multiple dimensions. Arrays are powerful when every element has the same
underlying atomic type and observations form a regular grid. But a
typical biomedical analysis produces **different kinds of information**:
participant identifiers, numerical laboratory values, a gene-expression
matrix, a quality-control indicator, and a study description. We need a
structure that can store these objects together without converting them
all to character values.

In R, that structure is a **list**.

A list can contain objects of different types, different lengths, and
even other lists. It is one of the most important structures in R
because functions frequently return lists containing estimates,
diagnostics, and metadata.

> **Core principle:** A list is a collection of elements. Each element
> can itself be a vector, matrix, array, list, or another R object.

This chapter uses **base R only** and introduces lists before we study
data frames in Chapter 9.

## 8.1 Learning objectives

After completing this chapter, we should be able to:

1.  Explain why lists differ from atomic vectors, matrices, and arrays.
2.  Create unnamed and named lists with `list()`.
3.  Inspect a list with `str()`, `length()`, `names()`, `class()`, and
    `typeof()`.
4.  Distinguish `[ ]`, `[[ ]]`, and `$` precisely.
5.  Extract, replace, append, and remove list elements.
6.  Work with nested lists and nested indexing.
7.  Recognize partial matching risks and use exact indexing.
8.  Combine lists and understand `c()` versus `append()`.
9.  Use `lapply()`, `sapply()`, and `vapply()` at an introductory level.
10. Convert suitable lists to data frames without assuming every list is
    tabular.
11. Organize synthetic biomedical and genomic results in structured
    lists.
12. Apply basic checks to avoid silent data misalignment.

------------------------------------------------------------------------

## 8.2 Why do we need lists?

Imagine a study with the following information:

``` r
study_id <- "SCZ_demo_001"
participants <- 5L
case_control <- c("case", "control", "case", "control", "case")
glucose <- c(91, 105, 98, 110, 95)
quality_checked <- TRUE
```

These objects have different types and roles. An atomic vector cannot
preserve all of their types if we combine them directly:

``` r
c(study_id, participants, quality_checked)
```

    ## [1] "SCZ_demo_001" "5"            "TRUE"

Because one value is character, the result is a character vector. A list
avoids this coercion:

``` r
study <- list(
  study_id = "SCZ_demo_001",
  participants = 5L,
  case_control = c("case", "control", "case", "control", "case"),
  glucose = c(91, 105, 98, 110, 95),
  quality_checked = TRUE
)
study
```

    ## $study_id
    ## [1] "SCZ_demo_001"
    ## 
    ## $participants
    ## [1] 5
    ## 
    ## $case_control
    ## [1] "case"    "control" "case"    "control" "case"   
    ## 
    ## $glucose
    ## [1]  91 105  98 110  95
    ## 
    ## $quality_checked
    ## [1] TRUE

We retain the original types of the elements:

``` r
typeof(study$study_id)
```

    ## [1] "character"

``` r
typeof(study$participants)
```

    ## [1] "integer"

``` r
typeof(study$glucose)
```

    ## [1] "double"

``` r
typeof(study$quality_checked)
```

    ## [1] "logical"

A list does **not** force its components to have the same length or
type.

## 8.3 Creating a simple list

The basic syntax is:

``` r
list(element1, element2, element3)
```

Create an unnamed list:

``` r
patient <- list("P001", 45, TRUE, c(110, 118, 115))
patient
```

    ## [[1]]
    ## [1] "P001"
    ## 
    ## [[2]]
    ## [1] 45
    ## 
    ## [[3]]
    ## [1] TRUE
    ## 
    ## [[4]]
    ## [1] 110 118 115

The elements are:

- a character identifier;
- a numeric age;
- a logical flag;
- a numeric vector of repeated measurements.

The **fourth element is one vector**, not three separate list elements.

``` r
length(patient)
```

    ## [1] 4

``` r
length(patient[[4]])
```

    ## [1] 3

`length(patient)` returns the number of **top-level list elements**,
whereas `length(patient[[4]])` returns the number of measurements in the
fourth element.

## 8.4 Named lists

Named elements make a list easier to interpret:

``` r
patient <- list(
  id = "P001",
  age = 45,
  consent = TRUE,
  sbp = c(110, 118, 115)
)
patient
```

    ## $id
    ## [1] "P001"
    ## 
    ## $age
    ## [1] 45
    ## 
    ## $consent
    ## [1] TRUE
    ## 
    ## $sbp
    ## [1] 110 118 115

Check the names:

``` r
names(patient)
```

    ## [1] "id"      "age"     "consent" "sbp"

Named lists are particularly useful for returning several related
research outputs from one function.

## 8.5 Inspecting list structure

A list may contain complicated objects. Printing the entire list is not
always useful.

``` r
str(patient)
```

    ## List of 4
    ##  $ id     : chr "P001"
    ##  $ age    : num 45
    ##  $ consent: logi TRUE
    ##  $ sbp    : num [1:3] 110 118 115

``` r
class(patient)
```

    ## [1] "list"

``` r
typeof(patient)
```

    ## [1] "list"

``` r
length(patient)
```

    ## [1] 4

``` r
is.list(patient)
```

    ## [1] TRUE

`str()` is often the most useful first inspection because it summarizes
each element’s structure and type.

The `typeof()` result is `"list"`, reflecting R’s underlying list type.
The list’s **elements**, however, can have their own types.

## 8.6 The three main extraction operators

The most important list skill is distinguishing:

``` text
[ ]     returns a sublist
[[ ]]   extracts one element
$       extracts a named element
```

We will explore each carefully.

### 8.6.1 Single brackets return a list

``` r
patient[1]
```

    ## $id
    ## [1] "P001"

``` r
class(patient[1])
```

    ## [1] "list"

``` r
length(patient[1])
```

    ## [1] 1

The result is a **one-element list** containing the `id` element.

Selecting multiple elements also returns a list:

``` r
patient[c(1, 3)]
```

    ## $id
    ## [1] "P001"
    ## 
    ## $consent
    ## [1] TRUE

``` r
patient[c("id", "consent")]
```

    ## $id
    ## [1] "P001"
    ## 
    ## $consent
    ## [1] TRUE

### 8.6.2 Double brackets extract one element

``` r
patient[[1]]
```

    ## [1] "P001"

``` r
class(patient[[1]])
```

    ## [1] "character"

This returns the underlying character value `"P001"`, not a one-element
list.

``` r
patient[[4]]
```

    ## [1] 110 118 115

``` r
class(patient[[4]])
```

    ## [1] "numeric"

Here we retrieve the numerical vector stored in the fourth element.

### 8.6.3 Dollar notation retrieves a named element

``` r
patient$id
```

    ## [1] "P001"

``` r
patient$age
```

    ## [1] 45

``` r
patient$sbp
```

    ## [1] 110 118 115

Dollar notation is readable when element names are fixed and known.

### 8.6.4 Compare the three forms

``` r
patient["sbp"]
```

    ## $sbp
    ## [1] 110 118 115

``` r
patient[["sbp"]]
```

    ## [1] 110 118 115

``` r
patient$sbp
```

    ## [1] 110 118 115

The first is a list. The second and third retrieve the contained vector.

| Syntax       | Meaning                  | Typical result   |
|--------------|--------------------------|------------------|
| `x[1]`       | Select list positions    | A list           |
| `x[c(1, 3)]` | Select several positions | A list           |
| `x[[1]]`     | Extract one element      | Contained object |
| `x[["age"]]` | Extract named element    | Contained object |
| `x$age`      | Retrieve named element   | Contained object |

**Memory rule:** `[ ]` keeps the list wrapper; `[[ ]]` opens it.

## 8.7 Indexing a vector inside a list

Suppose `sbp` contains three measurements:

``` r
patient$sbp
```

    ## [1] 110 118 115

To obtain the second measurement:

``` r
patient$sbp[2]
```

    ## [1] 118

``` r
patient[["sbp"]][2]
```

    ## [1] 118

Read the first expression from left to right:

1.  `patient$sbp` retrieves the numerical vector.
2.  `[2]` selects its second value.

The same idea applies to matrices and arrays stored in lists.

## 8.8 Adding new elements

We can add a new named element:

``` r
patient$weight_kg <- 76
patient
```

    ## $id
    ## [1] "P001"
    ## 
    ## $age
    ## [1] 45
    ## 
    ## $consent
    ## [1] TRUE
    ## 
    ## $sbp
    ## [1] 110 118 115
    ## 
    ## $weight_kg
    ## [1] 76

Or use double brackets:

``` r
patient[["height_m"]] <- 1.74
patient
```

    ## $id
    ## [1] "P001"
    ## 
    ## $age
    ## [1] 45
    ## 
    ## $consent
    ## [1] TRUE
    ## 
    ## $sbp
    ## [1] 110 118 115
    ## 
    ## $weight_kg
    ## [1] 76
    ## 
    ## $height_m
    ## [1] 1.74

Calculate BMI using the stored measurements:

``` r
patient$bmi <- patient$weight_kg / patient$height_m^2
patient$bmi
```

    ## [1] 25.10239

This preserves the participant’s measurements and derived result in one
organized object.

## 8.9 Modifying existing elements

``` r
patient$age <- 46
patient$sbp[3] <- 117
patient$age
```

    ## [1] 46

``` r
patient$sbp
```

    ## [1] 110 118 117

Replacing a list element does not require its new value to have the same
type as before. That flexibility is useful, but it also means we must
validate the structure we expect.

## 8.10 Removing elements

Assigning `NULL` to a named element removes it:

``` r
temporary <- list(a = 1, b = 2, c = 3)
temporary$b <- NULL
temporary
```

    ## $a
    ## [1] 1
    ## 
    ## $c
    ## [1] 3

A crucial distinction:

``` r
with_null <- list(a = 1, b = NULL, c = 3)
length(with_null)
```

    ## [1] 3

``` r
names(with_null)
```

    ## [1] "a" "b" "c"

This list **contains** an element whose value is `NULL`.

Compare with removal:

``` r
with_null["b"] <- NULL
length(with_null)
```

    ## [1] 2

``` r
names(with_null)
```

    ## [1] "a" "c"

Here the `b` element is removed.

### Preserving a NULL-valued element

If we want to replace an element with `NULL` while keeping its position,
use single-bracket replacement with a one-element list:

``` r
keep_null <- list(a = 1, b = 2)
keep_null["b"] <- list(NULL)
length(keep_null)
```

    ## [1] 2

This distinction matters when `NULL` is used to mean that a result was
not produced.

## 8.11 Missing values versus missing elements

`NA` and `NULL` do not mean the same thing.

``` r
example <- list(
  glucose = NA_real_,
  medication = NULL,
  age = 50
)
example
```

    ## $glucose
    ## [1] NA
    ## 
    ## $medication
    ## NULL
    ## 
    ## $age
    ## [1] 50

- `glucose = NA_real_`: a numeric measurement is missing.
- `medication = NULL`: the element exists but contains no object.
- An element absent from the list: no such named element was stored.

We can test:

``` r
is.na(example$glucose)
```

    ## [1] TRUE

``` r
is.null(example$medication)
```

    ## [1] TRUE

``` r
"medication" %in% names(example)
```

    ## [1] TRUE

``` r
"diagnosis" %in% names(example)
```

    ## [1] FALSE

**Caution:** `example$diagnosis` also evaluates to `NULL` when the
element is absent. Therefore, `is.null(example$diagnosis)` alone cannot
distinguish an absent element from an existing `NULL`-valued element.
Inspect `names(example)` when that distinction matters.

## 8.12 Exact name matching and the risk of `$`

For programming, exact matching is safer than relying on abbreviated
names.

``` r
results <- list(
  sample_size = 100,
  sample_missing = 5
)
results[["sample_size"]]
```

    ## [1] 100

The `[[ ]]` operator can require exact matching:

``` r
results[["sample", exact = TRUE]]  # NULL: no exact name
```

    ## NULL

By contrast, `$` can perform partial matching in some circumstances. We
should use full names, and for dynamic programmatic lookup prefer
`[[name, exact = TRUE]]`.

For example:

``` r
field <- "sample_size"
results[[field, exact = TRUE]]
```

    ## [1] 100

`results$field` would look for an element literally named `field`, not
use the value of the variable `field`.

## 8.13 Unnamed lists and positional indexing

Lists do not require names:

``` r
unnamed <- list(10, "P001", c(TRUE, FALSE))
unnamed[[2]]
```

    ## [1] "P001"

However, positions are easier to confuse than descriptive names. In
research scripts, named lists are usually more maintainable.

## 8.14 Nested lists

A list can contain another list:

``` r
study <- list(
  metadata = list(
    study_id = "BIO_001",
    site = "Site_A",
    year = 2026
  ),
  participant = list(
    id = "P001",
    age = 45,
    measurements = list(
      glucose = c(95, 100, 98),
      sbp = c(128, 130, 126)
    )
  )
)
str(study)
```

    ## List of 2
    ##  $ metadata   :List of 3
    ##   ..$ study_id: chr "BIO_001"
    ##   ..$ site    : chr "Site_A"
    ##   ..$ year    : num 2026
    ##  $ participant:List of 3
    ##   ..$ id          : chr "P001"
    ##   ..$ age         : num 45
    ##   ..$ measurements:List of 2
    ##   .. ..$ glucose: num [1:3] 95 100 98
    ##   .. ..$ sbp    : num [1:3] 128 130 126

Nested lists organize information hierarchically.

### Access nested elements with `$`

``` r
study$metadata$study_id
```

    ## [1] "BIO_001"

``` r
study$participant$measurements$glucose
```

    ## [1]  95 100  98

### Access nested elements with `[[ ]]`

``` r
study[["participant"]][["measurements"]][["glucose"]]
```

    ## [1]  95 100  98

### Use a path of names

For nested lists, `[[ ]]` also accepts a vector describing a path:

``` r
study[[c("participant", "measurements", "glucose")]]
```

    ## [1]  95 100  98

This is convenient when the path is constructed programmatically.

## 8.15 Nested indexing step by step

Suppose we need the second glucose measurement:

``` r
study$participant$measurements$glucose[2]
```

    ## [1] 100

We can break this into intermediate objects:

``` r
participant_info <- study$participant
measurements <- participant_info$measurements
glucose <- measurements$glucose
glucose[2]
```

    ## [1] 100

Both approaches return the same measurement. Intermediate objects are
often easier to debug when learning.

## 8.16 Lists containing matrices

In genomics, an analysis may produce a genotype matrix plus variant and
sample metadata.

``` r
dosage <- matrix(
  c(0, 1, 2,
    1, 0, 1,
    2, 1, 0,
    0, 2, 1),
  nrow = 4,
  byrow = TRUE,
  dimnames = list(
    c("P001", "P002", "P003", "P004"),
    c("rs1001", "rs1002", "rs1003")
  )
)

genomic <- list(
  dosage = dosage,
  genome_build = "GRCh38",
  counted_allele = c(rs1001 = "A", rs1002 = "G", rs1003 = "T"),
  qc_complete = FALSE
)
str(genomic)
```

    ## List of 4
    ##  $ dosage        : num [1:4, 1:3] 0 1 2 0 1 0 1 2 2 1 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##   .. ..$ : chr [1:4] "P001" "P002" "P003" "P004"
    ##   .. ..$ : chr [1:3] "rs1001" "rs1002" "rs1003"
    ##  $ genome_build  : chr "GRCh38"
    ##  $ counted_allele: Named chr [1:3] "A" "G" "T"
    ##   ..- attr(*, "names")= chr [1:3] "rs1001" "rs1002" "rs1003"
    ##  $ qc_complete   : logi FALSE

Extract the dosage matrix:

``` r
genomic$dosage
```

    ##      rs1001 rs1002 rs1003
    ## P001      0      1      2
    ## P002      1      0      1
    ## P003      2      1      0
    ## P004      0      2      1

Extract one variant’s dosages:

``` r
genomic$dosage[, "rs1002"]
```

    ## P001 P002 P003 P004 
    ##    1    0    1    2

Extract a one-column matrix without dropping dimensions:

``` r
genomic$dosage[, "rs1002", drop = FALSE]
```

    ##      rs1002
    ## P001      1
    ## P002      0
    ## P003      1
    ## P004      2

The list does not replace the matrix: it **contains** the matrix along
with its metadata.

## 8.17 Lists containing arrays

A list can similarly contain a multidimensional array:

``` r
expression_array <- array(
  1:12,
  dim = c(2, 3, 2),
  dimnames = list(
    Gene = c("G1", "G2"),
    Sample = c("S1", "S2", "S3"),
    Visit = c("T0", "T1")
  )
)

expression_result <- list(
  expression = expression_array,
  unit = "synthetic expression units",
  normalized = FALSE
)

dim(expression_result$expression)
```

    ## [1] 2 3 2

``` r
expression_result$expression[, , "T0"]
```

    ##     Sample
    ## Gene S1 S2 S3
    ##   G1  1  3  5
    ##   G2  2  4  6

This illustrates how lists and arrays complement each other.

## 8.18 Lists versus matrices and arrays

| Property | Atomic vector | Matrix | Array | List |
|----|----|----|----|----|
| Typical dimensions | No explicit `dim` | 2 | 1 or more | Elements, not a rectangular grid |
| All values same atomic type? | Yes | Yes | Yes | No |
| Elements can be matrices? | No | No | No | Yes |
| Elements can have different lengths? | Not applicable | No | No | Yes |
| Nested structure? | No | No | No | Yes |
| Common use | Measurements | Numerical table | Multidimensional assay | Related heterogeneous outputs |

A data frame, introduced in Chapter 9, is itself a specialized list
whose columns ordinarily have a common number of rows.

## 8.19 Combining lists with `c()`

The `c()` function combines list elements at the top level:

``` r
a <- list(id = "P001", age = 45)
b <- list(glucose = 105, consent = TRUE)
combined <- c(a, b)
combined
```

    ## $id
    ## [1] "P001"
    ## 
    ## $age
    ## [1] 45
    ## 
    ## $glucose
    ## [1] 105
    ## 
    ## $consent
    ## [1] TRUE

``` r
names(combined)
```

    ## [1] "id"      "age"     "glucose" "consent"

The result contains four top-level elements.

Be careful when combining lists with overlapping names:

``` r
a <- list(status = "pending")
b <- list(status = "complete")
c(a, b)
```

    ## $status
    ## [1] "pending"
    ## 
    ## $status
    ## [1] "complete"

The result can contain **duplicate names**, which make name-based
extraction ambiguous.

``` r
anyDuplicated(names(c(a, b)))
```

    ## [1] 2

For important research metadata, duplicate names should usually be
detected and resolved.

## 8.20 Appending elements with `append()`

``` r
values <- list("P001", 45)
append(values, list(TRUE))
```

    ## [[1]]
    ## [1] "P001"
    ## 
    ## [[2]]
    ## [1] 45
    ## 
    ## [[3]]
    ## [1] TRUE

We can insert an element after a particular position:

``` r
append(values, list("Site_A"), after = 1)
```

    ## [[1]]
    ## [1] "P001"
    ## 
    ## [[2]]
    ## [1] "Site_A"
    ## 
    ## [[3]]
    ## [1] 45

Remember that `append()` returns a new object; assign its result if we
want to keep the change.

``` r
values <- append(values, list(TRUE))
values
```

    ## [[1]]
    ## [1] "P001"
    ## 
    ## [[2]]
    ## [1] 45
    ## 
    ## [[3]]
    ## [1] TRUE

## 8.21 Converting a list to an atomic vector with `unlist()`

``` r
measurements <- list(
  baseline = c(95, 100),
  followup = c(98, 103)
)
unlist(measurements)
```

    ## baseline1 baseline2 followup1 followup2 
    ##        95       100        98       103

This can be useful when all elements contain compatible atomic values.

However, flattening a heterogeneous list may coerce types:

``` r
mixed <- list(id = "P001", age = 45, consent = TRUE)
unlist(mixed)
```

    ##      id     age consent 
    ##  "P001"    "45"  "TRUE"

The result is a character vector because it contains a character
identifier.

**Important:** `unlist()` changes the structure and can discard the
distinction between separate components. It is not appropriate for every
list.

## 8.22 `list()` versus `c()`

Compare:

``` r
c(1, 2, 3)
```

    ## [1] 1 2 3

``` r
list(1, 2, 3)
```

    ## [[1]]
    ## [1] 1
    ## 
    ## [[2]]
    ## [1] 2
    ## 
    ## [[3]]
    ## [1] 3

The first is an atomic vector. The second is a list containing three
elements.

Compare again:

``` r
c(c(1, 2), c(3, 4))
```

    ## [1] 1 2 3 4

``` r
list(c(1, 2), c(3, 4))
```

    ## [[1]]
    ## [1] 1 2
    ## 
    ## [[2]]
    ## [1] 3 4

The first combines values into one vector. The second keeps two vectors
as separate list elements.

## 8.23 Iterating over lists: an introduction to `lapply()`

A list may contain multiple numerical vectors, each representing a
different biomarker:

``` r
biomarkers <- list(
  glucose = c(95, 100, 105),
  cholesterol = c(175, 180, 178),
  crp = c(2.1, 2.4, 2.2)
)
```

Use `lapply()` to apply a function to each element:

``` r
means <- lapply(biomarkers, mean)
means
```

    ## $glucose
    ## [1] 100
    ## 
    ## $cholesterol
    ## [1] 177.6667
    ## 
    ## $crp
    ## [1] 2.233333

``` r
class(means)
```

    ## [1] "list"

The result is a list. Each component contains one mean.

The general syntax is:

``` r
lapply(X, FUN, ...)
```

We will study the apply family in detail in Chapter 13. Here we only
need to understand that `lapply()` is a convenient way to process each
list element.

## 8.24 `sapply()` and simplifying results

``` r
sapply(biomarkers, mean)
```

    ##     glucose cholesterol         crp 
    ##  100.000000  177.666667    2.233333

When possible, `sapply()` simplifies its output to a vector or matrix.
That simplification can make downstream code less predictable when
element lengths vary.

Compare:

``` r
lapply(biomarkers, mean)
```

    ## $glucose
    ## [1] 100
    ## 
    ## $cholesterol
    ## [1] 177.6667
    ## 
    ## $crp
    ## [1] 2.233333

``` r
sapply(biomarkers, mean)
```

    ##     glucose cholesterol         crp 
    ##  100.000000  177.666667    2.233333

For research scripts where output type must be stable, `lapply()` or
`vapply()` is often preferable.

## 8.25 `vapply()` and explicit output types

`vapply()` requires a description of the expected output:

``` r
vapply(biomarkers, mean, numeric(1))
```

    ##     glucose cholesterol         crp 
    ##  100.000000  177.666667    2.233333

Here `numeric(1)` means that each result must be one numeric value.

This makes the intended output structure explicit and helps catch
unexpected results.

We will return to `lapply()`, `sapply()`, and `vapply()` in Chapter 13.

## 8.26 Handling missing measurements inside list elements

``` r
biomarkers_missing <- list(
  glucose = c(95, NA, 105),
  cholesterol = c(175, 180, NA),
  crp = c(2.1, 2.4, 2.2)
)
```

Without removing missing values:

``` r
lapply(biomarkers_missing, mean)
```

    ## $glucose
    ## [1] NA
    ## 
    ## $cholesterol
    ## [1] NA
    ## 
    ## $crp
    ## [1] 2.233333

With `na.rm = TRUE`:

``` r
lapply(biomarkers_missing, mean, na.rm = TRUE)
```

    ## $glucose
    ## [1] 100
    ## 
    ## $cholesterol
    ## [1] 177.5
    ## 
    ## $crp
    ## [1] 2.233333

Count missing observations in each component:

``` r
lapply(biomarkers_missing, function(x) sum(is.na(x)))
```

    ## $glucose
    ## [1] 1
    ## 
    ## $cholesterol
    ## [1] 1
    ## 
    ## $crp
    ## [1] 0

The expression `function(x) ...` defines a small anonymous function. We
will learn to write our own functions in Chapter 12; for now, we can
read it as “for each vector `x`, count its missing values.”

## 8.27 A list can contain functions

Functions are R objects and can be stored in lists:

``` r
summary_functions <- list(
  average = mean,
  middle = median,
  spread = sd
)
summary_functions$average(c(1, 2, 3))
```

    ## [1] 2

This is an illustration of R’s flexibility. We do not need to use
function-valued lists routinely at this stage.

## 8.28 A list of participants

Suppose each participant has a different number of follow-up
measurements:

``` r
participants <- list(
  P001 = list(age = 42, sbp = c(125, 130, 128)),
  P002 = list(age = 51, sbp = c(140, 138)),
  P003 = list(age = 37, sbp = c(118, 120, 119, 121))
)
str(participants)
```

    ## List of 3
    ##  $ P001:List of 2
    ##   ..$ age: num 42
    ##   ..$ sbp: num [1:3] 125 130 128
    ##  $ P002:List of 2
    ##   ..$ age: num 51
    ##   ..$ sbp: num [1:2] 140 138
    ##  $ P003:List of 2
    ##   ..$ age: num 37
    ##   ..$ sbp: num [1:4] 118 120 119 121

This is an example of **irregular data**: the SBP vectors do not all
have the same length.

Extract the third participant’s measurements:

``` r
participants$P003$sbp
```

    ## [1] 118 120 119 121

Calculate the mean SBP for each participant:

``` r
vapply(participants, function(x) mean(x$sbp), numeric(1))
```

    ##     P001     P002     P003 
    ## 127.6667 139.0000 119.5000

The list structure handles unequal visit counts without padding every
participant’s record to the same length.

## 8.29 A list of research results

A statistical analysis often returns several related outputs:

``` r
analysis <- list(
  study = "Synthetic biomarker example",
  n = 5L,
  values = c(95, 100, 105, 98, 102),
  summary = list(
    mean = mean(c(95, 100, 105, 98, 102)),
    sd = sd(c(95, 100, 105, 98, 102))
  ),
  qc = list(
    missing_n = 0L,
    passed = TRUE
  )
)
str(analysis)
```

    ## List of 5
    ##  $ study  : chr "Synthetic biomarker example"
    ##  $ n      : int 5
    ##  $ values : num [1:5] 95 100 105 98 102
    ##  $ summary:List of 2
    ##   ..$ mean: num 100
    ##   ..$ sd  : num 3.81
    ##  $ qc     :List of 2
    ##   ..$ missing_n: int 0
    ##   ..$ passed   : logi TRUE

Retrieve the mean:

``` r
analysis$summary$mean
```

    ## [1] 100

Retrieve the QC status:

``` r
analysis$qc$passed
```

    ## [1] TRUE

This pattern appears throughout R packages: a single returned object may
contain coefficients, predictions, residuals, warnings, and diagnostics.

## 8.30 Biomedical example: participant record

We will construct a small record containing demographic information,
repeated laboratory measurements, and a consent flag. This is
**synthetic data**, not a clinical record.

``` r
record <- list(
  participant_id = "P1001",
  demographics = list(
    age = 48,
    sex_recorded = "F"
  ),
  visits = c("Baseline", "Month3", "Month6"),
  glucose = c(105, 100, 97),
  sbp = c(142, 138, 134),
  consent = TRUE
)
```

Inspect:

``` r
str(record)
```

    ## List of 6
    ##  $ participant_id: chr "P1001"
    ##  $ demographics  :List of 2
    ##   ..$ age         : num 48
    ##   ..$ sex_recorded: chr "F"
    ##  $ visits        : chr [1:3] "Baseline" "Month3" "Month6"
    ##  $ glucose       : num [1:3] 105 100 97
    ##  $ sbp           : num [1:3] 142 138 134
    ##  $ consent       : logi TRUE

``` r
record$demographics$age
```

    ## [1] 48

``` r
record$glucose[1]
```

    ## [1] 105

``` r
record$glucose[3]
```

    ## [1] 97

Calculate changes from baseline to Month6:

``` r
glucose_change <- record$glucose[3] - record$glucose[1]
sbp_change <- record$sbp[3] - record$sbp[1]
glucose_change
```

    ## [1] -8

``` r
sbp_change
```

    ## [1] -8

Add results to the record:

``` r
record$changes <- list(
  glucose = glucose_change,
  sbp = sbp_change
)
record$changes
```

    ## $glucose
    ## [1] -8
    ## 
    ## $sbp
    ## [1] -8

## 8.31 Genomics example: a variant-analysis bundle

A variant-analysis workflow may need to keep summary statistics,
alleles, quality-control information, and genomic build together.

``` r
variant_results <- list(
  metadata = list(
    trait = "Schizophrenia (synthetic example)",
    build = "GRCh38",
    chromosome = 6L
  ),
  variants = c("rs1001", "rs1002", "rs1003"),
  positions = c(31200000L, 32400000L, 32600000L),
  effect_allele = c("A", "G", "T"),
  other_allele = c("G", "A", "C"),
  beta = c(0.04, -0.03, 0.07),
  se = c(0.01, 0.015, 0.02),
  pvalue = c(6.3e-5, 0.0455, 0.00047),
  qc = list(
    harmonized = TRUE,
    excluded_palindromic = 0L
  )
)
str(variant_results)
```

    ## List of 9
    ##  $ metadata     :List of 3
    ##   ..$ trait     : chr "Schizophrenia (synthetic example)"
    ##   ..$ build     : chr "GRCh38"
    ##   ..$ chromosome: int 6
    ##  $ variants     : chr [1:3] "rs1001" "rs1002" "rs1003"
    ##  $ positions    : int [1:3] 31200000 32400000 32600000
    ##  $ effect_allele: chr [1:3] "A" "G" "T"
    ##  $ other_allele : chr [1:3] "G" "A" "C"
    ##  $ beta         : num [1:3] 0.04 -0.03 0.07
    ##  $ se           : num [1:3] 0.01 0.015 0.02
    ##  $ pvalue       : num [1:3] 0.000063 0.0455 0.00047
    ##  $ qc           :List of 2
    ##   ..$ harmonized          : logi TRUE
    ##   ..$ excluded_palindromic: int 0

The example uses invented values to demonstrate structure. No real
association result is implied.

### Check that variant-level vectors are aligned

``` r
n <- length(variant_results$variants)
stopifnot(length(variant_results$positions) == n)
stopifnot(length(variant_results$effect_allele) == n)
stopifnot(length(variant_results$other_allele) == n)
stopifnot(length(variant_results$beta) == n)
stopifnot(length(variant_results$se) == n)
stopifnot(length(variant_results$pvalue) == n)
```

Equal lengths are necessary but not sufficient: each position in every
vector must refer to the **same variant**.

### Extract one variant by its index

``` r
i <- match("rs1002", variant_results$variants)
i
```

    ## [1] 2

``` r
variant_results$beta[i]
```

    ## [1] -0.03

``` r
variant_results$effect_allele[i]
```

    ## [1] "G"

`match()` finds the position of a requested identifier. In later
chapters we will learn safer methods for joining and harmonizing
research tables.

## 8.32 Organizing COLOC-style output

Suppose a demonstration colocalization workflow returns a gene name and
five posterior probabilities. These are **illustrative values only**.

``` r
coloc_result <- list(
  gene = "GENE_X",
  region = "chr6_demo_region",
  n_snps = 250L,
  posterior = c(
    PP.H0 = 0.01,
    PP.H1 = 0.02,
    PP.H2 = 0.02,
    PP.H3 = 0.05,
    PP.H4 = 0.90
  ),
  diagnostics = list(
    alleles_harmonized = TRUE,
    palindromic_removed = TRUE
  )
)
```

Extract the posterior for hypothesis H4:

``` r
coloc_result$posterior["PP.H4"]
```

    ## PP.H4 
    ##   0.9

Check whether posterior probabilities sum to approximately 1:

``` r
sum(coloc_result$posterior)
```

    ## [1] 1

``` r
isTRUE(all.equal(sum(coloc_result$posterior), 1))
```

    ## [1] TRUE

The list organizes results but does not itself establish whether an
analysis was correctly specified or scientifically valid.

## 8.33 A list of gene-level results

A workflow may generate a separate result for each gene:

``` r
gene_results <- list(
  Gene_A = list(n_snps = 120L, pp_h4 = 0.85),
  Gene_B = list(n_snps = 95L, pp_h4 = 0.42),
  Gene_C = list(n_snps = 210L, pp_h4 = 0.91)
)
```

Extract one gene’s result:

``` r
gene_results$Gene_B
```

    ## $n_snps
    ## [1] 95
    ## 
    ## $pp_h4
    ## [1] 0.42

Collect all H4 posterior probabilities:

``` r
vapply(gene_results, function(x) x$pp_h4, numeric(1))
```

    ## Gene_A Gene_B Gene_C 
    ##   0.85   0.42   0.91

Identify genes meeting a **demonstration threshold**:

``` r
pp <- vapply(gene_results, function(x) x$pp_h4, numeric(1))
names(pp)[pp >= 0.80]
```

    ## [1] "Gene_A" "Gene_C"

The threshold is a teaching example; interpretation of posterior
probabilities requires attention to model assumptions, priors, locus
definition, and data quality.

## 8.34 Data frames are specialized lists: a preview

We will study data frames in Chapter 9. For now, observe that a data
frame is a list of equal-length columns:

``` r
participants_df <- data.frame(
  id = c("P001", "P002", "P003"),
  age = c(42, 51, 37),
  glucose = c(95, 105, 100)
)

is.list(participants_df)
```

    ## [1] TRUE

``` r
class(participants_df)
```

    ## [1] "data.frame"

``` r
length(participants_df)
```

    ## [1] 3

Here, `length(participants_df)` gives the number of columns, not the
number of rows.

``` r
nrow(participants_df)
```

    ## [1] 3

``` r
ncol(participants_df)
```

    ## [1] 3

This is one reason lists are fundamental to understanding R data
structures.

## 8.35 Converting a suitable list to a data frame

A list whose elements are equal-length vectors can often be converted:

``` r
table_like <- list(
  id = c("P001", "P002", "P003"),
  age = c(42, 51, 37),
  glucose = c(95, 105, 100)
)

df <- as.data.frame(table_like)
df
```

    ##     id age glucose
    ## 1 P001  42      95
    ## 2 P002  51     105
    ## 3 P003  37     100

But a heterogeneous list of different-length objects may not form a
valid rectangular table.

``` r
# This example intentionally demonstrates an incompatible structure.
# Do not execute while knitting.
not_rectangular <- list(
  ids = c("P001", "P002", "P003"),
  ages = c(42, 51)
)
as.data.frame(not_rectangular)
```

We should not force irregular scientific data into a rectangular table
without deciding how missing or unmatched observations should be
represented.

## 8.36 Saving and loading a list

Lists can be saved as R objects for reproducible work:

``` r
# Run in an appropriate project folder.
saveRDS(analysis, file = "analysis_result.rds")
restored <- readRDS("analysis_result.rds")
str(restored)
```

`saveRDS()` preserves R object structure, including nested lists. We
will cover file paths and saving intermediate results in depth in
Chapters 14–19.

## 8.37 Common mistakes

### Mistake 1: confusing `[ ]` and `[[ ]]`

``` r
patient["sbp"]
```

    ## $sbp
    ## [1] 110 118 117

``` r
patient[["sbp"]]
```

    ## [1] 110 118 117

The first returns a list; the second returns the vector.

### Mistake 2: expecting `length()` to count values inside every element

``` r
length(patient)
```

    ## [1] 7

``` r
length(patient$sbp)
```

    ## [1] 3

The first counts top-level elements; the second counts measurements.

### Mistake 3: assuming all elements share one type

Lists can contain numeric vectors, character values, matrices, and
nested lists without coercion.

### Mistake 4: using `$` with a variable holding a name

``` r
field <- "age"
patient[[field]]
```

    ## [1] 46

This retrieves the `age` element. `patient$field` would instead seek an
element named `field`.

### Mistake 5: accidentally removing an element by assigning `NULL`

``` r
temp <- list(a = 1, b = 2)
temp$b <- NULL
temp
```

    ## $a
    ## [1] 1

This removes `b`.

### Mistake 6: relying on partial matching

For programmatic access, prefer exact `[["name", exact = TRUE]]` and
check names explicitly.

### Mistake 7: assuming equal vector lengths prove correct alignment

Equal lengths do not ensure that measurements correspond to the same
participants, genes, or variants.

### Mistake 8: flattening a heterogeneous list without checking coercion

`unlist()` can convert numeric and logical elements to character when a
character element is present.

### Mistake 9: expecting `sapply()` always to return the same structure

Its simplification behavior depends on the outputs. Use `lapply()` or
`vapply()` when predictability is important.

### Mistake 10: confusing missing values and missing list elements

`NA`, `NULL`, and an absent name represent different situations.

------------------------------------------------------------------------

## 8.38 Guided practical: build a research participant record

We will build one participant record and perform basic checks.

**Step 1 — Create the record**

``` r
record <- list(
  id = "P020",
  age = 54,
  visits = c("V1", "V2", "V3"),
  glucose = c(110, 105, NA_real_),
  sbp = c(145, 138, 135),
  consent = TRUE
)
```

**Step 2 — Inspect the structure**

``` r
str(record)
```

    ## List of 6
    ##  $ id     : chr "P020"
    ##  $ age    : num 54
    ##  $ visits : chr [1:3] "V1" "V2" "V3"
    ##  $ glucose: num [1:3] 110 105 NA
    ##  $ sbp    : num [1:3] 145 138 135
    ##  $ consent: logi TRUE

``` r
names(record)
```

    ## [1] "id"      "age"     "visits"  "glucose" "sbp"     "consent"

``` r
length(record)
```

    ## [1] 6

**Step 3 — Extract a single measurement**

``` r
record$sbp[2]
```

    ## [1] 138

**Step 4 — Count missing glucose values**

``` r
sum(is.na(record$glucose))
```

    ## [1] 1

**Step 5 — Calculate observed glucose mean**

``` r
mean(record$glucose, na.rm = TRUE)
```

    ## [1] 107.5

**Step 6 — Calculate change in SBP**

``` r
record$sbp[3] - record$sbp[1]
```

    ## [1] -10

**Step 7 — Add a nested summary**

``` r
record$summary <- list(
  mean_glucose = mean(record$glucose, na.rm = TRUE),
  sbp_change = record$sbp[3] - record$sbp[1],
  glucose_missing_n = sum(is.na(record$glucose))
)
record$summary
```

    ## $mean_glucose
    ## [1] 107.5
    ## 
    ## $sbp_change
    ## [1] -10
    ## 
    ## $glucose_missing_n
    ## [1] 1

**Step 8 — Validate visit alignment**

``` r
stopifnot(length(record$visits) == length(record$glucose))
stopifnot(length(record$visits) == length(record$sbp))
```

**Step 9 — Retrieve one summary value**

``` r
record$summary$sbp_change
```

    ## [1] -10

------------------------------------------------------------------------

## 8.39 Guided practical: package a small genomic analysis

**Step 1 — Create synthetic summary statistics**

``` r
variant_id <- c("rs1001", "rs1002", "rs1003")
beta <- c(0.05, -0.02, 0.08)
se <- c(0.01, 0.02, 0.025)
```

**Step 2 — Store inputs in a list**

``` r
gwas <- list(
  metadata = list(
    trait = "Synthetic GWAS example",
    build = "GRCh38"
  ),
  variants = variant_id,
  beta = beta,
  se = se
)
```

**Step 3 — Validate vector lengths**

``` r
stopifnot(length(gwas$variants) == length(gwas$beta))
stopifnot(length(gwas$variants) == length(gwas$se))
```

**Step 4 — Calculate z statistics**

``` r
gwas$z <- gwas$beta / gwas$se
gwas$z
```

    ## [1]  5.0 -1.0  3.2

**Step 5 — Calculate two-sided normal-approximation p-values**

``` r
gwas$pvalue <- 2 * pnorm(-abs(gwas$z))
gwas$pvalue
```

    ## [1] 5.733031e-07 3.173105e-01 1.374276e-03

The formula is a demonstration of organizing calculations in a list;
actual GWAS inference requires appropriate statistical models and QC.

**Step 6 — Add a QC summary**

``` r
gwas$qc <- list(
  n_variants = length(gwas$variants),
  missing_beta = sum(is.na(gwas$beta)),
  missing_se = sum(is.na(gwas$se)),
  all_se_positive = all(gwas$se > 0)
)
str(gwas)
```

    ## List of 7
    ##  $ metadata:List of 2
    ##   ..$ trait: chr "Synthetic GWAS example"
    ##   ..$ build: chr "GRCh38"
    ##  $ variants: chr [1:3] "rs1001" "rs1002" "rs1003"
    ##  $ beta    : num [1:3] 0.05 -0.02 0.08
    ##  $ se      : num [1:3] 0.01 0.02 0.025
    ##  $ z       : num [1:3] 5 -1 3.2
    ##  $ pvalue  : num [1:3] 5.73e-07 3.17e-01 1.37e-03
    ##  $ qc      :List of 4
    ##   ..$ n_variants     : int 3
    ##   ..$ missing_beta   : int 0
    ##   ..$ missing_se     : int 0
    ##   ..$ all_se_positive: logi TRUE

**Step 7 — Extract one variant’s results**

``` r
i <- match("rs1002", gwas$variants)
c(beta = gwas$beta[i], se = gwas$se[i], z = gwas$z[i])
```

    ##  beta    se     z 
    ## -0.02  0.02 -1.00

------------------------------------------------------------------------

## 8.40 Independent exercises

Create this list:

``` r
exercise_patient <- list(
  id = "P101",
  age = 39,
  glucose = c(98, 105, 101),
  sbp = c(125, 130, 128),
  consent = TRUE
)
```

Complete the following tasks without looking at the solutions:

1.  Print the list and inspect its structure.
2.  Determine the number of top-level elements.
3.  Display all element names.
4.  Retrieve the participant identifier using `$`.
5.  Retrieve the participant identifier using `[[ ]]`.
6.  Retrieve the `glucose` element as a **one-element list**.
7.  Retrieve the `glucose` element as a **numeric vector**.
8.  Extract the second glucose measurement.
9.  Calculate mean glucose.
10. Calculate the change in SBP between the first and third visits.
11. Add `weight_kg = 70` and `height_m = 1.68`.
12. Calculate BMI and store it as a new list element.
13. Create a nested `summary` element containing mean glucose and BMI.
14. Extract BMI from the nested summary.
15. Add a new element called `site` with value `"Site_B"`.
16. Remove the `site` element.
17. Explain what would happen if we assigned `NULL` to `consent`.
18. Explain why `exercise_patient["glucose"]` and
    `exercise_patient[["glucose"]]` have different classes.

## 8.41 Challenge: participants with different numbers of visits

``` r
followup <- list(
  P001 = c(120, 125, 122),
  P002 = c(138, 134),
  P003 = c(110, 115, 112, 111),
  P004 = c(145)
)
```

Tasks:

1.  Determine the number of participants.
2.  Calculate the number of visits for each participant.
3.  Extract all observations for P003.
4.  Calculate mean SBP for each participant using `lapply()`.
5.  Repeat using `vapply()` with an explicit numeric output.
6.  Identify the participant with the highest observed mean SBP.
7.  Explain why a matrix is less convenient for these unequal-length
    vectors without introducing padding or another representation.
8.  Introduce an `NA` in P002’s second measurement and recalculate means
    using `na.rm = TRUE`.
9.  Count missing values per participant.
10. Explain why mean SBP is descriptive and does not by itself establish
    hypertension diagnosis or treatment response.

## 8.42 Challenge: nested gene results

``` r
results_by_gene <- list(
  Gene_A = list(n_variants = 120L, pp_h4 = 0.88),
  Gene_B = list(n_variants = 95L, pp_h4 = 0.35),
  Gene_C = list(n_variants = 210L, pp_h4 = 0.92),
  Gene_D = list(n_variants = 65L, pp_h4 = 0.77)
)
```

Tasks:

1.  Print the names of all genes.
2.  Extract the entire result for Gene_C.
3.  Extract only the H4 posterior probability for Gene_A.
4.  Use `vapply()` to obtain a named numeric vector of all H4 posterior
    probabilities.
5.  Identify genes with `pp_h4 >= 0.80` for this teaching example.
6.  Use `vapply()` to obtain the number of variants per gene.
7.  Calculate the total number of variants across gene-specific results
    (not necessarily unique variants).
8.  Add a new gene result with a different posterior probability.
9.  Remove Gene_B from a copy of the list without changing the original.
10. Explain why a list of per-gene results can be more flexible than a
    single matrix when different genes produce different types of
    diagnostics.

------------------------------------------------------------------------

## 8.43 Complete Chapter 8 practice script

The following standalone script brings together the chapter’s essential
techniques. It is not executed during knitting because its components
have already been demonstrated.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 8 — Lists
# ============================================================

# Create a named list
patient <- list(
  id = "P001",
  age = 45,
  sbp = c(110, 118, 115),
  consent = TRUE
)

# Inspect structure
str(patient)
names(patient)
length(patient)

# Compare extraction operators
patient["sbp"]
patient[["sbp"]]
patient$sbp
patient$sbp[2]

# Add a derived value
patient$weight_kg <- 76
patient$height_m <- 1.74
patient$bmi <- patient$weight_kg / patient$height_m^2

# Add nested summary
patient$summary <- list(
  mean_sbp = mean(patient$sbp),
  bmi = patient$bmi
)
patient$summary$mean_sbp

# Handle missingness
measurements <- list(
  glucose = c(95, NA, 105),
  cholesterol = c(175, 180, NA)
)
lapply(measurements, mean, na.rm = TRUE)
vapply(measurements, function(x) sum(is.na(x)), numeric(1))

# Irregular follow-up lengths
followup <- list(
  P001 = c(120, 125, 122),
  P002 = c(138, 134),
  P003 = c(110, 115, 112, 111)
)
vapply(followup, mean, numeric(1))

# Store a matrix and its metadata
m <- matrix(
  c(0, 1, 2, 1, 0, 1),
  nrow = 2,
  byrow = TRUE,
  dimnames = list(c("P001", "P002"), c("rs1", "rs2", "rs3"))
)
analysis <- list(
  dosage = m,
  build = "GRCh38",
  qc = list(passed = TRUE, missing = sum(is.na(m)))
)
analysis$dosage[, "rs2", drop = FALSE]
analysis$qc$passed

# Extract a nested element exactly
analysis[[c("qc", "missing")]]

# Check names and alignment
stopifnot(!anyDuplicated(colnames(analysis$dosage)))
stopifnot(nrow(analysis$dosage) == 2)

# Save a complete R object (run in a suitable project folder)
# saveRDS(analysis, "analysis.rds")
# restored <- readRDS("analysis.rds")
```

## 8.44 Essential list functions and operators

| Task | R syntax | Notes |
|----|----|----|
| Create list | `list(...)` | Can contain mixed types |
| Inspect structure | `str(x)` | Highly recommended |
| Count top-level elements | `length(x)` | Does not count nested values |
| Get element names | `names(x)` | May be `NULL` |
| Check list type | `is.list(x)` | Returns logical |
| Extract sublist | `x["name"]` | Returns a list |
| Extract element | `x[["name"]]` | Returns stored object |
| Extract named element | `x$name` | Convenient interactive syntax |
| Exact dynamic extraction | `x[[field, exact = TRUE]]` | Uses a name stored in a variable |
| Extract nested element | `x[[c("a", "b")]]` | Name path |
| Add or replace element | `x$name <- value` | Changes list |
| Remove element | `x$name <- NULL` | Removes name and value |
| Keep NULL-valued element | `x["name"] <- list(NULL)` | Preserves position |
| Combine lists | `c(x, y)` | Can create duplicate names |
| Append element | `append(x, list(value))` | Returns new list |
| Flatten list | `unlist(x)` | Can coerce types |
| Apply to elements | `lapply(x, FUN)` | Always returns list |
| Simplify applied result | `sapply(x, FUN)` | Output type can vary |
| Require output type | `vapply(x, FUN, FUN.VALUE)` | More predictable |
| Convert suitable list | `as.data.frame(x)` | Requires compatible structure |
| Save R object | `saveRDS(x, "file.rds")` | Preserve nested structure |

## 8.45 Review questions

1.  What problem does a list solve that an atomic vector cannot?
2.  Can a list contain a matrix, an array, and another list at the same
    time?
3.  What does `length()` count for a list?
4.  What is the difference between `x[1]` and `x[[1]]`?
5.  When is `$` convenient, and when is `[[ ]]` preferable?
6.  How do we extract the third observation in a vector stored inside a
    list?
7.  What happens when we assign `NULL` using `$`?
8.  How can we preserve a named element whose value is `NULL`?
9.  How do `NA`, `NULL`, and an absent element differ?
10. What is a nested list?
11. Why should we avoid relying on partial matching?
12. Why can `unlist()` cause type coercion?
13. What is the difference between `lapply()` and `sapply()`?
14. What additional guarantee does `vapply()` provide?
15. Why are lists useful for statistical model results?
16. Why are lists useful for storing genomic matrices with metadata?
17. Why are equal-length vectors not necessarily aligned correctly?
18. What makes a data frame a special kind of list?
19. Why are lists suitable for unequal numbers of follow-up visits?
20. What checks would we make before interpreting a nested research
    result?

## 8.46 Key takeaways

- Lists hold multiple R objects without forcing a common atomic type.
- Each list element can be a vector, matrix, array, function, or another
  list.
- `[ ]` returns a list; `[[ ]]` extracts an element; `$` accesses a
  named element.
- `length()` counts top-level elements, not all values nested inside
  them.
- Nested lists are useful for organizing metadata, measurements, QC, and
  analysis outputs.
- `NA`, `NULL`, and absent elements must not be confused.
- Exact name matching and identifier validation reduce avoidable
  research errors.
- `lapply()` returns a list; `vapply()` can enforce a predictable output
  type.
- Lists are useful for irregular data and complex analysis results.
- Data frames are a specialized list structure that we will study next.

> **Before extracting or modifying a list element, we should know
> whether we need the containing sublist or the object stored inside
> it.**

## 8.47 Looking ahead: Chapter 9 — Data Frames

Lists are flexible, but most epidemiological and clinical datasets are
organized as rectangular tables with participants in rows and variables
in columns. Those columns can have different data types while still
representing a consistent set of observations.

In **Chapter 9 — Data Frames: The Main Structure for Biomedical Data**,
we will learn to create, inspect, subset, clean, and modify these tables
in base R. We will also explain why a data frame behaves differently
from a matrix, despite appearing similar when printed.
