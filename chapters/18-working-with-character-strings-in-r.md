Working with Character Strings
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

Numbers represent quantities, but much of our everyday data consists of
**text**: names, email addresses, product descriptions, cities,
filenames, messages, and identifiers. In R, text is stored as
**character strings**. Learning to work confidently with strings allows
us to prepare messy data, construct readable output, extract
information, and automate repetitive tasks.

In this chapter, we begin with **base R**, which requires no additional
packages. We then introduce the popular **`stringr`** package as an
optional alternative. Chapter 19 will develop regular expressions in
depth; here we focus mainly on ordinary, *literal* text operations.

All datasets are synthetic. We use **we, us, and our** throughout the
textbook, and each example is designed to run in sequence in a fresh R
session.

## Learning objectives

By the end of the chapter, we will be able to:

1.  Create character vectors and distinguish strings from names and
    factors.
2.  Recognize missing, empty, and whitespace-only strings.
3.  Measure string lengths and understand Unicode caveats.
4.  Join, format, and repeat strings.
5.  Extract substrings and split text into components.
6.  Find, replace, and standardize literal text safely.
7.  Change case, trim whitespace, and normalize everyday labels.
8.  Sort, compare, and match character values.
9.  Understand escaping, quotation marks, and special characters.
10. Apply vectorized string operations to data frames.
11. Use optional `stringr` functions and compare their behavior with
    base R.
12. Write and test reusable string-cleaning functions.

# 18.1 What is a character string?

A **string** is a sequence of characters enclosed in single or double
quotation marks.

``` r
first_name <- "Asha"
last_name <- 'Sharma'
city <- "Lucknow"

first_name
```

    ## [1] "Asha"

``` r
last_name
```

    ## [1] "Sharma"

``` r
city
```

    ## [1] "Lucknow"

Both quote styles create the same R type. The quotation marks delimit
the text; they are not usually part of the stored value.

``` r
typeof(first_name)
```

    ## [1] "character"

``` r
class(first_name)
```

    ## [1] "character"

``` r
length(first_name)
```

    ## [1] 1

Notice that `length(first_name)` is **1**: the object is a vector
containing one string, even though that string contains four letters.

## Strings versus variable names

``` r
score <- 95
score          # value of an object
```

    ## [1] 95

``` r
"score"        # literal text
```

    ## [1] "score"

R evaluates `score` as an object name, whereas `"score"` is character
data.

## Strings versus numbers

``` r
number <- 2026
number_as_text <- "2026"

typeof(number)
```

    ## [1] "double"

``` r
typeof(number_as_text)
```

    ## [1] "character"

A number can be used directly in arithmetic. A string that looks like a
number must first be parsed or converted, and conversion can fail when
the text contains nonnumeric characters.

``` r
as.numeric("42")
```

    ## [1] 42

``` r
as.numeric("3.75")
```

    ## [1] 3.75

We should not convert identifiers such as `"0017"` to numbers: doing so
removes meaningful leading zeros.

# 18.2 Character vectors

R stores multiple strings in a character vector.

``` r
names_vec <- c("Asha", "Ravi", "Meera", "Kabir")
names_vec
```

    ## [1] "Asha"  "Ravi"  "Meera" "Kabir"

``` r
length(names_vec)
```

    ## [1] 4

``` r
typeof(names_vec)
```

    ## [1] "character"

We can select, replace, and subset elements with familiar vector
operations.

``` r
names_vec[1]
```

    ## [1] "Asha"

``` r
names_vec[c(2, 4)]
```

    ## [1] "Ravi"  "Kabir"

``` r
names_vec[names_vec != "Ravi"]
```

    ## [1] "Asha"  "Meera" "Kabir"

Strings are **case-sensitive** by default.

``` r
"Asha" == "asha"
```

    ## [1] FALSE

``` r
"Asha" == "Asha"
```

    ## [1] TRUE

## Character vectors and factors

A factor stores categorical values along with defined levels. It may
display like text but is not a character vector internally.

``` r
department_factor <- factor(c("Sales", "HR", "Sales"))
class(department_factor)
```

    ## [1] "factor"

``` r
levels(department_factor)
```

    ## [1] "HR"    "Sales"

``` r
as.character(department_factor)
```

    ## [1] "Sales" "HR"    "Sales"

When our task involves general text manipulation, converting a factor to
character explicitly can avoid surprising behavior.

# 18.3 Missing, empty, and whitespace-only strings

These are three distinct situations:

``` r
text_values <- c("R", "", "   ", NA_character_, "Data")
text_values
```

    ## [1] "R"    ""     "   "  NA     "Data"

``` r
is.na(text_values)
```

    ## [1] FALSE FALSE FALSE  TRUE FALSE

``` r
text_values == ""
```

    ## [1] FALSE  TRUE FALSE    NA FALSE

- `NA_character_` means a character value is missing.
- `""` is a present string containing **zero** characters.
- `"   "` contains three spaces; it is not empty.

Comparisons involving `NA` usually produce `NA`, not `TRUE` or `FALSE`.

``` r
text_values == "Data"
```

    ## [1] FALSE FALSE FALSE    NA  TRUE

To identify whitespace-only strings, we can trim them first.

``` r
trimmed_values <- trimws(text_values)
trimmed_values
```

    ## [1] "R"    ""     ""     NA     "Data"

``` r
is.na(trimmed_values) | (!is.na(trimmed_values) & trimmed_values == "")
```

    ## [1] FALSE  TRUE  TRUE  TRUE FALSE

For practical cleaning, we often distinguish genuinely missing entries
from present but blank entries, rather than silently merging them.

# 18.4 Counting characters: `nchar()` and `nzchar()`

`nchar()` counts characters in each string. It is not the same as
`length()`, which counts vector elements.

``` r
words <- c("R", "Python", "Statistics")
length(words)
```

    ## [1] 3

``` r
nchar(words)
```

    ## [1]  1  6 10

`nzchar()` tests whether a string contains at least one character.

``` r
nzchar(c("R", "", "  "))
```

    ## [1]  TRUE FALSE  TRUE

Spaces count as characters. If we want to treat whitespace-only values
as blank, we first apply `trimws()`.

