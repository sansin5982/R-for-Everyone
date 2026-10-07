Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

# Matrices

In Chapter 4, we learned that a vector stores a one-dimensional
collection of values. In Chapter 5, we learned how factors represent
categorical variables.

We now move from one dimension to two dimensions.

Consider gene-expression measurements for three genes measured in four
samples:

``` text
          Sample1   Sample2   Sample3   Sample4
Gene1        5.2       4.8       5.6       5.1
Gene2        8.1       7.9       8.4       8.0
Gene3        2.4       2.7       2.5       2.6
```

The values are arranged in **rows** and **columns**.

In R, a rectangular two-dimensional collection of values of the same
basic type can be stored as a **matrix**.

Matrices are important in biomedical and genomic research because many
scientific datasets naturally have this structure:

- gene-expression matrices;
- genotype dosage matrices;
- correlation matrices;
- covariance matrices;
- distance matrices;
- numerical assay results;
- repeated measurements;
- linear algebra used in statistical models.

A central principle for this chapter is:

> **A matrix is a two-dimensional atomic structure: it has rows and
> columns, but its elements share a common underlying type.**

------------------------------------------------------------------------

## 6.1 Learning objectives

By the end of this chapter, we should be able to:

- explain what a matrix is;
- distinguish vectors from matrices;
- create matrices using `matrix()`;
- understand rows, columns, and dimensions;
- explain column-wise and row-wise filling;
- inspect matrices using `dim()`, `nrow()`, `ncol()`, and `str()`;
- add and inspect row and column names;
- extract individual cells;
- extract complete rows and columns;
- select multiple rows and columns;
- use logical conditions with matrices;
- modify matrix elements;
- construct matrices using `rbind()` and `cbind()`;
- understand matrix type coercion;
- distinguish element-wise multiplication from matrix multiplication;
- perform element-wise arithmetic;
- transpose matrices;
- calculate row-wise and column-wise summaries;
- handle missing values;
- understand `drop = FALSE`;
- identify duplicated rows or columns conceptually;
- use matrices for gene-expression and genotype-style data;
- recognize when a matrix is appropriate and when another data structure
  will eventually be preferable.

------------------------------------------------------------------------

# 6.2 From vectors to matrices

A vector is one-dimensional.

For example:

``` r
expression <- c(
  5.2,
  4.8,
  5.6,
  5.1
)

expression
```

    ## [1] 5.2 4.8 5.6 5.1

We can think of it as:

``` text
5.2   4.8   5.6   5.1
```

A matrix adds a second dimension.

For example:

``` text
          Sample1   Sample2
Gene1        5.2       4.8
Gene2        8.1       7.9
```

Now every value has two positions:

``` text
row position
column position
```

For example:

``` text
Gene2, Sample1
```

identifies the value:

``` text
8.1
```

------------------------------------------------------------------------

# 6.3 What is a matrix?

A matrix is a rectangular arrangement of values organized into:

``` text
rows × columns
```

For example:

``` text
1  2  3
4  5  6
```

has:

``` text
2 rows
3 columns
```

Therefore, its dimension is:

$$2 \times 3$$

In R:

``` r
m <- matrix(
  1:6,
  nrow = 2,
  ncol = 3
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

------------------------------------------------------------------------

# 6.4 Creating our first matrix

Use `matrix()`:

``` r
m <- matrix(
  1:6,
  nrow = 2,
  ncol = 3
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

The general structure is:

``` r
matrix(
  data,
  nrow = ...,
  ncol = ...
)
```

Here:

``` text
data  = values 1 through 6
nrow  = 2
ncol  = 3
```

------------------------------------------------------------------------

# 6.5 R fills matrices by columns by default

This is one of the first important matrix rules.

Run:

``` r
m <- matrix(
  1:6,
  nrow = 2,
  ncol = 3
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

R fills the first column first:

``` text
1
2
```

then the second:

``` text
3
4
```

then the third:

``` text
5
6
```

So the matrix is:

``` text
     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6
```

------------------------------------------------------------------------

# 6.6 Filling by rows

If we want:

``` text
1  2  3
4  5  6
```

we can use:

``` r
m_byrow <- matrix(
  1:6,
  nrow = 2,
  ncol = 3,
  byrow = TRUE
)

m_byrow
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6

The argument:

``` r
byrow = TRUE
```

tells R to fill rows first.

------------------------------------------------------------------------

# 6.7 Column-wise versus row-wise filling

Compare:

``` r
matrix(
  1:6,
  nrow = 2
)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

with:

``` r
matrix(
  1:6,
  nrow = 2,
  byrow = TRUE
)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6

The same six values are used, but their positions differ.

This matters scientifically because matrix position determines which
measurement belongs to which row and column.

------------------------------------------------------------------------

# 6.8 We do not always need both `nrow` and `ncol`

If the number of values is compatible, R can infer one dimension.

For example:

``` r
m <- matrix(
  1:12,
  nrow = 3
)

m
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    4    7   10
    ## [2,]    2    5    8   11
    ## [3,]    3    6    9   12

There are 12 values and 3 rows, so R creates:

$$12 / 3 = 4$$

columns.

Check:

``` r
dim(m)
```

    ## [1] 3 4

------------------------------------------------------------------------

# 6.9 Matrix dimensions

Use:

``` r
dim(m)
```

    ## [1] 3 4

The result gives:

``` text
number of rows
number of columns
```

For example:

``` r
m <- matrix(
  1:12,
  nrow = 3
)

dim(m)
```

    ## [1] 3 4

returns:

``` text
3 4
```

meaning:

``` text
3 rows × 4 columns
```

------------------------------------------------------------------------

# 6.10 `nrow()` and `ncol()`

We can inspect each dimension separately:

``` r
nrow(m)
```

    ## [1] 3

``` r
ncol(m)
```

    ## [1] 4

These are especially useful when validating scientific matrices.

For example:

``` text
500 genes × 100 samples
```

should have:

``` text
nrow = 500
ncol = 100
```

if genes are stored in rows and samples in columns.

------------------------------------------------------------------------

# 6.11 Matrix length

A matrix also has a total number of elements.

``` r
length(m)
```

    ## [1] 12

For a:

``` text
3 × 4
```

matrix:

$$3 \times 4 = 12$$

elements.

Therefore:

``` r
nrow(m) * ncol(m)
```

    ## [1] 12

should equal:

``` r
length(m)
```

    ## [1] 12

Check:

``` r
length(m) == nrow(m) * ncol(m)
```

    ## [1] TRUE

------------------------------------------------------------------------

# 6.12 Inspecting matrix structure

Use:

``` r
str(m)
```

    ##  int [1:3, 1:4] 1 2 3 4 5 6 7 8 9 10 ...

This provides information about:

- the underlying type;
- the dimensions;
- some stored values.

We can also inspect:

``` r
class(m)
```

    ## [1] "matrix" "array"

``` r
typeof(m)
```

    ## [1] "integer"

------------------------------------------------------------------------

# 6.13 A matrix is still atomic

Like the vectors studied earlier, a basic matrix has one common
underlying type.

Consider:

``` r
m_numeric <- matrix(
  c(
    1,
    2,
    3,
    4
  ),
  nrow = 2
)

typeof(m_numeric)
```

    ## [1] "double"

The matrix contains numerical values.

------------------------------------------------------------------------

# 6.14 Character matrices

Matrices can also contain character values.

``` r
alleles <- matrix(
  c(
    "A", "G",
    "C", "T",
    "G", "A"
  ),
  nrow = 3,
  byrow = TRUE
)

alleles
```

    ##      [,1] [,2]
    ## [1,] "A"  "G" 
    ## [2,] "C"  "T" 
    ## [3,] "G"  "A"

Inspect:

``` r
typeof(alleles)
```

    ## [1] "character"

The underlying type is character.

------------------------------------------------------------------------

# 6.15 Logical matrices

A matrix can contain logical values:

``` r
qc_pass <- matrix(
  c(
    TRUE, TRUE,
    FALSE, TRUE,
    TRUE, FALSE
  ),
  nrow = 3,
  byrow = TRUE
)

qc_pass
```

    ##       [,1]  [,2]
    ## [1,]  TRUE  TRUE
    ## [2,] FALSE  TRUE
    ## [3,]  TRUE FALSE

Such matrices can represent masks, quality-control states, or logical
conditions.

------------------------------------------------------------------------

# 6.16 Mixed types cause coercion

Suppose:

``` r
mixed <- matrix(
  c(
    10,
    20,
    "Missing",
    40
  ),
  nrow = 2
)

mixed
```

    ##      [,1] [,2]     
    ## [1,] "10" "Missing"
    ## [2,] "20" "40"

Inspect:

``` r
typeof(mixed)
```

    ## [1] "character"

Because `"Missing"` is character, the entire matrix becomes character.

This follows the same coercion principle we learned for vectors.

------------------------------------------------------------------------

# 6.17 Why coercion matters in research matrices

Suppose laboratory measurements are:

``` r
lab <- matrix(
  c(
    95,
    105,
    110,
    "Not measured"
  ),
  nrow = 2
)

typeof(lab)
```

    ## [1] "character"

The whole matrix becomes character.

Numerical calculations will no longer behave as intended.

For genuinely missing numerical measurements, we should normally use:

``` r
lab <- matrix(
  c(
    95,
    105,
    110,
    NA
  ),
  nrow = 2
)

typeof(lab)
```

    ## [1] "double"

Now the matrix remains numeric.

------------------------------------------------------------------------

# 6.18 Row names and column names

Scientific matrices become much easier to interpret when dimensions have
meaningful names.

Consider:

``` r
expression <- matrix(
  c(
    5.2, 4.8, 5.6, 5.1,
    8.1, 7.9, 8.4, 8.0,
    2.4, 2.7, 2.5, 2.6
  ),
  nrow = 3,
  byrow = TRUE
)

expression
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]  5.2  4.8  5.6  5.1
    ## [2,]  8.1  7.9  8.4  8.0
    ## [3,]  2.4  2.7  2.5  2.6

