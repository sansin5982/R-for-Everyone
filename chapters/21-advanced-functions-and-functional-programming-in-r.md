Advanced Functions and Functional Programming in R
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

# Introduction

Functions are more than reusable blocks of code. In R, **functions are
objects**: we can assign them to variables, store them in lists, pass
them into other functions, and return them from functions. These
properties make functional programming possible. This chapter extends
our earlier chapters on functions, loops, and the apply family. Our goal
is to write code that is reusable, testable, predictable, and easy to
combine.

All required exercises use **base R**. Optional `purrr` examples run
only if the package is installed. Examples use general-purpose data such
as orders, scores, and inventory rather than specialist statistical
methods.

## Learning objectives

By the end of the chapter, we should be able to:

1.  Treat functions as first-class objects.
2.  Pass functions as arguments and return functions as results.
3.  Explain lexical scoping and environments.
4.  Create closures that retain state or configuration.
5.  Use anonymous functions and the base R pipe.
6.  Distinguish pure functions from functions with side effects.
7.  Apply `lapply()`, `vapply()`, `Map()`, `Reduce()`, `Filter()`,
    `Find()`, and `Position()`.
8.  Understand `...`, `do.call()`, and argument forwarding.
9.  Build function factories and composable pipelines.
10. Handle failures safely and test reusable functions.
11. Recognize when loops are clearer than functional alternatives.
12. Compare base R techniques with selected `purrr` functions.

# 1. Functions are values

A function can be assigned to a variable without calling it. Parentheses
call the function; omitting parentheses refers to the function itself.

``` r
square <- function(x) x^2
operation <- square
operation(5)
```

    ## [1] 25

``` r
identical(square, operation)
```

    ## [1] TRUE

``` r
is.function(operation)
```

    ## [1] TRUE

We can also store functions in a list:

``` r
operations <- list(
  double = function(x) 2 * x,
  square = function(x) x^2,
  increment = function(x) x + 1
)

operations$square(4)
```

    ## [1] 16

``` r
vapply(operations, function(f) f(3), numeric(1))
```

    ##    double    square increment 
    ##         6         9         4

The list stores **functions**, not their results. Each function is
called only when we explicitly apply it.

## 1.1 Functions as arguments

A **higher-order function** accepts another function or returns a
function.

``` r
apply_operation <- function(x, operation) {
  stopifnot(is.function(operation))
  operation(x)
}

apply_operation(10, sqrt)
```

    ## [1] 3.162278

``` r
apply_operation(10, function(x) x + 5)
```

    ## [1] 15

This separates *what should happen* from *how the surrounding workflow
is organized*.

## 1.2 Functions as results

``` r
make_multiplier <- function(factor) {
  function(x) x * factor
}

times_three <- make_multiplier(3)
times_ten <- make_multiplier(10)

times_three(7)
```

    ## [1] 21

``` r
times_ten(7)
```

    ## [1] 70

The returned function retains access to `factor` even after
`make_multiplier()` finishes. This is a **closure**.

# 2. Lexical scoping: where R finds variables

R generally resolves a name by looking in the environment where a
function was **defined**, then in enclosing environments. This is called
*lexical scoping*.

``` r
rate <- 0.10
calculate_fee <- function(amount) amount * rate
calculate_fee(200)
```

    ## [1] 20

The function looks for `rate` in its enclosing environment. This can be
convenient, but hidden dependencies can also make code fragile.

## 2.1 Local variables override enclosing names

``` r
rate <- 0.10
calculate_fixed_fee <- function(amount) {
  rate <- 0.05
  amount * rate
}

calculate_fixed_fee(200)
```

    ## [1] 10

``` r
rate
```

    ## [1] 0.1

The local assignment does not replace the outer `rate`.

## 2.2 Safer alternative: explicit arguments

``` r
calculate_fee_explicit <- function(amount, rate) {
  amount * rate
}

calculate_fee_explicit(200, 0.10)
```

    ## [1] 20

``` r
calculate_fee_explicit(200, 0.05)
```

    ## [1] 10

For reusable research and business code, explicit inputs are often
easier to test than reliance on mutable global variables.

# 3. Understanding environments

An **environment** is a collection of name–object bindings with a parent
environment. Functions have an enclosing environment.

``` r
f <- function(x) x + 1
environment(f)
```

    ## <environment: R_GlobalEnv>

