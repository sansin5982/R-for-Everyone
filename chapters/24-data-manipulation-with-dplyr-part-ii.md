Chapter 24 — Data Manipulation with dplyr, Part II
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

Previous chapter introduced five essential `dplyr` verbs: `select()`,
`filter()`, `arrange()`, `mutate()`, and `rename()`. We can now select,
reorganize, and create variables. The next programming skill is
**working with groups**. Instead of calculating one result for an entire
table, we often need one result per department, store, month, product,
or other category.

This chapter develops grouped data manipulation systematically, from
first principles to robust, reusable pipelines. The focus is **R
programming and data handling**, not statistical inference. All datasets
are synthetic and use everyday scenarios.

## Learning objectives

By the end, we should be able to:

1.  Explain what a grouped tibble is and what grouping changes.
2.  Use `group_by()`, `.by`, and `ungroup()` deliberately.
3.  Compute grouped summaries with `summarise()` and `reframe()`.
4.  Distinguish `summarise()` from grouped `mutate()` and `filter()`.
5.  Calculate counts with `count()`, `tally()`, and `n()`.
6.  Apply functions to multiple columns using `across()`.
7.  Select columns with tidyselect helpers and `where()`.
8.  Handle missing values, empty groups, and grouping metadata.
9.  Build multi-stage pipelines without accidentally retaining groups.
10. Compare base R and `dplyr` solutions and write testable helper
    functions.

## 24.1 Setup and package availability

This chapter uses `dplyr` and, where useful, `tibble`. A current version
of `dplyr` (1.1.0 or newer) is recommended for `.by`, `reframe()`, and
the newer `across()` conventions. Package installation is an
**interactive setup step**, not something that should occur
automatically during knitting.

``` r
install.packages(c("dplyr", "tibble"))
```

The chapter checks whether `dplyr` is available. Base-R demonstrations
remain executable if the package is missing; package-specific chunks are
skipped.

``` r
if (has_dplyr) {
  cat("dplyr version:", as.character(utils::packageVersion("dplyr")), "\n")
} else {
  cat("dplyr is not installed; base-R examples remain available.\n")
}
```

    ## dplyr version: 1.2.1

We use explicit `dplyr::` prefixes to make package dependencies visible
and avoid function-name conflicts.

## 24.2 A realistic practice dataset

Our synthetic company operates across several departments and regions.
Each row represents an order, with a price, quantity, and status. We
intentionally include missing values and a cancelled order to illustrate
realistic data-handling decisions.

``` r
orders <- data.frame(
  order_id = sprintf("ORD%03d", 1:14),
  department = c("Books", "Books", "Games", "Games", "Books", "Home", "Home",
                 "Games", "Home", "Books", "Games", "Home", "Books", "Games"),
  region = c("North", "South", "North", "South", "North", "North", "South",
             "South", "North", "South", "North", "South", "North", "South"),
  employee = c("Asha", "Ravi", "Meera", "Asha", "Ravi", "Meera", "Asha",
               "Ravi", "Meera", "Asha", "Ravi", "Meera", "Asha", "Ravi"),
  quantity = c(2, 1, 3, 2, 4, 1, 2, 3, 1, 5, 2, 4, 1, 2),
  unit_price = c(200, 250, 500, 450, 180, 900, 800, 520, 950, 210, 480, 850, NA, 510),
  status = c("Completed", "Completed", "Completed", "Cancelled", "Completed",
             "Completed", "Completed", "Completed", "Completed", "Completed",
             "Completed", "Cancelled", "Completed", "Completed"),
  stringsAsFactors = FALSE
)
orders$revenue <- orders$quantity * orders$unit_price
head(orders)
```

    ##   order_id department region employee quantity unit_price    status revenue
    ## 1   ORD001      Books  North     Asha        2        200 Completed     400
    ## 2   ORD002      Books  South     Ravi        1        250 Completed     250
    ## 3   ORD003      Games  North    Meera        3        500 Completed    1500
    ## 4   ORD004      Games  South     Asha        2        450 Cancelled     900
    ## 5   ORD005      Books  North     Ravi        4        180 Completed     720
    ## 6   ORD006       Home  North    Meera        1        900 Completed     900

We will distinguish **all orders** from **completed orders** when
interpreting results. A cancelled order should not silently contribute
to realized revenue.

``` r
completed <- orders[orders$status == "Completed", , drop = FALSE]
stopifnot(nrow(orders) == 14L, nrow(completed) == 12L)
```

## 24.3 What does grouping mean?

A normal data frame contains rows and columns. A **grouped data frame**
also carries metadata identifying which rows belong to each group. It is
still a table; `group_by()` does not split it into separate objects.

``` r
orders_tbl <- dplyr::as_tibble(orders)
by_department <- dplyr::group_by(orders_tbl, department)
by_department
```

    ## # A tibble: 14 × 8
    ## # Groups:   department [3]
    ##    order_id department region employee quantity unit_price status    revenue
    ##    <chr>    <chr>      <chr>  <chr>       <dbl>      <dbl> <chr>       <dbl>
    ##  1 ORD001   Books      North  Asha            2        200 Completed     400
    ##  2 ORD002   Books      South  Ravi            1        250 Completed     250
    ##  3 ORD003   Games      North  Meera           3        500 Completed    1500
    ##  4 ORD004   Games      South  Asha            2        450 Cancelled     900
    ##  5 ORD005   Books      North  Ravi            4        180 Completed     720
    ##  6 ORD006   Home       North  Meera           1        900 Completed     900
    ##  7 ORD007   Home       South  Asha            2        800 Completed    1600
    ##  8 ORD008   Games      South  Ravi            3        520 Completed    1560
    ##  9 ORD009   Home       North  Meera           1        950 Completed     950
    ## 10 ORD010   Books      South  Asha            5        210 Completed    1050
    ## 11 ORD011   Games      North  Ravi            2        480 Completed     960
    ## 12 ORD012   Home       South  Meera           4        850 Cancelled    3400
    ## 13 ORD013   Books      North  Asha            1         NA Completed      NA
    ## 14 ORD014   Games      South  Ravi            2        510 Completed    1020

Inspect the grouping variables:

``` r
dplyr::group_vars(by_department)
```

    ## [1] "department"

``` r
dplyr::n_groups(by_department)
```

    ## [1] 3

Inspect group membership:

``` r
dplyr::group_data(by_department)
```

    ## # A tibble: 3 × 2
    ##   department       .rows
    ##   <chr>      <list<int>>
    ## 1 Books              [5]
    ## 2 Games              [5]
    ## 3 Home               [4]

``` r
dplyr::group_keys(by_department)
```

    ## # A tibble: 3 × 1
    ##   department
    ##   <chr>     
    ## 1 Books     
    ## 2 Games     
    ## 3 Home

``` r
dplyr::group_size(by_department)
```

    ## [1] 5 5 4

`group_data()` contains a special `.rows` list-column describing the row
indices assigned to each group. The order of group keys follows
`dplyr`’s grouping rules; we should not assume it matches the order of
first appearance.

### Base-R analogy

The following operation splits a vector by department:

``` r
split(orders$order_id, orders$department)
```

    ## $Books
    ## [1] "ORD001" "ORD002" "ORD005" "ORD010" "ORD013"
    ## 
    ## $Games
    ## [1] "ORD003" "ORD004" "ORD008" "ORD011" "ORD014"
    ## 
    ## $Home
    ## [1] "ORD006" "ORD007" "ORD009" "ORD012"

Grouping in `dplyr` is conceptually related, but preserves a single
table with group metadata so that later verbs can operate within groups.

## 24.4 Our first `group_by()` and `summarise()` pipeline

``` r
department_summary <- orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    n_orders = dplyr::n(),
    total_quantity = sum(quantity),
    .groups = "drop"
  )

department_summary
```

    ## # A tibble: 3 × 3
    ##   department n_orders total_quantity
    ##   <chr>         <int>          <dbl>
    ## 1 Books             5             13
    ## 2 Games             5             12
    ## 3 Home              4              8

The pipe `|>` passes the preceding result into the next function. The
`group_by()` call defines the groups; `summarise()` reduces each group
to one row.

- `n()` counts rows in the current group.
- `sum(quantity)` adds quantities within that group.
- `.groups = "drop"` removes grouping from the result.

**Important:** `n()` counts rows, not distinct orders unless each row is
known to represent one unique order. We can validate uniqueness using
`anyDuplicated()`.

``` r
stopifnot(!anyDuplicated(orders$order_id))
```

### Base R comparison

``` r
aggregate(quantity ~ department, data = orders, FUN = sum)
```

    ##   department quantity
    ## 1      Books       13
    ## 2      Games       12
    ## 3       Home        8

Both approaches calculate department totals. `dplyr` becomes especially
convenient when multiple named summaries are required.

## 24.5 Several summaries at once

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    orders = dplyr::n(),
    units = sum(quantity),
    mean_units = mean(quantity),
    min_units = min(quantity),
    max_units = max(quantity),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 6
    ##   department orders units mean_units min_units max_units
    ##   <chr>       <int> <dbl>      <dbl>     <dbl>     <dbl>
    ## 1 Books           5    13        2.6         1         5
    ## 2 Games           5    12        2.4         2         3
    ## 3 Home            4     8        2           1         4

We can mix summary functions as long as each expression returns the
intended number of values per group. In ordinary `summarise()` usage,
each expression should return **one value per group**.

## 24.6 Grouping by multiple columns

We can group by both department and region:

``` r
department_region <- orders_tbl |>
  dplyr::group_by(department, region) |>
  dplyr::summarise(
    orders = dplyr::n(),
    units = sum(quantity),
    .groups = "drop"
  )

department_region
```

    ## # A tibble: 6 × 4
    ##   department region orders units
    ##   <chr>      <chr>   <int> <dbl>
    ## 1 Books      North       3     7
    ## 2 Books      South       2     6
    ## 3 Games      North       2     5
    ## 4 Games      South       3     7
    ## 5 Home       North       2     2
    ## 6 Home       South       2     6

Each distinct department–region combination forms a group. If a
combination does not appear in the data, it normally does not produce a
row.

### Counting combinations without `summarise()`

``` r
orders_tbl |>
  dplyr::count(department, region, name = "n_orders")
```

    ## # A tibble: 6 × 3
    ##   department region n_orders
    ##   <chr>      <chr>     <int>
    ## 1 Books      North         3
    ## 2 Books      South         2
    ## 3 Games      North         2
    ## 4 Games      South         3
    ## 5 Home       North         2
    ## 6 Home       South         2

This is a concise way to calculate group frequencies.

## 24.7 The `.groups` argument and persistent grouping

A subtle source of bugs is that grouped results may remain grouped after
summarization.

``` r
retained_grouping <- orders_tbl |>
  dplyr::group_by(department, region) |>
  dplyr::summarise(orders = dplyr::n(), .groups = "drop_last")

dplyr::group_vars(retained_grouping)
```

    ## [1] "department"

Here, the last grouping variable (`region`) is removed, but `department`
remains. Common `.groups` values are:

| Value         | Result                         |
|---------------|--------------------------------|
| `"drop"`      | Remove all grouping            |
| `"drop_last"` | Remove the last grouping level |
| `"keep"`      | Preserve grouping levels       |
| `"rowwise"`   | Return a rowwise data frame    |

We should choose `.groups` deliberately, especially before another
`mutate()` or `filter()`.

``` r
fully_ungrouped <- dplyr::ungroup(retained_grouping)
dplyr::group_vars(fully_ungrouped)
```

    ## character(0)

**Rule of thumb:** Use `.groups = "drop"` when the summary is intended
to become an ordinary result table.

## 24.8 Temporary grouping with `.by`

In `dplyr` 1.1.0 and later, many verbs support `.by`, which applies
grouping to one operation without permanently attaching grouping
metadata.

``` r
orders_tbl |>
  dplyr::summarise(
    orders = dplyr::n(),
    units = sum(quantity),
    .by = department
  )
```

    ## # A tibble: 3 × 3
    ##   department orders units
    ##   <chr>       <int> <dbl>
    ## 1 Books           5    13
    ## 2 Games           5    12
    ## 3 Home            4     8

This is useful when only one operation requires grouping.