Add row names:

``` r
rownames(expression) <- c(
  "Gene1",
  "Gene2",
  "Gene3"
)
```

Add column names:

``` r
colnames(expression) <- c(
  "Sample1",
  "Sample2",
  "Sample3",
  "Sample4"
)

expression
```

    ##       Sample1 Sample2 Sample3 Sample4
    ## Gene1     5.2     4.8     5.6     5.1
    ## Gene2     8.1     7.9     8.4     8.0
    ## Gene3     2.4     2.7     2.5     2.6

------------------------------------------------------------------------

# 6.19 Inspecting row and column names

Use:

``` r
rownames(expression)
```

    ## [1] "Gene1" "Gene2" "Gene3"

``` r
colnames(expression)
```

    ## [1] "Sample1" "Sample2" "Sample3" "Sample4"

Together, these labels describe the scientific meaning of the two
dimensions.

------------------------------------------------------------------------

# 6.20 `dimnames()`

We can inspect both sets of names together:

``` r
dimnames(expression)
```

    ## [[1]]
    ## [1] "Gene1" "Gene2" "Gene3"
    ## 
    ## [[2]]
    ## [1] "Sample1" "Sample2" "Sample3" "Sample4"

This returns the row-name and column-name components.

For beginner work, `rownames()` and `colnames()` are often easier to
read separately.

------------------------------------------------------------------------

# 6.21 Creating names during matrix construction

We can provide dimension names directly:

``` r
expression2 <- matrix(
  c(
    5.2, 4.8,
    8.1, 7.9,
    2.4, 2.7
  ),
  nrow = 3,
  byrow = TRUE,
  dimnames = list(
    c(
      "Gene1",
      "Gene2",
      "Gene3"
    ),
    c(
      "Sample1",
      "Sample2"
    )
  )
)

expression2
```

    ##       Sample1 Sample2
    ## Gene1     5.2     4.8
    ## Gene2     8.1     7.9
    ## Gene3     2.4     2.7

The first component of `dimnames` corresponds to rows.

The second corresponds to columns.

------------------------------------------------------------------------

# 6.22 Matrix indexing

Matrix indexing uses:

``` text
matrix[row, column]
```

This is fundamental.

Suppose:

``` r
m <- matrix(
  1:9,
  nrow = 3,
  byrow = TRUE
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9

To select:

``` text
row 2
column 3
```

use:

``` r
m[2, 3]
```

    ## [1] 6

------------------------------------------------------------------------

# 6.23 The comma matters

For matrices:

``` r
m[row, column]
```

The comma separates the two dimensions.

For example:

``` r
m[1, 2]
```

    ## [1] 2

means:

``` text
row 1, column 2
```

------------------------------------------------------------------------

# 6.24 Selecting an entire row

Leave the column position blank:

``` r
m[2, ]
```

    ## [1] 4 5 6

This means:

``` text
row 2
all columns
```

------------------------------------------------------------------------

# 6.25 Selecting an entire column

Leave the row position blank:

``` r
m[, 3]
```

    ## [1] 3 6 9

This means:

``` text
all rows
column 3
```

------------------------------------------------------------------------

# 6.26 Selecting multiple rows

``` r
m[c(1, 3), ]
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    7    8    9

This selects:

``` text
rows 1 and 3
all columns
```

------------------------------------------------------------------------

# 6.27 Selecting multiple columns

``` r
m[, c(1, 3)]
```

    ##      [,1] [,2]
    ## [1,]    1    3
    ## [2,]    4    6
    ## [3,]    7    9

This selects:

``` text
all rows
columns 1 and 3
```

------------------------------------------------------------------------

# 6.28 Selecting a submatrix

``` r
m[c(1, 3), c(2, 3)]
```

    ##      [,1] [,2]
    ## [1,]    2    3
    ## [2,]    8    9

This selects:

``` text
rows 1 and 3
columns 2 and 3
```

The result is a smaller matrix.

------------------------------------------------------------------------

# 6.29 Negative indexing

As with vectors, negative indices exclude positions.

Exclude row 2:

``` r
m[-2, ]
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    7    8    9

Exclude column 1:

``` r
m[, -1]
```

    ##      [,1] [,2]
    ## [1,]    2    3
    ## [2,]    5    6
    ## [3,]    8    9

Exclude multiple columns:

``` r
m[, -c(1, 3)]
```

    ## [1] 2 5 8

------------------------------------------------------------------------

# 6.30 Indexing by row names

Using our expression matrix:

``` r
expression["Gene2", ]
```

    ## Sample1 Sample2 Sample3 Sample4 
    ##     8.1     7.9     8.4     8.0

This returns all measurements for `Gene2`.

------------------------------------------------------------------------

# 6.31 Indexing by column names

``` r
expression[, "Sample3"]
```

    ## Gene1 Gene2 Gene3 
    ##   5.6   8.4   2.5

This returns measurements for all genes in `Sample3`.

------------------------------------------------------------------------

# 6.32 Selecting by both names

``` r
expression[
  "Gene2",
  "Sample3"
]
```

    ## [1] 8.4

This selects one specific gene-sample measurement.

------------------------------------------------------------------------

# 6.33 Selecting several named rows

``` r
expression[
  c(
    "Gene1",
    "Gene3"
  ),
  ]
```

    ##       Sample1 Sample2 Sample3 Sample4
    ## Gene1     5.2     4.8     5.6     5.1
    ## Gene3     2.4     2.7     2.5     2.6

This is often more interpretable than numeric positions.

------------------------------------------------------------------------

# 6.34 Selecting several named columns

``` r
expression[
  ,
  c(
    "Sample1",
    "Sample4"
  )
]
```

    ##       Sample1 Sample4
    ## Gene1     5.2     5.1
    ## Gene2     8.1     8.0
    ## Gene3     2.4     2.6

------------------------------------------------------------------------

# 6.35 A subtle issue: dimensions can be dropped

Suppose:

``` r
one_gene <- expression[
  "Gene1",
  ]
```

Check:

``` r
class(one_gene)
```

    ## [1] "numeric"

``` r
dim(one_gene)
```

    ## NULL

When a single row is selected, R often simplifies the result to a
vector.

This behavior is called **dropping dimensions**.

------------------------------------------------------------------------

# 6.36 Preserving matrix structure with `drop = FALSE`

If we want a one-row matrix rather than a vector:

``` r
one_gene_matrix <- expression[
  "Gene1",
  ,
  drop = FALSE
]

one_gene_matrix
```

    ##       Sample1 Sample2 Sample3 Sample4
    ## Gene1     5.2     4.8     5.6     5.1

Check:

``` r
class(one_gene_matrix)
```

    ## [1] "matrix" "array"

``` r
dim(one_gene_matrix)
```

    ## [1] 1 4

The result remains a matrix.

------------------------------------------------------------------------

# 6.37 Why `drop = FALSE` matters

Many analytical functions expect a matrix rather than a vector.

Suppose a pipeline normally processes:

``` text
many genes × many samples
```

but a filter leaves only one gene.

Without:

``` r
drop = FALSE
```

the object may unexpectedly become a vector and downstream code may
fail.

This is a common issue in matrix-based research workflows.

------------------------------------------------------------------------

# 6.38 Selecting one column while preserving matrix structure

Similarly:

``` r
one_sample_matrix <- expression[
  ,
  "Sample1",
  drop = FALSE
]

one_sample_matrix
```

    ##       Sample1
    ## Gene1     5.2
    ## Gene2     8.1
    ## Gene3     2.4

Check:

``` r
dim(one_sample_matrix)
```

    ## [1] 3 1

------------------------------------------------------------------------

# 6.39 Logical conditions on a matrix

Comparisons are vectorized across matrix elements.

``` r
expression > 5
```

    ##       Sample1 Sample2 Sample3 Sample4
    ## Gene1    TRUE   FALSE    TRUE    TRUE
    ## Gene2    TRUE    TRUE    TRUE    TRUE
    ## Gene3   FALSE   FALSE   FALSE   FALSE

R returns a logical matrix with the same dimensions.

Each cell answers:

``` text
Is this expression value greater than 5?
```

------------------------------------------------------------------------

# 6.40 Counting values satisfying a condition

``` r
sum(expression > 5)
```

    ## [1] 7

This counts all matrix cells with values greater than 5.

------------------------------------------------------------------------

# 6.41 Handling missing values in logical conditions

If a matrix contains `NA`:

``` r
lab <- matrix(
  c(
    95, 105, NA,
    110, 126, 99
  ),
  nrow = 2,
  byrow = TRUE
)

