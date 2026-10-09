Arrays and Higher-Dimensional Data
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 6, we learned to work with matrices. A matrix has two
dimensions: rows and columns. Many biomedical datasets have another
dimension, such as time, tissue, treatment, imaging slice, or
experimental condition.

Imagine measuring expression of three genes in four participants at two
visits. The data have three dimensions:

$$\text{Gene}\times\text{Participant}\times\text{Visit}
=3\times4\times2.$$

In R, an **array** can represent this structure without combining
distinct dimensions into a single long vector or inventing extra
columns.

An array is an atomic vector with a `dim` attribute. A matrix is a
special case of an array with exactly two dimensions. Like a matrix, an
array holds values of a **single atomic type**.

## 7.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Explain how vectors, matrices, and arrays relate.
2.  Create three- and four-dimensional arrays using `array()`.
3.  Predict how R fills arrays and interpret their dimensions.
4.  Assign and validate dimension names.
5.  Index cells, slices, and subarrays, including `drop = FALSE`.
6.  Use `apply()` and dedicated matrix functions to summarize across
    dimensions.
7.  Handle missing values and calculate missingness by dimension.
8.  Reorder dimensions using `aperm()`.
9.  Distinguish dimension order from data order and avoid misalignment.
10. Use arrays in longitudinal biomedical, genomic, and imaging
    examples.
11. Recognize when arrays are unsuitable for mixed-type or irregular
    data.

------------------------------------------------------------------------

## 7.2 Revisiting vectors and matrices

A vector has one dimension in the conceptual sense, although an ordinary
vector normally has no `dim` attribute:

``` r
v <- c(10, 20, 30, 40)
v
```

    ## [1] 10 20 30 40

``` r
length(v)
```

    ## [1] 4

``` r
dim(v)                  # NULL: no explicit dimensions
```

    ## NULL

A matrix has two dimensions:

``` r
m <- matrix(1:12, nrow = 3, ncol = 4)
m
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    4    7   10
    ## [2,]    2    5    8   11
    ## [3,]    3    6    9   12

``` r
dim(m)
```

    ## [1] 3 4

An array can have three or more dimensions:

``` r
a <- array(1:24, dim = c(3, 4, 2))
dim(a)
```

    ## [1] 3 4 2

``` r
length(a)
```

    ## [1] 24

The three dimensions are:

- dimension 1: 3 positions;
- dimension 2: 4 positions;
- dimension 3: 2 positions.

The total number of elements is:

$$3\times4\times2=24.$$

``` r
prod(dim(a))
```

    ## [1] 24

``` r
length(a) == prod(dim(a))
```

    ## [1] TRUE

**Important:** Arrays are not automatically three-dimensional. A matrix
is a two-dimensional array; `array()` can also create a one-dimensional
or four-dimensional object.

## 7.3 Understanding a three-dimensional structure

Suppose our data are organized as:

- dimension 1 = genes;
- dimension 2 = participants;
- dimension 3 = visits.

We can visualize a three-dimensional array as a stack of two matrices.

**Visit 1**

| Gene   | P001 | P002 | P003 | P004 |
|--------|-----:|-----:|-----:|-----:|
| Gene_A |  5.0 |  5.2 |  5.4 |  5.6 |
| Gene_B |  7.0 |  7.2 |  7.4 |  7.6 |
| Gene_C |  3.0 |  3.2 |  3.4 |  3.6 |

**Visit 2**

| Gene   | P001 | P002 | P003 | P004 |
|--------|-----:|-----:|-----:|-----:|
| Gene_A |  5.5 |  5.7 |  5.9 |  6.1 |
| Gene_B |  7.5 |  7.7 |  7.9 |  8.1 |
| Gene_C |  3.5 |  3.7 |  3.9 |  4.1 |

The first two dimensions describe the rows and columns of each matrix.
The third dimension selects which visit’s matrix we are viewing.

------------------------------------------------------------------------

## 7.4 Creating an array with `array()`

The basic syntax is:

``` r
array(data, dim = c(dimension_1, dimension_2, dimension_3))
```

For example:

``` r
a <- array(1:24, dim = c(3, 4, 2))
a
```

    ## , , 1
    ## 
    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    4    7   10
    ## [2,]    2    5    8   11
    ## [3,]    3    6    9   12
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2] [,3] [,4]
    ## [1,]   13   16   19   22
    ## [2,]   14   17   20   23
    ## [3,]   15   18   21   24

We should always inspect the dimensions:

``` r
dim(a)
```

    ## [1] 3 4 2

``` r
length(a)
```

    ## [1] 24

``` r
typeof(a)
```

    ## [1] "integer"

``` r
class(a)
```

    ## [1] "array"

``` r
is.array(a)
```

    ## [1] TRUE

The default printed representation separates the third dimension into
two-dimensional slices.

### A critical rule: R fills arrays in column-major order

R fills the **first dimension fastest**, then the second, then the
third.

``` r
small <- array(1:12, dim = c(2, 3, 2))
small
```

    ## , , 1
    ## 
    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2] [,3]
    ## [1,]    7    9   11
    ## [2,]    8   10   12

For the first slice (`small[, , 1]`), the values appear as:

``` text
     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6
```

For the second slice (`small[, , 2]`), the values are 7 through 12, also
filled column by column.

``` r
small[, , 1]
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

``` r
small[, , 2]
```

    ##      [,1] [,2] [,3]
    ## [1,]    7    9   11
    ## [2,]    8   10   12

This is why supplying data in an incorrect order can produce a valid R
object with **scientifically incorrect alignment**.

## 7.5 Array dimensions and attributes

``` r
a <- array(seq_len(24), dim = c(3, 4, 2))
dim(a)
```

    ## [1] 3 4 2

``` r
length(a)
```

    ## [1] 24

``` r
attributes(a)
```

    ## $dim
    ## [1] 3 4 2

An array’s dimensions are stored as an attribute.

``` r
is.matrix(a)
```

    ## [1] FALSE

``` r
is.array(a)
```

    ## [1] TRUE

For comparison:

``` r
m <- matrix(1:6, nrow = 2)
is.matrix(m)
```

    ## [1] TRUE

``` r
is.array(m)
```

    ## [1] TRUE

A matrix is also an array. A three-dimensional array is not a matrix.

## 7.6 Arrays are atomic: type coercion

As with vectors and matrices, all elements share one atomic type.

``` r
numeric_array <- array(c(1, 2, 3, NA), dim = c(2, 2, 1))
typeof(numeric_array)
```

    ## [1] "double"

If text is mixed with numbers, coercion can occur:

