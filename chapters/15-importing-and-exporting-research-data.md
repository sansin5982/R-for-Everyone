Importing and Exporting Research Data
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapter 14, we learned how files, directories, paths, and connections
work in R. We created CSV, TSV, gzip, and RDS files. In this chapter, we
move from knowing **how to open a file** to understanding **how to
import research data without changing their scientific meaning**.

A table can load successfully and still be wrong. A participant
identifier may lose its leading zeros. A laboratory result may be read
as text. A date may be interpreted using the wrong day–month order. A
value of `999` may be a missing-data code rather than a genuine
measurement. A GWAS coordinate may be numerically correct but belong to
the wrong genome build. These errors can propagate silently into
downstream analysis.

Our objective is to develop a reliable workflow:

**Inspect → Specify → Import → Validate → Clean with documented rules →
Export → Re-import → Verify.**

We use **base R only** throughout. Every executable example creates
**synthetic teaching data** in a dedicated temporary folder; no external
packages, downloads, or real participant records are required. We use
inclusive language—*we*, *our*, and *us*—throughout this textbook.

## 15.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Distinguish data import, parsing, validation, transformation, and
    export.
2.  Read CSV, TSV, whitespace-delimited, and semicolon-delimited files.
3.  Recognize headers, quoting, decimal conventions, and character
    encodings.
4.  Preserve identifiers and other columns with explicit import types.
5.  Diagnose mixed-type columns and unexpected missing values.
6.  Work with documented missing-data codes without altering valid
    observations.
7.  Import and export dates with explicit formats.
8.  Handle gzip-compressed research tables using base R.
9.  Select columns and preview large files before committing memory.
10. Understand what CSV/TSV cannot preserve and when to use RDS.
11. Build and use a data dictionary.
12. Validate ranges, uniqueness, allowed categories, and cross-field
    consistency.
13. Export interoperable, documented datasets and verify round trips.
14. Construct a reusable import function with informative errors.
15. Process multiple study files without silently mixing incompatible
    schemas.
16. Apply these practices to clinical, epidemiological, and GWAS
    summary-statistic datasets.

------------------------------------------------------------------------

## 15.2 Importing is not the same as validating

**Importing** converts bytes stored in a file into an R object.

**Parsing** interprets text as numbers, dates, logical values, and other
types.

**Validation** checks whether the resulting object satisfies expected
rules.

**Cleaning** applies explicit, scientifically justified corrections or
recodings.

**Exporting** writes an R object to a chosen format and location.

Suppose a blood-pressure column contains `"145"`, `"130"`, and `"999"`.
R can parse all three as numbers. However, if the study codebook defines
`999` as *not measured*, the imported data are not yet analytically
correct. We must interpret the codebook before using the values.

The central principle is: **successful parsing is not evidence of
scientific validity**.

## 15.3 Establishing a safe practice workspace

Our code should not depend on a previously opened RStudio session or an
existing file in an arbitrary working directory. We create a temporary
workspace and explicitly define our paths.

``` r
chapter15_root <- file.path(tempdir(), "r_book_chapter15")
raw_dir <- file.path(chapter15_root, "data", "raw")
clean_dir <- file.path(chapter15_root, "data", "clean")
export_dir <- file.path(chapter15_root, "results")

for (folder in c(raw_dir, clean_dir, export_dir)) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

stopifnot(all(dir.exists(c(raw_dir, clean_dir, export_dir))))
chapter15_root
```

    ## [1] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpQDbPrO/r_book_chapter15"

This directory exists for the current R session and may disappear after
the session ends. It is therefore suitable for exercises, not long-term
storage.

### Why we do not use `setwd()` here

We construct complete paths from `chapter15_root`. This avoids
repeatedly changing the working directory and reduces ambiguity during
knitting.

------------------------------------------------------------------------

## 15.4 Our first clinical import: inspect before reading

Create a synthetic clinical cohort:

``` r
cohort <- data.frame(
  participant_id = c("001", "002", "003", "004", "005"),
  age_years = c(34, 52, 46, 61, 40),
  sbp_mmhg = c(118, 152, NA, 146, 130),
  sex_recorded = c("F", "M", "F", "M", "F"),
  study_site = c("North", "South", "North", "East", "South"),
  stringsAsFactors = FALSE
)

clinical_path <- file.path(raw_dir, "clinical_cohort.csv")
write.csv(cohort, clinical_path, row.names = FALSE, na = "")
```

Inspect the file as text before parsing:

``` r
readLines(clinical_path, n = 4, warn = FALSE)
```

    ## [1] "\"participant_id\",\"age_years\",\"sbp_mmhg\",\"sex_recorded\",\"study_site\""
    ## [2] "\"001\",34,118,\"F\",\"North\""                                               
    ## [3] "\"002\",52,152,\"M\",\"South\""                                               
    ## [4] "\"003\",46,,\"F\",\"North\""

The first line contains column names; subsequent lines contain records.
This initial inspection helps us identify the delimiter, header, and
missing-value representation.

Now import:

``` r
clinical <- read.csv(
  clinical_path,
  colClasses = c(
    participant_id = "character",
    age_years = "numeric",
    sbp_mmhg = "numeric",
    sex_recorded = "character",
    study_site = "character"
  ),
  na.strings = c("", "NA"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

str(clinical)
```

    ## 'data.frame':    5 obs. of  5 variables:
    ##  $ participant_id: chr  "001" "002" "003" "004" ...
    ##  $ age_years     : num  34 52 46 61 40
    ##  $ sbp_mmhg      : num  118 152 NA 146 130
    ##  $ sex_recorded  : chr  "F" "M" "F" "M" ...
    ##  $ study_site    : chr  "North" "South" "North" "East" ...

``` r
clinical
```

    ##   participant_id age_years sbp_mmhg sex_recorded study_site
    ## 1            001        34      118            F      North
    ## 2            002        52      152            M      South
    ## 3            003        46       NA            F      North
    ## 4            004        61      146            M       East
    ## 5            005        40      130            F      South

**Why explicitly specify types?** The identifier `"001"` is not the
number 1. Converting it to numeric would remove the leading zeros and
potentially break linkage to other study files.

## 15.5 What the principal import arguments mean

| Argument | Purpose | Example |
|----|----|----|
| `file` | Input path or connection | `clinical_path` |
| `header` | Whether the first row contains names | `TRUE` |
| `sep` | Field delimiter | `","`, `"\t"`, `";"` |
| `quote` | Quotation characters | `"\""` |
| `na.strings` | Text interpreted as missing | `c("", "NA")` |
| `colClasses` | Expected column types | `c(id = "character")` |
| `stringsAsFactors` | Whether text becomes factors | `FALSE` |
| `check.names` | Whether to alter unusual names | `FALSE` |
| `nrows` | Maximum rows to read | `10` |
| `skip` | Number of initial lines to skip | `2` |
| `comment.char` | Marker for comment text | `"#"` or `""` |
| `fileEncoding` | Encoding used to read text | `"UTF-8"` |

The appropriate choices depend on the actual file format and
documentation. We should not copy options blindly from one dataset to
another.

------------------------------------------------------------------------

## 15.6 CSV, TSV, and semicolon-separated files

A **CSV** uses commas to separate fields. A **TSV** uses tabs. A
semicolon-separated file uses semicolons; this convention is common in
some locales where a comma is used as the decimal mark.

### CSV

