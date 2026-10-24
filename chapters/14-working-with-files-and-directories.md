Chapter 14 — Working with Files and Directories in R
================
Sandeep Kumar Singh, PhD

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

In Chapters 1–13, we learned how to create R objects, manipulate data
structures, make decisions, write loops, build functions, and use the
apply family. We can now analyze objects already in memory. However,
most biomedical and genomic research begins with **data stored in
files** and ends with **results that must be saved**.

A reproducible workflow must answer several practical questions:

- Where are our input files?
- How can we find them without repeatedly typing absolute paths?
- How do we import a clinical table, an epidemiological dataset, or GWAS
  summary statistics?
- How can we distinguish a comma-separated file from a tab-separated
  file?
- How do we save results without accidentally overwriting raw data?
- How do we organize a project so that the same script works on another
  computer?
- What happens when a file is missing, empty, incorrectly encoded, or
  malformed?

This chapter develops those skills from first principles, using **base R
only**. It is written for Windows and other operating systems, with
examples relevant to clinical research, epidemiology, and statistical
genomics.

**Important:** Every executable example uses small, **synthetic data**.
The chapter creates a dedicated temporary practice directory using
`tempdir()`; it does not modify real research files. Paths printed
during knitting will differ between systems.

## 14.1 Learning objectives

After this chapter, we should be able to:

1.  Explain the difference between an R object, a file, a folder, and a
    file path.
2.  Inspect the working directory using `getwd()` and understand
    `setwd()`.
3.  Distinguish absolute and relative paths.
4.  Build cross-platform paths with `file.path()`.
5.  Create, inspect, and remove practice directories safely.
6.  List files using `list.files()` and `list.dirs()`.
7.  Test paths with `file.exists()` and `dir.exists()`.
8.  Read and write CSV and tab-separated text files.
9.  Understand headers, separators, missing values, quotes, and
    encodings.
10. Import compressed text files using base R.
11. Save and restore R objects using RDS and `.RData`.
12. Use `readLines()` and `writeLines()` for plain text.
13. Process multiple files with loops.
14. Validate imported tables before analysis.
15. Design a safe and reproducible research folder structure.
16. Recognize security and privacy concerns when handling biomedical
    data.

------------------------------------------------------------------------

## 14.2 Four concepts we must distinguish

**An R object** exists in an R session’s memory. For example:

``` r
ages <- c(25, 38, 51)
ages
```

    ## [1] 25 38 51

**A file** is stored on a filesystem, such as `patients.csv`.

**A directory** (folder) organizes files and other directories.

**A path** tells the operating system where to find a file or directory.

For example, the path `data/raw/patients.csv` identifies a file named
`patients.csv` inside `raw`, which is inside `data`.

An object does not automatically become a file merely because it has a
name in R. We must explicitly save it.

### Why this matters

A research script may run successfully today because an object exists in
the interactive Environment pane, yet fail tomorrow in a fresh R
session. Reproducible scripts must explicitly load or create every
required object.

------------------------------------------------------------------------

## 14.3 The working directory

The **working directory** is the default location R uses when we provide
a relative path.

``` r
getwd()
```

    ## [1] "E:/Github_Classes/R for Everyone/R-for-Everyone/chapters"

The output is specific to the current computer and knitting environment.

We can inspect the files in that directory:

``` r
head(list.files(), 10)
```

    ##  [1] "01-introduction-to-r.html"                      
    ##  [2] "01-introduction-to-r.md"                        
    ##  [3] "01-introduction-to-r.Rmd"                       
    ##  [4] "01-introduction-to-r_files"                     
    ##  [5] "02-objects-variables-data-types.md"             
    ##  [6] "02-objects-variables-data-types.Rmd"            
    ##  [7] "03-operators-expressions-logical-conditions.md" 
    ##  [8] "03-operators-expressions-logical-conditions.Rmd"
    ##  [9] "04-vectors-foundation-of-r.md"                  
    ## [10] "04-vectors-foundation-of-r.Rmd"

### `setwd()`

The command `setwd("path")` changes the working directory.

``` r
setwd("C:/Research/MyProject")
```

This example is **not executed** because that path may not exist.

### Why we should avoid frequent `setwd()` calls

Repeatedly changing the working directory makes scripts harder to
reproduce. A script that works only when run from a particular
computer-specific location is fragile.

For a well-organized project, we usually prefer **project-relative
paths**, constructed from a stable project root.

### RStudio projects

An RStudio project (`.Rproj`) helps keep related scripts and data
together. When a project is opened, RStudio generally sets its working
directory to the project folder. However, knitting, sourcing, and
running scripts interactively can have different directory behavior
depending on configuration. We should verify with `getwd()` rather than
assume.

------------------------------------------------------------------------

## 14.4 Absolute versus relative paths

An **absolute path** identifies a location from the filesystem root.

Windows example:

``` text
C:/Research/SCZ_Project/data/raw/variants.tsv
```

Linux or WSL example:

``` text
/home/research/SCZ_Project/data/raw/variants.tsv
```

A **relative path** is interpreted from a starting directory, commonly
the working directory:

``` text
data/raw/variants.tsv
```

### Why relative paths are useful

If our project is moved from one computer to another, a relative path
can continue working as long as the folder structure is preserved and
the project root is correctly established.

### Windows path separators

Windows commonly displays backslashes:

``` text
C:\Research\Project\data\patients.csv
```

In R character strings, backslash is an escape character. The following
is **not** a safe way to write an ordinary Windows path:

``` r
# Not recommended:
# "C:\Research\Project\data\patients.csv"
```

We can use forward slashes instead:

``` r
"C:/Research/Project/data/patients.csv"
```

Or escaped backslashes:

``` r
"C:\\Research\\Project\\data\\patients.csv"
```

For portable code, we will normally use `file.path()`.

------------------------------------------------------------------------

## 14.5 Building paths with `file.path()`

Instead of manually joining strings:

``` r
file.path("data", "raw", "patients.csv")
```

    ## [1] "data/raw/patients.csv"

R uses the appropriate path convention for the current operating system.

We can construct multiple paths:

``` r
file.path("results", c("table1.csv", "table2.csv"))
```

    ## [1] "results/table1.csv" "results/table2.csv"

### `basename()` and `dirname()`

``` r
example_path <- file.path("data", "raw", "patients.csv")

basename(example_path)
```

    ## [1] "patients.csv"

``` r
dirname(example_path)
```

    ## [1] "data/raw"

- `basename()` extracts the final filename.
- `dirname()` extracts the directory portion.

### `path.expand()`

The tilde `~` represents the home directory on many systems:

``` r
path.expand("~")
```

    ## [1] "C:/Users/hp/OneDrive/Documents"

We should not assume that the home directory is the same as the RStudio
project directory.

------------------------------------------------------------------------

## 14.6 Creating a safe practice workspace

To ensure that examples do not alter real research data, we create a
temporary project folder.

``` r
chapter14_root <- file.path(tempdir(), "r_book_chapter14")

dir.create(chapter14_root, recursive = TRUE, showWarnings = FALSE)

chapter14_root
```

    ## [1] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14"

`tempdir()` returns a temporary directory for the current R session.

We will create a simple project structure:

``` text
chapter14/
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
├── results/
└── reports/
```

Create these directories:

``` r
chapter14_dirs <- file.path(
  chapter14_root,
  c("data/raw", "data/processed", "scripts", "results", "reports")
)

for (folder in chapter14_dirs) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

dir.exists(chapter14_dirs)
```

    ## [1] TRUE TRUE TRUE TRUE TRUE

The `recursive = TRUE` argument allows R to create missing parent
folders.