``` r
mixed_array <- array(c(1, 2, "Missing", 4), dim = c(2, 2, 1))
typeof(mixed_array)
```

    ## [1] "character"

``` r
mixed_array
```

    ## , , 1
    ## 
    ##      [,1] [,2]     
    ## [1,] "1"  "Missing"
    ## [2,] "2"  "4"

All elements have become character strings.

For genuinely missing numerical measurements, use `NA`, not a text label
such as `"Missing"`.

``` r
clean_array <- array(c(1, 2, NA_real_, 4), dim = c(2, 2, 1))
typeof(clean_array)
```

    ## [1] "double"

A mixed-type participant table is usually better represented by a data
frame, introduced in Chapter 9.

------------------------------------------------------------------------

## 7.7 Adding dimension names

Unnamed dimensions are difficult to interpret. For research data,
dimension names are often essential.

``` r
gene_names <- c("Gene_A", "Gene_B", "Gene_C")
participant_ids <- c("P001", "P002", "P003", "P004")
visit_names <- c("Baseline", "Followup")
```

Create the array:

``` r
expr <- array(
  NA_real_,
  dim = c(3, 4, 2),
  dimnames = list(
    Gene = gene_names,
    Participant = participant_ids,
    Visit = visit_names
  )
)
dim(expr)
```

    ## [1] 3 4 2

``` r
dimnames(expr)
```

    ## $Gene
    ## [1] "Gene_A" "Gene_B" "Gene_C"
    ## 
    ## $Participant
    ## [1] "P001" "P002" "P003" "P004"
    ## 
    ## $Visit
    ## [1] "Baseline" "Followup"

Here, `Gene`, `Participant`, and `Visit` are the **names of the
dimensions**; the vectors inside the list provide the labels along each
dimension.

Check:

``` r
names(dimnames(expr))
```

    ## [1] "Gene"        "Participant" "Visit"

``` r
rownames(expr)
```

    ## [1] "Gene_A" "Gene_B" "Gene_C"

``` r
colnames(expr)
```

    ## [1] "P001" "P002" "P003" "P004"

`rownames()` and `colnames()` refer to the first two dimensions. For all
dimensions, `dimnames()` is more general.

### Assigning names after construction

``` r
unnamed <- array(1:12, dim = c(2, 3, 2))
dimnames(unnamed) <- list(
  Gene = c("G1", "G2"),
  Sample = c("S1", "S2", "S3"),
  Time = c("T0", "T1")
)
unnamed
```

    ## , , Time = T0
    ## 
    ##     Sample
    ## Gene S1 S2 S3
    ##   G1  1  3  5
    ##   G2  2  4  6
    ## 
    ## , , Time = T1
    ## 
    ##     Sample
    ## Gene S1 S2 S3
    ##   G1  7  9 11
    ##   G2  8 10 12

### Validate the length of every dimension label vector

``` r
stopifnot(length(gene_names) == 3)
stopifnot(length(participant_ids) == 4)
stopifnot(length(visit_names) == 2)
```

`stopifnot()` stops execution if an assumption is false. It is useful
for catching mistakes before an analysis proceeds.

------------------------------------------------------------------------

## 7.8 Constructing a scientifically interpretable expression array

Instead of guessing how a long vector is mapped into three dimensions,
we will fill the two visit slices explicitly.

``` r
expr <- array(
  NA_real_,
  dim = c(3, 4, 2),
  dimnames = list(
    Gene = c("Gene_A", "Gene_B", "Gene_C"),
    Participant = c("P001", "P002", "P003", "P004"),
    Visit = c("Baseline", "Followup")
  )
)

baseline <- matrix(
  c(
    5.0, 5.2, 5.4, 5.6,
    7.0, 7.2, 7.4, 7.6,
    3.0, 3.2, 3.4, 3.6
  ),
  nrow = 3,
  byrow = TRUE
)

followup <- matrix(
  c(
    5.5, 5.7, 5.9, 6.1,
    7.5, 7.7, 7.9, 8.1,
    3.5, 3.7, 3.9, 4.1
  ),
  nrow = 3,
  byrow = TRUE
)

expr[, , "Baseline"] <- baseline
expr[, , "Followup"] <- followup
expr
```

    ## , , Visit = Baseline
    ## 
    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A    5  5.2  5.4  5.6
    ##   Gene_B    7  7.2  7.4  7.6
    ##   Gene_C    3  3.2  3.4  3.6
    ## 
    ## , , Visit = Followup
    ## 
    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A  5.5  5.7  5.9  6.1
    ##   Gene_B  7.5  7.7  7.9  8.1
    ##   Gene_C  3.5  3.7  3.9  4.1

The assignment is explicit:

``` text
expr[, , "Baseline"] = baseline matrix
expr[, , "Followup"] = follow-up matrix
```

This approach makes the meaning of the third dimension visible in the
code.

------------------------------------------------------------------------

## 7.9 Indexing an array

The general syntax is:

``` r
x[index_1, index_2, index_3]
```

For our array:

``` text
expr[gene, participant, visit]
```

### Select one cell

``` r
expr["Gene_B", "P003", "Followup"]
```

    ## [1] 7.9

The selected value corresponds to Gene_B in participant P003 at
follow-up.

### Select all genes for one participant and one visit

``` r
expr[, "P002", "Baseline"]
```

    ## Gene_A Gene_B Gene_C 
    ##    5.2    7.2    3.2

### Select one gene across participants at one visit

``` r
expr["Gene_A", , "Followup"]
```

    ## P001 P002 P003 P004 
    ##  5.5  5.7  5.9  6.1

### Select the complete baseline matrix

``` r
expr[, , "Baseline"]
```

    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A    5  5.2  5.4  5.6
    ##   Gene_B    7  7.2  7.4  7.6
    ##   Gene_C    3  3.2  3.4  3.6

### Select one participant across all genes and visits

``` r
expr[, "P001", ]
```

    ##         Visit
    ## Gene     Baseline Followup
    ##   Gene_A        5      5.5
    ##   Gene_B        7      7.5
    ##   Gene_C        3      3.5

### Select a subset of genes and participants at one visit

``` r
expr[
  c("Gene_A", "Gene_C"),
  c("P001", "P004"),
  "Baseline"
]
```

    ##         Participant
    ## Gene     P001 P004
    ##   Gene_A    5  5.6
    ##   Gene_C    3  3.6

### Negative indexing

Exclude participant P002:

``` r
expr[, -2, ]
```

    ## , , Visit = Baseline
    ## 
    ##         Participant
    ## Gene     P001 P003 P004
    ##   Gene_A    5  5.4  5.6
    ##   Gene_B    7  7.4  7.6
    ##   Gene_C    3  3.4  3.6
    ## 
    ## , , Visit = Followup
    ## 
    ##         Participant
    ## Gene     P001 P003 P004
    ##   Gene_A  5.5  5.9  6.1
    ##   Gene_B  7.5  7.9  8.1
    ##   Gene_C  3.5  3.9  4.1

