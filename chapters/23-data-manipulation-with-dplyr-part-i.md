Chapter 23 — Data Manipulation with dplyr, Part I
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In previous chapter, we introduced the tidyverse, tibbles, and pipes. We
now begin using **`dplyr`**, a package for expressing data-manipulation
tasks as readable operations. In this chapter, we learn five core verbs:
`select()`, `filter()`, `arrange()`, `mutate()`, and `rename()`. We will
also learn their close relatives and how to combine them into reliable
pipelines.

The goal is **R programming proficiency**, not statistical modelling.
Our examples use everyday retail, employee, and inventory data. Each
major operation is compared with base R so that we understand the
underlying data manipulation rather than memorizing one package’s
syntax.

> **Package note.** All essential `dplyr` examples run when `dplyr` is
> installed. If it is unavailable, the chapter still knits: the
> package-dependent chunks are skipped and base-R demonstrations remain
> executable. We can install the package separately with
> `install.packages("dplyr")` when the environment permits. We do not
> install packages automatically while knitting.

## 23.1 Learning objectives

By the end of the chapter, we should be able to:

1.  Identify the purpose and syntax of the five core `dplyr` verbs.
2.  Explain rows versus columns and the difference between selecting and
    filtering.
3.  Select, reorder, and drop columns using tidyselect helpers.
4.  Filter rows with comparisons, Boolean logic, membership, and
    missingness.
5.  Sort records with `arrange()` and `desc()`.
6.  Create and modify variables using `mutate()`.
7.  Rename columns using `rename()` and `rename_with()`.
8.  Combine operations with the native pipe `|>`.
9.  Distinguish data masking from ordinary R variable lookup.
10. Recognize common pitfalls involving `NA`, type conversion, and
    grouped data.
11. Write clear, testable, reusable data-processing functions.
12. Compare `dplyr` with equivalent base-R code.

------------------------------------------------------------------------

## 23.2 Preparing a reproducible workspace

We start with a deterministic synthetic dataset. No external files or
internet connection are needed.

``` r
has_dplyr
```

    ## [1] TRUE

If this prints `FALSE`, the `dplyr` examples are skipped rather than
failing. To follow every exercise interactively, install the package in
a working R environment.

``` r
install.packages("dplyr")
library(dplyr)
packageVersion("dplyr")
```

We will generally use `dplyr::function_name()` in code so that the
origin of a function is clear. This also avoids conflicts with similarly
named functions in other packages.

### Our practice data