lab
```

    ##      [,1] [,2] [,3]
    ## [1,]   95  105   NA
    ## [2,]  110  126   99

Then:

``` r
lab >= 110
```

    ##       [,1]  [,2]  [,3]
    ## [1,] FALSE FALSE    NA
    ## [2,]  TRUE  TRUE FALSE

contains `NA` where the measurement is missing.

To count observed values meeting the condition:

``` r
sum(
  lab >= 110,
  na.rm = TRUE
)
```

    ## [1] 2

------------------------------------------------------------------------

# 6.42 Identifying missing matrix elements

``` r
is.na(lab)
```

    ##       [,1]  [,2]  [,3]
    ## [1,] FALSE FALSE  TRUE
    ## [2,] FALSE FALSE FALSE

This returns a logical matrix.

Count all missing cells:

``` r
sum(is.na(lab))
```

    ## [1] 1

------------------------------------------------------------------------

# 6.43 Positions of missing cells

Use:

``` r
which(
  is.na(lab)
)
```

    ## [1] 5

This gives linear positions.

For row and column coordinates, use:

``` r
which(
  is.na(lab),
  arr.ind = TRUE
)
```

    ##      row col
    ## [1,]   1   3

The argument:

``` r
arr.ind = TRUE
```

returns matrix-style row and column indices.

------------------------------------------------------------------------

# 6.44 Modifying one matrix element

Suppose:

``` r
m <- matrix(
  1:9,
  nrow = 3,
  byrow = TRUE
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6
    ## [3,]    7    8    9

Replace row 2, column 3:

``` r
m[2, 3] <- 99

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5   99
    ## [3,]    7    8    9

------------------------------------------------------------------------

# 6.45 Replacing values by condition

Suppose a confirmed invalid laboratory code is `-999`:

``` r
lab <- matrix(
  c(
    95, 105, -999,
    110, 126, 99
  ),
  nrow = 2,
  byrow = TRUE
)

lab
```

    ##      [,1] [,2] [,3]
    ## [1,]   95  105 -999
    ## [2,]  110  126   99

After confirming from the study codebook that `-999` means missing:

``` r
lab[
  lab == -999
] <- NA

lab
```

    ##      [,1] [,2] [,3]
    ## [1,]   95  105   NA
    ## [2,]  110  126   99

------------------------------------------------------------------------

# 6.46 Creating matrices with `rbind()`

`rbind()` means **row bind**.

Suppose:

``` r
gene1 <- c(
  5.2,
  4.8,
  5.6
)

gene2 <- c(
  8.1,
  7.9,
  8.4
)
```

Combine as rows:

``` r
expression <- rbind(
  gene1,
  gene2
)

expression
```

    ##       [,1] [,2] [,3]
    ## gene1  5.2  4.8  5.6
    ## gene2  8.1  7.9  8.4

Each vector becomes a row.

------------------------------------------------------------------------

# 6.47 Creating matrices with `cbind()`

`cbind()` means **column bind**.

Suppose:

``` r
sample1 <- c(
  5.2,
  8.1,
  2.4
)

sample2 <- c(
  4.8,
  7.9,
  2.7
)
```

Combine as columns:

``` r
expression <- cbind(
  sample1,
  sample2
)

expression
```

    ##      sample1 sample2
    ## [1,]     5.2     4.8
    ## [2,]     8.1     7.9
    ## [3,]     2.4     2.7

Each vector becomes a column.

------------------------------------------------------------------------

# 6.48 `rbind()` versus `cbind()`

Conceptually:

``` text
rbind()
vectors
  ↓
become rows
```

whereas:

``` text
cbind()
vectors
  ↓
become columns
```

The choice depends on the intended scientific orientation.

------------------------------------------------------------------------

# 6.49 Compatible lengths matter when binding

For `rbind()`, row vectors should normally have compatible lengths.

For `cbind()`, column vectors should normally have compatible lengths.

Unexpected recycling can occur with incompatible lengths, so we should
verify dimensions rather than assume that a successful command means the
data are scientifically aligned.

------------------------------------------------------------------------

# 6.50 Adding a row

Suppose:

``` r
m <- matrix(
  1:6,
  nrow = 2,
  byrow = TRUE
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6

Add:

``` r
new_row <- c(
  7,
  8,
  9
)

m2 <- rbind(
  m,
  new_row
)

m2
```

    ##         [,1] [,2] [,3]
    ##            1    2    3
    ##            4    5    6
    ## new_row    7    8    9

The new row must correspond meaningfully to the existing columns.

------------------------------------------------------------------------

# 6.51 Adding a column

``` r
new_column <- c(
  10,
  20
)

m3 <- cbind(
  m,
  new_column
)

m3
```

    ##            new_column
    ## [1,] 1 2 3         10
    ## [2,] 4 5 6         20

Again, the new values must correspond correctly to existing rows.

------------------------------------------------------------------------

# 6.52 Element-wise matrix arithmetic

Suppose:

``` r
baseline <- matrix(
  c(
    120, 130,
    140, 150
  ),
  nrow = 2,
  byrow = TRUE
)

followup <- matrix(
  c(
    115, 128,
    135, 145
  ),
  nrow = 2,
  byrow = TRUE
)
```

Calculate change:

``` r
change <- followup - baseline

change
```

    ##      [,1] [,2]
    ## [1,]   -5   -2
    ## [2,]   -5   -5

R subtracts corresponding cells.

------------------------------------------------------------------------

# 6.53 Addition and subtraction

For matrices with compatible dimensions:

``` r
baseline + followup
```

    ##      [,1] [,2]
    ## [1,]  235  258
    ## [2,]  275  295

``` r
baseline - followup
```

    ##      [,1] [,2]
    ## [1,]    5    2
    ## [2,]    5    5

Operations occur element by element.

The scientific interpretation depends on what the matrices represent.

------------------------------------------------------------------------

# 6.54 Multiplying every element by a constant

``` r
m <- matrix(
  1:6,
  nrow = 2
)

m * 10
```

    ##      [,1] [,2] [,3]
    ## [1,]   10   30   50
    ## [2,]   20   40   60

Every element is multiplied by 10.

Likewise:

``` r
m / 2
```

    ##      [,1] [,2] [,3]
    ## [1,]  0.5  1.5  2.5
    ## [2,]  1.0  2.0  3.0

``` r
m + 5
```

    ##      [,1] [,2] [,3]
    ## [1,]    6    8   10
    ## [2,]    7    9   11

``` r
m - 1
```

    ##      [,1] [,2] [,3]
    ## [1,]    0    2    4
    ## [2,]    1    3    5

are vectorized across the matrix.

------------------------------------------------------------------------

# 6.55 Element-wise multiplication

Consider:

``` r
A <- matrix(
  c(
    1, 2,
    3, 4
  ),
  nrow = 2,
  byrow = TRUE
)

B <- matrix(
  c(
    10, 20,
    30, 40
  ),
  nrow = 2,
  byrow = TRUE
)
```

Run:

``` r
A * B
```

    ##      [,1] [,2]
    ## [1,]   10   40
    ## [2,]   90  160

This performs **element-wise multiplication**:

$$\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}
*
\begin{bmatrix}
10 & 20 \\
30 & 40
\end{bmatrix}
=
\begin{bmatrix}
10 & 40 \\
90 & 160
\end{bmatrix}$$

------------------------------------------------------------------------

# 6.56 Matrix multiplication is different

R uses:

``` r
%*%
```

for matrix multiplication.

Run:

``` r
A %*% B
```

    ##      [,1] [,2]
    ## [1,]   70  100
    ## [2,]  150  220

This is not the same as:

``` r
A * B
```

    ##      [,1] [,2]
    ## [1,]   10   40
    ## [2,]   90  160

------------------------------------------------------------------------

# 6.57 Understanding matrix multiplication

If:

$$A =
\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}$$

and:

$$B =
\begin{bmatrix}
10 & 20 \\
30 & 40
\end{bmatrix}$$

then:

$$AB =
\begin{bmatrix}
(1)(10)+(2)(30) & (1)(20)+(2)(40) \\
(3)(10)+(4)(30) & (3)(20)+(4)(40)
\end{bmatrix}$$

Therefore:

$$AB =
\begin{bmatrix}
70 & 100 \\
150 & 220
\end{bmatrix}$$

Check in R:

``` r
A %*% B
```

    ##      [,1] [,2]
    ## [1,]   70  100
    ## [2,]  150  220

------------------------------------------------------------------------

# 6.58 Why `%*%` matters in statistics

Matrix multiplication appears throughout:

- linear regression;
- multivariate statistics;
- covariance calculations;
- principal component analysis;
- genomic prediction;
- mixed models;
- machine learning.

We do not need to master all of the underlying linear algebra yet.

At this stage, the essential distinction is:

``` text
*    → element-wise multiplication

%*%  → matrix multiplication
```

------------------------------------------------------------------------

# 6.59 Dimensions required for matrix multiplication

For:

$$A_{m \times n} B_{n \times p}$$

the inner dimensions must match:

``` text
columns of A = rows of B
```

The resulting matrix has dimension:

$$m \times p$$

For example:

``` text
A: 2 × 3
B: 3 × 4
```

can be multiplied:

``` text
A %*% B
```

and the result is:

``` text
2 × 4
```

------------------------------------------------------------------------

# 6.60 A dimension-compatible multiplication example

``` r
A <- matrix(
  1:6,
  nrow = 2,
  byrow = TRUE
)

B <- matrix(
  1:12,
  nrow = 3,
  byrow = TRUE
)

dim(A)
```

    ## [1] 2 3

``` r
dim(B)
```

    ## [1] 3 4

