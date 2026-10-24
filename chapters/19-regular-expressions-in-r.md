Regular Expressions
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In previous chapter, we worked with character strings: combining,
splitting, trimming, extracting, and replacing text. In this chapter, we
learn **regular expressions**, commonly called **regex**. A regular
expression is a compact description of a text pattern. Instead of
looking for one fixed word, we can find strings that follow a rule: a
product code beginning with two letters, a number containing four
digits, or a line ending in `.csv`.

Regular expressions are useful for file management, data cleaning, log
inspection, customer records, product catalogues, and text processing.
Our goal is not to memorize every symbol. We will learn to read patterns
carefully, test them against representative examples, and avoid matching
text that should not match.

**Chapter scope:** R programming and text manipulation. No statistical
methods are required. All core examples use base R; optional `stringr`
examples run only when that package is installed.

## Learning objectives

By the end of the chapter, we should be able to:

1.  Explain literal matching and regular-expression matching.
2.  Use `grepl()`, `grep()`, `regexpr()`, `gregexpr()`, `regmatches()`,
    `sub()`, and `gsub()`.
3.  Use character classes, ranges, anchors, quantifiers, grouping, and
    alternation.
4.  Distinguish regex syntax from R string escaping.
5.  Apply capture groups and backreferences.
6.  Use `perl = TRUE` for selected advanced constructs.
7.  Use `stringr` as an optional alternative.
8.  Build and test safe, readable regex-based cleaning functions.

# 19.1 What is a regular expression?

A **literal** search looks for exactly the characters supplied. A
**regex** search describes a pattern.

For example, the literal `"cat"` searches for those three letters, while
the regex `"c.t"` matches a `c`, followed by any one character, followed
by a `t`. This can match `cat`, `cot`, or `cut`.

``` r
words <- c("cat", "cot", "cut", "coat", "dog")
grepl("c.t", words)
```

    ## [1]  TRUE  TRUE  TRUE FALSE FALSE

The result is a logical vector. Each position answers whether the
corresponding input contains a match.

``` r
words[grepl("c.t", words)]
```

    ## [1] "cat" "cot" "cut"

Notice that `"coat"` does not match `"c.t"`: between `c` and `t`, it has
two characters. We can design a different pattern if we want to match
it.

## 19.1.1 Regex matching is often substring matching

``` r
grepl("cat", c("cat", "cats", "bobcat", "dog"))
```

    ## [1]  TRUE  TRUE  TRUE FALSE

A match does not automatically mean the **whole** string matches. We
will use anchors when whole-string matching matters.

# 19.2 Our practice data

We will reuse small, synthetic text vectors throughout the chapter.

``` r
product_codes <- c("AB-1234", "XY-0087", "A-1234", "CD-123", "EF-9876", NA)
file_names <- c("sales.csv", "notes.txt", "archive.csv.gz", "REPORT.CSV", "data.tsv", "backup.csv")
messages <- c("Order 102 received", "Order 7 delayed", "No order", "Order 204 shipped")

product_codes
```

    ## [1] "AB-1234" "XY-0087" "A-1234"  "CD-123"  "EF-9876" NA

``` r
file_names
```

    ## [1] "sales.csv"      "notes.txt"      "archive.csv.gz" "REPORT.CSV"    
    ## [5] "data.tsv"       "backup.csv"

``` r
messages
```

    ## [1] "Order 102 received" "Order 7 delayed"    "No order"          
    ## [4] "Order 204 shipped"

These examples are intentionally small so we can see exactly which
strings match and why.

# 19.3 `grepl()` and `grep()`

## 19.3.1 `grepl()` returns logical values

``` r
grepl("csv", file_names)
```

    ## [1]  TRUE FALSE  TRUE FALSE FALSE  TRUE

The output is a logical vector aligned with `file_names`.

## 19.3.2 `grep()` returns positions by default

``` r
grep("csv", file_names)
```

    ## [1] 1 3 6

To return matching values, use `value = TRUE`:

``` r
grep("csv", file_names, value = TRUE)
```

    ## [1] "sales.csv"      "archive.csv.gz" "backup.csv"

## 19.3.3 Case-insensitive matching

``` r
grep("csv", file_names, value = TRUE, ignore.case = TRUE)
```

    ## [1] "sales.csv"      "archive.csv.gz" "REPORT.CSV"     "backup.csv"

This finds uppercase `.CSV` as well as lowercase `.csv`. However, the
simple pattern also matches `.csv.gz`. Later we will learn how to match
a filename extension precisely.

## 19.3.4 Exact fixed-text matching

If we are searching for a literal sequence rather than a regex,
`fixed = TRUE` is often clearer.

``` r
grepl("a.b", c("a.b", "acb", "ab"), fixed = TRUE)
```

    ## [1]  TRUE FALSE FALSE

``` r
grepl("a.b", c("a.b", "acb", "ab"))
```

    ## [1]  TRUE  TRUE FALSE

The first searches for a literal dot. The second treats `.` as a regex
metacharacter.

# 19.4 The dot: `.`

In regex, a dot usually matches one character other than a newline
(details can vary by engine and mode).

``` r
grepl("b.t", c("bat", "bet", "bit", "boat", "bt"))
```

    ## [1]  TRUE  TRUE  TRUE FALSE FALSE

A dot is **not** a literal period unless we escape it or use
`fixed = TRUE`.

