Chapter 22 — Introduction to the Tidyverse and Tibbles
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In the previous chapters, we learned base R, functions, iteration,
strings, and dates. We can now introduce a family of packages designed
to make common data tasks more consistent and expressive. The
**tidyverse** is not a new programming language: it is a collection of R
packages with related conventions. **Tibbles** are modern data frames
supplied by the `tibble` package.

This chapter concentrates on **R concepts and programming practice**,
not statistical modelling. We first learn each idea in base R and then
see the corresponding tidyverse approach. All required examples work
with base R. Optional demonstrations execute only when the relevant
package is installed; no installation is attempted automatically.

## Learning objectives

After this chapter, we should be able to:

1.  Describe the tidyverse ecosystem and distinguish packages from
    functions.
2.  Install, attach, and call package functions safely.
3.  Explain the difference between a data frame and a tibble.
4.  Construct, inspect, subset, and convert tibbles.
5.  Understand the native `|>` pipe and the optional `%>%` pipe.
6.  Identify tidy data: variables as columns, observations as rows,
    values as cells.
7.  Recognize type stability, missing values, and printing differences.
8.  Use namespaced functions without attaching an entire package.
9.  Recognize common errors, conflicts, and installation problems.
10. Complete a small data-management workflow with and without tidyverse
    packages.

------------------------------------------------------------------------

## 22.1 What is the tidyverse?

The tidyverse is a coordinated ecosystem of R packages. Its core
packages include:

| Package | Main role | Example functions |
|----|----|----|
| `tibble` | Modern data frames | `tibble()`, `as_tibble()`, `tribble()` |
| `dplyr` | Data manipulation | `filter()`, `select()`, `mutate()`, `summarise()` |
| `tidyr` | Reshaping and tidying | `pivot_longer()`, `pivot_wider()` |
| `readr` | Reading and writing rectangular data | `read_csv()`, `write_csv()` |
| `stringr` | String operations | `str_detect()`, `str_trim()` |
| `forcats` | Working with factors | `fct_relevel()`, `fct_recode()` |
| `purrr` | Functional programming | `map()`, `map_dbl()` |
| `ggplot2` | Data visualization | `ggplot()`, `geom_point()` |

Additional useful packages such as `lubridate`, `readxl`, `dbplyr`, and
`haven` belong to the broader ecosystem but are not all core packages
attached by `library(tidyverse)`.

We will explore `dplyr`, `tidyr`, and `ggplot2` in dedicated later
chapters. Here we focus on the common foundations.

### Packages versus functions

A **package** bundles functions, documentation, and sometimes datasets.
A **function** performs an operation. For example, `tibble` is a
package, whereas `tibble::tibble()` is a function from that package.

### Installation versus attachment

- `install.packages("tibble")` installs a package onto the computer.
- `library(tibble)` attaches its exported functions for convenient use.
- `tibble::tibble()` calls a function by namespace without attaching the
  package.

Installing a package is normally a one-time setup step for a particular
R library, whereas loading is repeated in new R sessions. This book does
**not** run installation commands while knitting.

``` r
# Run manually only when package installation is permitted:
install.packages("tibble")
install.packages("dplyr")
install.packages("tidyr")
# Alternatively, install the collection:
install.packages("tidyverse")
```

For managed Windows computers, installation may fail because of
permissions, network restrictions, or blocked compiled libraries. We
should diagnose the actual error rather than repeatedly reinstalling
unrelated dependencies.

``` r
optional_packages <- c("tibble", "dplyr", "tidyr", "magrittr")
installed_here <- vapply(optional_packages, requireNamespace,
                         logical(1), quietly = TRUE)
data.frame(package = optional_packages, installed = installed_here)
```

    ##           package installed
    ## tibble     tibble      TRUE
    ## dplyr       dplyr      TRUE
    ## tidyr       tidyr      TRUE
    ## magrittr magrittr      TRUE

## 22.2 Our reusable example dataset

We use a small fictional shop dataset with customers, products,
quantities, and unit prices. It is deliberately simple and contains no
private information.