``` r
csv_data <- read.csv(clinical_path, stringsAsFactors = FALSE)
head(csv_data, 3)
```

    ##   participant_id age_years sbp_mmhg sex_recorded study_site
    ## 1              1        34      118            F      North
    ## 2              2        52      152            M      South
    ## 3              3        46       NA            F      North

### TSV

``` r
tsv_path <- file.path(raw_dir, "clinical_cohort.tsv")
write.table(
  cohort, tsv_path,
  sep = "\t", row.names = FALSE,
  quote = TRUE, na = "NA"
)

tsv_data <- read.delim(
  tsv_path,
  stringsAsFactors = FALSE,
  check.names = FALSE
)
head(tsv_data, 3)
```

    ##   participant_id age_years sbp_mmhg sex_recorded study_site
    ## 1              1        34      118            F      North
    ## 2              2        52      152            M      South
    ## 3              3        46       NA            F      North

### Semicolon-separated file

``` r
semi_path <- file.path(raw_dir, "semicolon_data.csv")
writeLines(
  c("id;value", "S1;1,25", "S2;2,50"),
  semi_path
)

semi_data <- read.csv2(
  semi_path,
  stringsAsFactors = FALSE
)
semi_data
```

    ##   id value
    ## 1 S1  1.25
    ## 2 S2  2.50

`read.csv2()` defaults to a semicolon separator and comma decimal mark.
We should verify that these conventions actually match the source file.

### Whitespace-separated files

``` r
space_path <- file.path(raw_dir, "whitespace_data.txt")
writeLines(c("id value", "S1 12", "S2 18"), space_path)

space_data <- read.table(
  space_path, header = TRUE,
  stringsAsFactors = FALSE
)
space_data
```

    ##   id value
    ## 1 S1    12
    ## 2 S2    18

Whitespace-delimited files are not suitable when unquoted fields
legitimately contain spaces. We must inspect the source specification.

------------------------------------------------------------------------

## 15.7 Quoted fields and embedded delimiters

A clinical note may contain a comma or quotation marks:

``` r
notes <- data.frame(
  id = c("P1", "P2"),
  note = c('Follow-up, second visit', 'Patient stated "no"'),
  stringsAsFactors = FALSE
)

notes_path <- file.path(raw_dir, "notes.csv")
write.csv(notes, notes_path, row.names = FALSE)

readLines(notes_path, warn = FALSE)
```

    ## [1] "\"id\",\"note\""                     
    ## [2] "\"P1\",\"Follow-up, second visit\""  
    ## [3] "\"P2\",\"Patient stated \"\"no\"\"\""

``` r
notes_roundtrip <- read.csv(notes_path, stringsAsFactors = FALSE)
stopifnot(identical(notes, notes_roundtrip))
```

CSV quoting allows delimiters and quotation marks to be stored inside a
field. Manually splitting a CSV line using `strsplit(line, ",")` is
unreliable when quoted fields are present.

## 15.8 Column names and reproducibility

A file may contain headers such as `"Odds Ratio"` or `"P-Value"`.

``` r
unusual <- data.frame(
  "Odds Ratio" = c(1.2, 0.8),
  "P-Value" = c(0.01, 0.30),
  check.names = FALSE
)

unusual_path <- file.path(raw_dir, "unusual_headers.csv")
write.csv(unusual, unusual_path, row.names = FALSE)

unusual_import <- read.csv(
  unusual_path, check.names = FALSE
)
names(unusual_import)
```

    ## [1] "Odds Ratio" "P-Value"

``` r
unusual_import[["Odds Ratio"]]
```

    ## [1] 1.2 0.8

With `check.names = FALSE`, the imported names remain faithful to the
file. With default name checking, R may modify spaces or punctuation.
Neither approach is universally right; consistency with the documented
schema is what matters.

------------------------------------------------------------------------

## 15.9 Data types: character, integer, numeric, logical, factor

The most important post-import inspection commands are:

``` r
str(clinical)
```

    ## 'data.frame':    5 obs. of  5 variables:
    ##  $ participant_id: chr  "001" "002" "003" "004" ...
    ##  $ age_years     : num  34 52 46 61 40
    ##  $ sbp_mmhg      : num  118 152 NA 146 130
    ##  $ sex_recorded  : chr  "F" "M" "F" "M" ...
    ##  $ study_site    : chr  "North" "South" "North" "East" ...

``` r
sapply(clinical, class)
```

    ## participant_id      age_years       sbp_mmhg   sex_recorded     study_site 
    ##    "character"      "numeric"      "numeric"    "character"    "character"

``` r
sapply(clinical, typeof)
```

    ## participant_id      age_years       sbp_mmhg   sex_recorded     study_site 
    ##    "character"       "double"       "double"    "character"    "character"

``` r
summary(clinical)
```

    ##  participant_id       age_years       sbp_mmhg     sex_recorded      
    ##  Length:5           Min.   :34.0   Min.   :118.0   Length:5          
    ##  Class :character   1st Qu.:40.0   1st Qu.:127.0   Class :character  
    ##  Mode  :character   Median :46.0   Median :138.0   Mode  :character  
    ##                     Mean   :46.6   Mean   :136.5                     
    ##                     3rd Qu.:52.0   3rd Qu.:147.5                     
    ##                     Max.   :61.0   Max.   :152.0                     
    ##                                    NA's   :1                         
    ##   study_site       
    ##  Length:5          
    ##  Class :character  
    ##  Mode  :character  
    ##                    
    ##                    
    ##                    
    ## 

### Character versus numeric

A variable containing `"12"`, `"15"`, and `"unknown"` cannot be parsed
entirely as numeric without a rule for `"unknown"`.

``` r
raw_values <- c("12", "15", "unknown")
parsed_values <- suppressWarnings(as.numeric(raw_values))
parsed_values
```

    ## [1] 12 15 NA

The result contains `NA` where conversion failed. This does **not**
automatically mean that `"unknown"` is a legitimate missing code. We
must confirm its meaning in the data dictionary.

### Logical columns

``` r
flags <- c(TRUE, FALSE, TRUE)
typeof(flags)
```

    ## [1] "logical"

A source may instead use `"Y"/"N"`, `"1"/"0"`, or `"Yes"/"No"`. Those
encodings need explicit interpretation.

### Factor columns

``` r
site_factor <- factor(clinical$study_site)
levels(site_factor)
```

    ## [1] "East"  "North" "South"

Factors carry a defined set of levels. A CSV export usually stores
visible labels rather than the complete factor metadata. We should
reconstruct factors deliberately after import.

------------------------------------------------------------------------

## 15.10 The factor-to-numeric trap

Consider a factor with labels `"10"`, `"20"`, and `"30"`:

``` r
factor_numbers <- factor(c("10", "20", "30"))

as.numeric(factor_numbers)
```

    ## [1] 1 2 3

``` r
as.numeric(as.character(factor_numbers))
```

    ## [1] 10 20 30

The first conversion returns the factor’s internal codes, not the
original measurements. The second converts the **labels** into numbers.

This distinction can materially alter statistical analyses. We should
never convert a factor to numeric without checking what the levels
represent.

------------------------------------------------------------------------

## 15.11 Data dictionaries: describing the meaning of columns

A **data dictionary** specifies the expected variables, types, units,
allowed values, missing codes, and scientific interpretation.

For our clinical cohort:

| Variable | Intended type | Units / coding | Missing policy |
|----|----|----|----|
| `participant_id` | Character | Unique study ID | Not allowed |
| `age_years` | Numeric | Years | Investigate missing |
| `sbp_mmhg` | Numeric | mmHg | `NA` allowed |
| `sex_recorded` | Character | `F`, `M` in this synthetic dataset | Investigate other codes |
| `study_site` | Character | `North`, `South`, `East` | Not allowed |

These categories are specific to our **synthetic exercise**, not a
recommendation for coding real-world sex or gender variables.

We can store a small dictionary as a table:

``` r
dictionary <- data.frame(
  variable = c("participant_id", "age_years", "sbp_mmhg",
               "sex_recorded", "study_site"),
  type = c("character", "numeric", "numeric",
           "character", "character"),
  unit_or_codes = c("unique ID", "years", "mmHg",
                    "F/M (synthetic)", "North/South/East"),
  stringsAsFactors = FALSE
)

dictionary_path <- file.path(export_dir, "clinical_dictionary.csv")
write.csv(dictionary, dictionary_path, row.names = FALSE)
dictionary
```

    ##         variable      type    unit_or_codes
    ## 1 participant_id character        unique ID
    ## 2      age_years   numeric            years
    ## 3       sbp_mmhg   numeric             mmHg
    ## 4   sex_recorded character  F/M (synthetic)
    ## 5     study_site character North/South/East

For larger projects, a dictionary may also include variable
descriptions, valid ranges, measurement instruments, collection dates,
provenance, and version history.

------------------------------------------------------------------------

## 15.12 Missing values: distinguish absence from a real number

Research files may represent missingness as `NA`, `N/A`, `Unknown`, an
empty cell, `-9`, or `999`. We should interpret each code only after
consulting source documentation.

Create a file with a **documented synthetic sentinel** of `999` for
missing SBP:

``` r
sentinel_path <- file.path(raw_dir, "sbp_sentinel.csv")
writeLines(
  c("id,sbp", "P1,125", "P2,999", "P3,142", "P4,"),
  sentinel_path
)

sentinel <- read.csv(
  sentinel_path,
  colClasses = c(id = "character", sbp = "numeric"),
  na.strings = c("", "NA")
)
sentinel
```

    ##   id sbp
    ## 1 P1 125
    ## 2 P2 999
    ## 3 P3 142
    ## 4 P4  NA

Now apply the **documented rule**:

``` r
sentinel$sbp[sentinel$sbp == 999 & !is.na(sentinel$sbp)] <- NA_real_
sentinel
```

    ##   id sbp
    ## 1 P1 125
    ## 2 P2  NA
    ## 3 P3 142
    ## 4 P4  NA

The expression checks both equality and missingness; `NA` values remain
missing.

A clearer alternative uses an index:

``` r
sentinel2 <- read.csv(sentinel_path, na.strings = c("", "NA"))
replace_index <- which(!is.na(sentinel2$sbp) & sentinel2$sbp == 999)
sentinel2$sbp[replace_index] <- NA_real_
stopifnot(isTRUE(all.equal(sentinel$sbp, sentinel2$sbp)))
```

**Scientific caution:** A value of `999` is not always missing. It may
be valid for another variable. Sentinel conversion must be
variable-specific and documented.

### Counting missingness

``` r
colSums(is.na(clinical))
```

    ## participant_id      age_years       sbp_mmhg   sex_recorded     study_site 
    ##              0              0              1              0              0

``` r
round(colMeans(is.na(clinical)) * 100, 1)
```

    ## participant_id      age_years       sbp_mmhg   sex_recorded     study_site 
    ##              0              0             20              0              0

The second expression gives the percentage of missing entries per
column.

------------------------------------------------------------------------

## 15.13 Dates: text is not a date

Dates frequently appear as text in research files. We must specify their
format.

``` r
date_text <- c("2026-01-15", "2026-02-03", "2026-03-21")
dates <- as.Date(date_text, format = "%Y-%m-%d")
dates
```

    ## [1] "2026-01-15" "2026-02-03" "2026-03-21"

``` r
class(dates)
```

    ## [1] "Date"

The format codes are:

- `%Y`: four-digit year;
- `%m`: two-digit month;
- `%d`: two-digit day.

### Day–month–year input

``` r
dmy <- c("15/01/2026", "03/02/2026")
as.Date(dmy, format = "%d/%m/%Y")
```

    ## [1] "2026-01-15" "2026-02-03"

### Why ambiguous dates are dangerous

`03/04/2026` could mean 3 April or March 4, depending on convention. We
should not guess. The study’s collection system or codebook must
establish the intended format.

### A complete date import

``` r
visit_path <- file.path(raw_dir, "visits.csv")
writeLines(
  c("id,visit_date,sbp", "P1,15/01/2026,125", "P2,03/02/2026,142"),
  visit_path
)

visits <- read.csv(
  visit_path,
  colClasses = c("character", "character", "numeric"),
  stringsAsFactors = FALSE
)
visits$visit_date <- as.Date(visits$visit_date, format = "%d/%m/%Y")
str(visits)
```

    ## 'data.frame':    2 obs. of  3 variables:
    ##  $ id        : chr  "P1" "P2"
    ##  $ visit_date: Date, format: "2026-01-15" "2026-02-03"
    ##  $ sbp       : num  125 142

### Date arithmetic

``` r
visits$days_since_first <- as.numeric(
  visits$visit_date - min(visits$visit_date)
)
visits
```

    ##   id visit_date sbp days_since_first
    ## 1 P1 2026-01-15 125                0
    ## 2 P2 2026-02-03 142               19

For dates with times and time zones, we need additional care. A date
without a time zone is not equivalent to a timestamp.

------------------------------------------------------------------------

## 15.14 Exporting dates safely

CSV does not preserve the R `Date` class. We can explicitly format dates
as ISO 8601 (`YYYY-MM-DD`) text:

``` r
visits_export <- visits
visits_export$visit_date <- format(
  visits_export$visit_date, "%Y-%m-%d"
)

visits_export_path <- file.path(export_dir, "visits_iso.csv")
write.csv(visits_export, visits_export_path, row.names = FALSE)

visits_again <- read.csv(
  visits_export_path,
  colClasses = c("character", "character", "numeric", "numeric")
)
visits_again$visit_date <- as.Date(
  visits_again$visit_date, format = "%Y-%m-%d"
)
stopifnot(identical(visits$visit_date, visits_again$visit_date))
```

We must preserve the parsing convention in documentation or code.

------------------------------------------------------------------------

## 15.15 Decimal separators and numerical precision

In many files, `3.14` is a decimal number. In other locales, `3,14` may
represent the same quantity.

``` r
comma_decimal <- "3,14"
as.numeric(sub(",", ".", comma_decimal, fixed = TRUE))
```

    ## [1] 3.14

This substitution is suitable only when the source convention is known.
A comma might also be a thousands separator or a field delimiter.

### Floating-point representation

``` r
0.1 + 0.2
```

    ## [1] 0.3

``` r
isTRUE(all.equal(0.1 + 0.2, 0.3))
```

    ## [1] TRUE

Binary floating-point numbers do not represent every decimal fraction
exactly. When comparing imported numeric results, `all.equal()` is often
more appropriate than `identical()` if harmless rounding differences are
expected.

For identifiers and genomic coordinates, however, we should not apply
numerical tolerances that could hide genuine mismatches.

------------------------------------------------------------------------

## 15.16 Character encodings and international research data

Text encoding defines how characters are stored as bytes. UTF-8 is a
widely used interoperable choice.