## Matching a literal period

There are two levels of interpretation:

1.  Regex requires `\.` to mean a literal period.
2.  An ordinary R string requires `\\` to represent one backslash.

Therefore, the R source code contains `"\\."`.

``` r
grepl("\\.csv$", file_names)
```

    ## [1]  TRUE FALSE FALSE FALSE FALSE  TRUE

We will return to escaping because it is one of the most common sources
of regex errors.

# 19.5 Anchors: `^` and `$`

`^` matches the beginning of a string; `$` matches the end.

``` r
items <- c("cat", "cats", "bobcat", "concatenate", "dog")

grepl("^cat", items)
```

    ## [1]  TRUE  TRUE FALSE FALSE FALSE

``` r
grepl("cat$", items)
```

    ## [1]  TRUE FALSE  TRUE FALSE FALSE

``` r
grepl("^cat$", items)
```

    ## [1]  TRUE FALSE FALSE FALSE FALSE

The pattern `^cat$` matches the entire string `cat` and excludes longer
strings containing it.

## Practical example: CSV extensions

``` r
file_names[grepl("\\.csv$", file_names, ignore.case = TRUE)]
```

    ## [1] "sales.csv"  "REPORT.CSV" "backup.csv"

The `.csv.gz` file is intentionally excluded because its name ends in
`.gz`, not `.csv`.

## Start and end anchors for product codes

``` r
grepl("^[A-Z][A-Z]-[0-9][0-9][0-9][0-9]$", product_codes)
```

    ## [1]  TRUE  TRUE FALSE FALSE  TRUE FALSE

We will shorten this pattern using quantifiers.

# 19.6 Character classes: `[ ]`

Character classes match **one character** from a defined set.

| Pattern    | Meaning                    | Example     |
|------------|----------------------------|-------------|
| `[abc]`    | `a`, `b`, or `c`           | Matches `b` |
| `[0-9]`    | One digit                  | Matches `7` |
| `[A-Z]`    | One uppercase ASCII letter | Matches `Q` |
| `[a-z]`    | One lowercase ASCII letter | Matches `m` |
| `[A-Za-z]` | One ASCII letter           | Matches `G` |
| `[^0-9]`   | One non-digit              | Matches `-` |

``` r
values <- c("A7", "b3", "ZZ", "42", "A-7")
grepl("[0-9]", values)
```

    ## [1]  TRUE  TRUE FALSE  TRUE  TRUE

``` r
grepl("^[A-Z]", values)
```

    ## [1]  TRUE FALSE  TRUE FALSE  TRUE

``` r
grepl("^[^0-9]", values)
```

    ## [1]  TRUE  TRUE  TRUE FALSE  TRUE

## Negated character classes

Inside square brackets, `^` at the beginning negates the class:

``` r
grepl("[^0-9]", c("123", "12A", "", "4-5"))
```

    ## [1] FALSE  TRUE FALSE  TRUE

This means *contains at least one non-digit*. It does not mean *is a
valid number*.

## POSIX character classes

Base R supports POSIX character classes such as `[[:digit:]]`,
`[[:alpha:]]`, and `[[:space:]]`.

``` r
strings <- c("ABC", "A12", "hello world", "")
grepl("[[:digit:]]", strings)
```

    ## [1] FALSE  TRUE FALSE FALSE

``` r
grepl("[[:space:]]", strings)
```

    ## [1] FALSE FALSE  TRUE FALSE

The exact interpretation of alphabetic characters may depend on locale
and regex engine. For explicitly ASCII identifiers, `[A-Za-z]` is often
more predictable.

# 19.7 Quantifiers: how many repetitions?

A quantifier controls how many times the preceding element may occur.

| Quantifier | Meaning             |
|------------|---------------------|
| `*`        | Zero or more        |
| `+`        | One or more         |
| `?`        | Zero or one         |
| `{n}`      | Exactly `n`         |
| `{n,}`     | At least `n`        |
| `{n,m}`    | Between `n` and `m` |

## `+`: one or more digits

``` r
texts <- c("123", "7", "", "12a", "a12")
grepl("^[0-9]+$", texts)
```

    ## [1]  TRUE  TRUE FALSE FALSE FALSE

## `*`: zero or more

``` r
grepl("^ab*c$", c("ac", "abc", "abbc", "ab", "abbbc"))
```

    ## [1]  TRUE  TRUE  TRUE FALSE  TRUE

The `b` is optional and can repeat.

## `?`: optional element

``` r
grepl("^colou?r$", c("color", "colour", "colouur", "colors"))
```

    ## [1]  TRUE  TRUE FALSE FALSE

## Curly braces for exact lengths

``` r
grepl("^[0-9]{4}$", c("1234", "0123", "123", "12345", "12A4"))
```

    ## [1]  TRUE  TRUE FALSE FALSE FALSE

## Product code validation

``` r
valid_product_code <- grepl("^[A-Z]{2}-[0-9]{4}$", product_codes)
valid_product_code
```

    ## [1]  TRUE  TRUE FALSE FALSE  TRUE FALSE

``` r
product_codes[!is.na(valid_product_code) & valid_product_code]
```

    ## [1] "AB-1234" "XY-0087" "EF-9876"

The rule requires exactly two uppercase ASCII letters, a hyphen, and
exactly four digits. It checks **format**, not whether a code actually
exists in a catalogue.