``` r
orders <- data.frame(
  order_id = c("O001", "O002", "O003", "O004", "O005", "O006"),
  customer = c("Asha", "Ravi", "Mina", "Asha", "Ravi", "Leena"),
  product = c("Notebook", "Pen", "Notebook", "Bag", "Pen", "Bag"),
  quantity = c(2L, 5L, 1L, 1L, 3L, NA_integer_),
  unit_price = c(80, 15, 80, 450, 15, 450),
  stringsAsFactors = FALSE
)
orders
```

    ##   order_id customer  product quantity unit_price
    ## 1     O001     Asha Notebook        2         80
    ## 2     O002     Ravi      Pen        5         15
    ## 3     O003     Mina Notebook        1         80
    ## 4     O004     Asha      Bag        1        450
    ## 5     O005     Ravi      Pen        3         15
    ## 6     O006    Leena      Bag       NA        450

``` r
str(orders)
```

    ## 'data.frame':    6 obs. of  5 variables:
    ##  $ order_id  : chr  "O001" "O002" "O003" "O004" ...
    ##  $ customer  : chr  "Asha" "Ravi" "Mina" "Asha" ...
    ##  $ product   : chr  "Notebook" "Pen" "Notebook" "Bag" ...
    ##  $ quantity  : int  2 5 1 1 3 NA
    ##  $ unit_price: num  80 15 80 450 15 450

The dataset has six rows and five columns. Each row is an order, each
column is a variable, and the missing quantity is explicitly represented
by `NA`. The first question is not which package we use, but what each
row represents.

## 22.3 The traditional `data.frame`

A base R data frame is a list of equal-length columns. Its columns may
have different types, and it supports row and column indexing.

``` r
class(orders)
```

    ## [1] "data.frame"

``` r
is.data.frame(orders)
```

    ## [1] TRUE

``` r
nrow(orders)
```

    ## [1] 6

``` r
ncol(orders)
```

    ## [1] 5

``` r
names(orders)
```

    ## [1] "order_id"   "customer"   "product"    "quantity"   "unit_price"

``` r
orders[1:3, c("order_id", "quantity")]
```

    ##   order_id quantity
    ## 1     O001        2
    ## 2     O002        5
    ## 3     O003        1

``` r
orders[["quantity"]]
```

    ## [1]  2  5  1  1  3 NA

### The dropping problem

Base R’s `[ ]` may simplify a one-column selection to a vector unless we
request `drop = FALSE`.

``` r
single_column_vector <- orders[, "customer"]
single_column_table <- orders[, "customer", drop = FALSE]
class(single_column_vector)
```

    ## [1] "character"

``` r
class(single_column_table)
```

    ## [1] "data.frame"

``` r
stopifnot(is.character(single_column_vector),
          is.data.frame(single_column_table))
```

This is not an error in base R; it is part of its documented subsetting
behavior. Tibbles use a different convention that often makes code more
predictable.

## 22.4 What is a tibble?

A tibble inherits from `data.frame`, so many base R functions work with
it. Tibbles also have distinct printing, subsetting, and construction
rules.

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  orders_tbl <- tibble::as_tibble(orders)
  print(orders_tbl)
  print(class(orders_tbl))
  print(is.data.frame(orders_tbl))
} else {
  cat("Optional tibble package unavailable; base R example remains usable.\n")
}
```

    ## # A tibble: 6 × 5
    ##   order_id customer product  quantity unit_price
    ##   <chr>    <chr>    <chr>       <int>      <dbl>
    ## 1 O001     Asha     Notebook        2         80
    ## 2 O002     Ravi     Pen             5         15
    ## 3 O003     Mina     Notebook        1         80
    ## 4 O004     Asha     Bag             1        450
    ## 5 O005     Ravi     Pen             3         15
    ## 6 O006     Leena    Bag            NA        450
    ## [1] "tbl_df"     "tbl"        "data.frame"
    ## [1] TRUE

The typical class vector is `c("tbl_df", "tbl", "data.frame")`. Tibbles
remain data frames, but print a preview with column types instead of
automatically displaying an entire large dataset.

### Creating a tibble directly

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  demo_tbl <- tibble::tibble(
    item = c("Pencil", "Eraser", "Ruler"),
    price = c(10, 8, 25),
    total_with_tax = price * 1.05
  )
  print(demo_tbl)
}
```

    ## # A tibble: 3 × 3
    ##   item   price total_with_tax
    ##   <chr>  <dbl>          <dbl>
    ## 1 Pencil    10           10.5
    ## 2 Eraser     8            8.4
    ## 3 Ruler     25           26.2