``` r
labels <- c("Apple", "", "   ", "Pear")
nzchar(trimws(labels))
```

    ## [1]  TRUE FALSE FALSE  TRUE

## Missing-value behavior

``` r
nchar(c("cat", NA_character_))
```

    ## [1]  3 NA

``` r
nzchar(c("cat", NA_character_), keepNA = TRUE)
```

    ## [1] TRUE   NA

Explicit `keepNA = TRUE` makes missingness clear for `nzchar()`.

## Bytes versus characters

Unicode text may use more than one byte per character.

``` r
example_unicode <- "café"
nchar(example_unicode, type = "chars")
```

    ## [1] 4

``` r
nchar(example_unicode, type = "bytes")
```

    ## [1] 5

The byte count can depend on the string’s encoding. A character count is
also not necessarily a count of visible *grapheme clusters*: some
displayed symbols consist of multiple Unicode code points.

# 18.5 Joining strings with `paste()`

`paste()` joins values with a separator. The default separator is a
space.

``` r
paste("R", "for", "Everyone")
```

    ## [1] "R for Everyone"

``` r
paste("Chapter", 18)
```

    ## [1] "Chapter 18"

Change the separator with `sep`:

``` r
paste("2026", "10", "23", sep = "-")
```

    ## [1] "2026-10-23"

``` r
paste("file", "csv", sep = ".")
```

    ## [1] "file.csv"

## Vectorization

`paste()` works element by element across vectors.

``` r
first <- c("Asha", "Ravi", "Meera")
last <- c("Sharma", "Verma", "Singh")
paste(first, last)
```

    ## [1] "Asha Sharma" "Ravi Verma"  "Meera Singh"

Be careful with vector recycling. If the lengths are incompatible, R may
recycle shorter inputs and warn or produce unintended results.

``` r
paste(c("A", "B", "C"), "2026", sep = "_")
```

    ## [1] "A_2026" "B_2026" "C_2026"

Recycling a single value across a vector is common and intentional.

## Joining all values into one string: `collapse`

``` r
fruits <- c("apple", "banana", "mango")
paste(fruits, collapse = ", ")
```

    ## [1] "apple, banana, mango"

`sep` joins arguments *within each element*; `collapse` joins the
resulting elements into **one** string.

``` r
paste(c("A", "B"), c("1", "2"), sep = "-", collapse = "; ")
```

    ## [1] "A-1; B-2"

# 18.6 `paste0()` versus `paste()`

`paste0()` joins strings without inserting a separator.

``` r
paste("sample", 1:3)
```

    ## [1] "sample 1" "sample 2" "sample 3"

``` r
paste0("sample", 1:3)
```

    ## [1] "sample1" "sample2" "sample3"

``` r
paste0("ID", sprintf("%03d", 1:5))
```

    ## [1] "ID001" "ID002" "ID003" "ID004" "ID005"

The `paste0()` pattern is especially useful for building identifiers,
messages, and filenames.

``` r
file_names <- paste0("report_", 1:4, ".csv")
file_names
```

    ## [1] "report_1.csv" "report_2.csv" "report_3.csv" "report_4.csv"

For actual filesystem paths, `file.path()` is usually preferable to
manual concatenation.

``` r
file.path("data", "raw", "participants.csv")
```

    ## [1] "data/raw/participants.csv"

# 18.7 Formatted text with `sprintf()`

`sprintf()` inserts values into a template using formatting
instructions.

``` r
sprintf("Participant %s is %d years old.", "P001", 34)
```

    ## [1] "Participant P001 is 34 years old."

``` r
sprintf("Score: %.2f", 87.456)
```

    ## [1] "Score: 87.46"

``` r
sprintf("Sample_%03d", 1:5)
```

    ## [1] "Sample_001" "Sample_002" "Sample_003" "Sample_004" "Sample_005"

Common placeholders:

| Placeholder | Meaning                   | Example    |
|-------------|---------------------------|------------|
| `%s`        | String                    | `"Asha"`   |
| `%d`        | Integer                   | `12`       |
| `%f`        | Decimal number            | `3.140000` |
| `%.2f`      | Two decimal places        | `3.14`     |
| `%03d`      | Three digits, zero-padded | `007`      |
| `%%`        | Literal percent sign      | `%`        |

``` r
sprintf("Completion: %.1f%%", 92.75)
```

    ## [1] "Completion: 92.8%"

``` r
sprintf("Invoice-%04d", c(7, 18, 205))
```

    ## [1] "Invoice-0007" "Invoice-0018" "Invoice-0205"

Formatting affects how a value is **displayed**, not necessarily its
underlying numerical precision.

# 18.8 Extracting parts of strings with `substr()` and `substring()`

`substr(x, start, stop)` extracts characters from specified positions,
beginning at position 1.

``` r
word <- "Programming"
substr(word, 1, 4)
```

    ## [1] "Prog"

``` r
substr(word, 5, 11)
```

    ## [1] "ramming"

`substring()` has similar behavior and can also extract to the end when
`last` is omitted.

``` r
substring("Programming", 5)
```

    ## [1] "ramming"

## Vectorized extraction

``` r
codes <- c("IND-001", "USA-025", "GBR-110")
substr(codes, 1, 3)
```

    ## [1] "IND" "USA" "GBR"

``` r
substr(codes, 5, 7)
```

    ## [1] "001" "025" "110"

This is appropriate when the format and positions are consistent. When
the position varies, splitting or pattern-based extraction is more
reliable.

## Replacing part of a string

``` r
code <- "ABC-123"
substr(code, 1, 3) <- "XYZ"
code
```

    ## [1] "XYZ-123"

Substring assignment changes only the selected character positions; it
does not behave like arbitrary-length text insertion.

# 18.9 Splitting strings with `strsplit()`

`strsplit()` divides each string using a delimiter and returns a
**list**.

``` r
full_names <- c("Asha Sharma", "Ravi Verma", "Meera Singh")
parts <- strsplit(full_names, split = " ", fixed = TRUE)
parts
```

    ## [[1]]
    ## [1] "Asha"   "Sharma"
    ## 
    ## [[2]]
    ## [1] "Ravi"  "Verma"
    ## 
    ## [[3]]
    ## [1] "Meera" "Singh"