# 19.8 Alternation: `|`

Alternation means **OR** between regex alternatives.

``` r
colors <- c("red", "blue", "green", "yellow", "dark red")
grepl("red|blue", colors)
```

    ## [1]  TRUE  TRUE FALSE FALSE  TRUE

For exact values, add anchors and group the alternatives:

``` r
grepl("^(red|blue)$", colors)
```

    ## [1]  TRUE  TRUE FALSE FALSE FALSE

Without the anchors, `dark red` also matches.

# 19.9 Grouping with parentheses

Parentheses group parts of a pattern so quantifiers and alternation
apply to the group.

``` r
grepl("^(ha)+$", c("ha", "haha", "hahaha", "h", "hah"))
```

    ## [1]  TRUE  TRUE  TRUE FALSE FALSE

Here `(ha)+` means one or more repetitions of the sequence `ha`.

## Grouping changes the meaning of alternation

``` r
examples <- c("cat", "dog", "catalog", "hotdog", "bird")
grepl("^(cat|dog)$", examples)
```

    ## [1]  TRUE  TRUE FALSE FALSE FALSE

We are asking whether the entire value is either `cat` or `dog`.

# 19.10 Escaping: R strings versus regex patterns

This distinction is essential.

In an ordinary R string:

- `"\\n"` represents a newline character.
- `"\\t"` represents a tab character.
- `"\\\\"` represents a literal backslash.

In regex:

- `.` means any character.
- `\.` means a literal dot.
- `\d` means a digit in a Perl-compatible pattern.

To express regex `\d` in an ordinary R string, we write `"\\d"`.

``` r
pattern <- "\\d+"
grepl(pattern, c("abc", "A123", "42"), perl = TRUE)
```

    ## [1] FALSE  TRUE  TRUE

### Raw strings in modern R

R 4.0.0 and later support raw string literals, which can reduce
escaping:

``` r
# R 4.0.0+
pattern <- r"(\d+)"
grepl(pattern, c("abc", "A123"), perl = TRUE)
```

We keep the ordinary escaped-string syntax in most chapter examples for
consistency across environments.

# 19.11 Whitespace and trimming

Text may contain spaces, tabs, and line breaks.

``` r
raw_labels <- c("  apple ", "banana", "   green   tea   ")
trimws(raw_labels)
```

    ## [1] "apple"       "banana"      "green   tea"

To replace one or more whitespace characters with one ordinary space:

``` r
gsub("[[:space:]]+", " ", trimws(raw_labels))
```

    ## [1] "apple"     "banana"    "green tea"

This operation is useful for cleaning display labels. It may be
inappropriate for text where original spacing is meaningful, such as
source code or fixed-width data.

# 19.12 Replacing text: `sub()` versus `gsub()`

`sub()` replaces only the **first match in each string**. `gsub()`
replaces **all matches**.

``` r
text <- "apple apple apple"
sub("apple", "orange", text)
```

    ## [1] "orange apple apple"

``` r
gsub("apple", "orange", text)
```

    ## [1] "orange orange orange"

## Remove unwanted characters

``` r
phone_like <- c("(123) 456-7890", "123.456.7890", "+1 123 456 7890")
gsub("[^0-9]", "", phone_like)
```

    ## [1] "1234567890"  "1234567890"  "11234567890"

This extracts digits; it does **not** validate phone-number length,
country code, or whether the number is real.

## Standardize separators

``` r
codes <- c("AB 1234", "AB_1234", "AB-1234")
gsub("[ _]", "-", codes)
```

    ## [1] "AB-1234" "AB-1234" "AB-1234"

# 19.13 Extracting matches with `regexpr()` and `regmatches()`

`regexpr()` finds the first match position and length. `regmatches()`
extracts the matched text.

``` r
order_text <- c("Order 102 received", "Order 7 delayed", "No order")
match_info <- regexpr("[0-9]+", order_text)
match_info
```

    ## [1]  7  7 -1
    ## attr(,"match.length")
    ## [1]  3  1 -1
    ## attr(,"index.type")
    ## [1] "chars"
    ## attr(,"useBytes")
    ## [1] TRUE

``` r
regmatches(order_text, match_info)
```

    ## [1] "102" "7"

When no match is found, the extraction can omit that element; therefore,
a separate helper is useful when we need one output per input value.

For a convenient length-preserving extractor, we can write a helper:

``` r
extract_first <- function(x, pattern, perl = FALSE) {
  stopifnot(is.character(x), is.character(pattern), length(pattern) == 1L)
  out <- rep(NA_character_, length(x))
  present <- !is.na(x)
  if (!any(present)) return(out)
  positions <- regexpr(pattern, x[present], perl = perl)
  found <- positions > 0L
  extracted <- rep(NA_character_, sum(present))
  if (any(found)) {
    extracted[found] <- substring(
      x[present][found],
      positions[found],
      positions[found] + attr(positions, "match.length")[found] - 1L
    )
  }
  out[present] <- extracted
  out
}

extract_first(order_text, "[0-9]+")
```

    ## [1] "102" "7"   NA

We will also examine an alternative implementation using a
replacement-based extraction strategy later in the chapter.

# 19.14 Extracting all matches with `gregexpr()`

`gregexpr()` identifies all occurrences of a pattern within each input
string.

