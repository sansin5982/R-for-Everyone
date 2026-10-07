Operators, Expressions, and Logical Conditions
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

# Operators, Expressions, and Logical Conditions in R

In the previous chapter, we learned how R stores scientific information
in objects and how values can be numeric, integer, character, or
logical. We also examined missing values and type conversion.

We now move from **storing information** to **asking questions about it
and performing calculations with it**.

In biomedical and epidemiological research, we routinely ask questions
such as:

``` text
Is age at least 50 years?
Is systolic blood pressure greater than 140 mmHg?
Is fasting glucose missing?
Is a participant both a smoker and hypertensive?
Is a diagnosis one of several conditions of interest?
Does a variant fall inside a genomic region?
```

R expresses these questions using **operators**, **expressions**, and
**logical conditions**.

These concepts form the basis of filtering, quality control, data
cleaning, participant selection, programming, and statistical analysis.

------------------------------------------------------------------------

## 3.1 Learning objectives

By the end of this chapter, we should be able to:

- explain operators, operands, and expressions;
- perform arithmetic calculations;
- understand operator precedence;
- use comparison operators;
- distinguish assignment `=` or `<-` from equality testing `==`;
- create logical conditions;
- combine conditions using `&`, `|`, and `!`;
- understand the difference between `&` and `&&`, and between `|` and
  `||`;
- use `%in%` for membership testing;
- use `which()`, `any()`, and `all()`;
- count and calculate proportions from logical values;
- understand how `NA` behaves in logical expressions;
- construct biomedical eligibility and data-quality rules;
- apply logical reasoning to simple genomic examples.

------------------------------------------------------------------------

# 3.2 What is an operator?

An **operator** is a symbol or special construct that tells R to perform
an operation.

For example:

``` r
2 + 3
```

    ## [1] 5

Here:

``` text
2   +   3
↑   ↑   ↑
│   │   └── operand
│   └────── operator
└────────── operand
```

The values being acted upon are called **operands**.

The complete instruction:

``` r
2 + 3
```

is an **expression**.

R evaluates the expression and returns:

``` text
5
```

------------------------------------------------------------------------

# 3.3 Major operator groups

The main operator groups needed at this stage are:

| Category   | Operators                            |
|------------|--------------------------------------|
| Arithmetic | `+`, `-`, `*`, `/`, `^`, `%%`, `%/%` |
| Comparison | `<`, `>`, `<=`, `>=`, `==`, `!=`     |
| Logical    | `&`, `|`, `!`, `&&`, `||`            |
| Membership | `%in%`                               |

We will examine each group carefully.

------------------------------------------------------------------------

# 3.4 Arithmetic operators

Arithmetic operators perform mathematical calculations.

| Operator | Meaning          |
|----------|------------------|
| `+`      | Addition         |
| `-`      | Subtraction      |
| `*`      | Multiplication   |
| `/`      | Division         |
| `^`      | Exponentiation   |
| `%%`     | Remainder        |
| `%/%`    | Integer division |

------------------------------------------------------------------------

# 3.5 Addition and subtraction

``` r
10 + 5
```

    ## [1] 15

``` r
10 - 5
```

    ## [1] 5

Biomedical example:

``` r
baseline_weight <- 75
weight_gain <- 3

followup_weight <- baseline_weight + weight_gain
followup_weight
```

    ## [1] 78

Blood-pressure example:

``` r
sbp <- 138
dbp <- 86

pulse_pressure <- sbp - dbp
pulse_pressure
```

    ## [1] 52

Pulse pressure here is:

$$138 - 86 = 52$$

------------------------------------------------------------------------

# 3.6 Multiplication and division

``` r
10 * 5
```

    ## [1] 50

``` r
10 / 5
```

    ## [1] 2

Suppose weight is measured in kilograms and we want an approximate
conversion to grams:

``` r
weight_kg <- 72
weight_g <- weight_kg * 1000

weight_g
```

    ## [1] 72000

------------------------------------------------------------------------

# 3.7 Exponentiation

The `^` operator raises a value to a power.

``` r
2^3
```

    ## [1] 8

means:

$$2^3 = 2 \times 2 \times 2 = 8$$

BMI uses height squared:

$$BMI = \frac{\text{weight}}{\text{height}^2}$$

``` r
weight <- 75
height <- 1.75

bmi <- weight / height^2
bmi
```

    ## [1] 24.4898

------------------------------------------------------------------------

# 3.8 Mean arterial pressure example

A commonly used approximation for mean arterial pressure is:

$$MAP \approx \frac{SBP + 2(DBP)}{3}$$

For:

``` r
sbp <- 120
dbp <- 80
```

we calculate:

``` r
map <- (sbp + 2 * dbp) / 3
map
```

    ## [1] 93.33333

The parentheses make the intended calculation explicit.

------------------------------------------------------------------------

# 3.9 Operator precedence

R follows mathematical precedence rules.

Consider:

``` r
2 + 3 * 4
```

    ## [1] 14

R evaluates multiplication before addition:

$$2 + (3 \times 4) = 14$$

Compare:

``` r
(2 + 3) * 4
```

    ## [1] 20

Now the parentheses are evaluated first:

$$(2+3)\times4 = 20$$

A practical rule is:

> When a biomedical formula is even slightly complicated, parentheses
> improve clarity and reduce mistakes.

For example:

``` r
map <- (sbp + 2 * dbp) / 3
```