``` r
is.environment(environment(f))
```

    ## [1] TRUE

We can create a separate environment:

``` r
settings <- new.env(parent = emptyenv())
settings$currency <- "USD"
settings$precision <- 2L
settings$currency
```

    ## [1] "USD"

``` r
ls(settings)
```

    ## [1] "currency"  "precision"

`emptyenv()` has no ordinary function bindings, so an environment with
this parent is useful as a simple container, not as a normal function
evaluation environment.

## 3.1 Inspecting the current environment

``` r
inspect_environment <- function() {
  environment()
}

is.environment(inspect_environment())
```

    ## [1] TRUE

`environment(f)` describes a function’s enclosing environment;
`environment()` called inside a function refers to the current
evaluation environment. These are related but not identical concepts.

## 3.2 `local()` for isolated calculations

``` r
result <- local({
  temporary_value <- 12
  temporary_value * 3
})
result
```

    ## [1] 36

`local()` evaluates expressions in a new environment. It is useful for
keeping temporary names out of the surrounding workspace.

# 4. Closures in practice

A closure combines a function with the environment in which it was
created.

## 4.1 A configurable discount function

``` r
make_discount <- function(discount_rate) {
  stopifnot(is.numeric(discount_rate), length(discount_rate) == 1L,
            !is.na(discount_rate), discount_rate >= 0,
            discount_rate <= 1)

  function(price) {
    price * (1 - discount_rate)
  }
}

student_discount <- make_discount(0.15)
member_discount <- make_discount(0.05)
student_discount(c(100, 200))
```

    ## [1]  85 170

``` r
member_discount(c(100, 200))
```

    ## [1]  95 190

## 4.2 A counter with private state

Sometimes a closure intentionally remembers changes between calls.

``` r
make_counter <- function(start = 0L) {
  count <- as.integer(start)
  function() {
    count <<- count + 1L
    count
  }
}

counter <- make_counter()
counter()
```

    ## [1] 1

``` r
counter()
```

    ## [1] 2

``` r
counter()
```

    ## [1] 3

Here `<<-` updates the `count` binding in the enclosing function
environment. It should be used deliberately: hidden mutable state makes
functions harder to reason about and test. Ordinary data-processing
functions generally should avoid it.

## 4.3 Independent counters

``` r
first_counter <- make_counter()
second_counter <- make_counter(10L)
first_counter()
```

    ## [1] 1

``` r
second_counter()
```

    ## [1] 11

``` r
first_counter()
```

    ## [1] 2

Each counter retains its own environment and state.

# 5. Pure functions and side effects

A **pure function** produces an output determined by its explicit inputs
and does not modify external state.

``` r
add_tax <- function(price, tax_rate) {
  price * (1 + tax_rate)
}

add_tax(100, 0.18)
```

    ## [1] 118

``` r
add_tax(100, 0.18)
```

    ## [1] 118

Both calls return the same value. By contrast, writing a file, printing,
modifying a global variable, or reading the current clock is a **side
effect** or external dependency.

``` r
announce_total <- function(price, tax_rate) {
  total <- add_tax(price, tax_rate)
  message("Calculated total: ", total)
  total
}

announce_total(100, 0.18)
```

    ## Calculated total: 118

    ## [1] 118

A practical design is to keep calculation functions pure where possible
and perform file operations or user messages at clearly defined
boundaries.

# 6. Anonymous functions

An anonymous function has no permanent name. It is useful for a short
transformation needed in one place.

``` r
values <- list(a = 2:4, b = 5:7)
lapply(values, function(x) x * 2)
```

    ## $a
    ## [1] 4 6 8
    ## 
    ## $b
    ## [1] 10 12 14

Recent versions of R also support the shorthand `\(x) ...`. To keep this
chapter compatible with older installations, executable examples use
`function(x)`.

``` r
# R 4.1.0 or later:
# lapply(values, \(x) x * 2)
```

## 6.1 Named versus anonymous functions

``` r
triple <- function(x) 3 * x
lapply(values, triple)
```

    ## $a
    ## [1]  6  9 12
    ## 
    ## $b
    ## [1] 15 18 21

``` r
lapply(values, function(x) 3 * x)
```

    ## $a
    ## [1]  6  9 12
    ## 
    ## $b
    ## [1] 15 18 21