``` r
encoding_path <- file.path(raw_dir, "labels_utf8.csv")
labels <- data.frame(
  id = c("S1", "S2"),
  label = c("Cortex", "Liver"),
  stringsAsFactors = FALSE
)
write.csv(labels, encoding_path,
          row.names = FALSE, fileEncoding = "UTF-8")

labels_read <- read.csv(
  encoding_path,
  fileEncoding = "UTF-8",
  stringsAsFactors = FALSE
)
labels_read
```

    ##   id  label
    ## 1 S1 Cortex
    ## 2 S2  Liver

The example uses ASCII-compatible labels so it is robust across systems.
In multilingual datasets, incorrectly specified encodings can corrupt
names, labels, and other text fields. We should verify the actual source
encoding rather than repeatedly trying conversions without a record.

------------------------------------------------------------------------

## 15.17 Reading gzip-compressed GWAS tables

Large GWAS summary-statistic tables are often distributed as `.tsv.gz`.
Base R can read gzip-compressed text.

Create a synthetic GWAS table:

``` r
gwas <- data.frame(
  CHROM = c("6", "6", "6", "1", "6", "6"),
  ID = c("rsA", "rsB", "rsC", "rsD", "rsE", "rsF"),
  POS = c(26295926, 31298240, 32626565, 1500000, 33794605, 29000000),
  A1 = c("A", "C", "G", "T", "A", "G"),
  A2 = c("G", "T", "A", "C", "C", "A"),
  BETA = c(0.05, -0.08, 0.12, 0.01, NA, 0.03),
  SE = c(0.01, 0.02, 0.02, 0.01, 0.02, 0),
  PVAL = c(2e-8, 3e-9, 5e-12, 0.30, NA, 1e-6),
  stringsAsFactors = FALSE
)

gwas_gz_path <- file.path(raw_dir, "synthetic_gwas.tsv.gz")
con_initial <- gzfile(gwas_gz_path, open = "wt")
write.table(
  gwas, con_initial,
  sep = "\t", row.names = FALSE, quote = FALSE,
  na = "NA"
)
close(con_initial)
```

The preceding direct-connection write is concise, but explicit
connection management is preferable when writing complex workflows. To
illustrate, create another compressed file with a managed connection:

``` r
gwas_gz_managed <- file.path(raw_dir, "synthetic_gwas_managed.tsv.gz")
con_write <- gzfile(gwas_gz_managed, open = "wt")
write.table(gwas, con_write, sep = "\t", row.names = FALSE,
            quote = FALSE, na = "NA")
close(con_write)

stopifnot(file.exists(gwas_gz_managed))
```

Read the file:

``` r
con_read <- gzfile(gwas_gz_managed, open = "rt")
gwas_imported <- read.delim(
  con_read,
  colClasses = c(
    CHROM = "character", ID = "character", POS = "numeric",
    A1 = "character", A2 = "character",
    BETA = "numeric", SE = "numeric", PVAL = "numeric"
  ),
  check.names = FALSE,
  comment.char = ""
)
close(con_read)

str(gwas_imported)
```

    ## 'data.frame':    6 obs. of  8 variables:
    ##  $ CHROM: chr  "6" "6" "6" "1" ...
    ##  $ ID   : chr  "rsA" "rsB" "rsC" "rsD" ...
    ##  $ POS  : num  26295926 31298240 32626565 1500000 33794605 ...
    ##  $ A1   : chr  "A" "C" "G" "T" ...
    ##  $ A2   : chr  "G" "T" "A" "C" ...
    ##  $ BETA : num  0.05 -0.08 0.12 0.01 NA 0.03
    ##  $ SE   : num  0.01 0.02 0.02 0.01 0.02 0
    ##  $ PVAL : num  2e-08 3e-09 5e-12 3e-01 NA ...

### Preview before full import

``` r
con_preview <- gzfile(gwas_gz_managed, open = "rt")
first_lines <- readLines(con_preview, n = 4, warn = FALSE)
close(con_preview)
first_lines
```

    ## [1] "CHROM\tID\tPOS\tA1\tA2\tBETA\tSE\tPVAL"    
    ## [2] "6\trsA\t26295926\tA\tG\t0.05\t0.01\t2e-08" 
    ## [3] "6\trsB\t31298240\tC\tT\t-0.08\t0.02\t3e-09"
    ## [4] "6\trsC\t32626565\tG\tA\t0.12\t0.02\t5e-12"

**Genome-build warning:** `POS` values cannot be interpreted without a
reference build (for example, hg19 or hg38). The numbers above are
synthetic teaching records; they are not a real GWAS dataset.

------------------------------------------------------------------------

## 15.18 Checking GWAS import validity

For a basic structural QC demonstration, we can test:

1.  Required columns exist.
2.  Variant IDs are not missing.
3.  Positions are positive integers.
4.  Standard errors are positive and finite.
5.  P-values lie between 0 and 1.
6.  Alleles are present.

``` r
required_gwas <- c("CHROM", "ID", "POS", "A1", "A2",
                   "BETA", "SE", "PVAL")
stopifnot(all(required_gwas %in% names(gwas_imported)))

qc <- data.frame(
  ID = gwas_imported$ID,
  valid_position = !is.na(gwas_imported$POS) &
    is.finite(gwas_imported$POS) &
    gwas_imported$POS > 0 &
    gwas_imported$POS == floor(gwas_imported$POS),
  valid_se = !is.na(gwas_imported$SE) &
    is.finite(gwas_imported$SE) &
    gwas_imported$SE > 0,
  valid_p = !is.na(gwas_imported$PVAL) &
    is.finite(gwas_imported$PVAL) &
    gwas_imported$PVAL >= 0 &
    gwas_imported$PVAL <= 1
)

qc$pass <- qc$valid_position & qc$valid_se & qc$valid_p
qc
```

    ##    ID valid_position valid_se valid_p  pass
    ## 1 rsA           TRUE     TRUE    TRUE  TRUE
    ## 2 rsB           TRUE     TRUE    TRUE  TRUE
    ## 3 rsC           TRUE     TRUE    TRUE  TRUE
    ## 4 rsD           TRUE     TRUE    TRUE  TRUE
    ## 5 rsE           TRUE     TRUE   FALSE FALSE
    ## 6 rsF           TRUE    FALSE    TRUE FALSE

A full GWAS pipeline additionally needs allele harmonization, strand
handling, imputation-quality checks, sample-size assessment, variant
normalization, genome-build reconciliation, and other study-specific
requirements. A valid file import is only the first step.

------------------------------------------------------------------------

## 15.19 Importing only selected columns

A summary-statistics file may contain many fields, but a specific
analysis needs only a subset. In base R, `colClasses = "NULL"` can omit
selected columns during parsing.

``` r
small_tsv <- file.path(raw_dir, "synthetic_gwas.tsv")
write.table(gwas, small_tsv, sep = "\t", row.names = FALSE,
            quote = FALSE, na = "NA")

selected_gwas <- read.delim(
  small_tsv,
  colClasses = c(
    CHROM = "character", ID = "character", POS = "numeric",
    A1 = "NULL", A2 = "NULL", BETA = "numeric",
    SE = "numeric", PVAL = "numeric"
  ),
  check.names = FALSE
)
names(selected_gwas)
```

    ## [1] "CHROM" "ID"    "POS"   "BETA"  "SE"    "PVAL"

This reduces the number of stored columns. It does not automatically
make a multi-gigabyte dataset small enough for a limited-memory
computer.