``` r
class(parts)
```

    ## [1] "list"

Each list element contains the components of one input string.

``` r
parts[[1]]
```

    ## [1] "Asha"   "Sharma"

``` r
vapply(parts, length, integer(1))
```

    ## [1] 2 2 2

## Extracting a consistent first component

``` r
first_names <- vapply(parts, function(x) x[1], character(1))
first_names
```

    ## [1] "Asha"  "Ravi"  "Meera"

This works because every example contains at least one component.
Real-world names can include middle names, multiple spaces, and
culturally diverse naming conventions; we should not assume that every
person’s name splits cleanly into exactly two fields.

## Splitting codes

``` r
product_codes <- c("BOOK-2026-001", "PEN-2026-002")
code_parts <- strsplit(product_codes, "-", fixed = TRUE)
code_parts
```

    ## [[1]]
    ## [1] "BOOK" "2026" "001" 
    ## 
    ## [[2]]
    ## [1] "PEN"  "2026" "002"

For a delimiter such as a period (`.`), `fixed = TRUE` ensures that it
is interpreted literally rather than as a regular-expression
metacharacter.

``` r
strsplit("report.final.csv", ".", fixed = TRUE)[[1]]
```

    ## [1] "report" "final"  "csv"

## Reconstructing text

``` r
paste(code_parts[[1]], collapse = "-")
```

    ## [1] "BOOK-2026-001"

# 18.10 Searching for literal text

Base R provides `grepl()` to test whether text contains a pattern and
`grep()` to return matching positions or values.

By default, these functions use **regular expressions**. For ordinary
text searches, `fixed = TRUE` treats the pattern literally.

``` r
products <- c("Blue notebook", "Red pen", "Blue folder", "Pencil")

grepl("Blue", products, fixed = TRUE)
```

    ## [1]  TRUE FALSE  TRUE FALSE

``` r
grep("Blue", products, fixed = TRUE)
```

    ## [1] 1 3

``` r
grep("Blue", products, fixed = TRUE, value = TRUE)
```

    ## [1] "Blue notebook" "Blue folder"

### `grepl()` versus `grep()`

- `grepl()` returns a logical vector, one result per input element.
- `grep()` returns the indices of matching elements, unless
  `value = TRUE` requests the matching strings.

``` r
selected_products <- products[grepl("Blue", products, fixed = TRUE)]
selected_products
```

    ## [1] "Blue notebook" "Blue folder"

## Case-insensitive searching

``` r
grepl("blue", products, fixed = TRUE, ignore.case = TRUE)
```

    ## Warning in grepl("blue", products, fixed = TRUE, ignore.case = TRUE): argument
    ## 'ignore.case = TRUE' will be ignored

    ## [1] FALSE FALSE FALSE FALSE

## Why `fixed = TRUE` matters

A dot has special meaning in regular expressions, but not in literal
text.

``` r
file_labels <- c("data.csv", "dataXcsv", "notes.txt")
grepl(".csv", file_labels, fixed = TRUE)
```

    ## [1]  TRUE FALSE FALSE

In Chapter 19, we will explore pattern matching deliberately and learn
when regular expressions are more suitable.

# 18.11 Finding match positions with `regexpr()`

`regexpr()` returns the position of the first match in each input
string. A value of `-1` indicates no match.

``` r
sentences <- c("Learn R today", "R is useful", "Python course")
regexpr("R", sentences, fixed = TRUE)
```

    ## [1]  7  1 -1
    ## attr(,"match.length")
    ## [1]  1  1 -1
    ## attr(,"index.type")
    ## [1] "chars"
    ## attr(,"useBytes")
    ## [1] TRUE

The result includes attributes describing match lengths. When we need
only positions, we can convert it to an ordinary integer vector.

``` r
as.integer(regexpr("R", sentences, fixed = TRUE))
```

    ## [1]  7  1 -1

`gregexpr()` can locate multiple matches in a string; we will examine it
more thoroughly in Chapter 19.

# 18.12 Replacing literal text: `sub()` and `gsub()`

`sub()` replaces the **first** match in each string. `gsub()` replaces
**all** matches.

``` r
message <- "R is fun. R is powerful."
sub("R", "R programming", message, fixed = TRUE)
```

    ## [1] "R programming is fun. R is powerful."

``` r
gsub("R", "R programming", message, fixed = TRUE)
```

    ## [1] "R programming is fun. R programming is powerful."

## Cleaning inconsistent labels

``` r
statuses <- c("in progress", "completed", "in progress", "pending")
gsub("in progress", "active", statuses, fixed = TRUE)
```

    ## [1] "active"    "completed" "active"    "pending"

## Replacing punctuation literally

``` r
prices <- c("1,200", "3,450", "750")
clean_prices <- gsub(",", "", prices, fixed = TRUE)
as.numeric(clean_prices)
```

    ## [1] 1200 3450  750

We must check the number format before removing commas. In some locales,
a comma is a decimal separator rather than a thousands separator.

# 18.13 Converting letter case

Base R provides `toupper()`, `tolower()`, and `tools::toTitleCase()`.

``` r
labels <- c("new york", "LONDON", "mUmBaI")
toupper(labels)
```

    ## [1] "NEW YORK" "LONDON"   "MUMBAI"

``` r
tolower(labels)
```

    ## [1] "new york" "london"   "mumbai"

``` r
tools::toTitleCase(tolower(labels))
```

    ## [1] "New York" "London"   "Mumbai"

Title-casing personal names or addresses automatically can produce
incorrect capitalization. We should preserve authoritative spelling when
it is available.

## Case-insensitive comparisons

``` r
input_status <- c("Active", "ACTIVE", "active", "Closed")
tolower(input_status) == "active"
```

    ## [1]  TRUE  TRUE  TRUE FALSE

Case conversion can have locale-specific Unicode behavior; for
international text, assumptions about case mapping should be tested with
representative examples.

# 18.14 Removing leading and trailing whitespace

`trimws()` removes whitespace from the beginning and end of strings.

``` r
raw_cities <- c("  Delhi", "Mumbai  ", "  Chennai  ")
trimws(raw_cities)
```

    ## [1] "Delhi"   "Mumbai"  "Chennai"