``` r
text_with_numbers <- c("A12 B34 C56", "X7", "none")
all_positions <- gregexpr("[0-9]+", text_with_numbers)
all_matches <- regmatches(text_with_numbers, all_positions)
all_matches
```

    ## [[1]]
    ## [1] "12" "34" "56"
    ## 
    ## [[2]]
    ## [1] "7"
    ## 
    ## [[3]]
    ## character(0)

The result is a list because each input string can contain a different
number of matches.

``` r
vapply(all_matches, length, integer(1))
```

    ## [1] 3 1 0

This is a natural connection to Chapters 12 and 13 on functions and the
apply family.

# 19.15 Capturing groups and backreferences

A **capturing group** stores the part of a match corresponding to
parentheses.

Suppose a product code contains two letters followed by four digits:

``` r
codes <- c("AB-1234", "XY-0087", "invalid")
```

We can rearrange the first two components using capture-group
backreferences in `sub()`:

``` r
sub("^([A-Z]{2})-([0-9]{4})$", "\\2/\\1", codes)
```

    ## [1] "1234/AB" "0087/XY" "invalid"

The replacement `"\\2/\\1"` means: second captured group, slash, first
captured group.

**Important:** When there is no match, `sub()` returns the original
string unchanged. Therefore, we should validate matches before treating
the transformed output as standardized data.

## A safe transformation

``` r
pattern <- "^([A-Z]{2})-([0-9]{4})$"
valid <- grepl(pattern, codes)
transformed <- rep(NA_character_, length(codes))
transformed[valid] <- sub(pattern, "\\2/\\1", codes[valid])
transformed
```

    ## [1] "1234/AB" "0087/XY" NA

# 19.16 Greedy and lazy matching

Quantifiers are usually **greedy**: they try to match as much as
possible while allowing the pattern to succeed.

``` r
html_like <- "<b>bold</b><i>italic</i>"
regmatches(html_like, regexpr("<.*>", html_like))
```

    ## [1] "<b>bold</b><i>italic</i>"

The greedy pattern can span from the first `<` to the last `>`.

With `perl = TRUE`, `*?` is a lazy quantifier:

``` r
regmatches(html_like, regexpr("<.*?>", html_like, perl = TRUE))
```

    ## [1] "<b>"

This matches the first short tag-like substring. Regex is not a complete
HTML parser; complex or malformed HTML should be handled by a dedicated
parser.

# 19.17 Word boundaries

A word boundary helps distinguish a word from text containing it as a
substring.

``` r
words_in_sentences <- c("cat", "cats", "a cat sleeps", "bobcat")
grepl("\\bcat\\b", words_in_sentences, perl = TRUE)
```

    ## [1]  TRUE FALSE  TRUE FALSE

Word-boundary behavior depends on the regex engine’s definition of word
characters. It may not align with every language or identifier
convention.

# 19.18 Lookahead and lookbehind (advanced)

Some regex engines support **lookaround assertions**, which test context
without consuming the matching characters. We use `perl = TRUE` for
these examples.

## Positive lookahead

Find digits that occur immediately before `kg`:

``` r
weights <- c("70kg", "65lb", "82kg", "unknown")
regmatches(weights, regexpr("[0-9]+(?=kg)", weights, perl = TRUE))
```

    ## [1] "70" "82"

## Positive lookbehind

Find digits immediately after `ID-`:

``` r
ids <- c("ID-123", "REF-456", "ID-78")
regmatches(ids, regexpr("(?<=ID-)[0-9]+", ids, perl = TRUE))
```

    ## [1] "123" "78"

Lookbehind restrictions depend on the regex engine and R version.
Fixed-length lookbehind, as above, is generally more portable than
variable-length lookbehind.

# 19.19 Case sensitivity and Unicode

By default, many matching operations are case-sensitive.

``` r
labels <- c("Apple", "apple", "APPLE", "Pineapple")
grepl("apple", labels)
```

    ## [1] FALSE  TRUE FALSE  TRUE

``` r
grepl("apple", labels, ignore.case = TRUE)
```

    ## [1] TRUE TRUE TRUE TRUE

## Unicode and international text

R supports Unicode text, but exact matching behavior depends on
encodings, locale, and regex engine. We should not assume that `[A-Z]`
represents all letters in every language.

``` r
text_values <- c("cafe", "café", "CAFÉ")
nchar(text_values, type = "chars")
```

    ## [1] 4 4 4

For multilingual applications, we should test with real representative
inputs and document the locale and encoding assumptions.

# 19.20 Optional `stringr` equivalents

The `stringr` package offers a consistent family of text-processing
functions. It is part of the tidyverse ecosystem, but **the core chapter
does not require it**.

``` r
if (requireNamespace("stringr", quietly = TRUE)) {
  x <- c("AB-1234", "invalid", "XY-0087")
  print(stringr::str_detect(x, "^[A-Z]{2}-[0-9]{4}$"))
  print(stringr::str_extract(x, "[0-9]{4}"))
  print(stringr::str_replace_all(x, "-", "/"))
  print(stringr::str_count(x, "[0-9]"))
} else {
  cat("Optional stringr examples skipped: package not installed.\n")
}
```

    ## [1]  TRUE FALSE  TRUE
    ## [1] "1234" NA     "0087"
    ## [1] "AB/1234" "invalid" "XY/0087"
    ## [1] 4 0 4