is easier to interpret than relying entirely on precedence.

------------------------------------------------------------------------

# 3.10 Remainder with `%%`

The operator:

``` text
%%
```

returns the remainder after division.

``` r
10 %% 3
```

    ## [1] 1

Since:

$$10 = 3\times3 + 1$$

the remainder is `1`.

Another example:

``` r
12 %% 2
```

    ## [1] 0

returns `0`.

This allows us to test whether a number is even:

``` r
participant_number <- 8

participant_number %% 2 == 0
```

    ## [1] TRUE

The result is `TRUE`.

------------------------------------------------------------------------

# 3.11 Integer division with `%/%`

The operator:

``` text
%/%
```

returns the whole-number part of a division.

``` r
10 %/% 3
```

    ## [1] 3

returns:

``` text
3
```

Compare:

``` r
10 / 3
```

    ## [1] 3.333333

``` r
10 %/% 3
```

    ## [1] 3

``` r
10 %% 3
```

    ## [1] 1

These represent:

``` text
ordinary division
integer division
remainder
```

------------------------------------------------------------------------

# 3.12 Comparison operators

Comparison operators ask whether a relationship is true.

| Operator | Meaning                  |
|----------|--------------------------|
| `<`      | Less than                |
| `>`      | Greater than             |
| `<=`     | Less than or equal to    |
| `>=`     | Greater than or equal to |
| `==`     | Equal to                 |
| `!=`     | Not equal to             |

The result of a comparison is usually:

``` text
TRUE
```

or:

``` text
FALSE
```

------------------------------------------------------------------------

# 3.13 Numerical comparisons

``` r
age <- 52

age > 50
```

    ## [1] TRUE

``` r
age < 50
```

    ## [1] FALSE

``` r
age >= 52
```

    ## [1] TRUE

``` r
age == 52
```

    ## [1] TRUE

``` r
age != 52
```

    ## [1] FALSE

These expressions ask different questions about the same object.

------------------------------------------------------------------------

# 3.14 Equality uses `==`

This distinction is essential.

Assignment:

``` r
age <- 52
```

asks R to store a value.

Equality comparison:

``` r
age == 52
```

    ## [1] TRUE

asks:

> Is the current value of `age` equal to 52?

The result is logical.

A useful distinction is:

``` text
<-   assign a value
==   compare two values
```

R also permits `=` for assignment in many contexts, but `==` is the
equality comparison operator.

------------------------------------------------------------------------

# 3.15 Biomedical threshold example

Suppose:

``` r
age <- 57
```

A study requires age of at least 50:

``` r
age >= 50
```

    ## [1] TRUE

Result:

``` text
TRUE
```

If the upper age limit is 65:

``` r
age <= 65
```

    ## [1] TRUE

also returns `TRUE`.

We will shortly combine these conditions.

------------------------------------------------------------------------

# 3.16 Character comparisons

Comparisons also work with character data.

``` r
sex <- "Female"

sex == "Female"
```

    ## [1] TRUE

``` r
sex == "Male"
```

    ## [1] FALSE

Similarly:

``` r
disease_status <- "Case"

disease_status == "Case"
```

    ## [1] TRUE

``` r
disease_status != "Control"
```

    ## [1] TRUE

Quotation marks matter because `"Case"` is text.

------------------------------------------------------------------------

# 3.17 Character comparisons are case-sensitive

``` r
diagnosis <- "Diabetes"

diagnosis == "Diabetes"
```

    ## [1] TRUE

``` r
diagnosis == "diabetes"
```

    ## [1] FALSE

The second comparison is `FALSE`.

Therefore, inconsistent capitalization in raw data can create problems:

``` text
Diabetes
diabetes
DIABETES
```

We will learn systematic string cleaning later in the book.

------------------------------------------------------------------------

# 3.18 Comparisons create logical values

Suppose:

``` r
sbp <- 145
```

Then:

``` r
high_sbp <- sbp >= 140
high_sbp
```

    ## [1] TRUE

``` r
class(high_sbp)
```

    ## [1] "logical"

The object `high_sbp` is logical.

This is a major programming pattern:

``` text
measurement
     ↓
comparison
     ↓
TRUE / FALSE
     ↓
logical variable
```

------------------------------------------------------------------------

# 3.19 Comparisons across several observations

Vectors receive a full chapter next, but a preview is important.