``` r
orders <- data.frame(
  order_id = c("O001", "O002", "O003", "O004", "O005", "O006", "O007", "O008"),
  customer = c("Asha", "Ben", "Chen", "Dina", "Eli", "Fatima", "Gita", "Hari"),
  region = c("North", "South", "East", "North", "West", "South", "East", "North"),
  category = c("Books", "Electronics", "Books", "Home", "Electronics", "Books", "Home", "Books"),
  quantity = c(2L, 1L, 3L, 2L, 1L, 4L, NA_integer_, 1L),
  unit_price = c(250, 1800, 200, 450, 2200, 175, 300, 500),
  discount = c(0, 0.10, 0, 0.05, 0.15, NA_real_, 0, 0),
  delivered = c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, NA, TRUE),
  stringsAsFactors = FALSE
)
orders
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE

This data frame has eight rows and eight columns. Each row represents
one order. Each column represents one attribute of that order.

``` r
stopifnot(nrow(orders) == 8L, ncol(orders) == 8L)
str(orders)
```

    ## 'data.frame':    8 obs. of  8 variables:
    ##  $ order_id  : chr  "O001" "O002" "O003" "O004" ...
    ##  $ customer  : chr  "Asha" "Ben" "Chen" "Dina" ...
    ##  $ region    : chr  "North" "South" "East" "North" ...
    ##  $ category  : chr  "Books" "Electronics" "Books" "Home" ...
    ##  $ quantity  : int  2 1 3 2 1 4 NA 1
    ##  $ unit_price: num  250 1800 200 450 2200 175 300 500
    ##  $ discount  : num  0 0.1 0 0.05 0.15 NA 0 0
    ##  $ delivered : logi  TRUE FALSE TRUE TRUE FALSE TRUE ...

### A tibble version

``` r
orders_tbl <- dplyr::as_tibble(orders)
orders_tbl
```

    ## # A tibble: 8 × 8
    ##   order_id customer region category    quantity unit_price discount delivered
    ##   <chr>    <chr>    <chr>  <chr>          <int>      <dbl>    <dbl> <lgl>    
    ## 1 O001     Asha     North  Books              2        250     0    TRUE     
    ## 2 O002     Ben      South  Electronics        1       1800     0.1  FALSE    
    ## 3 O003     Chen     East   Books              3        200     0    TRUE     
    ## 4 O004     Dina     North  Home               2        450     0.05 TRUE     
    ## 5 O005     Eli      West   Electronics        1       2200     0.15 FALSE    
    ## 6 O006     Fatima   South  Books              4        175    NA    TRUE     
    ## 7 O007     Gita     East   Home              NA        300     0    NA       
    ## 8 O008     Hari     North  Books              1        500     0    TRUE

Tibbles are modern data frames. The five verbs work with both ordinary
data frames and tibbles. A tibble usually prints a compact preview and
preserves types more predictably during subsetting.

------------------------------------------------------------------------

## 23.3 Understanding the `dplyr` grammar

A useful way to remember the five verbs is to associate each with the
dimension or property it changes.

| Verb | Main question | Typical effect |
|----|----|----|
| `select()` | Which columns do we keep? | Changes columns |
| `filter()` | Which rows meet a condition? | Changes rows |
| `arrange()` | In what order should rows appear? | Reorders rows |
| `mutate()` | Which variables should we create or modify? | Adds or modifies columns |
| `rename()` | What should columns be called? | Changes names |

All five normally return a data-frame-like object. They do **not**
modify an existing object in place unless we assign the result back to a
variable.

``` r
small_orders <- dplyr::select(orders, order_id, region)
names(orders)
```

    ## [1] "order_id"   "customer"   "region"     "category"   "quantity"  
    ## [6] "unit_price" "discount"   "delivered"

``` r
names(small_orders)
```

    ## [1] "order_id" "region"

The original `orders` still contains all eight columns.

### Reading a function call

``` r
result <- dplyr::filter(orders, region == "North")
```

- `orders` is the input table.
- `region == "North"` is the row-selection condition.
- `result` receives a new table containing matching rows.

We will build from one verb at a time toward multi-step pipelines.

------------------------------------------------------------------------

## 23.4 `select()`: choosing columns

`select()` chooses columns by name, position, or a selection helper. It
does **not** filter rows.

``` r
dplyr::select(orders, order_id, customer, region)
```

    ##   order_id customer region
    ## 1     O001     Asha  North
    ## 2     O002      Ben  South
    ## 3     O003     Chen   East
    ## 4     O004     Dina  North
    ## 5     O005      Eli   West
    ## 6     O006   Fatima  South
    ## 7     O007     Gita   East
    ## 8     O008     Hari  North

### Selecting columns in a new order

``` r
dplyr::select(orders, region, customer, order_id)
```

    ##   region customer order_id
    ## 1  North     Asha     O001
    ## 2  South      Ben     O002
    ## 3   East     Chen     O003
    ## 4  North     Dina     O004
    ## 5   West      Eli     O005
    ## 6  South   Fatima     O006
    ## 7   East     Gita     O007
    ## 8  North     Hari     O008

The order of names in `select()` determines the order of the resulting
columns.

### Selecting a range of adjacent columns

``` r
dplyr::select(orders, customer:category)
```

    ##   customer region    category
    ## 1     Asha  North       Books
    ## 2      Ben  South Electronics
    ## 3     Chen   East       Books
    ## 4     Dina  North        Home
    ## 5      Eli   West Electronics
    ## 6   Fatima  South       Books
    ## 7     Gita   East        Home
    ## 8     Hari  North       Books

Here, `:` refers to the inclusive span of columns **in the current
column order**. It is not a numeric sequence of values inside the
columns.

### Excluding columns with a minus sign

``` r
dplyr::select(orders, -discount, -delivered)
```

    ##   order_id customer region    category quantity unit_price
    ## 1     O001     Asha  North       Books        2        250
    ## 2     O002      Ben  South Electronics        1       1800
    ## 3     O003     Chen   East       Books        3        200
    ## 4     O004     Dina  North        Home        2        450
    ## 5     O005      Eli   West Electronics        1       2200
    ## 6     O006   Fatima  South       Books        4        175
    ## 7     O007     Gita   East        Home       NA        300
    ## 8     O008     Hari  North       Books        1        500

This keeps all columns except `discount` and `delivered`.

### Selecting by position

``` r
dplyr::select(orders, 1:3)
```

    ##   order_id customer region
    ## 1     O001     Asha  North
    ## 2     O002      Ben  South
    ## 3     O003     Chen   East
    ## 4     O004     Dina  North
    ## 5     O005      Eli   West
    ## 6     O006   Fatima  South
    ## 7     O007     Gita   East
    ## 8     O008     Hari  North

Column positions can be convenient in exploration but are fragile if the
dataset’s column order changes. For scripts shared across projects,
explicit names are usually safer.

### Base-R equivalent

``` r
orders[c("order_id", "customer", "region")]
```

    ##   order_id customer region
    ## 1     O001     Asha  North
    ## 2     O002      Ben  South
    ## 3     O003     Chen   East
    ## 4     O004     Dina  North
    ## 5     O005      Eli   West
    ## 6     O006   Fatima  South
    ## 7     O007     Gita   East
    ## 8     O008     Hari  North

The base-R and `dplyr` versions express the same column-selection
operation.

------------------------------------------------------------------------

## 23.5 Tidyselect helpers

Real tables often have dozens or hundreds of columns. Tidyselect helpers
let us express selection patterns without manually listing every
variable.

### `starts_with()`

``` r
dplyr::select(orders, tidyselect::starts_with("unit"))
```

    ##   unit_price
    ## 1        250
    ## 2       1800
    ## 3        200
    ## 4        450
    ## 5       2200
    ## 6        175
    ## 7        300
    ## 8        500

### `ends_with()`

``` r
dplyr::select(orders, tidyselect::ends_with("id"))
```

    ##   order_id
    ## 1     O001
    ## 2     O002
    ## 3     O003
    ## 4     O004
    ## 5     O005
    ## 6     O006
    ## 7     O007
    ## 8     O008

### `contains()`

``` r
dplyr::select(orders, tidyselect::contains("price"))
```

    ##   unit_price
    ## 1        250
    ## 2       1800
    ## 3        200
    ## 4        450
    ## 5       2200
    ## 6        175
    ## 7        300
    ## 8        500

### `matches()`

`matches()` accepts a regular expression, building on Chapter 19.

``` r
dplyr::select(orders, tidyselect::matches("^(order|unit)"))
```

    ##   order_id unit_price
    ## 1     O001        250
    ## 2     O002       1800
    ## 3     O003        200
    ## 4     O004        450
    ## 5     O005       2200
    ## 6     O006        175
    ## 7     O007        300
    ## 8     O008        500

The expression `^(order|unit)` matches names beginning with `order` or
`unit`.

### `everything()`

``` r
dplyr::select(orders, customer, tidyselect::everything())
```

    ##   customer order_id region    category quantity unit_price discount delivered
    ## 1     Asha     O001  North       Books        2        250     0.00      TRUE
    ## 2      Ben     O002  South Electronics        1       1800     0.10     FALSE
    ## 3     Chen     O003   East       Books        3        200     0.00      TRUE
    ## 4     Dina     O004  North        Home        2        450     0.05      TRUE
    ## 5      Eli     O005   West Electronics        1       2200     0.15     FALSE
    ## 6   Fatima     O006  South       Books        4        175       NA      TRUE
    ## 7     Gita     O007   East        Home       NA        300     0.00        NA
    ## 8     Hari     O008  North       Books        1        500     0.00      TRUE

This moves `customer` to the first position while retaining the other
columns.

### `all_of()` and `any_of()`

When column names are stored in a character vector, use `all_of()` or
`any_of()`.

``` r
requested <- c("order_id", "region", "quantity")
dplyr::select(orders, tidyselect::all_of(requested))
```

    ##   order_id region quantity
    ## 1     O001  North        2
    ## 2     O002  South        1
    ## 3     O003   East        3
    ## 4     O004  North        2
    ## 5     O005   West        1
    ## 6     O006  South        4
    ## 7     O007   East       NA
    ## 8     O008  North        1

`all_of()` requires every requested column to exist. `any_of()` silently
ignores absent names.

``` r
optional <- c("order_id", "region", "not_present")
dplyr::select(orders, tidyselect::any_of(optional))
```

    ##   order_id region
    ## 1     O001  North
    ## 2     O002  South
    ## 3     O003   East
    ## 4     O004  North
    ## 5     O005   West
    ## 6     O006  South
    ## 7     O007   East
    ## 8     O008  North

**Practical rule:** Use `all_of()` for mandatory schema fields and
`any_of()` when absent fields are genuinely optional. Silently ignoring
missing required fields can conceal a broken data pipeline.

### `where()` for selecting by type

``` r
dplyr::select(orders, tidyselect::where(is.numeric))
```

    ##   quantity unit_price discount
    ## 1        2        250     0.00
    ## 2        1       1800     0.10
    ## 3        3        200     0.00
    ## 4        2        450     0.05
    ## 5        1       2200     0.15
    ## 6        4        175       NA
    ## 7       NA        300     0.00
    ## 8        1        500     0.00

`quantity`, `unit_price`, and `discount` are numeric-type columns. We
can combine selection helpers:

``` r
dplyr::select(orders, order_id, tidyselect::where(is.numeric))
```

    ##   order_id quantity unit_price discount
    ## 1     O001        2        250     0.00
    ## 2     O002        1       1800     0.10
    ## 3     O003        3        200     0.00
    ## 4     O004        2        450     0.05
    ## 5     O005        1       2200     0.15
    ## 6     O006        4        175       NA
    ## 7     O007       NA        300     0.00
    ## 8     O008        1        500     0.00

### A common mistake: external character vectors

Avoid assuming that `select(orders, requested)` always means “select the
columns whose names are stored in `requested`.” In programming,
`all_of(requested)` makes this intent explicit and avoids ambiguity.

------------------------------------------------------------------------

## 23.6 `filter()`: choosing rows

`filter()` retains rows for which the supplied condition evaluates to
`TRUE`.

``` r
dplyr::filter(orders, region == "North")
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 3     O008     Hari  North    Books        1        500     0.00      TRUE