| Task                  | Base R                        | `stringr`           |
|-----------------------|-------------------------------|---------------------|
| Detect pattern        | `grepl()`                     | `str_detect()`      |
| Find matching strings | `grep(..., value=TRUE)`       | `str_subset()`      |
| Replace first match   | `sub()`                       | `str_replace()`     |
| Replace all matches   | `gsub()`                      | `str_replace_all()` |
| Extract first match   | `regexpr()` + `regmatches()`  | `str_extract()`     |
| Extract all matches   | `gregexpr()` + `regmatches()` | `str_extract_all()` |
| Count matches         | `gregexpr()` + counting       | `str_count()`       |
| Split strings         | `strsplit()`                  | `str_split()`       |

## Important distinction: `stringr` and base R regex engines

`stringr` uses the ICU regular-expression engine through `stringi`. Base
R may use TRE or PCRE2 depending on arguments. Therefore, some advanced
features, Unicode handling, and corner cases can differ. A regex is not
guaranteed to behave identically in every engine.

# 19.21 Building reusable regex functions

We will create a validator for synthetic inventory codes.

``` r
is_inventory_code <- function(x) {
  if (!is.character(x)) stop("x must be a character vector")
  grepl("^[A-Z]{2}-[0-9]{4}$", x)
}

is_inventory_code(c("AB-1234", "ab-1234", "CD-0001", NA))
```

    ## [1]  TRUE FALSE  TRUE FALSE

Missing values remain missing, rather than being silently classified as
invalid.

## Normalize labels before validation

``` r
normalize_inventory_code <- function(x) {
  if (!is.character(x)) stop("x must be character")
  x <- toupper(trimws(x))
  x <- gsub("[ _]", "-", x)
  x
}

raw_codes <- c(" ab 1234 ", "cd_0001", "XY-9876", "bad-code", NA)
clean_codes <- normalize_inventory_code(raw_codes)

data.frame(
  original = raw_codes,
  normalized = clean_codes,
  valid = is_inventory_code(clean_codes)
)
```

    ##    original normalized valid
    ## 1  ab 1234     AB-1234  TRUE
    ## 2   cd_0001    CD-0001  TRUE
    ## 3   XY-9876    XY-9876  TRUE
    ## 4  bad-code   BAD-CODE FALSE
    ## 5      <NA>       <NA> FALSE

Normalization and validation are separate operations. We should retain
original values when cleaning important identifiers.

# 19.22 Testing regex rules systematically

Regex patterns should be tested with **positive**, **negative**, and
**boundary** cases.

``` r
valid_examples <- c("AB-1234", "XY-0000", "ZZ-9999")
invalid_examples <- c("A-1234", "AB-123", "ab-1234", "AB_1234", "AB-12345", "")

stopifnot(all(is_inventory_code(valid_examples)))
stopifnot(!any(is_inventory_code(invalid_examples)))
```

A single successful example is not enough to demonstrate that a pattern
is correct.

## A common mistake: missing anchors

``` r
pattern_weak <- "[A-Z]{2}-[0-9]{4}"
pattern_strict <- "^[A-Z]{2}-[0-9]{4}$"

candidate <- "prefix AB-1234 suffix"
grepl(pattern_weak, candidate)
```

    ## [1] TRUE

``` r
grepl(pattern_strict, candidate)
```

    ## [1] FALSE

The weak pattern detects a substring. The strict pattern validates the
entire string.

# 19.23 Regex and missing values

Missing values deserve explicit attention.

``` r
inputs <- c("AB-1234", NA_character_, "bad")
grepl("^[A-Z]{2}-[0-9]{4}$", inputs)
```

    ## [1]  TRUE FALSE FALSE

In modern base R, regex operations commonly propagate missing input as
missing output. We should decide whether to preserve missingness or
explicitly convert it to `FALSE` for a particular task.

``` r
valid <- grepl("^[A-Z]{2}-[0-9]{4}$", inputs)
valid_for_filter <- !is.na(valid) & valid
inputs[valid_for_filter]
```

    ## [1] "AB-1234"

# 19.24 Pattern design for filenames

Consider the following files:

``` r
files <- c(
  "report_2024.csv",
  "report_2025.csv",
  "report_25.csv",
  "report_2025.csv.gz",
  "summary_2025.csv",
  "report_2026.CSV"
)
```

Find reports with a four-digit year and `.csv` extension:

``` r
files[grepl("^report_[0-9]{4}\\.csv$", files, ignore.case = TRUE)]
```

    ## [1] "report_2024.csv" "report_2025.csv" "report_2026.CSV"

Find gzip-compressed report CSVs:

``` r
files[grepl("^report_[0-9]{4}\\.csv\\.gz$", files, ignore.case = TRUE)]
```

    ## [1] "report_2025.csv.gz"

A four-digit sequence is not necessarily a valid calendar year. If year
validity matters, we must add an explicit range check after extraction.

# 19.25 Practical project: clean a product catalogue

Our dataset contains deliberately inconsistent product codes and
descriptions.