### Reading only a preview

``` r
preview_gwas <- read.delim(
  small_tsv, nrows = 3,
  stringsAsFactors = FALSE,
  check.names = FALSE
)
preview_gwas
```

    ##   CHROM  ID      POS A1 A2  BETA   SE  PVAL
    ## 1     6 rsA 26295926  A  G  0.05 0.01 2e-08
    ## 2     6 rsB 31298240  C  T -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  G  A  0.12 0.02 5e-12

### A note about memory

Compressed disk size is not the same as in-memory data-frame size. R
also needs memory for parsing and intermediate objects. We should assess
file sizes, row counts, and available RAM before full import.

------------------------------------------------------------------------

## 15.20 RDS: preserving R-specific structure

CSV and TSV preserve table values but generally do not preserve all R
attributes and classes. RDS stores a single R object.

``` r
clinical$study_site <- factor(
  clinical$study_site,
  levels = c("North", "South", "East")
)

clinical_rds_path <- file.path(clean_dir, "clinical_typed.rds")
saveRDS(clinical, clinical_rds_path)
clinical_rds <- readRDS(clinical_rds_path)

stopifnot(identical(clinical, clinical_rds))
levels(clinical_rds$study_site)
```

    ## [1] "North" "South" "East"

RDS is useful for R-to-R workflows. CSV and TSV remain valuable when
collaborators use other software.

### `save()` and `load()`

`save()` can store multiple named objects in an `.RData` file. `load()`
restores those names, so it is safer to load into a separate environment
if name collisions are possible.

``` r
objects_path <- file.path(clean_dir, "chapter15_objects.RData")
save(clinical, dictionary, file = objects_path)

isolated <- new.env(parent = baseenv())
loaded_names <- load(objects_path, envir = isolated)
loaded_names
```

    ## [1] "clinical"   "dictionary"

------------------------------------------------------------------------

## 15.21 Export options and what they preserve

| Format | Interoperability | R classes and attributes | Typical use |
|----|----|----|----|
| CSV | High | Generally not preserved | Exchange of rectangular tables |
| TSV | High | Generally not preserved | Genomic summary statistics |
| RDS | Primarily R | Preserved for many R objects | Internal intermediate objects |
| `.RData` | Primarily R | Preserved for saved objects | Multiple R objects |
| Plain text | High | No structured table metadata | Gene lists, notes, manifests |

There is no universally best format. We choose according to the
recipient, intended reuse, metadata requirements, and dataset size.

------------------------------------------------------------------------

## 15.22 Designing a clean export

A useful exported dataset should include:

- meaningful column names;
- stable participant or variant identifiers;
- clearly defined units;
- documented missing-value representation;
- consistent dates;
- a version or creation date in accompanying metadata;
- a data dictionary;
- a description of transformations applied.

Create a cleaned table and export it:

``` r
clinical_clean <- clinical
clinical_clean$sbp_screen <- ifelse(
  is.na(clinical_clean$sbp_mmhg),
  "Missing",
  ifelse(clinical_clean$sbp_mmhg >= 140,
         "Review", "Below threshold")
)

clean_csv_path <- file.path(clean_dir, "clinical_clean.csv")
write.csv(clinical_clean, clean_csv_path,
          row.names = FALSE, na = "")
file.exists(clean_csv_path)
```

    ## [1] TRUE

The 140 mmHg threshold is an **illustrative study-screening rule**, not
a diagnosis.

------------------------------------------------------------------------

## 15.23 The round-trip test

A **round trip** means exporting an object and importing it again. We
then compare the result with the intended representation.

``` r
roundtrip <- read.csv(
  clean_csv_path,
  colClasses = c(
    participant_id = "character",
    age_years = "numeric",
    sbp_mmhg = "numeric",
    sex_recorded = "character",
    study_site = "character",
    sbp_screen = "character"
  ),
  na.strings = c("", "NA"),
  check.names = FALSE
)

stopifnot(
  identical(as.character(clinical_clean$participant_id),
            roundtrip$participant_id),
  isTRUE(all.equal(clinical_clean$sbp_mmhg,
                   roundtrip$sbp_mmhg)),
  identical(as.character(clinical_clean$study_site),
            roundtrip$study_site),
  identical(clinical_clean$sbp_screen,
            roundtrip$sbp_screen)
)
```

We compare the **intended values**, not the factor attributes that CSV
cannot preserve. For exact R object fidelity, the RDS round trip is more
appropriate.

### Why `identical()` can be too strict for numbers

`identical()` also compares storage types and attributes. `all.equal()`
is often preferable for numerical equivalence when tiny floating-point
differences are acceptable. We should not apply tolerances to
identifiers or genomic positions.

------------------------------------------------------------------------

## 15.24 A practical import-validation function

We will build a reusable function that checks the file path, required
columns, and identifier integrity.

``` r
import_study_csv <- function(path, required, id_col,
                             col_classes = NA) {
  if (!is.character(path) || length(path) != 1L ||
      is.na(path) || !nzchar(path)) {
    stop("path must be one nonempty character string.")
  }
  if (!file.exists(path)) {
    stop("Input file not found: ", path)
  }
  if (!is.character(required) || !is.character(id_col) ||
      length(id_col) != 1L || is.na(id_col)) {
    stop("required and id_col must be valid character inputs.")
  }

  dat <- read.csv(
    path,
    colClasses = col_classes,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  missing_columns <- setdiff(c(required, id_col), names(dat))
  if (length(missing_columns) > 0L) {
    stop("Missing required columns: ",
         paste(missing_columns, collapse = ", "))
  }
  if (anyNA(dat[[id_col]]) || any(!nzchar(as.character(dat[[id_col]])))) {
    stop("Missing or empty study identifiers detected.")
  }
  if (anyDuplicated(dat[[id_col]]) > 0L) {
    stop("Duplicate study identifiers detected.")
  }

  dat
}
```

Use it:

``` r
validated_clinical <- import_study_csv(
  clinical_path,
  required = c("age_years", "sbp_mmhg", "study_site"),
  id_col = "participant_id",
  col_classes = c(
    participant_id = "character",
    age_years = "numeric",
    sbp_mmhg = "numeric",
    sex_recorded = "character",
    study_site = "character"
  )
)

nrow(validated_clinical)
```

    ## [1] 5

### Why errors are helpful

A script that silently proceeds after detecting duplicate IDs can
generate invalid joins, inflated sample sizes, or incorrect longitudinal
comparisons. Stopping with an informative message can be safer than
producing a plausible but wrong result.

------------------------------------------------------------------------

## 15.25 Detecting duplicates and composite keys

In a cross-sectional dataset, one row per participant may be expected.
In longitudinal research, several rows per participant may be correct.

``` r
longitudinal <- data.frame(
  id = c("P1", "P1", "P2", "P2"),
  visit = c("Baseline", "Followup", "Baseline", "Followup"),
  sbp = c(150, 140, 135, 130),
  stringsAsFactors = FALSE
)

anyDuplicated(longitudinal$id)
```

    ## [1] 2

The participant IDs repeat by design. We can check uniqueness of the
**participant–visit pair**:

``` r
composite_key <- paste(longitudinal$id,
                       longitudinal$visit, sep = "::")
anyDuplicated(composite_key)
```

    ## [1] 0

For production data, we should ensure that the chosen separator cannot
create ambiguous composite keys, or use an explicit multi-column
duplicate check:

``` r
any(duplicated(longitudinal[c("id", "visit")]))
```

    ## [1] FALSE