Notice the **double equals sign**: `==` compares values. A single `=` is
not the appropriate comparison operator.

### Numeric comparisons

``` r
dplyr::filter(orders, unit_price >= 500)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE

Other comparisons include `<`, `<=`, `>`, `!=`, and `==`.

### Multiple conditions: AND

``` r
dplyr::filter(orders, region == "North", unit_price >= 400)
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 2     O008     Hari  North    Books        1        500     0.00      TRUE

Separate conditions inside `filter()` are combined with logical AND. We
can also write:

``` r
dplyr::filter(orders, region == "North" & unit_price >= 400)
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 2     O008     Hari  North    Books        1        500     0.00      TRUE

### OR conditions

``` r
dplyr::filter(orders, region == "North" | region == "East")
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O007     Gita   East     Home       NA        300     0.00        NA
    ## 5     O008     Hari  North    Books        1        500     0.00      TRUE

### Membership with `%in%`

``` r
dplyr::filter(orders, region %in% c("North", "East"))
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O007     Gita   East     Home       NA        300     0.00        NA
    ## 5     O008     Hari  North    Books        1        500     0.00      TRUE

Membership is often clearer than a long series of OR comparisons.

### Negation

``` r
dplyr::filter(orders, region != "South")
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 4     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 5     O007     Gita   East        Home       NA        300     0.00        NA
    ## 6     O008     Hari  North       Books        1        500     0.00      TRUE

Or:

``` r
dplyr::filter(orders, !(region %in% c("South", "West")))
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O007     Gita   East     Home       NA        300     0.00        NA
    ## 5     O008     Hari  North    Books        1        500     0.00      TRUE

### `between()` for inclusive ranges

``` r
dplyr::filter(orders, dplyr::between(unit_price, 200, 500))
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O007     Gita   East     Home       NA        300     0.00        NA
    ## 5     O008     Hari  North    Books        1        500     0.00      TRUE

Both endpoints are included.

### Base-R equivalent

``` r
orders[orders$region == "North", , drop = FALSE]
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 4     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 8     O008     Hari  North    Books        1        500     0.00      TRUE

In base R, the comma separates row and column selection. In `dplyr`, the
intent is expressed by the verb name.

------------------------------------------------------------------------

## 23.7 Missing values in `filter()`

Missing values require special care. In R, a comparison involving `NA`
usually returns `NA`, not `TRUE` or `FALSE`.

``` r
NA_real_ >= 2
```

    ## [1] NA

``` r
is.na(NA_real_)
```

    ## [1] TRUE

`filter()` keeps only rows whose condition is `TRUE`; rows yielding
`FALSE` **or `NA`** are dropped.

``` r
dplyr::filter(orders, quantity >= 2)
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O006   Fatima  South    Books        4        175       NA      TRUE

The order with missing `quantity` is not retained.

### Keep missing values explicitly

``` r
dplyr::filter(orders, quantity >= 2 | is.na(quantity))
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East    Books        3        200     0.00      TRUE
    ## 3     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 4     O006   Fatima  South    Books        4        175       NA      TRUE
    ## 5     O007     Gita   East     Home       NA        300     0.00        NA

### Select missing values

``` r
dplyr::filter(orders, is.na(quantity))
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O007     Gita   East     Home       NA        300        0        NA

### Select nonmissing values

``` r
dplyr::filter(orders, !is.na(discount))
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O007     Gita   East        Home       NA        300     0.00        NA
    ## 7     O008     Hari  North       Books        1        500     0.00      TRUE

### Why `quantity == NA` is wrong

``` r
orders$quantity == NA_integer_
```

    ## [1] NA NA NA NA NA NA NA NA

The result is missing logical values, not a test for missingness. Use
`is.na(quantity)`.

### A robust count check

``` r
nonmissing_qty <- dplyr::filter(orders, !is.na(quantity))
stopifnot(nrow(nonmissing_qty) == sum(!is.na(orders$quantity)))
```

------------------------------------------------------------------------

## 23.8 Filtering text and dates

We can filter text with exact matching, membership, and pattern
detection.

``` r
dplyr::filter(orders, category == "Books")
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250        0      TRUE
    ## 2     O003     Chen   East    Books        3        200        0      TRUE
    ## 3     O006   Fatima  South    Books        4        175       NA      TRUE
    ## 4     O008     Hari  North    Books        1        500        0      TRUE

For a pattern, base R’s `grepl()` works inside `filter()`:

``` r
dplyr::filter(orders, grepl("^E", category))
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE

This selects categories starting with `E`.

### Date filtering

``` r
tasks <- data.frame(
  task = c("Draft", "Review", "Publish"),
  due = as.Date(c("2026-11-01", "2026-11-10", "2026-11-20"))
)
tasks
```

    ##      task        due
    ## 1   Draft 2026-11-01
    ## 2  Review 2026-11-10
    ## 3 Publish 2026-11-20

``` r
dplyr::filter(tasks, due <= as.Date("2026-11-10"))
```

    ##     task        due
    ## 1  Draft 2026-11-01
    ## 2 Review 2026-11-10

We should compare `Date` objects to dates, not rely on unverified
character-string ordering.

------------------------------------------------------------------------

## 23.9 `arrange()`: sorting rows

`arrange()` orders rows according to one or more columns.

``` r
dplyr::arrange(orders, unit_price)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 2     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 3     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 4     O007     Gita   East        Home       NA        300     0.00        NA
    ## 5     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 6     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 7     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 8     O005      Eli   West Electronics        1       2200     0.15     FALSE

Ascending order is the default.

### Descending order

``` r
dplyr::arrange(orders, dplyr::desc(unit_price))
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O007     Gita   East        Home       NA        300     0.00        NA
    ## 6     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 7     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 8     O006   Fatima  South       Books        4        175       NA      TRUE

### Multiple sorting keys

``` r
dplyr::arrange(orders, region, dplyr::desc(unit_price))
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O007     Gita   East        Home       NA        300     0.00        NA
    ## 2     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 6     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 7     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 8     O005      Eli   West Electronics        1       2200     0.15     FALSE

This first orders by `region` and then orders prices from high to low
within each region.

### Missing values and sorting