Whitespace inside a string remains unchanged:

``` r
trimws("  New   Delhi  ")
```

    ## [1] "New   Delhi"

## Standardizing simple labels

``` r
raw_departments <- c(" SALES ", "Sales", " sales", "HR ", " hr")
standard_departments <- tolower(trimws(raw_departments))
standard_departments
```

    ## [1] "sales" "sales" "sales" "hr"    "hr"

``` r
unique(standard_departments)
```

    ## [1] "sales" "hr"

This operation is useful when the differences are only case and
surrounding whitespace. It does not resolve spelling variants such as
`"Human Resources"` versus `"HR"` without an explicit mapping.

# 18.15 Repeating strings with `strrep()`

``` r
strrep("-", 20)
```

    ## [1] "--------------------"

``` r
strrep("R", c(1, 2, 3, 4))
```

    ## [1] "R"    "RR"   "RRR"  "RRRR"

We can create readable console separators:

``` r
cat(strrep("=", 30), "\n", sep = "")
```

    ## ==============================

``` r
cat("Monthly Report\n")
```

    ## Monthly Report

``` r
cat(strrep("=", 30), "\n", sep = "")
```

    ## ==============================

`cat()` prints text without the quoted representation used by ordinary
object printing. It is useful for console reports but does not return a
string object suitable for further transformation.

# 18.16 Comparing, matching, and sorting strings

## Equality and membership

``` r
colors <- c("red", "blue", "green", "red")
colors == "red"
```

    ## [1]  TRUE FALSE FALSE  TRUE

``` r
colors %in% c("red", "green")
```

    ## [1]  TRUE FALSE  TRUE  TRUE

## `match()`

``` r
lookup <- c("A", "B", "C")
match(c("B", "C", "X"), lookup)
```

    ## [1]  2  3 NA

`match()` returns the position of the first matching value, or `NA` if
no match exists.

## `unique()` and `duplicated()`

``` r
unique(colors)
```

    ## [1] "red"   "blue"  "green"

``` r
duplicated(colors)
```

    ## [1] FALSE FALSE FALSE  TRUE

## Sorting

``` r
sort(c("banana", "apple", "cherry"))
```

    ## [1] "apple"  "banana" "cherry"

``` r
order(c("banana", "apple", "cherry"))
```

    ## [1] 2 1 3

Alphabetical ordering can depend on locale and collation rules. We
should not assume that string ordering is identical across all
computers.

# 18.17 Special characters and escaping

Some characters have special meanings inside R string literals.

| Escape | Meaning                                    |
|--------|--------------------------------------------|
| `\n`   | Newline                                    |
| `\t`   | Tab                                        |
| `\\`   | Literal backslash                          |
| `\"`   | Double quote inside a double-quoted string |
| `\'`   | Single quote inside a single-quoted string |

``` r
cat("Line one\nLine two\n")
```

    ## Line one
    ## Line two

``` r
cat("Column A\tColumn B\n")
```

    ## Column A Column B

``` r
cat("He said: \"Hello\"\n")
```

    ## He said: "Hello"

## Backslashes in Windows paths

``` r
windows_path <- "C:/Projects/R/data.csv"
windows_path
```

    ## [1] "C:/Projects/R/data.csv"

Forward slashes are typically simpler in R on Windows. We can also
escape backslashes:

``` r
windows_path2 <- "C:\\Projects\\R\\data.csv"
windows_path2
```

    ## [1] "C:\\Projects\\R\\data.csv"

## Raw character strings

Modern R supports raw string constants, which can be useful for text
containing many backslashes.

``` r
raw_path <- r"(C:\Projects\R\data.csv)"
raw_path
```

    ## [1] "C:\\Projects\\R\\data.csv"

Raw strings are particularly helpful when we later write complex regular
expressions.

# 18.18 Encoding and Unicode basics

Text may include accented letters and scripts beyond basic ASCII. R
supports Unicode strings, but behavior can depend on the operating
system, locale, and file encoding.

``` r
words_unicode <- c("café", "naïve", "résumé")
words_unicode
```

    ## [1] "café"   "naïve"  "résumé"

``` r
Encoding(words_unicode)
```

    ## [1] "UTF-8" "UTF-8" "UTF-8"

`Encoding()` reports encoding marks attached to strings; it is **not** a
universal detector of the original encoding of an external file.

``` r
enc2utf8(words_unicode)
```

    ## [1] "café"   "naïve"  "résumé"

For files, we should prefer an explicitly documented encoding, often
UTF-8. For multilingual or visually complex text, code-point counts and
byte counts do not always match what a reader perceives as characters.

# 18.19 Working with strings inside data frames

String operations are vectorized, so we can transform entire columns
without writing loops.

``` r
employees <- data.frame(
  employee_id = c("E001", "E002", "E003", "E004", "E005"),
  name = c("  Asha Sharma ", "RAVI VERMA", "Meera Singh", " Kabir Ali", "Nina Roy "),
  department = c("Sales", " sales ", "HR", "hr", "SALES"),
  email = c("ASHA@example.com", "ravi@example.com", "meera@example.org", "kabir@example.org", "nina@example.com"),
  stringsAsFactors = FALSE
)

employees
```

    ##   employee_id           name department             email
    ## 1        E001   Asha Sharma       Sales  ASHA@example.com
    ## 2        E002     RAVI VERMA     sales   ravi@example.com
    ## 3        E003    Meera Singh         HR meera@example.org
    ## 4        E004      Kabir Ali         hr kabir@example.org
    ## 5        E005      Nina Roy       SALES  nina@example.com

## Standardize names and departments

``` r
employees$name_clean <- trimws(employees$name)
employees$department_clean <- tolower(trimws(employees$department))
employees$email_clean <- tolower(trimws(employees$email))

employees[, c("name_clean", "department_clean", "email_clean")]
```

    ##    name_clean department_clean       email_clean
    ## 1 Asha Sharma            sales  asha@example.com
    ## 2  RAVI VERMA            sales  ravi@example.com
    ## 3 Meera Singh               hr meera@example.org
    ## 4   Kabir Ali               hr kabir@example.org
    ## 5    Nina Roy            sales  nina@example.com

## Construct display labels