Here:

``` text
A = 2 × 3
B = 3 × 4
```

Therefore:

``` r
C <- A %*% B

C
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]   38   44   50   56
    ## [2,]   83   98  113  128

``` r
dim(C)
```

    ## [1] 2 4

The result is:

``` text
2 × 4
```

------------------------------------------------------------------------

# 6.61 Transposing a matrix

The transpose exchanges rows and columns.

Use:

``` r
m <- matrix(
  1:6,
  nrow = 2,
  byrow = TRUE
)

m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    2    3
    ## [2,]    4    5    6

Transpose:

``` r
t(m)
```

    ##      [,1] [,2]
    ## [1,]    1    4
    ## [2,]    2    5
    ## [3,]    3    6

If `m` has dimension:

``` text
2 × 3
```

then:

``` r
t(m)
```

has dimension:

``` text
3 × 2
```

------------------------------------------------------------------------

# 6.62 Why transposition is useful

Suppose an expression matrix is organized as:

``` text
genes × samples
```

but an analytical method expects:

``` text
samples × genes
```

Transposition changes the orientation:

``` r
expression_t <- t(expression)

expression_t
```

    ##         [,1] [,2] [,3]
    ## sample1  5.2  8.1  2.4
    ## sample2  4.8  7.9  2.7

Check:

``` r
dim(expression)
```

    ## [1] 3 2

``` r
dim(expression_t)
```

    ## [1] 2 3

------------------------------------------------------------------------

# 6.63 Row sums

Suppose:

``` r
counts <- matrix(
  c(
    10, 20, 30,
    5, 10, 15,
    100, 120, 110
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(counts) <- c(
  "Gene1",
  "Gene2",
  "Gene3"
)

colnames(counts) <- c(
  "Sample1",
  "Sample2",
  "Sample3"
)

counts
```

    ##       Sample1 Sample2 Sample3
    ## Gene1      10      20      30
    ## Gene2       5      10      15
    ## Gene3     100     120     110

Calculate row sums:

``` r
rowSums(counts)
```

    ## Gene1 Gene2 Gene3 
    ##    60    30   330

Each result summarizes one gene across samples.

------------------------------------------------------------------------

# 6.64 Column sums

``` r
colSums(counts)
```

    ## Sample1 Sample2 Sample3 
    ##     115     150     155

Each result summarizes one sample across genes.

The scientific interpretation depends on the matrix.

------------------------------------------------------------------------

# 6.65 Row means

``` r
rowMeans(counts)
```

    ## Gene1 Gene2 Gene3 
    ##    20    10   110

This calculates the mean across columns for each row.

For the current orientation:

``` text
one mean per gene
```

------------------------------------------------------------------------

# 6.66 Column means

``` r
colMeans(counts)
```

    ##  Sample1  Sample2  Sample3 
    ## 38.33333 50.00000 51.66667

This calculates:

``` text
one mean per sample
```

for the current matrix orientation.

------------------------------------------------------------------------

# 6.67 Missing values in row and column summaries

Suppose:

``` r
measurements <- matrix(
  c(
    10, 20, NA,
    5, NA, 15,
    100, 120, 110
  ),
  nrow = 3,
  byrow = TRUE
)

measurements
```

    ##      [,1] [,2] [,3]
    ## [1,]   10   20   NA
    ## [2,]    5   NA   15
    ## [3,]  100  120  110

Then:

``` r
rowMeans(measurements)
```

    ## [1]  NA  NA 110

contains missing results for rows containing `NA`.

Use:

``` r
rowMeans(
  measurements,
  na.rm = TRUE
)
```

    ## [1]  15  10 110

Similarly:

``` r
colMeans(
  measurements,
  na.rm = TRUE
)
```

    ## [1] 38.33333 70.00000 62.50000

------------------------------------------------------------------------

# 6.68 Counting missing values by row

`is.na()` returns a logical matrix.

Logical `TRUE` values can be counted.

Therefore:

``` r
rowSums(
  is.na(measurements)
)
```

    ## [1] 1 1 0

gives the number of missing values in each row.

------------------------------------------------------------------------

# 6.69 Counting missing values by column

``` r
colSums(
  is.na(measurements)
)
```

    ## [1] 0 1 1

This gives the number of missing observations in each column.

This pattern is extremely useful in quality control.

------------------------------------------------------------------------

# 6.70 Proportion missing by row

The number of missing cells per row is:

``` r
rowSums(
  is.na(measurements)
)
```

    ## [1] 1 1 0

The number of columns is:

``` r
ncol(measurements)
```

    ## [1] 3

Therefore:

``` r
rowSums(
  is.na(measurements)
) / ncol(measurements)
```

    ## [1] 0.3333333 0.3333333 0.0000000

gives the proportion missing for each row.

------------------------------------------------------------------------

# 6.71 Proportion missing by column

Similarly:

``` r
colSums(
  is.na(measurements)
) / nrow(measurements)
```

    ## [1] 0.0000000 0.3333333 0.3333333

gives the proportion missing for each column.

------------------------------------------------------------------------

# 6.72 `apply()` preview

R also has a general function called `apply()` for operating across
matrix margins.

For example:

``` r
apply(
  counts,
  1,
  mean
)
```

    ## Gene1 Gene2 Gene3 
    ##    20    10   110

calculates means across rows.

Here:

``` text
1 = rows
```

And:

``` r
apply(
  counts,
  2,
  mean
)
```

    ##  Sample1  Sample2  Sample3 
    ## 38.33333 50.00000 51.66667

calculates means across columns.

Here:

``` text
2 = columns
```

We will study the apply family formally in Chapter 13. For common sums
and means, specialized functions such as `rowSums()`, `colSums()`,
`rowMeans()`, and `colMeans()` are usually clearer.

------------------------------------------------------------------------

# 6.73 Minimum and maximum values

For the whole matrix:

``` r
min(counts)
```

    ## [1] 5

``` r
max(counts)
```

    ## [1] 120

``` r
range(counts)
```

    ## [1]   5 120

These treat all cells as a collection of numerical values.

------------------------------------------------------------------------

# 6.74 Position of the maximum value

``` r
which.max(counts)
```

    ## [1] 6

returns a linear position.

For matrix coordinates:

``` r
which(
  counts == max(counts),
  arr.ind = TRUE
)
```

    ##       row col
    ## Gene3   3   2

This identifies the row and column containing the maximum.

------------------------------------------------------------------------

# 6.75 Using row and column names with an extreme value

Suppose:

``` r
max_position <- which(
  counts == max(counts),
  arr.ind = TRUE
)

max_position
```

    ##       row col
    ## Gene3   3   2

We can retrieve the corresponding labels:

``` r
rownames(counts)[
  max_position[1, "row"]
]
```

    ## [1] "Gene3"

``` r
colnames(counts)[
  max_position[1, "col"]
]
```

    ## [1] "Sample2"

This links numerical matrix positions back to scientific identifiers.

------------------------------------------------------------------------

# 6.76 Matrix comparison

Suppose:

``` r
A <- matrix(
  c(
    1, 2,
    3, 4
  ),
  nrow = 2,
  byrow = TRUE
)

B <- matrix(
  c(
    1, 5,
    3, 8
  ),
  nrow = 2,
  byrow = TRUE
)
```

Compare:

``` r
A == B
```

    ##      [,1]  [,2]
    ## [1,] TRUE FALSE
    ## [2,] TRUE FALSE

The result is a logical matrix showing cell-by-cell equality.

------------------------------------------------------------------------

# 6.77 Testing whether all corresponding cells match

``` r
all(A == B)
```

    ## [1] FALSE

returns `FALSE`.

If matrices can contain missing values, comparisons require more care
because `NA` can propagate through logical expressions. We will revisit
robust data validation later.

------------------------------------------------------------------------

# 6.78 Gene-expression example

Consider a small expression matrix:

``` r
expression <- matrix(
  c(
    5.2, 4.8, 5.6, 5.1,
    8.1, 7.9, 8.4, 8.0,
    2.4, 2.7, 2.5, 2.6,
    6.8, 6.5, 7.0, 6.9
  ),
  nrow = 4,
  byrow = TRUE
)

rownames(expression) <- c(
  "C4A",
  "HLA_B",
  "BTN3A2",
  "HLA_DPA1"
)

colnames(expression) <- c(
  "Sample1",
  "Sample2",
  "Sample3",
  "Sample4"
)

expression
```

    ##          Sample1 Sample2 Sample3 Sample4
    ## C4A          5.2     4.8     5.6     5.1
    ## HLA_B        8.1     7.9     8.4     8.0
    ## BTN3A2       2.4     2.7     2.5     2.6
    ## HLA_DPA1     6.8     6.5     7.0     6.9

This matrix has:

``` text
rows    = genes
columns = samples
cells   = expression measurements
```

------------------------------------------------------------------------

# 6.79 Inspecting the expression matrix

``` r
dim(expression)
```

    ## [1] 4 4

``` r
nrow(expression)
```

    ## [1] 4

``` r
ncol(expression)
```

    ## [1] 4

``` r
rownames(expression)
```

    ## [1] "C4A"      "HLA_B"    "BTN3A2"   "HLA_DPA1"

``` r
colnames(expression)
```

    ## [1] "Sample1" "Sample2" "Sample3" "Sample4"

These checks establish the structure before analysis.

------------------------------------------------------------------------

# 6.80 Extracting one gene