``` r
dplyr::arrange(orders, quantity)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 4     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 5     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 6     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 7     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 8     O007     Gita   East        Home       NA        300     0.00        NA

For local data frames, missing values are generally placed at the end by
`dplyr::arrange()`. Database-backed tables may have different ordering
semantics; we will revisit that in the database chapter.

### Base-R equivalent

``` r
orders[order(orders$unit_price), , drop = FALSE]
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE

### Deterministic tie-breaking

When several rows have the same sort key, include a secondary key if the
exact row order matters.

``` r
dplyr::arrange(orders, category, order_id)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 3     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 4     O008     Hari  North       Books        1        500     0.00      TRUE
    ## 5     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 6     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 7     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 8     O007     Gita   East        Home       NA        300     0.00        NA

------------------------------------------------------------------------

## 23.10 `mutate()`: creating and changing columns

`mutate()` adds new variables or replaces existing ones.

``` r
orders_with_gross <- dplyr::mutate(
  orders,
  gross_amount = quantity * unit_price
)
orders_with_gross
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   gross_amount
    ## 1          500
    ## 2         1800
    ## 3          600
    ## 4          900
    ## 5         2200
    ## 6          700
    ## 7           NA
    ## 8          500

### Multiple derived columns

``` r
orders_calculated <- dplyr::mutate(
  orders,
  gross_amount = quantity * unit_price,
  discount_amount = gross_amount * discount,
  net_amount = gross_amount - discount_amount
)
orders_calculated
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   gross_amount discount_amount net_amount
    ## 1          500               0        500
    ## 2         1800             180       1620
    ## 3          600               0        600
    ## 4          900              45        855
    ## 5         2200             330       1870
    ## 6          700              NA         NA
    ## 7           NA              NA         NA
    ## 8          500               0        500

Later expressions in the same `mutate()` call can refer to columns
created earlier in that call.

### What happens with missing values?

If `quantity` or `discount` is missing, the corresponding calculation
may produce `NA`.

``` r
dplyr::select(orders_calculated, order_id, gross_amount, discount_amount, net_amount)
```

    ##   order_id gross_amount discount_amount net_amount
    ## 1     O001          500               0        500
    ## 2     O002         1800             180       1620
    ## 3     O003          600               0        600
    ## 4     O004          900              45        855
    ## 5     O005         2200             330       1870
    ## 6     O006          700              NA         NA
    ## 7     O007           NA              NA         NA
    ## 8     O008          500               0        500

This is usually preferable to silently replacing unknown values with
zero.

### Explicitly replacing missing values when justified

``` r
orders_discount_policy <- dplyr::mutate(
  orders,
  discount_assumed_zero = ifelse(is.na(discount), 0, discount),
  net_amount = quantity * unit_price * (1 - discount_assumed_zero)
)
orders_discount_policy
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   discount_assumed_zero net_amount
    ## 1                  0.00        500
    ## 2                  0.10       1620
    ## 3                  0.00        600
    ## 4                  0.05        855
    ## 5                  0.15       1870
    ## 6                  0.00        700
    ## 7                  0.00         NA
    ## 8                  0.00        500

**Important:** This is a demonstration of a hypothetical business rule.
We should only replace missing discounts with zero if that is the
documented policy. Missing does not automatically mean zero.

------------------------------------------------------------------------

## 23.11 Conditional columns with `if_else()` and `case_when()`

A common task is to create a category from another variable.

### `if_else()`

``` r
orders_labelled <- dplyr::mutate(
  orders,
  price_band = dplyr::if_else(
    unit_price >= 1000,
    "High",
    "Standard"
  )
)
orders_labelled
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   price_band
    ## 1   Standard
    ## 2       High
    ## 3   Standard
    ## 4   Standard
    ## 5       High
    ## 6   Standard
    ## 7   Standard
    ## 8   Standard

`dplyr::if_else()` is type-conscious and supports explicit handling of
missing conditions.

### Handling missing conditions

``` r
orders_delivery <- dplyr::mutate(
  orders,
  delivery_label = dplyr::if_else(
    delivered,
    "Delivered",
    "Pending",
    missing = "Unknown"
  )
)
orders_delivery
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   delivery_label
    ## 1      Delivered
    ## 2        Pending
    ## 3      Delivered
    ## 4      Delivered
    ## 5        Pending
    ## 6      Delivered
    ## 7        Unknown
    ## 8      Delivered

### `case_when()` for multiple categories