For complicated logic used repeatedly, a named function usually improves
readability and testing.

# 7. Revisiting the apply family with functions

We learned the mechanics of the apply family in Chapter 13. Here we
focus on composing transformations and controlling outputs.

``` r
orders <- list(
  online = c(100, 250, 150),
  store = c(80, 120),
  wholesale = c(500, 400, 600, 300)
)

lapply(orders, sum)
```

    ## $online
    ## [1] 500
    ## 
    ## $store
    ## [1] 200
    ## 
    ## $wholesale
    ## [1] 1800

``` r
vapply(orders, sum, numeric(1))
```

    ##    online     store wholesale 
    ##       500       200      1800

`lapply()` always returns a list. `vapply()` uses an explicit output
prototype (`numeric(1)`) and reports a problem if a function returns an
incompatible shape.

## 7.1 Why predictable output types matter

``` r
get_count <- function(x) length(x)
vapply(orders, get_count, integer(1))
```

    ##    online     store wholesale 
    ##         3         2         4

If we know that every result must be one integer, `vapply()` makes that
contract explicit.

## 7.2 Working with heterogeneous lists

``` r
records <- list(
  first = list(name = "Asha", score = 82),
  second = list(name = "Ravi", score = 91),
  third = list(name = "Mira", score = 76)
)

vapply(records, function(x) x$name, character(1))
```

    ##  first second  third 
    ## "Asha" "Ravi" "Mira"

``` r
vapply(records, function(x) x$score, numeric(1))
```

    ##  first second  third 
    ##     82     91     76

# 8. `Map()` and `mapply()`

`Map()` applies a function to corresponding elements of multiple inputs
and always returns a list.

``` r
prices <- c(100, 200, 300)
rates <- c(0.05, 0.10, 0.15)

Map(function(price, rate) price * (1 - rate), prices, rates)
```

    ## [[1]]
    ## [1] 95
    ## 
    ## [[2]]
    ## [1] 180
    ## 
    ## [[3]]
    ## [1] 255

`mapply()` uses similar iteration but may simplify its result:

``` r
mapply(function(price, rate) price * (1 - rate), prices, rates)
```

    ## [1]  95 180 255

## 8.1 Matching parallel lists

``` r
first_names <- c("Asha", "Ravi", "Mira")
last_names <- c("Shah", "Kumar", "Das")

mapply(paste, first_names, last_names, USE.NAMES = FALSE)
```

    ## [1] "Asha Shah"  "Ravi Kumar" "Mira Das"

Parallel inputs should be checked for compatible lengths. Silent
recycling can hide mistakes.

# 9. `Reduce()`: combining a sequence

`Reduce()` repeatedly combines elements using a two-argument function.

``` r
Reduce(`+`, c(2, 4, 6, 8))
```

    ## [1] 20

``` r
Reduce(function(a, b) paste(a, b, sep = "-"), c("A", "B", "C"))
```

    ## [1] "A-B-C"

We can provide an initial value:

``` r
Reduce(`+`, c(2, 4, 6), init = 10)
```

    ## [1] 22

## 9.1 Cumulative results

``` r
Reduce(`+`, c(2, 4, 6), accumulate = TRUE)
```

    ## [1]  2  6 12

For simple sums and products, `sum()` and `prod()` are usually clearer
and more efficient. `Reduce()` is useful when the combination rule is
custom.

## 9.2 Combining named configuration lists

``` r
config_parts <- list(
  list(theme = "light"),
  list(page_size = 20),
  list(language = "en")
)

combined_config <- Reduce(function(a, b) c(a, b), config_parts)
combined_config
```

    ## $theme
    ## [1] "light"
    ## 
    ## $page_size
    ## [1] 20
    ## 
    ## $language
    ## [1] "en"

This is a simple example. When names overlap, we should explicitly
decide which value should win rather than blindly concatenating.

# 10. `Filter()`, `Find()`, and `Position()`

These functions evaluate a predicate: a function that returns a single
`TRUE` or `FALSE` for each element.

``` r
items <- list(
  c(2, 3),
  integer(0),
  c(5, 7, 9),
  10L
)

Filter(function(x) length(x) >= 2L, items)
```

    ## [[1]]
    ## [1] 2 3
    ## 
    ## [[2]]
    ## [1] 5 7 9