The `showWarnings = FALSE` option prevents a warning if the directory
already exists. It does not guarantee success; we still check with
`dir.exists()`.

### Define reusable paths

``` r
raw_dir <- file.path(chapter14_root, "data", "raw")
processed_dir <- file.path(chapter14_root, "data", "processed")
results_dir <- file.path(chapter14_root, "results")

stopifnot(
  dir.exists(raw_dir),
  dir.exists(processed_dir),
  dir.exists(results_dir)
)
```

We will reuse these variables throughout the chapter.

------------------------------------------------------------------------

## 14.7 Inspecting files and directories

### `list.files()`

``` r
list.files(chapter14_root)
```

    ## [1] "data"    "reports" "results" "scripts"

List files and folders recursively:

``` r
list.files(chapter14_root, recursive = TRUE)
```

    ## character(0)

Show full paths:

``` r
list.files(chapter14_root, full.names = TRUE)
```

    ## [1] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data"   
    ## [2] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/reports"
    ## [3] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/results"
    ## [4] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/scripts"

### `list.dirs()`

``` r
list.dirs(chapter14_root, recursive = TRUE)
```

    ## [1] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14"               
    ## [2] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data"          
    ## [3] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data/processed"
    ## [4] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data/raw"      
    ## [5] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/reports"       
    ## [6] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/results"       
    ## [7] "C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/scripts"

### `file.exists()` and `dir.exists()`

``` r
file.exists(file.path(raw_dir, "patients.csv"))
```

    ## [1] FALSE

``` r
dir.exists(raw_dir)
```

    ## [1] TRUE

At this point, the first result should be `FALSE` because we have not
created the CSV file.

### `file.info()`

`file.info()` provides metadata such as file size, modification time,
and whether a path is a directory.

``` r
file.info(raw_dir)[, c("isdir", "size")]
```

    ##                                                                           isdir
    ## C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data/raw  TRUE
    ##                                                                           size
    ## C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data/raw    0

The exact metadata depend on the filesystem.

------------------------------------------------------------------------

## 14.8 Our first real file: exporting synthetic clinical data

Create a small synthetic dataset:

``` r
patients <- data.frame(
  patient_id = c("P001", "P002", "P003", "P004", "P005"),
  age = c(34, 52, 46, 61, 40),
  sbp = c(118, 152, NA, 146, 130),
  diabetes = c(FALSE, TRUE, FALSE, FALSE, TRUE),
  site = c("North", "South", "North", "East", "South"),
  stringsAsFactors = FALSE
)

patients
```

    ##   patient_id age sbp diabetes  site
    ## 1       P001  34 118    FALSE North
    ## 2       P002  52 152     TRUE South
    ## 3       P003  46  NA    FALSE North
    ## 4       P004  61 146    FALSE  East
    ## 5       P005  40 130     TRUE South

We want to save this data frame to a comma-separated values (CSV) file.

``` r
patients_csv <- file.path(raw_dir, "patients.csv")

write.csv(
  patients,
  file = patients_csv,
  row.names = FALSE,
  na = ""
)

file.exists(patients_csv)
```

    ## [1] TRUE

### Explanation of each argument

- `patients`: the data frame to export.
- `file`: destination path.
- `row.names = FALSE`: do not create an unnecessary row-number column.
- `na = ""`: write missing values as empty fields.

### Why `row.names = FALSE` matters

By default, `write.csv()` may include row names. If those are only
automatic row numbers, importing them later can create an unwanted
column. We generally omit them unless row names carry genuine,
documented identifiers.

------------------------------------------------------------------------

## 14.9 Inspecting the actual CSV text

A CSV file is a text file.

``` r
readLines(patients_csv)
```

    ## [1] "\"patient_id\",\"age\",\"sbp\",\"diabetes\",\"site\""
    ## [2] "\"P001\",34,118,FALSE,\"North\""                     
    ## [3] "\"P002\",52,152,TRUE,\"South\""                      
    ## [4] "\"P003\",46,,FALSE,\"North\""                        
    ## [5] "\"P004\",61,146,FALSE,\"East\""                      
    ## [6] "\"P005\",40,130,TRUE,\"South\""

We should see a header line followed by one line per participant.

CSV is not an R-specific format. It is widely used for data exchange,
but CSV does not preserve all R-specific metadata such as factor levels,
object attributes, or custom classes.

------------------------------------------------------------------------

## 14.10 Reading a CSV file

Use `read.csv()`:

``` r
patients_imported <- read.csv(
  patients_csv,
  stringsAsFactors = FALSE
)

patients_imported
```

    ##   patient_id age sbp diabetes  site
    ## 1       P001  34 118    FALSE North
    ## 2       P002  52 152     TRUE South
    ## 3       P003  46  NA    FALSE North
    ## 4       P004  61 146    FALSE  East
    ## 5       P005  40 130     TRUE South

Inspect the structure:

``` r
str(patients_imported)
```

    ## 'data.frame':    5 obs. of  5 variables:
    ##  $ patient_id: chr  "P001" "P002" "P003" "P004" ...
    ##  $ age       : int  34 52 46 61 40
    ##  $ sbp       : int  118 152 NA 146 130
    ##  $ diabetes  : logi  FALSE TRUE FALSE FALSE TRUE
    ##  $ site      : chr  "North" "South" "North" "East" ...

``` r
names(patients_imported)
```

    ## [1] "patient_id" "age"        "sbp"        "diabetes"   "site"

``` r
nrow(patients_imported)
```

    ## [1] 5

``` r
ncol(patients_imported)
```

    ## [1] 5

### Verify key properties

``` r
stopifnot(
  nrow(patients_imported) == 5L,
  ncol(patients_imported) == 5L,
  !anyDuplicated(patients_imported$patient_id),
  sum(is.na(patients_imported$sbp)) == 1L
)
```

The import worked if these expectations are satisfied.

### A note on data types

`read.csv()` guesses column types. We should always inspect them. An
identifier such as `"00123"` may be incorrectly interpreted as numeric
if we do not control its type.

------------------------------------------------------------------------

## 14.11 Preserving identifiers with `colClasses`

Participant IDs, postal codes, genomic identifiers, and accession
numbers are **identifiers**, not quantities.

Consider:

``` r
id_data <- data.frame(
  sample_id = c("001", "002", "010"),
  measurement = c(2.5, 3.1, 4.0)
)

id_path <- file.path(raw_dir, "sample_ids.csv")
write.csv(id_data, id_path, row.names = FALSE)
```

Import with an explicit character class for the identifier:

``` r
id_imported <- read.csv(
  id_path,
  colClasses = c(sample_id = "character",
                 measurement = "numeric")
)

id_imported
```

    ##   sample_id measurement
    ## 1       001         2.5
    ## 2       002         3.1
    ## 3       010         4.0

``` r
str(id_imported)
```

    ## 'data.frame':    3 obs. of  2 variables:
    ##  $ sample_id  : chr  "001" "002" "010"
    ##  $ measurement: num  2.5 3.1 4

This preserves leading zeros.

### Why this matters in genomics

Variant IDs such as `rs12345` are naturally character strings.
Chromosome labels may include `X`, `Y`, or `MT`, so treating chromosome
as a character field can be appropriate. Position is a numeric
coordinate, but it must be interpreted relative to a specified reference
genome build.

------------------------------------------------------------------------

## 14.12 Reading and writing tab-separated files

Genomic summary statistics are commonly distributed as tab-separated
values (TSV).

Create a small synthetic GWAS table:

``` r
gwas <- data.frame(
  CHROM = c("6", "6", "6", "1"),
  ID = c("rsA", "rsB", "rsC", "rsD"),
  POS = c(26295926, 31298240, 32626565, 1500000),
  BETA = c(0.05, -0.08, 0.12, 0.01),
  SE = c(0.01, 0.02, 0.02, 0.01),
  PVAL = c(2e-8, 3e-9, 5e-12, 0.30),
  stringsAsFactors = FALSE
)

gwas
```

    ##   CHROM  ID      POS  BETA   SE  PVAL
    ## 1     6 rsA 26295926  0.05 0.01 2e-08
    ## 2     6 rsB 31298240 -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  0.12 0.02 5e-12
    ## 4     1 rsD  1500000  0.01 0.01 3e-01

Write a TSV:

``` r
gwas_tsv <- file.path(raw_dir, "gwas_summary.tsv")

write.table(
  gwas,
  file = gwas_tsv,
  sep = "\t",
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE,
  na = "NA"
)
```

### Why `quote = FALSE`?

It avoids wrapping text fields in quotation marks when our identifiers
contain no special delimiter or newline characters. In general,
**quoting is safer** if text may contain tabs, quotes, or embedded line
breaks. We should not disable quoting indiscriminately.

Read the TSV:

``` r
gwas_imported <- read.delim(
  gwas_tsv,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

gwas_imported
```

    ##   CHROM  ID      POS  BETA   SE  PVAL
    ## 1     6 rsA 26295926  0.05 0.01 2e-08
    ## 2     6 rsB 31298240 -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  0.12 0.02 5e-12
    ## 4     1 rsD  1500000  0.01 0.01 3e-01

### `read.table()` as the general reader

``` r
gwas_imported2 <- read.table(
  gwas_tsv,
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

stopifnot(isTRUE(all.equal(gwas_imported, gwas_imported2)))
```

`read.csv()` and `read.delim()` are convenient wrappers around
`read.table()` with different defaults.

------------------------------------------------------------------------

## 14.13 CSV versus TSV: choosing the delimiter

| Format | Typical separator | Common reader | Common writer |
|----|----|----|----|
| CSV | Comma `,` | `read.csv()` | `write.csv()` |
| TSV | Tab `\t` | `read.delim()` | `write.table(..., sep = "\t")` |
| Space-delimited | Whitespace | `read.table()` | `write.table()` |
| Semicolon-delimited | Semicolon `;` | `read.csv2()` in relevant locales | `write.csv2()` |

The extension alone does not guarantee the delimiter. When importing
unfamiliar data, inspect the first few lines and consult the data
dictionary.

``` r
readLines(gwas_tsv, n = 3)
```

    ## [1] "CHROM\tID\tPOS\tBETA\tSE\tPVAL"      
    ## [2] "6\trsA\t26295926\t0.05\t0.01\t2e-08" 
    ## [3] "6\trsB\t31298240\t-0.08\t0.02\t3e-09"

------------------------------------------------------------------------

## 14.14 Headers and column names

The first line of a table may contain variable names.

``` r
readLines(gwas_tsv, n = 1)
```

    ## [1] "CHROM\tID\tPOS\tBETA\tSE\tPVAL"

For files **without a header**, use `header = FALSE` and supply names.

``` r
no_header_path <- file.path(raw_dir, "measurements_no_header.tsv")

write.table(
  data.frame(id = c("P1", "P2"), value = c(10.5, 12.0)),
  no_header_path,
  sep = "\t",
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE
)

no_header <- read.table(
  no_header_path,
  header = FALSE,
  sep = "\t",
  col.names = c("patient_id", "measurement"),
  stringsAsFactors = FALSE
)

no_header
```

    ##   patient_id measurement
    ## 1         P1        10.5
    ## 2         P2        12.0

### `check.names = FALSE`

R may modify names that contain spaces, hyphens, or other characters.

``` r
example_names <- data.frame(
  "Effect Size" = 0.2,
  check.names = FALSE
)

names(example_names)
```

    ## [1] "Effect Size"

Setting `check.names = FALSE` preserves original headers. This is useful
for faithful imports, but column access may then require backticks or
`[[ ]]`.

------------------------------------------------------------------------

## 14.15 Missing-value codes

Real datasets may use several missing-value conventions:

- empty fields;
- `NA`;
- `N/A`;
- `NULL`;
- `-9`;
- `999`.

These codes are **not interchangeable** without a data dictionary.

Create a file containing explicit text missingness:

``` r
missing_path <- file.path(raw_dir, "missing_codes.csv")

writeLines(
  c(
    "id,sbp",
    "P1,120",
    "P2,NA",
    "P3,N/A",
    "P4,145"
  ),
  missing_path
)
```

Read it with specified missing strings:

``` r
missing_data <- read.csv(
  missing_path,
  na.strings = c("", "NA", "N/A"),
  stringsAsFactors = FALSE
)

missing_data
```

    ##   id sbp
    ## 1 P1 120
    ## 2 P2  NA
    ## 3 P3  NA
    ## 4 P4 145

``` r
str(missing_data)
```

    ## 'data.frame':    4 obs. of  2 variables:
    ##  $ id : chr  "P1" "P2" "P3" "P4"
    ##  $ sbp: int  120 NA NA 145

### Why we must not automatically treat `0` as missing

A zero may be a legitimate measurement or a valid coded category. A
sentinel value should be converted to missing only when the dataset
documentation confirms its meaning.

### Counting missing values

``` r
colSums(is.na(missing_data))
```

    ##  id sbp 
    ##   0   2

------------------------------------------------------------------------

## 14.16 Quotation marks and embedded delimiters

A participant note might contain a comma:

``` r
notes <- data.frame(
  id = c("P1", "P2"),
  note = c("Follow-up required, contact site",
           "No additional note"),
  stringsAsFactors = FALSE
)

notes_path <- file.path(raw_dir, "notes.csv")
write.csv(notes, notes_path, row.names = FALSE)

notes_imported <- read.csv(
  notes_path,
  stringsAsFactors = FALSE
)

notes_imported
```

    ##   id                             note
    ## 1 P1 Follow-up required, contact site
    ## 2 P2               No additional note

CSV quoting protects the comma inside the first note so it is not
mistaken for a field separator.

We should avoid manually splitting CSV lines on commas; robust readers
understand quoted fields.

------------------------------------------------------------------------

## 14.17 Encodings and non-ASCII text

Text files are sequences of bytes. An **encoding** specifies how
characters are represented.

Common encodings include UTF-8 and legacy Windows code pages.

For cross-platform research projects, UTF-8 is generally a good default,
but actual input encoding must be verified.

``` r
site_labels <- data.frame(
  site = c("North", "South"),
  city = c("Site A", "Site B")
)

utf8_path <- file.path(raw_dir, "site_labels_utf8.csv")

write.csv(
  site_labels,
  utf8_path,
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

read.csv(
  utf8_path,
  fileEncoding = "UTF-8",
  stringsAsFactors = FALSE
)
```

    ##    site   city
    ## 1 North Site A
    ## 2 South Site B

If text appears garbled, the file may use a different encoding. Changing
encoding blindly can corrupt identifiers or labels; confirm the source
encoding when possible.

------------------------------------------------------------------------

## 14.18 Reading compressed files: `.gz`

Genomic datasets are frequently distributed in gzip-compressed text
files, such as:

``` text
PGC3_SCZ_wave3.european.autosome.public.v3.vcf.tsv.gz
```

Base R can read gzip-compressed text using `gzfile()`.

First, create a small compressed synthetic file:

``` r
gwas_gz <- file.path(raw_dir, "gwas_summary.tsv.gz")

gz_connection <- gzfile(gwas_gz, open = "wt")
write.table(
  gwas,
  file = gz_connection,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
close(gz_connection)

file.exists(gwas_gz)
```

    ## [1] TRUE