Negative indices exclude positions, as they do for vectors and matrices.

### Logical indexing

Select genes whose baseline expression in P001 exceeds 4:

``` r
selected_genes <- expr[, "P001", "Baseline"] > 4
selected_genes
```

    ## Gene_A Gene_B Gene_C 
    ##   TRUE   TRUE  FALSE

``` r
expr[selected_genes, , , drop = FALSE]
```

    ## , , Visit = Baseline
    ## 
    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A    5  5.2  5.4  5.6
    ##   Gene_B    7  7.2  7.4  7.6
    ## 
    ## , , Visit = Followup
    ## 
    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A  5.5  5.7  5.9  6.1
    ##   Gene_B  7.5  7.7  7.9  8.1

The logical vector applies to the first dimension (genes).

------------------------------------------------------------------------

## 7.10 Dimension dropping and `drop = FALSE`

Selecting a single slice may return a matrix:

``` r
one_visit <- expr[, , "Baseline"]
dim(one_visit)
```

    ## [1] 3 4

``` r
is.matrix(one_visit)
```

    ## [1] TRUE

Selecting one gene across participants and visits can also return a
matrix:

``` r
one_gene <- expr["Gene_A", , ]
dim(one_gene)
```

    ## [1] 4 2

If we need to preserve the full three-dimensional structure, specify
`drop = FALSE`:

``` r
one_gene_array <- expr[
  "Gene_A",
  ,
  ,
  drop = FALSE
]
dim(one_gene_array)
```

    ## [1] 1 4 2

Its dimensions are:

``` text
1 gene × 4 participants × 2 visits
```

This is particularly important when a filter leaves only one gene, one
participant, or one visit.

**Practical rule:** In functions or analysis pipelines expecting an
array, use `drop = FALSE` when subsetting could reduce a dimension to
length one.

------------------------------------------------------------------------

## 7.11 Modifying array values

Replace one cell:

``` r
expr["Gene_A", "P001", "Baseline"] <- 5.1
expr["Gene_A", "P001", "Baseline"]
```

    ## [1] 5.1

Replace an entire slice:

``` r
expr[, , "Baseline"] <- baseline
```

Replace values using a logical condition:

``` r
example <- array(c(1, 2, -999, 4, 5, 6, 7, 8), dim = c(2, 2, 2))
example[example == -999] <- NA
example
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]    1   NA
    ## [2,]    2    4
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]    5    7
    ## [2,]    6    8

We should only replace sentinel values such as `-999` after confirming
their meaning in the study codebook.

------------------------------------------------------------------------

## 7.12 Element-wise operations on arrays

Arrays of compatible dimensions can be added, subtracted, multiplied, or
divided element by element.

``` r
a <- array(1:8, dim = c(2, 2, 2))
b <- array(rep(2, 8), dim = c(2, 2, 2))

a + b
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]    3    5
    ## [2,]    4    6
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]    7    9
    ## [2,]    8   10

``` r
a - b
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]   -1    1
    ## [2,]    0    2
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]    3    5
    ## [2,]    4    6

``` r
a * b
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]    2    6
    ## [2,]    4    8
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]   10   14
    ## [2,]   12   16