``` r
Find(function(x) length(x) == 0L, items)
```

    ## integer(0)

``` r
Position(function(x) length(x) == 0L, items)
```

    ## [1] 2

`Filter()` retains all matching elements. `Find()` returns the first
matching element. `Position()` returns its position.

## 10.1 Filtering records

``` r
products <- list(
  list(name = "Notebook", stock = 15L),
  list(name = "Pen", stock = 0L),
  list(name = "Folder", stock = 8L)
)

in_stock <- Filter(function(x) x$stock > 0L, products)
vapply(in_stock, function(x) x$name, character(1))
```

    ## [1] "Notebook" "Folder"

For data frames, ordinary row filtering may be clearer. Functional
filtering is particularly useful for lists of objects.

# 11. `Negate()` and `isTRUE()`

`Negate()` creates the logical opposite of a predicate.

``` r
is_empty <- function(x) length(x) == 0L
is_not_empty <- Negate(is_empty)

vapply(items, is_not_empty, logical(1))
```

    ## [1]  TRUE FALSE  TRUE  TRUE

A predicate should return exactly one nonmissing logical value.
`isTRUE()` is useful when a condition may otherwise return `NA`.

``` r
is_positive_number <- function(x) {
  is.numeric(x) && length(x) == 1L &&
    !is.na(x) && is.finite(x) && x > 0
}

vapply(list(3, -2, NA_real_, "text"),
       is_positive_number, logical(1))
```

    ## [1]  TRUE FALSE FALSE FALSE

# 12. `...`: forwarding arguments

The `...` parameter accepts additional arguments. A wrapper can forward
them to another function.

``` r
calculate_average <- function(x, ...) {
  mean(x, ...)
}

calculate_average(c(10, NA, 20), na.rm = TRUE)
```

    ## [1] 15

This makes wrappers flexible, but can also hide spelling errors or
obscure which arguments are supported.

## 12.1 A wrapper with an explicit argument

``` r
calculate_average_safe <- function(x, na.rm = FALSE) {
  mean(x, na.rm = na.rm)
}

calculate_average_safe(c(10, NA, 20), na.rm = TRUE)
```

    ## [1] 15

Prefer explicit parameters when the supported interface is small and
stable.

# 13. `do.call()`: calling with a list of arguments

`do.call()` constructs a function call from an argument list.

``` r
arguments <- list(x = c(2, 4, 6), na.rm = TRUE)
do.call(mean, arguments)
```

    ## [1] 4

It is especially useful when arguments are assembled programmatically.

``` r
text_parts <- list("R", "for", "Everyone", sep = " ")
do.call(paste, text_parts)
```

    ## [1] "R for Everyone"

Only pass trusted, validated functions and arguments when constructing
dynamic calls from external input.

# 14. Function composition

Function composition connects the output of one function to the input of
another.

``` r
trim_and_lower <- function(x) tolower(trimws(x))

trim_and_lower(c("  APPLE ", " Banana  "))
```

    ## [1] "apple"  "banana"

We can write a simple composition helper:

``` r
compose_two <- function(f, g) {
  stopifnot(is.function(f), is.function(g))
  function(x) f(g(x))
}

clean_text <- compose_two(tolower, trimws)
clean_text(c("  RED ", " BLUE "))
```

    ## [1] "red"  "blue"

The order matters: `compose_two(f, g)` applies `g` first, then `f`.

## 14.1 A pipeline of several functions

``` r
run_pipeline <- function(x, steps) {
  stopifnot(is.list(steps), all(vapply(steps, is.function, logical(1))))
  Reduce(function(value, step) step(value), steps, init = x)
}

pipeline_steps <- list(
  trimws,
  tolower,
  function(x) gsub(" +", "_", x)
)

run_pipeline(c("  Red Apple  ", " Green Pear "), pipeline_steps)
```

    ## [1] "red_apple"  "green_pear"

This pattern works when each function’s output is a suitable input for
the next function.

# 15. Pipes and readable workflows

R 4.1.0 introduced the base pipe `|>`. It passes the value on its left
to a function call on its right.

``` r
# R 4.1.0 or later:
# c("  Red ", " Blue  ") |>
#   trimws() |>
#   tolower()
```

For maximum compatibility, our executable examples use nested calls or
named intermediate objects.