``` r
catalogue <- data.frame(
  item = 1:9,
  raw_code = c(
    "ab 1234", "XY_0087", "CD-4567", "bad", "EF-9876",
    "G-1234", "ZZ 0001", "LM-55", NA
  ),
  description = c(
    "  Blue   notebook ", "RED pen", "  green marker",
    "eraser  ", "Desk   lamp", " Paper clips ",
    "  Folder", "Tape", "unknown"
  ),
  stringsAsFactors = FALSE
)

catalogue
```

    ##   item raw_code        description
    ## 1    1  ab 1234   Blue   notebook 
    ## 2    2  XY_0087            RED pen
    ## 3    3  CD-4567       green marker
    ## 4    4      bad           eraser  
    ## 5    5  EF-9876        Desk   lamp
    ## 6    6   G-1234       Paper clips 
    ## 7    7  ZZ 0001             Folder
    ## 8    8    LM-55               Tape
    ## 9    9     <NA>            unknown

## Step 1: preserve original values

We retain `raw_code` and create new columns instead of overwriting it.

``` r
catalogue$code_clean <- normalize_inventory_code(catalogue$raw_code)
```

## Step 2: normalize descriptions

``` r
catalogue$description_clean <- gsub(
  "[[:space:]]+", " ",
  trimws(tolower(catalogue$description))
)
```

## Step 3: validate codes

``` r
catalogue$code_valid <- is_inventory_code(catalogue$code_clean)
catalogue
```

    ##   item raw_code        description code_clean description_clean code_valid
    ## 1    1  ab 1234   Blue   notebook     AB-1234     blue notebook       TRUE
    ## 2    2  XY_0087            RED pen    XY-0087           red pen       TRUE
    ## 3    3  CD-4567       green marker    CD-4567      green marker       TRUE
    ## 4    4      bad           eraser          BAD            eraser      FALSE
    ## 5    5  EF-9876        Desk   lamp    EF-9876         desk lamp       TRUE
    ## 6    6   G-1234       Paper clips      G-1234       paper clips      FALSE
    ## 7    7  ZZ 0001             Folder    ZZ-0001            folder       TRUE
    ## 8    8    LM-55               Tape      LM-55              tape      FALSE
    ## 9    9     <NA>            unknown       <NA>           unknown      FALSE

## Step 4: extract components only from valid codes

``` r
catalogue$prefix <- rep(NA_character_, nrow(catalogue))
catalogue$number <- rep(NA_character_, nrow(catalogue))

valid_rows <- which(!is.na(catalogue$code_valid) & catalogue$code_valid)

catalogue$prefix[valid_rows] <- substr(catalogue$code_clean[valid_rows], 1, 2)
catalogue$number[valid_rows] <- substr(catalogue$code_clean[valid_rows], 4, 7)

catalogue
```

    ##   item raw_code        description code_clean description_clean code_valid
    ## 1    1  ab 1234   Blue   notebook     AB-1234     blue notebook       TRUE
    ## 2    2  XY_0087            RED pen    XY-0087           red pen       TRUE
    ## 3    3  CD-4567       green marker    CD-4567      green marker       TRUE
    ## 4    4      bad           eraser          BAD            eraser      FALSE
    ## 5    5  EF-9876        Desk   lamp    EF-9876         desk lamp       TRUE
    ## 6    6   G-1234       Paper clips      G-1234       paper clips      FALSE
    ## 7    7  ZZ 0001             Folder    ZZ-0001            folder       TRUE
    ## 8    8    LM-55               Tape      LM-55              tape      FALSE
    ## 9    9     <NA>            unknown       <NA>           unknown      FALSE
    ##   prefix number
    ## 1     AB   1234
    ## 2     XY   0087
    ## 3     CD   4567
    ## 4   <NA>   <NA>
    ## 5     EF   9876
    ## 6   <NA>   <NA>
    ## 7     ZZ   0001
    ## 8   <NA>   <NA>
    ## 9   <NA>   <NA>

For a fixed and validated format, `substr()` can be simpler than another
regex. Regex is one tool, not a requirement for every string operation.

## Step 5: summarize quality-control results

``` r
qc_summary <- data.frame(
  total = nrow(catalogue),
  valid = sum(catalogue$code_valid, na.rm = TRUE),
  invalid = sum(!catalogue$code_valid, na.rm = TRUE),
  missing = sum(is.na(catalogue$code_valid))
)
qc_summary
```

    ##   total valid invalid missing
    ## 1     9     5       4       0

## Step 6: verify invariants

``` r
stopifnot(
  qc_summary$total == qc_summary$valid + qc_summary$invalid + qc_summary$missing,
  all(nchar(catalogue$prefix[valid_rows]) == 2L),
  all(nchar(catalogue$number[valid_rows]) == 4L)
)
```

# 19.26 Practical project: extracting information from logs

Application logs often contain repeated, semi-structured text.

``` r
logs <- c(
  "2026-01-03 INFO user=alice action=login",
  "2026-01-03 ERROR user=bob action=upload",
  "2026-01-04 INFO user=carol action=logout",
  "malformed log entry"
)
```

Find lines containing an error status:

``` r
logs[grepl(" ERROR ", logs, fixed = TRUE)]
```

    ## [1] "2026-01-03 ERROR user=bob action=upload"

Extract dates from correctly formatted prefixes:

``` r
dates <- rep(NA_character_, length(logs))
date_pattern <- "^[0-9]{4}-[0-9]{2}-[0-9]{2}"
has_date <- grepl(date_pattern, logs)
dates[has_date] <- substr(logs[has_date], 1, 10)
dates
```

    ## [1] "2026-01-03" "2026-01-03" "2026-01-04" NA