``` r
result_by <- orders_tbl |>
  dplyr::summarise(orders = dplyr::n(), .by = department)

dplyr::group_vars(result_by)
```

    ## character(0)

`group_by()` and `.by` have different grouping and ordering semantics.
We should not assume the row order of their outputs is identical.
Explicit `arrange()` is appropriate whenever output order matters.

## 24.9 `summarise()` versus grouped `mutate()`

This distinction is fundamental.

- `summarise()` **reduces** each group to a summary row.
- `mutate()` **retains** the original rows while adding or modifying
  columns.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::mutate(
    department_units = sum(quantity),
    fraction_of_department_units = quantity / sum(quantity)
  ) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, department, quantity,
                department_units, fraction_of_department_units) |>
  head(8)
```

    ## # A tibble: 8 × 5
    ##   order_id department quantity department_units fraction_of_department_units
    ##   <chr>    <chr>         <dbl>            <dbl>                        <dbl>
    ## 1 ORD001   Books             2               13                       0.154 
    ## 2 ORD002   Books             1               13                       0.0769
    ## 3 ORD003   Games             3               12                       0.25  
    ## 4 ORD004   Games             2               12                       0.167 
    ## 5 ORD005   Books             4               13                       0.308 
    ## 6 ORD006   Home              1                8                       0.125 
    ## 7 ORD007   Home              2                8                       0.25  
    ## 8 ORD008   Games             3               12                       0.25

The group total is repeated for every row belonging to that department.
This is not redundant when we need row-level features that depend on
group context.

### Verify a useful invariant

``` r
shares <- orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::mutate(share = quantity / sum(quantity)) |>
  dplyr::summarise(total_share = sum(share), .groups = "drop")

stopifnot(all(abs(shares$total_share - 1) < 1e-12))
shares
```

    ## # A tibble: 3 × 2
    ##   department total_share
    ##   <chr>            <dbl>
    ## 1 Books                1
    ## 2 Games                1
    ## 3 Home                 1

## 24.10 Grouped `filter()`

Grouping also changes how `filter()` evaluates aggregate expressions.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::filter(quantity > mean(quantity)) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, department, quantity)
```

    ## # A tibble: 5 × 3
    ##   order_id department quantity
    ##   <chr>    <chr>         <dbl>
    ## 1 ORD003   Games             3
    ## 2 ORD005   Books             4
    ## 3 ORD008   Games             3
    ## 4 ORD010   Books             5
    ## 5 ORD012   Home              4

Here, each order is compared with the **mean quantity in its own
department**. Without grouping, the comparison would use the overall
mean.

### Common mistake

``` r
overall_mean <- mean(orders_tbl$quantity)
by_group <- orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::filter(quantity > mean(quantity)) |>
  dplyr::ungroup()

cat("Overall mean:", overall_mean, "\n")
```

    ## Overall mean: 2.357143

``` r
cat("Rows retained using within-department means:", nrow(by_group), "\n")
```

    ## Rows retained using within-department means: 5

We must decide whether the question concerns the entire dataset or
comparisons within groups.

## 24.11 Counting rows, distinct values, and missing values

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    n_rows = dplyr::n(),
    n_employees = dplyr::n_distinct(employee),
    missing_prices = sum(is.na(unit_price)),
    available_prices = sum(!is.na(unit_price)),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 5
    ##   department n_rows n_employees missing_prices available_prices
    ##   <chr>       <int>       <int>          <int>            <int>
    ## 1 Books           5           2              1                4
    ## 2 Games           5           3              0                5
    ## 3 Home            4           2              0                4

`n()` counts rows; `n_distinct()` counts distinct values. We should
distinguish `n_distinct(x)` from `n_distinct(x, na.rm = TRUE)` when
missing values are present.

``` r
orders_tbl |>
  dplyr::summarise(
    distinct_prices_including_NA = dplyr::n_distinct(unit_price),
    distinct_prices_excluding_NA = dplyr::n_distinct(unit_price, na.rm = TRUE)
  )
```

    ## # A tibble: 1 × 2
    ##   distinct_prices_including_NA distinct_prices_excluding_NA
    ##                          <int>                        <int>
    ## 1                           14                           13

## 24.12 Missing values in grouped summaries

Missing values can propagate through many numeric functions.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    mean_price_default = mean(unit_price),
    mean_price_observed = mean(unit_price, na.rm = TRUE),
    missing_prices = sum(is.na(unit_price)),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 4
    ##   department mean_price_default mean_price_observed missing_prices
    ##   <chr>                   <dbl>               <dbl>          <int>
    ## 1 Books                      NA                 210              1
    ## 2 Games                     492                 492              0
    ## 3 Home                      875                 875              0

`na.rm = TRUE` excludes missing observations. It does not repair them or
explain why they are missing.

### All-missing groups

When all values are missing, `mean(x, na.rm = TRUE)` produces `NaN`. We
can explicitly handle that case:

``` r
safe_mean <- function(x) {
  if (!is.numeric(x)) stop("x must be numeric")
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) return(NA_real_)
  mean(observed)
}

safe_mean(c(1, 2, NA_real_))
```

    ## [1] 1.5

``` r
safe_mean(c(NA_real_, NA_real_))
```

    ## [1] NA

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(mean_price = safe_mean(unit_price), .groups = "drop")
```

    ## # A tibble: 3 × 2
    ##   department mean_price
    ##   <chr>           <dbl>
    ## 1 Books             210
    ## 2 Games             492
    ## 3 Home              875

### Zero counts versus absent groups

A missing category combination is not automatically the same as a
category with zero observations. The distinction matters when preparing
reports.

## 24.13 `count()`, `tally()`, and `add_count()`

`count()` is shorthand for grouping and counting.

``` r
orders_tbl |> dplyr::count(department)
```

    ## # A tibble: 3 × 2
    ##   department     n
    ##   <chr>      <int>
    ## 1 Books          5
    ## 2 Games          5
    ## 3 Home           4

``` r
orders_tbl |> dplyr::count(department, region, sort = TRUE)
```

    ## # A tibble: 6 × 3
    ##   department region     n
    ##   <chr>      <chr>  <int>
    ## 1 Books      North      3
    ## 2 Games      South      3
    ## 3 Books      South      2
    ## 4 Games      North      2
    ## 5 Home       North      2
    ## 6 Home       South      2

`tally()` counts rows within an existing grouping structure:

``` r
orders_tbl |>
  dplyr::group_by(region) |>
  dplyr::tally(name = "number_of_orders")