``` r
expression[
  "C4A",
  ]
```

    ## Sample1 Sample2 Sample3 Sample4 
    ##     5.2     4.8     5.6     5.1

This returns expression values for `C4A` across all samples.

To preserve matrix structure:

``` r
expression[
  "C4A",
  ,
  drop = FALSE
]
```

    ##     Sample1 Sample2 Sample3 Sample4
    ## C4A     5.2     4.8     5.6     5.1

------------------------------------------------------------------------

# 6.81 Extracting one sample

``` r
expression[
  ,
  "Sample2"
]
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##      4.8      7.9      2.7      6.5

This returns all gene measurements for `Sample2`.

------------------------------------------------------------------------

# 6.82 Extracting selected genes and samples

``` r
expression[
  c(
    "C4A",
    "HLA_B"
  ),
  c(
    "Sample1",
    "Sample3"
  )
]
```

    ##       Sample1 Sample3
    ## C4A       5.2     5.6
    ## HLA_B     8.1     8.4

This creates a smaller submatrix.

------------------------------------------------------------------------

# 6.83 Mean expression per gene

``` r
rowMeans(expression)
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##    5.175    8.100    2.550    6.800

Because genes are rows, this calculates mean expression across samples
for each gene.

------------------------------------------------------------------------

# 6.84 Mean expression per sample

``` r
colMeans(expression)
```

    ## Sample1 Sample2 Sample3 Sample4 
    ##   5.625   5.475   5.875   5.650

Because samples are columns, this calculates mean expression across
genes for each sample.

This simple example emphasizes why matrix orientation matters.

------------------------------------------------------------------------

# 6.85 Identifying expression values above a threshold

For a programming example:

``` r
high_expression <- expression > 7

high_expression
```

    ##          Sample1 Sample2 Sample3 Sample4
    ## C4A        FALSE   FALSE   FALSE   FALSE
    ## HLA_B       TRUE    TRUE    TRUE    TRUE
    ## BTN3A2     FALSE   FALSE   FALSE   FALSE
    ## HLA_DPA1   FALSE   FALSE   FALSE   FALSE

Count:

``` r
sum(high_expression)
```

    ## [1] 4

This threshold is used only to demonstrate matrix operations; biological
interpretation would depend on the assay, normalization, tissue, and
analysis context.

------------------------------------------------------------------------

# 6.86 Counting threshold exceedances per gene

``` r
rowSums(
  expression > 7
)
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##        0        4        0        0

This tells us how many samples exceed the teaching threshold for each
gene.

------------------------------------------------------------------------

# 6.87 Counting threshold exceedances per sample

``` r
colSums(
  expression > 7
)
```

    ## Sample1 Sample2 Sample3 Sample4 
    ##       1       1       1       1

This tells us how many genes exceed the threshold in each sample.

------------------------------------------------------------------------

# 6.88 Genotype dosage matrix example

A common genomic representation places individuals in rows and variants
in columns.

For example:

``` r
dosage <- matrix(
  c(
    0, 1, 2, 0,
    1, 1, 0, 2,
    2, 0, 1, 1,
    0, 2, 2, 1,
    1, 0, 1, 0
  ),
  nrow = 5,
  byrow = TRUE
)

rownames(dosage) <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005"
)

colnames(dosage) <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004"
)

dosage
```

    ##      rs1001 rs1002 rs1003 rs1004
    ## P001      0      1      2      0
    ## P002      1      1      0      2
    ## P003      2      0      1      1
    ## P004      0      2      2      1
    ## P005      1      0      1      0

Here:

``` text
0 = zero copies of the counted allele
1 = one copy
2 = two copies
```

provided the allele definition has been established correctly.

------------------------------------------------------------------------

# 6.89 Selecting one variant

``` r
dosage[
  ,
  "rs1002"
]
```

    ## P001 P002 P003 P004 P005 
    ##    1    1    0    2    0

This returns dosage values for `rs1002` across participants.

------------------------------------------------------------------------

# 6.90 Selecting one participant

``` r
dosage[
  "P003",
  ]
```

    ## rs1001 rs1002 rs1003 rs1004 
    ##      2      0      1      1

This returns all four variant dosages for participant `P003`.

------------------------------------------------------------------------

# 6.91 Calculating counted-allele frequency from dosage

For a diploid autosomal variant with complete dosage data coded as 0, 1,
and 2, the counted-allele frequency can be calculated as:

$$\text{Allele frequency}
=
\frac{\text{sum of counted alleles}}
{2 \times \text{number of individuals}}$$

For `rs1001`:

``` r
rs1001 <- dosage[
  ,
  "rs1001"
]

sum(rs1001) /
  (2 * length(rs1001))
```

    ## [1] 0.4

Equivalent:

``` r
mean(rs1001) / 2
```

    ## [1] 0.4

This assumes complete diploid genotype dosage and a correctly defined
counted allele.

------------------------------------------------------------------------

# 6.92 Allele frequencies for all variants

Because participants are rows and variants are columns:

``` r
colMeans(dosage) / 2
```

    ## rs1001 rs1002 rs1003 rs1004 
    ##    0.4    0.4    0.6    0.4

gives the counted-allele frequency for each variant under the same
assumptions.

This is a useful example of how matrix orientation and column-wise
summaries work together.

------------------------------------------------------------------------

# 6.93 Missing genotype dosage

Suppose:

``` r
dosage_missing <- dosage

dosage_missing[
  "P003",
  "rs1002"
] <- NA

dosage_missing
```

    ##      rs1001 rs1002 rs1003 rs1004
    ## P001      0      1      2      0
    ## P002      1      1      0      2
    ## P003      2     NA      1      1
    ## P004      0      2      2      1
    ## P005      1      0      1      0

Calculate frequencies while ignoring missing values:

``` r
colMeans(
  dosage_missing,
  na.rm = TRUE
) / 2
```

    ## rs1001 rs1002 rs1003 rs1004 
    ##    0.4    0.5    0.6    0.4

For simple 0/1/2 diploid dosage, the mean of observed dosages divided by
two remains the observed counted-allele frequency.

------------------------------------------------------------------------

# 6.94 Missingness per variant

Because variants are columns:

``` r
colSums(
  is.na(dosage_missing)
)
```

    ## rs1001 rs1002 rs1003 rs1004 
    ##      0      1      0      0

gives missing genotype counts per variant.

Proportion missing:

``` r
colSums(
  is.na(dosage_missing)
) / nrow(dosage_missing)
```

    ## rs1001 rs1002 rs1003 rs1004 
    ##    0.0    0.2    0.0    0.0

------------------------------------------------------------------------

# 6.95 Missingness per participant

Because participants are rows:

``` r
rowSums(
  is.na(dosage_missing)
)
```

    ## P001 P002 P003 P004 P005 
    ##    0    0    1    0    0

Proportion missing:

``` r
rowSums(
  is.na(dosage_missing)
) / ncol(dosage_missing)
```

    ## P001 P002 P003 P004 P005 
    ## 0.00 0.00 0.25 0.00 0.00

These patterns resemble basic sample-level and variant-level genotype QC
concepts.

------------------------------------------------------------------------

# 6.96 Correlation matrix preview

Matrices are often used to store pairwise relationships.

Suppose:

``` r
x <- c(
  10,
  12,
  15,
  18,
  20
)

y <- c(
  5,
  7,
  8,
  11,
  13
)

z <- c(
  30,
  28,
  25,
  22,
  20
)
```

Create a numerical matrix:

``` r
measurements <- cbind(
  x,
  y,
  z
)

measurements
```

    ##       x  y  z
    ## [1,] 10  5 30
    ## [2,] 12  7 28
    ## [3,] 15  8 25
    ## [4,] 18 11 22
    ## [5,] 20 13 20

Then:

``` r
cor(measurements)
```

    ##           x         y         z
    ## x  1.000000  0.987231 -1.000000
    ## y  0.987231  1.000000 -0.987231
    ## z -1.000000 -0.987231  1.000000

returns a correlation matrix.

We will study correlation statistically in Book II. Here the important
point is structural: the output is a square matrix.

------------------------------------------------------------------------

# 6.97 Square matrices

A square matrix has the same number of rows and columns.

For example:

``` text
2 × 2
3 × 3
100 × 100
```

Check:

``` r
cor_matrix <- cor(measurements)

dim(cor_matrix)
```

    ## [1] 3 3

A correlation matrix is square because every variable is compared with
every variable.

------------------------------------------------------------------------

# 6.98 Diagonal elements

For a square matrix:

``` r
diag(cor_matrix)
```

    ## x y z 
    ## 1 1 1

extracts the diagonal.

In a correlation matrix, each variable is perfectly correlated with
itself, so the diagonal values are:

``` text
1
```

------------------------------------------------------------------------

# 6.99 Creating a diagonal matrix

`diag()` can also create a diagonal matrix:

``` r
diag(3)
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    0    0
    ## [2,]    0    1    0
    ## [3,]    0    0    1

This produces the 3 × 3 identity matrix:

$$\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix}$$

Identity matrices are important in linear algebra and statistical
modeling.

------------------------------------------------------------------------

# 6.100 Extracting the upper or lower triangle

For a square matrix:

``` r
upper.tri(cor_matrix)
```

    ##       [,1]  [,2]  [,3]
    ## [1,] FALSE  TRUE  TRUE
    ## [2,] FALSE FALSE  TRUE
    ## [3,] FALSE FALSE FALSE