``` r
employees$display_label <- paste0(
  employees$employee_id, " — ", employees$name_clean
)

employees$display_label
```

    ## [1] "E001 — Asha Sharma" "E002 — RAVI VERMA"  "E003 — Meera Singh"
    ## [4] "E004 — Kabir Ali"   "E005 — Nina Roy"

## Select records by text

``` r
sales_employees <- employees[
  employees$department_clean == "sales",
  ,
  drop = FALSE
]

sales_employees
```

    ##   employee_id           name department            email  name_clean
    ## 1        E001   Asha Sharma       Sales ASHA@example.com Asha Sharma
    ## 2        E002     RAVI VERMA     sales  ravi@example.com  RAVI VERMA
    ## 5        E005      Nina Roy       SALES nina@example.com    Nina Roy
    ##   department_clean      email_clean      display_label
    ## 1            sales asha@example.com E001 — Asha Sharma
    ## 2            sales ravi@example.com  E002 — RAVI VERMA
    ## 5            sales nina@example.com    E005 — Nina Roy

## Extract simple email domains

``` r
email_parts <- strsplit(employees$email_clean, "@", fixed = TRUE)
email_domains <- vapply(
  email_parts,
  function(x) if (length(x) == 2L) x[2] else NA_character_,
  character(1)
)

employees$email_domain <- email_domains
employees[, c("email_clean", "email_domain")]
```

    ##         email_clean email_domain
    ## 1  asha@example.com  example.com
    ## 2  ravi@example.com  example.com
    ## 3 meera@example.org  example.org
    ## 4 kabir@example.org  example.org
    ## 5  nina@example.com  example.com

Splitting on `@` illustrates string processing but is **not a complete
email-address validator**. Real email syntax and internationalized
addresses are more complicated.

# 18.20 A first introduction to `stringr`

The **`stringr`** package is part of the tidyverse ecosystem and
provides a consistent family of `str_*()` functions. Its main advantages
include clear names, predictable argument conventions, and convenient
handling of many common text tasks.

This chapter remains fully runnable without `stringr`. The following
chunk checks whether the package is installed and displays optional
examples only when it is available.

``` r
stringr_available <- requireNamespace("stringr", quietly = TRUE)
stringr_available
```

    ## [1] TRUE

If installation is permitted in our R environment, we can install it
separately using:

``` r
install.packages("stringr")
```

Installation may be restricted on managed computers. No example in this
chapter requires package installation during knitting.

## Base R and stringr equivalents

| Task | Base R | `stringr` |
|----|----|----|
| Length of each string | `nchar(x)` | `str_length(x)` |
| Join strings | `paste0(a, b)` | `str_c(a, b)` |
| Detect text | `grepl(p, x, fixed=TRUE)` | `str_detect(x, fixed(p))` |
| Extract by position | `substr(x, i, j)` | `str_sub(x, i, j)` |
| Split strings | `strsplit(x, p, fixed=TRUE)` | `str_split(x, fixed(p))` |
| Replace first match | `sub(p, r, x, fixed=TRUE)` | `str_replace(x, fixed(p), r)` |
| Replace all matches | `gsub(p, r, x, fixed=TRUE)` | `str_replace_all(x, fixed(p), r)` |
| Change case | `tolower(x)` | `str_to_lower(x)` |
| Trim whitespace | `trimws(x)` | `str_trim(x)` |
| Repeat text | `strrep(x, n)` | `str_dup(x, n)` |

For `stringr`, the `fixed()` helper is important when we want
**literal** matching rather than regular expressions.

``` r
if (stringr_available) {
  print(stringr::str_length(c("R", "Everyone")))
  print(stringr::str_c("Chapter ", 18))
  print(stringr::str_detect(c("report.csv", "notes.txt"), stringr::fixed(".csv")))
  print(stringr::str_replace_all("red red blue", stringr::fixed("red"), "green"))
  print(stringr::str_trim("  R programming  "))
} else {
  cat("Optional stringr examples skipped; base R examples remain available.\n")
}
```

    ## [1] 1 8
    ## [1] "Chapter 18"
    ## [1]  TRUE FALSE
    ## [1] "green green blue"
    ## [1] "R programming"

## `str_sub()` supports negative positions

Negative positions count from the end of the string, a convenient
feature absent from the simplest `substr()` usage.

``` r
if (stringr_available) {
  print(stringr::str_sub("report.csv", -3, -1))
}
```

    ## [1] "csv"

## `str_squish()` removes extra internal whitespace

Unlike `trimws()`, `str_squish()` also collapses runs of internal
whitespace.

``` r
if (stringr_available) {
  print(stringr::str_squish("  New    Delhi   Office  "))
}
```

    ## [1] "New Delhi Office"

A base-R alternative for ordinary ASCII spaces is possible:

``` r
space_example <- "  New    Delhi   Office  "
base_squish_spaces <- gsub("  ", " ", trimws(space_example), fixed = TRUE)
while (grepl("  ", base_squish_spaces, fixed = TRUE)) {
  base_squish_spaces <- gsub("  ", " ", base_squish_spaces, fixed = TRUE)
}
base_squish_spaces
```

    ## [1] "New Delhi Office"

This demonstration handles repeated **space characters**. It is not a
full replacement for `str_squish()` across every whitespace character.

# 18.21 Base R versus stringr: an applied comparison

Suppose we receive the following messy product descriptions:

``` r
raw_products <- c(
  "  BLUE notebook  ",
  "red PEN",
  "Blue Folder ",
  "  green notebook"
)
```

Our goal is to trim surrounding spaces, convert text to lowercase, and
identify notebook entries.

### Base R solution

``` r
products_clean_base <- tolower(trimws(raw_products))
notebooks_base <- products_clean_base[
  grepl("notebook", products_clean_base, fixed = TRUE)
]

products_clean_base
```

    ## [1] "blue notebook"  "red pen"        "blue folder"    "green notebook"

``` r
notebooks_base
```

    ## [1] "blue notebook"  "green notebook"

### Optional stringr solution