``` r
orders_bands <- dplyr::mutate(
  orders,
  price_band = dplyr::case_when(
    unit_price < 300 ~ "Low",
    unit_price < 1000 ~ "Medium",
    unit_price >= 1000 ~ "High",
    .default = "Unknown"
  )
)
orders_bands
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   price_band
    ## 1        Low
    ## 2       High
    ## 3        Low
    ## 4     Medium
    ## 5       High
    ## 6        Low
    ## 7     Medium
    ## 8     Medium

Conditions are evaluated in order; the first matching condition
determines the result. The final default protects against unmatched
cases.

### A subtlety with `case_when()`

A broad condition placed first can make later conditions unreachable. We
should order conditions from specific to general and test boundary
values.

``` r
stopifnot(
  orders_bands$price_band[orders_bands$unit_price == 250][1] == "Low",
  orders_bands$price_band[orders_bands$unit_price == 1800][1] == "High"
)
```

------------------------------------------------------------------------

## 23.12 Controlling where new columns appear

By default, new columns are generally added at the end. `mutate()`
supports `.before` and `.after`.

``` r
dplyr::mutate(
  orders,
  gross_amount = quantity * unit_price,
  .after = unit_price
)
```

    ##   order_id customer region    category quantity unit_price gross_amount
    ## 1     O001     Asha  North       Books        2        250          500
    ## 2     O002      Ben  South Electronics        1       1800         1800
    ## 3     O003     Chen   East       Books        3        200          600
    ## 4     O004     Dina  North        Home        2        450          900
    ## 5     O005      Eli   West Electronics        1       2200         2200
    ## 6     O006   Fatima  South       Books        4        175          700
    ## 7     O007     Gita   East        Home       NA        300           NA
    ## 8     O008     Hari  North       Books        1        500          500
    ##   discount delivered
    ## 1     0.00      TRUE
    ## 2     0.10     FALSE
    ## 3     0.00      TRUE
    ## 4     0.05      TRUE
    ## 5     0.15     FALSE
    ## 6       NA      TRUE
    ## 7     0.00        NA
    ## 8     0.00      TRUE

We can also keep only newly created columns and explicitly requested
originals with `.keep`:

``` r
dplyr::mutate(
  orders,
  gross_amount = quantity * unit_price,
  .keep = "used"
)
```

    ##   quantity unit_price gross_amount
    ## 1        2        250          500
    ## 2        1       1800         1800
    ## 3        3        200          600
    ## 4        2        450          900
    ## 5        1       2200         2200
    ## 6        4        175          700
    ## 7       NA        300           NA
    ## 8        1        500          500

`.keep = "used"` retains the input columns used to construct the new
variable along with the new variable. It can make intermediate
calculations easier to inspect.

------------------------------------------------------------------------

## 23.13 `rename()`: changing column names

The syntax of `rename()` is **new_name = old_name**.

``` r
dplyr::rename(
  orders,
  price_per_unit = unit_price,
  units_ordered = quantity
)
```

    ##   order_id customer region    category units_ordered price_per_unit discount
    ## 1     O001     Asha  North       Books             2            250     0.00
    ## 2     O002      Ben  South Electronics             1           1800     0.10
    ## 3     O003     Chen   East       Books             3            200     0.00
    ## 4     O004     Dina  North        Home             2            450     0.05
    ## 5     O005      Eli   West Electronics             1           2200     0.15
    ## 6     O006   Fatima  South       Books             4            175       NA
    ## 7     O007     Gita   East        Home            NA            300     0.00
    ## 8     O008     Hari  North       Books             1            500     0.00
    ##   delivered
    ## 1      TRUE
    ## 2     FALSE
    ## 3      TRUE
    ## 4      TRUE
    ## 5     FALSE
    ## 6      TRUE
    ## 7        NA
    ## 8      TRUE

The values are unchanged; only column names change.

### Compare with base R

``` r
base_renamed <- orders
names(base_renamed)[names(base_renamed) == "unit_price"] <- "price_per_unit"
names(base_renamed)
```

    ## [1] "order_id"       "customer"       "region"         "category"      
    ## [5] "quantity"       "price_per_unit" "discount"       "delivered"

### `rename_with()` for systematic renaming

``` r
dplyr::rename_with(orders, toupper)
```

    ##   ORDER_ID CUSTOMER REGION    CATEGORY QUANTITY UNIT_PRICE DISCOUNT DELIVERED
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE

This converts every column name to uppercase.

``` r
dplyr::rename_with(
  orders,
  toupper,
  .cols = tidyselect::starts_with("unit")
)
```

    ##   order_id customer region    category quantity UNIT_PRICE discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA
    ## 8     O008     Hari  North       Books        1        500     0.00      TRUE

Only selected column names are transformed.

### Why naming conventions matter

Consistent names reduce typing errors and make code easier to maintain.
For many projects, lowercase `snake_case` names are convenient, but we
should preserve external schemas when downstream systems require exact
names.

------------------------------------------------------------------------

## 23.14 Combining verbs with pipes

A pipeline passes the result of one operation into the next.

Without a pipe:

``` r
step1 <- dplyr::filter(orders, region == "North")
step2 <- dplyr::select(step1, order_id, category, quantity, unit_price)
step3 <- dplyr::arrange(step2, dplyr::desc(unit_price))
step3
```

    ##   order_id category quantity unit_price
    ## 1     O008    Books        1        500
    ## 2     O004     Home        2        450
    ## 3     O001    Books        2        250

Using the native R pipe `|>`:

``` r
orders |>
  dplyr::filter(region == "North") |>
  dplyr::select(order_id, category, quantity, unit_price) |>
  dplyr::arrange(dplyr::desc(unit_price))
```

    ##   order_id category quantity unit_price
    ## 1     O008    Books        1        500
    ## 2     O004     Home        2        450
    ## 3     O001    Books        2        250

The native pipe is available in R 4.1 and later. The examples in this
chapter use it because the syntax is clear and does not require
attaching another package.

### Reading a pipeline from top to bottom

1.  Begin with the `orders` table.
2.  Keep only North-region rows.
3.  Keep four columns.
4.  Sort by descending unit price.

This stepwise description is the main readability advantage of
pipelines.

### A pipeline that creates a variable

``` r
order_view <- orders |>
  dplyr::filter(!is.na(quantity), !is.na(discount)) |>
  dplyr::mutate(net_amount = quantity * unit_price * (1 - discount)) |>
  dplyr::select(order_id, region, category, net_amount) |>
  dplyr::arrange(dplyr::desc(net_amount))

order_view
```

    ##   order_id region    category net_amount
    ## 1     O005   West Electronics       1870
    ## 2     O002  South Electronics       1620
    ## 3     O004  North        Home        855
    ## 4     O003   East       Books        600
    ## 5     O001  North       Books        500
    ## 6     O008  North       Books        500

We can inspect each intermediate stage while debugging rather than
treating a long pipeline as an indivisible expression.

------------------------------------------------------------------------

## 23.15 `dplyr` does not automatically change the original table

``` r
updated <- dplyr::mutate(orders, fee = 25)
"fee" %in% names(orders)
```

    ## [1] FALSE

``` r
"fee" %in% names(updated)
```

    ## [1] TRUE

To replace the original variable, we must assign the returned table:

``` r
orders <- dplyr::mutate(orders, fee = 25)
```

We avoid doing that in the teaching dataset because later examples
expect the original columns.

------------------------------------------------------------------------

## 23.16 Data masking: why column names work without `$`

In base R, we often write:

``` r
orders$unit_price > 500
```

    ## [1] FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE FALSE

In `dplyr`, many verbs evaluate expressions in a **data mask**, where
column names are available directly:

``` r
dplyr::filter(orders, unit_price > 500)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE

This convenience introduces a programming issue: what if an external R
variable has the same name as a column?

### Explicit `.data` and `.env` pronouns

``` r
minimum_price <- 500

dplyr::filter(
  orders,
  .data$unit_price > .env$minimum_price
)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE

- `.data$unit_price` explicitly means the column in the input table.
- `.env$minimum_price` explicitly means the variable in the surrounding
  R environment.

This is particularly valuable inside reusable functions.

### A function with a configurable threshold

``` r
filter_expensive_orders <- function(data, minimum_price) {
  stopifnot(
    is.data.frame(data),
    is.numeric(minimum_price),
    length(minimum_price) == 1L,
    !is.na(minimum_price)
  )

  dplyr::filter(
    data,
    .data$unit_price >= .env$minimum_price
  )
}

filter_expensive_orders(orders, 1000)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE

**Important:** `.data` is a special pronoun provided within the tidy
evaluation context. We should not assume it is an ordinary object
available outside the verb.

------------------------------------------------------------------------

## 23.17 Column names stored in variables

Sometimes a function receives the name of a column as a character
string. Use `.data[[column_name]]` to refer to it safely.