```

    ## # A tibble: 2 × 2
    ##   region number_of_orders
    ##   <chr>             <int>
    ## 1 North                 7
    ## 2 South                 7

`add_count()` retains all original rows and adds a group count:

``` r
orders_tbl |>
  dplyr::add_count(department, name = "department_order_count") |>
  dplyr::select(order_id, department, department_order_count) |>
  head()
```

    ## # A tibble: 6 × 3
    ##   order_id department department_order_count
    ##   <chr>    <chr>                       <int>
    ## 1 ORD001   Books                           5
    ## 2 ORD002   Books                           5
    ## 3 ORD003   Games                           5
    ## 4 ORD004   Games                           5
    ## 5 ORD005   Books                           5
    ## 6 ORD006   Home                            4

### Weighted counts

The `wt` argument adds a numeric weight rather than counting rows:

``` r
orders_tbl |>
  dplyr::count(department, wt = quantity, name = "units")
```

    ## # A tibble: 3 × 2
    ##   department units
    ##   <chr>      <dbl>
    ## 1 Books         13
    ## 2 Games         12
    ## 3 Home           8

The result represents **units sold**, not the number of order rows.

## 24.14 Conditional summaries

We can count rows satisfying a condition by summing a logical
expression. In R, `TRUE` behaves as 1 and `FALSE` as 0 in numeric sums.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    n_orders = dplyr::n(),
    n_completed = sum(status == "Completed"),
    n_cancelled = sum(status == "Cancelled"),
    completion_rate = mean(status == "Completed"),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 5
    ##   department n_orders n_completed n_cancelled completion_rate
    ##   <chr>         <int>       <int>       <int>           <dbl>
    ## 1 Books             5           5           0            1   
    ## 2 Games             5           4           1            0.8 
    ## 3 Home              4           3           1            0.75

This works because `status` has no missing values in our synthetic
table. With missing statuses, `sum(status == "Completed", na.rm = TRUE)`
and a clearly defined denominator may be needed.

## 24.15 Revenue summaries and business rules

The data include cancelled orders and one missing unit price. We should
explicitly state our rule: realized revenue comes only from completed
orders with known prices.

``` r
completed_tbl <- orders_tbl |>
  dplyr::filter(status == "Completed")

completed_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    n_completed = dplyr::n(),
    n_missing_revenue = sum(is.na(revenue)),
    known_revenue = sum(revenue, na.rm = TRUE),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 4
    ##   department n_completed n_missing_revenue known_revenue
    ##   <chr>            <int>             <int>         <dbl>
    ## 1 Books                5                 1          2420
    ## 2 Games                4                 0          5040
    ## 3 Home                 3                 0          3450

A total calculated with `na.rm = TRUE` is a **known-value subtotal**
when some values are missing; it should not be presented as complete
revenue without qualification.

## 24.16 Introducing `across()`

Suppose we need the mean of several numeric columns. Repeating each
column name can become cumbersome.

``` r
orders_tbl |>
  dplyr::summarise(
    dplyr::across(
      c(quantity, unit_price),
      ~ safe_mean(.x),
      .names = "mean_{.col}"
    )
  )
```

    ## # A tibble: 1 × 2
    ##   mean_quantity mean_unit_price
    ##           <dbl>           <dbl>
    ## 1          2.36            523.

`across()` takes three main components:

1.  `.cols`: which columns to process;
2.  `.fns`: which function or functions to apply;
3.  `.names`: how to name resulting columns.

Here, `.x` represents the current selected column inside the anonymous
function.

### Why use `~`?

The expression `~ safe_mean(.x)` is a compact anonymous function. We can
also use modern R function syntax:

``` r
orders_tbl |>
  dplyr::summarise(
    dplyr::across(
      c(quantity, unit_price),
      \(x) safe_mean(x),
      .names = "mean_{.col}"
    )
  )
```

    ## # A tibble: 1 × 2
    ##   mean_quantity mean_unit_price
    ##           <dbl>           <dbl>
    ## 1          2.36            523.

The `\(x)` syntax requires R 4.1.0 or newer; the tilde form is often
more portable across older installations.

## 24.17 `across()` with multiple functions

We can supply a named list of functions:

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    dplyr::across(
      c(quantity, unit_price),
      list(
        mean = safe_mean,
        missing = function(x) sum(is.na(x))
      ),
      .names = "{.col}_{.fn}"
    ),
    .groups = "drop"
  )
```

    ## # A tibble: 3 × 5
    ##   department quantity_mean quantity_missing unit_price_mean unit_price_missing
    ##   <chr>              <dbl>            <int>           <dbl>              <int>
    ## 1 Books                2.6                0             210                  1
    ## 2 Games                2.4                0             492                  0
    ## 3 Home                 2                  0             875                  0

The placeholders `{.col}` and `{.fn}` refer to the selected column name
and function name. Naming functions helps create predictable output
names.

## 24.18 Selecting columns with tidyselect

Common column-selection helpers include:

| Helper                | Meaning                              |
|-----------------------|--------------------------------------|
| `starts_with("unit")` | Names beginning with `unit`          |
| `ends_with("price")`  | Names ending with `price`            |
| `contains("id")`      | Names containing `id`                |
| `all_of(names)`       | Require every supplied name to exist |
| `any_of(names)`       | Select supplied names that exist     |
| `where(is.numeric)`   | Columns satisfying a predicate       |
| `everything()`        | All columns                          |

``` r
orders_tbl |>
  dplyr::summarise(
    dplyr::across(
      where(is.numeric),
      ~ sum(is.na(.x)),
      .names = "missing_{.col}"
    )
  )
```

    ## # A tibble: 1 × 3
    ##   missing_quantity missing_unit_price missing_revenue
    ##              <int>              <int>           <int>
    ## 1                0                  1               1

**Grouping variables** are handled specially in `across()` and are not
normally selectable as ordinary columns while grouping is active.

### `all_of()` versus `any_of()`

``` r
requested_columns <- c("quantity", "unit_price", "not_in_table")