Unlike `data.frame()`, `tibble()` can use an earlier newly created
column while evaluating a later column. We should still use descriptive
names and avoid depending on ambiguous evaluation behavior.

### `tribble()` for small hand-entered tables

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  grades_tbl <- tibble::tribble(
    ~student, ~score,
    "A",       82,
    "B",       91,
    "C",       77
  )
  print(grades_tbl)
}
```

    ## # A tibble: 3 × 2
    ##   student score
    ##   <chr>   <dbl>
    ## 1 A          82
    ## 2 B          91
    ## 3 C          77

The tilde marks the column names in `tribble()`. This style is useful
for short illustrative datasets, not for typing thousands of records.

## 22.5 Comparing data frames and tibbles

| Behavior | Base data frame | Tibble |
|----|----|----|
| Basic structure | List of columns | Data frame subclass |
| Printing | May print all rows | Concise preview |
| Selecting one column with `[ , ]` | May simplify to vector | Retains tibble |
| Extracting with `[[ ]]` | Returns column vector | Returns column vector |
| Partial matching with `$` | May partially match | Does not silently partially match |
| Column name repair | Depends on constructor settings | Explicit name-repair conventions |
| Existing base R functions | Yes | Usually, but verify class-sensitive behavior |

These differences are important when functions expect a vector rather
than a table.

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  tbl <- tibble::as_tibble(orders)
  print(class(tbl[, "customer"]))
  print(class(tbl[["customer"]]))
  stopifnot(inherits(tbl[, "customer"], "tbl_df"),
            is.character(tbl[["customer"]]))
}
```

    ## [1] "tbl_df"     "tbl"        "data.frame"
    ## [1] "character"

### `pull()` versus `[[ ]]`

`dplyr::pull()` is a convenient way to extract a column as a vector. In
base R, `[[ ]]` already performs that task.

``` r
if (requireNamespace("dplyr", quietly = TRUE)) {
  customer_vector <- dplyr::pull(orders, customer)
  stopifnot(identical(customer_vector, orders[["customer"]]))
}
```

## 22.6 Inspecting tibbles

Common inspection functions include `head()`, `tail()`, `str()`,
`names()`, `dim()`, and `summary()`. The tibble package additionally
provides `glimpse()`.

``` r
head(orders, 3)
```

    ##   order_id customer  product quantity unit_price
    ## 1     O001     Asha Notebook        2         80
    ## 2     O002     Ravi      Pen        5         15
    ## 3     O003     Mina Notebook        1         80

``` r
str(orders)
```

    ## 'data.frame':    6 obs. of  5 variables:
    ##  $ order_id  : chr  "O001" "O002" "O003" "O004" ...
    ##  $ customer  : chr  "Asha" "Ravi" "Mina" "Asha" ...
    ##  $ product   : chr  "Notebook" "Pen" "Notebook" "Bag" ...
    ##  $ quantity  : int  2 5 1 1 3 NA
    ##  $ unit_price: num  80 15 80 450 15 450

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  tibble::glimpse(tibble::as_tibble(orders))
}
```

    ## Rows: 6
    ## Columns: 5
    ## $ order_id   <chr> "O001", "O002", "O003", "O004", "O005", "O006"
    ## $ customer   <chr> "Asha", "Ravi", "Mina", "Asha", "Ravi", "Leena"
    ## $ product    <chr> "Notebook", "Pen", "Notebook", "Bag", "Pen", "Bag"
    ## $ quantity   <int> 2, 5, 1, 1, 3, NA
    ## $ unit_price <dbl> 80, 15, 80, 450, 15, 450

`glimpse()` is especially convenient when a table contains many columns.
We should still check the actual classes of important columns.

## 22.7 Converting between data frames and tibbles

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  x_tbl <- tibble::as_tibble(orders)
  x_df <- as.data.frame(x_tbl)
  stopifnot(is.data.frame(x_tbl),
            identical(x_df, orders))
}
```

Conversion is generally straightforward for ordinary rectangular tables.
Specialized classes and attributes should be verified rather than
assumed to survive every conversion unchanged.

## 22.8 Column names and name repair

Duplicate or empty column names can make programming difficult. Tibbles
provide configurable name repair, including unique names.

