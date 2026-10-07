Factors and Categorical Variables
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

# Factors and Categorical Variables

In Chapter 4, we learned that vectors are one-dimensional collections of
values. A character vector can easily store labels such as:

``` r
disease_status <- c(
  "Control",
  "Case",
  "Case",
  "Control",
  "Case"
)

disease_status
```

    ## [1] "Control" "Case"    "Case"    "Control" "Case"

This representation preserves the labels, but biomedical variables such
as disease status, treatment group, smoking category, genotype class,
and disease severity are not merely text. They represent **categories**.

R provides a dedicated data structure for categorical variables: the
**factor**.

Factors become especially important when we later perform statistical
analyses. In regression, ANOVA, contingency-table analysis, and many
other methods, R needs to know that a variable represents categories
rather than ordinary text or continuous numbers.

A central principle for this chapter is:

> **A factor represents a categorical variable by storing a defined set
> of possible levels and associating observations with those levels.**

------------------------------------------------------------------------

## 5.1 Learning objectives

By the end of this chapter, we should be able to:

- explain categorical variables;
- distinguish nominal, binary, and ordinal categories;
- explain why numeric codes are not automatically numeric measurements;
- distinguish character vectors from factors;
- create factors using `factor()`;
- inspect factor levels;
- understand the internal integer coding of factors;
- specify the order of factor levels;
- change reference levels using `relevel()`;
- distinguish unordered from ordered factors;
- create ordered factors;
- identify and handle missing categorical observations;
- use `table()` and `prop.table()` to audit categories;
- detect unexpected category labels;
- recode categories safely;
- collapse categories when scientifically justified;
- understand unused factor levels and `droplevels()`;
- avoid dangerous factor-to-numeric conversions;
- prepare categorical variables for later statistical modeling;
- apply factor concepts to biomedical, epidemiological, and genomic
  examples.

------------------------------------------------------------------------

# 5.2 What is a categorical variable?

A categorical variable assigns observations to groups or categories.

Examples include:

``` text
Disease status:
Control
Case

Sex:
Female
Male

Smoking status:
Never
Former
Current

Treatment group:
Placebo
Drug A
Drug B

Disease severity:
Mild
Moderate
Severe

Genotype:
AA
AG
GG
```

These values describe **membership in categories** rather than a
directly measured numerical quantity.

------------------------------------------------------------------------

# 5.3 Numerical versus categorical information

Consider:

``` text
Age = 52 years
```

The value 52 has a quantitative interpretation.

Differences are meaningful:

$$52 - 42 = 10 \text{ years}$$

Now consider:

``` text
Disease status:
0 = Control
1 = Case
```

Although the categories are coded using numbers, the difference:

$$1 - 0 = 1$$

does not represent a meaningful quantitative difference in disease
amount.

The values `0` and `1` are **codes**.

This gives us an important principle:

> **The appearance of numbers does not determine the scientific type of
> a variable.**

------------------------------------------------------------------------

# 5.4 Main kinds of categorical variables

Categorical variables can be classified according to their scientific
structure.

Three especially important types are:

``` text
Binary
Nominal
Ordinal
```

------------------------------------------------------------------------

# 5.5 Binary categorical variables

A binary variable has two categories.

Examples:

``` text
Disease:
Case
Control

Smoking:
Yes
No

Treatment:
Drug
Placebo

Mutation:
Present
Absent
```

In R, binary data might initially appear as:

``` r
disease <- c(
  "Case",
  "Control",
  "Case",
  "Case",
  "Control"
)
```

or as logical values:

``` r
disease_present <- c(
  TRUE,
  FALSE,
  TRUE,
  TRUE,
  FALSE
)
```

or as numeric codes:

``` r
disease_code <- c(
  1,
  0,
  1,
  1,
  0
)
```

These representations may describe the same scientific concept, but R
treats them differently.

------------------------------------------------------------------------

# 5.6 Nominal categorical variables

A nominal variable has categories with **no inherent ranking**.

Examples:

``` text
Blood group:
A
B
AB
O

Study centre:
Lucknow
Delhi
Mumbai

Genotype:
AA
AG
GG

Treatment:
Placebo
Drug A
Drug B
```

There is no natural statement such as:

``` text
Blood group A < Blood group B
```

The categories are labels rather than ordered measurements.

------------------------------------------------------------------------

# 5.7 Ordinal categorical variables

An ordinal variable has categories with a meaningful order.

Examples:

``` text
Disease severity:
Mild
Moderate
Severe

Pain:
None
Mild
Moderate
Severe

Tumour stage:
Stage I
Stage II
Stage III
Stage IV

Response:
Poor
Fair
Good
Excellent
```

The order matters.

However, the distance between categories is not necessarily equal.

For example:

``` text
Mild → Moderate
```

does not necessarily represent the same quantitative change as:

``` text
Moderate → Severe
```

Therefore, ordinal categories should not automatically be treated as
continuous measurements.

------------------------------------------------------------------------

# 5.8 Character vectors can store categories

Suppose:

``` r
smoking <- c(
  "Never",
  "Former",
  "Current",
  "Never",
  "Current"
)
```

Inspect:

``` r
class(smoking)
```

    ## [1] "character"

``` r
typeof(smoking)
```

    ## [1] "character"

This is a character vector.

R knows that the elements are text, but it does not yet formally
represent the set of categories as factor levels.

------------------------------------------------------------------------

# 5.9 Creating a factor

Use:

``` r
smoking_factor <- factor(smoking)

smoking_factor
```

    ## [1] Never   Former  Current Never   Current
    ## Levels: Current Former Never

Inspect:

``` r
class(smoking_factor)
```

    ## [1] "factor"

The result is:

``` text
"factor"
```

Inspect levels:

``` r
levels(smoking_factor)
```

    ## [1] "Current" "Former"  "Never"

R now knows the possible categories.

------------------------------------------------------------------------

# 5.10 Character vector versus factor

Compare:

``` r
smoking_character <- c(
  "Never",
  "Former",
  "Current",
  "Never"
)

smoking_factor <- factor(
  smoking_character
)
```

Inspect:

``` r
class(smoking_character)
```

    ## [1] "character"

``` r
class(smoking_factor)
```

    ## [1] "factor"

The first is:

``` text
"character"
```

The second is:

``` text
"factor"
```

Although the displayed labels may look similar, the objects have
different structures and purposes.

------------------------------------------------------------------------

# 5.11 Inspecting a factor with `str()`

``` r
str(smoking_factor)
```

    ##  Factor w/ 3 levels "Current","Former",..: 3 2 1 3

R may display something conceptually similar to:

``` text
Factor w/ 3 levels "Current","Former",..: ...
```

This tells us:

- the object is a factor;
- it has three levels;
- observations are internally represented using level codes.

------------------------------------------------------------------------

# 5.12 Factors use internal integer codes

Consider:

``` r
disease <- factor(
  c(
    "Control",
    "Case",
    "Case",
    "Control"
  )
)

disease
```

    ## [1] Control Case    Case    Control
    ## Levels: Case Control

Inspect:

``` r
levels(disease)
```

    ## [1] "Case"    "Control"

Suppose the levels are:

``` text
"Case"
"Control"
```

Internally, R stores integer codes corresponding to those levels.

We can inspect:

``` r
unclass(disease)
```

    ## [1] 2 1 1 2
    ## attr(,"levels")
    ## [1] "Case"    "Control"

The important point is:

> The integers inside a factor are internal category codes. They are not
> the scientific values themselves.

------------------------------------------------------------------------

# 5.13 Why factor internals matter

Suppose:

``` r
severity <- factor(
  c(
    "Mild",
    "Moderate",
    "Severe"
  )
)
```

If the internal codes happen to be:

``` text
1 2 3
```

that does **not** mean we should automatically perform arithmetic such
as:

``` text
3 - 1 = 2 units of severity
```

The codes identify levels.

They do not create a quantitative measurement scale.

------------------------------------------------------------------------

# 5.14 Default level ordering

When we create:

``` r
smoking <- factor(
  c(
    "Never",
    "Former",
    "Current",
    "Never"
  )
)

levels(smoking)
```

    ## [1] "Current" "Former"  "Never"

R commonly arranges character levels alphabetically:

``` text
"Current"
"Former"
"Never"
```

That order may not match the scientific order or the desired reference
category.

Therefore, we should inspect levels rather than assume them.

------------------------------------------------------------------------

# 5.15 Specifying levels explicitly

We can define the level order ourselves:

``` r
smoking <- factor(
  c(
    "Never",
    "Former",
    "Current",
    "Never"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

levels(smoking)
```

    ## [1] "Never"   "Former"  "Current"

Now the levels appear in the specified order.

------------------------------------------------------------------------

# 5.16 Why explicit levels improve research code

Explicit levels help us:

- document expected categories;
- control display order;
- detect unexpected values;
- define reference categories;
- create ordered factors;
- make analyses more reproducible.

Instead of relying on alphabetical defaults, the scientific structure
becomes part of the code.

------------------------------------------------------------------------

# 5.17 Unexpected labels become `NA` when levels are restricted

Consider:

``` r
smoking_raw <- c(
  "Never",
  "Former",
  "Current",
  "Unknown"
)
```

Now define only expected levels:

``` r
smoking <- factor(
  smoking_raw,
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

smoking
```

    ## [1] Never   Former  Current <NA>   
    ## Levels: Never Former Current

`"Unknown"` becomes `NA` because it is not one of the declared levels.

This can be useful for detecting invalid coding, but it also means we
must inspect the result carefully.

------------------------------------------------------------------------

# 5.18 We should audit before converting

A safer workflow is:

``` r
smoking_raw <- c(
  "Never",
  "Former",
  "Current",
  "Unknown"
)

unique(smoking_raw)
```

    ## [1] "Never"   "Former"  "Current" "Unknown"

Then inspect frequency:

``` r
table(
  smoking_raw,
  useNA = "ifany"
)
```

    ## smoking_raw
    ## Current  Former   Never Unknown 
    ##       1       1       1       1

Only after understanding the raw categories should we define the factor.

This avoids silently converting unexpected labels into missing values
without investigation.

------------------------------------------------------------------------

# 5.19 Frequency tables with `table()`

Suppose:

``` r
disease <- factor(
  c(
    "Control",
    "Case",
    "Case",
    "Control",
    "Case",
    "Control"
  ),
  levels = c(
    "Control",
    "Case"
  )
)
```

Count categories:

``` r
table(disease)
```

    ## disease
    ## Control    Case 
    ##       3       3

This is one of the simplest ways to audit categorical data.

------------------------------------------------------------------------

# 5.20 Proportions with `prop.table()`

``` r
disease_table <- table(disease)

prop.table(disease_table)
```

    ## disease
    ## Control    Case 
    ##     0.5     0.5

This converts counts into proportions.

For percentages:

``` r
100 * prop.table(disease_table)
```

    ## disease
    ## Control    Case 
    ##      50      50

Later chapters will cover frequency tables in greater depth.

------------------------------------------------------------------------

# 5.21 Missing categories

Suppose:

``` r
smoking <- factor(
  c(
    "Never",
    "Current",
    NA,
    "Former",
    "Never"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)
```

Inspect:

``` r
smoking
```

    ## [1] Never   Current <NA>    Former  Never  
    ## Levels: Never Former Current

Identify missing values:

``` r
is.na(smoking)
```

    ## [1] FALSE FALSE  TRUE FALSE FALSE

Count:

``` r
sum(is.na(smoking))
```

    ## [1] 1

------------------------------------------------------------------------

# 5.22 Including missing values in a frequency table

By default:

``` r
table(smoking)
```

    ## smoking
    ##   Never  Former Current 
    ##       2       1       1

does not display missing observations.

Use:

``` r
table(
  smoking,
  useNA = "ifany"
)
```

    ## smoking
    ##   Never  Former Current    <NA> 
    ##       2       1       1       1

Now `NA` is included if present.

For data auditing, this is often preferable.

------------------------------------------------------------------------

# 5.23 Missing category versus a category called `"Unknown"`

These are not automatically the same.

Consider:

``` r
x <- c(
  "Never",
  "Current",
  "Unknown",
  NA
)
```

Here:

``` text
"Unknown"
```

is a recorded category label.

`NA` means the value is missing.

Scientifically, `"Unknown"` might mean:

- the participant did not know;
- the investigator could not determine status;
- a questionnaire contained an explicit “Unknown” option.

By contrast, `NA` may mean no value was recorded.

We should not merge these concepts without understanding the study
design.

------------------------------------------------------------------------

# 5.24 Reference categories

Reference categories become important in statistical modeling.

Suppose:

``` r
disease <- factor(
  c(
    "Control",
    "Case",
    "Case",
    "Control"
  ),
  levels = c(
    "Control",
    "Case"
  )
)

levels(disease)
```

    ## [1] "Control" "Case"

The first level is:

``` text
Control
```

For many R modeling functions, the first factor level is used as the
reference category under the default treatment contrasts.

This means level order can affect model interpretation.

------------------------------------------------------------------------

# 5.25 Choosing a reference level deliberately

For a case-control variable, we may want:

``` text
Control
```

as the reference.

We can define it explicitly:

``` r
disease <- factor(
  disease,
  levels = c(
    "Control",
    "Case"
  )
)
```

Or use:

``` r
disease <- relevel(
  disease,
  ref = "Control"
)
```

Check:

``` r
levels(disease)
```

    ## [1] "Control" "Case"

------------------------------------------------------------------------

# 5.26 Why reference level matters

Suppose a future regression model compares:

``` text
Case versus Control
```

If `Control` is the reference, the coefficient for `Case` will be
interpreted relative to controls.

If the reference changes, the numerical parameterization and
interpretation also change.

