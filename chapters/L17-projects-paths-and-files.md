Lesson 17: Projects, Paths, and Reading and Writing Files
================
Dr. Sandeep Kumar Singh

> **The real question for today:** Real projects do not start from a
> package’s built-in dataset. A colleague emails a CSV file, a hospital
> exports a spreadsheet, a database offers a download. How does R find a
> file on our computer, read it into a data frame, and save our cleaned
> data and results so that others can use them?

------------------------------------------------------------------------

## 1. Why this lesson matters

Reading and writing files is the bridge between R and the rest of the
world. Most “R does not work” moments for beginners are really “R cannot
find my file” moments. Once we understand **where R is looking** and
organise our work in an **RStudio Project**, those problems disappear,
and our scripts will run unchanged on a colleague’s computer.

------------------------------------------------------------------------

## 2. The ideas, in plain words

### 2.1 The working directory: where R is standing

At any moment, R is “standing” in one folder on the computer, called the
**working directory**. When we ask for a file by its name alone, R looks
for it **in that folder**. If the file is somewhere else, R says it
cannot find it, even if it is right there on our desktop.

Think of being in one room of a house. If someone says “bring the red
file”, we look in the room we are in. If the file is in another room, we
need directions.

### 2.2 Paths: directions to a file

A **path** is the directions to a file.

| Kind of path | Example | Directions given… |
|----|----|----|
| **Absolute** path | `C:/Users/sandeep/Documents/r-course/data/births.csv` | from the front door of the house |
| **Relative** path | `data/births.csv` | from the room we are standing in |

Absolute paths break as soon as the project moves to another folder or
another computer, because nobody else has `C:/Users/sandeep`. Relative
paths keep working, **as long as R is standing in the project folder.**
So we use relative paths, and we make sure R always stands in the right
place. That is what an RStudio Project does.

> **Windows users:** in R, write paths with forward slashes `/`, as
> above. Windows shows backslashes (`C:\Users\...`), but in R a single
> backslash has a special meaning and causes errors.

### 2.3 RStudio Projects: one folder per piece of work

An **RStudio Project** is a folder that holds everything for one piece
of work, plus a small file ending in `.Rproj`. When we open the project,
RStudio automatically sets the working directory to that folder. A tidy
layout used in this course:

    low-birth-weight/                 <- the project folder
    ├── low-birth-weight.Rproj        <- double-click to open the project
    ├── data/                         <- raw and cleaned data files
    ├── scripts/                      <- our .R scripts
    └── outputs/                      <- figures and result tables

### 2.4 CSV: the universal table file

A **CSV** file (comma-separated values) is a plain text file in which
each line is a row and commas separate the columns. Almost every
program, from Excel to hospital databases, can read and write CSV. If we
open one in a text editor, it looks like this (Snow’s Table IX):

    company,deaths,houses
    Southwark_Vauxhall,1263,40046
    Lambeth,98,26107
    Rest_of_London,1422,256423

The first line is the **header**: the column names.

------------------------------------------------------------------------

## 3. Setting up a project (do this once)

1.  **File → New Project → New Directory → New Project.**
2.  Name it `low-birth-weight` and choose where to keep it (for example,
    your Documents folder). Click **Create Project**.
3.  RStudio restarts inside the project. The project name appears at the
    top right, and the Files pane shows the project folder.
4.  In the Files pane, click **New Folder** three times to make `data`,
    `scripts` and `outputs`. (Or run the code in section 4.2.)
5.  From now on, open your work by double-clicking the `.Rproj` file.

------------------------------------------------------------------------

## 4. Code, step by step

### 4.1 Where is R standing? `getwd()`

``` r
getwd()
## [1] "C:/Users/yourname/Documents/low-birth-weight"
```

**What it does:** `getwd()` (“get working directory”) prints the folder
R is standing in. Inside a project, it is the project folder. (Your path
will be different from the one shown.)

There is also `setwd()` to move R to another folder, but we avoid it in
scripts: it contains an absolute path that only works on one computer.
The project does the job instead.

### 4.2 Creating folders and listing files

``` r
dir.create("data", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
list.files("data")
```

    ## [1] "births_clean.csv" "births_clean.rds" "pima.csv"         "snow_table9.csv" 
    ## [5] "snow_table9.tsv"

**What it does:** `dir.create()` makes a folder (`showWarnings = FALSE`
stops it complaining if the folder already exists). `list.files()` lists
the files in a folder.

**How to read the output:** the `data` folder contains Snow’s table,
saved as `snow_table9.csv`. To follow along, create this file yourself:
**File → New File → Text File**, type the four lines shown in section
2.4, and save it as `data/snow_table9.csv`.

### 4.3 Reading a CSV file: `read.csv()`

``` r
snow <- read.csv("data/snow_table9.csv")
snow
```

    ##              company deaths houses
    ## 1 Southwark_Vauxhall   1263  40046
    ## 2            Lambeth     98  26107
    ## 3     Rest_of_London   1422 256423