``` r
age <- c(34, 52, 46, 67, 29, 58)

age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

R compares every element with `50`.

The result is:

``` text
FALSE TRUE FALSE TRUE FALSE TRUE
```

Each output corresponds to the observation in the same position.

------------------------------------------------------------------------

# 3.20 Counting TRUE values

Logical values can be counted with `sum()` because, in this context:

``` text
TRUE  → 1
FALSE → 0
```

For:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

we can count participants aged 50 or older:

``` r
sum(age >= 50)
```

    ## [1] 3

The result is `3`.

------------------------------------------------------------------------

# 3.21 Calculating a proportion from a logical condition

The mean of logical values gives the proportion that are `TRUE`.

``` r
mean(age >= 50)
```

    ## [1] 0.5

Here three of six observations satisfy the condition:

$$\frac{3}{6}=0.5$$

Therefore:

``` text
0.5
```

represents 50%.

This simple pattern is extremely useful in exploratory data analysis.

------------------------------------------------------------------------

# 3.22 Logical operators

Comparison operators create logical values. Logical operators allow us
to combine them.

The main operators are:

``` text
&   AND
|   OR
!   NOT
```

------------------------------------------------------------------------

# 3.23 AND with `&`

The AND operator requires both conditions to be `TRUE`.

Truth table:

| Condition A | Condition B | A `&` B |
|-------------|-------------|---------|
| `TRUE`      | `TRUE`      | `TRUE`  |
| `TRUE`      | `FALSE`     | `FALSE` |
| `FALSE`     | `TRUE`      | `FALSE` |
| `FALSE`     | `FALSE`     | `FALSE` |

Suppose:

``` r
age <- 57
smoker <- TRUE
```

A study requires age at least 50 **and** current smoking:

``` r
(age >= 50) & smoker
```

    ## [1] TRUE

Result:

``` text
TRUE
```

------------------------------------------------------------------------

# 3.24 Epidemiological AND example

Suppose:

``` r
sbp <- 145
diabetes <- TRUE
```

We define a teaching condition requiring:

``` text
SBP ≥ 140
AND
diabetes = TRUE
```

In R:

``` r
(sbp >= 140) & diabetes
```

    ## [1] TRUE

Both conditions are true, so the combined result is `TRUE`.

------------------------------------------------------------------------

# 3.25 OR with `|`

The OR operator requires at least one condition to be `TRUE`.

| Condition A | Condition B | A `|` B |
|-------------|-------------|---------|
| `TRUE`      | `TRUE`      | `TRUE`  |
| `TRUE`      | `FALSE`     | `TRUE`  |
| `FALSE`     | `TRUE`      | `TRUE`  |
| `FALSE`     | `FALSE`     | `FALSE` |

Suppose:

``` r
hypertension <- FALSE
diabetes <- TRUE
```

Then:

``` r
hypertension | diabetes
```

    ## [1] TRUE

returns `TRUE`.

At least one condition is present.

------------------------------------------------------------------------

# 3.26 NOT with `!`

The NOT operator reverses a logical value.

``` r
smoker <- TRUE

!smoker
```

    ## [1] FALSE

returns:

``` text
FALSE
```

Likewise:

``` r
disease <- FALSE

!disease
```

    ## [1] TRUE

returns `TRUE`.

------------------------------------------------------------------------

# 3.27 Combining several conditions

Suppose a study includes participants who:

- are at least 40 years old;
- are no older than 65;
- are current smokers.

``` r
age <- 52
smoker <- TRUE

eligible <- (age >= 40) & (age <= 65) & smoker
eligible
```

    ## [1] TRUE

Result:

``` text
TRUE
```

Parentheses make each condition visually clear.

------------------------------------------------------------------------

# 3.28 Why parentheses are useful in logical expressions

Consider:

``` r
(age >= 40) & (age <= 65)
```

    ## [1] TRUE

This clearly communicates:

``` text
age is at least 40
AND
age is at most 65
```

Even when R could evaluate an expression without extra parentheses,
explicit grouping makes scientific code easier to audit.

------------------------------------------------------------------------

# 3.29 AND versus OR changes the scientific question

Suppose:

``` r
hypertension <- TRUE
diabetes <- FALSE
```

Compare:

``` r
hypertension & diabetes
```

    ## [1] FALSE

with:

``` r
hypertension | diabetes
```

    ## [1] TRUE

The first asks:

> Are both conditions present?

The second asks:

> Is at least one condition present?

Choosing the wrong logical operator changes the scientific definition.

------------------------------------------------------------------------

# 3.30 Element-wise `&` and `|`

Suppose:

``` r
age <- c(34, 52, 46, 67)
smoker <- c(FALSE, TRUE, TRUE, FALSE)
```

Run:

``` r
(age >= 50) & smoker
```

    ## [1] FALSE  TRUE FALSE FALSE

R evaluates corresponding elements:

``` text
Participant   age >= 50   smoker   Combined
------------------------------------------------
1             FALSE       FALSE    FALSE
2             TRUE        TRUE     TRUE
3             FALSE       TRUE     FALSE
4             TRUE        FALSE    FALSE
```

This element-wise behavior is exactly what we need for participant-level
filtering.

------------------------------------------------------------------------

# 3.31 `&` versus `&&`

R provides both:

``` text
&
&&
```

They are not interchangeable.

`&` performs **element-wise** comparison:

``` r
x <- c(TRUE, FALSE, TRUE)
y <- c(TRUE, TRUE, FALSE)

x & y
```

    ## [1]  TRUE FALSE FALSE

The result contains three values.

By contrast:

``` r
# && is intended for a single logical decision
x[1] && y[1]
```

    ## [1] TRUE

uses only the first element of each side for a single control-flow
decision.

For data vectors, we normally use:

``` text
&
```

For conditions inside programming structures such as `if`, `&&` can be
useful when we specifically need one logical decision.

We will revisit this distinction when we study conditional programming.

------------------------------------------------------------------------

# 3.32 `|` versus `||`

The same principle applies:

``` text
|   element-wise OR
||  single-condition OR
```

Example:

``` r
x <- c(FALSE, TRUE, FALSE)
y <- c(FALSE, FALSE, TRUE)

