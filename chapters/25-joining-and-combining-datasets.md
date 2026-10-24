Chapter 25 — Joining and Combining Datasets
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In a real project, information rarely arrives in one perfectly organized
table. A shop may store customer profiles, orders, products, and
payments in separate files. We need to combine these records without
losing observations, duplicating transactions, or confusing missing
values with unmatched keys.

In this chapter, we learn the distinction between **joins** (matching
rows using keys) and **binding** (stacking rows or columns by position).
We begin with base R, develop the tidyverse approach using `dplyr`, and
finish with a practical, auditable workflow.

**Learning outcomes.** By the end, we will be able to identify join keys
and relationships; choose among inner, left, right, full, semi, and anti
joins; control duplicate matches and missing keys; perform joins using
multiple keys or non-equality conditions; bind compatible tables; and
validate the resulting data.

**Prerequisites.** Chapters 22–24 introduce tibbles, pipes, `select()`,
`filter()`, `group_by()`, and `summarise()`. We can still follow the
core ideas with base R alone.

**Package note.** The essential datasets and base R demonstrations run
without additional packages. Sections requiring `dplyr` execute only
when the package is installed. Modern join options such as
`relationship`, `multiple`, `unmatched`, `na_matches`, and `join_by()`
require recent `dplyr` releases; examples explicitly check availability.

``` r
options(stringsAsFactors = FALSE)
has_dplyr <- requireNamespace("dplyr", quietly = TRUE)
modern_dplyr <- has_dplyr &&
  utils::packageVersion("dplyr") >= package_version("1.1.0")
cat("dplyr installed:", has_dplyr, "
")
```

    ## dplyr installed: TRUE

``` r
if (has_dplyr) cat("dplyr version:", as.character(utils::packageVersion("dplyr")), "
")
```

    ## dplyr version: 1.2.1

# 1. Why separate tables exist

A well-organized system often stores each type of entity once. Customer
details belong in a customer table; order records belong in an order
table; product prices belong in a product table. This reduces repeated
information, but creates a need to **reconnect** tables during analysis.

A **key** is one or more columns used to identify a record or establish
a relationship. A **primary key** is expected to uniquely identify a row
in its own table; a **foreign key** refers to an identifier in another
table. For example, `customer_id` is unique in a customer lookup table
but may repeat in an order table because one customer can place several
orders.

A join uses key values, not the current row order. This is its defining
difference from column binding.

``` r
customers <- data.frame(
  customer_id = c("C01", "C02", "C03", "C04"),
  customer_name = c("Asha", "Ben", "Carla", "Dev"),
  city = c("Delhi", "Pune", "Kochi", "Jaipur")
)
orders <- data.frame(
  order_id = c("O101", "O102", "O103", "O104", "O105"),
  customer_id = c("C01", "C02", "C01", "C05", "C03"),
  product_id = c("P1", "P2", "P3", "P1", "P2"),
  quantity = c(2L, 1L, 3L, 1L, 2L)
)
products <- data.frame(
  product_id = c("P1", "P2", "P3", "P4"),
  product_name = c("Notebook", "Pen Set", "Desk Lamp", "Folder"),
  unit_price = c(80, 120, 650, 45)
)
customers
```

    ##   customer_id customer_name   city
    ## 1         C01          Asha  Delhi
    ## 2         C02           Ben   Pune
    ## 3         C03         Carla  Kochi
    ## 4         C04           Dev Jaipur

``` r
orders
```

    ##   order_id customer_id product_id quantity
    ## 1     O101         C01         P1        2
    ## 2     O102         C02         P2        1
    ## 3     O103         C01         P3        3
    ## 4     O104         C05         P1        1
    ## 5     O105         C03         P2        2

``` r
products
```

    ##   product_id product_name unit_price
    ## 1         P1     Notebook         80
    ## 2         P2      Pen Set        120
    ## 3         P3    Desk Lamp        650
    ## 4         P4       Folder         45

The sample deliberately includes an order for customer `C05`, who is
missing from `customers`, and a product `P4` that has not been ordered.
These mismatches make join behavior visible.

# 2. Join vocabulary and visual intuition

For a join between `orders` (left table, `x`) and `customers` (right
table, `y`):

| Join | Rows retained | Typical question |
|:---|:---|:---|
| `inner_join()` | Matching rows from both tables | Which orders have known customers? |
| `left_join()` | All left rows, with matching right columns | Add customer details to every order |
| `right_join()` | All right rows, with matching left columns | Which customers appear, even without orders? |
| `full_join()` | All keys represented in either table | What exists in either source? |
| `semi_join()` | Left rows that have a match in right | Which orders reference valid customers? |
| `anti_join()` | Left rows without a match in right | Which orders reference unknown customers? |

**Important:** Joins can return more rows than either input when keys
repeat on both sides. “Left join” means every left row is represented,
not necessarily exactly once.

# 3. Start with base R: `merge()`

`merge(x, y, by = "key")` performs an inner join by default.
`all.x = TRUE` creates a left join; `all.y = TRUE` creates a right join;
`all = TRUE` creates a full join. By default, `merge()` may reorder rows
by key, so we must not assume original order is preserved.

``` r
merge(orders, customers, by = "customer_id")
```

    ##   customer_id order_id product_id quantity customer_name  city
    ## 1         C01     O101         P1        2          Asha Delhi
    ## 2         C01     O103         P3        3          Asha Delhi
    ## 3         C02     O102         P2        1           Ben  Pune
    ## 4         C03     O105         P2        2         Carla Kochi

``` r
merge(orders, customers, by = "customer_id", all.x = TRUE)
```

    ##   customer_id order_id product_id quantity customer_name  city
    ## 1         C01     O101         P1        2          Asha Delhi
    ## 2         C01     O103         P3        3          Asha Delhi
    ## 3         C02     O102         P2        1           Ben  Pune
    ## 4         C03     O105         P2        2         Carla Kochi
    ## 5         C05     O104         P1        1          <NA>  <NA>

``` r
merge(orders, customers, by = "customer_id", all.y = TRUE)
```

    ##   customer_id order_id product_id quantity customer_name   city
    ## 1         C01     O101         P1        2          Asha  Delhi
    ## 2         C01     O103         P3        3          Asha  Delhi
    ## 3         C02     O102         P2        1           Ben   Pune
    ## 4         C03     O105         P2        2         Carla  Kochi
    ## 5         C04     <NA>       <NA>       NA           Dev Jaipur

``` r
merge(orders, customers, by = "customer_id", all = TRUE)
```

    ##   customer_id order_id product_id quantity customer_name   city
    ## 1         C01     O101         P1        2          Asha  Delhi
    ## 2         C01     O103         P3        3          Asha  Delhi
    ## 3         C02     O102         P2        1           Ben   Pune
    ## 4         C03     O105         P2        2         Carla  Kochi
    ## 5         C04     <NA>       <NA>       NA           Dev Jaipur
    ## 6         C05     O104         P1        1          <NA>   <NA>