``` r
raw_labels <- c("  Red ", " Blue  ")
trimmed_labels <- trimws(raw_labels)
cleaned_labels <- tolower(trimmed_labels)
cleaned_labels
```

    ## [1] "red"  "blue"

A pipe does not automatically make code better. We should choose the
style that most clearly communicates the transformation.

# 16. A function factory for validation

Function factories are useful when we repeatedly apply the same rule
with different parameters.

``` r
make_range_checker <- function(min_value, max_value) {
  stopifnot(is.numeric(min_value), is.numeric(max_value),
            length(min_value) == 1L, length(max_value) == 1L,
            is.finite(min_value), is.finite(max_value),
            min_value <= max_value)

  function(x) {
    is.numeric(x) & !is.na(x) &
      x >= min_value & x <= max_value
  }
}

check_score <- make_range_checker(0, 100)
check_percentage <- make_range_checker(0, 100)
check_score(c(90, 105, NA, -3))
```

    ## [1]  TRUE FALSE FALSE FALSE

The function returns a logical vector, retaining missing-input
information as `FALSE` through the explicit `!is.na(x)` condition.

## 16.1 Validation of inputs and outputs

``` r
check_score(c(0, 50, 100))
```

    ## [1] TRUE TRUE TRUE

``` r
stopifnot(identical(check_score(c(0, 50, 100)),
                    c(TRUE, TRUE, TRUE)))
```

# 17. Defensive functional programming

Reusable functions should make their assumptions explicit.

``` r
safe_divide <- function(numerator, denominator) {
  if (!is.numeric(numerator) || !is.numeric(denominator)) {
    stop("Both inputs must be numeric.")
  }
  if (length(denominator) != 1L || is.na(denominator) ||
      !is.finite(denominator) || denominator == 0) {
    stop("denominator must be one finite, nonzero number.")
  }
  numerator / denominator
}

safe_divide(c(10, 20), 2)
```

    ## [1]  5 10

## 17.1 Catching an expected error

``` r
result <- tryCatch(
  safe_divide(10, 0),
  error = function(e) paste("Handled:", conditionMessage(e))
)
result
```

    ## [1] "Handled: denominator must be one finite, nonzero number."

`tryCatch()` is appropriate when failure is expected and we have a
meaningful recovery action. It should not be used to silently ignore
errors.

# 18. Mapping with failure isolation

Suppose one input is invalid but we still want to inspect results for
the remaining inputs.

``` r
inputs <- list(2, 4, "invalid", 8)

safe_square <- function(x) {
  tryCatch(
    list(ok = TRUE, value = {
      if (!is.numeric(x)) stop("numeric input required")
      x^2
    }),
    error = function(e) list(ok = FALSE, error = conditionMessage(e))
  )
}

mapped_results <- lapply(inputs, safe_square)
mapped_results
```

    ## [[1]]
    ## [[1]]$ok
    ## [1] TRUE
    ## 
    ## [[1]]$value
    ## [1] 4
    ## 
    ## 
    ## [[2]]
    ## [[2]]$ok
    ## [1] TRUE
    ## 
    ## [[2]]$value
    ## [1] 16
    ## 
    ## 
    ## [[3]]
    ## [[3]]$ok
    ## [1] FALSE
    ## 
    ## [[3]]$error
    ## [1] "numeric input required"
    ## 
    ## 
    ## [[4]]
    ## [[4]]$ok
    ## [1] TRUE
    ## 
    ## [[4]]$value
    ## [1] 64

``` r
vapply(mapped_results, function(x) x$ok, logical(1))
```

    ## [1]  TRUE  TRUE FALSE  TRUE

The result is a list of structured success or failure records, rather
than a collection of unlabelled missing values.

# 19. Optional introduction to purrr

The `purrr` package is part of the tidyverse and provides a consistent
set of tools for functional iteration. It is **optional** in this
chapter.

``` r
if (requireNamespace("purrr", quietly = TRUE)) {
  print(purrr::map(orders, sum))
  print(purrr::map_dbl(orders, sum))
} else {
  message("Optional purrr examples skipped: package not installed.")
}
```

    ## $online
    ## [1] 500
    ## 
    ## $store
    ## [1] 200
    ## 
    ## $wholesale
    ## [1] 1800
    ## 
    ##    online     store wholesale 
    ##       500       200      1800