``` r
filter_by_minimum <- function(data, column_name, minimum) {
  if (!is.character(column_name) || length(column_name) != 1L ||
      is.na(column_name) || !(column_name %in% names(data))) {
    stop("column_name must identify one existing column.")
  }
  if (!is.numeric(minimum) || length(minimum) != 1L || is.na(minimum)) {
    stop("minimum must be one nonmissing numeric value.")
  }
  if (!is.numeric(data[[column_name]])) {
    stop("The selected column must be numeric.")
  }

  dplyr::filter(data, .data[[column_name]] >= .env$minimum)
}

filter_by_minimum(orders, "unit_price", 500)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 2     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE

This is different from tidyselect’s `all_of()` because we are referring
to **values within a column**, not selecting a set of columns.

------------------------------------------------------------------------

## 23.18 Selecting versus filtering: a frequent confusion

Consider the following two commands:

``` r
dplyr::select(orders, region)
```

    ##   region
    ## 1  North
    ## 2  South
    ## 3   East
    ## 4  North
    ## 5   West
    ## 6  South
    ## 7   East
    ## 8  North

``` r
dplyr::filter(orders, region == "North")
```

    ##   order_id customer region category quantity unit_price discount delivered
    ## 1     O001     Asha  North    Books        2        250     0.00      TRUE
    ## 2     O004     Dina  North     Home        2        450     0.05      TRUE
    ## 3     O008     Hari  North    Books        1        500     0.00      TRUE

The first returns all eight rows but only one column. The second returns
fewer rows while retaining the original columns.

``` r
stopifnot(
  nrow(dplyr::select(orders, region)) == nrow(orders),
  ncol(dplyr::select(orders, region)) == 1L,
  nrow(dplyr::filter(orders, region == "North")) == 3L,
  ncol(dplyr::filter(orders, region == "North")) == ncol(orders)
)
```

A helpful mnemonic is **select columns, filter rows**.

------------------------------------------------------------------------

## 23.19 Related verbs: `relocate()` and `distinct()`

Although our main focus is the five core verbs, two related functions
are common in everyday data manipulation.

### `relocate()` moves columns

``` r
dplyr::relocate(orders, region, .before = customer)
```

    ##   order_id region customer    category quantity unit_price discount delivered
    ## 1     O001  North     Asha       Books        2        250     0.00      TRUE
    ## 2     O002  South      Ben Electronics        1       1800     0.10     FALSE
    ## 3     O003   East     Chen       Books        3        200     0.00      TRUE
    ## 4     O004  North     Dina        Home        2        450     0.05      TRUE
    ## 5     O005   West      Eli Electronics        1       2200     0.15     FALSE
    ## 6     O006  South   Fatima       Books        4        175       NA      TRUE
    ## 7     O007   East     Gita        Home       NA        300     0.00        NA
    ## 8     O008  North     Hari       Books        1        500     0.00      TRUE

Unlike `select()`, `relocate()` is designed specifically to change
column positions without dropping the other columns.

### `distinct()` removes duplicate combinations

``` r
dplyr::distinct(orders, region)
```

    ##   region
    ## 1  North
    ## 2  South
    ## 3   East
    ## 4   West

This returns one row for each distinct region.

``` r
dplyr::distinct(orders, region, category, .keep_all = TRUE)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O006   Fatima  South       Books        4        175       NA      TRUE
    ## 7     O007     Gita   East        Home       NA        300     0.00        NA

`.keep_all = TRUE` keeps the other columns from the first encountered
row of each distinct combination. This is **not** a substitute for
deciding which duplicate record is authoritative.

------------------------------------------------------------------------

## 23.20 Related verbs: `slice()` and row positions

`slice()` chooses rows by their positions.

``` r
dplyr::slice(orders, 1:3)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250      0.0      TRUE
    ## 2     O002      Ben  South Electronics        1       1800      0.1     FALSE
    ## 3     O003     Chen   East       Books        3        200      0.0      TRUE

For the highest prices, `slice_max()` is more expressive than manually
sorting and slicing:

``` r
dplyr::slice_max(orders, order_by = unit_price, n = 3, with_ties = FALSE)
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O008     Hari  North       Books        1        500     0.00      TRUE

`with_ties = FALSE` limits the result to the requested number of rows
when ties occur; if ties matter, we should define a deliberate policy
rather than discard them silently.

------------------------------------------------------------------------

## 23.21 Combining `mutate()` with string and date functions

The previous chapters remain useful inside `dplyr`.

### Clean text

``` r
contacts <- data.frame(
  name = c("  ASHA  ", "ben", " Chen "),
  city = c("north", "SOUTH", "East")
)
contacts
```

    ##       name  city
    ## 1   ASHA   north
    ## 2      ben SOUTH
    ## 3    Chen   East

``` r
dplyr::mutate(
  contacts,
  name = trimws(name),
  name = tools::toTitleCase(tolower(name)),
  city = toupper(city)
)
```

    ##   name  city
    ## 1 Asha NORTH
    ## 2  Ben SOUTH
    ## 3 Chen  EAST

### Derive date components

``` r
shipments <- data.frame(
  shipment_id = c("S1", "S2", "S3"),
  shipped_on = as.Date(c("2026-01-03", "2026-02-14", "2026-02-28"))
)
```

``` r
dplyr::mutate(
  shipments,
  shipment_month = format(shipped_on, "%Y-%m"),
  shipment_weekday = weekdays(shipped_on)
)
```

    ##   shipment_id shipped_on shipment_month shipment_weekday
    ## 1          S1 2026-01-03        2026-01         Saturday
    ## 2          S2 2026-02-14        2026-02         Saturday
    ## 3          S3 2026-02-28        2026-02         Saturday

We do not need a separate package for every transformation. Base R
functions work naturally within `mutate()`.

------------------------------------------------------------------------

## 23.22 Common errors and how to fix them

### Error: a misspelled column

``` r
# Not executed: the column does not exist.
# dplyr::select(orders, unit_prce)
```

Inspect `names(orders)` and use `all_of()` for required dynamic column
selections.

### Error: using `=` instead of `==` for comparison

``` r
# Incorrect intention:
# dplyr::filter(orders, region = "North")

# Correct:
# dplyr::filter(orders, region == "North")
```

### Error: `NA` comparisons

``` r
# Incorrect:
# dplyr::filter(orders, discount == NA)

# Correct:
# dplyr::filter(orders, is.na(discount))
```

### Error: forgetting to assign a result

``` r
# This returns a modified table but does not replace orders:
# dplyr::mutate(orders, total = quantity * unit_price)

# Assignment is needed if we want to retain the result:
# orders_new <- dplyr::mutate(orders, total = quantity * unit_price)
```

### Error: dropping rows with missing conditions

Remember that `filter()` drops both `FALSE` and `NA` conditions. Include
`is.na()` explicitly if missing records should remain.

### Error: package function conflicts

Some packages export functions named `filter()` or `lag()`. Use
`dplyr::filter()` when ambiguity is possible.

### Error: unintended type changes

After creating a variable, inspect `str()` and validate its values. In
particular, text labels, factors, dates, and numeric columns should
retain intended types.

------------------------------------------------------------------------

## 23.23 A complete practical project: order processing

We now combine all five verbs in a small, realistic programming
workflow.

### Task

We need a report that:

1.  Starts with the original order table.
2.  Retains rows with known quantities and discounts.
3.  Computes gross and net amounts.
4.  Creates a delivery label.
5.  Renames the price column.
6.  Keeps only useful report columns.
7.  Sorts orders by net amount.
8.  Validates the output.

### Step 1: filter incomplete financial records

``` r
complete_orders <- orders |>
  dplyr::filter(!is.na(quantity), !is.na(discount))

complete_orders
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O008     Hari  North       Books        1        500     0.00      TRUE

We have excluded incomplete financial rows for this specific report. In
a production pipeline, we would also record and investigate the excluded
records.

### Step 2: derive amounts

``` r
calculated_orders <- complete_orders |>
  dplyr::mutate(
    gross_amount = quantity * unit_price,
    discount_amount = gross_amount * discount,
    net_amount = gross_amount - discount_amount
  )