x | y
```

    ## [1] FALSE  TRUE  TRUE

returns an element-wise result.

For participant-level data, `|` is generally the relevant operator.

------------------------------------------------------------------------

# 3.33 Membership testing with `%in%`

Sometimes we need to ask whether a value belongs to a set.

Suppose:

``` r
diagnosis <- "Diabetes"
```

We want to know whether the diagnosis is one of:

``` text
Diabetes
Hypertension
Dyslipidemia
```

Use:

``` r
diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
)
```

    ## [1] TRUE

Result:

``` text
TRUE
```

------------------------------------------------------------------------

# 3.34 Why `%in%` is preferable to repeated OR expressions

We could write:

``` r
diagnosis == "Diabetes" |
  diagnosis == "Hypertension" |
  diagnosis == "Dyslipidemia"
```

    ## [1] TRUE

But this is longer and easier to mistype.

The equivalent membership expression is:

``` r
diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
)
```

    ## [1] TRUE

This is clearer.

------------------------------------------------------------------------

# 3.35 Negating `%in%`

Suppose:

``` r
diagnosis <- "Asthma"
```

To test whether it is **not** in a set:

``` r
!(diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
))
```

    ## [1] TRUE

The parentheses make the logic explicit:

1.  test membership;
2.  reverse the result with `!`.

------------------------------------------------------------------------

# 3.36 Genotype membership example

Suppose:

``` r
genotype <- "AG"
```

We want to know whether the genotype is one of:

``` text
AG
GG
```

Use:

``` r
genotype %in% c("AG", "GG")
```

    ## [1] TRUE

This type of membership test is useful when grouping genotype
categories.

------------------------------------------------------------------------

# 3.37 Genomic variant membership example

Suppose:

``` r
snp_id <- "rs9273371"
```

and a small set of variants of interest is:

``` r
snp_id %in% c(
  "rs9265549",
  "rs9273371",
  "rs9461911"
)
```

    ## [1] TRUE

The result is `TRUE`.

Later, the same idea will allow us to select thousands of variants using
a vector of identifiers.

------------------------------------------------------------------------

# 3.38 `which()`: finding positions

Suppose:

``` r
age <- c(34, 52, 46, 67, 29, 58)
```

The condition:

``` r
age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

returns logical values.

If we want the **positions** where the condition is true:

``` r
which(age >= 50)
```

    ## [1] 2 4 6

Result:

``` text
2 4 6
```

These are positions, not ages.

------------------------------------------------------------------------

# 3.39 Values versus positions

Compare:

``` r
age[age >= 50]
```

    ## [1] 52 67 58

with:

``` r
which(age >= 50)
```

    ## [1] 2 4 6

The first returns the values:

``` text
52 67 58
```

The second returns positions:

``` text
2 4 6
```

We will explore indexing fully in Chapter 4.

------------------------------------------------------------------------

# 3.40 `any()`: is at least one condition true?

Suppose:

``` r
sbp <- c(118, 125, 142, 130, 155)
```

Ask whether **any** measurement is at least 140:

``` r
any(sbp >= 140)
```

    ## [1] TRUE

Result:

``` text
TRUE
```

`any()` answers:

> Is at least one value TRUE?

------------------------------------------------------------------------

# 3.41 `all()`: are all conditions true?

Suppose:

``` r
age <- c(34, 52, 46, 67, 29)
```

Ask whether all participants are adults:

``` r
all(age >= 18)
```

    ## [1] TRUE

Result:

``` text
TRUE
```

`all()` answers:

> Are all values TRUE?

------------------------------------------------------------------------

# 3.42 Data-quality checks with `any()` and `all()`

Suppose valid ages should be between 0 and 120:

``` r
age <- c(34, 52, 46, 167, 29)
```

Check whether any age is invalid:

``` r
any(age < 0 | age > 120)
```

    ## [1] TRUE

Result:

``` text
TRUE
```

Check whether all ages are within the permitted range:

``` r
all(age >= 0 & age <= 120)
```

    ## [1] FALSE

Result:

``` text
FALSE
```

This pattern is extremely useful in data validation.

------------------------------------------------------------------------

# 3.43 Missing values in logical comparisons

Suppose:

``` r
glucose <- NA
```

What happens here?

``` r
glucose >= 126
```

    ## [1] NA

The result is:

``` text
NA
```

R cannot determine whether an unknown glucose value is greater than or
equal to 126.

This is a crucial principle:

> **Missing does not mean FALSE.**

It means the truth of the comparison is unknown.

------------------------------------------------------------------------

# 3.44 A vector containing missing data

``` r
glucose <- c(95, 130, NA, 110)
```

Now:

``` r
glucose >= 126
```

    ## [1] FALSE  TRUE    NA FALSE

returns something conceptually like:

``` text
FALSE TRUE NA FALSE
```

The third condition is unknown because the glucose value itself is
missing.

------------------------------------------------------------------------

# 3.45 Testing missingness explicitly

Use:

``` r
is.na(glucose)
```

    ## [1] FALSE FALSE  TRUE FALSE

To identify recorded values:

``` r
!is.na(glucose)
```

    ## [1]  TRUE  TRUE FALSE  TRUE

We can combine this with another condition:

``` r
!is.na(glucose) & glucose >= 126
```

    ## [1] FALSE  TRUE FALSE FALSE

This explicitly asks for:

``` text
glucose is recorded
AND
glucose is at least 126
```

------------------------------------------------------------------------

# 3.46 Three-valued logic

When `NA` enters a logical expression, R effectively works with three
states:

``` text
TRUE
FALSE
NA
```

Consider:

``` r
FALSE & NA
```

    ## [1] FALSE

``` r
TRUE & NA
```

    ## [1] NA

``` r
TRUE | NA
```

    ## [1] TRUE

``` r
FALSE | NA
```

    ## [1] NA

Results:

``` text
FALSE & NA  → FALSE
TRUE  & NA  → NA
TRUE  | NA  → TRUE
FALSE | NA  → NA
```

Why?

For:

``` text
FALSE & unknown
```

the result must be false because AND requires both sides to be true.

For:

``` text
TRUE & unknown
```

the final answer depends on the unknown value, so the result remains
`NA`.

For:

``` text
TRUE | unknown
```

the result must be true because OR needs only one true condition.

For:

``` text
FALSE | unknown
```

the result depends on the unknown value, so it remains `NA`.

------------------------------------------------------------------------

# 3.47 Missingness should not silently become absence

Suppose disease status is:

``` r
disease <- NA
```

The expression:

``` r
disease == "Case"
```

    ## [1] NA

returns `NA`, not `FALSE`.

Scientifically:

``` text
FALSE → known not to be a case
NA    → disease status is unknown
```

These states must not be confused.

------------------------------------------------------------------------

# 3.48 Creating logical variables

Logical expressions can be saved as objects.

``` r
age <- 57
age_50plus <- age >= 50

age_50plus
```

    ## [1] TRUE

``` r
class(age_50plus)
```

    ## [1] "logical"

Likewise:

``` r
sbp <- 145
high_sbp <- sbp >= 140

high_sbp
```

    ## [1] TRUE

This is useful because a complicated rule can be defined once and
reused.

------------------------------------------------------------------------

# 3.49 Combining derived logical variables

``` r
age <- 57
sbp <- 145

age_50plus <- age >= 50
high_sbp <- sbp >= 140

combined_flag <- age_50plus & high_sbp

combined_flag
```

    ## [1] TRUE

This approach can make code easier to read than writing one very long
expression.

------------------------------------------------------------------------

# 3.50 Study eligibility example

Suppose a study requires:

- age 40–65 years;
- current smoker;
- systolic BP at least 130;
- glucose measurement available.

For one participant:

``` r
age <- 52
smoker <- TRUE
sbp <- 138
glucose <- 110
```

Define each rule:

``` r
age_eligible <- age >= 40 & age <= 65
smoking_eligible <- smoker
bp_eligible <- sbp >= 130
glucose_available <- !is.na(glucose)
```

Combine:

``` r
eligible <- age_eligible &
  smoking_eligible &
  bp_eligible &
  glucose_available

eligible
```

    ## [1] TRUE

This style mirrors how research inclusion criteria are documented.

------------------------------------------------------------------------

# 3.51 Eligibility across several participants

Now consider:

``` r
age <- c(35, 52, 61, 47, 68)
smoker <- c(TRUE, TRUE, FALSE, TRUE, TRUE)
sbp <- c(135, 142, 150, 128, 145)
glucose <- c(100, 115, 120, NA, 130)
```

Define:

``` r
age_eligible <- age >= 40 & age <= 65
smoking_eligible <- smoker
bp_eligible <- sbp >= 130
glucose_available <- !is.na(glucose)
```

Then:

``` r
eligible <- age_eligible &
  smoking_eligible &
  bp_eligible &
  glucose_available

eligible
```

    ## [1] FALSE  TRUE FALSE FALSE FALSE

Each output corresponds to one participant.

This is the foundation of participant filtering.

------------------------------------------------------------------------

# 3.52 Data-quality rule: impossible ages

Suppose:

``` r
age <- c(34, 52, -5, 46, 145, NA)
```

We can identify recorded ages outside a plausible range:

``` r
invalid_age <- !is.na(age) & (age < 0 | age > 120)

invalid_age
```

    ## [1] FALSE FALSE  TRUE FALSE  TRUE FALSE

We can separately identify missing ages:

``` r
missing_age <- is.na(age)

missing_age
```

    ## [1] FALSE FALSE FALSE FALSE FALSE  TRUE

Then combine:

``` r
problem_age <- missing_age | invalid_age

problem_age
```

    ## [1] FALSE FALSE  TRUE FALSE  TRUE  TRUE

This distinguishes:

``` text
missing value
from
recorded but implausible value
```

That distinction is important in research data cleaning.

------------------------------------------------------------------------

# 3.53 Data-quality rule: BMI

Suppose:

``` r
bmi <- c(22.4, 31.2, 17.8, 250, NA)
```

For a teaching QC rule, imagine we want to flag recorded BMI values
outside 10–80:

``` r
invalid_bmi <- !is.na(bmi) & (bmi < 10 | bmi > 80)

invalid_bmi
```

    ## [1] FALSE FALSE FALSE  TRUE FALSE

This is a **data-quality rule**, not a clinical diagnostic definition.

That distinction matters: QC thresholds and clinical thresholds serve
different purposes.

------------------------------------------------------------------------

# 3.54 Genomic interval example

Suppose:

``` r
chromosome <- 6
position <- 32626565
```

We want to know whether the variant lies on chromosome 6 between
32,000,000 and 33,000,000:

``` r
in_region <- chromosome == 6 &
  position >= 32000000 &
  position <= 33000000

in_region
```

    ## [1] TRUE

This same logic later allows us to filter genomic datasets by chromosome
and coordinate.

------------------------------------------------------------------------