Now read it:

``` r
gz_read_connection <- gzfile(gwas_gz, open = "rt")

gwas_from_gz <- read.delim(
  gz_read_connection,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

close(gz_read_connection)

gwas_from_gz
```

    ##   CHROM  ID      POS  BETA   SE  PVAL
    ## 1     6 rsA 26295926  0.05 0.01 2e-08
    ## 2     6 rsB 31298240 -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  0.12 0.02 5e-12
    ## 4     1 rsD  1500000  0.01 0.01 3e-01

Verify:

``` r
stopifnot(isTRUE(all.equal(gwas_imported, gwas_from_gz)))
```

### Why close connections?

A connection represents an open resource. Closing it releases
operating-system resources and helps avoid incomplete writes or locked
files.

### A simpler reader

Many base R file-reading functions can also recognize compressed
filenames automatically. Explicit `gzfile()` connections are useful for
understanding and controlling compressed I/O.

------------------------------------------------------------------------

## 14.19 Previewing a large file without importing everything

Whole-genome summary statistics can be too large to load comfortably
into memory.

We can inspect the first few lines using a connection:

``` r
con <- gzfile(gwas_gz, open = "rt")
preview <- readLines(con, n = 3)
close(con)

preview
```

    ## [1] "CHROM\tID\tPOS\tBETA\tSE\tPVAL"      
    ## [2] "6\trsA\t26295926\t0.05\t0.01\t2e-08" 
    ## [3] "6\trsB\t31298240\t-0.08\t0.02\t3e-09"

Or read only the first few rows:

``` r
preview_table <- read.delim(
  gwas_gz,
  nrows = 3,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

preview_table
```

    ##   CHROM  ID      POS  BETA   SE  PVAL
    ## 1     6 rsA 26295926  0.05 0.01 2e-08
    ## 2     6 rsB 31298240 -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  0.12 0.02 5e-12

### Why preview first?

Before importing a large dataset, we should confirm:

1.  The delimiter.
2.  Column names.
3.  Genome build and coordinate conventions.
4.  Whether the file contains comments or metadata lines.
5.  Missing-value conventions.
6.  Expected column types.
7.  Approximate file size and available memory.

A small preview does not guarantee that every subsequent row is valid,
but it catches many avoidable problems.

------------------------------------------------------------------------

## 14.20 `read.table()` options for larger files

For large delimited files, useful options include:

- `colClasses`: specify types rather than guessing.
- `nrows`: limit the number of rows.
- `comment.char`: control comment handling.
- `quote`: specify quotation characters.
- `na.strings`: define missing-value strings.
- `check.names`: preserve or sanitize headers.

Example:

``` r
gwas_typed <- read.table(
  gwas_tsv,
  header = TRUE,
  sep = "\t",
  colClasses = c(
    CHROM = "character",
    ID = "character",
    POS = "numeric",
    BETA = "numeric",
    SE = "numeric",
    PVAL = "numeric"
  ),
  comment.char = "",
  check.names = FALSE
)

str(gwas_typed)
```

    ## 'data.frame':    4 obs. of  6 variables:
    ##  $ CHROM: chr  "6" "6" "6" "1"
    ##  $ ID   : chr  "rsA" "rsB" "rsC" "rsD"
    ##  $ POS  : num  26295926 31298240 32626565 1500000
    ##  $ BETA : num  0.05 -0.08 0.12 0.01
    ##  $ SE   : num  0.01 0.02 0.02 0.01
    ##  $ PVAL : num  2e-08 3e-09 5e-12 3e-01

This example uses a small dataset, but the principles matter even more
for large files.

**Memory limitation:** Base R’s `read.table()` family generally loads
the resulting table into memory. We should not assume that a
multi-gigabyte compressed GWAS file will fit in a memory-constrained
computer merely because the compressed file is small.

------------------------------------------------------------------------

## 14.21 Chunk-wise reading: a first introduction

When files are large, we can read successive groups of lines rather than
the entire file.

The following example uses a simple numeric file without a header.

``` r
numbers_path <- file.path(raw_dir, "numbers.txt")
writeLines(as.character(1:12), numbers_path)

con <- file(numbers_path, open = "rt")
chunk_sizes <- integer(0)
chunk_sums <- numeric(0)

repeat {
  lines <- readLines(con, n = 5, warn = FALSE)

  if (length(lines) == 0L) {
    break
  }

  values <- as.numeric(lines)
  chunk_sizes <- c(chunk_sizes, length(values))
  chunk_sums <- c(chunk_sums, sum(values))
}

close(con)

chunk_sizes
```

    ## [1] 5 5 2

``` r
chunk_sums
```

    ## [1] 15 40 23

``` r
sum(chunk_sums)
```

    ## [1] 78

Verify:

``` r
stopifnot(sum(chunk_sums) == sum(1:12))
```

### Important distinction

This example illustrates streaming plain numeric lines. Parsing a large,
quoted CSV or TSV in chunks is more complicated because we must preserve
headers, types, row boundaries, quoting rules, and errors. For very
large genomic files, specialized tools and indexed formats may be more
appropriate; those are beyond this base-R chapter.

------------------------------------------------------------------------

## 14.22 Saving an R object with `saveRDS()`

CSV and TSV are good for exchanging tabular data, but they may lose
R-specific object properties.

RDS stores **one R object**, including much of its R-specific structure.

``` r
patients_rds <- file.path(processed_dir, "patients_processed.rds")

saveRDS(patients, file = patients_rds)

file.exists(patients_rds)
```

    ## [1] TRUE

Restore it:

``` r
patients_restored <- readRDS(patients_rds)

str(patients_restored)
```

    ## 'data.frame':    5 obs. of  5 variables:
    ##  $ patient_id: chr  "P001" "P002" "P003" "P004" ...
    ##  $ age       : num  34 52 46 61 40
    ##  $ sbp       : num  118 152 NA 146 130
    ##  $ diabetes  : logi  FALSE TRUE FALSE FALSE TRUE
    ##  $ site      : chr  "North" "South" "North" "East" ...

Check equality:

``` r
stopifnot(identical(patients, patients_restored))
```

### A key benefit

We can choose the name of the restored object:

``` r
another_name <- readRDS(patients_rds)

identical(another_name, patients)
```

    ## [1] TRUE

RDS stores the object, not its original variable name.

------------------------------------------------------------------------

## 14.23 Saving several objects with `save()` and `load()`

We can also save multiple named objects to an `.RData` file.

``` r
summary_note <- "Synthetic Chapter 14 practice data"

rdata_path <- file.path(processed_dir, "practice_objects.RData")

save(
  patients,
  gwas,
  summary_note,
  file = rdata_path
)
```

Loading an `.RData` file recreates objects under their saved names.

To avoid overwriting objects in our current environment, load into a new
environment:

``` r
loaded_env <- new.env(parent = emptyenv())
loaded_names <- load(rdata_path, envir = loaded_env)

loaded_names
```

    ## [1] "patients"     "gwas"         "summary_note"

Access the objects:

``` r
loaded_env$summary_note
```

    ## [1] "Synthetic Chapter 14 practice data"

``` r
nrow(loaded_env$patients)
```

    ## [1] 5

### RDS versus `.RData`

| Property | RDS | `.RData` |
|----|----|----|
| Saves | One object | One or more named objects |
| Write | `saveRDS()` | `save()` |
| Read | `readRDS()` | `load()` |
| Restore name chosen by us? | Yes | Saved names are restored |
| Risk of name collisions | Lower | Higher when loading into an existing environment |

For reproducible pipelines, RDS is often convenient because we
explicitly assign the returned object.

------------------------------------------------------------------------