``` r
a / b
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]  0.5  1.5
    ## [2,]  1.0  2.0
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]  2.5  3.5
    ## [2,]  3.0  4.0

Here `*` means element-wise multiplication, just as it did for matrices.

``` r
a * 10
```

    ## , , 1
    ## 
    ##      [,1] [,2]
    ## [1,]   10   30
    ## [2,]   20   40
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,]   50   70
    ## [2,]   60   80

``` r
a > 4
```

    ## , , 1
    ## 
    ##       [,1]  [,2]
    ## [1,] FALSE FALSE
    ## [2,] FALSE FALSE
    ## 
    ## , , 2
    ## 
    ##      [,1] [,2]
    ## [1,] TRUE TRUE
    ## [2,] TRUE TRUE

The logical comparison returns a logical array.

``` r
sum(a > 4)
```

    ## [1] 4

This counts elements satisfying the condition.

**Caution:** Matching dimensions do not guarantee matching scientific
identifiers. Two arrays can both have dimensions `3 × 4 × 2` while their
genes, participants, or visits appear in different orders.

------------------------------------------------------------------------

## 7.13 Longitudinal change: follow-up minus baseline

For the expression array, calculate change for each gene and
participant:

$$\Delta_{g,p}=X_{g,p,\mathrm{Followup}}-
X_{g,p,\mathrm{Baseline}}.$$

``` r
change <- expr[, , "Followup"] - expr[, , "Baseline"]
change
```

    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A  0.5  0.5  0.5  0.5
    ##   Gene_B  0.5  0.5  0.5  0.5
    ##   Gene_C  0.5  0.5  0.5  0.5

``` r
dim(change)
```

    ## [1] 3 4

Because we selected one slice from each visit, the result is a
two-dimensional matrix:

``` text
genes × participants
```

We can inspect change for one gene:

``` r
change["Gene_A", ]
```

    ## P001 P002 P003 P004 
    ##  0.5  0.5  0.5  0.5

Or mean change for each gene:

``` r
rowMeans(change)
```

    ## Gene_A Gene_B Gene_C 
    ##    0.5    0.5    0.5

**Interpretation:** These are descriptive differences in the synthetic
teaching data. They are not estimates of a treatment effect, and no
causal conclusion follows from the subtraction alone.

------------------------------------------------------------------------

## 7.14 Summarizing arrays with `apply()`

In Chapter 6, we introduced `rowMeans()` and `colMeans()` for matrices.
For arrays with more dimensions, `apply()` is especially useful.

The syntax is:

``` r
apply(X, MARGIN, FUN, ...)
```

- `X`: the array;
- `MARGIN`: the dimension or dimensions to retain;
- `FUN`: the summary function;
- `...`: additional arguments passed to that function.

For our expression array:

``` text
dimension 1 = Gene
dimension 2 = Participant
dimension 3 = Visit
```

### Keep dimension 1: one result per gene

``` r
mean_by_gene <- apply(expr, 1, mean)
mean_by_gene
```

    ## Gene_A Gene_B Gene_C 
    ##   5.55   7.55   3.55

R averages across participants and visits, leaving one value per gene.

### Keep dimension 2: one result per participant

``` r
mean_by_participant <- apply(expr, 2, mean)
mean_by_participant
```

    ## P001 P002 P003 P004 
    ## 5.25 5.45 5.65 5.85

This is a programming example. Averaging unrelated genes may not be a
meaningful biological summary.

### Keep dimension 3: one result per visit

``` r
mean_by_visit <- apply(expr, 3, mean)
mean_by_visit
```

    ## Baseline Followup 
    ##      5.3      5.8

### Keep dimensions 1 and 3

``` r
mean_gene_visit <- apply(expr, c(1, 3), mean)
mean_gene_visit
```

    ##         Visit
    ## Gene     Baseline Followup
    ##   Gene_A      5.3      5.8
    ##   Gene_B      7.3      7.8
    ##   Gene_C      3.3      3.8

This produces a matrix of:

``` text
genes × visits
```

Each cell is the mean across participants.

### Keep dimensions 2 and 3

``` r
mean_participant_visit <- apply(expr, c(2, 3), mean)
mean_participant_visit
```

    ##            Visit
    ## Participant Baseline Followup
    ##        P001      5.0      5.5
    ##        P002      5.2      5.7
    ##        P003      5.4      5.9
    ##        P004      5.6      6.1

This averages across genes, leaving participant × visit.

### Keep dimensions 1 and 2

``` r
mean_gene_participant <- apply(expr, c(1, 2), mean)
mean_gene_participant
```

    ##         Participant
    ## Gene     P001 P002 P003 P004
    ##   Gene_A 5.25 5.45 5.65 5.85
    ##   Gene_B 7.25 7.45 7.65 7.85
    ##   Gene_C 3.25 3.45 3.65 3.85

This averages across visits.

**The crucial idea:** `MARGIN` identifies the dimensions **we keep**,
not the dimensions we remove.

------------------------------------------------------------------------

## 7.15 Understanding `apply()` with a hand calculation

Suppose a small array has two genes, two participants, and two visits:

``` r
toy <- array(
  1:8,
  dim = c(2, 2, 2),
  dimnames = list(
    Gene = c("G1", "G2"),
    Participant = c("P1", "P2"),
    Visit = c("T0", "T1")
  )
)
toy
```

    ## , , Visit = T0
    ## 
    ##     Participant
    ## Gene P1 P2
    ##   G1  1  3
    ##   G2  2  4
    ## 
    ## , , Visit = T1
    ## 
    ##     Participant
    ## Gene P1 P2
    ##   G1  5  7
    ##   G2  6  8

For G1, the four measurements are:

``` r
toy["G1", , ]
```

    ##            Visit
    ## Participant T0 T1
    ##          P1  1  5
    ##          P2  3  7

The mean is:

$$\overline{x}_{G1}=\frac{1+3+5+7}{4}=4.$$

Check:

``` r
mean(toy["G1", , ])
```

    ## [1] 4

``` r
apply(toy, 1, mean)
```

    ## G1 G2 
    ##  4  5

For G2, the four values are 2, 4, 6, and 8, so the mean is 5.

------------------------------------------------------------------------

## 7.16 `apply()` and output shape

The shape of an `apply()` result depends on the retained dimensions and
on the output of the function.

``` r
dim(apply(expr, c(1, 3), mean))
```

    ## [1] 3 2

``` r
length(apply(expr, 1, mean))
```

    ## [1] 3

When `FUN` returns a single value for each group, the output is often a
vector or matrix. More complicated return values may be simplified
differently.

We should inspect:

``` r
str(result)
dim(result)
```

rather than assuming an output has a particular structure.

------------------------------------------------------------------------

## 7.17 Missing data in arrays

Introduce missing expression measurements:

``` r
expr_missing <- expr
expr_missing["Gene_A", "P002", "Baseline"] <- NA
expr_missing["Gene_C", "P004", "Followup"] <- NA

sum(is.na(expr_missing))
```

    ## [1] 2

``` r
which(is.na(expr_missing), arr.ind = TRUE)
```

    ##        Gene Participant Visit
    ## Gene_A    1           2     1
    ## Gene_C    3           4     2

`is.na()` produces a logical array with the same dimensions.

### Why missing values affect summaries

``` r
apply(expr_missing, 1, mean)
```

    ## Gene_A Gene_B Gene_C 
    ##     NA   7.55     NA

Any gene with a missing measurement may have an `NA` mean unless missing
values are removed.

``` r
apply(expr_missing, 1, mean, na.rm = TRUE)
```

    ##   Gene_A   Gene_B   Gene_C 
    ## 5.600000 7.550000 3.471429

This calculates means from observed measurements only.

**Scientific caution:** `na.rm = TRUE` changes the denominator. It does
not solve the statistical problems that missingness may create.

### All-missing groups

``` r
all_missing <- array(
  c(NA_real_, NA_real_, 1, 2),
  dim = c(2, 1, 2)
)
apply(all_missing, 1, mean, na.rm = TRUE)
```

    ## [1] 1 2

If a group contains no observed measurements, `mean(..., na.rm = TRUE)`
returns `NaN`. This requires explicit handling in real analyses.

------------------------------------------------------------------------

## 7.18 Missingness by gene, participant, and visit

The total number of missing cells is:

``` r
sum(is.na(expr_missing))
```

    ## [1] 2

### Missing cells per gene

``` r
apply(is.na(expr_missing), 1, sum)
```

    ## Gene_A Gene_B Gene_C 
    ##      1      0      1

### Missing cells per participant

``` r
apply(is.na(expr_missing), 2, sum)
```

    ## P001 P002 P003 P004 
    ##    0    1    0    1

### Missing cells per visit

``` r
apply(is.na(expr_missing), 3, sum)
```

    ## Baseline Followup 
    ##        1        1

### Missingness per gene and visit

``` r
missing_gene_visit <- apply(
  is.na(expr_missing),
  c(1, 3),
  sum
)
missing_gene_visit
```

    ##         Visit
    ## Gene     Baseline Followup
    ##   Gene_A        1        0
    ##   Gene_B        0        0
    ##   Gene_C        0        1

The denominator is the number of participants:

``` r
missing_gene_visit / dim(expr_missing)[2]
```

    ##         Visit
    ## Gene     Baseline Followup
    ##   Gene_A     0.25     0.00
    ##   Gene_B     0.00     0.00
    ##   Gene_C     0.00     0.25

### Missingness per participant and visit

``` r
missing_participant_visit <- apply(
  is.na(expr_missing),
  c(2, 3),
  sum
)
missing_participant_visit / dim(expr_missing)[1]
```

    ##            Visit
    ## Participant  Baseline  Followup
    ##        P001 0.0000000 0.0000000
    ##        P002 0.3333333 0.0000000
    ##        P003 0.0000000 0.0000000
    ##        P004 0.0000000 0.3333333

Here the denominator is the number of genes.

These are basic array-level quality-control calculations.

------------------------------------------------------------------------

## 7.19 Using `which(..., arr.ind = TRUE)`

We may need the exact coordinates of missing or unusual measurements.

``` r
which(is.na(expr_missing), arr.ind = TRUE)
```

    ##        Gene Participant Visit
    ## Gene_A    1           2     1
    ## Gene_C    3           4     2

For a named array, the output identifies indices for gene, participant,
and visit.

To identify expression measurements above a demonstration threshold:

``` r
which(expr > 7.5, arr.ind = TRUE)
```

    ##        Gene Participant Visit
    ## Gene_B    2           4     1
    ## Gene_B    2           2     2
    ## Gene_B    2           3     2
    ## Gene_B    2           4     2

A numerical threshold is only a programming example; real biological
thresholds depend on assay properties and scientific context.

------------------------------------------------------------------------

## 7.20 Reordering dimensions with `aperm()`

Sometimes a tool expects a different dimension order.

Our array is:

``` text
Gene × Participant × Visit
```

Suppose we need:

``` text
Participant × Gene × Visit
```

Use `aperm()`:

``` r
expr_reordered <- aperm(expr, c(2, 1, 3))
dim(expr_reordered)
```

    ## [1] 4 3 2

``` r
names(dimnames(expr_reordered))
```

    ## [1] "Participant" "Gene"        "Visit"

The permutation:

``` text
c(2, 1, 3)
```

means:

- new dimension 1 comes from old dimension 2;
- new dimension 2 comes from old dimension 1;
- new dimension 3 comes from old dimension 3.

Verify a measurement:

``` r
expr["Gene_B", "P003", "Followup"]
```

    ## [1] 7.9

``` r
expr_reordered["P003", "Gene_B", "Followup"]
```

    ## [1] 7.9

Both selections should return the same value.

### Another dimension order

Change to:

``` text
Visit × Participant × Gene
```

``` r
expr_visit_first <- aperm(expr, c(3, 2, 1))
dim(expr_visit_first)
```

    ## [1] 2 4 3

``` r
names(dimnames(expr_visit_first))
```

    ## [1] "Visit"       "Participant" "Gene"

`aperm()` reorders dimensions while preserving the association between
measurements and their coordinates.

------------------------------------------------------------------------

## 7.21 Why changing `dim()` is not the same as `aperm()`

A common error is to change dimensions without moving the values
appropriately.

``` r
toy <- array(1:8, dim = c(2, 2, 2))
permuted <- aperm(toy, c(2, 1, 3))