# 3.55 GWAS significance example

Suppose:

``` r
p_value <- 2.4e-09
```

We can test:

``` r
p_value < 5e-8
```

    ## [1] TRUE

The result is `TRUE`.

This demonstrates how a statistical threshold can be represented
programmatically.

At this stage, our focus is the R expression rather than the statistical
interpretation of genome-wide significance.

------------------------------------------------------------------------

# 3.56 Allele example

Suppose:

``` r
effect_allele <- "A"
other_allele <- "G"
```

We can ask:

``` r
effect_allele == "A"
```

    ## [1] TRUE

``` r
other_allele == "G"
```

    ## [1] TRUE

Or test membership:

``` r
effect_allele %in% c("A", "C", "G", "T")
```

    ## [1] TRUE

This can become part of a simple allele-validation rule.

------------------------------------------------------------------------

# 3.57 A simple nucleotide validation rule

``` r
allele <- "A"

valid_allele <- allele %in% c("A", "C", "G", "T")
valid_allele
```

    ## [1] TRUE

If:

``` r
allele <- "X"
```

then:

``` r
allele %in% c("A", "C", "G", "T")
```

    ## [1] FALSE

returns `FALSE`.

This is a simple example of data validation using membership logic.

------------------------------------------------------------------------

# 3.58 Common mistakes

## Mistake 1: using `=` when we mean `==`

Assignment:

``` r
age <- 52
```

Comparison:

``` r
age == 52
```

    ## [1] TRUE

These are conceptually different operations.

------------------------------------------------------------------------

## Mistake 2: confusing AND with OR

Suppose inclusion requires both:

``` text
age ≥ 50
AND
smoker
```

Correct:

``` r
age <- 55
smoker <- TRUE

(age >= 50) & smoker
```

    ## [1] TRUE

Using `|` would define a different eligibility rule.

------------------------------------------------------------------------

## Mistake 3: forgetting parentheses in complex conditions

Clear:

``` r
age <- 55
(age >= 40) & (age <= 65)
```

    ## [1] TRUE

Readable scientific code is preferable to unnecessarily compressed
expressions.

------------------------------------------------------------------------

## Mistake 4: using `== NA`

Incorrect:

``` r
glucose == NA
```

Correct:

``` r
glucose <- NA
is.na(glucose)
```

    ## [1] TRUE

------------------------------------------------------------------------

## Mistake 5: treating missing as FALSE

If:

``` r
glucose <- NA
```

then:

``` r
glucose >= 126
```

    ## [1] NA

returns `NA`, not `FALSE`.

Unknown and negative are not the same.

------------------------------------------------------------------------

## Mistake 6: forgetting quotes around character values

Incorrect:

``` r
diagnosis == Diabetes
```

Correct:

``` r
diagnosis <- "Diabetes"
diagnosis == "Diabetes"
```

    ## [1] TRUE

------------------------------------------------------------------------

## Mistake 7: writing repeated OR conditions unnecessarily

Longer:

``` r
diagnosis == "Diabetes" |
  diagnosis == "Hypertension" |
  diagnosis == "Dyslipidemia"
```

    ## [1] TRUE

Clearer:

``` r
diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
)
```

    ## [1] TRUE

------------------------------------------------------------------------

## Mistake 8: using `&&` for participant-level vectors

For vectors:

``` r
x <- c(TRUE, FALSE, TRUE)
y <- c(TRUE, TRUE, FALSE)

x & y
```

    ## [1]  TRUE FALSE FALSE

is element-wise.

`&&` is intended for a single logical decision and does not replace `&`
in ordinary participant-level vector filtering.

------------------------------------------------------------------------

# 3.59 Guided practical: small epidemiological dataset

Create:

``` r
id <- c(
  "P001", "P002", "P003",
  "P004", "P005", "P006"
)

age <- c(
  34, 52, 46,
  67, 29, 58
)

sbp <- c(
  118, 145, 132,
  155, 121, 142
)

glucose <- c(
  92, 105, NA,
  130, 88, 128
)

smoker <- c(
  FALSE, TRUE, TRUE,
  FALSE, FALSE, TRUE
)
```

## Task 1: age at least 50

``` r
age >= 50
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

Count:

``` r
sum(age >= 50)
```

    ## [1] 3

Proportion:

``` r
mean(age >= 50)
```

    ## [1] 0.5

------------------------------------------------------------------------

## Task 2: current smokers

``` r
smoker
```

    ## [1] FALSE  TRUE  TRUE FALSE FALSE  TRUE

Count:

``` r
sum(smoker)
```

    ## [1] 3

------------------------------------------------------------------------

## Task 3: smokers aged at least 50

``` r
(age >= 50) & smoker
```

    ## [1] FALSE  TRUE FALSE FALSE FALSE  TRUE

Identify IDs:

``` r
id[(age >= 50) & smoker]
```

    ## [1] "P002" "P006"

------------------------------------------------------------------------

## Task 4: missing glucose

``` r
is.na(glucose)
```

    ## [1] FALSE FALSE  TRUE FALSE FALSE FALSE

Count:

``` r
sum(is.na(glucose))
```

    ## [1] 1

Identify IDs:

``` r
id[is.na(glucose)]
```

    ## [1] "P003"

------------------------------------------------------------------------

## Task 5: recorded glucose at least 126

``` r
high_glucose <- !is.na(glucose) & glucose >= 126