## 14.24 Why automatic workspace restoration can be risky

An R session may contain objects left over from earlier analysis. If a
script silently relies on those objects, it may work interactively but
fail when run from a clean session.

A robust script should:

- create or import all required objects;
- use clear input and output paths;
- avoid relying on an old `.RData` workspace;
- record processing decisions in code;
- validate outputs.

This principle is especially important when analyses are repeated after
a dataset update.

------------------------------------------------------------------------

## 14.25 Writing and reading plain text

Sometimes we need to save a list of genes, variant IDs, or sample IDs.

``` r
gene_ids <- c("HLA-A", "HLA-B", "C4A", "NOTCH4")

gene_file <- file.path(results_dir, "candidate_genes.txt")

writeLines(gene_ids, gene_file)

readLines(gene_file)
```

    ## [1] "HLA-A"  "HLA-B"  "C4A"    "NOTCH4"

Unlike `write.csv()`, `writeLines()` writes one character string per
line.

### Save a simple report

``` r
report_lines <- c(
  "Synthetic GWAS QC summary",
  paste("Number of variants:", nrow(gwas)),
  paste("Number on chromosome 6:", sum(gwas$CHROM == "6")),
  "All results are illustrative."
)

report_file <- file.path(results_dir, "qc_summary.txt")

writeLines(report_lines, report_file)
readLines(report_file)
```

    ## [1] "Synthetic GWAS QC summary"     "Number of variants: 4"        
    ## [3] "Number on chromosome 6: 3"     "All results are illustrative."

For more complex reports, we can later use R Markdown.

------------------------------------------------------------------------

## 14.26 File operations: copy, rename, and delete

Base R includes:

- `file.copy()`
- `file.rename()`
- `file.remove()`
- `unlink()`

We must use these carefully, especially around raw or irreplaceable
research data.

### Safe demonstration inside our temporary folder

``` r
original <- file.path(results_dir, "temporary_example.txt")
copy_path <- file.path(results_dir, "temporary_copy.txt")
renamed_path <- file.path(results_dir, "temporary_renamed.txt")

writeLines("Temporary demonstration file", original)

stopifnot(file.copy(original, copy_path))
stopifnot(file.rename(copy_path, renamed_path))

file.exists(original)
```

    ## [1] TRUE

``` r
file.exists(renamed_path)
```

    ## [1] TRUE

Remove only the practice copy:

``` r
stopifnot(file.remove(renamed_path))
file.exists(renamed_path)
```

    ## [1] FALSE

### Why we do not use `unlink(..., recursive = TRUE)` casually

Recursive deletion can remove an entire directory tree. It should be
used only after validating that the target is a deliberately created,
disposable path.

**This chapter does not delete the practice root**, even though it is
temporary.

------------------------------------------------------------------------

## 14.27 `normalizePath()` and path verification

A path may contain relative components such as `.` and `..`.

`normalizePath()` returns a normalized path when it can be resolved.

``` r
normalizePath(raw_dir, winslash = "/", mustWork = TRUE)
```

    ## [1] "C:/Users/hp/AppData/Local/Temp/RtmpyEcRWJ/r_book_chapter14/data/raw"

The `mustWork = TRUE` argument raises an error if the path does not
exist.

For a prospective output file that does not yet exist, normalize its
existing parent directory instead.

``` r
output_candidate <- file.path(results_dir, "future_table.csv")

normalizePath(
  dirname(output_candidate),
  winslash = "/",
  mustWork = TRUE
)
```

    ## [1] "C:/Users/hp/AppData/Local/Temp/RtmpyEcRWJ/r_book_chapter14/results"

### Why path verification matters

We should verify that the intended output directory exists before
writing results. Otherwise, a file may be saved to an unexpected
location or the operation may fail.

------------------------------------------------------------------------

## 14.28 A reusable safe file reader

In Chapter 12, we learned to write functions. We can now build a simple
function to validate and import a CSV file.

``` r
read_clinical_csv <- function(path, required_columns) {
  if (!is.character(path) || length(path) != 1L ||
      is.na(path) || !nzchar(path)) {
    stop("path must be one nonempty character string.")
  }

  if (!file.exists(path)) {
    stop("Input file does not exist: ", path)
  }

  if (!is.character(required_columns)) {
    stop("required_columns must be a character vector.")
  }

  dat <- read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  missing_columns <- setdiff(required_columns, names(dat))

  if (length(missing_columns) > 0L) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }

  dat
}
```

Test it:

``` r
clinical_checked <- read_clinical_csv(
  patients_csv,
  required_columns = c("patient_id", "age", "sbp")
)

nrow(clinical_checked)
```

    ## [1] 5

### Why this function is useful

It separates the input-validation logic from the analysis logic. A real
pipeline can extend it to verify types, ranges, missingness, and
duplicate identifiers.

### A limitation

Checking that a file exists and contains named columns is not sufficient
to prove that the data are correct. File formats, scientific units, and
data provenance still require validation.

------------------------------------------------------------------------

## 14.29 Data validation immediately after import

A useful minimum validation sequence is:

1.  Check row and column counts.
2.  Confirm required column names.
3.  Inspect data types.
4.  Count missing values.
5.  Check duplicate identifiers.
6.  Validate numerical ranges.
7.  Confirm units and coding schemes.
8.  Check reference genome build for genomic coordinates.

Apply several checks to the imported clinical table:

``` r
clinical <- read_clinical_csv(
  patients_csv,
  c("patient_id", "age", "sbp", "diabetes")
)

stopifnot(
  nrow(clinical) > 0L,
  is.character(clinical$patient_id),
  is.numeric(clinical$age),
  is.numeric(clinical$sbp),
  !anyDuplicated(clinical$patient_id)
)

summary(clinical)
```

    ##   patient_id             age            sbp         diabetes      
    ##  Length:5           Min.   :34.0   Min.   :118.0   Mode :logical  
    ##  Class :character   1st Qu.:40.0   1st Qu.:127.0   FALSE:3        
    ##  Mode  :character   Median :46.0   Median :138.0   TRUE :2        
    ##                     Mean   :46.6   Mean   :136.5                  
    ##                     3rd Qu.:52.0   3rd Qu.:147.5                  
    ##                     Max.   :61.0   Max.   :152.0                  
    ##                                    NA's   :1                      
    ##      site          
    ##  Length:5          
    ##  Class :character  
    ##  Mode  :character  
    ##                    
    ##                    
    ##                    
    ## 

``` r
colSums(is.na(clinical))
```

    ## patient_id        age        sbp   diabetes       site 
    ##          0          0          1          0          0

### A range check

``` r
invalid_age <- !is.na(clinical$age) &
  (clinical$age < 0 | clinical$age > 120)

sum(invalid_age)
```

    ## [1] 0

The upper bound is illustrative; appropriate plausibility checks depend
on the study population.

------------------------------------------------------------------------

## 14.30 Writing processed data without overwriting raw data

A central reproducibility rule is:

> Keep original raw files unchanged and write derived outputs to a
> separate directory.

Create a derived screening column:

``` r
clinical$sbp_status <- ifelse(
  is.na(clinical$sbp),
  "Missing",
  ifelse(clinical$sbp >= 140, "Review", "Below threshold")
)

processed_csv <- file.path(
  processed_dir,
  "patients_with_screening_status.csv"
)

write.csv(
  clinical,
  processed_csv,
  row.names = FALSE,
  na = ""
)

file.exists(processed_csv)
```

    ## [1] TRUE

Verify that the raw file still exists:

``` r
stopifnot(
  file.exists(patients_csv),
  file.exists(processed_csv)
)
```

The derived screening category is a study-defined rule, not a medical
diagnosis.

------------------------------------------------------------------------