We will study this carefully during regression chapters.

For now, the key rule is:

> **Reference levels should be chosen deliberately and documented.**

------------------------------------------------------------------------

# 5.27 Binary factor example

``` r
hypertension <- factor(
  c(
    "No",
    "Yes",
    "No",
    "Yes",
    "Yes"
  ),
  levels = c(
    "No",
    "Yes"
  )
)

hypertension
```

    ## [1] No  Yes No  Yes Yes
    ## Levels: No Yes

``` r
levels(hypertension)
```

    ## [1] "No"  "Yes"

``` r
table(hypertension)
```

    ## hypertension
    ##  No Yes 
    ##   2   3

This clearly communicates:

``` text
Reference/first level: No
Comparison level:      Yes
```

------------------------------------------------------------------------

# 5.28 Nominal factor example

Blood group has no natural order:

``` r
blood_group <- factor(
  c(
    "A",
    "O",
    "B",
    "AB",
    "O",
    "A"
  ),
  levels = c(
    "O",
    "A",
    "B",
    "AB"
  )
)

blood_group
```

    ## [1] A  O  B  AB O  A 
    ## Levels: O A B AB

Although we supplied an order to the level labels, this factor is still
**unordered** unless we explicitly make it ordered.

Check:

``` r
is.ordered(blood_group)
```

    ## [1] FALSE

Result:

``` text
FALSE
```

------------------------------------------------------------------------

# 5.29 Ordered factors

For an ordinal variable such as disease severity:

``` text
Mild < Moderate < Severe
```

we can create an ordered factor:

``` r
severity <- factor(
  c(
    "Moderate",
    "Mild",
    "Severe",
    "Moderate",
    "Mild"
  ),
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  ),
  ordered = TRUE
)

severity
```

    ## [1] Moderate Mild     Severe   Moderate Mild    
    ## Levels: Mild < Moderate < Severe

Check:

``` r
is.ordered(severity)
```

    ## [1] TRUE

Result:

``` text
TRUE
```

------------------------------------------------------------------------

# 5.30 Comparing ordered factor levels

Because the factor is ordered:

``` r
severity[1] > severity[2]
```

    ## [1] TRUE

R can interpret:

``` text
Moderate > Mild
```

according to the specified level ordering.

This comparison would not have the same meaning for an unordered nominal
factor.

------------------------------------------------------------------------

# 5.31 Creating an ordered factor with `ordered()`

An alternative is:

``` r
severity <- ordered(
  c(
    "Moderate",
    "Mild",
    "Severe",
    "Moderate"
  ),
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  )
)

severity
```

    ## [1] Moderate Mild     Severe   Moderate
    ## Levels: Mild < Moderate < Severe

Both approaches can create ordered categorical variables.

------------------------------------------------------------------------

# 5.32 Order must come from scientific meaning

Suppose:

``` text
Mild
Moderate
Severe
```

The scientific order is clear.

But for:

``` text
A
B
AB
O
```

there is no inherent clinical ordering.

We should not create an ordered factor merely because R allows it.

The variable’s scientific meaning determines whether ordering is
appropriate.

------------------------------------------------------------------------

# 5.33 Numeric category codes

Suppose a dataset uses:

``` text
1 = Never smoker
2 = Former smoker
3 = Current smoker
```

Raw values might be:

``` r
smoking_code <- c(
  1,
  3,
  2,
  1,
  3
)

class(smoking_code)
```

    ## [1] "numeric"

R sees a numeric vector.

Scientifically, however, these are category codes.

We can convert them deliberately:

``` r
smoking <- factor(
  smoking_code,
  levels = c(
    1,
    2,
    3
  ),
  labels = c(
    "Never",
    "Former",
    "Current"
  )
)

smoking
```

    ## [1] Never   Current Former  Never   Current
    ## Levels: Never Former Current

------------------------------------------------------------------------

# 5.34 Using `labels` in `factor()`

The structure:

``` r
factor(
  x,
  levels = ...,
  labels = ...
)
```

allows raw codes to be mapped to meaningful labels.

For example:

``` r
disease_code <- c(
  0,
  1,
  1,
  0,
  1
)

disease <- factor(
  disease_code,
  levels = c(
    0,
    1
  ),
  labels = c(
    "Control",
    "Case"
  )
)

disease
```

    ## [1] Control Case    Case    Control Case   
    ## Levels: Control Case

This is clearer than leaving disease status as unexplained `0` and `1`
values.

------------------------------------------------------------------------

# 5.35 Labels must correspond to levels

If we specify:

``` text
levels: 0, 1
labels: Control, Case
```

then:

``` text
0 → Control
1 → Case
```

The mapping must follow the study codebook.

We should never guess what numerical codes mean.

------------------------------------------------------------------------

# 5.36 Dangerous factor-to-numeric conversion

This is one of the most important factor pitfalls.

Suppose:

``` r
x <- factor(
  c(
    "10",
    "20",
    "30"
  )
)

x
```

    ## [1] 10 20 30
    ## Levels: 10 20 30

If we run:

``` r
as.numeric(x)
```

    ## [1] 1 2 3

we do **not** necessarily get:

``` text
10 20 30
```

Instead, R returns the factor’s internal integer codes.

------------------------------------------------------------------------

# 5.37 Safe conversion of numeric-looking factor labels

If a factor genuinely contains numerical labels that should become
numerical measurements, a common safe conversion is:

``` r
as.numeric(
  as.character(x)
)
```

    ## [1] 10 20 30

Check:

``` r
x_character <- as.character(x)
x_numeric <- as.numeric(x_character)

x_character
```

    ## [1] "10" "20" "30"

``` r
x_numeric
```

    ## [1] 10 20 30

The logic is:

``` text
factor
  ↓
character labels
  ↓
numeric values
```

However, conversion should only occur when the categories truly
represent numerical measurements.

------------------------------------------------------------------------

# 5.38 Why direct `as.numeric(factor)` is dangerous

Consider:

``` r
glucose_factor <- factor(
  c(
    "95",
    "105",
    "126"
  )
)
```

The factor levels might internally correspond to:

``` text
1, 2, 3
```

Therefore:

``` r
as.numeric(glucose_factor)
```

    ## [1] 3 1 2

returns internal codes, not glucose values.

This can silently corrupt an analysis.

A critical rule is:

> **Never assume `as.numeric()` applied directly to a factor returns the
> displayed numbers.**

------------------------------------------------------------------------

# 5.39 Converting a factor to character

This is straightforward:

``` r
disease <- factor(
  c(
    "Control",
    "Case",
    "Case"
  )
)

disease_character <- as.character(disease)

disease_character
```

    ## [1] "Control" "Case"    "Case"

``` r
class(disease_character)
```

    ## [1] "character"

The displayed category labels are preserved.

------------------------------------------------------------------------

# 5.40 Recoding categorical values

Real datasets often contain inconsistent labels.

Suppose:

``` r
sex_raw <- c(
  "Male",
  "Female",
  "F",
  "M",
  "Female",
  "Male"
)
```

First inspect:

``` r
unique(sex_raw)
```

    ## [1] "Male"   "Female" "F"      "M"

``` r
table(sex_raw)
```

    ## sex_raw
    ##      F Female      M   Male 
    ##      1      2      1      2

We should understand the coding before recoding.

If the codebook confirms:

``` text
M = Male
F = Female
```

we can standardize:

``` r
sex_clean <- sex_raw

sex_clean[
  sex_clean == "M"
] <- "Male"

sex_clean[
  sex_clean == "F"
] <- "Female"

sex_clean
```

    ## [1] "Male"   "Female" "Female" "Male"   "Female" "Male"

Then create the factor:

``` r
sex_factor <- factor(
  sex_clean,
  levels = c(
    "Female",
    "Male"
  )
)

sex_factor
```

    ## [1] Male   Female Female Male   Female Male  
    ## Levels: Female Male

------------------------------------------------------------------------

# 5.41 Recoding with logical indexing

The pattern:

``` r
x[x == old_value] <- new_value
```

is useful for simple recoding.

For example:

``` r
smoking <- c(
  "Never",
  "Ex",
  "Current",
  "Ex"
)

smoking[
  smoking == "Ex"
] <- "Former"

smoking
```

    ## [1] "Never"   "Former"  "Current" "Former"

We should always verify the result:

``` r
unique(smoking)
```

    ## [1] "Never"   "Former"  "Current"

``` r
table(smoking)
```

    ## smoking
    ## Current  Former   Never 
    ##       1       2       1

------------------------------------------------------------------------

# 5.42 Multiple inconsistent labels

Suppose:

``` r
disease_raw <- c(
  "Control",
  "control",
  "CASE",
  "Case",
  "Case"
)
```

Inspect:

``` r
unique(disease_raw)
```

    ## [1] "Control" "control" "CASE"    "Case"

One simple correction is:

``` r
disease_clean <- disease_raw

disease_clean[
  disease_clean == "control"
] <- "Control"

disease_clean[
  disease_clean == "CASE"
] <- "Case"

table(disease_clean)
```

    ## disease_clean
    ##    Case Control 
    ##       3       2

Later, our string-processing chapter will provide more systematic tools.

------------------------------------------------------------------------

# 5.43 Creating a factor after cleaning

Once labels are standardized:

``` r
disease <- factor(
  disease_clean,
  levels = c(
    "Control",
    "Case"
  )
)

disease
```

    ## [1] Control Control Case    Case    Case   
    ## Levels: Control Case

``` r
levels(disease)
```

    ## [1] "Control" "Case"

A good general workflow is:

``` text
Raw categorical data
        ↓
Inspect unique values
        ↓
Check frequencies
        ↓
Understand codebook
        ↓
Correct known inconsistencies
        ↓
Define factor levels
        ↓
Verify factor
```

------------------------------------------------------------------------

# 5.44 Collapsing categories

Sometimes categories need to be combined for a scientifically justified
analysis.

Suppose smoking status contains:

``` text
Never
Former
Current
```

For a particular analysis, we may want:

``` text
Never
Ever
```

where:

``` text
Former + Current → Ever
```

Start with:

``` r
smoking <- c(
  "Never",
  "Former",
  "Current",
  "Never",
  "Former"
)
```

Create a new variable rather than immediately destroying the original:

``` r
smoking_binary <- smoking

smoking_binary[
  smoking_binary %in% c(
    "Former",
    "Current"
  )
] <- "Ever"

smoking_binary
```

    ## [1] "Never" "Ever"  "Ever"  "Never" "Ever"

Then:

``` r
smoking_binary <- factor(
  smoking_binary,
  levels = c(
    "Never",
    "Ever"
  )
)

smoking_binary
```

    ## [1] Never Ever  Ever  Never Ever 
    ## Levels: Never Ever

------------------------------------------------------------------------

# 5.45 Preserve the original variable when recoding

Instead of:

``` r
smoking[smoking == "Former"] <- "Ever"
```

we often prefer:

``` r
smoking_original <- c(
  "Never",
  "Former",
  "Current"
)

smoking_binary <- smoking_original
```

Then modify the new object.

This preserves the original information and improves reproducibility.

------------------------------------------------------------------------

# 5.46 Collapsing categories requires scientific justification

Combining categories can lose information.

For example:

``` text
Never
Former
Current
```

contains more information than:

``` text
Never
Ever
```

Whether collapsing is appropriate depends on:

- the research question;
- sample size;
- statistical model;
- clinical interpretation;
- prior literature;
- study protocol.

Programming convenience alone is not sufficient justification.

------------------------------------------------------------------------

# 5.47 Unused factor levels

Suppose:

``` r
treatment <- factor(
  c(
    "Placebo",
    "Drug A",
    "Drug B",
    "Placebo",
    "Drug A"
  ),
  levels = c(
    "Placebo",
    "Drug A",
    "Drug B"
  )
)
```

Now select observations excluding Drug B:

``` r
treatment_subset <- treatment[
  treatment != "Drug B"
]

treatment_subset
```

    ## [1] Placebo Drug A  Placebo Drug A 
    ## Levels: Placebo Drug A Drug B

Check:

``` r
levels(treatment_subset)
```

    ## [1] "Placebo" "Drug A"  "Drug B"

`"Drug B"` may still remain as an unused factor level.

------------------------------------------------------------------------

# 5.48 Removing unused levels with `droplevels()`

Use:

``` r
treatment_subset <- droplevels(
  treatment_subset
)

levels(treatment_subset)
```

    ## [1] "Placebo" "Drug A"

Now only levels represented in the subset remain.

This becomes important after filtering datasets.

------------------------------------------------------------------------

# 5.49 Why unused levels can matter

Unused levels can:

- appear in tables;
- confuse plots;
- affect interpretation;
- create unnecessary categories in later analyses.

Therefore, after subsetting factor data, checking:

``` r
levels(x)
```

and sometimes applying:

``` r
droplevels(x)
```

is useful.

------------------------------------------------------------------------

# 5.50 Changing level labels

Suppose:

``` r
disease <- factor(
  c(
    "Ctrl",
    "Case",
    "Ctrl",
    "Case"
  ),
  levels = c(
    "Ctrl",
    "Case"
  )
)
```

We can rename the levels:

``` r
levels(disease) <- c(
  "Control",
  "Case"
)

disease
```

    ## [1] Control Case    Control Case   
    ## Levels: Control Case

This works when we know exactly how the current levels map to the new
labels.

For complex recoding, explicit recoding before factor creation is often
easier to audit.

------------------------------------------------------------------------

# 5.51 Reordering factor levels

Suppose:

``` r
treatment <- factor(
  c(
    "Drug",
    "Placebo",
    "Drug",
    "Placebo"
  )
)

levels(treatment)
```

    ## [1] "Drug"    "Placebo"

If we want `"Placebo"` as the reference:

``` r
treatment <- relevel(
  treatment,
  ref = "Placebo"
)

levels(treatment)
```

    ## [1] "Placebo" "Drug"

This changes level order without changing the observed labels.

------------------------------------------------------------------------

# 5.52 Factor summaries

Suppose:

``` r
smoking <- factor(
  c(
    "Never",
    "Former",
    "Current",
    "Never",
    "Current",
    "Never"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)
```

Run:

``` r
summary(smoking)
```

    ##   Never  Former Current 
    ##       3       1       2

For a factor, `summary()` provides category counts.

This differs from numeric summaries such as means and quartiles.

------------------------------------------------------------------------

# 5.53 Why `mean()` is not appropriate for ordinary factors

For a nominal factor such as:

``` r
blood_group <- factor(
  c(
    "A",
    "O",
    "B",
    "AB"
  )
)
```

there is no scientifically meaningful arithmetic mean of the category
labels.

We summarize such data with counts and proportions:

``` r
table(blood_group)
```

    ## blood_group
    ##  A AB  B  O 
    ##  1  1  1  1

``` r
prop.table(
  table(blood_group)
)
```

    ## blood_group
    ##    A   AB    B    O 
    ## 0.25 0.25 0.25 0.25

The summary method should match the scientific variable type.

------------------------------------------------------------------------

# 5.54 Categorical variables and measurement scales

A useful conceptual distinction is:

``` text
Nominal:
categories without order

Ordinal:
categories with order

Quantitative:
numerical measurements where arithmetic has scientific meaning
```

Examples:

| Variable         | Scientific type     |
|------------------|---------------------|
| Disease status   | Binary categorical  |
| Blood group      | Nominal categorical |
| Smoking category | Nominal categorical |
| Disease severity | Ordinal categorical |
| Age              | Quantitative        |
| Weight           | Quantitative        |
| Systolic BP      | Quantitative        |

These distinctions will become essential in biostatistics.

------------------------------------------------------------------------

# 5.55 Biomedical example: treatment group

``` r
treatment <- factor(
  c(
    "Placebo",
    "Drug A",
    "Drug A",
    "Placebo",
    "Drug B",
    "Drug A"
  ),
  levels = c(
    "Placebo",
    "Drug A",
    "Drug B"
  )
)

treatment
```

    ## [1] Placebo Drug A  Drug A  Placebo Drug B  Drug A 
    ## Levels: Placebo Drug A Drug B

Check:

``` r
levels(treatment)
```

    ## [1] "Placebo" "Drug A"  "Drug B"

``` r
table(treatment)
```

    ## treatment
    ## Placebo  Drug A  Drug B 
    ##       2       3       1

``` r
prop.table(
  table(treatment)
)
```

    ## treatment
    ##   Placebo    Drug A    Drug B 
    ## 0.3333333 0.5000000 0.1666667

Because `"Placebo"` is first, it is positioned to serve as the default
reference under common modeling conventions.

------------------------------------------------------------------------

# 5.56 Epidemiological example: smoking status

``` r
smoking <- factor(
  c(
    "Never",
    "Current",
    "Former",
    "Never",
    "Current",
    "Former",
    "Never"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

table(
  smoking,
  useNA = "ifany"
)
```

    ## smoking
    ##   Never  Former Current 
    ##       3       2       2

The level order is deliberately defined rather than left alphabetical.

------------------------------------------------------------------------

# 5.57 Ordinal example: disease severity

``` r
severity <- ordered(
  c(
    "Mild",
    "Moderate",
    "Severe",
    "Moderate",
    "Mild",
    "Severe"
  ),
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  )
)

severity
```

    ## [1] Mild     Moderate Severe   Moderate Mild     Severe  
    ## Levels: Mild < Moderate < Severe

Check:

``` r
levels(severity)
```

    ## [1] "Mild"     "Moderate" "Severe"

``` r
is.ordered(severity)
```

    ## [1] TRUE

``` r
table(severity)
```

    ## severity
    ##     Mild Moderate   Severe 
    ##        2        2        2

------------------------------------------------------------------------

# 5.58 Genomic example: genotype

Suppose:

``` r
genotype <- c(
  "AA",
  "AG",
  "GG",
  "AG",
  "AA",
  "GG",
  "AG"
)
```

Create a nominal factor:

``` r
genotype_factor <- factor(
  genotype,
  levels = c(
    "AA",
    "AG",
    "GG"
  )
)

genotype_factor
```

    ## [1] AA AG GG AG AA GG AG
    ## Levels: AA AG GG

Count:

``` r
table(genotype_factor)
```

    ## genotype_factor
    ## AA AG GG 
    ##  2  3  2

Genotype categories are labels here. We should not assume that the
factor level numbers themselves represent allele dosage.

------------------------------------------------------------------------

# 5.59 Genotype factor versus allele dosage

Suppose genotype is:

``` text
AA
AG
GG
```

A factor representation is categorical:

``` r
genotype_factor <- factor(
  c(
    "AA",
    "AG",
    "GG"
  )
)
```

An additive genetic model might instead use an explicitly defined dosage
such as:

``` text
AA → 0
AG → 1
GG → 2
```

But that numerical coding represents a **specific genetic model**, not
the internal factor codes.

The dosage must be constructed deliberately according to the chosen
effect allele and analysis model.

This distinction is critical in genetic association analysis.

------------------------------------------------------------------------

# 5.60 Creating genotype dosage deliberately

Suppose `G` is defined as the effect allele.

``` r
genotype <- c(
  "AA",
  "AG",
  "GG",
  "AG",
  "AA"
)

dosage_g <- c(
  0,
  1,
  2,
  1,
  0
)

genotype
```

    ## [1] "AA" "AG" "GG" "AG" "AA"

``` r
dosage_g
```

    ## [1] 0 1 2 1 0

These are two different representations:

``` text
genotype → categorical representation
dosage_g → quantitative count of G alleles
```

We should not obtain dosage using:

``` r
as.numeric(factor(genotype))
```

because those numbers would merely reflect factor-level coding.

------------------------------------------------------------------------

# 5.61 Participant example with several categorical variables

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

disease <- factor(
  c(
    "Control",
    "Case",
    "Case",
    "Control",
    "Case",
    "Control"
  ),
  levels = c(
    "Control",
    "Case"
  )
)