``` r
str(snow)
```

    ## 'data.frame':    3 obs. of  3 variables:
    ##  $ company: chr  "Southwark_Vauxhall" "Lambeth" "Rest_of_London"
    ##  $ deaths : int  1263 98 1422
    ##  $ houses : int  40046 26107 256423

**What it does:** `read.csv()` reads the file and returns a **data
frame** (Lesson 14). The first line becomes the column names, and R
guesses each column’s type.

**How to read the output:** three rows and three columns; `company` is
character and the counts are integers. Running `str()` straight after
reading is the habit that catches problems early: a number column read
as character means something in the file is not a clean number (Lesson
6).

### 4.4 Checking a file exists before reading

``` r
file.exists("data/snow_table9.csv")
```

    ## [1] TRUE

``` r
file.exists("data/snow_table_9.csv")
```

    ## [1] FALSE

**What it does:** answers `TRUE` or `FALSE`. When a file “cannot be
found”, this quickly tells us whether the name or path is wrong.

### 4.5 Writing our prepared data: `write.csv()`

``` r
library(MASS)
births <- birthwt
births$smoke <- factor(births$smoke, levels = c(0, 1),
                       labels = c("Non-smoker", "Smoker"))
births$bwt_kg <- births$bwt / 1000

write.csv(births, "data/births_clean.csv", row.names = FALSE)
list.files("data")
```

    ## [1] "births_clean.csv" "births_clean.rds" "pima.csv"         "snow_table9.csv" 
    ## [5] "snow_table9.tsv"

**What it does:** prepares the data as in Lesson 15, then writes it to a
CSV file in the `data` folder. `row.names = FALSE` stops R adding an
extra, unnamed column holding the row names (85, 86, …).

**Why:** now anyone, using any software, can open the cleaned data.

### 4.6 Reading it back, and a surprise

``` r
births_in <- read.csv("data/births_clean.csv")
dim(births_in)
```

    ## [1] 189  11

``` r
str(births_in[, c("smoke", "bwt", "bwt_kg")])
```

    ## 'data.frame':    189 obs. of  3 variables:
    ##  $ smoke : chr  "Non-smoker" "Non-smoker" "Smoker" "Smoker" ...
    ##  $ bwt   : int  2523 2551 2557 2594 2600 2622 2637 2637 2663 2665 ...
    ##  $ bwt_kg: num  2.52 2.55 2.56 2.59 2.6 ...

**How to read the output:** 189 rows and 11 columns, as expected. But
look at `smoke`: it was a **factor** when we saved it, and now it is
**character**. A CSV file is plain text; it stores the labels but not
the factor’s lookup card or level order. After reading a CSV, we always
re-create the factors we need:

``` r
births_in$smoke <- factor(births_in$smoke, levels = c("Non-smoker", "Smoker"))
levels(births_in$smoke)
```

    ## [1] "Non-smoker" "Smoker"

### 4.7 Saving an R object exactly: `saveRDS()` and `readRDS()`

``` r
saveRDS(births, "data/births_clean.rds")
births_rds <- readRDS("data/births_clean.rds")
class(births_rds$smoke)
```

    ## [1] "factor"

**What it does:** an **RDS** file stores one R object exactly as it is,
factors and all. It can only be read by R, so we use CSV to share data
with others and RDS to pass data between our own scripts.

### 4.8 Missing values in files: `na.strings`

Files mark missing values in different ways: an empty cell, `NA`, `-`,
`.` or `999`. Let us save the Pima diabetes data (Lesson 9) with missing
values written as **empty cells**, as Excel often does, and read it
back:

``` r
write.csv(Pima.tr2, "data/pima.csv", row.names = FALSE, na = "")
pima <- read.csv("data/pima.csv", na.strings = "")
sum(is.na(pima$skin))
```

    ## [1] 98

**What it does:** `na = ""` writes each `NA` as an empty cell.
`na.strings = ""` tells `read.csv()` that an empty cell means “missing”.

**How to read the output:** 98 missing skin-fold values, the same as in
Lesson 9: nothing was lost. Always check how missing values are written
in a new file, then tell `read.csv()`. For example, a file using `-` or
`999` would need `na.strings = c("-", "999")`.

### 4.9 Tab-separated files: `read.delim()`

Many genomics files, such as downloads from the GWAS Catalog, use
**tabs** instead of commas between columns (often with the extension
`.tsv` or `.txt`). R reads them with `read.delim()`:

``` r
write.table(snow, "data/snow_table9.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
read.delim("data/snow_table9.tsv")
```

    ##              company deaths houses
    ## 1 Southwark_Vauxhall   1263  40046
    ## 2            Lambeth     98  26107
    ## 3     Rest_of_London   1422 256423

**What it does:** `write.table()` with `sep = "\t"` (`\t` means a tab)
writes a tab-separated file, and `read.delim()` reads it back.