`purrr::map()` returns a list, much like `lapply()`. `purrr::map_dbl()`
requests a numeric vector, conceptually similar to
`vapply(..., numeric(1))`.

## 19.1 Mapping over multiple inputs

``` r
if (requireNamespace("purrr", quietly = TRUE)) {
  print(purrr::map2_dbl(prices, rates,
                        function(price, rate) price * (1 - rate)))
} else {
  message("Optional purrr example skipped.")
}
```

    ## [1]  95 180 255

## 19.2 Functional predicates

``` r
if (requireNamespace("purrr", quietly = TRUE)) {
  print(purrr::keep(c(-3, 2, 0, 5), function(x) x > 0))
  print(purrr::some(c(-3, 2, 0, 5), function(x) x > 4))
} else {
  message("Optional purrr example skipped.")
}
```

    ## [1] 2 5
    ## [1] TRUE

We will study `purrr` more thoroughly when we introduce the tidyverse
ecosystem in a later chapter.

# 20. When a loop is better

Functional programming is a technique, not a rule that all loops must
disappear.

A loop is often clearer when we need:

- several state updates per iteration;
- early termination with `break`;
- extensive logging;
- complex error recovery;
- sequential processing with dependencies between steps.

``` r
values <- c(3, 7, 12, 5)
first_over_ten <- NA_real_

for (value in values) {
  if (value > 10) {
    first_over_ten <- value
    break
  }
}

first_over_ten
```

    ## [1] 12

We can also use a functional helper:

``` r
Find(function(x) x > 10, as.list(values))
```

    ## [1] 12

The better approach depends on readability and requirements.

# 21. Complete practical project: an order-processing toolkit

We will build a small toolkit that validates order records, applies
configurable discounts, and produces consistent summaries.

## Step 1: create synthetic orders

``` r
order_data <- data.frame(
  order_id = c("O001", "O002", "O003", "O004", "O005"),
  category = c("book", "pen", "book", "folder", "pen"),
  quantity = c(2L, 5L, 1L, 3L, 4L),
  unit_price = c(250, 20, 300, 80, 25),
  stringsAsFactors = FALSE
)
order_data
```

    ##   order_id category quantity unit_price
    ## 1     O001     book        2        250
    ## 2     O002      pen        5         20
    ## 3     O003     book        1        300
    ## 4     O004   folder        3         80
    ## 5     O005      pen        4         25

## Step 2: validate the table

``` r
validate_orders <- function(dat) {
  required <- c("order_id", "category", "quantity", "unit_price")
  if (!is.data.frame(dat)) stop("Input must be a data frame.")
  missing <- setdiff(required, names(dat))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
  if (anyNA(dat[required])) stop("Required columns contain missing values.")
  if (!is.numeric(dat$quantity) || !is.numeric(dat$unit_price)) {
    stop("quantity and unit_price must be numeric.")
  }
  if (any(!is.finite(dat$quantity)) || any(!is.finite(dat$unit_price)) ||
      any(dat$quantity < 0) || any(dat$unit_price < 0)) {
    stop("Quantities and prices must be finite and nonnegative.")
  }
  if (any(dat$quantity != floor(dat$quantity))) {
    stop("Quantities must be whole numbers.")
  }
  if (anyDuplicated(dat$order_id)) stop("Order IDs must be unique.")
  dat
}

order_data <- validate_orders(order_data)
```

## Step 3: create a configurable price calculator

``` r
make_price_calculator <- function(discount_rate = 0, tax_rate = 0) {
  stopifnot(is.numeric(discount_rate), length(discount_rate) == 1L,
            is.finite(discount_rate), discount_rate >= 0,
            discount_rate <= 1,
            is.numeric(tax_rate), length(tax_rate) == 1L,
            is.finite(tax_rate), tax_rate >= 0)

  function(quantity, unit_price) {
    quantity * unit_price * (1 - discount_rate) * (1 + tax_rate)
  }
}

calculate_total <- make_price_calculator(discount_rate = 0.10,
                                         tax_rate = 0.05)
order_data$total <- calculate_total(order_data$quantity,
                                     order_data$unit_price)
order_data
```

    ##   order_id category quantity unit_price total
    ## 1     O001     book        2        250 472.5
    ## 2     O002      pen        5         20  94.5
    ## 3     O003     book        1        300 283.5
    ## 4     O004   folder        3         80 226.8
    ## 5     O005      pen        4         25  94.5