``` r
if (stringr_available) {
  products_clean_stringr <- stringr::str_to_lower(
    stringr::str_trim(raw_products)
  )
  notebooks_stringr <- products_clean_stringr[
    stringr::str_detect(products_clean_stringr, stringr::fixed("notebook"))
  ]
  print(products_clean_stringr)
  print(notebooks_stringr)
  stopifnot(identical(unname(products_clean_base), unname(products_clean_stringr)))
}
```

    ## [1] "blue notebook"  "red pen"        "blue folder"    "green notebook"
    ## [1] "blue notebook"  "green notebook"

The two approaches express the same underlying transformation. We should
understand the base-R operations before treating package syntax as a
shortcut.

# 18.22 Writing reusable string-cleaning functions

A useful function should handle missing values, vector inputs, and
invalid input types explicitly.

``` r
clean_label <- function(x) {
  if (!is.character(x)) {
    stop("x must be a character vector.")
  }
  tolower(trimws(x))
}

clean_label(c("  ACTIVE ", "Pending  ", NA_character_))
```

    ## [1] "active"  "pending" NA

The function preserves missing values rather than silently converting
them into a string such as `"NA"`.

## A safer blank-value detector

``` r
is_blank_text <- function(x) {
  if (!is.character(x)) {
    stop("x must be a character vector.")
  }
  is.na(x) | (!is.na(x) & !nzchar(trimws(x)))
}

is_blank_text(c("R", "", "  ", NA_character_))
```

    ## [1] FALSE  TRUE  TRUE  TRUE

## A filename constructor

``` r
make_report_name <- function(prefix, index, extension = "csv") {
  if (!is.character(prefix) || length(prefix) != 1L ||
      is.na(prefix) || !nzchar(prefix)) {
    stop("prefix must be one nonempty string.")
  }
  if (!is.numeric(index) || anyNA(index) ||
      any(!is.finite(index)) || any(index < 0) ||
      any(index != floor(index))) {
    stop("index must contain finite, nonnegative whole numbers.")
  }
  if (!is.character(extension) || length(extension) != 1L ||
      is.na(extension) || !nzchar(extension)) {
    stop("extension must be one nonempty string.")
  }
  paste0(prefix, "_", sprintf("%03.0f", index), ".", extension)
}

make_report_name("sales", 1:4)
```

    ## [1] "sales_001.csv" "sales_002.csv" "sales_003.csv" "sales_004.csv"

The function constructs **filenames**, not complete paths. For complete
paths, we can combine its output with `file.path()`.

# 18.23 Testing our string functions

Small tests help detect mistakes before we apply a function to a large
dataset.

``` r
stopifnot(
  identical(clean_label("  ACTIVE "), "active"),
  identical(clean_label(NA_character_), NA_character_),
  identical(is_blank_text(c("A", "", " ", NA_character_)),
            c(FALSE, TRUE, TRUE, TRUE)),
  identical(make_report_name("file", 7), "file_007.csv")
)
```

## Testing expected errors

We can use `tryCatch()` to confirm that invalid input produces an error
without interrupting knitting.

``` r
invalid_input_result <- tryCatch(
  clean_label(123),
  error = function(e) conditionMessage(e)
)
invalid_input_result
```

    ## [1] "x must be a character vector."

We should also test empty vectors, missing strings, punctuation,
accented characters, and unexpected delimiters when relevant.

# 18.24 Common mistakes and how to fix them

## Mistake 1: confusing `length()` and `nchar()`

``` r
x <- c("apple", "banana")
length(x)
```

    ## [1] 2

``` r
nchar(x)
```

    ## [1] 5 6

`length()` counts vector elements; `nchar()` counts characters within
each element.

## Mistake 2: treating `NA` as the text `"NA"`

``` r
values <- c("NA", NA_character_)
values == "NA"
```

    ## [1] TRUE   NA

``` r
is.na(values)
```

    ## [1] FALSE  TRUE

The first element is present text; the second is missing.

## Mistake 3: assuming case-insensitive matching

``` r
"Sales" == "sales"
```

    ## [1] FALSE

``` r
tolower("Sales") == tolower("sales")
```

    ## [1] TRUE

## Mistake 4: forgetting that `strsplit()` returns a list

``` r
result <- strsplit(c("A-B", "C-D"), "-", fixed = TRUE)
class(result)
```

    ## [1] "list"

``` r
result[[1]]
```

    ## [1] "A" "B"

## Mistake 5: using regex unintentionally

``` r
grepl(".csv", c("data.csv", "dataXcsv"), fixed = TRUE)
```

    ## [1]  TRUE FALSE

For literal searches, `fixed = TRUE` makes our intention explicit.

## Mistake 6: losing leading zeros

``` r
code <- "0007"
code
```

    ## [1] "0007"

``` r
as.numeric(code)
```

    ## [1] 7

Identifiers should normally remain character values.

## Mistake 7: removing all spaces when only trimming is intended

``` r
text <- "  New Delhi  "
trimws(text)
```

    ## [1] "New Delhi"

``` r
gsub(" ", "", text, fixed = TRUE)
```

    ## [1] "NewDelhi"

The second operation changes `"New Delhi"` to `"NewDelhi"`, which may be
undesirable.

## Mistake 8: assuming a fixed-width format is universal

``` r
ids <- c("ABC-001", "LONGCODE-002")
substr(ids, 1, 3)
```

    ## [1] "ABC" "LON"

Fixed-position extraction is suitable only when the input specification
guarantees those positions.

## Mistake 9: forgetting to inspect unusual Unicode text

``` r
nchar("café")
```

    ## [1] 4

For multilingual data, we should test normalization, encoding, and
display assumptions explicitly.

# 18.25 Guided practical project: cleaning a small customer directory

Our goal is to transform a messy directory into a consistent table
suitable for downstream analysis.

## Step 1: create synthetic raw data