Extract user labels using a captured pattern:

``` r
user_pattern <- "user=[A-Za-z]+"
user_token <- rep(NA_character_, length(logs))
has_user <- grepl(user_pattern, logs)
user_token[has_user] <- sub(
  ".*?(user=[A-Za-z]+).*", "\\1", logs[has_user], perl = TRUE
)
user_token
```

    ## [1] "user=alice" "user=bob"   "user=carol" NA

This is a teaching example, not a general-purpose log parser. Real logs
may contain quoted fields, spaces, escaped values, and multiple formats.

# 19.27 Regex performance and readability

Regular expressions can become difficult to maintain when they are too
long or try to perform too many tasks at once.

Good practices include:

- Give complex patterns descriptive variable names.
- Add comments explaining each component.
- Use `fixed = TRUE` for literal searches.
- Anchor validation patterns with `^` and `$`.
- Separate normalization, extraction, and validation.
- Test empty strings, missing values, mixed case, and malformed inputs.
- Avoid unbounded, nested repetition when processing untrusted text.
- Prefer a dedicated parser for structured formats such as JSON, XML, or
  HTML.

## A readable pattern

``` r
# Two uppercase letters, hyphen, four digits; whole string
inventory_pattern <- "^[A-Z]{2}-[0-9]{4}$"
grepl(inventory_pattern, c("AB-1234", "INVALID"))
```

    ## [1]  TRUE FALSE

# 19.28 Common mistakes and troubleshooting

## Mistake 1: treating `.` as a literal period

``` r
grepl("a.b", c("a.b", "acb"))
```

    ## [1] TRUE TRUE

``` r
grepl("a\\.b", c("a.b", "acb"))
```

    ## [1]  TRUE FALSE

## Mistake 2: forgetting anchors

``` r
grepl("[0-9]{4}", c("1234", "A1234B", "12345"))
```

    ## [1] TRUE TRUE TRUE

``` r
grepl("^[0-9]{4}$", c("1234", "A1234B", "12345"))
```

    ## [1]  TRUE FALSE FALSE

## Mistake 3: confusing `sub()` and `gsub()`

``` r
sub("-", "/", "A-B-C")
```

    ## [1] "A/B-C"

``` r
gsub("-", "/", "A-B-C")
```

    ## [1] "A/B/C"

## Mistake 4: expecting `grep()` to return logical values

``` r
grep("cat", c("cat", "dog", "bobcat"))
```

    ## [1] 1 3

``` r
grepl("cat", c("cat", "dog", "bobcat"))
```

    ## [1]  TRUE FALSE  TRUE

## Mistake 5: validating a value using only a substring

``` r
grepl("[0-9]+", "abc123xyz")
```

    ## [1] TRUE

``` r
grepl("^[0-9]+$", "abc123xyz")
```

    ## [1] FALSE

## Mistake 6: overusing regex

For a fixed separator, `strsplit()` may be easier to understand:

``` r
strsplit("red,green,blue", ",", fixed = TRUE)
```

    ## [[1]]
    ## [1] "red"   "green" "blue"

## Mistake 7: assuming format validation proves correctness

A pattern can confirm that `2026-99-99` looks like `YYYY-MM-DD`; it
cannot confirm that the date exists. We should use a date parser after
structural validation.

``` r
date_text <- c("2026-01-15", "2026-99-99")
format_ok <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", date_text)
parsed_dates <- as.Date(date_text, format = "%Y-%m-%d")
data.frame(date_text, format_ok, parsed_dates)
```

    ##    date_text format_ok parsed_dates
    ## 1 2026-01-15      TRUE   2026-01-15
    ## 2 2026-99-99      TRUE         <NA>

# 19.29 Independent exercises — beginner

1.  Create a vector of ten filenames with `.csv`, `.txt`, `.tsv`, and
    `.csv.gz` extensions.
2.  Use `grepl()` to identify strings containing `csv`.
3.  Use an anchored pattern to identify files ending in `.csv` only.
4.  Explain why `".csv"` and `"\\.csv"` have different meanings.
5.  Find strings beginning with `A`.
6.  Find strings ending with a digit.
7.  Validate a string containing exactly three digits.
8.  Match `color` and `colour` with one pattern.
9.  Match either `red` or `blue`, but not `dark red`.
10. Replace every space with an underscore.
11. Compare `sub()` and `gsub()` using a string with three repeated
    words.
12. Explain the difference between `grep()` and `grepl()`.

# 19.30 Independent exercises — intermediate

1.  Validate a code with three uppercase letters, a hyphen, and five
    digits.
2.  Extract all numbers from `"A12 B34 C56"`.
3.  Standardize multiple consecutive spaces into one.
4.  Detect strings that contain no digits.
5.  Use capture groups to transform `"AB-1234"` into `"1234-AB"`.
6.  Find words `cat` as a whole word, not as part of `bobcat`.
7.  Write a function that returns `TRUE` for filenames ending in `.csv`
    or `.tsv`.
8.  Create positive and negative tests for that function.
9.  Compare a literal search using `fixed = TRUE` with a regex search.
10. Explain when regex alone is insufficient for validating an email
    address, URL, or calendar date.
11. Write a function that preserves `NA` while normalizing product
    codes.
12. Describe the difference between greedy and lazy matching.

# 19.31 Independent exercises — challenge