`merge()` also supports different key names using `by.x` and `by.y`. It
is useful when tidyverse packages are unavailable, although it does not
have all the relationship controls available in modern `dplyr`.

``` r
left_ids <- data.frame(client_code = c("C01", "C03", "C07"))
right_ids <- customers[, c("customer_id", "customer_name")]
merge(left_ids, right_ids,
      by.x = "client_code", by.y = "customer_id",
      all.x = TRUE)
```

    ##   client_code customer_name
    ## 1         C01          Asha
    ## 2         C03         Carla
    ## 3         C07          <NA>

# 4. Preparing for `dplyr` joins

We use namespace-qualified calls such as `dplyr::left_join()` to make
the origin of each function explicit and to avoid conflicts with
functions in other packages. When `dplyr` is missing, the examples print
a message instead of stopping the entire chapter.

``` r
if (has_dplyr) {
  customers_tbl <- dplyr::as_tibble(customers)
  orders_tbl <- dplyr::as_tibble(orders)
  products_tbl <- dplyr::as_tibble(products)
  print(orders_tbl)
} else {
  message("Install dplyr to run the tidyverse examples: install.packages('dplyr')")
}
```

    ## # A tibble: 5 × 4
    ##   order_id customer_id product_id quantity
    ##   <chr>    <chr>       <chr>         <int>
    ## 1 O101     C01         P1                2
    ## 2 O102     C02         P2                1
    ## 3 O103     C01         P3                3
    ## 4 O104     C05         P1                1
    ## 5 O105     C03         P2                2

## Inner join

An inner join keeps only matching combinations. The order for `C05`
disappears because there is no customer record.