calculated_orders
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   gross_amount discount_amount net_amount
    ## 1          500               0        500
    ## 2         1800             180       1620
    ## 3          600               0        600
    ## 4          900              45        855
    ## 5         2200             330       1870
    ## 6          500               0        500

### Step 3: label delivery status

``` r
labelled_orders <- calculated_orders |>
  dplyr::mutate(
    delivery_status = dplyr::if_else(
      delivered,
      "Delivered",
      "Pending",
      missing = "Unknown"
    )
  )

labelled_orders
```

    ##   order_id customer region    category quantity unit_price discount delivered
    ## 1     O001     Asha  North       Books        2        250     0.00      TRUE
    ## 2     O002      Ben  South Electronics        1       1800     0.10     FALSE
    ## 3     O003     Chen   East       Books        3        200     0.00      TRUE
    ## 4     O004     Dina  North        Home        2        450     0.05      TRUE
    ## 5     O005      Eli   West Electronics        1       2200     0.15     FALSE
    ## 6     O008     Hari  North       Books        1        500     0.00      TRUE
    ##   gross_amount discount_amount net_amount delivery_status
    ## 1          500               0        500       Delivered
    ## 2         1800             180       1620         Pending
    ## 3          600               0        600       Delivered
    ## 4          900              45        855       Delivered
    ## 5         2200             330       1870         Pending
    ## 6          500               0        500       Delivered

### Step 4: rename, select, and sort

``` r
final_report <- labelled_orders |>
  dplyr::rename(price_per_unit = unit_price) |>
  dplyr::select(
    order_id, customer, region, category,
    quantity, price_per_unit, net_amount, delivery_status
  ) |>
  dplyr::arrange(dplyr::desc(net_amount), order_id)

final_report
```

    ##   order_id customer region    category quantity price_per_unit net_amount
    ## 1     O005      Eli   West Electronics        1           2200       1870
    ## 2     O002      Ben  South Electronics        1           1800       1620
    ## 3     O004     Dina  North        Home        2            450        855
    ## 4     O003     Chen   East       Books        3            200        600
    ## 5     O001     Asha  North       Books        2            250        500
    ## 6     O008     Hari  North       Books        1            500        500
    ##   delivery_status
    ## 1         Pending
    ## 2         Pending
    ## 3       Delivered
    ## 4       Delivered
    ## 5       Delivered
    ## 6       Delivered

### Step 5: validate the result

``` r
stopifnot(
  nrow(final_report) == sum(!is.na(orders$quantity) & !is.na(orders$discount)),
  !anyNA(final_report$net_amount),
  all(final_report$net_amount >= 0),
  all(diff(final_report$net_amount) <= 0),
  !anyDuplicated(final_report$order_id)
)
```

### Step 6: compare with base R

``` r
base_complete <- orders[
  !is.na(orders$quantity) & !is.na(orders$discount),
  , drop = FALSE
]
base_complete$net_amount <-
  base_complete$quantity * base_complete$unit_price *
  (1 - base_complete$discount)
base_complete <- base_complete[
  order(-base_complete$net_amount, base_complete$order_id),
  , drop = FALSE
]
row.names(base_complete) <- NULL
base_complete[c("order_id", "net_amount")]
```

    ##   order_id net_amount
    ## 1     O005       1870
    ## 2     O002       1620
    ## 3     O004        855
    ## 4     O003        600
    ## 5     O001        500
    ## 6     O008        500

### Step 7: verify equivalent calculations

``` r
stopifnot(
  identical(final_report$order_id, base_complete$order_id),
  isTRUE(all.equal(final_report$net_amount, base_complete$net_amount))
)
```

The two approaches compute the same results. Choosing between them is a
matter of readability, team conventions, dependencies, and performance
requirements.

------------------------------------------------------------------------

## 23.24 Writing a reusable pipeline function

A reusable function makes a workflow easier to test and apply to new
data.

``` r
prepare_order_report <- function(data, minimum_net = 0) {
  required <- c(
    "order_id", "customer", "region", "category",
    "quantity", "unit_price", "discount", "delivered"
  )

  if (!is.data.frame(data)) {
    stop("data must be a data frame or tibble.")
  }

  absent <- setdiff(required, names(data))
  if (length(absent) > 0L) {
    stop("Missing required columns: ", paste(absent, collapse = ", "))
  }

  if (!is.numeric(minimum_net) || length(minimum_net) != 1L ||
      is.na(minimum_net) || !is.finite(minimum_net)) {
    stop("minimum_net must be one finite numeric value.")
  }

  data |>
    dplyr::filter(!is.na(quantity), !is.na(discount)) |>
    dplyr::mutate(
      gross_amount = quantity * unit_price,
      net_amount = gross_amount * (1 - discount),
      delivery_status = dplyr::if_else(
        delivered, "Delivered", "Pending", missing = "Unknown"
      )
    ) |>
    dplyr::filter(.data$net_amount >= .env$minimum_net) |>
    dplyr::select(
      order_id, customer, region, category,
      quantity, unit_price, net_amount, delivery_status
    ) |>
    dplyr::arrange(dplyr::desc(net_amount), order_id)
}

report_500 <- prepare_order_report(orders, minimum_net = 500)
report_500
```

    ##   order_id customer region    category quantity unit_price net_amount
    ## 1     O005      Eli   West Electronics        1       2200       1870
    ## 2     O002      Ben  South Electronics        1       1800       1620
    ## 3     O004     Dina  North        Home        2        450        855
    ## 4     O003     Chen   East       Books        3        200        600
    ## 5     O001     Asha  North       Books        2        250        500
    ## 6     O008     Hari  North       Books        1        500        500
    ##   delivery_status
    ## 1         Pending
    ## 2         Pending
    ## 3       Delivered
    ## 4       Delivered
    ## 5       Delivered
    ## 6       Delivered

### Validate the function

``` r
stopifnot(
  all(report_500$net_amount >= 500),
  !anyNA(report_500$net_amount),
  all(c("order_id", "net_amount") %in% names(report_500))
)
```

### A design improvement for production code

The function validates required columns, but a production version should
also validate their types, allowed ranges, identifier uniqueness, and
documented missing-value policy. These checks should be tailored to the
actual application rather than inferred from the variable names.

------------------------------------------------------------------------

## 23.25 `dplyr` and grouping: a short preview

Grouping changes how certain operations are evaluated. We will cover
this thoroughly in Chapter 24.

``` r
orders |>
  dplyr::group_by(region) |>
  dplyr::mutate(region_order_count = dplyr::n()) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, region, region_order_count)
```

    ## # A tibble: 8 × 3
    ##   order_id region region_order_count
    ##   <chr>    <chr>               <int>
    ## 1 O001     North                   3
    ## 2 O002     South                   2
    ## 3 O003     East                    2
    ## 4 O004     North                   3
    ## 5 O005     West                    1
    ## 6 O006     South                   2
    ## 7 O007     East                    2
    ## 8 O008     North                   3