### 4.10 Excel files: `readxl` and `writexl`

Base R cannot read Excel files. Two small packages do it. Install them
once (Lesson 5):

``` r
#install.packages(c("readxl", "writexl"))
```

``` r
library(writexl, lib.loc = "C:/R/library")
library(readxl)
write_xlsx(births, "data/births_clean.xlsx")
births_xl <- read_excel("data/births_clean.xlsx")
dim(births_xl)
```

    ## [1] 189  11

``` r
class(births_xl)
```

    ## [1] "tbl_df"     "tbl"        "data.frame"

**What it does:** `write_xlsx()` saves a data frame as an Excel file;
`read_excel()` reads one. If a workbook has several sheets, choose one
with `sheet = "Sheet name"` or `sheet = 2`.

**How to read the output:** 189 rows and 11 columns. The class shows
three entries: `read_excel()` returns a **tibble**, a modern kind of
data frame that we meet properly in Lesson 24. Everything we know about
data frames still works on it.

### 4.11 Saving a results table

``` r
summary_table <- data.frame(group = levels(births$smoke),
                            n = as.vector(table(births$smoke)),
                            mean_bwt = round(c(mean(births$bwt[births$smoke == "Non-smoker"]),
                                               mean(births$bwt[births$smoke == "Smoker"]))))
summary_table
```

    ##        group   n mean_bwt
    ## 1 Non-smoker 115     3056
    ## 2     Smoker  74     2772

``` r
write.csv(summary_table, "outputs/bwt_by_smoking.csv", row.names = FALSE)
```

**What it does:** builds a small results table (Lesson 15) and saves it
in `outputs/`, ready to paste into a report. `as.vector()` turns the
counts from a table into an ordinary vector of numbers.

------------------------------------------------------------------------

## 5. Common errors

### “cannot open file … No such file or directory”

``` r
read.csv("births_clean.csv")
```

    ## Warning in file(file, "rt"): cannot open file 'births_clean.csv': No such file
    ## or directory

    ## Error in `file()`:
    ## ! cannot open the connection

R looked in the working directory, but the file is inside `data/`. Fix
the path (`"data/births_clean.csv"`), check the name with
`list.files("data")`, and make sure the project is open, so that R is
standing in the project folder.

### Backslashes in Windows paths

`read.csv("C:\Users\...")` fails because R reads `\U` as a special code.
Use forward slashes, and better still, a relative path.

### Extra column called `X`

If a CSV was written without `row.names = FALSE`, reading it back gives
an extra first column named `X` holding the old row names. Write with
`row.names = FALSE`, or remove the column with `df$X <- NULL`.

### The file is open in Excel

On Windows, R cannot overwrite a CSV file while it is open in Excel.
Close it in Excel and run the line again.

------------------------------------------------------------------------

## 6. Practice

1.  Create a project called `low-birth-weight` with `data`, `scripts`
    and `outputs` folders, as in section 3.
2.  Save `Pima.tr2` as `data/pima_raw.csv` with missing values written
    as `NA` (the default), read it back, and check that `bp` still has
    13 missing values.
3.  Save Snow’s data frame as an Excel file in `outputs/`, then read it
    back with `read_excel()`.
4.  Look at a CSV file from your own work (or download one from your
    country’s open-data portal) and read it with `read.csv()`. Run
    `str()` and check every column’s type.

<details>

<summary>

Show answers
</summary>

``` r
write.csv(Pima.tr2, "data/pima_raw.csv", row.names = FALSE)
pima_raw <- read.csv("data/pima_raw.csv")
sum(is.na(pima_raw$bp))
```

    ## [1] 13

``` r
write_xlsx(snow, "outputs/snow_table9.xlsx")
read_excel("outputs/snow_table9.xlsx")
```

    ## # A tibble: 3 × 3
    ##   company            deaths houses
    ##   <chr>               <dbl>  <dbl>
    ## 1 Southwark_Vauxhall   1263  40046
    ## 2 Lambeth                98  26107
    ## 3 Rest_of_London       1422 256423

`read.csv()` treats the text `NA` as missing by default, so no
`na.strings` argument was needed in question 2.

</details>

------------------------------------------------------------------------

## 7. Recap

R reads and writes files relative to the **working directory**, which an
**RStudio Project** sets to the project folder, so we use relative paths
such as `"data/births_clean.csv"`. `read.csv()` and `write.csv()` (with
`row.names = FALSE`) handle CSV files; `read.delim()` reads
tab-separated files; `readxl` and `writexl` handle Excel; and
`saveRDS()`/`readRDS()` keep R objects exactly. After reading any file,
run `str()`, re-create factors, and check how missing values were
written.

## 8. What comes next

We now have every skill needed for a small, complete analysis. In
**Lesson 18**, the **Level 1 capstone**, we put it all together in one
script: read the data, prepare it, check it, describe it, plot it and
save a short fact sheet on low birth weight, in a project that anyone
can re-run from start to finish.