reshaped <- toy
dim(reshaped) <- c(2, 2, 2)
```

The last assignment leaves the data ordering unchanged. It does **not**
swap the first two dimensions.

Compare:

``` r
permuted[, , 1]
```

    ##      [,1] [,2]
    ## [1,]    1    2
    ## [2,]    3    4

``` r
reshaped[, , 1]
```

    ##      [,1] [,2]
    ## [1,]    1    3
    ## [2,]    2    4

The lesson is broader than this small example:

> **Changing dimension sizes or labels does not automatically reorder
> observations.**

When we need to exchange axes, `aperm()` is the appropriate operation.

------------------------------------------------------------------------

## 7.22 Creating a four-dimensional array

Suppose a synthetic imaging study has:

``` text
x coordinate × y coordinate × slice × participant
```

We can create a four-dimensional array:

``` r
image_data <- array(
  seq_len(4 * 5 * 3 * 2),
  dim = c(4, 5, 3, 2),
  dimnames = list(
    X = paste0("X", 1:4),
    Y = paste0("Y", 1:5),
    Slice = paste0("Z", 1:3),
    Participant = c("P001", "P002")
  )
)
dim(image_data)
```

    ## [1] 4 5 3 2

``` r
length(image_data)
```

    ## [1] 120

This object contains:

$$4\times5\times3\times2=120$$

values.

### Select one image slice for one participant

``` r
image_data[, , "Z2", "P001"]
```

    ##     Y
    ## X    Y1 Y2 Y3 Y4 Y5
    ##   X1 21 25 29 33 37
    ##   X2 22 26 30 34 38
    ##   X3 23 27 31 35 39
    ##   X4 24 28 32 36 40

The result is a two-dimensional matrix.

### Preserve all four dimensions

``` r
image_data[
  ,
  ,
  "Z2",
  "P001",
  drop = FALSE
] |> dim()
```

    ## [1] 4 5 1 1

This example uses a small array for teaching. Real imaging data may be
extremely large and require specialized formats and software.

------------------------------------------------------------------------

## 7.23 Genomics example: genotype dosages across time

Genotypes inherited at a locus ordinarily do not change between visits,
so **time is not normally a biological dimension of germline genotype
dosage**. Instead, repeated genotype measurements might reflect
technical replicates, different assays, or QC runs.

A better example for an array is:

``` text
Variant × Participant × Assay run
```

``` r
geno <- array(
  NA_real_,
  dim = c(3, 4, 2),
  dimnames = list(
    Variant = c("rs1001", "rs1002", "rs1003"),
    Participant = c("P001", "P002", "P003", "P004"),
    Run = c("Run1", "Run2")
  )
)

run1 <- matrix(
  c(
    0, 1, 2, 1,
    1, 1, 0, 2,
    2, 0, 1, 1
  ),
  nrow = 3,
  byrow = TRUE
)

run2 <- run1
run2[2, 3] <- NA