``` r
customers <- data.frame(
  customer_id = c("C001", "C002", "C003", "C004", "C005", "C006"),
  customer_name = c("  Asha Sharma", "RAVI VERMA  ", "Meera Singh", "  Kabir Ali  ", "Nina Roy", " "),
  city = c(" delhi ", "DELHI", "Mumbai ", "mumbai", " Pune", NA_character_),
  membership = c(" ACTIVE ", "active", "Pending ", "PENDING", "inactive", " active "),
  email = c("ASHA@example.com", "ravi@example.com", "meera@example.org", "kabir@example.org", "nina@example.com", "unknown"),
  stringsAsFactors = FALSE
)

customers
```

    ##   customer_id customer_name    city membership             email
    ## 1        C001   Asha Sharma  delhi     ACTIVE   ASHA@example.com
    ## 2        C002  RAVI VERMA     DELHI     active  ravi@example.com
    ## 3        C003   Meera Singh Mumbai    Pending  meera@example.org
    ## 4        C004   Kabir Ali    mumbai    PENDING kabir@example.org
    ## 5        C005      Nina Roy    Pune   inactive  nina@example.com
    ## 6        C006                  <NA>    active            unknown

## Step 2: inspect missing and blank text

``` r
colSums(is.na(customers))
```

    ##   customer_id customer_name          city    membership         email 
    ##             0             0             1             0             0

``` r
is_blank_text(customers$customer_name)
```

    ## [1] FALSE FALSE FALSE FALSE FALSE  TRUE

## Step 3: standardize text

``` r
customers$name_clean <- trimws(customers$customer_name)
customers$city_clean <- clean_label(customers$city)
customers$membership_clean <- clean_label(customers$membership)
customers$email_clean <- clean_label(customers$email)
```

## Step 4: convert blank names to missing values

``` r
customers$name_clean[is_blank_text(customers$name_clean)] <- NA_character_
```

## Step 5: create a readable customer label

``` r
customers$customer_label <- ifelse(
  is.na(customers$name_clean),
  customers$customer_id,
  paste0(customers$customer_id, " — ", customers$name_clean)
)
```

## Step 6: extract domains where exactly one `@` occurs

``` r
email_tokens <- strsplit(customers$email_clean, "@", fixed = TRUE)
customers$email_domain <- vapply(
  email_tokens,
  function(tokens) {
    if (length(tokens) == 2L && all(nzchar(tokens))) {
      tokens[2]
    } else {
      NA_character_
    }
  },
  character(1)
)
```

This is a simplified structural check, not formal email validation.

## Step 7: summarize the cleaned directory

``` r
customers[, c(
  "customer_id", "name_clean", "city_clean",
  "membership_clean", "email_domain"
)]
```

    ##   customer_id  name_clean city_clean membership_clean email_domain
    ## 1        C001 Asha Sharma      delhi           active  example.com
    ## 2        C002  RAVI VERMA      delhi           active  example.com
    ## 3        C003 Meera Singh     mumbai          pending  example.org
    ## 4        C004   Kabir Ali     mumbai          pending  example.org
    ## 5        C005    Nina Roy       pune         inactive  example.com
    ## 6        C006        <NA>       <NA>           active         <NA>

``` r
table(customers$membership_clean, useNA = "ifany")
```

    ## 
    ##   active inactive  pending 
    ##        3        1        2

``` r
table(customers$city_clean, useNA = "ifany")
```

    ## 
    ##  delhi mumbai   pune   <NA> 
    ##      2      2      1      1

## Step 8: validate the result

``` r
stopifnot(
  nrow(customers) == 6L,
  !anyDuplicated(customers$customer_id),
  sum(is.na(customers$name_clean)) == 1L,
  sum(is.na(customers$email_domain)) == 1L,
  all(customers$membership_clean %in%
        c("active", "pending", "inactive"))
)
```

## Step 9: export to a temporary file

``` r
output_dir <- file.path(tempdir(), "r_for_everyone_ch18")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
output_path <- file.path(output_dir, "customers_clean.csv")
write.csv(customers, output_path, row.names = FALSE, na = "")
file.exists(output_path)
```

    ## [1] TRUE

The practical illustrates a complete workflow: **inspect → clean →
derive → validate → export**. All inputs are synthetic and all outputs
are written to a temporary folder.

# 18.26 Independent exercises: beginner level

1.  Create a character vector containing five city names.
2.  Use `length()` and `nchar()` and explain why the outputs differ.
3.  Combine a first name and last name with `paste()`.
4.  Create identifiers `S001` through `S010` using `sprintf()`.
5.  Join a vector of five fruits into one comma-separated string.
6.  Extract the first three characters from a set of product codes.
7.  Split `"North-East-West"` into separate components.
8.  Convert `"  R PROGRAMMING  "` to `"r programming"`.
9.  Identify empty strings in `c("A", "", "B", " ")`.
10. Explain the difference between `NA_character_` and `"NA"`.
11. Replace every occurrence of `"old"` with `"new"`.
12. Sort a character vector alphabetically.

# 18.27 Independent exercises: intermediate level

1.  Build a function that standardizes city labels using `tolower()` and
    `trimws()`.
2.  Write a function that detects missing, empty, or whitespace-only
    strings.
3.  Given filenames `"sales.csv"`, `"notes.txt"`, and `"report.csv"`,
    select only the `.csv` filenames using literal matching.
4.  Split a vector of codes of the form `"CAT-001"` into category and
    numeric identifier.
5.  Extract the extension from a filename using a literal split, and
    discuss filenames with multiple dots.
6.  Standardize `"Yes"`, `"YES"`, `" yes "`, and `"No"`.
7.  Create a formatted invoice message containing an identifier and a
    two-decimal price.
8.  Use `match()` to connect a vector of labels to a reference list.
9.  Identify duplicated text values after trimming and case
    normalization.
10. Compare `sub()` and `gsub()` using a sentence containing repeated
    words.
11. Explain why an identifier with leading zeros should remain character
    data.
12. Create tests for a function that accepts a character vector and
    returns its trimmed values.

# 18.28 Challenge project: product catalog standardization

Create a synthetic catalog with at least 20 products containing
inconsistent capitalization, surrounding whitespace, repeated category
labels, and product codes. Develop a base-R workflow that:

1.  Preserves the original input columns.
2.  Standardizes product names and categories.
3.  Flags missing or blank product names.
4.  Extracts category prefixes from well-formed product codes.
5.  Identifies duplicates after normalization.
6.  Builds human-readable display labels.
7.  Produces a frequency table of cleaned categories.
8.  Exports the cleaned catalog to CSV.
9.  Validates key assumptions with `stopifnot()`.
10. Implements an optional `stringr` version of at least three
    transformations.