returns a logical matrix marking the upper triangle.

Similarly:

``` r
lower.tri(cor_matrix)
```

    ##       [,1]  [,2]  [,3]
    ## [1,] FALSE FALSE FALSE
    ## [2,]  TRUE FALSE FALSE
    ## [3,]  TRUE  TRUE FALSE

marks the lower triangle.

These become useful when working with symmetric matrices such as
correlations or linkage disequilibrium matrices.

------------------------------------------------------------------------

# 6.101 Symmetric matrices

A symmetric matrix satisfies:

$$A = A^T$$

Correlation matrices are symmetric.

Check:

``` r
cor_matrix
```

    ##           x         y         z
    ## x  1.000000  0.987231 -1.000000
    ## y  0.987231  1.000000 -0.987231
    ## z -1.000000 -0.987231  1.000000

``` r
t(cor_matrix)
```

    ##           x         y         z
    ## x  1.000000  0.987231 -1.000000
    ## y  0.987231  1.000000 -0.987231
    ## z -1.000000 -0.987231  1.000000

A simple check is:

``` r
isTRUE(
  all.equal(
    cor_matrix,
    t(cor_matrix)
  )
)
```

    ## [1] TRUE

This should return `TRUE` for the correlation matrix.

------------------------------------------------------------------------

# 6.102 LD matrix connection

In statistical genetics, linkage disequilibrium information can be
represented using a variant-by-variant matrix.

Conceptually:

``` text
          SNP1   SNP2   SNP3
SNP1      1.00   0.72   0.10
SNP2      0.72   1.00   0.18
SNP3      0.10   0.18   1.00
```

Such a matrix is:

- square;
- variant × variant;
- usually symmetric when representing a symmetric LD measure;
- labeled by variant identifiers.

This structure appears in fine-mapping, polygenic scoring, and other
genomic methods.

------------------------------------------------------------------------

# 6.103 A small LD-style matrix

``` r
ld <- matrix(
  c(
    1.00, 0.72, 0.10,
    0.72, 1.00, 0.18,
    0.10, 0.18, 1.00
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(ld) <- c(
  "rs1001",
  "rs1002",
  "rs1003"
)

colnames(ld) <- c(
  "rs1001",
  "rs1002",
  "rs1003"
)

ld
```

    ##        rs1001 rs1002 rs1003
    ## rs1001   1.00   0.72   0.10
    ## rs1002   0.72   1.00   0.18
    ## rs1003   0.10   0.18   1.00

------------------------------------------------------------------------

# 6.104 Checking LD-style matrix dimensions and labels

``` r
dim(ld)
```

    ## [1] 3 3

``` r
rownames(ld)
```

    ## [1] "rs1001" "rs1002" "rs1003"

``` r
colnames(ld)
```

    ## [1] "rs1001" "rs1002" "rs1003"

Check whether row and column identifiers match:

``` r
identical(
  rownames(ld),
  colnames(ld)
)
```

    ## [1] TRUE

This is an important structural validation step for many matrix-based
genomic analyses.

------------------------------------------------------------------------

# 6.105 Checking symmetry

``` r
isTRUE(
  all.equal(
    ld,
    t(ld)
  )
)
```

    ## [1] TRUE

For our example, this returns `TRUE`.

------------------------------------------------------------------------

# 6.106 Checking the diagonal

``` r
diag(ld)
```

    ## rs1001 rs1002 rs1003 
    ##      1      1      1

For a correlation-like LD matrix, the diagonal should normally be 1.

Check:

``` r
all(
  diag(ld) == 1
)
```

    ## [1] TRUE

For real floating-point data, exact equality may sometimes be too
strict; later chapters will discuss robust numerical validation.

------------------------------------------------------------------------

# 6.107 Matrix storage orientation matters

Consider two possible expression layouts.

### Layout A

``` text
rows    = genes
columns = samples
```

### Layout B

``` text
rows    = samples
columns = genes
```

Both are valid.

However:

``` r
rowMeans()
```

means something different under each orientation.

Therefore, before analyzing an unfamiliar matrix, we should determine:

``` text
What does one row represent?
What does one column represent?
What does one cell represent?
```

------------------------------------------------------------------------

# 6.108 A useful three-question matrix audit

Whenever we encounter a matrix, we should ask:

1.  **What does each row represent?**
2.  **What does each column represent?**
3.  **What does each cell represent?**

For example:

``` text
Expression matrix

Rows    → genes
Columns → samples
Cells   → expression measurements
```

Or:

``` text
Genotype matrix

Rows    → participants
Columns → variants
Cells   → allele dosage
```

Or:

``` text
LD matrix

Rows    → variants
Columns → variants
Cells   → pairwise LD measure
```

This prevents many orientation errors.

------------------------------------------------------------------------

# 6.109 Matrices versus data frames

A matrix requires one common atomic type.

A biomedical dataset may contain:

``` text
ID         → character
Age        → numeric
Sex        → categorical
Smoker     → categorical
Glucose    → numeric
Disease    → categorical
```

Trying to place all of these into one matrix can cause coercion to
character.

For mixed-type tabular research data, a **data frame** is usually more
appropriate.

We will study data frames in Chapter 9.

Matrices are particularly appropriate when cells naturally share one
numerical or character type.

------------------------------------------------------------------------

# 6.110 Common mistakes

## Mistake 1: forgetting that `matrix()` fills columns by default

If row-wise entry is intended, specify:

``` r
byrow = TRUE
```

------------------------------------------------------------------------

## Mistake 2: mixing incompatible data types

``` r
bad_matrix <- matrix(
  c(
    95,
    105,
    "Missing",
    110
  ),
  nrow = 2
)

typeof(bad_matrix)
```

    ## [1] "character"

The matrix becomes character.

For genuinely missing numeric measurements, use `NA`.

------------------------------------------------------------------------

## Mistake 3: reversing row and column positions

The syntax is:

``` r
m[row, column]
```

not:

``` text
m[column, row]
```

------------------------------------------------------------------------

## Mistake 4: forgetting the comma

For a matrix:

``` r
m[2, ]
```

means row 2.

``` r
m[, 2]
```

means column 2.

------------------------------------------------------------------------

## Mistake 5: losing dimensions unexpectedly

Selecting one row:

``` r
expression[
  "C4A",
  ]
```

    ## Sample1 Sample2 Sample3 Sample4 
    ##     5.2     4.8     5.6     5.1

usually simplifies to a vector.

If matrix structure is required:

``` r
expression[
  "C4A",
  ,
  drop = FALSE
]
```

    ##     Sample1 Sample2 Sample3 Sample4
    ## C4A     5.2     4.8     5.6     5.1

------------------------------------------------------------------------

## Mistake 6: confusing `*` with `%*%`

``` text
*    = element-wise multiplication
%*%  = matrix multiplication
```

These operations are mathematically different.

------------------------------------------------------------------------

## Mistake 7: applying row summaries without knowing matrix orientation

Before:

``` r
rowMeans(x)
```

we should know what a row represents.

------------------------------------------------------------------------

## Mistake 8: assuming row and column names are decorative

In scientific workflows, dimension names often identify:

- genes;
- variants;
- participants;
- samples.

Incorrect or misaligned names can lead to serious analytical errors.

------------------------------------------------------------------------

## Mistake 9: ignoring missing values in summaries

``` r
rowMeans(x)
```

can return `NA` when a row contains missing values.

When scientifically appropriate:

``` r
rowMeans(
  x,
  na.rm = TRUE
)
```

------------------------------------------------------------------------

## Mistake 10: using a matrix for mixed-type participant data

Matrices are atomic.

For participant tables containing IDs, categories, dates, and
measurements, data frames are generally more appropriate.

------------------------------------------------------------------------

# 6.111 Guided practical: laboratory matrix

Suppose three laboratory measurements are recorded at four visits.

Create:

``` r
lab <- matrix(
  c(
    92, 98, 101, 95,
    180, 175, 190, 185,
    120, 118, 125, 122
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(lab) <- c(
  "Glucose",
  "Cholesterol",
  "SBP"
)

colnames(lab) <- c(
  "Visit1",
  "Visit2",
  "Visit3",
  "Visit4"
)

lab
```

    ##             Visit1 Visit2 Visit3 Visit4
    ## Glucose         92     98    101     95
    ## Cholesterol    180    175    190    185
    ## SBP            120    118    125    122

------------------------------------------------------------------------

## Step 1: inspect dimensions

``` r
dim(lab)
```

    ## [1] 3 4

``` r
nrow(lab)
```

    ## [1] 3

``` r
ncol(lab)
```

    ## [1] 4

------------------------------------------------------------------------

## Step 2: inspect names

``` r
rownames(lab)
```

    ## [1] "Glucose"     "Cholesterol" "SBP"

``` r
colnames(lab)
```

    ## [1] "Visit1" "Visit2" "Visit3" "Visit4"

------------------------------------------------------------------------

## Step 3: extract glucose across visits

``` r
lab[
  "Glucose",
  ]
```

    ## Visit1 Visit2 Visit3 Visit4 
    ##     92     98    101     95

------------------------------------------------------------------------

## Step 4: extract all measurements at Visit3

``` r
lab[
  ,
  "Visit3"
]
```

    ##     Glucose Cholesterol         SBP 
    ##         101         190         125

------------------------------------------------------------------------

## Step 5: extract one cell