Here, `n()` counts rows within each group. We use `ungroup()` to avoid
carrying grouping metadata into later operations unintentionally.

A key point is that `filter()` and `mutate()` can behave differently on
grouped versus ungrouped data when their expressions depend on the
group. Chapter 24 will explain that behavior carefully.

------------------------------------------------------------------------

## 23.26 Exercises: beginner level

Work with the original `orders` table.

1.  Select only `order_id`, `customer`, and `unit_price`.
2.  Move `region` to the first column using `select()` and
    `everything()`.
3.  Select every numeric column using `where(is.numeric)`.
4.  Exclude `discount` and `delivered`.
5.  Keep orders from the North region.
6.  Keep orders with unit prices greater than 400.
7.  Keep orders from either the East or West region.
8.  Find rows where `quantity` is missing.
9.  Sort orders from lowest to highest unit price.
10. Sort orders by region and descending unit price.
11. Create `gross_amount = quantity * unit_price`.
12. Rename `unit_price` to `price_per_unit`.
13. Use `rename_with()` to convert all column names to uppercase.
14. Explain why `filter()` and `select()` are not interchangeable.
15. Reproduce any three solutions using base R.

## 23.27 Exercises: intermediate level

1.  Use `all_of()` to select columns listed in a character vector.
2.  Use `any_of()` with one nonexistent optional column.
3.  Use `starts_with()` and `matches()` to select columns by pattern.
4.  Keep orders with `quantity >= 2`, including missing quantities
    explicitly.
5.  Create a three-level unit-price category using `case_when()`.
6.  Create a delivery-status label that handles missing values.
7.  Create gross amount, discount amount, and net amount in one
    `mutate()` call.
8.  Move a new column directly after `unit_price`.
9.  Use a pipeline to filter, mutate, select, and arrange.
10. Write a function that filters on a configurable numeric column.
11. Use `distinct()` to identify unique region–category combinations.
12. Use `slice_max()` to find the three most expensive products.
13. Add checks to confirm that a filtered table has no missing
    quantities.
14. Compare the output of a base-R workflow with its `dplyr` equivalent.
15. Explain the difference between `.data` and `.env`.

## 23.28 Challenge project: employee records

Create a synthetic employee table with at least 15 records and these
columns:

- `employee_id`
- `employee_name`
- `department`
- `city`
- `monthly_salary`
- `years_experience`
- `employment_type`
- `active`

Then build a pipeline that:

1.  Validates the required columns.
2.  Retains active employees.
3.  Creates an annual salary column.
4.  Creates a salary-band label using `case_when()`.
5.  Selects a consistent reporting schema.
6.  Sorts by department and descending annual salary.
7.  Renames at least one column.
8.  Flags missing salary values rather than automatically converting
    them to zero.
9.  Produces a second report containing only a specified city.
10. Repeats the main workflow in base R.
11. Tests row counts, identifier uniqueness, and the derived salary
    calculation.

**Extension:** Turn the pipeline into a function with parameters for
city and minimum annual salary.

------------------------------------------------------------------------

## 23.29 Standalone practice script

The following script is intended for a separate R session after `dplyr`
has been installed. It is not executed during knitting.

``` r
# ============================================================
# R for Everyone — Chapter 23
# Data Manipulation with dplyr, Part I
# ============================================================

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Install dplyr before running this practice script.")
}

orders <- data.frame(
  order_id = c("O001", "O002", "O003", "O004"),
  region = c("North", "South", "North", "East"),
  quantity = c(2L, 1L, 3L, NA_integer_),
  unit_price = c(250, 1800, 400, 300),
  discount = c(0, 0.10, 0.05, 0)
)

# SELECT columns
selected <- dplyr::select(orders, order_id, region, unit_price)

# FILTER rows
north <- dplyr::filter(orders, region == "North")

# ARRANGE rows
sorted <- dplyr::arrange(orders, dplyr::desc(unit_price))

# MUTATE columns
calculated <- dplyr::mutate(
  orders,
  gross_amount = quantity * unit_price,
  net_amount = gross_amount * (1 - discount)
)

# RENAME columns
renamed <- dplyr::rename(orders, price_per_unit = unit_price)

# PIPELINE
report <- orders |>
  dplyr::filter(!is.na(quantity), !is.na(discount)) |>
  dplyr::mutate(net_amount = quantity * unit_price * (1 - discount)) |>
  dplyr::select(order_id, region, net_amount) |>
  dplyr::arrange(dplyr::desc(net_amount))

print(report)

# CHECKS
stopifnot(
  nrow(report) == 3L,
  !anyNA(report$net_amount),
  all(diff(report$net_amount) <= 0)
)
```

------------------------------------------------------------------------

## 23.30 Review questions

1.  What is the purpose of `dplyr`?
2.  Which verb changes rows and which changes columns?
3.  How do we select several nonadjacent columns?
4.  What is the purpose of `all_of()`?
5.  When should we prefer `any_of()`?
6.  How do we filter for several possible values?
7.  How does `filter()` treat missing logical conditions?
8.  Why is `x == NA` not a valid missing-value test?
9.  How do we sort descending?
10. How can we create several columns in one `mutate()` call?
11. How does `if_else()` differ conceptually from base `ifelse()`?
12. Why does the order of `case_when()` conditions matter?
13. What does `.before` do in `mutate()`?
14. What is the syntax of `rename()`?
15. What does `rename_with()` do?
16. Why do we use pipes?
17. Do `dplyr` verbs automatically overwrite the original table?
18. What is data masking?
19. Why can `.data` and `.env` improve functions?
20. What is the difference between `all_of()` and `.data[[name]]`?
21. How does `relocate()` differ from `select()`?
22. Why should we be careful when using
    `distinct(..., .keep_all = TRUE)`?
23. Why should we validate derived columns?
24. What is one advantage of writing a pipeline as a function?
25. How might grouping change a `mutate()` operation?

## 23.31 Key takeaways

- **`select()`** chooses columns.
- **`filter()`** chooses rows whose conditions are `TRUE`.
- **`arrange()`** sorts rows.
- **`mutate()`** creates or modifies columns.
- **`rename()`** changes column names.
- Selection helpers such as `starts_with()`, `where()`, and `all_of()`
  support flexible column selection.
- Missing values must be handled explicitly; `filter()` does not
  automatically retain `NA` conditions.
- Pipes make multi-step transformations easier to read and test.
- `.data` and `.env` clarify column references versus external variables
  in reusable functions.
- Base R and `dplyr` can solve the same data-manipulation problems;
  understanding both strengthens programming skills.
- Reliable workflows include validation, deliberate missing-value
  policies, and checks of expected output structure.

## 23.32 Looking ahead: Chapter 24 — Data Manipulation with `dplyr`, Part II

In the next chapter, we will learn grouped operations using
`group_by()`, `summarise()`, `across()`, `count()`, and related tools.
We will investigate how grouping affects calculations, how to manage
missing values within groups, and how to build readable summaries
without losing control of the resulting data structure.