## 14.31 Processing multiple files with a loop

In Chapter 11, we learned loops. Now we apply them to real files.

Create three synthetic site-level CSV files:

``` r
site_a <- data.frame(id = c("A1", "A2"), sbp = c(120, 145))
site_b <- data.frame(id = c("B1", "B2", "B3"), sbp = c(NA, 150, 138))
site_c <- data.frame(id = "C1", sbp = 160)

site_files <- file.path(
  raw_dir,
  c("site_A.csv", "site_B.csv", "site_C.csv")
)

write.csv(site_a, site_files[1], row.names = FALSE)
write.csv(site_b, site_files[2], row.names = FALSE)
write.csv(site_c, site_files[3], row.names = FALSE)

file.exists(site_files)
```

    ## [1] TRUE TRUE TRUE

Read and summarize each file:

``` r
site_summaries <- vector("list", length(site_files))

for (i in seq_along(site_files)) {
  dat <- read.csv(
    site_files[i],
    stringsAsFactors = FALSE
  )

  site_summaries[[i]] <- data.frame(
    site = sub("\\.csv$", "", basename(site_files[i])),
    n_total = nrow(dat),
    n_missing = sum(is.na(dat$sbp)),
    n_review = sum(dat$sbp >= 140, na.rm = TRUE)
  )
}

site_summary <- do.call(rbind, site_summaries)
row.names(site_summary) <- NULL

site_summary
```

    ##     site n_total n_missing n_review
    ## 1 site_A       2         0        1
    ## 2 site_B       3         1        1
    ## 3 site_C       1         0        1

### Validate the totals

``` r
stopifnot(
  sum(site_summary$n_total) == 6L,
  sum(site_summary$n_missing) == 1L,
  sum(site_summary$n_review) == 3L
)
```

Write the summary:

``` r
site_summary_path <- file.path(
  results_dir,
  "site_screening_summary.csv"
)

write.csv(site_summary, site_summary_path, row.names = FALSE)
```

### Why list preallocation helps

Each site may contain a different number of participants. A list can
hold a separate data frame for each site, and `do.call(rbind, ...)` can
combine compatible summary rows afterward.

------------------------------------------------------------------------

## 14.32 Discovering files by pattern

We do not always know every filename in advance.

Use `list.files()` with a regular-expression pattern:

``` r
discovered_sites <- list.files(
  raw_dir,
  pattern = "^site_[A-C]\\.csv$",
  full.names = TRUE
)

basename(discovered_sites)
```

    ## [1] "site_A.csv" "site_B.csv" "site_C.csv"

The pattern means:

- `^`: start of the filename;
- `site_`: literal text;
- `[A-C]`: one character from A through C;
- `\\.`: a literal dot;
- `csv`: literal extension;
- `$`: end of the filename.

### Why narrow patterns matter

A broad pattern such as `".csv"` can accidentally include unrelated
files. Explicit patterns reduce the risk of mixing inputs from different
studies or analysis stages.

------------------------------------------------------------------------

## 14.33 A GWAS-oriented directory structure

A computational genomics project may be organized as follows:

``` text
SCZ_xMHC_Project/
├── README.md
├── data/
│   ├── raw/
│   │   └── gwas_summary.tsv.gz
│   ├── reference/
│   │   └── genome_build_notes.txt
│   └── processed/
│       └── xmhc_variants.tsv
├── scripts/
│   ├── 01_import_qc.R
│   ├── 02_region_filter.R
│   └── 03_summary.R
├── results/
│   ├── tables/
│   └── figures/
└── reports/
    └── analysis_notes.md
```

This is a recommended conceptual structure, not a requirement that every
project use identical names.

### A typical workflow

1.  Import raw summary statistics.
2.  Validate headers, types, genome build, and essential fields.
3.  Filter the genomic region of interest.
4.  Perform additional QC.
5.  Save processed data separately.
6.  Write tables and figures to `results/`.
7.  Record versions, parameters, and provenance.

### Example regional filter

``` r
gwas_chr6 <- gwas_imported[
  gwas_imported$CHROM == "6" &
  gwas_imported$POS >= 25000000 &
  gwas_imported$POS <= 34000000,
  ,
  drop = FALSE
]

gwas_chr6
```

    ##   CHROM  ID      POS  BETA   SE  PVAL
    ## 1     6 rsA 26295926  0.05 0.01 2e-08
    ## 2     6 rsB 31298240 -0.08 0.02 3e-09
    ## 3     6 rsC 32626565  0.12 0.02 5e-12

Save it:

``` r
xmhc_path <- file.path(processed_dir, "synthetic_xmhc.tsv")

write.table(
  gwas_chr6,
  xmhc_path,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
```

**Critical scientific point:** A genomic coordinate interval is
meaningful only when the chromosome convention and reference genome
build are specified. We must not combine hg19 and hg38 coordinates
without appropriate harmonization.

------------------------------------------------------------------------

## 14.34 Filesystem metadata and provenance

Reproducibility is not only about code. It also requires identifying the
exact input files used.

Useful metadata include:

- original filename;
- source URL or accession;
- date downloaded;
- file size;
- checksum;
- genome build, when applicable;
- software and package versions;
- filtering parameters.

### File size

``` r
file.info(gwas_tsv)$size
```

    ## [1] 153

### Modification time

``` r
file.info(gwas_tsv)$mtime
```

    ## [1] "2026-10-24 10:22:34 IST"

### MD5 checksum

Base R provides `tools::md5sum()`:

``` r
tools::md5sum(gwas_tsv)
```

    ## C:\\Users\\hp\\AppData\\Local\\Temp\\RtmpyEcRWJ/r_book_chapter14/data/raw/gwas_summary.tsv 
    ##                                                         "20aedd687b931707f0642eb754becd5e"

A checksum can help detect whether file bytes have changed. MD5 is
useful for accidental-change detection, but it is not recommended for
security-sensitive integrity guarantees against deliberate tampering.

### Record the R version

``` r
R.version.string
```

    ## [1] "R version 4.5.3 (2026-03-11 ucrt)"

For reproducible analysis, we should also record important input
parameters and dataset versions.

------------------------------------------------------------------------

## 14.35 File sizes and memory considerations

Compressed genomic files may expand substantially when decompressed and
can consume additional memory when parsed into R objects.

For example, a file occupying 1 GB on disk does **not** imply that the
imported data frame will require only 1 GB of RAM.

We can inspect object memory usage:

``` r
object.size(gwas_imported)
```

    ## 1712 bytes

``` r
format(object.size(gwas_imported), units = "auto")
```

    ## [1] "1.7 Kb"

For large data:

- preview before full import;
- use `colClasses` where possible;
- avoid keeping unnecessary copies;
- consider chromosome- or region-specific processing;
- consider indexed genomic formats and command-line tools when
  appropriate;
- verify that the computer has sufficient RAM and disk space.

The chapter’s examples are intentionally small so they can run on a
standard personal laptop.

------------------------------------------------------------------------

## 14.36 File permissions and privacy

Clinical and genomic datasets can contain sensitive information.

Even when our code works correctly, we must ensure that:

- identifiable patient data are stored only in approved locations;
- permissions follow institutional and legal requirements;
- raw data are not accidentally committed to public repositories;
- filenames do not reveal sensitive identifiers;
- temporary files and exports follow retention policies;
- collaborators receive only authorized datasets;
- de-identification and consent requirements are respected.

This chapter uses synthetic participant IDs and contains no real
personal medical records.

### Git and public repositories

A useful project repository may include code, documentation, and
synthetic example data while excluding restricted raw data. A
`.gitignore` file can help prevent accidental commits, but it is not a
substitute for access controls or reviewing files before publication.