orders_tbl |>
  dplyr::select(dplyr::any_of(requested_columns)) |>
  names()
```

    ## [1] "quantity"   "unit_price"

`all_of()` is appropriate when missing requested columns should trigger
an error; `any_of()` is appropriate when optional columns may be absent.

## 24.19 `across()` inside grouped `mutate()`

`across()` also works in `mutate()` to transform several columns without
reducing the number of rows.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::mutate(
    dplyr::across(
      c(quantity, unit_price),
      ~ .x - mean(.x, na.rm = TRUE),
      .names = "centered_{.col}"
    )
  ) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, department, dplyr::starts_with("centered_")) |>
  head()
```

    ## # A tibble: 6 × 4
    ##   order_id department centered_quantity centered_unit_price
    ##   <chr>    <chr>                  <dbl>               <dbl>
    ## 1 ORD001   Books                   -0.6                 -10
    ## 2 ORD002   Books                   -1.6                  40
    ## 3 ORD003   Games                    0.6                   8
    ## 4 ORD004   Games                   -0.4                 -42
    ## 5 ORD005   Books                    1.4                 -30
    ## 6 ORD006   Home                    -1                    25

Here, centering uses each department’s mean. The missing unit price
remains missing. This is a data transformation example, not an
inferential statistical analysis.

## 24.20 `if_any()` and `if_all()`

When filtering by conditions across multiple columns, `if_any()` and
`if_all()` are often clearer than manually combining expressions.

``` r
orders_tbl |>
  dplyr::filter(dplyr::if_any(c(quantity, unit_price), is.na)) |>
  dplyr::select(order_id, quantity, unit_price)
```

    ## # A tibble: 1 × 3
    ##   order_id quantity unit_price
    ##   <chr>       <dbl>      <dbl>
    ## 1 ORD013          1         NA

`if_any()` returns `TRUE` when at least one selected column satisfies
the predicate. `if_all()` requires every selected column to satisfy it.

``` r
orders_tbl |>
  dplyr::filter(dplyr::if_all(c(quantity, unit_price), ~ !is.na(.x))) |>
  dplyr::summarise(complete_rows = dplyr::n())
```

    ## # A tibble: 1 × 1
    ##   complete_rows
    ##           <int>
    ## 1            13

## 24.21 Grouped ranking and ordering