``` r
raw_names <- c("id", "id", "")
make.unique(raw_names)
```

    ## [1] "id"   "id.1" ""

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  repaired <- tibble::as_tibble(
    setNames(data.frame(1:2, 3:4, 5:6), raw_names),
    .name_repair = "unique"
  )
  print(names(repaired))
}
```

    ## New names:
    ## • `id` -> `id...1`
    ## • `id` -> `id...2`
    ## • `` -> `...3`

    ## [1] "id...1" "id...2" "...3"

Name repair should not hide a source-data problem. If duplicate headers
appear unexpectedly, we should inspect the original file and document
any renaming decisions.

## 22.9 Missing values and types

Tibbles do not automatically clean data. Missing values remain missing;
text remains text; numeric columns remain numeric unless we explicitly
transform them.

``` r
sum(is.na(orders$quantity))
```

    ## [1] 1

``` r
colSums(is.na(orders))
```

    ##   order_id   customer    product   quantity unit_price 
    ##          0          0          0          1          0

``` r
mean(orders$quantity, na.rm = TRUE)
```

    ## [1] 2.4

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  tbl <- tibble::as_tibble(orders)
  stopifnot(identical(is.na(tbl$quantity),
                      is.na(orders$quantity)))
}
```

The `na.rm = TRUE` argument removes missing values from that particular
calculation. It does not modify the underlying table.

## 22.10 Tidy data as a design principle

A dataset is **tidy** when:

1.  Each variable has its own column.
2.  Each observation has its own row.
3.  Each value has its own cell.

These principles help us choose a consistent data layout. They do not
imply that every dataset must always be stored in long format; the
appropriate observational unit depends on the task.

Consider monthly sales recorded across several columns.

``` r
sales_wide <- data.frame(
  store = c("North", "South"),
  jan = c(100, 120),
  feb = c(110, 135)
)
sales_wide
```

    ##   store jan feb
    ## 1 North 100 110
    ## 2 South 120 135

For some operations, we want one row per store-month rather than one row
per store. In Chapter 26, we will use `tidyr::pivot_longer()` to perform
this reshaping. Here is the base R version.

``` r
sales_long <- reshape(
  sales_wide,
  varying = c("jan", "feb"),
  v.names = "sales",
  timevar = "month",
  times = c("jan", "feb"),
  idvar = "store",
  direction = "long"
)
row.names(sales_long) <- NULL
sales_long[order(sales_long$store, sales_long$month), ]
```

    ##   store month sales
    ## 3 North   feb   110
    ## 1 North   jan   100
    ## 4 South   feb   135
    ## 2 South   jan   120

``` r
if (requireNamespace("tidyr", quietly = TRUE)) {
  sales_long_tidy <- tidyr::pivot_longer(
    sales_wide,
    cols = c("jan", "feb"),
    names_to = "month",
    values_to = "sales"
  )
  print(sales_long_tidy)
}
```

    ## # A tibble: 4 × 3
    ##   store month sales
    ##   <chr> <chr> <dbl>
    ## 1 North jan     100
    ## 2 North feb     110
    ## 3 South jan     120
    ## 4 South feb     135

## 22.11 Pipes: reading code from left to right

A pipe passes the result of one operation to another. Base R provides
the native pipe `|>` (R 4.1.0 or later). The magrittr package provides
`%>%`, widely used in older tidyverse examples.

Without a pipe, transformations can become nested.

``` r
values <- c(3, 1, 5, 2, 4)
sort(unique(values))
```

    ## [1] 1 2 3 4 5

With the native pipe, the sequence reads from left to right.

``` r
values |>
  unique() |>
  sort()
```

    ## [1] 1 2 3 4 5

The native pipe generally inserts the left-hand value as the first
argument of the function on the right. For a named non-first argument,
modern R supports the `_` placeholder with restrictions. We will avoid
relying on version-specific pipe features in the main examples.

### `%>%` and its relationship to `|>`

``` r
if (requireNamespace("magrittr", quietly = TRUE)) {
  print(magrittr::`%>%`(values, sort()))
}
```

    ## [1] 1 2 3 4 5

The `%>%` pipe has additional behavior, including a dot placeholder, and
is not identical to `|>`. For straightforward first-argument pipelines,
both express a similar flow. We should avoid mixing the two
indiscriminately in one teaching example.