geno[, , "Run1"] <- run1
geno[, , "Run2"] <- run2
geno
```

    ## , , Run = Run1
    ## 
    ##         Participant
    ## Variant  P001 P002 P003 P004
    ##   rs1001    0    1    2    1
    ##   rs1002    1    1    0    2
    ##   rs1003    2    0    1    1
    ## 
    ## , , Run = Run2
    ## 
    ##         Participant
    ## Variant  P001 P002 P003 P004
    ##   rs1001    0    1    2    1
    ##   rs1002    1    1   NA    2
    ##   rs1003    2    0    1    1

### Comparing assay runs

``` r
same_dosage <- geno[, , "Run1"] == geno[, , "Run2"]
same_dosage
```

    ##         Participant
    ## Variant  P001 P002 P003 P004
    ##   rs1001 TRUE TRUE TRUE TRUE
    ##   rs1002 TRUE TRUE   NA TRUE
    ##   rs1003 TRUE TRUE TRUE TRUE

Missing values yield `NA` in comparisons.

Count observed disagreements:

``` r
sum(!same_dosage, na.rm = TRUE)
```

    ## [1] 0

Count positions that cannot be compared:

``` r
sum(is.na(same_dosage))
```

    ## [1] 1

We should distinguish technical missingness from a genuine disagreement
between observed genotype calls.

------------------------------------------------------------------------

## 7.24 A second genomics example: expression across tissues

A three-dimensional structure might represent:

``` text
Gene × Sample × Tissue
```

However, this is only appropriate if the sample axis has a coherent
meaning across tissues. If different tissues have unrelated sample sets
or different sample counts, a single rectangular array may require
padding with many missing values or may be unsuitable.

For matched samples across tissues, an array can be convenient:

``` r
tissue_expr <- array(
  c(
    5.0, 6.0, 7.0, 8.0,
    5.5, 6.5, 7.5, 8.5
  ),
  dim = c(2, 2, 2),
  dimnames = list(
    Gene = c("Gene_A", "Gene_B"),
    Sample = c("P001", "P002"),
    Tissue = c("Cortex", "Blood")
  )
)
tissue_expr
```

    ## , , Tissue = Cortex
    ## 
    ##         Sample
    ## Gene     P001 P002
    ##   Gene_A    5    7
    ##   Gene_B    6    8
    ## 
    ## , , Tissue = Blood
    ## 
    ##         Sample
    ## Gene     P001 P002
    ##   Gene_A  5.5  7.5
    ##   Gene_B  6.5  8.5

Check the intended measurement-to-label mapping before using a vector to
fill an array. For complex imports, explicitly filling named slices is
safer.

### Compare tissue measurements

``` r
tissue_expr[, , "Cortex"]
```

    ##         Sample
    ## Gene     P001 P002
    ##   Gene_A    5    7
    ##   Gene_B    6    8

``` r
tissue_expr[, , "Blood"]
```

    ##         Sample
    ## Gene     P001 P002
    ##   Gene_A  5.5  7.5
    ##   Gene_B  6.5  8.5

This is a structural example, not an assumption that brain and blood
expression values are directly comparable without normalization and
study-specific considerations.

------------------------------------------------------------------------

## 7.25 Array alignment: a critical research problem

Two arrays can have identical dimensions but different participant
orders.

``` r
a1 <- array(
  1:8,
  dim = c(2, 2, 2),
  dimnames = list(
    Gene = c("G1", "G2"),
    Participant = c("P001", "P002"),
    Visit = c("T0", "T1")
  )
)

a2 <- a1[, c("P002", "P001"), , drop = FALSE]
```

The dimensions match:

``` r
identical(dim(a1), dim(a2))
```

    ## [1] TRUE

But the participant orders do not:

``` r
identical(
  dimnames(a1)[[2]],
  dimnames(a2)[[2]]
)
```

    ## [1] FALSE

Blindly subtracting `a2 - a1` would compare different participants by
position.

### Align by identifiers first

``` r
a2_aligned <- a2[
  ,
  dimnames(a1)[[2]],
  ,
  drop = FALSE
]

identical(dimnames(a1), dimnames(a2_aligned))
```

    ## [1] TRUE

``` r
all(a1 == a2_aligned)
```

    ## [1] TRUE

This is a central lesson for biomedical and genomic data integration:

> **Dimension equality is not sufficient; the identifiers and their
> order must also agree.**

------------------------------------------------------------------------

## 7.26 Validating an array before analysis

For a gene × participant × visit array, useful checks include:

``` r
stopifnot(is.array(expr))
stopifnot(length(dim(expr)) == 3)
stopifnot(identical(
  names(dimnames(expr)),
  c("Gene", "Participant", "Visit")
))
stopifnot(!anyDuplicated(dimnames(expr)[[1]]))
stopifnot(!anyDuplicated(dimnames(expr)[[2]]))
stopifnot(!anyDuplicated(dimnames(expr)[[3]]))
```

We can also check that values are numeric:

``` r
stopifnot(is.numeric(expr))
```

And verify that baseline and follow-up labels exist:

``` r
stopifnot(all(c("Baseline", "Followup") %in% dimnames(expr)[[3]]))
```

These checks make analytical assumptions explicit.

------------------------------------------------------------------------

## 7.27 Memory considerations

Arrays store every cell of a rectangular grid, including missing cells.

A numeric double-precision array requires approximately 8 bytes per
element for its numeric payload, excluding attributes and other
overhead.

For example, a hypothetical array of:

``` text
20,000 genes × 1,000 samples × 5 time points
```

contains:

$$20{,}000\times1{,}000\times5
=100{,}000{,}000$$

elements.

The numeric payload alone would be approximately:

$$100{,}000{,}000\times8
=800{,}000{,}000\text{ bytes}$$

or about 763 MiB.

Additional copies created by operations can increase memory usage
substantially. For large genomic or imaging data, specialized on-disk
and sparse representations may be more appropriate. We will discuss
large-data workflows in later chapters.

------------------------------------------------------------------------

## 7.28 When arrays are appropriate

Arrays are particularly useful when:

- the same set of measurements is observed across several aligned
  dimensions;
- every cell has the same underlying type;
- dimension names can be defined consistently;
- operations naturally apply across one or more dimensions.

Examples include longitudinal biomarker measurements, repeated assay
runs, matched multi-tissue measurements, and small imaging datasets.

Arrays are less convenient when:

- different variables require different types;
- groups have different numbers of observations;
- dimensions do not form a regular rectangular grid;
- most possible combinations are absent;
- data are too large for an in-memory dense representation.

In these situations, lists, data frames, or specialized scientific
structures may be more suitable.

------------------------------------------------------------------------

## 7.29 Common mistakes and corrections

### Mistake 1: assuming an array must be three-dimensional

`array()` supports one, two, three, four, or more dimensions. A matrix
is a two-dimensional array.

### Mistake 2: misunderstanding filling order

R fills the first dimension fastest. A long input vector must be ordered
consistently with `dim`.

### Mistake 3: treating labels as decoration

Incorrect dimension names can silently misidentify measurements. Labels
must match the data ordering.

### Mistake 4: losing dimensions after subsetting

``` r
expr["Gene_A", , ]
```

may return a matrix. To retain all three dimensions:

``` r
expr["Gene_A", , , drop = FALSE]
```

### Mistake 5: misinterpreting `apply()` margins

`apply(expr, c(1, 3), mean)` **keeps** gene and visit, averaging over
participants.

### Mistake 6: assuming `na.rm = TRUE` fixes missing-data problems

It excludes missing values from the arithmetic calculation but does not
address bias, missingness mechanisms, or the study design.

### Mistake 7: confusing `aperm()` with changing `dim`

`aperm()` reorders axes. Changing `dim` alone reinterprets the same
linear storage order.

### Mistake 8: ignoring identifier alignment

Arrays with equal dimensions can contain participants or genes in
different orders. Align by identifiers before comparing or combining
them.

### Mistake 9: creating an array for irregular data

Not every dataset naturally forms a complete rectangular grid.

### Mistake 10: assuming all numerical averages are scientifically meaningful

Averaging across genes, assays, or biomarkers can be mathematically
valid but scientifically inappropriate when measurements have different
scales or meanings.

------------------------------------------------------------------------

## 7.30 Guided practical: repeated biomarker measurements

We will create a small array representing:

``` text
Biomarker × Participant × Visit
```

### Step 1: define the structure

``` r
biomarker <- array(
  NA_real_,
  dim = c(2, 3, 3),
  dimnames = list(
    Biomarker = c("CRP", "IL6"),
    Participant = c("P001", "P002", "P003"),
    Visit = c("Day0", "Day30", "Day60")
  )
)
```

### Step 2: enter each visit’s measurements

``` r
biomarker[, , "Day0"] <- matrix(
  c(
    4.5, 5.0, 4.8,
    2.0, 2.2, 2.1
  ),
  nrow = 2,
  byrow = TRUE
)