high_glucose
```

    ## [1] FALSE FALSE FALSE  TRUE FALSE  TRUE

``` r
id[high_glucose]
```

    ## [1] "P004" "P006"

The threshold here is used as a programming example rather than as a
complete clinical diagnostic rule.

------------------------------------------------------------------------

## Task 6: teaching risk flag

Suppose we define a simple teaching flag as:

``` text
SBP ≥ 140
OR
recorded glucose ≥ 126
```

``` r
risk_flag <- (sbp >= 140) |
  (!is.na(glucose) & glucose >= 126)

risk_flag
```

    ## [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE

``` r
id[risk_flag]
```

    ## [1] "P002" "P004" "P006"

This demonstrates how a research rule can combine multiple variables.

------------------------------------------------------------------------

# 3.60 Independent exercise

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

Complete the following:

1.  identify participants aged at least 50;
2.  count participants aged at least 50;
3.  calculate the proportion aged at least 50;
4.  identify current smokers;
5.  identify smokers aged at least 50;
6.  identify participants with SBP at least 140;
7.  identify missing glucose values;
8.  count missing glucose values;
9.  identify participants with recorded glucose at least 126;
10. determine whether any SBP is at least 150;
11. determine whether all participants are adults;
12. find positions where SBP is at least 140;
13. create a logical flag for `SBP >= 140 OR glucose >= 126`, handling
    missing glucose explicitly;
14. identify IDs satisfying that flag.

------------------------------------------------------------------------

# 3.61 Challenge: study eligibility

Suppose eligibility requires:

``` text
Age:               40–65 years inclusive
Current smoker:    Yes
SBP:               at least 130
Glucose:           must be recorded
```

Use:

``` r
id <- c(
  "P001", "P002", "P003",
  "P004", "P005", "P006"
)

age <- c(
  39, 52, 61,
  47, 66, 58
)

smoker <- c(
  TRUE, TRUE, FALSE,
  TRUE, TRUE, TRUE
)

sbp <- c(
  135, 142, 150,
  128, 145, 138
)

glucose <- c(
  100, 115, 120,
  NA, 130, 110
)
```

Build the criteria separately:

``` r
age_ok <- age >= 40 & age <= 65
smoker_ok <- smoker
sbp_ok <- sbp >= 130
glucose_ok <- !is.na(glucose)
```

Then combine:

``` r
eligible <- age_ok &
  smoker_ok &
  sbp_ok &
  glucose_ok

eligible
```

    ## [1] FALSE  TRUE FALSE FALSE FALSE  TRUE

Identify eligible participants:

``` r
id[eligible]
```

    ## [1] "P002" "P006"

Breaking a complicated definition into named logical components makes
the code easier to verify.

------------------------------------------------------------------------

# 3.62 Challenge: genomic filtering logic

Suppose:

``` r
snp_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004",
  "rs1005"
)

chromosome <- c(6, 6, 6, 5, 6)

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
```

Define a teaching xMHC-style interval:

``` r
in_region <- chromosome == 6 &
  position >= 27000000 &
  position <= 34000000
```

Define a significance rule:

``` r
significant <- p_value < 5e-8
```

Combine:

``` r
region_and_significant <- in_region & significant

region_and_significant
```

    ## [1] FALSE  TRUE  TRUE FALSE FALSE

``` r
snp_id[region_and_significant]
```

    ## [1] "rs1002" "rs1003"

This exercise shows that the same logical concepts used for participant
eligibility also apply to genomic variant filtering.

------------------------------------------------------------------------

# 3.63 Complete Chapter 3 practice script

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 3: Operators, Expressions, and Logical Conditions
# ============================================================

# ------------------------------------------------------------
# 1. Arithmetic
# ------------------------------------------------------------

2 + 3
10 - 4
5 * 6
20 / 4
2^3

10 %% 3
10 %/% 3


# ------------------------------------------------------------
# 2. Biomedical calculations
# ------------------------------------------------------------

weight <- 75
height <- 1.75

bmi <- weight / height^2
bmi

sbp <- 138
dbp <- 86

pulse_pressure <- sbp - dbp
map <- (sbp + 2 * dbp) / 3

pulse_pressure
map


# ------------------------------------------------------------
# 3. Comparisons
# ------------------------------------------------------------

age <- 52

age > 50
age >= 50
age < 50
age <= 65
age == 52
age != 52


# ------------------------------------------------------------
# 4. Character comparisons
# ------------------------------------------------------------

disease_status <- "Case"

disease_status == "Case"
disease_status != "Control"


# ------------------------------------------------------------
# 5. Logical operators
# ------------------------------------------------------------

age <- 57
smoker <- TRUE

(age >= 50) & smoker
(age >= 65) | smoker
!smoker


# ------------------------------------------------------------
# 6. Membership
# ------------------------------------------------------------

diagnosis <- "Diabetes"

diagnosis %in% c(
  "Diabetes",
  "Hypertension",
  "Dyslipidemia"
)


# ------------------------------------------------------------
# 7. Vector comparisons
# ------------------------------------------------------------

age <- c(34, 52, 46, 67, 29, 58)

age >= 50

sum(age >= 50)
mean(age >= 50)

which(age >= 50)

any(age >= 65)
all(age >= 18)


# ------------------------------------------------------------
# 8. Missing values and logic
# ------------------------------------------------------------

glucose <- c(
  95, 130, NA,
  110, 128
)

is.na(glucose)

!is.na(glucose)

!is.na(glucose) & glucose >= 126


# ------------------------------------------------------------
# 9. Participant selection
# ------------------------------------------------------------

id <- c(
  "P001", "P002", "P003",
  "P004", "P005"
)

age <- c(
  34, 52, 46,
  67, 58
)

smoker <- c(
  FALSE, TRUE, TRUE,
  FALSE, TRUE
)

id[age >= 50]

id[(age >= 50) & smoker]


# ------------------------------------------------------------
# 10. Data-quality checks
# ------------------------------------------------------------

age <- c(
  34, 52, -5,
  46, 145, NA
)

missing_age <- is.na(age)

invalid_age <- !is.na(age) &
  (age < 0 | age > 120)

problem_age <- missing_age |
  invalid_age

missing_age
invalid_age
problem_age


# ------------------------------------------------------------
# 11. Genomic example
# ------------------------------------------------------------

chromosome <- 6
position <- 32626565
p_value <- 2.4e-09

in_region <- chromosome == 6 &
  position >= 32000000 &
  position <= 33000000

significant <- p_value < 5e-8

in_region
significant
in_region & significant
```