### Pipelines do not mutate objects automatically

``` r
numbers <- c(4, 2, 8)
result <- numbers |> sort()
numbers
```

    ## [1] 4 2 8

``` r
result
```

    ## [1] 2 4 8

``` r
stopifnot(identical(numbers, c(4, 2, 8)))
```

A pipe returns a value. The original object is unchanged unless we
explicitly assign the result or invoke a function with side effects.

## 22.12 A first glimpse of `dplyr`

We will study `dplyr` in Chapters 23–25. For now, we need only
understand the style.

``` r
# Base R: select rows with an observed quantity of at least 2
base_result <- orders[
  !is.na(orders$quantity) & orders$quantity >= 2,
  c("order_id", "customer", "quantity"),
  drop = FALSE
]
base_result
```

    ##   order_id customer quantity
    ## 1     O001     Asha        2
    ## 2     O002     Ravi        5
    ## 5     O005     Ravi        3

``` r
if (requireNamespace("dplyr", quietly = TRUE)) {
  tidy_result <- orders |>
    dplyr::filter(!is.na(quantity), quantity >= 2) |>
    dplyr::select(order_id, customer, quantity)
  print(tidy_result)
  stopifnot(nrow(tidy_result) == nrow(base_result))
}
```

    ##   order_id customer quantity
    ## 1     O001     Asha        2
    ## 2     O002     Ravi        5
    ## 3     O005     Ravi        3

Notice that column names such as `quantity` are written without
`orders$` inside `dplyr` verbs. This is called **data masking**: `dplyr`
evaluates column names in a data context. It is convenient but
introduces programming considerations that we will discuss in the
dedicated `dplyr` chapters.

## 22.13 A first grouped summary

Grouping is another common operation. The goal is to calculate a result
separately for each category.

``` r
base_totals <- aggregate(
  quantity ~ customer,
  data = orders,
  FUN = sum,
  na.action = na.omit
)
base_totals
```

    ##   customer quantity
    ## 1     Asha        3
    ## 2     Mina        1
    ## 3     Ravi        8

Here `aggregate()` excludes rows with missing quantity when constructing
the model frame. If our intended policy is to keep every customer and
treat missing quantities in a specified way, we must define that policy
explicitly.

``` r
if (requireNamespace("dplyr", quietly = TRUE)) {
  grouped <- orders |>
    dplyr::group_by(customer) |>
    dplyr::summarise(
      total_quantity = sum(quantity, na.rm = TRUE),
      .groups = "drop"
    )
  print(grouped)
}
```

    ## # A tibble: 4 × 2
    ##   customer total_quantity
    ##   <chr>             <int>
    ## 1 Asha                  3
    ## 2 Leena                 0
    ## 3 Mina                  1
    ## 4 Ravi                  8

The `.groups = "drop"` argument requests an ungrouped result. Persistent
grouping can affect later operations, so we should inspect grouping
state when building longer pipelines.

## 22.14 Package namespaces and function conflicts

Different packages may export functions with the same name. For example,
`filter()` exists in base R’s `stats` package and in `dplyr`, but these
functions serve different purposes.

We can avoid ambiguity by writing `dplyr::filter()` or `stats::filter()`
explicitly.

``` r
find("filter")
```

    ## [1] "package:stats"

``` r
getExportedValue("stats", "filter") |> typeof()
```

    ## [1] "closure"

A namespaced call is particularly helpful in reusable scripts and
textbooks. It makes the intended package visible to readers and reduces
dependence on the order in which packages were attached.

## 22.15 Package availability and robust optional code