biomarker[, , "Day30"] <- matrix(
  c(
    4.0, 4.7, 4.5,
    1.9, 2.1, 2.0
  ),
  nrow = 2,
  byrow = TRUE
)

biomarker[, , "Day60"] <- matrix(
  c(
    3.8, 4.3, 4.2,
    1.8, 1.9, 1.9
  ),
  nrow = 2,
  byrow = TRUE
)

biomarker
```

    ## , , Visit = Day0
    ## 
    ##          Participant
    ## Biomarker P001 P002 P003
    ##       CRP  4.5  5.0  4.8
    ##       IL6  2.0  2.2  2.1
    ## 
    ## , , Visit = Day30
    ## 
    ##          Participant
    ## Biomarker P001 P002 P003
    ##       CRP  4.0  4.7  4.5
    ##       IL6  1.9  2.1  2.0
    ## 
    ## , , Visit = Day60
    ## 
    ##          Participant
    ## Biomarker P001 P002 P003
    ##       CRP  3.8  4.3  4.2
    ##       IL6  1.8  1.9  1.9

### Step 3: inspect the dimensions

``` r
dim(biomarker)
```

    ## [1] 2 3 3

``` r
dimnames(biomarker)
```

    ## $Biomarker
    ## [1] "CRP" "IL6"
    ## 
    ## $Participant
    ## [1] "P001" "P002" "P003"
    ## 
    ## $Visit
    ## [1] "Day0"  "Day30" "Day60"

### Step 4: inspect CRP for participant P002 across visits

``` r
biomarker["CRP", "P002", ]
```

    ##  Day0 Day30 Day60 
    ##   5.0   4.7   4.3

### Step 5: calculate average CRP and IL6 by visit

``` r
apply(biomarker, c(1, 3), mean)
```

    ##          Visit
    ## Biomarker     Day0 Day30    Day60
    ##       CRP 4.766667   4.4 4.100000
    ##       IL6 2.100000   2.0 1.866667

### Step 6: calculate Day60 minus Day0

``` r
change_60 <- biomarker[, , "Day60"] -
  biomarker[, , "Day0"]

change_60
```

    ##          Participant
    ## Biomarker P001 P002 P003
    ##       CRP -0.7 -0.7 -0.6
    ##       IL6 -0.2 -0.3 -0.2

### Step 7: calculate mean change per biomarker

``` r
rowMeans(change_60)
```

    ##        CRP        IL6 
    ## -0.6666667 -0.2333333

These are descriptive changes in synthetic measurements; we are not
making treatment-effect claims.

### Step 8: introduce missingness and audit it

``` r
biomarker_missing <- biomarker
biomarker_missing["IL6", "P003", "Day30"] <- NA

sum(is.na(biomarker_missing))
```

    ## [1] 1

``` r
which(is.na(biomarker_missing), arr.ind = TRUE)
```

    ##     Biomarker Participant Visit
    ## IL6         2           3     2

``` r
apply(is.na(biomarker_missing), 3, sum)
```

    ##  Day0 Day30 Day60 
    ##     0     1     0

### Step 9: preserve array structure when selecting one biomarker

``` r
crp_array <- biomarker[
  "CRP",
  ,
  ,
  drop = FALSE
]

dim(crp_array)
```

    ## [1] 1 3 3

------------------------------------------------------------------------

## 7.31 Independent exercises

Use the following array:

``` r
practice <- array(
  NA_real_,
  dim = c(3, 4, 2),
  dimnames = list(
    Marker = c("A", "B", "C"),
    Patient = c("P1", "P2", "P3", "P4"),
    Visit = c("V1", "V2")
  )
)

practice[, , "V1"] <- matrix(
  c(
    10, 12, 11, 13,
    20, 21, 19, 22,
    30, 32, 31, 33
  ),
  nrow = 3,
  byrow = TRUE
)

practice[, , "V2"] <- matrix(
  c(
    11, 13, 12, 14,
    18, 20, 18, 21,
    31, 34, 32, 35
  ),
  nrow = 3,
  byrow = TRUE
)
```

Complete these tasks independently:

1.  Display the array and its dimensions.
2.  Verify the total number of elements.
3.  Identify the names of all three dimensions.
4.  Extract Marker B for Patient P3 at Visit V2.
5.  Extract all markers for Patient P2 at Visit V1.
6.  Extract Marker C across all patients and visits.
7.  Preserve Marker C as a three-dimensional array.
8.  Calculate the mean of each marker across all patients and visits.
9.  Calculate the mean of each marker separately at V1 and V2.
10. Calculate V2 minus V1 for every marker and patient.
11. Calculate mean change for each marker.
12. Count values above 25 in the entire array.
13. Count values above 25 separately by visit.
14. Replace Marker A for Patient P4 at V1 with `NA`.
15. Count missing values by marker and by visit.
16. Reorder dimensions to `Patient × Marker × Visit`.
17. Verify that a selected measurement is unchanged after reordering.
18. Explain why `apply(practice, c(1, 3), mean)` averages over patients.

------------------------------------------------------------------------

## 7.32 Genomics challenge: assay concordance

Create a three-dimensional array:

``` r
g <- array(
  NA_real_,
  dim = c(3, 3, 2),
  dimnames = list(
    Variant = c("rs1", "rs2", "rs3"),
    Sample = c("S1", "S2", "S3"),
    Run = c("Run1", "Run2")
  )
)