## Step 4: create reusable summary functions

``` r
summary_functions <- list(
  n_orders = function(x) nrow(x),
  total_units = function(x) sum(x$quantity),
  total_revenue = function(x) sum(x$total),
  average_order = function(x) mean(x$total)
)

order_summary <- vapply(summary_functions,
                        function(f) as.numeric(f(order_data)), numeric(1))
order_summary
```

    ##      n_orders   total_units total_revenue average_order 
    ##          5.00         15.00       1171.80        234.36

## Step 5: produce category summaries

``` r
orders_by_category <- split(order_data, order_data$category)
category_revenue <- vapply(orders_by_category,
                           function(x) sum(x$total), numeric(1))
category_revenue
```

    ##   book folder    pen 
    ##  756.0  226.8  189.0

## Step 6: verify invariants

``` r
stopifnot(
  nrow(order_data) == 5L,
  all(order_data$total >= 0),
  isTRUE(all.equal(sum(category_revenue), sum(order_data$total))),
  isTRUE(all.equal(unname(order_summary["total_revenue"]),
                   sum(order_data$total)))
)
```

The practical demonstrates function factories, closures, higher-order
functions, list-based function registries, grouping, and validation in
one workflow.

# 22. Common mistakes and debugging

## Mistake 1: calling a function too early

``` r
# Incorrect when a function object is required:
# lapply(list(1:3, 4:6), sum())

# Correct:
# lapply(list(1:3, 4:6), sum)
```

`sum()` executes immediately, whereas `sum` refers to the function.

## Mistake 2: assuming `sapply()` always returns a vector

`sapply()` may return a vector, matrix, or list depending on the
results. Use `vapply()` when the expected type and length are known.

## Mistake 3: forgetting that closures retain environments

A closure can keep references to large objects or mutable state. Avoid
capturing unnecessary data and document intentional state.

## Mistake 4: overusing `<<-`

Superassignment can make code behavior depend on earlier calls. Prefer
explicit inputs and returned outputs unless persistent state is
genuinely required.

## Mistake 5: using `...` without understanding forwarded arguments

Arguments passed through `...` may be ignored, rejected, or interpreted
differently by downstream functions. Keep wrappers simple and document
supported arguments.

## Mistake 6: hiding errors

Returning `NA` for every failure can conceal serious data problems.
Prefer structured error messages and distinguish missing data from
invalid inputs.

# 23. Independent exercises: beginner

1.  Assign the built-in function `sqrt` to a new name and call it.
2.  Create a list containing three functions: double, square, and
    negate.
3.  Use `vapply()` to apply each function to the number 4.
4.  Write `apply_operation()` so it accepts a value and a function.
5.  Write a function factory that adds a fixed amount to its input.
6.  Create two independent functions from that factory.
7.  Explain why a closure remembers its configuration.
8.  Compare `lapply()` and `vapply()` on a list of numeric vectors.
9.  Use `Map()` to combine first and last names.
10. Use `Reduce()` to multiply a vector of numbers.

# 24. Independent exercises: intermediate

1.  Create a range-checking function factory for exam scores.
2.  Write a function that composes two functions.
3.  Build a pipeline that trims whitespace, converts to lowercase, and
    replaces spaces with underscores.
4.  Use `Filter()` to keep nonempty character vectors.
5.  Use `Find()` to locate the first list element with at least five
    values.
6.  Use `Position()` to report the index of the first matching element.
7.  Write a function with `...` that forwards options to `paste()`.
8.  Call `paste()` using `do.call()` and an argument list.
9.  Write a safe division function and handle division-by-zero with
    `tryCatch()`.
10. Explain why an explicit `for` loop may be clearer than nested
    higher-order functions.

# 25. Independent exercises: advanced

1.  Create a closure-based counter with a `reset` option.
2.  Explain how environments differ from ordinary lists.
3.  Write a function registry that stores named transformations.
4.  Build a reusable pipeline runner using `Reduce()`.
5.  Add input validation to the pipeline runner.
6.  Write a function that returns structured success/failure results for
    a list of inputs.
7.  Compare base `lapply()` and optional `purrr::map()`.
8.  Explain the differences between a pure function and a stateful
    closure.
9.  Design a function factory that generates configurable text
    validators.