We can rank quantities within departments using `min_rank()` and
`dense_rank()`.

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::mutate(
    rank_desc = dplyr::min_rank(dplyr::desc(quantity)),
    dense_rank_desc = dplyr::dense_rank(dplyr::desc(quantity))
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(department, rank_desc) |>
  dplyr::select(order_id, department, quantity, rank_desc, dense_rank_desc)
```

    ## # A tibble: 14 × 5
    ##    order_id department quantity rank_desc dense_rank_desc
    ##    <chr>    <chr>         <dbl>     <int>           <int>
    ##  1 ORD010   Books             5         1               1
    ##  2 ORD005   Books             4         2               2
    ##  3 ORD001   Books             2         3               3
    ##  4 ORD002   Books             1         4               4
    ##  5 ORD013   Books             1         4               4
    ##  6 ORD003   Games             3         1               1
    ##  7 ORD008   Games             3         1               1
    ##  8 ORD004   Games             2         3               2
    ##  9 ORD011   Games             2         3               2
    ## 10 ORD014   Games             2         3               2
    ## 11 ORD012   Home              4         1               1
    ## 12 ORD007   Home              2         2               2
    ## 13 ORD006   Home              1         3               3
    ## 14 ORD009   Home              1         3               3

Ties are handled differently by different ranking functions. We should
choose the rule that matches the task.

### Highest quantity in each department

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::slice_max(order_by = quantity, n = 1, with_ties = FALSE) |>
  dplyr::ungroup() |>
  dplyr::select(order_id, department, quantity)
```

    ## # A tibble: 3 × 3
    ##   order_id department quantity
    ##   <chr>    <chr>         <dbl>
    ## 1 ORD010   Books             5
    ## 2 ORD003   Games             3
    ## 3 ORD012   Home              4

`with_ties = FALSE` returns one row per group but does not define a
substantive tie-breaking policy. For reproducibility, add an explicit
secondary ordering when ties matter.

## 24.22 `first()`, `last()`, `nth()`, `lag()`, and `lead()`

These functions are useful for ordered records, such as transaction
histories.

``` r
orders_tbl |>
  dplyr::arrange(employee, order_id) |>
  dplyr::group_by(employee) |>
  dplyr::mutate(
    previous_quantity = dplyr::lag(quantity),
    next_quantity = dplyr::lead(quantity)
  ) |>
  dplyr::ungroup() |>
  dplyr::select(employee, order_id, quantity, previous_quantity, next_quantity) |>
  head(10)
```

    ## # A tibble: 10 × 5
    ##    employee order_id quantity previous_quantity next_quantity
    ##    <chr>    <chr>       <dbl>             <dbl>         <dbl>
    ##  1 Asha     ORD001          2                NA             2
    ##  2 Asha     ORD004          2                 2             2
    ##  3 Asha     ORD007          2                 2             5
    ##  4 Asha     ORD010          5                 2             1
    ##  5 Asha     ORD013          1                 5            NA
    ##  6 Meera    ORD003          3                NA             1
    ##  7 Meera    ORD006          1                 3             1
    ##  8 Meera    ORD009          1                 1             4
    ##  9 Meera    ORD012          4                 1            NA
    ## 10 Ravi     ORD002          1                NA             4

**Ordering is essential.** Without an explicit order, `lag()` and
`lead()` refer to the current row order, which may not represent
chronological order. Our synthetic IDs are ordered labels, not real
timestamps.

## 24.23 `reframe()` versus `summarise()`

Sometimes we want **multiple rows per group**, such as the top two
orders from each department. Modern `dplyr` provides `reframe()` for
this purpose.

``` r
orders_tbl |>
  dplyr::reframe(
    order_id = head(order_id[order(quantity, decreasing = TRUE)], 2),
    quantity = head(sort(quantity, decreasing = TRUE), 2),
    .by = department
  )
```

    ## # A tibble: 6 × 3
    ##   department order_id quantity
    ##   <chr>      <chr>       <dbl>
    ## 1 Books      ORD010          5
    ## 2 Books      ORD005          4
    ## 3 Games      ORD003          3
    ## 4 Games      ORD008          3
    ## 5 Home       ORD012          4
    ## 6 Home       ORD007          2

`reframe()` always returns an ungrouped data frame and may return any
number of rows per group. In `dplyr` 1.1.0+, returning multiple rows per
group from `summarise()` is deprecated; use `reframe()` or an
appropriate slicing verb.

### A simpler alternative

``` r
orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::slice_max(quantity, n = 2, with_ties = FALSE) |>
  dplyr::ungroup()
```

    ## # A tibble: 6 × 8
    ##   order_id department region employee quantity unit_price status    revenue
    ##   <chr>    <chr>      <chr>  <chr>       <dbl>      <dbl> <chr>       <dbl>
    ## 1 ORD010   Books      South  Asha            5        210 Completed    1050
    ## 2 ORD005   Books      North  Ravi            4        180 Completed     720
    ## 3 ORD003   Games      North  Meera           3        500 Completed    1500
    ## 4 ORD008   Games      South  Ravi            3        520 Completed    1560
    ## 5 ORD012   Home       South  Meera           4        850 Cancelled    3400
    ## 6 ORD007   Home       South  Asha            2        800 Completed    1600

## 24.24 Empty groups and factor levels

Factors can contain levels not observed in the data.

``` r
stock <- data.frame(
  category = factor(c("Food", "Books", "Food"),
                    levels = c("Food", "Books", "Clothing")),
  units = c(4, 2, 6)
)
stock
```

    ##   category units
    ## 1     Food     4
    ## 2    Books     2
    ## 3     Food     6

``` r
dplyr::as_tibble(stock) |>
  dplyr::group_by(category, .drop = FALSE) |>
  dplyr::summarise(n_rows = dplyr::n(), .groups = "drop")
```

    ## # A tibble: 3 × 2
    ##   category n_rows
    ##   <fct>     <int>
    ## 1 Food          2
    ## 2 Books         1
    ## 3 Clothing      0

`Clothing` appears with zero rows because we explicitly retained unused
factor levels. Aggregation functions may return different values or
warnings for empty groups; we must select summary functions appropriate
to the expected data.

## 24.25 Rowwise operations versus column-wise operations

Most `dplyr` operations are vectorized. Sometimes a calculation must be
performed separately for each row.

``` r
ratings <- dplyr::tibble(
  item = c("A", "B", "C"),
  quality = c(4, 5, 3),
  service = c(5, 3, 4),
  value = c(3, 4, 5)
)

ratings |>
  dplyr::rowwise() |>
  dplyr::mutate(total = sum(dplyr::c_across(c(quality, service, value)))) |>
  dplyr::ungroup()
```

    ## # A tibble: 3 × 5
    ##   item  quality service value total
    ##   <chr>   <dbl>   <dbl> <dbl> <dbl>
    ## 1 A           4       5     3    12
    ## 2 B           5       3     4    12
    ## 3 C           3       4     5    12

For simple numeric row sums, base R’s `rowSums()` is usually clearer and
faster:

``` r
ratings_base <- data.frame(
  item = c("A", "B", "C"),
  quality = c(4, 5, 3),
  service = c(5, 3, 4),
  value = c(3, 4, 5)
)
ratings_base$total <- rowSums(ratings_base[c("quality", "service", "value")])
ratings_base
```

    ##   item quality service value total
    ## 1    A       4       5     3    12
    ## 2    B       5       3     4    12
    ## 3    C       3       4     5    12

Use `rowwise()` when a genuinely row-specific operation is needed; do
not use it by default.

## 24.26 Programming with `dplyr`: reusable grouped summaries

A reusable function can accept a data frame and group-column name.

``` r
count_by <- function(data, group_col) {
  if (!is.data.frame(data)) stop("data must be a data frame")
  if (!is.character(group_col) || length(group_col) != 1L ||
      is.na(group_col) || !nzchar(group_col)) {
    stop("group_col must be one nonempty column name")
  }
  if (!group_col %in% names(data)) {
    stop("Unknown column: ", group_col)
  }

  data |>
    dplyr::count(.data[[group_col]], name = "n")
}

count_by(orders_tbl, "department")
```

    ## # A tibble: 3 × 2
    ##   department     n
    ##   <chr>      <int>
    ## 1 Books          5
    ## 2 Games          5
    ## 3 Home           4

`.data[[group_col]]` makes the distinction between an environment
variable containing a column name and the actual data column explicit.

### Two-variable summary helper

``` r
sum_by <- function(data, group_col, value_col) {
  required <- c(group_col, value_col)
  if (!is.data.frame(data) ||
      !is.character(group_col) || length(group_col) != 1L ||
      !is.character(value_col) || length(value_col) != 1L ||
      anyNA(required) || any(!nzchar(required)) ||
      !all(required %in% names(data))) {
    stop("Valid data and existing group/value column names are required")
  }
  if (!is.numeric(data[[value_col]])) {
    stop("The value column must be numeric")
  }

  data |>
    dplyr::group_by(.data[[group_col]]) |>
    dplyr::summarise(
      total_known = sum(.data[[value_col]], na.rm = TRUE),
      n_missing = sum(is.na(.data[[value_col]])),
      .groups = "drop"
    )
}

sum_by(orders_tbl, "department", "quantity")
```

    ## # A tibble: 3 × 3
    ##   department total_known n_missing
    ##   <chr>            <dbl>     <int>
    ## 1 Books               13         0
    ## 2 Games               12         0
    ## 3 Home                 8         0

This function reports both the known-value total and the number of
missing values to avoid silently concealing incomplete data.

## 24.27 Common mistakes and troubleshooting

### Mistake 1: forgetting to ungroup

A later `mutate()` may calculate within-group values when an overall
value was intended. Check `group_vars()` and use `ungroup()` or
`.groups = "drop"`.

### Mistake 2: `summarise()` unexpectedly returns `NA`

A numeric column may contain missing values. Inspect `sum(is.na(x))`,
then decide whether `na.rm = TRUE` is appropriate.

### Mistake 3: interpreting `n()` as distinct entities

Rows are not always unique customers, products, or orders. Use
`n_distinct()` after validating the identifier.

### Mistake 4: grouping by too many columns

Grouping by a unique ID produces one-row groups, often defeating the
purpose of aggregation.

### Mistake 5: confusing grouped `mutate()` with `summarise()`

`mutate()` retains rows; `summarise()` reduces them. Choose based on the
desired output structure.

### Mistake 6: `across()` selects unexpected columns

Review `where()`, `starts_with()`, and other tidyselect expressions.
Grouping columns have special treatment.

### Mistake 7: old `dplyr` version

`.by` and `reframe()` require `dplyr` 1.1.0 or newer. The chapter skips
these demonstrations on older versions.

### Mistake 8: grouping and output order

Explicitly call `arrange()` if downstream work depends on row order.

### Mistake 9: cancelled transactions included in revenue

Filter by business rules before computing totals, and document
exclusions.

### Mistake 10: relying on an incomplete subtotal

When a value is missing, a total with `na.rm = TRUE` omits it. Report
missing counts alongside the subtotal.

## 24.28 Complete guided project: Store operations dashboard

We will create a compact department-by-region report with completed
order counts, units, known revenue, and missing-price counts. The
workflow will validate its own totals.

### Step 1: filter completed orders

``` r
dashboard_input <- orders_tbl |>
  dplyr::filter(status == "Completed")

stopifnot(nrow(dashboard_input) == 12L)
```

### Step 2: create the grouped dashboard

``` r
dashboard <- dashboard_input |>
  dplyr::group_by(department, region) |>
  dplyr::summarise(
    completed_orders = dplyr::n(),
    total_units = sum(quantity),
    known_revenue = sum(revenue, na.rm = TRUE),
    missing_prices = sum(is.na(unit_price)),
    .groups = "drop"
  ) |>
  dplyr::arrange(department, region)

dashboard
```

    ## # A tibble: 6 × 6
    ##   department region completed_orders total_units known_revenue missing_prices
    ##   <chr>      <chr>             <int>       <dbl>         <dbl>          <int>
    ## 1 Books      North                 3           7          1120              1
    ## 2 Books      South                 2           6          1300              0
    ## 3 Games      North                 2           5          2460              0
    ## 4 Games      South                 2           5          2580              0
    ## 5 Home       North                 2           2          1850              0
    ## 6 Home       South                 1           2          1600              0

### Step 3: validate totals

``` r
stopifnot(
  sum(dashboard$completed_orders) == nrow(dashboard_input),
  sum(dashboard$total_units) == sum(dashboard_input$quantity),
  sum(dashboard$missing_prices) == sum(is.na(dashboard_input$unit_price)),
  isTRUE(all.equal(
    sum(dashboard$known_revenue),
    sum(dashboard_input$revenue, na.rm = TRUE)
  ))
)
```

### Step 4: produce a department-only summary

``` r
department_dashboard <- dashboard |>
  dplyr::group_by(department) |>
  dplyr::summarise(
    completed_orders = sum(completed_orders),
    units = sum(total_units),
    known_revenue = sum(known_revenue),
    missing_prices = sum(missing_prices),
    .groups = "drop"
  ) |>
  dplyr::arrange(dplyr::desc(known_revenue))

department_dashboard
```

    ## # A tibble: 3 × 5
    ##   department completed_orders units known_revenue missing_prices
    ##   <chr>                 <int> <dbl>         <dbl>          <int>
    ## 1 Games                     4    10          5040              0
    ## 2 Home                      3     4          3450              0
    ## 3 Books                     5    13          2420              1

### Step 5: optional export

To avoid modifying files unexpectedly during knitting, the export
demonstration writes into the session’s temporary directory.

``` r
dashboard_path <- file.path(tempdir(), "chapter24_department_dashboard.csv")
utils::write.csv(department_dashboard, dashboard_path, row.names = FALSE)
stopifnot(file.exists(dashboard_path))
```

## 24.29 Base R and `dplyr` comparison

Both styles are valid. We should understand what each operation does
before choosing a style.

| Task | Base R | `dplyr` |
|----|----|----|
| Group counts | `table(x)` | `count(x)` |
| Group sums | `aggregate()` or `tapply()` | `group_by()` + `summarise()` |
| Group mean attached to rows | `ave()` | grouped `mutate()` |
| Split into groups | `split()` | `group_split()` where appropriate |
| Multiple column summaries | `lapply()`/`vapply()` | `across()` |
| Keep rows meeting group condition | `ave()` + indexing | grouped `filter()` |

### Base R group summary

``` r
base_units <- aggregate(quantity ~ department, data = orders, FUN = sum)
base_units
```

    ##   department quantity
    ## 1      Books       13
    ## 2      Games       12
    ## 3       Home        8

### Equivalent `dplyr` summary

``` r
dplyr_units <- orders_tbl |>
  dplyr::group_by(department) |>
  dplyr::summarise(quantity = sum(quantity), .groups = "drop") |>
  dplyr::arrange(department)

base_sorted <- base_units[order(base_units$department), ]
stopifnot(isTRUE(all.equal(
  unname(base_sorted$quantity), unname(dplyr_units$quantity)
)))
```

## 24.30 Practice exercises: beginner

1.  Create a data frame containing `student`, `class`, and `score` for
    12 students.
2.  Group by `class` and count students.
3.  Calculate the total score for each class.
4.  Calculate the mean score for each class.
5.  Compare grouped `summarise()` with grouped `mutate()`.
6.  Add each class’s mean score to every student row.
7.  Keep students scoring above their class mean.
8.  Remove grouping and verify with `group_vars()`.
9.  Repeat a group count using `count()`.
10. Explain the difference between `n()` and `n_distinct()`.

## 24.31 Practice exercises: intermediate

1.  Group the `orders` data by department and region.
2.  Count completed and cancelled orders per department.
3.  Calculate the total quantity per department and region.
4.  Identify departments with missing prices.
5.  Use `across()` to count missing values in numeric columns.
6.  Use `across()` to calculate the minimum, maximum, and mean for two
    numeric columns.
7.  Create names such as `quantity_mean` and `unit_price_mean`.
8.  Add each department’s order count using `add_count()`.
9.  Identify the highest-quantity order in each department.
10. Explain why the known-revenue subtotal may be incomplete.

## 24.32 Practice exercises: advanced

1.  Create a reusable function that summarizes any numeric column by any
    grouping column.
2.  Validate input types and required columns before grouping.
3.  Implement an explicit policy for all-missing groups.
4.  Compare `group_by()` with `.by` on a recent `dplyr` version.
5.  Use `reframe()` to return the two largest quantities per department.
6.  Investigate how `.drop = FALSE` affects unused factor levels.
7.  Use `if_any()` to identify incomplete records.
8.  Use `if_all()` to retain complete numeric records.
9.  Explain when `rowSums()` is preferable to `rowwise()`.
10. Write tests that ensure grouped totals reconcile with original data.

## 24.33 Capstone challenge: Employee performance report

Create a synthetic employee activity dataset with the following columns:

- `employee_id`
- `team`
- `month`
- `tasks_assigned`
- `tasks_completed`
- `hours_worked`
- `status`

Build a report that:

1.  Validates identifiers and numeric columns.
2.  Calculates task completion rates while avoiding division by zero.
3.  Summarizes assignments and completions by team and month.
4.  Counts missing values per group.
5.  Ranks employees by completed tasks within each team.
6.  Adds team totals to employee-level rows using grouped `mutate()`.
7.  Uses `across()` to generate multiple numeric summaries.
8.  Produces a final ungrouped report.
9.  Exports the result to a temporary CSV file.
10. Uses `stopifnot()` to verify aggregate totals.

## 24.34 Standalone practice script

The following script is intentionally not executed during knitting. It
can be copied into an `.R` file and run after installing `dplyr`.

``` r
# R for Everyone — Chapter 24
# Standalone grouped-data practice

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Install dplyr before running this script")
}

sales <- data.frame(
  team = c("A", "A", "B", "B", "B", "C"),
  employee = c("P1", "P2", "P3", "P4", "P5", "P6"),
  units = c(4, 6, 3, 7, 2, 5),
  price = c(100, 120, 150, NA, 180, 200)
)

report <- sales |>
  dplyr::group_by(team) |>
  dplyr::summarise(
    n_employees = dplyr::n_distinct(employee),
    units = sum(units),
    known_revenue = sum(units * price, na.rm = TRUE),
    missing_prices = sum(is.na(price)),
    .groups = "drop"
  ) |>
  dplyr::arrange(team)

stopifnot(
  sum(report$n_employees) == nrow(sales),
  sum(report$units) == sum(sales$units)
)

print(report)
utils::write.csv(
  report,
  file.path(tempdir(), "chapter24_practice_report.csv"),
  row.names = FALSE
)
```

## 24.35 Function reference

| Function           | Primary purpose                                     |
|--------------------|-----------------------------------------------------|
| `group_by()`       | Attach grouping metadata                            |
| `ungroup()`        | Remove grouping                                     |
| `group_vars()`     | Inspect grouping variables                          |
| `group_data()`     | Inspect group membership                            |
| `group_keys()`     | Inspect group combinations                          |
| `n_groups()`       | Count groups                                        |
| `summarise()`      | Produce group-level summaries                       |
| `.by`              | Temporary grouping for supported verbs              |
| `reframe()`        | Return zero or more rows per group                  |
| `n()`              | Count rows in the current group                     |
| `n_distinct()`     | Count distinct values                               |
| `count()`          | Group and count in one step                         |
| `tally()`          | Count within existing groups                        |
| `add_count()`      | Attach counts to original rows                      |
| `across()`         | Apply functions to selected columns                 |
| `if_any()`         | Test whether any selected column meets a condition  |
| `if_all()`         | Test whether all selected columns meet a condition  |
| `rowwise()`        | Enable rowwise calculations                         |
| `c_across()`       | Collect selected columns within a rowwise operation |
| `slice_max()`      | Select highest-ranked rows                          |
| `min_rank()`       | Rank values with gaps after ties                    |
| `dense_rank()`     | Rank values without gaps after ties                 |
| `lag()` / `lead()` | Access adjacent values in an ordering               |

## 24.36 Chapter review

1.  What changes when we call `group_by()`?
2.  Does `group_by()` split a data frame into separate objects?
3.  How does `summarise()` differ from `mutate()`?
4.  Why should we use `.groups = "drop"` deliberately?
5.  What is the difference between persistent grouping and `.by`?
6.  How can we count rows in each group?
7.  How do we count distinct identifiers?
8.  Why might a total calculated with `na.rm = TRUE` be incomplete?
9.  What do `.cols`, `.fns`, and `.names` mean in `across()`?
10. When should we use `if_any()` rather than `if_all()`?
11. Why does ordering matter for `lag()` and `lead()`?
12. What problem does `reframe()` solve?
13. What does `.drop = FALSE` do for unused factor levels?
14. Why should `rowwise()` not be our default for numeric row sums?
15. How can we validate that grouped totals reconcile with source data?

## 24.37 Key takeaways

- `group_by()` changes the scope in which subsequent verbs evaluate
  expressions.
- `summarise()` reduces groups to summary rows; grouped `mutate()` keeps
  the original rows.
- `filter()` can compare each row with its own group’s values.
- `count()`, `tally()`, and `add_count()` provide concise counting
  workflows.
- `across()` applies one or more functions to selected columns.
- `.by` offers temporary grouping in newer `dplyr` versions.
- `reframe()` is appropriate when each group should return multiple
  rows.
- Missing-value rules, grouping state, and ordering must be explicit.
- Reconciliation tests make grouped pipelines safer and easier to
  maintain.

## Looking ahead — Chapter 25: Joining and Combining Datasets

We have learned to summarize a single dataset by groups. Next, we will
learn to **combine multiple datasets** using `left_join()`,
`inner_join()`, `right_join()`, `full_join()`, `semi_join()`,
`anti_join()`, `bind_rows()`, and `bind_cols()`. We will also examine
duplicate keys, many-to-many relationships, missing matches, and
practical safeguards against accidental row multiplication.