A chapter should not fail simply because an optional library is missing.
We can test availability without attaching the package.

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  example <- tibble::tibble(x = 1:3)
  print(example)
} else {
  example <- data.frame(x = 1:3)
  print(example)
}
```

    ## # A tibble: 3 × 1
    ##       x
    ##   <int>
    ## 1     1
    ## 2     2
    ## 3     3

This pattern is suitable for **optional demonstrations**. In a
production script where a package is essential, we should instead stop
with a clear message so that we do not silently change the analysis
behavior.

## 22.16 Inspecting package versions

``` r
if (requireNamespace("tibble", quietly = TRUE)) {
  print(as.character(utils::packageVersion("tibble")))
}
```

    ## [1] "3.3.1"

``` r
R.version.string
```

    ## [1] "R version 4.5.3 (2026-03-11 ucrt)"

Software versions matter because package behavior and available
arguments can change. For collaborative projects, we should record the R
version and required package versions.

## 22.17 Importing data: base R and `readr`

`readr` provides modern import functions and tibbles. Unlike
`read.csv()`, `readr::read_csv()` uses its own parsing conventions and
type guessing. We must inspect parsing results rather than assume they
are identical.

``` r
practice_dir <- file.path(tempdir(), "r_for_everyone_ch22")
dir.create(practice_dir, recursive = TRUE, showWarnings = FALSE)
orders_path <- file.path(practice_dir, "orders.csv")
write.csv(orders, orders_path, row.names = FALSE, na = "")
orders_base_import <- read.csv(orders_path, stringsAsFactors = FALSE)
str(orders_base_import)
```

    ## 'data.frame':    6 obs. of  5 variables:
    ##  $ order_id  : chr  "O001" "O002" "O003" "O004" ...
    ##  $ customer  : chr  "Asha" "Ravi" "Mina" "Asha" ...
    ##  $ product   : chr  "Notebook" "Pen" "Notebook" "Bag" ...
    ##  $ quantity  : int  2 5 1 1 3 NA
    ##  $ unit_price: int  80 15 80 450 15 450

``` r
if (requireNamespace("readr", quietly = TRUE)) {
  orders_readr <- readr::read_csv(
    orders_path,
    show_col_types = FALSE
  )
  print(orders_readr)
  print(readr::problems(orders_readr))
}
```

    ## # A tibble: 6 × 5
    ##   order_id customer product  quantity unit_price
    ##   <chr>    <chr>    <chr>       <dbl>      <dbl>
    ## 1 O001     Asha     Notebook        2         80
    ## 2 O002     Ravi     Pen             5         15
    ## 3 O003     Mina     Notebook        1         80
    ## 4 O004     Asha     Bag             1        450
    ## 5 O005     Ravi     Pen             3         15
    ## 6 O006     Leena    Bag            NA        450
    ## # A tibble: 0 × 5
    ## # ℹ 5 variables: row <int>, col <int>, expected <chr>, actual <chr>, file <chr>

For identifiers with leading zeros, we should explicitly specify a
character column type rather than rely on automatic guessing. This
principle applies regardless of which import package we use.

## 22.18 Common beginner errors

### Error: `could not find function "tibble"`

The package may not be installed or attached. Use `tibble::tibble()`
after verifying installation, or use `library(tibble)` in an interactive
session.

### Error: `there is no package called 'tibble'`

The package is not available in the active R library. Installation may
require permission or dependency troubleshooting. Base R examples in
this chapter remain usable.

### Error: selecting one tibble column but expecting a vector

Use `[[ ]]` or `dplyr::pull()` when a vector is required.

### Error: a column name is not found

Inspect `names(data)` and check capitalization, whitespace, and
spelling. Avoid assuming that `$` always performs partial matching.

### Error: unexpected results after `group_by()`

Grouping state may persist. Use `dplyr::ungroup()` or `.groups = "drop"`
when appropriate.

### Error: function masking

Write the namespace explicitly, such as `dplyr::filter()`.

### Error: the pipe fails in an older R version

The native `|>` pipe requires R 4.1.0 or later. In older versions, use
nested functions or a compatible alternative.

### Error: printing appears to hide rows

Tibbles print a preview. The underlying rows still exist. Inspect with
`nrow()` or print an explicitly chosen subset.

------------------------------------------------------------------------

## 22.19 Guided project: a small order-processing workflow

We will complete the same task with base R and optional tidyverse
functions. The goal is to calculate a line total for each order, flag
missing quantities, and summarize sales by product.

### Step 1: define a missingness policy

We will **not** silently treat missing quantities as zero. Missing order
quantities remain `NA` in line totals. Summaries report both observed
revenue and the number of missing quantities.

``` r
orders_clean <- orders
orders_clean$line_total <- orders_clean$quantity * orders_clean$unit_price
orders_clean$quantity_missing <- is.na(orders_clean$quantity)
orders_clean
```

    ##   order_id customer  product quantity unit_price line_total quantity_missing
    ## 1     O001     Asha Notebook        2         80        160            FALSE
    ## 2     O002     Ravi      Pen        5         15         75            FALSE
    ## 3     O003     Mina Notebook        1         80         80            FALSE
    ## 4     O004     Asha      Bag        1        450        450            FALSE
    ## 5     O005     Ravi      Pen        3         15         45            FALSE
    ## 6     O006    Leena      Bag       NA        450         NA             TRUE

### Step 2: summarize in base R

``` r
products <- sort(unique(orders_clean$product))
summary_rows <- lapply(products, function(item) {
  subset_data <- orders_clean[orders_clean$product == item, , drop = FALSE]
  data.frame(
    product = item,
    orders = nrow(subset_data),
    missing_quantities = sum(subset_data$quantity_missing),
    observed_revenue = sum(subset_data$line_total, na.rm = TRUE)
  )
})
summary_base <- do.call(rbind, summary_rows)
row.names(summary_base) <- NULL
summary_base
```

    ##    product orders missing_quantities observed_revenue
    ## 1      Bag      2                  1              450
    ## 2 Notebook      2                  0              240
    ## 3      Pen      2                  0              120

### Step 3: compare with optional `dplyr`

``` r
if (requireNamespace("dplyr", quietly = TRUE)) {
  summary_dplyr <- orders |>
    dplyr::mutate(
      line_total = quantity * unit_price,
      quantity_missing = is.na(quantity)
    ) |>
    dplyr::group_by(product) |>
    dplyr::summarise(
      orders = dplyr::n(),
      missing_quantities = sum(quantity_missing),
      observed_revenue = sum(line_total, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::arrange(product)
  print(summary_dplyr)
  stopifnot(isTRUE(all.equal(
    as.data.frame(summary_dplyr), summary_base,
    check.attributes = FALSE
  )))
}
```

    ## # A tibble: 3 × 4
    ##   product  orders missing_quantities observed_revenue
    ##   <chr>     <int>              <int>            <dbl>
    ## 1 Bag           2                  1              450
    ## 2 Notebook      2                  0              240
    ## 3 Pen           2                  0              120

### Step 4: export the result

``` r
summary_path <- file.path(practice_dir, "product_summary.csv")
write.csv(summary_base, summary_path, row.names = FALSE)
stopifnot(file.exists(summary_path))
read.csv(summary_path, stringsAsFactors = FALSE)
```

    ##    product orders missing_quantities observed_revenue
    ## 1      Bag      2                  1              450
    ## 2 Notebook      2                  0              240
    ## 3      Pen      2                  0              120

### Step 5: verify the project

``` r
stopifnot(
  nrow(orders) == 6L,
  sum(is.na(orders$quantity)) == 1L,
  sum(summary_base$orders) == nrow(orders),
  sum(summary_base$missing_quantities) == 1L,
  isTRUE(all.equal(
    sum(summary_base$observed_revenue),
    sum(orders_clean$line_total, na.rm = TRUE)
  ))
)
cat("All core project checks passed.\n")
```

    ## All core project checks passed.

### Interpretation

Both programming styles can solve the task. The base R solution exposes
indexing, loops through a list, and row binding. The `dplyr` solution
expresses the same operations as a pipeline of verbs. Neither approach
removes the need to define missing-data behavior and verify results.

## 22.20 Exercises: foundational

1.  Explain the difference between the tidyverse and a tibble.
2.  Name four tidyverse packages and describe their roles.
3.  Explain installation versus attaching a package.
4.  Create a three-column base R data frame.
5.  Convert it to a tibble if the package is available.
6.  Compare `x[, "column"]` for a data frame and a tibble.
7.  Extract a column as a vector with `[[ ]]`.
8.  Explain why concise tibble printing does not mean rows were deleted.
9.  Create a tibble using `tibble::tibble()`.
10. Create a small tibble using `tribble()`.
11. Explain the three principles of tidy data.
12. Convert a tibble back to a base data frame.

## 22.21 Exercises: intermediate

1.  Construct a dataset with duplicated column names and repair them
    explicitly.
2.  Write a native-pipe expression that sorts unique numbers.
3.  Compare a nested expression with a piped expression.
4.  Explain the difference between `|>` and `%>%`.
5.  Import a CSV using base R and optionally `readr`.
6.  Preserve an identifier such as `"0007"` as character.
7.  Count missing values in every column.
8.  Select rows satisfying two logical conditions in base R.
9.  Repeat the selection with `dplyr::filter()` if installed.
10. Group a dataset by category and calculate totals.
11. Explain function masking using `filter()`.
12. Inspect installed versions of optional packages.

## 22.22 Challenge: tidy-data redesign

Create a fictional monthly attendance table with columns `employee`,
`jan`, `feb`, and `mar`. Reshape it into an employee-month table using
base R. If `tidyr` is installed, repeat the transformation with
`pivot_longer()`. Verify that both versions represent the same
observations. Explain which structure is more convenient for calculating
monthly totals and why.

## 22.23 Challenge: a reusable package-aware helper

Write a function `make_table(x, prefer_tibble = TRUE)` that:

- accepts an ordinary data frame;
- validates the input;
- returns a tibble when requested and available;
- otherwise returns a base data frame;
- never installs a package automatically;
- preserves the original number of rows and columns.

Test the function with an empty data frame and with a data frame
containing a missing value.

## 22.24 Complete standalone practice script

The following script repeats the key concepts in a fresh R session. It
is not executed during knitting because the chapter has already
demonstrated the operations.

``` r
# Chapter 22: Introduction to the Tidyverse and Tibbles
# All essential steps use base R.

orders <- data.frame(
  order_id = c("O1", "O2", "O3", "O4"),
  product = c("Pen", "Book", "Pen", "Book"),
  quantity = c(2L, 1L, NA_integer_, 3L),
  unit_price = c(10, 80, 10, 80)
)

# Base R inspection
str(orders)
print(orders[, "product", drop = FALSE])

# Native pipe
print(c(3, 1, 2, 1) |> unique() |> sort())

# Base R transformation
orders$line_total <- orders$quantity * orders$unit_price

# Base R grouped summary
summary_base <- aggregate(
  line_total ~ product,
  data = orders,
  FUN = sum,
  na.action = na.omit
)
print(summary_base)

# Optional tidyverse examples
if (requireNamespace("tibble", quietly = TRUE)) {
  tbl <- tibble::as_tibble(orders)
  print(tbl)
  print(tibble::glimpse(tbl))
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  result <- orders |>
    dplyr::group_by(product) |>
    dplyr::summarise(
      observed_revenue = sum(line_total, na.rm = TRUE),
      missing_orders = sum(is.na(quantity)),
      .groups = "drop"
    )
  print(result)
}

# Safe export
outdir <- file.path(tempdir(), "chapter22_demo")
dir.create(outdir, showWarnings = FALSE)
write.csv(orders, file.path(outdir, "orders.csv"), row.names = FALSE)

stopifnot(file.exists(file.path(outdir, "orders.csv")))
```

## 22.25 Chapter review

1.  What is the tidyverse, and why is it called an ecosystem?
2.  How does a tibble differ from a traditional data frame?
3.  When should we use `[[ ]]` rather than `[ ]`?
4.  Why do package namespaces matter?
5.  How can we write a script that runs without optional packages?
6.  What are the three principles of tidy data?
7.  What is the difference between a pipe and an assignment?
8.  Why must we define a policy for missing values before summarizing?
9.  How can we compare a base R result with a tidyverse result?
10. Why should we record package versions?

## 22.26 Key takeaways

- The tidyverse is a collection of packages, not a replacement for R.
- Tibbles are data frames with predictable printing and subsetting
  conventions.
- `[[ ]]` extracts a column vector from either a data frame or a tibble.
- `|>` helps express operations in a readable left-to-right sequence.
- Namespaced calls such as `dplyr::filter()` reduce ambiguity.
- Tidy data principles help us design consistent rectangular datasets.
- Optional packages should be checked explicitly, not installed
  automatically while knitting.
- Base R remains a strong foundation for understanding tidyverse
  operations.
- Data correctness depends on validation and explicit assumptions, not
  on package choice.

## Looking ahead: Chapter 23 — Data Manipulation with dplyr, Part I

We will study `select()`, `filter()`, `arrange()`, `mutate()`, and
`rename()` in detail, including data masking, missing-value behavior,
common errors, and base R equivalents.