``` r
lab[
  "Cholesterol",
  "Visit2"
]
```

    ## [1] 175

------------------------------------------------------------------------

## Step 6: calculate mean per measurement

Because measurements are rows:

``` r
rowMeans(lab)
```

    ##     Glucose Cholesterol         SBP 
    ##       96.50      182.50      121.25

------------------------------------------------------------------------

## Step 7: calculate mean per visit

``` r
colMeans(lab)
```

    ##   Visit1   Visit2   Visit3   Visit4 
    ## 130.6667 130.3333 138.6667 134.0000

The biological interpretation of averaging different measurement types
may be limited because glucose, cholesterol, and SBP have different
units. This calculation is included to demonstrate matrix mechanics, not
to recommend such a scientific summary.

------------------------------------------------------------------------

## Step 8: transpose

``` r
t(lab)
```

    ##        Glucose Cholesterol SBP
    ## Visit1      92         180 120
    ## Visit2      98         175 118
    ## Visit3     101         190 125
    ## Visit4      95         185 122

Now visits become rows and measurements become columns.

------------------------------------------------------------------------

# 6.112 Guided practical: expression matrix

Create:

``` r
expression <- matrix(
  c(
    5.2, 4.8, 5.6, 5.1, 5.4,
    8.1, 7.9, 8.4, 8.0, 8.3,
    2.4, 2.7, 2.5, 2.6, 2.8,
    6.8, 6.5, 7.0, 6.9, 7.1
  ),
  nrow = 4,
  byrow = TRUE
)

rownames(expression) <- c(
  "C4A",
  "HLA_B",
  "BTN3A2",
  "HLA_DPA1"
)

colnames(expression) <- c(
  "S1",
  "S2",
  "S3",
  "S4",
  "S5"
)
```

Inspect:

``` r
expression
```

    ##           S1  S2  S3  S4  S5
    ## C4A      5.2 4.8 5.6 5.1 5.4
    ## HLA_B    8.1 7.9 8.4 8.0 8.3
    ## BTN3A2   2.4 2.7 2.5 2.6 2.8
    ## HLA_DPA1 6.8 6.5 7.0 6.9 7.1

``` r
dim(expression)
```

    ## [1] 4 5

------------------------------------------------------------------------

## Step 1: extract HLA_B

``` r
expression[
  "HLA_B",
  ]
```

    ##  S1  S2  S3  S4  S5 
    ## 8.1 7.9 8.4 8.0 8.3

------------------------------------------------------------------------

## Step 2: preserve it as a matrix

``` r
expression[
  "HLA_B",
  ,
  drop = FALSE
]
```

    ##        S1  S2  S3 S4  S5
    ## HLA_B 8.1 7.9 8.4  8 8.3

------------------------------------------------------------------------

## Step 3: extract S3

``` r
expression[
  ,
  "S3"
]
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##      5.6      8.4      2.5      7.0

------------------------------------------------------------------------

## Step 4: calculate gene means

``` r
gene_mean <- rowMeans(expression)

gene_mean
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##     5.22     8.14     2.60     6.86

------------------------------------------------------------------------

## Step 5: identify the gene with the highest mean

``` r
which.max(gene_mean)
```

    ## HLA_B 
    ##     2

``` r
names(gene_mean)[
  which.max(gene_mean)
]
```

    ## [1] "HLA_B"

------------------------------------------------------------------------

## Step 6: count values above 7 per gene

``` r
rowSums(
  expression > 7
)
```

    ##      C4A    HLA_B   BTN3A2 HLA_DPA1 
    ##        0        5        0        1

------------------------------------------------------------------------

# 6.113 Independent exercise

Create:

``` r
biomarker <- matrix(
  c(
    10.2, 11.1, 9.8, 10.5,
    5.4, 5.8, 6.1, 5.9,
    100, 110, 105, 115,
    32, 30, 35, 31
  ),
  nrow = 4,
  byrow = TRUE
)

rownames(biomarker) <- c(
  "Marker_A",
  "Marker_B",
  "Marker_C",
  "Marker_D"
)

colnames(biomarker) <- c(
  "P001",
  "P002",
  "P003",
  "P004"
)
```

Complete the following tasks:

1.  display the matrix;
2.  determine its dimensions;
3.  count rows and columns;
4.  extract `Marker_B`;
5.  extract participant `P003`;
6.  extract the value for `Marker_C` and `P004`;
7.  select `Marker_A` and `Marker_D`;
8.  select participants `P001` and `P004`;
9.  create a 2 × 2 submatrix using those rows and columns;
10. calculate the mean of each biomarker;
11. calculate the maximum value in each row using `apply()`;
12. transpose the matrix;
13. verify the dimensions after transposition;
14. count how many matrix cells exceed 20;
15. preserve `Marker_A` as a one-row matrix using `drop = FALSE`.

------------------------------------------------------------------------

# 6.114 Challenge: missing assay values

Create:

``` r
assay <- matrix(
  c(
    5.1, 5.3, NA, 5.8,
    7.2, NA, 7.5, 7.1,
    2.1, 2.3, 2.4, 2.2
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(assay) <- c(
  "Gene_A",
  "Gene_B",
  "Gene_C"
)

colnames(assay) <- c(
  "S1",
  "S2",
  "S3",
  "S4"
)
```

Tasks:

1.  count total missing cells;
2.  identify missing row-column coordinates;
3.  count missing values per gene;
4.  count missing values per sample;
5.  calculate proportion missing per gene;
6.  calculate proportion missing per sample;
7.  calculate mean expression per gene using observed values;
8.  identify which gene has the highest observed mean;
9.  explain why replacing missing values with zero without scientific
    justification could distort the analysis.

------------------------------------------------------------------------

# 6.115 Challenge: genotype dosage matrix

Create:

``` r
dosage <- matrix(
  c(
    0, 1, 2, 0, 1,
    1, 1, 0, 2, 0,
    2, 0, 1, 1, 2,
    0, 2, 2, 1, 1,
    1, 0, 1, 0, 2,
    2, 1, 0, 1, 0
  ),
  nrow = 6,
  byrow = TRUE
)

rownames(dosage) <- c(
  "P001",
  "P002",
  "P003",
  "P004",
  "P005",
  "P006"
)

colnames(dosage) <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004",
  "rs1005"
)
```

Tasks:

1.  inspect dimensions;
2.  verify that there are six participants and five variants;
3.  extract dosages for `rs1003`;
4.  extract all dosages for `P004`;
5.  calculate counted-allele frequency for each variant using
    `colMeans(dosage) / 2`;
6.  determine which variant has the highest counted-allele frequency;
7.  introduce an `NA` at `P002`, `rs1004`;
8.  calculate missingness per participant;
9.  calculate missingness per variant;
10. recalculate observed counted-allele frequencies using
    `na.rm = TRUE`;
11. explain why the meaning of dosage values depends on knowing which
    allele is being counted.

------------------------------------------------------------------------

# 6.116 Challenge: LD-style matrix

Create:

``` r
ld <- matrix(
  c(
    1.00, 0.82, 0.15, 0.05,
    0.82, 1.00, 0.21, 0.08,
    0.15, 0.21, 1.00, 0.64,
    0.05, 0.08, 0.64, 1.00
  ),
  nrow = 4,
  byrow = TRUE
)

variant_id <- c(
  "rs1001",
  "rs1002",
  "rs1003",
  "rs1004"
)

rownames(ld) <- variant_id
colnames(ld) <- variant_id
```

Tasks:

1.  verify that the matrix is square;
2.  verify that row names and column names are identical;
3.  inspect the diagonal;
4.  test whether all diagonal values equal 1;
5.  test whether the matrix is symmetric;
6.  extract the LD value between `rs1001` and `rs1002`;
7.  extract the submatrix for `rs1003` and `rs1004`;
8.  identify off-diagonal values greater than 0.7;
9.  explain why row/column variant alignment is essential before using
    an LD matrix in downstream genomic analysis.

------------------------------------------------------------------------

# 6.117 Complete Chapter 6 practice script

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 6: Matrices
# ============================================================


# ------------------------------------------------------------
# 1. Create a matrix
# ------------------------------------------------------------

m <- matrix(
  1:6,
  nrow = 2,
  ncol = 3
)

m


# ------------------------------------------------------------
# 2. Fill by rows
# ------------------------------------------------------------

m_byrow <- matrix(
  1:6,
  nrow = 2,
  ncol = 3,
  byrow = TRUE
)

m_byrow


# ------------------------------------------------------------
# 3. Inspect matrix
# ------------------------------------------------------------

dim(m)
nrow(m)
ncol(m)
length(m)
class(m)
typeof(m)
str(m)


# ------------------------------------------------------------
# 4. Add row and column names
# ------------------------------------------------------------