------------------------------------------------------------------------

# 3.64 Essential operators and functions

| Task              | R syntax           |
|-------------------|--------------------|
| Addition          | `x + y`            |
| Subtraction       | `x - y`            |
| Multiplication    | `x * y`            |
| Division          | `x / y`            |
| Power             | `x^2`              |
| Remainder         | `x %% y`           |
| Integer division  | `x %/% y`          |
| Less than         | `x < y`            |
| Greater than      | `x > y`            |
| Less/equal        | `x <= y`           |
| Greater/equal     | `x >= y`           |
| Equal             | `x == y`           |
| Not equal         | `x != y`           |
| AND               | `x & y`            |
| OR                | `x \| y`           |
| NOT               | `!x`               |
| Membership        | `x %in% values`    |
| Missing           | `is.na(x)`         |
| Positions of TRUE | `which(condition)` |
| At least one TRUE | `any(condition)`   |
| All TRUE          | `all(condition)`   |
| Count TRUE        | `sum(condition)`   |
| Proportion TRUE   | `mean(condition)`  |

------------------------------------------------------------------------

# 3.65 Concept map

``` text
Objects and values
       │
       ↓
   Operators
       │
       ├─────────────┬─────────────┬──────────────┐
       ↓             ↓             ↓              ↓
 Arithmetic      Comparison      Logical       Membership
 + - * / ^       < > == !=       & | !          %in%
       │             │             │              │
       └─────────────┴──────┬──────┴──────────────┘
                            ↓
                       Expression
                            ↓
                    TRUE / FALSE / NA
                            ↓
              ┌─────────────┼─────────────┐
              ↓             ↓             ↓
           which()         any()         all()
              │
              ↓
        Select observations
              │
              ↓
   Filtering / QC / eligibility /
      cleaning / genomic rules
```

------------------------------------------------------------------------

# 3.66 Chapter review

Before moving forward, we should be able to answer:

1.  What is the difference between an operator and an operand?
2.  What is an expression?
3.  What is the difference between `<-` and `==`?
4.  What does `!=` mean?
5.  How does `&` differ from `|`?
6.  What does `!` do?
7.  Why is `%in%` useful?
8.  What does `which()` return?
9.  How does `any()` differ from `all()`?
10. Why does `sum(condition)` count `TRUE` values?
11. Why does `mean(condition)` calculate a proportion?
12. What happens when a comparison involves `NA`?
13. Why is missingness not equivalent to `FALSE`?
14. What is the difference between `&` and `&&`?
15. How can logical expressions represent research inclusion criteria?
16. How can the same logic be used for genomic interval filtering?

------------------------------------------------------------------------

# 3.67 Key takeaways

1.  Operators allow us to calculate and compare values.
2.  Arithmetic operators perform mathematical operations.
3.  Comparison operators return logical results.
4.  `==` tests equality; it does not perform ordinary assignment.
5.  `&` means AND, `|` means OR, and `!` means NOT.
6.  `&` and `|` are element-wise and are especially important for data
    vectors.
7.  `%in%` tests whether values belong to a specified set.
8.  `which()` returns positions where a condition is true.
9.  `any()` asks whether at least one condition is true.
10. `all()` asks whether every condition is true.
11. Logical values can be counted with `sum()` and summarized as
    proportions with `mean()`.
12. Comparisons involving missing values may return `NA`.
13. `NA` means unknown, not false.
14. Complex research definitions can be constructed from simple logical
    conditions.
15. The same logical framework applies to epidemiological participants,
    laboratory QC, and genomic variants.

A central pattern from this chapter is:

``` text
Scientific question
       ↓
Logical condition
       ↓
TRUE / FALSE / NA
       ↓
Selection or decision
```

------------------------------------------------------------------------

# 3.68 Looking ahead

So far, we have used short collections of values only as previews. The
next chapter examines them properly.

A typical research variable contains many observations:

``` text
Age:
34, 52, 46, 67, 29, 58, ...
```

R represents this kind of one-dimensional collection using a **vector**.

Once vectors are understood, expressions such as:

``` r
age >= 50
```

become much more powerful because R can evaluate an entire study
population at once.

The next chapter is:

**Chapter 4 — Vectors: The Foundation of R**