10. Refactor a multi-step loop into named functions, without sacrificing
    clarity.

# 26. Challenge project: a configurable text-processing pipeline

Build a reusable toolkit that accepts a character vector and a list of
transformations. The toolkit should:

1.  Validate that the input is character.
2.  Preserve or explicitly handle missing values.
3.  Trim surrounding whitespace.
4.  Standardize letter case.
5.  Optionally replace internal spaces with underscores.
6.  Allow a user-defined transformation function.
7.  Return both the original and cleaned text.
8.  Record which transformation steps were applied.
9.  Test empty vectors, missing strings, and unusual punctuation.
10. Demonstrate both an explicit loop and a functional solution.

# 27. Standalone practice script

The following script is independent of the chapter’s earlier objects. It
can be copied into a new R script and run without installing any
packages.

``` r
# R for Everyone — Chapter 21 standalone practice

make_transformer <- function(prefix = "", uppercase = FALSE) {
  function(x) {
    stopifnot(is.character(x))
    result <- trimws(x)
    if (uppercase) result <- toupper(result)
    paste0(prefix, result)
  }
}

clean_id <- make_transformer(prefix = "ID-", uppercase = TRUE)
ids <- c("  a01 ", "b02", " c03")
cleaned <- clean_id(ids)
print(cleaned)

functions <- list(
  count = length,
  first = function(x) x[1],
  last = function(x) x[length(x)]
)

results <- lapply(functions, function(f) f(cleaned))
print(results)

validate_id <- function(x) {
  is.character(x) & !is.na(x) & grepl("^ID-[A-Z][0-9]{2}$", x)
}

stopifnot(all(validate_id(cleaned)))

run_pipeline <- function(x, steps) {
  stopifnot(is.list(steps), all(vapply(steps, is.function, logical(1))))
  Reduce(function(value, step) step(value), steps, init = x)
}

result <- run_pipeline(
  c("  Red Apple ", " Green Pear "),
  list(trimws, tolower, function(x) gsub(" +", "_", x))
)
print(result)
```

# 28. Review questions

1.  What does it mean that functions are first-class objects in R?
2.  What is a higher-order function?
3.  How does lexical scoping work?
4.  What is the enclosing environment of a function?
5.  What is a closure?
6.  Why can a closure retain state between calls?
7.  What is the role of `<<-` in a stateful closure?
8.  Why are pure functions often easier to test?
9.  What is an anonymous function?
10. When should we use `vapply()` instead of `sapply()`?
11. How do `Map()` and `mapply()` differ in their outputs?
12. What does `Reduce()` do?
13. How do `Filter()`, `Find()`, and `Position()` differ?
14. What does `Negate()` return?
15. How can `...` forward arguments?
16. What does `do.call()` accomplish?
17. What is function composition?
18. What is a function factory?
19. Why might a pipeline be preferable to a deeply nested expression?
20. When is a conventional loop clearer?
21. How does `purrr::map_dbl()` relate to `vapply()`?
22. Why should a reusable function validate its inputs?
23. What is a structured error result?
24. What are the risks of hidden global variables?
25. How can we test the invariants of a processing pipeline?

# 29. Key takeaways

- In R, functions are objects that can be stored, passed, and returned.
- Higher-order functions allow us to separate reusable workflow
  structure from specific operations.
- Lexical scoping explains how functions find variables outside their
  local body.
- Closures retain access to their defining environments and can hold
  configuration or state.
- Pure functions with explicit inputs are usually easier to test and
  reuse.
- `vapply()` gives predictable result types; `Map()` handles parallel
  inputs; `Reduce()` combines a sequence.
- `Filter()`, `Find()`, and `Position()` provide concise predicate-based
  list operations.
- `...` and `do.call()` support flexible argument handling but require
  care.
- Function composition helps build clear transformation pipelines.
- Functional programming complements loops; it does not replace them in
  every situation.
- The optional `purrr` package provides a consistent
  functional-programming interface that we will revisit in later
  tidyverse chapters.

# 30. Next chapter

**Chapter 22 — Introduction to the Tidyverse and Tibbles** will
introduce the tidyverse ecosystem, package installation and loading,
tibbles, pipes, and the relationship between base R and tidyverse
workflows. Our foundation in higher-order functions will make the later
`purrr` chapter easier to understand.