smoking <- factor(
  c(
    "Never",
    "Current",
    "Former",
    "Never",
    "Current",
    "Former"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

severity <- ordered(
  c(
    NA,
    "Moderate",
    "Severe",
    NA,
    "Mild",
    NA
  ),
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  )
)
```

Inspect:

``` r
levels(disease)
```

    ## [1] "Control" "Case"

``` r
levels(smoking)
```

    ## [1] "Never"   "Former"  "Current"

``` r
levels(severity)
```

    ## [1] "Mild"     "Moderate" "Severe"

``` r
table(
  disease,
  useNA = "ifany"
)
```

    ## disease
    ## Control    Case 
    ##       3       3

``` r
table(
  smoking,
  useNA = "ifany"
)
```

    ## smoking
    ##   Never  Former Current 
    ##       2       2       2

``` r
table(
  severity,
  useNA = "ifany"
)
```

    ## severity
    ##     Mild Moderate   Severe     <NA> 
    ##        1        1        1        3

Here severity is missing for controls because the variable may only be
meaningful among cases.

This illustrates an important scientific point: missingness can
sometimes reflect study structure rather than accidental data loss.

------------------------------------------------------------------------

# 5.62 Structural missingness versus accidental missingness

Suppose disease severity is defined only for participants with disease.

For controls:

``` text
Severity = not applicable
```

Representing severity as `NA` may be appropriate.

However, a missing severity value among a case may have a different
interpretation:

``` text
Severity should have been recorded but is missing
```

Both may appear as `NA` in R, even though their scientific meanings
differ.

Later missing-data chapters will examine these distinctions more
carefully.

------------------------------------------------------------------------

# 5.63 Auditing expected categories

Suppose expected smoking categories are:

``` r
expected_smoking <- c(
  "Never",
  "Former",
  "Current"
)
```

Raw data:

``` r
smoking_raw <- c(
  "Never",
  "Former",
  "Current",
  "Unknown",
  "Never"
)
```

Find observed unique values:

``` r
unique(smoking_raw)
```

    ## [1] "Never"   "Former"  "Current" "Unknown"

Identify unexpected categories:

``` r
unique(smoking_raw)[
  !unique(smoking_raw) %in%
    expected_smoking
]
```

    ## [1] "Unknown"

This provides a simple categorical QC pattern.

------------------------------------------------------------------------

# 5.64 Checking whether all values are expected

``` r
all(
  smoking_raw %in%
    expected_smoking
)
```

    ## [1] FALSE

This returns `FALSE` because `"Unknown"` is not in the expected set.

If missing values are allowed, we can use:

``` r
all(
  is.na(smoking_raw) |
    smoking_raw %in%
      expected_smoking
)
```

    ## [1] FALSE

This asks whether every value is either missing or valid.

------------------------------------------------------------------------

# 5.65 Factor creation as validation

After auditing raw values, we can create:

``` r
smoking <- factor(
  smoking_raw,
  levels = expected_smoking
)
```

Then verify:

``` r
table(
  smoking,
  useNA = "ifany"
)
```

    ## smoking
    ##   Never  Former Current    <NA> 
    ##       2       1       1       1

If unexpected labels were present, they become `NA`, which should
trigger investigation rather than silent acceptance.

------------------------------------------------------------------------

# 5.66 Common mistakes

## Mistake 1: assuming character and factor are identical

``` r
x <- c(
  "Control",
  "Case"
)

y <- factor(x)

class(x)
```

    ## [1] "character"

``` r
class(y)
```

    ## [1] "factor"

The displayed values may look similar, but their structures differ.

------------------------------------------------------------------------

## Mistake 2: assuming numeric codes are measurements

``` r
disease_code <- c(
  0,
  1,
  1,
  0
)
```

These may be category codes rather than quantitative measurements.

------------------------------------------------------------------------

## Mistake 3: trusting alphabetical factor order

If R creates:

``` text
Case
Control
```

alphabetically, but our intended reference is `"Control"`, we should
specify or relevel the factor.

------------------------------------------------------------------------

## Mistake 4: direct factor-to-numeric conversion

Potentially dangerous:

``` r
as.numeric(my_factor)
```

This returns internal factor codes.

If numeric-looking labels genuinely represent measurements, the
conversion route is usually:

``` r
as.numeric(
  as.character(my_factor)
)
```

after verifying the labels.

------------------------------------------------------------------------

## Mistake 5: treating nominal categories as ordered

Blood group and study centre do not have a natural ranking.

An ordered factor should only be used when scientific ordering exists.

------------------------------------------------------------------------

## Mistake 6: silently converting unexpected labels to `NA`

Defining restricted levels can turn unknown labels into missing values.

We should inspect:

``` r
unique(smoking_raw)
```

    ## [1] "Never"   "Former"  "Current" "Unknown"

``` r
table(
  smoking_raw,
  useNA = "ifany"
)
```

    ## smoking_raw
    ## Current  Former   Never Unknown 
    ##       1       1       2       1

before factor conversion.

------------------------------------------------------------------------

## Mistake 7: forgetting unused levels after subsetting

Use:

``` r
droplevels(x)
```

when `x` is a factor and unused categories should be removed after
subsetting. This is syntax for reference here rather than an evaluated
example, because the class of `x` depends on the object created earlier
in a workflow.

------------------------------------------------------------------------

## Mistake 8: overwriting the original during recoding

When practical, preserve raw information:

``` r
smoking_clean <- smoking_raw
```

and recode the copy.

------------------------------------------------------------------------

## Mistake 9: interpreting factor codes as genotype dosage

Internal factor codes are not allele counts.

Genetic dosage must be defined deliberately according to allele coding
and the genetic model.

------------------------------------------------------------------------

# 5.67 Guided practical: disease and smoking variables

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

disease_raw <- c(
  "Control",
  "Case",
  "Case",
  "Control",
  "case",
  "Control",
  "Case",
  "Control"
)

smoking_raw <- c(
  "Never",
  "Current",
  "Former",
  "Never",
  "Current",
  "Former",
  "Never",
  NA
)
```

## Step 1: inspect raw categories

``` r
unique(disease_raw)
```

    ## [1] "Control" "Case"    "case"

``` r
table(
  disease_raw,
  useNA = "ifany"
)
```

    ## disease_raw
    ##    case    Case Control 
    ##       1       3       4

We can see that `"case"` and `"Case"` are inconsistent labels.

------------------------------------------------------------------------

## Step 2: create a cleaned copy

``` r
disease_clean <- disease_raw

disease_clean[
  disease_clean == "case"
] <- "Case"
```

Verify:

``` r
unique(disease_clean)
```

    ## [1] "Control" "Case"

``` r
table(
  disease_clean,
  useNA = "ifany"
)
```

    ## disease_clean
    ##    Case Control 
    ##       4       4

------------------------------------------------------------------------

## Step 3: create disease factor

``` r
disease <- factor(
  disease_clean,
  levels = c(
    "Control",
    "Case"
  )
)

levels(disease)
```

    ## [1] "Control" "Case"

``` r
table(disease)
```

    ## disease
    ## Control    Case 
    ##       4       4

------------------------------------------------------------------------

## Step 4: create smoking factor

``` r
smoking <- factor(
  smoking_raw,
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

levels(smoking)
```

    ## [1] "Never"   "Former"  "Current"

``` r
table(
  smoking,
  useNA = "ifany"
)
```

    ## smoking
    ##   Never  Former Current    <NA> 
    ##       3       2       2       1

------------------------------------------------------------------------

## Step 5: calculate category proportions

``` r
prop.table(
  table(disease)
)
```

    ## disease
    ## Control    Case 
    ##     0.5     0.5

For smoking:

``` r
prop.table(
  table(smoking)
)
```

    ## smoking
    ##     Never    Former   Current 
    ## 0.4285714 0.2857143 0.2857143

These proportions exclude missing observations because `table(smoking)`
excludes `NA` by default.

This should always be recognized when interpreting percentages.

------------------------------------------------------------------------

# 5.68 Guided practical: ordered disease severity

Create:

``` r
severity_raw <- c(
  "Mild",
  "Moderate",
  "Severe",
  "Moderate",
  "Mild",
  "Severe",
  "Moderate"
)
```

Create an ordered factor:

``` r
severity <- ordered(
  severity_raw,
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  )
)

severity
```

    ## [1] Mild     Moderate Severe   Moderate Mild     Severe   Moderate
    ## Levels: Mild < Moderate < Severe

Inspect:

``` r
levels(severity)
```

    ## [1] "Mild"     "Moderate" "Severe"

``` r
is.ordered(severity)
```

    ## [1] TRUE

``` r
table(severity)
```

    ## severity
    ##     Mild Moderate   Severe 
    ##        2        3        2

Test:

``` r
severity[2] > severity[1]
```

    ## [1] TRUE

R can interpret this because the category order was explicitly defined.

------------------------------------------------------------------------

# 5.69 Independent exercise

Use:

``` r
id <- c(
  "S001", "S002", "S003", "S004", "S005",
  "S006", "S007", "S008", "S009", "S010"
)

treatment_raw <- c(
  "Placebo",
  "Drug",
  "Drug",
  "placebo",
  "Drug",
  "Placebo",
  "Drug",
  "Placebo",
  NA,
  "Drug"
)

response_raw <- c(
  "Good",
  "Poor",
  "Excellent",
  "Fair",
  "Good",
  "Excellent",
  "Poor",
  "Good",
  "Fair",
  NA
)
```

Complete the following tasks:

1.  inspect unique treatment values;
2.  create a frequency table including missing treatment;
3.  standardize `"placebo"` to `"Placebo"`;
4.  create a treatment factor with `"Placebo"` as the first level;
5.  verify its levels;
6.  calculate treatment counts;
7.  calculate treatment proportions;
8.  create an ordered response factor with:
    `Poor < Fair < Good < Excellent`;
9.  verify that response is ordered;
10. count response categories including missing values;
11. identify IDs with missing treatment;
12. identify IDs with missing response;
13. explain why treatment is nominal rather than ordinal;
14. explain why response can reasonably be treated as ordinal.

------------------------------------------------------------------------

# 5.70 Challenge: coded epidemiological variable

Suppose:

``` r
smoking_code <- c(
  1,
  2,
  3,
  1,
  3,
  2,
  9,
  1
)
```

The codebook states:

``` text
1 = Never
2 = Former
3 = Current
9 = Missing
```

Tasks:

1.  inspect the raw codes;
2.  replace code `9` with `NA`;
3.  create a factor with labels `Never`, `Former`, and `Current`;
4.  verify the level order;
5.  create a table including missing values;
6.  calculate proportions among observed smoking categories;
7.  create a second variable with: `Never` versus `Ever`;
8.  preserve the original three-category factor;
9.  explain why calculating the mean of raw smoking codes would not
    provide a meaningful smoking summary.

------------------------------------------------------------------------

# 5.71 Challenge: genotype categories

Use:

``` r
genotype <- c(
  "AA",
  "AG",
  "GG",
  "AG",
  "AA",
  "GG",
  "AG",
  "AA",
  NA,
  "GG"
)
```

Tasks:

1.  inspect unique genotype values;
2.  create a factor with levels `AA`, `AG`, `GG`;
3.  count genotypes including missing values;
4.  calculate genotype proportions among observed genotypes;
5.  identify missing genotype positions;
6.  create an explicit G-allele dosage vector: `AA = 0`, `AG = 1`,
    `GG = 2`;
7.  preserve missing genotype as missing dosage;
8.  explain why `as.numeric(genotype_factor)` should not be used to
    derive allele dosage.

One possible dosage construction is:

``` r
dosage_g <- rep(
  NA_real_,
  length(genotype)
)

dosage_g[
  genotype == "AA"
] <- 0

dosage_g[
  genotype == "AG"
] <- 1

dosage_g[
  genotype == "GG"
] <- 2

dosage_g
```

    ##  [1]  0  1  2  1  0  2  1  0 NA  2

This coding is explicit and scientifically interpretable because `G` has
been deliberately defined as the counted allele.

------------------------------------------------------------------------

# 5.72 Complete Chapter 5 practice script

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 5: Factors and Categorical Variables
# ============================================================


# ------------------------------------------------------------
# 1. Character categories
# ------------------------------------------------------------

smoking_raw <- c(
  "Never",
  "Former",
  "Current",
  "Never",
  "Current"
)

class(smoking_raw)

unique(smoking_raw)

table(smoking_raw)


# ------------------------------------------------------------
# 2. Create factor
# ------------------------------------------------------------

smoking <- factor(
  smoking_raw,
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

smoking

class(smoking)
levels(smoking)
str(smoking)


# ------------------------------------------------------------
# 3. Disease factor
# ------------------------------------------------------------

disease_code <- c(
  0,
  1,
  1,
  0,
  1
)

disease <- factor(
  disease_code,
  levels = c(
    0,
    1
  ),
  labels = c(
    "Control",
    "Case"
  )
)

disease

levels(disease)

table(disease)

prop.table(
  table(disease)
)


# ------------------------------------------------------------
# 4. Missing categorical values
# ------------------------------------------------------------

smoking_missing <- factor(
  c(
    "Never",
    "Current",
    NA,
    "Former",
    "Never"
  ),
  levels = c(
    "Never",
    "Former",
    "Current"
  )
)

is.na(smoking_missing)

table(
  smoking_missing,
  useNA = "ifany"
)


# ------------------------------------------------------------
# 5. Ordered factor
# ------------------------------------------------------------

severity <- ordered(
  c(
    "Moderate",
    "Mild",
    "Severe",
    "Moderate",
    "Mild"
  ),
  levels = c(
    "Mild",
    "Moderate",
    "Severe"
  )
)

severity

levels(severity)

is.ordered(severity)

severity[1] > severity[2]


# ------------------------------------------------------------
# 6. Reference level
# ------------------------------------------------------------

treatment <- factor(
  c(
    "Drug",
    "Placebo",
    "Drug",
    "Placebo"
  )
)

levels(treatment)

treatment <- relevel(
  treatment,
  ref = "Placebo"
)

levels(treatment)


# ------------------------------------------------------------
# 7. Clean inconsistent labels
# ------------------------------------------------------------

sex_raw <- c(
  "Male",
  "Female",
  "F",
  "M",
  "Female"
)

sex_clean <- sex_raw

sex_clean[
  sex_clean == "M"
] <- "Male"

sex_clean[
  sex_clean == "F"
] <- "Female"

sex <- factor(
  sex_clean,
  levels = c(
    "Female",
    "Male"
  )
)

table(sex)


# ------------------------------------------------------------
# 8. Collapse categories
# ------------------------------------------------------------

smoking_original <- c(
  "Never",
  "Former",
  "Current",
  "Never",
  "Former"
)

smoking_binary <- smoking_original

smoking_binary[
  smoking_binary %in% c(
    "Former",
    "Current"
  )
] <- "Ever"

smoking_binary <- factor(
  smoking_binary,
  levels = c(
    "Never",
    "Ever"
  )
)

smoking_binary


# ------------------------------------------------------------
# 9. Unused levels
# ------------------------------------------------------------

treatment3 <- factor(
  c(
    "Placebo",
    "Drug A",
    "Drug B",
    "Placebo",
    "Drug A"
  ),
  levels = c(
    "Placebo",
    "Drug A",
    "Drug B"
  )
)

treatment_subset <- treatment3[
  treatment3 != "Drug B"
]

levels(treatment_subset)

treatment_subset <- droplevels(
  treatment_subset
)

levels(treatment_subset)


# ------------------------------------------------------------
# 10. Genotype factor
# ------------------------------------------------------------

genotype <- c(
  "AA",
  "AG",
  "GG",
  "AG",
  "AA"
)

genotype_factor <- factor(
  genotype,
  levels = c(
    "AA",
    "AG",
    "GG"
  )
)

table(genotype_factor)


# ------------------------------------------------------------
# 11. Explicit allele dosage
# ------------------------------------------------------------

dosage_g <- rep(
  NA_real_,
  length(genotype)
)

dosage_g[
  genotype == "AA"
] <- 0

dosage_g[
  genotype == "AG"
] <- 1

dosage_g[
  genotype == "GG"
] <- 2

dosage_g
```

------------------------------------------------------------------------

# 5.73 Essential factor functions and syntax

| Task | R syntax |
|----|----|
| Create factor | `factor(x)` |
| Specify levels | `factor(x, levels = ...)` |
| Assign labels | `factor(x, levels = ..., labels = ...)` |
| Create ordered factor | `ordered(x, levels = ...)` |
| Alternative ordered factor | `factor(x, ordered = TRUE)` |
| Inspect levels | `levels(x)` |
| Check factor | `is.factor(x)` |
| Check ordered factor | `is.ordered(x)` |
| Change reference | `relevel(x, ref = "...")` |
| Remove unused levels | `droplevels(x)` |
| Category counts | `table(x)` |
| Include missing in table | `table(x, useNA = "ifany")` |
| Proportions | `prop.table(table(x))` |
| Inspect unique labels | `unique(x)` |
| Missing-value test | `is.na(x)` |
| Convert factor labels to character | `as.character(x)` |
| Inspect internal codes | `unclass(x)` |

------------------------------------------------------------------------

# 5.74 Concept map

``` text
Research variable
       │
       ↓
Is it categorical?
       │
       ├───────────────────────────────┐
       ↓                               ↓
      Yes                              No
       │                               │
       ↓                               ↓
Categorical structure            Quantitative
       │
       ├──────────────┬──────────────┐
       ↓              ↓              ↓
    Binary         Nominal        Ordinal
       │              │              │
       └──────────────┴──────┬───────┘
                             ↓
                           factor
                             │
                  ┌──────────┼──────────┐
                  ↓          ↓          ↓
                levels    reference    ordered?
                  │          │          │
                  ↓          ↓          ↓
               table()   relevel()   ordered()
                  │
                  ↓
            data validation
                  │
         ┌────────┴─────────┐
         ↓                  ↓
 biomedical data       genomic data
```

------------------------------------------------------------------------

# 5.75 Chapter review

Before moving forward, we should be able to answer:

1.  What is a categorical variable?
2.  What is a binary variable?
3.  What is a nominal variable?
4.  What is an ordinal variable?
5.  Why can a numeric code still represent categorical information?
6.  What is the difference between a character vector and a factor?
7.  What does `levels()` return?
8.  Why should we inspect factor levels rather than assume their order?
9.  What is a reference category?
10. Why can reference level matter in statistical modeling?
11. How do we change a reference level?
12. What is an ordered factor?
13. When should an ordered factor be used?
14. What is the difference between `NA` and a category called
    `"Unknown"`?
15. Why should raw category labels be audited before factor conversion?
16. What does `table(..., useNA = "ifany")` provide?
17. Why can `as.numeric(factor)` be dangerous?
18. How can numeric-looking factor labels be converted safely when they
    truly represent measurements?
19. What are unused factor levels?
20. What does `droplevels()` do?
21. Why should category collapsing be scientifically justified?
22. Why are genotype factor codes not equivalent to allele dosage?

------------------------------------------------------------------------

# 5.76 Key takeaways

1.  Categorical variables represent membership in groups rather than
    ordinary quantitative measurements.
2.  Binary variables have two categories.
3.  Nominal variables have categories without inherent order.
4.  Ordinal variables have scientifically meaningful order.
5.  Numeric codes can represent categories and should not automatically
    be treated as measurements.
6.  Character vectors can store labels, but factors explicitly represent
    categorical structure.
7.  Factor levels should be inspected and often specified deliberately.
8.  Alphabetical order is not necessarily scientifically appropriate.
9.  The first factor level commonly acts as the reference under default
    treatment contrasts in many statistical models.
10. `relevel()` allows us to set a reference category deliberately.
11. Ordered factors should only be used when scientific ordering exists.
12. `table()` and `prop.table()` provide basic categorical summaries.
13. Missing values and explicit categories such as `"Unknown"` are
    conceptually different.
14. Unexpected labels should be investigated before factor creation.
15. Direct `as.numeric()` conversion of a factor returns internal codes
    rather than displayed numerical labels.
16. Unused factor levels may remain after subsetting and can be removed
    with `droplevels()`.
17. Recoding should generally preserve the original variable when
    practical.
18. Category collapsing can lose information and requires scientific
    justification.
19. Genotype categories and allele dosage are different representations.
20. Correct categorical representation is essential for later
    statistical modeling.

The central principle is:

> **A factor does more than store labels: it tells R that the values
> represent a defined categorical structure.**

------------------------------------------------------------------------

# 5.77 Looking ahead

Vectors contain one-dimensional collections of values, and factors allow
us to represent categorical variables correctly.

The next structure extends the idea into two dimensions.

For example, gene-expression measurements might be arranged as:

``` text
             Sample1   Sample2   Sample3
Gene1          5.2       4.8       5.6
Gene2          8.1       7.9       8.4
Gene3          2.4       2.7       2.5
```

This rectangular structure contains values of one common type arranged
in rows and columns.

In R, such a structure can be represented using a **matrix**.

The next chapter is:

**Chapter 6 — Matrices**