**Advanced extension:** Write a function that accepts a data frame and a
set of column names, then trims whitespace in all specified character
columns while leaving numerical columns unchanged.

# 18.29 Complete standalone practice script

The following script is self-contained and intentionally not executed
during knitting because the individual examples have already
demonstrated its operations.

``` r
# ============================================================
# R for Everyone — Chapter 18
# Working with Character Strings in R
# Base R only; synthetic data
# ============================================================

clean_label <- function(x) {
  stopifnot(is.character(x))
  tolower(trimws(x))
}

is_blank_text <- function(x) {
  stopifnot(is.character(x))
  is.na(x) | (!is.na(x) & !nzchar(trimws(x)))
}

catalog <- data.frame(
  code = c("BOOK-001", "PEN-002", "BOOK-003", "BAG-004"),
  product = c("  BLUE NOTEBOOK", "Red Pen ", "blue notebook", "  Travel Bag "),
  category = c(" Books ", "STATIONERY", "books", " Bags"),
  stringsAsFactors = FALSE
)

catalog$product_clean <- clean_label(catalog$product)
catalog$category_clean <- clean_label(catalog$category)
catalog$blank_product <- is_blank_text(catalog$product)

parts <- strsplit(catalog$code, "-", fixed = TRUE)
catalog$prefix <- vapply(parts, function(x) x[1], character(1))

catalog$label <- paste0(catalog$code, ": ", catalog$product_clean)

stopifnot(
  nrow(catalog) == 4L,
  !any(catalog$blank_product),
  all(nzchar(catalog$prefix))
)

print(catalog)
print(table(catalog$category_clean))

out_dir <- file.path(tempdir(), "chapter18_standalone")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(catalog, file.path(out_dir, "catalog_clean.csv"), row.names = FALSE)

if (requireNamespace("stringr", quietly = TRUE)) {
  print(stringr::str_squish("  New   Delhi  "))
}
```

# 18.30 Essential functions reference

| Function                     | Purpose                              |
|------------------------------|--------------------------------------|
| `c()`                        | Construct a character vector         |
| `typeof()`                   | Inspect storage type                 |
| `class()`                    | Inspect object class                 |
| `length()`                   | Count vector elements                |
| `nchar()`                    | Count characters or bytes            |
| `nzchar()`                   | Test whether strings are nonempty    |
| `is.na()`                    | Detect missing values                |
| `paste()`                    | Join strings with a separator        |
| `paste0()`                   | Join strings without a separator     |
| `sprintf()`                  | Format text using placeholders       |
| `substr()`                   | Extract or replace a substring       |
| `substring()`                | Extract substring, optionally to end |
| `strsplit()`                 | Split strings into a list            |
| `grepl()`                    | Test for text matches                |
| `grep()`                     | Return matching positions or values  |
| `regexpr()`                  | Find first match positions           |
| `sub()`                      | Replace first match                  |
| `gsub()`                     | Replace all matches                  |
| `tolower()`                  | Convert to lowercase                 |
| `toupper()`                  | Convert to uppercase                 |
| `trimws()`                   | Remove surrounding whitespace        |
| `strrep()`                   | Repeat text                          |
| `unique()`                   | Find distinct values                 |
| `duplicated()`               | Identify repeated values             |
| `match()`                    | Find positions in a reference vector |
| `sort()`                     | Sort strings                         |
| `order()`                    | Obtain ordering indices              |
| `cat()`                      | Print text to a connection           |
| `Encoding()`                 | Inspect encoding marks               |
| `enc2utf8()`                 | Convert to UTF-8 representation      |
| `stringr::str_length()`      | Optional package-based length        |
| `stringr::str_detect()`      | Optional pattern detection           |
| `stringr::str_replace_all()` | Optional replacement                 |
| `stringr::str_squish()`      | Optional whitespace normalization    |

# 18.31 Review questions

1.  What is a character string?
2.  How does a character string differ from an object name?
3.  Why does `length("Programming")` return 1?
4.  What does `nchar()` measure?
5.  How do missing, empty, and whitespace-only strings differ?
6.  What is the difference between `paste()` and `paste0()`?
7.  What does `collapse` do in `paste()`?
8.  How can `sprintf()` create zero-padded identifiers?
9.  How does `substr()` select characters?
10. Why does `strsplit()` return a list?
11. What is the difference between `grep()` and `grepl()`?
12. Why is `fixed = TRUE` useful?
13. What is the difference between `sub()` and `gsub()`?
14. How do we compare labels without regard to capitalization?
15. What does `trimws()` remove?
16. Why can deleting all spaces corrupt a city name?
17. How do we construct a vectorized display label?
18. Why are identifiers with leading zeros treated as text?
19. What is Unicode, and why might bytes and characters differ?
20. How can we use `stringr` without making it a mandatory dependency?
21. What does `str_squish()` add beyond `trimws()`?
22. Why should cleaning functions preserve missing values?
23. How do we test a text-cleaning function?
24. What are the limitations of splitting names on a single space?
25. When should we use regular expressions instead of literal matching?

# 18.32 Key takeaways

- Strings are character values; character vectors can contain many
  strings.
- `length()` counts vector elements, while `nchar()` counts characters
  within strings.
- Missing, empty, and whitespace-only values require different handling.
- `paste()`, `paste0()`, and `sprintf()` support readable text
  construction.
- `substr()` and `strsplit()` extract components of structured text.
- `grep()`, `grepl()`, `sub()`, and `gsub()` provide powerful search and
  replacement operations.
- **`fixed = TRUE` is the safest default for literal text matching** in
  base R when regex is unnecessary.
- `tolower()`, `toupper()`, and `trimws()` handle common normalization
  tasks.
- `stringr` provides a convenient, consistent interface but is optional
  for the core concepts.
- Reusable functions and explicit validation make text-processing
  workflows more reliable.

# Looking ahead: Chapter 19 — Regular Expressions in R

In Chapter 19, we will move beyond literal text to **patterns**. We will
learn character classes, anchors, quantifiers, groups, alternation,
capture groups, and practical regex debugging. We will compare base R’s
regular-expression functions with `stringr`, using examples such as
filenames, identifiers, phone-like strings, and structured log messages.