The second method checks the pair directly and is generally preferable.

------------------------------------------------------------------------

## 15.26 Validation of scientific ranges and categories

A valid import should satisfy study-defined constraints.

``` r
range_checks <- data.frame(
  participant_id = clinical$participant_id,
  age_valid = !is.na(clinical$age_years) &
    clinical$age_years >= 0 & clinical$age_years <= 120,
  sbp_valid = is.na(clinical$sbp_mmhg) |
    (clinical$sbp_mmhg > 0 & clinical$sbp_mmhg < 350),
  site_valid = as.character(clinical$study_site) %in%
    c("North", "South", "East")
)
range_checks
```

    ##   participant_id age_valid sbp_valid site_valid
    ## 1            001      TRUE      TRUE       TRUE
    ## 2            002      TRUE      TRUE       TRUE
    ## 3            003      TRUE      TRUE       TRUE
    ## 4            004      TRUE      TRUE       TRUE
    ## 5            005      TRUE      TRUE       TRUE

The numerical limits are **illustrative plausibility checks**, not
universal clinical cutoffs. They must be chosen from the study protocol,
data dictionary, and measurement context.

### Summarize failures

``` r
validation_summary <- data.frame(
  rule = c("age_valid", "sbp_valid", "site_valid"),
  n_failed = c(
    sum(!range_checks$age_valid),
    sum(!range_checks$sbp_valid),
    sum(!range_checks$site_valid)
  )
)
validation_summary
```

    ##         rule n_failed
    ## 1  age_valid        0
    ## 2  sbp_valid        0
    ## 3 site_valid        0

We can save this report alongside processed data.

``` r
validation_path <- file.path(export_dir, "validation_summary.csv")
write.csv(validation_summary, validation_path, row.names = FALSE)
```

------------------------------------------------------------------------

## 15.27 Cross-field consistency checks

Some values are individually plausible but jointly inconsistent. For
example, a follow-up visit date should generally not precede baseline if
those labels are defined chronologically.

``` r
visits_wide <- data.frame(
  id = c("P1", "P2", "P3"),
  baseline = as.Date(c("2026-01-01", "2026-02-01", "2026-03-01")),
  followup = as.Date(c("2026-01-15", "2026-01-20", "2026-03-15"))
)

visits_wide$chronology_valid <-
  visits_wide$followup >= visits_wide$baseline

visits_wide
```

    ##   id   baseline   followup chronology_valid
    ## 1 P1 2026-01-01 2026-01-15             TRUE
    ## 2 P2 2026-02-01 2026-01-20            FALSE
    ## 3 P3 2026-03-01 2026-03-15             TRUE

Participant `P2` has a follow-up date before baseline. This may indicate
a data-entry error, a label error, or an unusual study process. We
should flag it for investigation rather than automatically changing the
dates.

------------------------------------------------------------------------

## 15.28 Importing multiple study files

Suppose three sites provide CSV files with the same schema.

``` r
site_A <- data.frame(id = c("A1", "A2"), sbp = c(125, 145))
site_B <- data.frame(id = c("B1", "B2", "B3"), sbp = c(NA, 151, 137))
site_C <- data.frame(id = "C1", sbp = 160)

site_paths <- file.path(raw_dir,
                        c("site_A.csv", "site_B.csv", "site_C.csv"))
write.csv(site_A, site_paths[1], row.names = FALSE)
write.csv(site_B, site_paths[2], row.names = FALSE)
write.csv(site_C, site_paths[3], row.names = FALSE)
```

Import with a loop, validating the schema before combining:

``` r
site_tables <- vector("list", length(site_paths))
names(site_tables) <- c("Site_A", "Site_B", "Site_C")

for (i in seq_along(site_paths)) {
  dat <- read.csv(
    site_paths[i],
    colClasses = c(id = "character", sbp = "numeric")
  )
  stopifnot(identical(names(dat), c("id", "sbp")))
  dat$site <- names(site_tables)[i]
  site_tables[[i]] <- dat
}

combined_sites <- do.call(rbind, site_tables)
row.names(combined_sites) <- NULL
combined_sites
```

    ##   id sbp   site
    ## 1 A1 125 Site_A
    ## 2 A2 145 Site_A
    ## 3 B1  NA Site_B
    ## 4 B2 151 Site_B
    ## 5 B3 137 Site_B
    ## 6 C1 160 Site_C

### Check row counts

``` r
expected_rows <- sum(vapply(site_tables, nrow, integer(1)))
stopifnot(nrow(combined_sites) == expected_rows)
```

### What if schemas differ?

We should **not** automatically merge incompatible columns or silently
discard information. A documented harmonization step is required if
sites use different units, variable names, or category codes.

------------------------------------------------------------------------

## 15.29 Import manifests and provenance

A **manifest** records the exact files that entered an analysis.

``` r
manifest <- data.frame(
  file_name = basename(site_paths),
  bytes = as.numeric(file.info(site_paths)$size),
  modified = as.character(file.info(site_paths)$mtime),
  md5 = unname(as.character(tools::md5sum(site_paths))),
  stringsAsFactors = FALSE
)
manifest
```

    ##    file_name bytes                   modified                              md5
    ## 1 site_A.csv    32 2026-10-24 11:11:44.413521 e52c55f5271fed8d754755a41e4e4db3
    ## 2 site_B.csv    41 2026-10-24 11:11:44.414528 843089a1745fd0c3aa295775ebaa9a6d
    ## 3 site_C.csv    22 2026-10-24 11:11:44.416439 dcd944ca44d1e708c507b42ad2ca8f54

Export the manifest:

``` r
manifest_path <- file.path(export_dir, "input_manifest.csv")
write.csv(manifest, manifest_path, row.names = FALSE)
```

Checksums are useful for detecting accidental file changes. MD5 is not
suitable for security-sensitive authentication against malicious
tampering.

For a real genomics project, the manifest should also identify the
source accession or URL, download date, release version, genome build,
and any licensing or access restrictions.

------------------------------------------------------------------------

## 15.30 Safe output filenames and overwrite prevention

A common mistake is writing processed results back to the raw input
filename.

We can make this harder by using separate directories and checking
before export.

``` r
safe_output <- file.path(export_dir, "combined_sites.csv")

if (file.exists(safe_output)) {
  message("Practice output already exists; overwriting this disposable file.")
}
write.csv(combined_sites, safe_output, row.names = FALSE)
```

In a real research pipeline, overwriting may be prohibited or require an
explicit versioning policy. The example writes only within our
disposable temporary workspace.

### Example of a no-overwrite policy

``` r
write_csv_no_overwrite <- function(dat, path) {
  if (file.exists(path)) {
    stop("Output already exists: ", path)
  }
  if (!dir.exists(dirname(path))) {
    stop("Output directory does not exist: ", dirname(path))
  }
  write.csv(dat, path, row.names = FALSE, na = "")
  invisible(path)
}

new_output <- file.path(export_dir, "new_export_only.csv")
write_csv_no_overwrite(combined_sites, new_output)
stopifnot(file.exists(new_output))
```

For concurrent production workflows, existence checks alone do not
guarantee atomic writes; more robust file-management procedures may be
needed.

------------------------------------------------------------------------

## 15.31 Common import failures and how to diagnose them

### All values appear in one column

The separator may be wrong. Inspect the first lines with `readLines()`
and choose `read.csv()`, `read.delim()`, or the appropriate `sep`.