expression <- matrix(
  c(
    5.2, 4.8, 5.6, 5.1,
    8.1, 7.9, 8.4, 8.0,
    2.4, 2.7, 2.5, 2.6
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(expression) <- c(
  "Gene1",
  "Gene2",
  "Gene3"
)

colnames(expression) <- c(
  "Sample1",
  "Sample2",
  "Sample3",
  "Sample4"
)

expression


# ------------------------------------------------------------
# 5. Matrix indexing
# ------------------------------------------------------------

expression[
  2,
  3
]

expression[
  2,
  ]

expression[
  ,
  3
]

expression[
  "Gene2",
  "Sample3"
]

expression[
  c(
    "Gene1",
    "Gene3"
  ),
  c(
    "Sample1",
    "Sample4"
  )
]


# ------------------------------------------------------------
# 6. Preserve dimensions
# ------------------------------------------------------------

expression[
  "Gene1",
  ,
  drop = FALSE
]


# ------------------------------------------------------------
# 7. Logical matrix operations
# ------------------------------------------------------------

expression > 5

sum(
  expression > 5
)


# ------------------------------------------------------------
# 8. Row and column summaries
# ------------------------------------------------------------

rowSums(expression)
colSums(expression)

rowMeans(expression)
colMeans(expression)


# ------------------------------------------------------------
# 9. Transpose
# ------------------------------------------------------------

expression_t <- t(expression)

expression_t

dim(expression)
dim(expression_t)


# ------------------------------------------------------------
# 10. rbind and cbind
# ------------------------------------------------------------

gene1 <- c(
  5.2,
  4.8,
  5.6
)

gene2 <- c(
  8.1,
  7.9,
  8.4
)

rbind(
  gene1,
  gene2
)

sample1 <- c(
  5.2,
  8.1,
  2.4
)

sample2 <- c(
  4.8,
  7.9,
  2.7
)

cbind(
  sample1,
  sample2
)


# ------------------------------------------------------------
# 11. Element-wise versus matrix multiplication
# ------------------------------------------------------------

A <- matrix(
  c(
    1, 2,
    3, 4
  ),
  nrow = 2,
  byrow = TRUE
)

B <- matrix(
  c(
    10, 20,
    30, 40
  ),
  nrow = 2,
  byrow = TRUE
)

A * B

A %*% B


# ------------------------------------------------------------
# 12. Missing values
# ------------------------------------------------------------

assay <- matrix(
  c(
    5.1, 5.3, NA,
    7.2, NA, 7.5,
    2.1, 2.3, 2.4
  ),
  nrow = 3,
  byrow = TRUE
)

sum(
  is.na(assay)
)

rowSums(
  is.na(assay)
)

colSums(
  is.na(assay)
)

rowMeans(
  assay,
  na.rm = TRUE
)


# ------------------------------------------------------------
# 13. Genotype dosage matrix
# ------------------------------------------------------------

dosage <- matrix(
  c(
    0, 1, 2,
    1, 1, 0,
    2, 0, 1,
    0, 2, 2
  ),
  nrow = 4,
  byrow = TRUE
)

rownames(dosage) <- c(
  "P001",
  "P002",
  "P003",
  "P004"
)

colnames(dosage) <- c(
  "rs1001",
  "rs1002",
  "rs1003"
)

dosage

colMeans(dosage) / 2


# ------------------------------------------------------------
# 14. LD-style matrix
# ------------------------------------------------------------

ld <- matrix(
  c(
    1.00, 0.72, 0.10,
    0.72, 1.00, 0.18,
    0.10, 0.18, 1.00
  ),
  nrow = 3,
  byrow = TRUE
)

variant_id <- c(
  "rs1001",
  "rs1002",
  "rs1003"
)

rownames(ld) <- variant_id
colnames(ld) <- variant_id

ld

identical(
  rownames(ld),
  colnames(ld)
)

diag(ld)

isTRUE(
  all.equal(
    ld,
    t(ld)
  )
)
```

------------------------------------------------------------------------

# 6.118 Essential matrix functions and syntax

| Task                        | R syntax                           |
|-----------------------------|------------------------------------|
| Create matrix               | `matrix()`                         |
| Fill by rows                | `matrix(..., byrow = TRUE)`        |
| Dimensions                  | `dim(x)`                           |
| Number of rows              | `nrow(x)`                          |
| Number of columns           | `ncol(x)`                          |
| Total elements              | `length(x)`                        |
| Row names                   | `rownames(x)`                      |
| Column names                | `colnames(x)`                      |
| Both dimension names        | `dimnames(x)`                      |
| Select cell                 | `x[row, column]`                   |
| Select row                  | `x[row, ]`                         |
| Select column               | `x[, column]`                      |
| Preserve dimensions         | `x[row, , drop = FALSE]`           |
| Bind rows                   | `rbind()`                          |
| Bind columns                | `cbind()`                          |
| Transpose                   | `t(x)`                             |
| Row sums                    | `rowSums(x)`                       |
| Column sums                 | `colSums(x)`                       |
| Row means                   | `rowMeans(x)`                      |
| Column means                | `colMeans(x)`                      |
| General margin operation    | `apply(x, margin, function)`       |
| Element-wise multiplication | `A * B`                            |
| Matrix multiplication       | `A %*% B`                          |
| Diagonal                    | `diag(x)`                          |
| Upper triangle              | `upper.tri(x)`                     |
| Lower triangle              | `lower.tri(x)`                     |
| Missing-value matrix        | `is.na(x)`                         |
| Matrix coordinates          | `which(condition, arr.ind = TRUE)` |

------------------------------------------------------------------------

# 6.119 Concept map

``` text
Vector
  │
  │ add second dimension
  ↓
Matrix
  │
  ├───────────────────────────────┐
  ↓                               ↓
Rows                           Columns
  │                               │
  └───────────────┬───────────────┘
                  ↓
             matrix[row, col]
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
     indexing   names    submatrices
                  │
                  ↓
           numerical operations
                  │
        ┌─────────┼──────────────┐
        ↓         ↓              ↓
    element-wise transpose   matrix algebra
        │         │              │
        ↓         ↓              ↓
       `*`       `t()`          `%*%`
                  │
                  ↓
          row/column summaries
                  │
       ┌──────────┼──────────┐
       ↓          ↓          ↓
 expression    genotype      LD
 matrices      matrices    matrices
```

------------------------------------------------------------------------

# 6.120 Chapter review

Before moving forward, we should be able to answer:

1.  What is a matrix?
2.  How does a matrix differ from a vector?
3.  Why is a basic matrix described as atomic?
4.  How does `matrix()` fill values by default?
5.  What does `byrow = TRUE` change?
6.  What does `dim()` return?
7.  What is the difference between `nrow()` and `ncol()`?
8.  How do we assign row and column names?
9.  What does `m[2, 3]` mean?
10. How do we select an entire row?
11. How do we select an entire column?
12. How do we select a submatrix?
13. Why can selecting one row or column return a vector?
14. What does `drop = FALSE` do?
15. What is the difference between `rbind()` and `cbind()`?
16. Why can mixed data types cause matrix coercion?
17. What is the difference between `A * B` and `A %*% B`?
18. What dimension rule is required for matrix multiplication?
19. What does `t()` do?
20. What do `rowSums()` and `colSums()` calculate?
21. What do `rowMeans()` and `colMeans()` calculate?
22. How can we count missing values per row?
23. How can we count missing values per column?
24. What does `which(..., arr.ind = TRUE)` provide?
25. Why must matrix orientation be known before interpreting row or
    column summaries?
26. Why are matrices useful for gene-expression data?
27. How can genotype dosage be represented in a matrix?
28. Under what assumptions can `colMeans(dosage) / 2` estimate
    counted-allele frequency?
29. Why is an LD matrix usually square?
30. Why should row and column variant identifiers be checked before
    using an LD matrix?
31. Why are mixed-type participant datasets usually better represented
    by data frames than matrices?

------------------------------------------------------------------------

# 6.121 Key takeaways

1.  A matrix is a two-dimensional structure with rows and columns.
2.  Basic matrices are atomic, so all elements share a common underlying
    type.
3.  `matrix()` fills values by columns unless `byrow = TRUE` is
    specified.
4.  `dim()`, `nrow()`, and `ncol()` describe matrix dimensions.
5.  Row and column names give scientific meaning to matrix dimensions.
6.  Matrix indexing follows `matrix[row, column]`.
7.  Entire rows or columns can be selected by leaving one index blank.
8.  Multiple rows and columns can be selected to create submatrices.
9.  Selecting a single row or column can simplify a matrix to a vector.
10. `drop = FALSE` preserves matrix structure.
11. `rbind()` combines objects by rows, while `cbind()` combines them by
    columns.
12. Mixed element types can cause coercion of the entire matrix.
13. Matrix arithmetic is usually element-wise for `+`, `-`, `*`, and
    `/`.
14. `%*%` performs true matrix multiplication.
15. `t()` transposes a matrix.
16. `rowSums()`, `colSums()`, `rowMeans()`, and `colMeans()` efficiently
    summarize matrix dimensions.
17. `is.na()` can be combined with row and column sums to quantify
    missingness.
18. Matrix orientation determines the meaning of every row-wise and
    column-wise calculation.
19. Gene-expression, genotype dosage, correlation, and LD data naturally
    illustrate matrix structures.
20. Mixed-type participant-level datasets generally require a different
    structure, which we will study later.

The central principle is:

> **Before analyzing a matrix, we should know what one row represents,
> what one column represents, and what one cell represents.**

------------------------------------------------------------------------

# 6.122 Looking ahead

A matrix has two dimensions:

``` text
rows × columns
```

But some research data naturally require more than two dimensions.

For example, suppose gene expression is measured for:

``` text
genes
×
samples
×
time points
```

or imaging data contain:

``` text
x coordinate
×
y coordinate
×
slice
```

R extends the matrix concept through **arrays**, which can contain three
or more dimensions while still storing one common atomic type.

The next chapter is:

**Chapter 7 — Arrays and Higher-Dimensional Data**