g[, , "Run1"] <- matrix(
  c(
    0, 1, 2,
    1, 1, 0,
    2, 0, 1
  ),
  nrow = 3,
  byrow = TRUE
)

g[, , "Run2"] <- matrix(
  c(
    0, 1, 2,
    1, 2, 0,
    2, NA, 1
  ),
  nrow = 3,
  byrow = TRUE
)
```

Tasks:

1.  Identify the dimensions and scientific meaning of each axis.
2.  Extract the two runs for variant `rs2`.
3.  Identify all positions where observed calls disagree.
4.  Count disagreements excluding missing comparisons.
5.  Count comparisons that cannot be made because of missing data.
6.  Calculate the proportion of concordant calls among positions
    observed in both runs.
7.  Explain why a missing comparison must not automatically be
    classified as concordant or discordant.
8.  Reorder the array to `Sample × Variant × Run`.
9.  Verify that sample and variant labels remain aligned.

------------------------------------------------------------------------

## 7.33 Complete Chapter 7 practice script

The following script consolidates the main programming techniques. It is
intentionally not executed during knitting because the chapter already
runs the individual demonstrations.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 7: Arrays and Higher-Dimensional Data
# ============================================================

# 1. Create an array
x <- array(1:24, dim = c(3, 4, 2))
dim(x)
length(x)
is.array(x)

# 2. Create a named biomedical array
expr <- array(
  NA_real_,
  dim = c(3, 4, 2),
  dimnames = list(
    Gene = c("Gene_A", "Gene_B", "Gene_C"),
    Participant = c("P001", "P002", "P003", "P004"),
    Visit = c("Baseline", "Followup")
  )
)

baseline <- matrix(
  c(5.0, 5.2, 5.4, 5.6,
    7.0, 7.2, 7.4, 7.6,
    3.0, 3.2, 3.4, 3.6),
  nrow = 3,
  byrow = TRUE
)

followup <- baseline + 0.5

expr[, , "Baseline"] <- baseline
expr[, , "Followup"] <- followup

# 3. Index by names
expr["Gene_A", "P001", "Baseline"]
expr[, , "Followup"]
expr["Gene_A", , , drop = FALSE]

# 4. Calculate change
change <- expr[, , "Followup"] -
  expr[, , "Baseline"]
rowMeans(change)

# 5. Summaries by dimension
apply(expr, 1, mean)
apply(expr, 3, mean)
apply(expr, c(1, 3), mean)

# 6. Missingness
expr["Gene_C", "P004", "Followup"] <- NA
sum(is.na(expr))
which(is.na(expr), arr.ind = TRUE)
apply(is.na(expr), 1, sum)
apply(is.na(expr), 3, sum)
apply(expr, c(1, 3), mean, na.rm = TRUE)

# 7. Reorder axes
expr2 <- aperm(expr, c(2, 1, 3))
dim(expr2)
expr2["P001", "Gene_A", "Baseline"]

# 8. Validate identifiers
stopifnot(
  identical(
    names(dimnames(expr)),
    c("Gene", "Participant", "Visit")
  )
)
stopifnot(!anyDuplicated(dimnames(expr)[[2]]))

# 9. Four-dimensional imaging-style data
image_data <- array(
  seq_len(120),
  dim = c(4, 5, 3, 2)
)
dim(image_data)
image_data[, , 2, 1]
image_data[, , 2, 1, drop = FALSE]
```

------------------------------------------------------------------------

## 7.34 Essential functions

| Task                     | R syntax                          |
|--------------------------|-----------------------------------|
| Create array             | `array(data, dim = c(...))`       |
| Inspect dimensions       | `dim(x)`                          |
| Count elements           | `length(x)`                       |
| Verify array             | `is.array(x)`                     |
| Inspect labels           | `dimnames(x)`                     |
| Select cell              | `x[i, j, k]`                      |
| Select one slice         | `x[, , k]`                        |
| Preserve dimensions      | `x[i, , , drop = FALSE]`          |
| Summarize by dimensions  | `apply(x, MARGIN, FUN)`           |
| Count missing values     | `sum(is.na(x))`                   |
| Find missing coordinates | `which(is.na(x), arr.ind = TRUE)` |
| Reorder dimensions       | `aperm(x, c(2, 1, 3))`            |
| Validate assumptions     | `stopifnot(condition)`            |
| Inspect structure        | `str(x)`                          |
| Inspect atomic type      | `typeof(x)`                       |

------------------------------------------------------------------------

## 7.35 Chapter review

We should be able to explain:

1.  Why a matrix is a special case of an array.
2.  How a three-dimensional array differs from a two-dimensional matrix.
3.  How R fills array elements.
4.  How dimension names are assigned.
5.  Why names and order matter for scientific data.
6.  How to extract a cell, a slice, and a subarray.
7.  Why `drop = FALSE` is important.
8.  How `apply()` interprets `MARGIN`.
9.  How to calculate summaries across participants while retaining genes
    and visits.
10. How to count missing observations by dimension.
11. How to identify missing coordinates.
12. What `aperm()` does.
13. Why changing `dim()` does not necessarily reorder data correctly.
14. Why equal dimensions do not guarantee aligned observations.
15. When arrays are appropriate for biomedical or genomic data.
16. Why some research data should be represented with lists, data
    frames, or specialized structures instead.

## 7.36 Key takeaways

- An array is an atomic structure with one or more dimensions; matrices
  are two-dimensional arrays.
- The product of the dimensions equals the number of stored elements.
- R fills the first dimension fastest.
- Dimension names are essential for interpreting scientific arrays.
- Indexing uses one position per dimension.
- `drop = FALSE` prevents unintended simplification.
- `apply()` retains the dimensions specified by `MARGIN`.
- Missing-data summaries require attention to both numerators and
  denominators.
- `aperm()` changes the order of axes while preserving the
  data-coordinate relationship.
- Matching shapes are not sufficient for safe comparisons; identifiers
  must align.
- Arrays are best suited to regular, same-type, multidimensional data.

> **Before analyzing an array, we should be able to state what every
> dimension represents and verify that its labels match the underlying
> measurements.**

## 7.37 Looking ahead: Chapter 8 — Lists

Arrays are useful when values share one atomic type and fit a regular
multidimensional structure. But a biomedical analysis often produces
several different kinds of objects together:

``` text
Patient identifiers       → character vector
Clinical measurements     → numeric matrix
Model results             → numerical estimates
QC summary                → logical values
Study metadata            → character values
```

We need a structure that can hold these different objects together
without coercing them all to one type.

In **Chapter 8 — Lists**, we will learn how R stores collections of
heterogeneous objects, how to access nested elements, and why lists are
fundamental to statistical modeling and research workflows.