``` r
if (has_dplyr) {
  result <- dplyr::inner_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 4 × 6
    ##   order_id customer_id product_id quantity customer_name city 
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr>
    ## 1 O101     C01         P1                2 Asha          Delhi
    ## 2 O102     C02         P2                1 Ben           Pune 
    ## 3 O103     C01         P3                3 Asha          Delhi
    ## 4 O105     C03         P2                2 Carla         Kochi
    ## Rows: 4

## Left join

A left join retains all orders. The unknown customer has missing
customer details, shown as `NA`.

``` r
if (has_dplyr) {
  result <- dplyr::left_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 5 × 6
    ##   order_id customer_id product_id quantity customer_name city 
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr>
    ## 1 O101     C01         P1                2 Asha          Delhi
    ## 2 O102     C02         P2                1 Ben           Pune 
    ## 3 O103     C01         P3                3 Asha          Delhi
    ## 4 O104     C05         P1                1 <NA>          <NA> 
    ## 5 O105     C03         P2                2 Carla         Kochi
    ## Rows: 5

## Right join

A right join retains every customer. A customer without an order has
missing order fields.

``` r
if (has_dplyr) {
  result <- dplyr::right_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 5 × 6
    ##   order_id customer_id product_id quantity customer_name city  
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr> 
    ## 1 O101     C01         P1                2 Asha          Delhi 
    ## 2 O102     C02         P2                1 Ben           Pune  
    ## 3 O103     C01         P3                3 Asha          Delhi 
    ## 4 O105     C03         P2                2 Carla         Kochi 
    ## 5 <NA>     C04         <NA>             NA Dev           Jaipur
    ## Rows: 5

## Full join

A full join includes all matched and unmatched rows from both inputs.

``` r
if (has_dplyr) {
  result <- dplyr::full_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 6 × 6
    ##   order_id customer_id product_id quantity customer_name city  
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr> 
    ## 1 O101     C01         P1                2 Asha          Delhi 
    ## 2 O102     C02         P2                1 Ben           Pune  
    ## 3 O103     C01         P3                3 Asha          Delhi 
    ## 4 O104     C05         P1                1 <NA>          <NA>  
    ## 5 O105     C03         P2                2 Carla         Kochi 
    ## 6 <NA>     C04         <NA>             NA Dev           Jaipur
    ## Rows: 6

## Semi join

A semi join returns only columns from the left table and does not
duplicate its rows due to repeated matches on the right.

``` r
if (has_dplyr) {
  result <- dplyr::semi_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 4 × 4
    ##   order_id customer_id product_id quantity
    ##   <chr>    <chr>       <chr>         <int>
    ## 1 O101     C01         P1                2
    ## 2 O102     C02         P2                1
    ## 3 O103     C01         P3                3
    ## 4 O105     C03         P2                2
    ## Rows: 4

## Anti join

An anti join is particularly useful for data quality checks because it
exposes unmatched left-hand keys.

``` r
if (has_dplyr) {
  result <- dplyr::anti_join(orders_tbl, customers_tbl, by = "customer_id")
  print(result)
  cat("Rows:", nrow(result), "
")
}
```

    ## # A tibble: 1 × 4
    ##   order_id customer_id product_id quantity
    ##   <chr>    <chr>       <chr>         <int>
    ## 1 O104     C05         P1                1
    ## Rows: 1

# 5. A side-by-side row-count comparison

The row count is often the first diagnostic we examine. For our example,
a left join should return five rows because customer IDs are unique in
the lookup table. A semi join should return four orders, and an anti
join should identify the single unknown customer order.

``` r
if (has_dplyr) {
  join_names <- c("inner", "left", "right", "full", "semi", "anti")
  join_functions <- list(
    dplyr::inner_join, dplyr::left_join, dplyr::right_join,
    dplyr::full_join, dplyr::semi_join, dplyr::anti_join
  )
  counts <- vapply(join_functions, function(f) {
    nrow(f(orders_tbl, customers_tbl, by = "customer_id"))
  }, integer(1))
  print(data.frame(join = join_names, rows = counts))
}
```

    ##    join rows
    ## 1 inner    4
    ## 2  left    5
    ## 3 right    5
    ## 4  full    6
    ## 5  semi    4
    ## 6  anti    1

# 6. Understanding one-to-one, one-to-many, and many-to-many relationships

We describe a relationship by the number of records that can share a
key:

- **One-to-one:** each key occurs at most once on each side, such as one
  employee and one badge record.
- **Many-to-one:** multiple left rows can match one right row, such as
  many orders belonging to one customer.
- **One-to-many:** one left row can match several right rows, such as
  one customer and several orders.
- **Many-to-many:** keys can repeat on both sides, creating all pairwise
  combinations for each matching key.

The last case can create a surprising increase in row count. It is not
always wrong; it must be intentional.

``` r
visits <- data.frame(customer_id = c("C01", "C01", "C02"),
                     visit = c("Morning", "Evening", "Morning"))
notes <- data.frame(customer_id = c("C01", "C01", "C02"),
                    note = c("Requested invoice", "Asked about delivery", "New account"))
merge(visits, notes, by = "customer_id")
```

    ##   customer_id   visit                 note
    ## 1         C01 Morning    Requested invoice
    ## 2         C01 Morning Asked about delivery
    ## 3         C01 Evening    Requested invoice
    ## 4         C01 Evening Asked about delivery
    ## 5         C02 Morning          New account

``` r
cat("Input rows:", nrow(visits), "and", nrow(notes), "
")
```

    ## Input rows: 3 and 3

``` r
cat("Joined rows:", nrow(merge(visits, notes, by = "customer_id")), "
")
```

    ## Joined rows: 5

For `C01`, two visits multiplied by two notes yield four rows. A join
does not know which note belongs to which visit. If the business
question requires that association, we need an additional key such as
`visit_id`.

Modern `dplyr` can enforce an expected relationship. The following
examples require version 1.1.0 or later. A relationship assertion should
reflect the data model rather than merely silence a warning.

``` r
if (modern_dplyr) {
  safe <- dplyr::left_join(
    orders_tbl, customers_tbl,
    by = "customer_id", relationship = "many-to-one"
  )
  print(safe)
  explicit_many <- dplyr::inner_join(
    visits, notes, by = "customer_id",
    relationship = "many-to-many"
  )
  print(explicit_many)
} else {
  message("Relationship assertions require dplyr 1.1.0 or newer.")
}
```

    ## # A tibble: 5 × 6
    ##   order_id customer_id product_id quantity customer_name city 
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr>
    ## 1 O101     C01         P1                2 Asha          Delhi
    ## 2 O102     C02         P2                1 Ben           Pune 
    ## 3 O103     C01         P3                3 Asha          Delhi
    ## 4 O104     C05         P1                1 <NA>          <NA> 
    ## 5 O105     C03         P2                2 Carla         Kochi
    ##   customer_id   visit                 note
    ## 1         C01 Morning    Requested invoice
    ## 2         C01 Morning Asked about delivery
    ## 3         C01 Evening    Requested invoice
    ## 4         C01 Evening Asked about delivery
    ## 5         C02 Morning          New account

# 7. Checking key uniqueness before joining

Before we merge data, we should establish which table is supposed to
have unique keys. We can check duplicated IDs with `duplicated()` and
`anyDuplicated()`. Missing IDs need separate inspection.

``` r
cat("Customer IDs unique:", !anyDuplicated(customers$customer_id), "
")
```

    ## Customer IDs unique: TRUE

``` r
cat("Order IDs unique:", !anyDuplicated(orders$order_id), "
")
```

    ## Order IDs unique: TRUE

``` r
cat("Customer IDs repeated in orders:",
    anyDuplicated(orders$customer_id) > 0L, "
")
```

    ## Customer IDs repeated in orders: TRUE

``` r
customers[duplicated(customers$customer_id) |
            duplicated(customers$customer_id, fromLast = TRUE), , drop = FALSE]
```

    ## [1] customer_id   customer_name city         
    ## <0 rows> (or 0-length row.names)

``` r
assert_unique_key <- function(data, keys, table_name = "table") {
  stopifnot(is.data.frame(data), length(keys) >= 1L,
            all(keys %in% names(data)))
  if (anyNA(data[keys])) {
    stop(sprintf("%s contains missing key values", table_name))
  }
  if (anyDuplicated(data[keys])) {
    stop(sprintf("%s contains duplicate key combinations", table_name))
  }
  invisible(TRUE)
}
assert_unique_key(customers, "customer_id", "customers")
assert_unique_key(products, "product_id", "products")
assert_unique_key(orders, "order_id", "orders")
```

When we validate composite keys, `data[keys]` treats the selected
columns together as the identifier. A repeated value in one column may
be acceptable if the **combination** remains unique.

# 8. Joining on differently named columns

Two tables may use `customer_id` and `client_id` for the same
identifier. We can state the correspondence explicitly with a named `by`
vector.

``` r
client_lookup <- data.frame(
  client_id = c("C01", "C02", "C03"),
  loyalty_level = c("Gold", "Silver", "Bronze")
)
if (has_dplyr) {
  print(dplyr::left_join(orders_tbl, client_lookup,
                         by = c("customer_id" = "client_id")))
}
```

    ## # A tibble: 5 × 5
    ##   order_id customer_id product_id quantity loyalty_level
    ##   <chr>    <chr>       <chr>         <int> <chr>        
    ## 1 O101     C01         P1                2 Gold         
    ## 2 O102     C02         P2                1 Silver       
    ## 3 O103     C01         P3                3 Gold         
    ## 4 O104     C05         P1                1 <NA>         
    ## 5 O105     C03         P2                2 Bronze

# 9. Joining on multiple columns

Sometimes a single identifier is not unique across locations or years.
In that case, the join key must contain all relevant columns. Joining
only by product code could attach the wrong warehouse stock count.

``` r
requests <- data.frame(
  warehouse = c("North", "South", "North"),
  sku = c("A1", "A1", "B2"),
  requested = c(3L, 4L, 2L)
)
inventory <- data.frame(
  warehouse = c("North", "South", "North"),
  sku = c("A1", "A1", "B2"),
  available = c(10L, 1L, 8L)
)
if (has_dplyr) {
  print(dplyr::left_join(requests, inventory,
                         by = c("warehouse", "sku")))
}
```

    ##   warehouse sku requested available
    ## 1     North  A1         3        10
    ## 2     South  A1         4         1
    ## 3     North  B2         2         8

``` r
merge(requests, inventory, by = c("warehouse", "sku"), all.x = TRUE)
```

    ##   warehouse sku requested available
    ## 1     North  A1         3        10
    ## 2     North  B2         2         8
    ## 3     South  A1         4         1

# 10. Missing keys and the meaning of `NA`

Missing keys are not ordinary values. Base R and `dplyr` can match
missing keys under some defaults, which may be inappropriate for real
identifiers. Modern `dplyr` allows `na_matches = "never"` so missing
identifiers are not treated as a match.

``` r
missing_left <- data.frame(id = c("A", NA_character_, "B"),
                           amount = c(10, 20, 30))
missing_right <- data.frame(id = c("A", NA_character_),
                            label = c("Known", "Unknown"))
if (has_dplyr) {
  print(dplyr::left_join(missing_left, missing_right, by = "id"))
  print(dplyr::left_join(missing_left, missing_right,
                         by = "id", na_matches = "never"))
}
```

    ##     id amount   label
    ## 1    A     10   Known
    ## 2 <NA>     20 Unknown
    ## 3    B     30    <NA>
    ##     id amount label
    ## 1    A     10 Known
    ## 2 <NA>     20  <NA>
    ## 3    B     30  <NA>

``` r
print(merge(missing_left, missing_right, by = "id", all.x = TRUE))
```

    ##     id amount   label
    ## 1    A     10   Known
    ## 2    B     30    <NA>
    ## 3 <NA>     20 Unknown

The presence of `NA` in a joined column does not by itself prove a
failed match: the matching right-hand row may legitimately contain a
missing attribute. For a reliable match indicator, we can add a marker
column to the lookup table before joining.

``` r
if (has_dplyr) {
  marked_customers <- dplyr::mutate(customers_tbl, .matched_customer = TRUE)
  checked <- dplyr::left_join(orders_tbl, marked_customers,
                              by = "customer_id", na_matches = "never")
  checked$.matched_customer[is.na(checked$.matched_customer)] <- FALSE
  print(checked[, c("order_id", "customer_id", ".matched_customer")])
}
```

    ## # A tibble: 5 × 3
    ##   order_id customer_id .matched_customer
    ##   <chr>    <chr>       <lgl>            
    ## 1 O101     C01         TRUE             
    ## 2 O102     C02         TRUE             
    ## 3 O103     C01         TRUE             
    ## 4 O104     C05         FALSE            
    ## 5 O105     C03         TRUE

# 11. Finding orphan records with anti joins

An **orphan record** references a key absent from the lookup table. An
anti join exposes these records without requiring us to inspect every
joined column. This is one of the most valuable practical uses of
`dplyr` joins.

``` r
if (has_dplyr) {
  orphan_orders <- dplyr::anti_join(
    orders_tbl, customers_tbl, by = "customer_id", na_matches = "never"
  )
  print(orphan_orders)
  cat("Orphan order count:", nrow(orphan_orders), "
")
} else {
  print(orders[!(orders$customer_id %in% customers$customer_id), , drop = FALSE])
}
```

    ## # A tibble: 1 × 4
    ##   order_id customer_id product_id quantity
    ##   <chr>    <chr>       <chr>         <int>
    ## 1 O104     C05         P1                1
    ## Orphan order count: 1

# 12. Preventing unintended column name collisions

If both tables contain a non-key column named `status`, `dplyr` adds
suffixes such as `.x` and `.y` to distinguish the sources. We can choose
more meaningful suffixes and rename fields before joining.

``` r
shipments <- data.frame(order_id = c("O101", "O102"),
                        status = c("Dispatched", "Pending"))
order_status <- data.frame(order_id = c("O101", "O102", "O103"),
                           status = c("Paid", "Paid", "Awaiting payment"))
if (has_dplyr) {
  print(dplyr::left_join(order_status, shipments, by = "order_id",
                         suffix = c("_payment", "_shipping")))
}
```

    ##   order_id   status_payment status_shipping
    ## 1     O101             Paid      Dispatched
    ## 2     O102             Paid         Pending
    ## 3     O103 Awaiting payment            <NA>

# 13. Key type mismatches and normalization

Keys that look identical can fail to match because of different types,
leading spaces, inconsistent capitalization, or leading zeros. We should
normalize deliberately and retain original values when auditability
matters.

**Leading-zero warning:** converting a character identifier such as
`"0012"` to numeric produces `12`. That conversion can destroy
meaningful identifiers. Prefer character keys for codes and IDs.

``` r
dirty_ids <- data.frame(customer_id = c(" c01 ", "C02", "c03"),
                        source = c("web", "store", "web"))
dirty_ids$normalized_id <- toupper(trimws(dirty_ids$customer_id))
print(dirty_ids)
```

    ##   customer_id source normalized_id
    ## 1        c01     web           C01
    ## 2         C02  store           C02
    ## 3         c03    web           C03

``` r
if (has_dplyr) {
  print(dplyr::left_join(dirty_ids, customers_tbl,
                         by = c("normalized_id" = "customer_id")))
}
```

    ##   customer_id source normalized_id customer_name  city
    ## 1        c01     web           C01          Asha Delhi
    ## 2         C02  store           C02           Ben  Pune
    ## 3         c03    web           C03         Carla Kochi

# 14. Joining and preserving expected row counts

For a many-to-one lookup join, the expected row count is exactly the
number of rows in the left table. We can enforce this as a test.
However, row-count equality alone does not guarantee correctness: one
duplicate match can offset one missing row in certain transformations.
We should also test key uniqueness, unmatched records, and known values.

``` r
if (has_dplyr) {
  enriched_orders <- dplyr::left_join(
    orders_tbl, customers_tbl, by = "customer_id", na_matches = "never"
  )
  stopifnot(nrow(enriched_orders) == nrow(orders_tbl))
  stopifnot(!anyDuplicated(enriched_orders$order_id))
  stopifnot(enriched_orders$customer_name[
    enriched_orders$order_id == "O101"] == "Asha")
  cat("Row count, order ID uniqueness, and spot check passed.
")
}
```

    ## Row count, order ID uniqueness, and spot check passed.

# 15. Controlling unmatched rows and multiple matches (modern dplyr)

Recent `dplyr` versions add options that make assumptions explicit.
`relationship` checks the cardinality we expect; `unmatched` can raise
an error when rows that would be dropped are present; `multiple`
controls which match is returned in cases where multiple matches are
possible. Selecting `"first"` or `"last"` should not be used to conceal
a data-model problem.

``` r
if (modern_dplyr) {
  validated <- dplyr::left_join(
    orders_tbl, customers_tbl,
    by = "customer_id", relationship = "many-to-one",
    na_matches = "never"
  )
  print(validated)
  # For an inner join, unmatched = "error" would reject unmatched rows.
  tryCatch(
    dplyr::inner_join(orders_tbl, customers_tbl,
                      by = "customer_id", unmatched = "error"),
    error = function(e) message("Expected validation error: ", conditionMessage(e))
  )
}
```

    ## # A tibble: 5 × 6
    ##   order_id customer_id product_id quantity customer_name city 
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr>
    ## 1 O101     C01         P1                2 Asha          Delhi
    ## 2 O102     C02         P2                1 Ben           Pune 
    ## 3 O103     C01         P3                3 Asha          Delhi
    ## 4 O104     C05         P1                1 <NA>          <NA> 
    ## 5 O105     C03         P2                2 Carla         Kochi

    ## Expected validation error: Each row of `x` must have a match in `y`.
    ## ℹ Row 4 of `x` does not have a match.

# 16. Non-equality joins and `join_by()`

An equality join matches when two keys are equal. A **non-equality
join** can match on inequalities, such as assigning a sale to a
promotion when the sale date falls between the promotion’s start and end
dates. `join_by()` also supports rolling and overlap helpers in modern
`dplyr`.

These joins can produce multiple matches when intervals overlap. We
should check whether overlap is allowed before deciding how to handle
it.

``` r
sales_dates <- data.frame(
  sale_id = c("S1", "S2", "S3"),
  sale_date = as.Date(c("2026-03-02", "2026-03-09", "2026-03-20"))
)
promotions <- data.frame(
  promotion = c("Early March", "Mid March"),
  start_date = as.Date(c("2026-03-01", "2026-03-08")),
  end_date = as.Date(c("2026-03-07", "2026-03-15"))
)
if (modern_dplyr) {
  print(dplyr::left_join(
    sales_dates, promotions,
    by = dplyr::join_by(sale_date >= start_date, sale_date <= end_date)
  ))
}
```

    ##   sale_id  sale_date   promotion start_date   end_date
    ## 1      S1 2026-03-02 Early March 2026-03-01 2026-03-07
    ## 2      S2 2026-03-09   Mid March 2026-03-08 2026-03-15
    ## 3      S3 2026-03-20        <NA>       <NA>       <NA>

# 17. Joining more than two tables

A common workflow is to enrich orders with customer details and then
product details. We should inspect the relationship at **each step**,
rather than performing several joins and validating only the final
result.

``` r
if (has_dplyr) {
  order_details <- orders_tbl |>
    dplyr::left_join(customers_tbl, by = "customer_id") |>
    dplyr::left_join(products_tbl, by = "product_id") |>
    dplyr::mutate(line_total = quantity * unit_price)
  print(order_details)
  stopifnot(nrow(order_details) == nrow(orders_tbl))
} else {
  order_details <- merge(orders, customers, by = "customer_id", all.x = TRUE)
  order_details <- merge(order_details, products, by = "product_id", all.x = TRUE)
  order_details$line_total <- order_details$quantity * order_details$unit_price
  print(order_details)
}
```

    ## # A tibble: 5 × 9
    ##   order_id customer_id product_id quantity customer_name city  product_name
    ##   <chr>    <chr>       <chr>         <int> <chr>         <chr> <chr>       
    ## 1 O101     C01         P1                2 Asha          Delhi Notebook    
    ## 2 O102     C02         P2                1 Ben           Pune  Pen Set     
    ## 3 O103     C01         P3                3 Asha          Delhi Desk Lamp   
    ## 4 O104     C05         P1                1 <NA>          <NA>  Notebook    
    ## 5 O105     C03         P2                2 Carla         Kochi Pen Set     
    ## # ℹ 2 more variables: unit_price <dbl>, line_total <dbl>

# 18. Joining versus binding

**Joining** combines columns by matching identifiers. **Row binding**
stacks observations with compatible variables. **Column binding**
attaches variables by row position and should be used only when the rows
are known to correspond exactly.

| Operation   | How rows align         | Main risk                       |
|:------------|:-----------------------|:--------------------------------|
| Join        | Matching key values    | Duplicated or missing matches   |
| Row bind    | Column names and types | Inconsistent schemas or units   |
| Column bind | Row position           | Silent misalignment of entities |

# 19. Combining rows with `bind_rows()`

`dplyr::bind_rows()` combines datasets with columns aligned by name.
Missing columns are filled with `NA`, and compatible types are
reconciled. Base R’s `rbind()` generally requires compatible column
structure.

``` r
january <- data.frame(order_id = c("J1", "J2"),
                      amount = c(100, 200))
february <- data.frame(order_id = c("F1", "F2"),
                       amount = c(150, 250),
                       channel = c("online", "store"))
if (has_dplyr) {
  combined_months <- dplyr::bind_rows(january, february, .id = "source")
  print(combined_months)
}
```

    ##   source order_id amount channel
    ## 1      1       J1    100    <NA>
    ## 2      1       J2    200    <NA>
    ## 3      2       F1    150  online
    ## 4      2       F2    250   store

``` r
# Base R requires the same columns before rbind():
jan_aligned <- january
jan_aligned$channel <- NA_character_
print(rbind(jan_aligned, february))
```

    ##   order_id amount channel
    ## 1       J1    100    <NA>
    ## 2       J2    200    <NA>
    ## 3       F1    150  online
    ## 4       F2    250   store

The `.id` column is most useful when the inputs are supplied as a
**named list**. It records the list element name, making it possible to
trace where each row originated.

``` r
if (has_dplyr) {
  monthly <- list(January = january, February = february)
  print(dplyr::bind_rows(monthly, .id = "month_source"))
}
```

    ##   month_source order_id amount channel
    ## 1      January       J1    100    <NA>
    ## 2      January       J2    200    <NA>
    ## 3     February       F1    150  online
    ## 4     February       F2    250   store

# 20. Combining columns with `bind_cols()`

`bind_cols()` combines objects by position, not by ID. It is appropriate
only when the rows are guaranteed to be aligned. We should use a keyed
join for independent datasets.

``` r
employee_names <- data.frame(employee_id = c("E1", "E2", "E3"),
                             name = c("Riya", "Omar", "Tina"))
employee_teams <- data.frame(team = c("Support", "Sales", "Design"))
if (has_dplyr) {
  print(dplyr::bind_cols(employee_names, employee_teams))
}
```

    ##   employee_id name    team
    ## 1          E1 Riya Support
    ## 2          E2 Omar   Sales
    ## 3          E3 Tina  Design

``` r
print(cbind(employee_names, employee_teams))
```

    ##   employee_id name    team
    ## 1          E1 Riya Support
    ## 2          E2 Omar   Sales
    ## 3          E3 Tina  Design

## Why row order matters

The following two tables have the same employee IDs but in different
orders. Column binding would assign the wrong team. A join matches IDs
correctly.

``` r
team_lookup <- data.frame(employee_id = c("E3", "E1", "E2"),
                          team = c("Design", "Support", "Sales"))
if (has_dplyr) {
  print(dplyr::left_join(employee_names, team_lookup, by = "employee_id"))
} else {
  print(merge(employee_names, team_lookup, by = "employee_id", all.x = TRUE))
}
```

    ##   employee_id name    team
    ## 1          E1 Riya Support
    ## 2          E2 Omar   Sales
    ## 3          E3 Tina  Design

# 21. Base R `rbind()`, `cbind()`, and `merge()`

These functions remain important for portable R scripts. We can choose
the smallest tool that clearly expresses our intended operation.

``` r
first_batch <- data.frame(id = 1:2, score = c(7, 9))
second_batch <- data.frame(id = 3:4, score = c(8, 6))
print(rbind(first_batch, second_batch))
```

    ##   id score
    ## 1  1     7
    ## 2  2     9
    ## 3  3     8
    ## 4  4     6

``` r
print(cbind(first_batch, flag = c(TRUE, FALSE)))
```

    ##   id score  flag
    ## 1  1     7  TRUE
    ## 2  2     9 FALSE

``` r
print(merge(first_batch, data.frame(id = c(1, 2), group = c("A", "B")),
            by = "id"))
```

    ##   id score group
    ## 1  1     7     A
    ## 2  2     9     B

# 22. Combining tables with inconsistent types

Files exported from different systems may represent the same field as
integer in one table and character in another. Before row binding, we
should decide the intended data type and convert explicitly. Combining a
character identifier with a numeric identifier can erase leading zeros
or produce type errors.

``` r
batch_a <- data.frame(order_id = c("001", "002"),
                      amount = c(100, 200))
batch_b <- data.frame(order_id = c(3L, 4L),
                      amount = c(150, 175))
batch_b$order_id <- sprintf("%03d", batch_b$order_id)
if (has_dplyr) {
  print(dplyr::bind_rows(batch_a, batch_b))
} else {
  print(rbind(batch_a, batch_b))
}
```

    ##   order_id amount
    ## 1      001    100
    ## 2      002    200
    ## 3      003    150
    ## 4      004    175

# 23. Set operations: `union()`, `intersect()`, `setdiff()`

Set operations answer a different question from joins. They compare
whole rows (for data frames) or values (for vectors) and generally
remove duplicates. For distinct identifiers, base R vector operations
are particularly convenient.

``` r
online_ids <- c("C01", "C02", "C03", "C03")
store_ids <- c("C02", "C04")
union(online_ids, store_ids)
```

    ## [1] "C01" "C02" "C03" "C04"

``` r
intersect(online_ids, store_ids)
```

    ## [1] "C02"

``` r
setdiff(online_ids, store_ids)
```

    ## [1] "C01" "C03"

``` r
setdiff(store_ids, online_ids)
```

    ## [1] "C04"

``` r
setequal(c("A", "B"), c("B", "A", "A"))
```

    ## [1] TRUE

When using `dplyr` set operations on data frames, the inputs should have
compatible columns. A semi join, by contrast, returns matching rows from
the left table without requiring identical schemas.

``` r
if (has_dplyr) {
  x <- data.frame(id = c("A", "B", "C"))
  y <- data.frame(id = c("B", "C", "D"))
  print(dplyr::union(x, y))
  print(dplyr::intersect(x, y))
  print(dplyr::setdiff(x, y))
}
```

    ##   id
    ## 1  A
    ## 2  B
    ## 3  C
    ## 4  D
    ##   id
    ## 1  B
    ## 2  C
    ##   id
    ## 1  A

# 24. A robust reusable join-validation function

In a production workflow, repeated manual checks are easy to forget. We
can package common validations into a function. The following function
checks that the lookup key is unique, counts unmatched left-hand rows,
and verifies that a left join did not unexpectedly change row count. It
uses base R so it works without additional packages.

``` r
audit_left_join <- function(left, right, key) {
  stopifnot(is.data.frame(left), is.data.frame(right),
            length(key) >= 1L,
            all(key %in% names(left)),
            all(key %in% names(right)))
  if (anyDuplicated(right[key])) {
    stop("Lookup table has duplicate key combinations")
  }
  # Match multi-column keys by their row-wise data-frame representation.
  # Rows with missing key components are excluded from matching.
  complete_left <- stats::complete.cases(left[key])
  complete_right <- stats::complete.cases(right[key])
  encode <- function(df) {
    if (nrow(df) == 0L) return(character())
    do.call(paste, c(lapply(df, function(z) {
      # Length-prefixed strings avoid collisions caused by separators.
      value <- as.character(z)
      paste0(nchar(value, type = "bytes"), ":", value)
    }), sep = "|"))
  }
  left_key <- encode(left[key])
  right_key <- encode(right[key])
  matched <- complete_left & (left_key %in% right_key[complete_right])
  list(left_rows = nrow(left),
       lookup_rows = nrow(right),
       matched_left_rows = sum(matched),
       unmatched_left_rows = sum(!matched),
       unmatched_left_indices = which(!matched))
}
print(audit_left_join(orders, customers, "customer_id"))
```

    ## $left_rows
    ## [1] 5
    ## 
    ## $lookup_rows
    ## [1] 4
    ## 
    ## $matched_left_rows
    ## [1] 4
    ## 
    ## $unmatched_left_rows
    ## [1] 1
    ## 
    ## $unmatched_left_indices
    ## [1] 4

The helper above is a teaching implementation for ordinary
character-like keys. For strict production use, key classes, encodings,
missing-value semantics, and composite-key serialization deserve
explicit tests. In particular, delimiter-based encodings require care if
identifiers can contain unusual characters. The `dplyr` joins themselves
should remain the authoritative matching operation.

# 25. Complete practical project: store orders and reference tables

Our goal is to produce an order-level report with customer names,
product names, and line totals. We also want a separate data-quality
report showing missing customers and missing products. The process
follows a repeatable sequence: inspect → validate → find orphans → join
→ calculate → test → summarize.

## Step 1. Inspect the source tables

``` r
source_tables <- list(customers = customers,
                      orders = orders,
                      products = products)
source_overview <- data.frame(
  table = names(source_tables),
  rows = vapply(source_tables, nrow, integer(1)),
  columns = vapply(source_tables, ncol, integer(1))
)
print(source_overview)
```

    ##               table rows columns
    ## customers customers    4       3
    ## orders       orders    5       4
    ## products   products    4       3

``` r
str(orders)
```

    ## 'data.frame':    5 obs. of  4 variables:
    ##  $ order_id   : chr  "O101" "O102" "O103" "O104" ...
    ##  $ customer_id: chr  "C01" "C02" "C01" "C05" ...
    ##  $ product_id : chr  "P1" "P2" "P3" "P1" ...
    ##  $ quantity   : int  2 1 3 1 2

## Step 2. Validate the primary keys

``` r
assert_unique_key(customers, "customer_id", "customers")
assert_unique_key(products, "product_id", "products")
assert_unique_key(orders, "order_id", "orders")
cat("All declared primary keys are unique and nonmissing.
")
```

    ## All declared primary keys are unique and nonmissing.

## Step 3. Report missing reference records

``` r
if (has_dplyr) {
  unknown_customers <- dplyr::anti_join(orders, customers,
                                        by = "customer_id")
  unknown_products <- dplyr::anti_join(orders, products,
                                       by = "product_id")
} else {
  unknown_customers <- orders[!(orders$customer_id %in% customers$customer_id),
                              , drop = FALSE]
  unknown_products <- orders[!(orders$product_id %in% products$product_id),
                             , drop = FALSE]
}
print(unknown_customers)
```

    ##   order_id customer_id product_id quantity
    ## 1     O104         C05         P1        1

``` r
print(unknown_products)
```

    ## [1] order_id    customer_id product_id  quantity   
    ## <0 rows> (or 0-length row.names)

## Step 4. Enrich order records

``` r
if (has_dplyr) {
  report <- orders |>
    dplyr::left_join(customers, by = "customer_id") |>
    dplyr::left_join(products, by = "product_id") |>
    dplyr::mutate(line_total = quantity * unit_price)
} else {
  report <- merge(orders, customers, by = "customer_id", all.x = TRUE,
                  sort = FALSE)
  report <- merge(report, products, by = "product_id", all.x = TRUE,
                  sort = FALSE)
  report$line_total <- report$quantity * report$unit_price
}
print(report)
```

    ##   order_id customer_id product_id quantity customer_name  city product_name
    ## 1     O101         C01         P1        2          Asha Delhi     Notebook
    ## 2     O102         C02         P2        1           Ben  Pune      Pen Set
    ## 3     O103         C01         P3        3          Asha Delhi    Desk Lamp
    ## 4     O104         C05         P1        1          <NA>  <NA>     Notebook
    ## 5     O105         C03         P2        2         Carla Kochi      Pen Set
    ##   unit_price line_total
    ## 1         80        160
    ## 2        120        120
    ## 3        650       1950
    ## 4         80         80
    ## 5        120        240

## Step 5. Validate the report

``` r
stopifnot(nrow(report) == nrow(orders))
stopifnot(!anyDuplicated(report$order_id))
stopifnot(all(report$line_total == report$quantity * report$unit_price,
              na.rm = TRUE))
stopifnot(setequal(report$order_id, orders$order_id))
cat("Project validation checks passed.
")
```

    ## Project validation checks passed.

## Step 6. Produce an operational summary

``` r
if (has_dplyr) {
  summary_by_city <- report |>
    dplyr::group_by(city) |>
    dplyr::summarise(
      orders = dplyr::n(),
      revenue = sum(line_total, na.rm = TRUE),
      .groups = "drop"
    )
} else {
  summary_by_city <- aggregate(
    line_total ~ city, data = report,
    FUN = sum, na.rm = TRUE
  )
}
print(summary_by_city)
```

    ## # A tibble: 4 × 3
    ##   city  orders revenue
    ##   <chr>  <int>   <dbl>
    ## 1 Delhi      2    2110
    ## 2 Kochi      1     240
    ## 3 Pune       1     120
    ## 4 <NA>       1      80

**Interpretation caution:** The revenue summary excludes unknown city
labels in base R’s formula-based `aggregate()` but may include an `NA`
group in `dplyr`. If missing customers should be tracked separately, we
should label them explicitly before aggregation and use the same rule in
both implementations.

# 26. Common mistakes and troubleshooting

| Symptom | Likely cause | Practical remedy |
|:---|:---|:---|
| Joined table has too many rows | Duplicate keys on both sides | Check `anyDuplicated()` and expected relationship |
| Many new `NA` values | Unmatched keys or genuinely missing lookup attributes | Run `anti_join()` and add a match marker |
| No matches despite similar-looking IDs | Different case, whitespace, or types | Normalize with `trimws()`, `toupper()`, and explicit types |
| Wrong attributes after `bind_cols()` | Rows were not in identical order | Use a keyed join instead |
| `bind_rows()` fails | Incompatible column types | Harmonize types before binding |
| Columns end in `.x` and `.y` | Duplicate non-key names | Rename first or set `suffix` |
| `join_by()` unavailable | Older `dplyr` version | Check `packageVersion("dplyr")` |
| `merge()` changes row order | Default sorting | Avoid positional assumptions; restore order with a stable ID |
| Join errors about relationships | Data violates declared cardinality | Investigate duplicate keys, not just the warning |
| Missing IDs unexpectedly match | Default missing-key matching | Use `na_matches = "never"` where appropriate |

## A deliberate debugging example

``` r
bad_lookup <- data.frame(customer_id = c("C01", "C01", "C02"),
                         segment = c("Retail", "Wholesale", "Retail"))
cat("Duplicate lookup keys:", anyDuplicated(bad_lookup$customer_id) > 0L, "
")
```

    ## Duplicate lookup keys: TRUE

``` r
tryCatch(
  assert_unique_key(bad_lookup, "customer_id", "bad_lookup"),
  error = function(e) message("Detected: ", conditionMessage(e))
)
```

    ## Detected: bad_lookup contains duplicate key combinations

``` r
cat("Rows before:", nrow(orders), "
")
```

    ## Rows before: 5

``` r
cat("Rows after:", nrow(merge(orders, bad_lookup,
                                  by = "customer_id", all.x = TRUE)), "
")
```

    ## Rows after: 7

# 27. Good practices for reliable data integration

1.  Define the business meaning of every join key before writing code.
2.  Preserve identifiers as character strings when leading zeros matter.
3.  Verify primary-key uniqueness in lookup tables.
4.  Use `anti_join()` to inspect unmatched foreign keys.
5.  Specify join columns explicitly rather than relying on all shared
    names.
6.  State the expected cardinality and validate it where supported.
7.  Avoid column binding independently sorted tables.
8.  Keep source tables unchanged and create new result objects.
9.  Check row counts, distinct IDs, missing values, and representative
    records.
10. Record transformation decisions so the workflow can be reproduced.

# 28. Guided exercises

The exercises are designed to be completed in order. Each uses only the
datasets created in this chapter.

## Beginner exercises

**Exercise 1.** Perform a base R inner join between `orders` and
`customers`. Explain why `O104` is missing.

**Exercise 2.** Create a left join that retains all five orders.
Identify the row with a missing customer name.

**Exercise 3.** List customers who have never placed an order. Use a
right join or a suitable anti join.

**Exercise 4.** Combine the `january` and `february` tables by rows,
retaining the source month.

**Exercise 5.** Explain why `bind_cols()` is unsafe when independent
tables have been sorted differently.

## Intermediate exercises

**Exercise 6.** Create a report containing `order_id`, `customer_name`,
`product_name`, `quantity`, and `line_total`.

**Exercise 7.** Check whether `customer_id` is unique in `customers` and
whether `order_id` is unique in `orders`.

**Exercise 8.** Join `requests` to `inventory` using both `warehouse`
and `sku`. Add an `enough_stock` logical column.

**Exercise 9.** Find orphan orders using `anti_join()`. Compare the
result with a base R `%in%` approach.

**Exercise 10.** Create a pair of tables with different names for the
same key and join them using a named `by` vector.

## Advanced exercises

**Exercise 11.** Construct a many-to-many join that creates more rows
than either input. Explain the multiplication of matches.

**Exercise 12.** Use `relationship = "many-to-one"` to enforce an
expected lookup relationship, when supported.

**Exercise 13.** Join sales to promotional date ranges using `join_by()`
and inequalities, when supported.

**Exercise 14.** Create a reusable function that rejects duplicate
lookup keys before joining.

**Exercise 15.** Develop a reconciliation report that counts matched and
unmatched orders and checks that every original `order_id` is retained
exactly once.

# 29. Challenge project: employee assignments across departments

A company keeps employee records, department records, and project
assignments separately. Some assignments reference an unknown employee,
and an employee can work on multiple projects.

Our tasks are to identify unmatched assignments, enrich assignments with
employee and department details, calculate the number of projects per
employee, and verify that the join does not accidentally duplicate
assignments.

``` r
employees <- data.frame(
  employee_id = c("E01", "E02", "E03", "E04"),
  employee_name = c("Mina", "Kabir", "Leah", "Nikhil"),
  department_id = c("D1", "D2", "D1", "D3")
)
departments <- data.frame(
  department_id = c("D1", "D2", "D3"),
  department_name = c("Operations", "Technology", "Marketing")
)
assignments <- data.frame(
  assignment_id = c("A1", "A2", "A3", "A4", "A5"),
  employee_id = c("E01", "E01", "E02", "E03", "E99"),
  project = c("Launch", "Training", "Website", "Support", "Audit")
)
print(employees)
```

    ##   employee_id employee_name department_id
    ## 1         E01          Mina            D1
    ## 2         E02         Kabir            D2
    ## 3         E03          Leah            D1
    ## 4         E04        Nikhil            D3

``` r
print(departments)
```

    ##   department_id department_name
    ## 1            D1      Operations
    ## 2            D2      Technology
    ## 3            D3       Marketing

``` r
print(assignments)
```

    ##   assignment_id employee_id  project
    ## 1            A1         E01   Launch
    ## 2            A2         E01 Training
    ## 3            A3         E02  Website
    ## 4            A4         E03  Support
    ## 5            A5         E99    Audit

## Worked solution

We first identify unknown employee references. We then join assignments
to employees and departments. The expected relationship from assignments
to employees is many-to-one; from employees to departments it is also
many-to-one.

``` r
if (has_dplyr) {
  invalid_assignments <- dplyr::anti_join(
    assignments, employees, by = "employee_id"
  )
  enriched_assignments <- assignments |>
    dplyr::left_join(employees, by = "employee_id") |>
    dplyr::left_join(departments, by = "department_id")
  employee_workload <- enriched_assignments |>
    dplyr::filter(!is.na(employee_name)) |>
    dplyr::count(employee_id, employee_name, name = "project_count")
} else {
  invalid_assignments <- assignments[
    !(assignments$employee_id %in% employees$employee_id), , drop = FALSE
  ]
  enriched_assignments <- merge(assignments, employees,
                                by = "employee_id", all.x = TRUE)
  enriched_assignments <- merge(enriched_assignments, departments,
                                by = "department_id", all.x = TRUE)
  valid_rows <- !is.na(enriched_assignments$employee_name)
  employee_workload <- aggregate(
    assignment_id ~ employee_id + employee_name,
    data = enriched_assignments[valid_rows, , drop = FALSE],
    FUN = length
  )
  names(employee_workload)[3] <- "project_count"
}
print(invalid_assignments)
```

    ##   assignment_id employee_id project
    ## 1            A5         E99   Audit

``` r
print(enriched_assignments)
```

    ##   assignment_id employee_id  project employee_name department_id
    ## 1            A1         E01   Launch          Mina            D1
    ## 2            A2         E01 Training          Mina            D1
    ## 3            A3         E02  Website         Kabir            D2
    ## 4            A4         E03  Support          Leah            D1
    ## 5            A5         E99    Audit          <NA>          <NA>
    ##   department_name
    ## 1      Operations
    ## 2      Operations
    ## 3      Technology
    ## 4      Operations
    ## 5            <NA>

``` r
print(employee_workload)
```

    ##   employee_id employee_name project_count
    ## 1         E01          Mina             2
    ## 2         E02         Kabir             1
    ## 3         E03          Leah             1

``` r
stopifnot(nrow(enriched_assignments) == nrow(assignments))
stopifnot(!anyDuplicated(enriched_assignments$assignment_id))
```

# 30. Complete standalone practice script

The following script is independent of the chapter’s earlier code
chunks. It constructs its own datasets, checks uniqueness, finds missing
lookup references, joins records, calculates order totals, and verifies
that no orders were lost or duplicated. It works with base R; when
`dplyr` is installed, it uses the corresponding tidyverse operations.

``` r
# ----- BEGIN STANDALONE SCRIPT -----
options(stringsAsFactors = FALSE)
use_dplyr <- requireNamespace("dplyr", quietly = TRUE)

customers_demo <- data.frame(
  customer_id = c("C1", "C2", "C3"),
  name = c("Asha", "Ben", "Carla")
)
products_demo <- data.frame(
  product_id = c("P1", "P2"),
  description = c("Notebook", "Pen"),
  price = c(75, 30)
)
orders_demo <- data.frame(
  order_id = c("O1", "O2", "O3", "O4"),
  customer_id = c("C1", "C2", "C9", "C1"),
  product_id = c("P1", "P2", "P1", "P2"),
  units = c(2L, 5L, 1L, 3L)
)

stopifnot(!anyDuplicated(customers_demo$customer_id))
stopifnot(!anyDuplicated(products_demo$product_id))
stopifnot(!anyDuplicated(orders_demo$order_id))

if (use_dplyr) {
  unmatched_demo <- dplyr::anti_join(
    orders_demo, customers_demo, by = "customer_id"
  )
  result_demo <- orders_demo |>
    dplyr::left_join(customers_demo, by = "customer_id") |>
    dplyr::left_join(products_demo, by = "product_id") |>
    dplyr::mutate(total = units * price)
} else {
  unmatched_demo <- orders_demo[
    !(orders_demo$customer_id %in% customers_demo$customer_id),
    , drop = FALSE
  ]
  result_demo <- merge(orders_demo, customers_demo,
                       by = "customer_id", all.x = TRUE)
  result_demo <- merge(result_demo, products_demo,
                       by = "product_id", all.x = TRUE)
  result_demo$total <- result_demo$units * result_demo$price
}

stopifnot(nrow(result_demo) == nrow(orders_demo))
stopifnot(!anyDuplicated(result_demo$order_id))
stopifnot(setequal(result_demo$order_id, orders_demo$order_id))
cat("Unknown customer orders:
")
```

    ## Unknown customer orders:

``` r
print(unmatched_demo)
```

    ##   order_id customer_id product_id units
    ## 1       O3          C9         P1     1

``` r
cat("Enriched order report:
")
```

    ## Enriched order report:

``` r
print(result_demo)
```

    ##   order_id customer_id product_id units name description price total
    ## 1       O1          C1         P1     2 Asha    Notebook    75   150
    ## 2       O2          C2         P2     5  Ben         Pen    30   150
    ## 3       O3          C9         P1     1 <NA>    Notebook    75    75
    ## 4       O4          C1         P2     3 Asha         Pen    30    90

``` r
cat("Total sales value:", sum(result_demo$total, na.rm = TRUE), "
")
```

    ## Total sales value: 465

``` r
# ----- END STANDALONE SCRIPT -----
```

# 31. Knowledge check

1.  What is the difference between a primary key and a foreign key?
2.  Why can a left join produce more rows than its left input?
3.  When would we choose `semi_join()` rather than `inner_join()`?
4.  How does `anti_join()` help with data quality?
5.  What is the difference between joining on one key and joining on a
    composite key?
6.  Why is matching missing identifiers potentially dangerous?
7.  What does `relationship = "many-to-one"` express?
8.  Why is `bind_cols()` not a substitute for a join?
9.  How does `bind_rows()` handle a column that exists in only one
    input?
10. What is the difference between a join and a set operation?
11. How can we identify an unintended many-to-many join?
12. Which checks should we perform before and after enriching an order
    table?

# 32. Key takeaways

- A **join** matches records by keys; **binding** combines records by
  row or column position.
- `inner_join()`, `left_join()`, `right_join()`, and `full_join()`
  differ in which unmatched rows they retain.
- `semi_join()` and `anti_join()` are especially useful for membership
  tests and identifying orphan records.
- A many-to-many join can multiply rows; we must understand cardinality
  before joining.
- Missing identifiers, inconsistent types, duplicate keys, and
  column-name collisions require deliberate handling.
- `bind_rows()` stacks observations by column name, whereas
  `bind_cols()` assumes positional alignment.
- Base R offers `merge()`, `rbind()`, `cbind()`, and vector set
  operations for portable workflows.
- Reliable data integration requires validation before **and** after the
  join.

# Looking ahead

**Chapter 26 — Data Reshaping with `tidyr`** introduces long and wide
formats, `pivot_longer()`, `pivot_wider()`, `separate_wider_delim()`,
`unite()`, and other tools for restructuring data.