------------------------------------------------------------------------

## 14.37 Troubleshooting common file errors

### Error 1: cannot open the connection

Typical causes include:

- incorrect path;
- missing file;
- insufficient permissions;
- file locked by another process;
- missing parent directory.

Start with:

``` r
file.exists(patients_csv)
```

    ## [1] TRUE

``` r
dir.exists(dirname(patients_csv))
```

    ## [1] TRUE

### Error 2: more columns than column names

This can indicate an incorrect separator, malformed quotation marks, or
an unexpected header.

Inspect the raw lines:

``` r
readLines(patients_csv, n = 3)
```

    ## [1] "\"patient_id\",\"age\",\"sbp\",\"diabetes\",\"site\""
    ## [2] "\"P001\",34,118,FALSE,\"North\""                     
    ## [3] "\"P002\",52,152,TRUE,\"South\""

### Error 3: all data appear in one column

The wrong delimiter may have been used. Check whether the file is
comma-, tab-, or semicolon-separated.

### Error 4: identifiers lose leading zeros

Specify the identifier column as character using `colClasses`.

### Error 5: numeric values import as character

Check missing-value codes, decimal conventions, embedded text, and
separators. Do not convert blindly before investigating.

### Error 6: a script works interactively but fails when knitted

The working directory or preexisting Environment objects may differ. Use
explicit project-relative paths and ensure the script creates or imports
its inputs.

### Error 7: output file cannot be written

Check the destination directory, permissions, and whether the file is
open in another application.

### Error 8: unexpectedly large memory use

A compressed file can expand substantially in memory. Read only required
fields or subsets where feasible.

### Error 9: unexpected column-name changes

Use `check.names = FALSE` if original headers must be preserved, and
then access unusual names with `[[ ]]` or backticks.

### Error 10: overwritten raw data

Keep raw and processed directories separate. Confirm output paths before
writing.

------------------------------------------------------------------------

## 14.38 Guided practical: complete biomedical file workflow

We will create a dataset, save it, import it, validate it, calculate
derived variables, and export results.

### Step 1: create synthetic data

``` r
workflow_data <- data.frame(
  id = c("W001", "W002", "W003", "W004", "W005"),
  age = c(35, 51, 62, 44, 58),
  weight_kg = c(62, 84, 76, 71, 90),
  height_m = c(1.62, 1.75, 1.68, 1.70, 1.80),
  sbp = c(118, 148, NA, 142, 155)
)

workflow_data
```

    ##     id age weight_kg height_m sbp
    ## 1 W001  35        62     1.62 118
    ## 2 W002  51        84     1.75 148
    ## 3 W003  62        76     1.68  NA
    ## 4 W004  44        71     1.70 142
    ## 5 W005  58        90     1.80 155

### Step 2: export raw data

``` r
workflow_raw_path <- file.path(
  raw_dir,
  "workflow_participants.csv"
)

write.csv(
  workflow_data,
  workflow_raw_path,
  row.names = FALSE,
  na = ""
)
```

### Step 3: import and validate

``` r
workflow_imported <- read.csv(
  workflow_raw_path,
  colClasses = c(
    id = "character",
    age = "numeric",
    weight_kg = "numeric",
    height_m = "numeric",
    sbp = "numeric"
  )
)

stopifnot(
  nrow(workflow_imported) == 5L,
  !anyDuplicated(workflow_imported$id),
  all(workflow_imported$height_m > 0),
  all(workflow_imported$weight_kg > 0)
)
```

### Step 4: derive BMI and a study screening label

``` r
workflow_imported$bmi <-
  workflow_imported$weight_kg /
  workflow_imported$height_m^2

workflow_imported$sbp_status <- ifelse(
  is.na(workflow_imported$sbp),
  "Missing",
  ifelse(
    workflow_imported$sbp >= 140,
    "Review",
    "Below threshold"
  )
)

workflow_imported
```

    ##     id age weight_kg height_m sbp      bmi      sbp_status
    ## 1 W001  35        62     1.62 118 23.62445 Below threshold
    ## 2 W002  51        84     1.75 148 27.42857          Review
    ## 3 W003  62        76     1.68  NA 26.92744         Missing
    ## 4 W004  44        71     1.70 142 24.56747          Review
    ## 5 W005  58        90     1.80 155 27.77778          Review

### Step 5: save processed data in two formats

``` r
workflow_csv <- file.path(
  processed_dir,
  "workflow_processed.csv"
)

workflow_rds <- file.path(
  processed_dir,
  "workflow_processed.rds"
)

write.csv(
  workflow_imported,
  workflow_csv,
  row.names = FALSE,
  na = ""
)

saveRDS(workflow_imported, workflow_rds)
```

### Step 6: restore and verify

``` r
workflow_restored <- readRDS(workflow_rds)

stopifnot(
  identical(workflow_imported, workflow_restored),
  file.exists(workflow_csv)
)
```

### Step 7: create a summary report

``` r
workflow_summary <- data.frame(
  n_participants = nrow(workflow_restored),
  n_missing_sbp = sum(is.na(workflow_restored$sbp)),
  n_review = sum(workflow_restored$sbp_status == "Review"),
  mean_bmi = mean(workflow_restored$bmi)
)

workflow_summary
```

    ##   n_participants n_missing_sbp n_review mean_bmi
    ## 1              5             1        3 26.06514

### Step 8: export the summary

``` r
workflow_summary_path <- file.path(
  results_dir,
  "workflow_summary.csv"
)

write.csv(
  workflow_summary,
  workflow_summary_path,
  row.names = FALSE
)

stopifnot(file.exists(workflow_summary_path))
```

### Interpretation

We have built a reproducible data-processing sequence:

**Create → Export → Import → Validate → Transform → Save → Verify →
Summarize.**

The same structure can be adapted to epidemiological cohorts, genomic
annotation tables, and quality-control reports.

------------------------------------------------------------------------

## 14.39 Independent exercises: files and paths

1.  Explain the difference between an R object and a file.
2.  Use `getwd()` and interpret its output.
3.  Explain absolute versus relative paths.
4.  Construct a path to `data/raw/cohort.csv` using `file.path()`.
5.  Use `basename()` and `dirname()` on that path.
6.  Explain why `C:\Research\Project` can be problematic inside an
    ordinary R string.
7.  Create a temporary practice directory.
8.  Create subdirectories named `raw`, `processed`, and `results`.
9.  Verify their existence.
10. List all files recursively.
11. Explain why changing the working directory repeatedly can reduce
    reproducibility.
12. Explain how an RStudio project can help organize an analysis.

------------------------------------------------------------------------

## 14.40 Independent exercises: reading and writing tables

Create a synthetic data frame with 10 participants and variables `id`,
`age`, `sbp`, and `site`.

1.  Export it as CSV without row names.
2.  Read it back and inspect the structure.
3.  Export it as TSV.
4.  Import the TSV with `read.delim()`.
5.  Compare the CSV and TSV imports.
6.  Insert one missing SBP value and verify the missing-value count
    after import.
7.  Create identifiers with leading zeros and preserve them using
    `colClasses`.
8.  Create a note field containing a comma and verify that CSV quoting
    works.
9.  Explain `header`, `sep`, `quote`, `na.strings`, and `check.names`.
10. Explain why imported column types must be checked.
11. Save the data frame as RDS.
12. Restore it under a new variable name and compare it with the
    original.

------------------------------------------------------------------------

## 14.41 Independent exercises: genomics file handling

Using a synthetic GWAS table with `CHROM`, `ID`, `POS`, `BETA`, `SE`,
and `PVAL`:

1.  Save the table as TSV.
2.  Create a gzip-compressed version.
3.  Preview the first three lines without loading the entire file.
4.  Import the compressed file.
5.  Validate the required column names.
6.  Check that `SE` is numeric.
7.  Count missing `BETA`, `SE`, and `PVAL` values.
8.  Filter chromosome 6 positions 25–34 Mb inclusive.
9.  Save the filtered result to `data/processed/`.
10. Save the filtered result as RDS.
11. Record a checksum for the input TSV.
12. Explain why genome-build information must accompany the dataset.
13. Explain why a compressed file’s size is not a reliable estimate of
    its memory footprint.
14. Describe the additional QC needed before real GWAS analysis.

------------------------------------------------------------------------

## 14.42 Challenge: a small multi-file research pipeline

Develop a complete base-R pipeline that:

1.  Creates three synthetic site-level clinical CSV files.
2.  Discovers them using a specific filename pattern.
3.  Reads each file inside a loop.
4.  Verifies that required columns exist.
5.  Checks for duplicate participant IDs within each file.
6.  Counts participants and missing SBP values.
7.  Calculates the number of observed SBP values meeting a specified
    screening threshold.
8.  Combines site summaries.
9.  Validates aggregate counts.
10. Exports a CSV summary and an RDS copy.
11. Records file names and modification times.
12. Includes a short text report describing the analysis and
    limitations.

**Advanced extension:** Deliberately create a file with a missing
required column and confirm that the pipeline reports the problem rather
than silently proceeding.

------------------------------------------------------------------------

## 14.43 Complete standalone practice script

This script summarizes the chapter’s core workflow. It is **not executed
during knitting** because the individual demonstrations already create
and inspect files.

``` r
# ============================================================
# R for Biomedical, Epidemiological & Genomic Research
# Chapter 14: Files and Directories
# Base R only; synthetic data
# ============================================================

# Create a disposable workspace
project <- file.path(tempdir(), "chapter14_standalone")
raw <- file.path(project, "data", "raw")
processed <- file.path(project, "data", "processed")
results <- file.path(project, "results")

for (folder in c(raw, processed, results)) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
}

# Synthetic clinical data
patients <- data.frame(
  id = c("P001", "P002", "P003"),
  age = c(35, 52, 61),
  sbp = c(120, 150, NA_real_),
  weight_kg = c(65, 82, 74),
  height_m = c(1.65, 1.75, 1.70)
)

# Export
raw_path <- file.path(raw, "patients.csv")
write.csv(patients, raw_path, row.names = FALSE, na = "")

# Import and validate
dat <- read.csv(
  raw_path,
  colClasses = c(
    id = "character",
    age = "numeric",
    sbp = "numeric",
    weight_kg = "numeric",
    height_m = "numeric"
  )
)

stopifnot(
  all(c("id", "age", "sbp") %in% names(dat)),
  !anyDuplicated(dat$id),
  all(dat$height_m > 0)
)

# Derived variables
dat$bmi <- dat$weight_kg / dat$height_m^2
dat$screening <- ifelse(
  is.na(dat$sbp),
  "Missing",
  ifelse(dat$sbp >= 140, "Review", "Below threshold")
)

# Save processed data
processed_path <- file.path(processed, "patients.rds")
saveRDS(dat, processed_path)

# Restore
restored <- readRDS(processed_path)
stopifnot(identical(dat, restored))

# Summarize
summary_table <- data.frame(
  n = nrow(restored),
  missing_sbp = sum(is.na(restored$sbp)),
  review = sum(restored$screening == "Review")
)

# Export results
summary_path <- file.path(results, "summary.csv")
write.csv(summary_table, summary_path, row.names = FALSE)

# Provenance
print(tools::md5sum(raw_path))
print(R.version.string)
print(list.files(project, recursive = TRUE))
```

------------------------------------------------------------------------

## 14.44 Essential functions reference

| Function          | Purpose                       |
|-------------------|-------------------------------|
| `getwd()`         | Inspect working directory     |
| `setwd()`         | Change working directory      |
| `file.path()`     | Construct paths               |
| `basename()`      | Extract filename              |
| `dirname()`       | Extract parent path           |
| `path.expand()`   | Expand `~`                    |
| `normalizePath()` | Normalize an existing path    |
| `dir.create()`    | Create a directory            |
| `dir.exists()`    | Check directory existence     |
| `file.exists()`   | Check file existence          |
| `list.files()`    | List directory entries        |
| `list.dirs()`     | List directories              |
| `file.info()`     | Inspect file metadata         |
| `read.csv()`      | Import CSV                    |
| `write.csv()`     | Export CSV                    |
| `read.delim()`    | Import tab-separated data     |
| `read.table()`    | General delimited-text import |
| `write.table()`   | General delimited-text export |
| `readLines()`     | Read text lines               |
| `writeLines()`    | Write text lines              |
| `gzfile()`        | Create a gzip file connection |
| `file()`          | Create a file connection      |
| `close()`         | Close a connection            |
| `saveRDS()`       | Save one R object             |
| `readRDS()`       | Restore one R object          |
| `save()`          | Save named R objects          |
| `load()`          | Restore named R objects       |
| `file.copy()`     | Copy a file                   |
| `file.rename()`   | Rename or move a file         |
| `file.remove()`   | Remove a file                 |
| `tools::md5sum()` | Compute an MD5 checksum       |
| `object.size()`   | Estimate object memory use    |

------------------------------------------------------------------------

## 14.45 Chapter review questions

1.  Why is an R object not the same as a file?
2.  What does the working directory control?
3.  Why are relative paths useful in research projects?
4.  How does `file.path()` improve portability?
5.  What does `recursive = TRUE` mean in `dir.create()`?
6.  How can we verify a directory exists?
7.  Why should CSV exports generally use `row.names = FALSE`?
8.  How do CSV and TSV differ?
9.  What does `header = TRUE` mean?
10. What happens when a file has an incorrect delimiter?
11. Why should identifiers often be imported as character?
12. What is the purpose of `na.strings`?
13. Why are quoted fields important in CSV?
14. What is text encoding?
15. How can base R read gzip-compressed text?
16. How can we preview a large file without importing it all?
17. What are the differences between RDS and `.RData`?
18. Why should raw data remain unchanged?
19. How can loops help process multiple files?
20. Why must we validate imported data before analysis?
21. What is a checksum?
22. Why should genomic coordinates include genome-build metadata?
23. Why might a compressed file require much more RAM than its disk
    size?
24. Why are file permissions and privacy relevant to biomedical
    research?
25. What steps make a file-based R workflow reproducible?

## 14.46 Key takeaways

- A reliable R workflow must manage **both in-memory objects and
  filesystem files**.
- `getwd()` shows where relative paths are interpreted.
- `file.path()` supports readable, portable path construction.
- `read.csv()` and `read.delim()` import common biomedical and genomic
  table formats.
- `write.csv()` and `write.table()` export data for exchange.
- `saveRDS()` and `readRDS()` preserve R object structure.
- `gzfile()` supports compressed text I/O without extra packages.
- Large files should be previewed and validated before full import.
- **Raw data should remain unchanged**; processed data and results
  belong in separate folders.
- Input validation, provenance, checksums, and privacy protections are
  part of reproducible research.

> A successful analysis is not only one that produces the right
> calculation. It must also load the intended data, preserve their
> meaning, and save verifiable outputs in the correct location.

## 14.47 Looking ahead: Chapter 15 — Importing and Exporting Research Data

Chapter 14 introduced files, paths, and common base-R formats. In
**Chapter 15**, we will extend these foundations to systematic data
import and export, including data dictionaries, type conversion, dates,
common parsing problems, data-validation reports, and safe exchange
between research collaborators.