### A numeric column becomes character

Unexpected text, decimal separators, or missing codes may be present.
Inspect unique nonnumeric entries before conversion.

### Leading zeros disappear

The identifier was parsed as numeric. Re-import it as character.

### Dates are wrong or missing

The date format may not match the source. Check whether the file uses
day–month–year or month–day–year conventions.

### Factor values become numbers

`as.numeric(factor_column)` returns internal codes. Convert labels
explicitly when appropriate.

### Column names change

R may sanitize headers. Use `check.names = FALSE` when preserving the
source schema matters.

### `cannot open the connection`

Check path existence, permissions, open connections, and whether the
parent directory exists.

### Rows appear shifted

The file may contain embedded delimiters, malformed quotation marks, or
inconsistent field counts.

### A file imports but results are implausible

Verify units, coding conventions, reference build, missing codes, and
sample identity. A technically valid import is not sufficient.

### Knitting fails while interactive execution succeeds

The script may depend on a different working directory or objects left
in the interactive environment. Use explicit paths and create all
required inputs in the document.

------------------------------------------------------------------------

## 15.32 Guided practical: a complete epidemiological import pipeline

We will import a synthetic cohort, validate identifiers and values,
derive BMI and a screening category, save results, and verify the
export.

### Step 1: create source data

``` r
epi_source <- data.frame(
  id = c("E001", "E002", "E003", "E004", "E005"),
  age = c(35, 48, 59, 42, 64),
  weight_kg = c(65, 82, 74, 70, 88),
  height_m = c(1.65, 1.75, 1.70, 1.68, 1.78),
  sbp = c(120, 151, NA, 144, 138),
  stringsAsFactors = FALSE
)

epi_source_path <- file.path(raw_dir, "epi_source.csv")
write.csv(epi_source, epi_source_path, row.names = FALSE, na = "")
```

### Step 2: import with types

``` r
epi <- read.csv(
  epi_source_path,
  colClasses = c(
    id = "character", age = "numeric",
    weight_kg = "numeric", height_m = "numeric",
    sbp = "numeric"
  ),
  na.strings = c("", "NA")
)
```

### Step 3: validate

``` r
stopifnot(
  nrow(epi) == 5L,
  !anyNA(epi$id),
  !anyDuplicated(epi$id),
  all(epi$height_m > 0),
  all(epi$weight_kg > 0),
  all(epi$age >= 0)
)
```

### Step 4: derive variables

``` r
epi$bmi <- epi$weight_kg / epi$height_m^2
epi$sbp_status <- ifelse(
  is.na(epi$sbp), "Missing",
  ifelse(epi$sbp >= 140, "Review", "Below threshold")
)
epi
```

    ##     id age weight_kg height_m sbp      bmi      sbp_status
    ## 1 E001  35        65     1.65 120 23.87511 Below threshold
    ## 2 E002  48        82     1.75 151 26.77551          Review
    ## 3 E003  59        74     1.70  NA 25.60554         Missing
    ## 4 E004  42        70     1.68 144 24.80159          Review
    ## 5 E005  64        88     1.78 138 27.77427 Below threshold

### Step 5: export CSV and RDS

``` r
epi_csv_path <- file.path(clean_dir, "epi_processed.csv")
epi_rds_path <- file.path(clean_dir, "epi_processed.rds")
write.csv(epi, epi_csv_path, row.names = FALSE, na = "")
saveRDS(epi, epi_rds_path)
```

### Step 6: re-import and verify

``` r
epi_restored <- readRDS(epi_rds_path)
stopifnot(identical(epi, epi_restored))

epi_csv_restored <- read.csv(
  epi_csv_path,
  colClasses = c(
    id = "character", age = "numeric",
    weight_kg = "numeric", height_m = "numeric",
    sbp = "numeric", bmi = "numeric",
    sbp_status = "character"
  )
)

stopifnot(
  identical(epi$id, epi_csv_restored$id),
  isTRUE(all.equal(epi$bmi, epi_csv_restored$bmi)),
  identical(epi$sbp_status, epi_csv_restored$sbp_status)
)
```

### Step 7: write a summary

``` r
epi_summary <- data.frame(
  n_total = nrow(epi),
  n_missing_sbp = sum(is.na(epi$sbp)),
  n_review = sum(epi$sbp_status == "Review"),
  mean_bmi = mean(epi$bmi)
)
epi_summary
```

    ##   n_total n_missing_sbp n_review mean_bmi
    ## 1       5             1        2  25.7664

``` r
write.csv(
  epi_summary,
  file.path(export_dir, "epi_summary.csv"),
  row.names = FALSE
)
```

### Interpretation

We have implemented a reproducible pipeline from raw file to verified
export. The screening label is descriptive and study-defined; it is not
a medical diagnosis or evidence of a causal relationship.

------------------------------------------------------------------------

## 15.33 Independent exercises: foundational import skills

1.  Explain the difference between importing, parsing, validation, and
    cleaning.
2.  Create a CSV file with five synthetic participants.
3.  Import it using `read.csv()` and inspect `str()`.
4.  Preserve a participant ID such as `"0007"` as character.
5.  Export and import a TSV version of the same table.
6.  Create a semicolon-separated file using a comma decimal mark and
    import it correctly.
7.  Explain why manually splitting CSV rows on commas can fail.
8.  Preserve an unusual column name with `check.names = FALSE`.
9.  Explain how to detect unexpected character values in a numeric
    column.
10. Explain why a successful import may still contain scientifically
    invalid data.
11. Save a data frame as RDS and restore it.
12. Compare a CSV round trip with an RDS round trip.

## 15.34 Independent exercises: data dictionaries and missingness

1.  Construct a data dictionary for a clinical table containing ID, age,
    BMI, SBP, and study site.
2.  Record types, units, allowed values, and missing codes.
3.  Import a file containing `"N/A"` as a documented missing code.
4.  Recode a documented sentinel value of `999` to `NA` for one
    specified variable.
5.  Explain why the same value should not automatically be recoded in
    every variable.
6.  Calculate the percentage of missing values in each column.
7.  Identify duplicate participant IDs.
8.  Explain why repeated participant IDs may be valid in longitudinal
    data.
9.  Check uniqueness of participant–visit pairs.
10. Create a report of invalid age and SBP values using study-defined
    ranges.

## 15.35 Independent exercises: dates and numerical parsing

1.  Import dates stored as `YYYY-MM-DD`.
2.  Import dates stored as `DD/MM/YYYY`.
3.  Explain why `03/04/2026` is ambiguous without documentation.
4.  Calculate days between two visits.
5.  Export dates in ISO format and re-import them.
6.  Explain the difference between a `Date` and a timestamp.
7.  Explain why `as.numeric()` on a factor can be misleading.
8.  Compare two floating-point results with `all.equal()`.
9.  Explain why numerical tolerance is inappropriate for exact
    participant IDs.
10. Explain how a wrong decimal separator can affect statistical
    results.

## 15.36 Independent exercises: GWAS summary-statistic files

Using a synthetic table containing `CHROM`, `ID`, `POS`, `A1`, `A2`,
`BETA`, `SE`, and `PVAL`:

1.  Export it as TSV.
2.  Create a gzip-compressed version.
3.  Preview the first four lines without reading the whole table.
4.  Import the compressed table with explicit column types.
5.  Preserve chromosome labels as character.
6.  Verify the required columns.
7.  Flag nonpositive standard errors.
8.  Flag p-values outside the interval 0–1.
9.  Flag missing effect sizes.
10. Select chromosome 6 variants within a documented coordinate
    interval.