Build a **text-processing pipeline** for a synthetic customer directory
containing:

- customer ID;
- full name;
- email-like string;
- product code;
- free-text notes.

The pipeline should:

1.  Preserve all original columns.
2.  Trim leading and trailing whitespace.
3.  Standardize repeated internal spaces in names.
4.  Convert product codes to a common format.
5.  Validate product-code structure.
6.  Extract a domain-like suffix from email-like strings.
7.  Flag missing or malformed values without silently deleting records.
8.  Produce a data-quality summary.
9.  Test at least five boundary cases.
10. Explain why structural regex validation is not proof of a
    deliverable email address.

# 19.32 Complete standalone practice script

The following script consolidates the chapter’s core concepts. It is not
executed during knitting because the individual examples above already
demonstrate its operations.

``` r
# Chapter 19 — Regular Expressions in R
# R for Everyone | Base R only

raw <- c(" ab 1234 ", "XY_0087", "CD-4567", "invalid", NA)

normalize_code <- function(x) {
  stopifnot(is.character(x))
  x <- toupper(trimws(x))
  gsub("[ _]", "-", x)
}

is_code <- function(x) {
  stopifnot(is.character(x))
  grepl("^[A-Z]{2}-[0-9]{4}$", x)
}

clean <- normalize_code(raw)
valid <- is_code(clean)

result <- data.frame(
  original = raw,
  normalized = clean,
  valid = valid,
  stringsAsFactors = FALSE
)

print(result)

# Check valid and invalid examples
stopifnot(all(is_code(c("AB-1234", "XY-0087"))))
stopifnot(!any(is_code(c("A-1234", "AB-123", "ab-1234"))))

# Match files ending in CSV
files <- c("sales.csv", "notes.txt", "archive.csv.gz", "REPORT.CSV")
print(files[grepl("\\.csv$", files, ignore.case = TRUE)])

# Extract all numbers
text <- c("A12 B34", "X7", "none")
print(regmatches(text, gregexpr("[0-9]+", text)))

# Clean display labels
labels <- c("  Blue   notebook ", "RED pen")
labels_clean <- gsub("[[:space:]]+", " ", trimws(tolower(labels)))
print(labels_clean)
```

# 19.33 Quick reference

| Pattern or function    | Purpose                                           |
|------------------------|---------------------------------------------------|
| `.`                    | Any single character (normally excluding newline) |
| `^`                    | Beginning of string                               |
| `$`                    | End of string                                     |
| `[abc]`                | One of `a`, `b`, or `c`                           |
| `[0-9]`                | One ASCII digit                                   |
| `[^0-9]`               | One non-digit                                     |
| `*`                    | Zero or more repetitions                          |
| `+`                    | One or more repetitions                           |
| `?`                    | Optional occurrence                               |
| `{n}`                  | Exactly `n` repetitions                           |
| `{n,m}`                | Between `n` and `m` repetitions                   |
| `(a|b)`                | Grouped alternatives                              |
| `\\b` with `perl=TRUE` | Word boundary                                     |
| `grepl()`              | Logical match detection                           |
| `grep()`               | Match positions or values                         |
| `sub()`                | Replace first match                               |
| `gsub()`               | Replace all matches                               |
| `regexpr()`            | Locate first match                                |
| `gregexpr()`           | Locate all matches                                |
| `regmatches()`         | Extract matched text                              |
| `fixed=TRUE`           | Literal matching                                  |
| `ignore.case=TRUE`     | Case-insensitive matching                         |
| `perl=TRUE`            | Use Perl-compatible regex engine                  |

# 19.34 Chapter review questions

1.  What is the difference between literal matching and regex matching?
2.  Why does `.` match more than a literal period?
3.  What is the purpose of `^` and `$`?
4.  How do `[0-9]` and `[^0-9]` differ?
5.  What is the difference between `*` and `+`?
6.  How can we require exactly four digits?
7.  How do we match `cat` or `dog` as complete strings?
8.  What is the difference between `grep()` and `grepl()`?
9.  When should we use `fixed = TRUE`?
10. What is the difference between `sub()` and `gsub()`?
11. How do `regexpr()` and `gregexpr()` differ?
12. What does a capture group do?
13. Why do ordinary R strings often require doubled backslashes?
14. What does a lazy quantifier do?
15. Why might Unicode matching differ between regex engines?
16. How can we avoid accidentally accepting a substring as a valid
    identifier?
17. How should missing values be handled during validation?
18. Why should normalization and validation be separate steps?
19. Why should a regex be tested with boundary cases?
20. When should a dedicated parser be preferred over regex?

# 19.35 Key takeaways

- Regex lets us describe **patterns**, not just fixed strings.
- `grepl()` detects matches; `grep()` identifies matching positions or
  values.
- Anchors, character classes, and quantifiers form the foundation of
  most practical regex.
- Escaping must account for both R string syntax and regex syntax.
- `sub()` replaces the first match; `gsub()` replaces all matches.
- `regexpr()`, `gregexpr()`, and `regmatches()` support text extraction.
- Capture groups enable rearrangement of matched components.
- Advanced regex features can depend on the chosen engine.
- Format validation is not the same as verifying that information is
  correct.
- Readable, well-tested patterns are better than unnecessarily complex
  patterns.

**Next: Chapter 20 — Working with Dates and Times in R.**