11. Save the selected records to a processed-data folder.
12. Record a checksum and a manifest.
13. Explain why genome build and allele orientation must be documented.
14. Explain why a structurally valid table is not yet a harmonized GWAS
    dataset.

## 15.37 Challenge: a reproducible multi-site research exchange

Build a base-R pipeline that:

1.  Creates three synthetic site-level CSV files.
2.  Gives every participant a character identifier with leading zeros.
3.  Includes at least one missing value and one documented missing
    sentinel.
4.  Uses a data dictionary to define each column.
5.  Imports each file with explicit types.
6.  Validates identifiers, missingness, and allowed ranges.
7.  Flags rather than silently fixes scientifically questionable
    records.
8.  Combines only compatible schemas.
9.  Produces a site-level summary table.
10. Saves a cleaned CSV and an RDS copy.
11. Re-imports both outputs and verifies key values.
12. Writes a manifest with filenames, sizes, and checksums.
13. Produces a brief text report documenting assumptions and
    limitations.
14. Ensures raw files remain unchanged.

**Advanced extension:** Create a deliberately malformed site file and
test whether the pipeline stops with a useful error message.

------------------------------------------------------------------------

## 15.38 Complete standalone practice script

The following script summarizes the core techniques and can be copied
into a separate `.R` file. It is not executed during knitting because
the examples above have already created their inputs.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 15: Importing and Exporting Research Data
# Base R only; synthetic data
# ============================================================

root <- file.path(tempdir(), "chapter15_standalone")
raw <- file.path(root, "raw")
clean <- file.path(root, "clean")
results <- file.path(root, "results")

for (folder in c(raw, clean, results)) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

source <- data.frame(
  id = c("001", "002", "003"),
  age = c(35, 48, 61),
  sbp = c(120, NA, 150),
  weight_kg = c(65, 82, 74),
  height_m = c(1.65, 1.75, 1.70),
  stringsAsFactors = FALSE
)

raw_path <- file.path(raw, "cohort.csv")
write.csv(source, raw_path, row.names = FALSE, na = "")

cohort <- read.csv(
  raw_path,
  colClasses = c(
    id = "character", age = "numeric", sbp = "numeric",
    weight_kg = "numeric", height_m = "numeric"
  ),
  na.strings = c("", "NA")
)

stopifnot(
  !anyDuplicated(cohort$id),
  !anyNA(cohort$id),
  all(cohort$height_m > 0)
)

cohort$bmi <- cohort$weight_kg / cohort$height_m^2
cohort$sbp_status <- ifelse(
  is.na(cohort$sbp), "Missing",
  ifelse(cohort$sbp >= 140, "Review", "Below threshold")
)

csv_path <- file.path(clean, "cohort_processed.csv")
rds_path <- file.path(clean, "cohort_processed.rds")
write.csv(cohort, csv_path, row.names = FALSE, na = "")
saveRDS(cohort, rds_path)

restored <- readRDS(rds_path)
stopifnot(identical(cohort, restored))

summary <- data.frame(
  n = nrow(cohort),
  missing_sbp = sum(is.na(cohort$sbp)),
  review = sum(cohort$sbp_status == "Review")
)
write.csv(summary, file.path(results, "summary.csv"),
          row.names = FALSE)

manifest <- data.frame(
  filename = basename(raw_path),
  bytes = as.numeric(file.info(raw_path)$size),
  md5 = unname(as.character(tools::md5sum(raw_path)))
)
write.csv(manifest, file.path(results, "manifest.csv"),
          row.names = FALSE)

print(summary)
print(manifest)
print(R.version.string)
```

------------------------------------------------------------------------

## 15.39 Essential functions reference

| Function | Main purpose |
|----|----|
| `read.csv()` | Import comma-separated tables |
| `read.csv2()` | Import semicolon-separated tables with comma decimal convention |
| `read.delim()` | Import tab-separated tables |
| `read.table()` | General delimited-text reader |
| `write.csv()` | Export CSV |
| `write.table()` | Export a delimited table |
| `readLines()` | Preview or read plain-text lines |
| `writeLines()` | Write text lines |
| `gzfile()` | Open gzip-compressed text connections |
| `close()` | Close an open connection |
| `str()` | Inspect object structure |
| `class()` | Inspect an object’s class |
| `typeof()` | Inspect storage type |
| `colSums(is.na(...))` | Count missing values by column |
| `colMeans(is.na(...))` | Calculate missingness proportions |
| `as.Date()` | Parse dates with a specified format |
| `format()` | Convert dates to documented text formats |
| `factor()` | Construct categorical variables with levels |
| `as.character()` | Convert values to text |
| `as.numeric()` | Convert values to numeric where appropriate |
| `anyDuplicated()` | Find the first duplicate position |
| `duplicated()` | Identify duplicate records |
| `setdiff()` | Find required fields that are absent |
| `stopifnot()` | Assert expected conditions |
| `saveRDS()` | Save one R object |
| `readRDS()` | Restore one R object |
| `save()` | Save multiple named objects |
| `load()` | Restore named objects |
| `tools::md5sum()` | Calculate file checksums |
| `file.info()` | Inspect file metadata |
| `all.equal()` | Check numerical equivalence |

## 15.40 Chapter review

We should now be able to answer:

1.  Why is importing different from validating?
2.  What can go wrong when identifiers are parsed as numbers?
3.  How do we select the correct delimiter?
4.  What does `colClasses` control?
5.  Why should missing-value codes be documented?
6.  How do we preserve leading zeros?
7.  Why should dates be parsed with explicit formats?
8.  Why can `as.numeric(factor)` be misleading?
9.  What does CSV quoting protect?
10. How can we import gzip-compressed TSV data in base R?
11. Why might a compressed file require much more RAM than its disk
    size?
12. What is the difference between CSV and RDS?
13. Why is a round-trip test useful?
14. How can we validate uniqueness in longitudinal data?
15. What is a data dictionary?
16. Why are units and allowed ranges part of validation?
17. Why should raw files remain unchanged?
18. How can a manifest support reproducibility?
19. Why is genome-build metadata necessary for GWAS positions?
20. Why should we stop a pipeline when required columns are missing?

## 15.41 Key takeaways

- Importing a table successfully does **not** guarantee scientific
  correctness.
- Inspect source files and data dictionaries before choosing parsing
  options.
- Preserve identifiers as character and specify types where practical.
- Missing-value codes must be interpreted using documented rules.
- Dates require explicit formats and careful handling of ambiguity.
- CSV and TSV support exchange; RDS preserves R object structure.
- Validate required columns, identifiers, types, ranges, categories, and
  cross-field consistency.
- Preserve raw inputs, export cleaned results separately, and verify
  important round trips.
- Record file provenance, versions, and transformation rules.
- For genomic data, verify genome build, alleles, and QC requirements
  before downstream analysis.

> A reproducible research dataset is not merely a file that R can read.
> It is a file whose structure, meaning, transformations, and
> limitations are explicitly documented and checked.

## 15.42 Looking ahead: Chapter 16 — Data Cleaning and Quality Control in R

Now that we can import and export research data reliably, we will turn
to **systematic data cleaning and quality control**. Chapter 16 will
address duplicates, inconsistent categories, missingness patterns,
outliers, data-validation rules, audit trails, and scientifically
defensible cleaning decisions for biomedical and genomic datasets.
