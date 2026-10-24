Chapter 20 — Working with Dates and Times in R
================

<script type="text/javascript" async
    src="https://polyfill.io/v3/polyfill.min.js?features=es6">
</script>

<script type="text/javascript" async
    src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
</script>

Dates and times appear in almost every kind of project: order dates,
attendance records, bookings, delivery timestamps, employee schedules,
website logs, and recurring tasks. Although dates often arrive as
character strings, treating them as ordinary text causes problems when
we sort, subtract, filter, or group them. R has dedicated classes for
calendar dates, instants in time, and elapsed durations.

In this chapter we develop these concepts from the beginning using
**base R**, then introduce the optional **`lubridate`** package. Our
examples use fictional retail, travel, workplace, and event data. No
statistics background is required.

> **Reproducibility note:** All examples use fixed example dates rather
> than relying on today’s date. We will demonstrate `Sys.Date()` and
> `Sys.time()` separately, but will not use them in assertions that
> depend on the current clock.

## 20.1 Learning objectives

By the end of this chapter, we should be able to:

1.  Distinguish text that looks like a date from an actual R date
    object.
2.  Create and parse `Date` objects with `as.Date()`.
3.  Use format codes with `format()` and `strptime()`.
4.  Extract calendar components and work with weekdays and months.
5.  Compare, sort, filter, and calculate differences between dates.
6.  Explain the difference between elapsed days and calendar months.
7.  Create and use `POSIXct` and `POSIXlt` date-time objects.
8.  Interpret time zones, UTC offsets, and daylight saving time.
9.  Use `difftime()` and distinguish elapsed time from clock time.
10. Handle missing, invalid, ambiguous, and mixed-format dates.
11. Read and write date columns safely in CSV files.
12. Perform practical date-time transformations on data frames.
13. Use optional `lubridate` helpers when the package is available.
14. Design and test reusable date-processing functions.

------------------------------------------------------------------------

## 20.2 A date is not merely a string

Consider the following text values:

``` r
date_text <- c("2026-01-03", "2025-12-30", "2026-02-01")
class(date_text)
```

    ## [1] "character"

``` r
sort(date_text)
```

    ## [1] "2025-12-30" "2026-01-03" "2026-02-01"

The values are **character strings**. Their ISO-style format happens to
sort chronologically, but this is not guaranteed for other date formats.

``` r
ambiguous_text <- c("02/01/2026", "15/12/2025", "03/11/2026")
sort(ambiguous_text)
```

    ## [1] "02/01/2026" "03/11/2026" "15/12/2025"

Lexicographic ordering is not the same as chronological ordering here.
In addition, a string such as `02/01/2026` is ambiguous: does it
represent 2 January or 1 February? We must know the source convention.

Convert unambiguous ISO-formatted strings to real dates:

``` r
dates <- as.Date(date_text)
class(dates)
```

    ## [1] "Date"

``` r
dates
```

    ## [1] "2026-01-03" "2025-12-30" "2026-02-01"

``` r
sort(dates)
```

    ## [1] "2025-12-30" "2026-01-03" "2026-02-01"

A `Date` object represents a calendar day without a time of day or time
zone. It is appropriate for birthdays, holidays, due dates, and many
other day-level records.

### Inspecting the internal representation

Base R stores `Date` values as numbers of days relative to
**1970-01-01**.

``` r
as.numeric(as.Date("1970-01-01"))
```

    ## [1] 0

``` r
as.numeric(as.Date("1970-01-02"))
```

    ## [1] 1

``` r
as.numeric(as.Date("1969-12-31"))
```

    ## [1] -1

This internal representation makes comparisons and date arithmetic
possible. We should ordinarily keep the `Date` class rather than
manually manipulating these numbers.

------------------------------------------------------------------------

## 20.3 Creating dates with `as.Date()`

The simplest approach uses ISO format `YYYY-MM-DD`:

``` r
launch_date <- as.Date("2026-05-15")
launch_date
```

    ## [1] "2026-05-15"

``` r
class(launch_date)
```

    ## [1] "Date"

We can convert vectors:

``` r
meeting_dates <- as.Date(c("2026-05-15", "2026-05-18", "2026-05-22"))
meeting_dates
```

    ## [1] "2026-05-15" "2026-05-18" "2026-05-22"

### Supplying a format explicitly

When source strings use day/month/year, we should specify that
convention:

``` r
source_dates <- c("15/05/2026", "18/05/2026", "22/05/2026")
parsed_dates <- as.Date(source_dates, format = "%d/%m/%Y")
parsed_dates
```

    ## [1] "2026-05-15" "2026-05-18" "2026-05-22"

The format argument tells R how to **read the original text**. It is not
merely a display preference.

### Important format codes

| Code | Meaning                                   | Example  |
|------|-------------------------------------------|----------|
| `%Y` | Four-digit year                           | `2026`   |
| `%y` | Two-digit year                            | `26`     |
| `%m` | Month number, 01–12                       | `05`     |
| `%d` | Day of month, 01–31                       | `15`     |
| `%b` | Abbreviated month name                    | `May`    |
| `%B` | Full month name                           | `May`    |
| `%a` | Abbreviated weekday                       | `Fri`    |
| `%A` | Full weekday                              | `Friday` |
| `%H` | Hour on 24-hour clock                     | `14`     |
| `%M` | Minute                                    | `30`     |
| `%S` | Second                                    | `09`     |
| `%z` | Numeric UTC offset                        | `+0530`  |
| `%Z` | Time-zone abbreviation (system-dependent) | `UTC`    |

Month and weekday names can depend on the operating-system locale.
Numeric formats are usually safer for exchanging data between computers.

### A different ordering

``` r
as.Date("05-15-2026", format = "%m-%d-%Y")
```

    ## [1] "2026-05-15"

``` r
as.Date("2026/05/15", format = "%Y/%m/%d")
```

    ## [1] "2026-05-15"

**Rule:** Never guess the day/month order of an undocumented data
source.

------------------------------------------------------------------------

## 20.4 Displaying dates with `format()`

Once a date is stored correctly, we can change how it appears without
changing its underlying value.

``` r
d <- as.Date("2026-05-15")
format(d, "%d/%m/%Y")
```

    ## [1] "15/05/2026"

``` r
format(d, "%Y-%m-%d")
```

    ## [1] "2026-05-15"

``` r
format(d, "%b %Y")
```

    ## [1] "May 2026"

``` r
format(d, "%A")
```

    ## [1] "Friday"

`format()` returns character text, not a `Date` object:

``` r
formatted <- format(d, "%d/%m/%Y")
class(formatted)
```

    ## [1] "character"

``` r
class(d)
```

    ## [1] "Date"

For computation, we should keep the original date variable and create
formatted text only for presentation or export.

------------------------------------------------------------------------

## 20.5 Valid, missing, and invalid dates

Missing dates are represented by `NA` of the appropriate class.

``` r
planned <- as.Date(c("2026-06-01", NA, "2026-06-05"))
planned
```

    ## [1] "2026-06-01" NA           "2026-06-05"

``` r
is.na(planned)
```

    ## [1] FALSE  TRUE FALSE

``` r
sum(is.na(planned))
```

    ## [1] 1

Invalid text should be detected rather than silently converted or
ignored.

``` r
raw_dates <- c("2026-06-01", "not a date", "2026-06-05")
parsed <- as.Date(raw_dates, format = "%Y-%m-%d")
data.frame(raw = raw_dates, parsed = parsed)
```

    ##          raw     parsed
    ## 1 2026-06-01 2026-06-01
    ## 2 not a date       <NA>
    ## 3 2026-06-05 2026-06-05

Here an invalid entry becomes `NA` when parsing fails. That does not
mean every `NA` in a dataset originated from invalid text; some entries
may have been genuinely missing.

### Distinguishing missing from malformed input

``` r
raw <- c("2026-06-01", "", "not a date", NA_character_)
parsed <- as.Date(raw, format = "%Y-%m-%d")
missing_input <- is.na(raw) | trimws(raw) == ""
invalid_input <- !missing_input & is.na(parsed)

data.frame(raw, parsed, missing_input, invalid_input)
```

    ##          raw     parsed missing_input invalid_input
    ## 1 2026-06-01 2026-06-01         FALSE         FALSE
    ## 2                  <NA>          TRUE         FALSE
    ## 3 not a date       <NA>         FALSE          TRUE
    ## 4       <NA>       <NA>          TRUE         FALSE

This distinction is useful in quality-control reports.

### Why strict validation matters

Some date-time parsers accept partial matches, and behavior around
impossible calendar dates can differ by platform. If the source must
follow an exact format, we can compare a successfully parsed date back
to its canonical representation.

``` r
parse_iso_date <- function(x) {
  stopifnot(is.character(x))
  result <- as.Date(x, format = "%Y-%m-%d")
  valid <- !is.na(x) & !is.na(result) &
    (format(result, "%Y-%m-%d") == x)
  valid[is.na(valid)] <- FALSE
  result[!valid] <- as.Date(NA)
  result
}

parse_iso_date(c("2026-02-28", "2026-02-30", "2026/02/28"))
```

    ## [1] "2026-02-28" NA           NA

This helper accepts only exact ISO-style dates that round-trip
successfully. More complex input policies may require additional checks.

------------------------------------------------------------------------

## 20.6 Comparing and sorting dates

We can use familiar comparison operators:

``` r
a <- as.Date("2026-04-10")
b <- as.Date("2026-04-15")
a < b
```

    ## [1] TRUE

``` r
a == b
```

    ## [1] FALSE

``` r
a >= b
```

    ## [1] FALSE

Sort dates:

``` r
unsorted_dates <- as.Date(c("2026-08-10", "2026-01-02", "2026-06-15"))
sort(unsorted_dates)
```

    ## [1] "2026-01-02" "2026-06-15" "2026-08-10"

``` r
order(unsorted_dates)
```

    ## [1] 2 3 1

### Filtering a data frame by date

``` r
orders <- data.frame(
  order_id = c("O01", "O02", "O03", "O04"),
  order_date = as.Date(c("2026-04-01", "2026-04-12", "2026-05-02", "2026-05-18")),
  amount = c(120, 85, 200, 60)
)

start_date <- as.Date("2026-04-01")
end_date <- as.Date("2026-04-30")

april_orders <- orders[
  orders$order_date >= start_date & orders$order_date <= end_date,
  , drop = FALSE
]
april_orders
```

    ##   order_id order_date amount
    ## 1      O01 2026-04-01    120
    ## 2      O02 2026-04-12     85

The interval is inclusive at both ends. In many software systems,
date-time filters use a half-open interval, such as `>= start` and
`< next_start`, to avoid problems with times at the end of a day.

------------------------------------------------------------------------

## 20.7 Arithmetic with dates

We can add or subtract a number of **days**:

``` r
start <- as.Date("2026-05-10")
start + 7
```

    ## [1] "2026-05-17"

``` r
start - 3
```

    ## [1] "2026-05-07"

Subtract two dates to obtain a time difference:

``` r
finish <- as.Date("2026-05-22")
finish - start
```

    ## Time difference of 12 days

``` r
as.numeric(finish - start)
```

    ## [1] 12

The result of subtracting `Date` objects is a `difftime` object.
Converting it to numeric expresses the difference in its chosen units
(days here).

### Delivery deadline example

``` r
ship_date <- as.Date("2026-09-03")
delivery_date <- as.Date("2026-09-08")
delivery_days <- as.numeric(delivery_date - ship_date)
delivery_days
```

    ## [1] 5

``` r
stopifnot(delivery_days == 5)
```

### Inclusive day counting

If we are counting all calendar dates in a period, including both
endpoints, the count may be `difference + 1`.

``` r
first_day <- as.Date("2026-09-01")
last_day <- as.Date("2026-09-05")
number_of_calendar_days <- as.integer(last_day - first_day) + 1L
number_of_calendar_days
```

    ## [1] 5

The appropriate convention depends on the task. Elapsed days and
inclusive counts are not the same thing.

------------------------------------------------------------------------

## 20.8 Sequences of dates

The `seq()` function can create daily, weekly, or monthly sequences.

``` r
seq(as.Date("2026-01-01"), as.Date("2026-01-07"), by = "day")
```

    ## [1] "2026-01-01" "2026-01-02" "2026-01-03" "2026-01-04" "2026-01-05"
    ## [6] "2026-01-06" "2026-01-07"

``` r
seq(as.Date("2026-01-01"), by = "week", length.out = 4)
```

    ## [1] "2026-01-01" "2026-01-08" "2026-01-15" "2026-01-22"

### Monthly sequences

``` r
month_starts <- seq(
  as.Date("2026-01-01"),
  as.Date("2026-06-01"),
  by = "month"
)
month_starts
```

    ## [1] "2026-01-01" "2026-02-01" "2026-03-01" "2026-04-01" "2026-05-01"
    ## [6] "2026-06-01"

Starting on the first of a month is a reliable way to generate
month-start dates. Starting on the 29th, 30th, or 31st can produce
unexpected results because months have different lengths.

### Calendar months are not fixed numbers of days

February, April, and July do not all have the same number of days.
Therefore, adding 30 days is not generally equivalent to adding one
calendar month.

``` r
as.Date("2026-01-31") + 30
```

    ## [1] "2026-03-02"

Later, `lubridate` will help us express calendar-month arithmetic
explicitly.

------------------------------------------------------------------------

## 20.9 Extracting year, month, and day

We can use `format()` to extract components:

``` r
example_dates <- as.Date(c("2026-01-05", "2026-07-18", "2026-12-30"))
year <- as.integer(format(example_dates, "%Y"))
month <- as.integer(format(example_dates, "%m"))
day <- as.integer(format(example_dates, "%d"))

data.frame(date = example_dates, year, month, day)
```

    ##         date year month day
    ## 1 2026-01-05 2026     1   5
    ## 2 2026-07-18 2026     7  18
    ## 3 2026-12-30 2026    12  30

### Weekday labels

``` r
weekdays(example_dates)
```

    ## [1] "Monday"    "Saturday"  "Wednesday"

``` r
months(example_dates)
```

    ## [1] "January"  "July"     "December"

``` r
quarters(example_dates)
```

    ## [1] "Q1" "Q3" "Q4"

The text produced by `weekdays()` and `months()` can be
locale-dependent. For machine-readable output, numeric components are
often more portable.

### Day of week as a number

``` r
format(example_dates, "%u")
```

    ## [1] "1" "6" "3"

On platforms that support `%u`, Monday is 1 and Sunday is 7. If
cross-platform portability is critical, we should document and test the
chosen convention.

### Grouping by month

``` r
sales <- data.frame(
  date = as.Date(c("2026-01-02", "2026-01-20", "2026-02-05", "2026-02-21")),
  amount = c(100, 80, 120, 140)
)
sales$year_month <- format(sales$date, "%Y-%m")
aggregate(amount ~ year_month, data = sales, FUN = sum)
```

    ##   year_month amount
    ## 1    2026-01    180
    ## 2    2026-02    260

The `YYYY-MM` representation sorts in chronological order when all
entries follow the same format.

------------------------------------------------------------------------

## 20.10 Leap years and calendar rules

A leap year usually has 366 days. In the Gregorian calendar, a year is a
leap year if it is divisible by 4, except centuries not divisible by
400.

``` r
is_leap_year <- function(year) {
  (year %% 4 == 0) & ((year %% 100 != 0) | (year %% 400 == 0))
}

is_leap_year(c(1900, 2000, 2024, 2026))
```

    ## [1] FALSE  TRUE  TRUE FALSE

Test the function:

``` r
stopifnot(identical(is_leap_year(c(1900, 2000, 2024, 2026)),
                    c(FALSE, TRUE, TRUE, FALSE)))
```

This example also demonstrates how date-related rules can be expressed
as reusable logical functions.

------------------------------------------------------------------------

## 20.11 Dates and date-times are different

A date answers: **Which calendar day?**

A date-time answers: **Which instant, or which local clock reading in a
specified time zone?**

Compare:

``` r
calendar_day <- as.Date("2026-10-23")
instant <- as.POSIXct("2026-10-23 14:30:00", tz = "UTC")

class(calendar_day)
```

    ## [1] "Date"

``` r
class(instant)
```

    ## [1] "POSIXct" "POSIXt"

A `Date` does not store the hour or minute. `POSIXct` represents
instants as seconds relative to the Unix epoch and can be displayed in
different time zones.

------------------------------------------------------------------------

## 20.12 Creating date-times with `as.POSIXct()`

``` r
meeting_utc <- as.POSIXct(
  "2026-10-23 09:00:00",
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)
meeting_utc
```

    ## [1] "2026-10-23 09:00:00 UTC"

``` r
class(meeting_utc)
```

    ## [1] "POSIXct" "POSIXt"

The `tz` argument matters. Without it, parsing can depend on the
computer’s local time-zone setting.

### POSIXct versus POSIXlt

- **POSIXct** stores date-times in a compact numeric representation and
  is usually convenient for data frames and computation.
- **POSIXlt** stores date-time components in a list-like structure and
  can expose year, month, day, hour, and related fields.

``` r
meeting_lt <- as.POSIXlt(meeting_utc, tz = "UTC")
class(meeting_lt)
```

    ## [1] "POSIXlt" "POSIXt"

``` r
meeting_lt$hour
```

    ## [1] 9

``` r
meeting_lt$min
```

    ## [1] 0

For most routine data processing, we can use `POSIXct` and extract
components with `format()`.

------------------------------------------------------------------------

## 20.13 Understanding time zones

Suppose an online meeting begins at 09:00 UTC. It is the **same
instant** for everyone, but the local clock display differs.

``` r
meeting_utc <- as.POSIXct("2026-10-23 09:00:00", tz = "UTC")
format(meeting_utc, tz = "UTC", format = "%Y-%m-%d %H:%M:%S %Z")
```

    ## [1] "2026-10-23 09:00:00 UTC"

``` r
format(meeting_utc, tz = "Asia/Kolkata", format = "%Y-%m-%d %H:%M:%S %Z")
```

    ## [1] "2026-10-23 14:30:00 IST"

The corresponding Indian local clock time is 14:30 on that date.

``` r
format(meeting_utc, tz = "Asia/Kolkata", format = "%H:%M")
```

    ## [1] "14:30"

### Converting display versus changing the instant

`format(x, tz = ...)` changes how an existing instant is **displayed**.
It does not move the instant to another point in time.

By contrast, parsing a clock reading in the wrong time zone changes the
instant that R understands the input to represent.

``` r
clock_as_utc <- as.POSIXct("2026-10-23 09:00:00", tz = "UTC")
clock_as_india <- as.POSIXct("2026-10-23 09:00:00", tz = "Asia/Kolkata")

as.numeric(difftime(clock_as_utc, clock_as_india, units = "hours"))
```

    ## [1] 5.5

These are different instants, even though the text `09:00:00` is
identical.

### Time-zone names

Prefer recognizable IANA time-zone names, such as `UTC`, `Asia/Kolkata`,
`Europe/London`, or `America/New_York`, over ambiguous abbreviations
like `IST` or `CST`.

------------------------------------------------------------------------

## 20.14 Daylight saving time: a common trap

Some regions adjust local clocks seasonally. A day containing a daylight
saving transition may have 23 or 25 elapsed hours rather than 24.

We can compare two UTC instants that correspond to local noon on
consecutive days around a spring transition in New York:

``` r
noon_before <- as.POSIXct("2026-03-07 17:00:00", tz = "UTC")
noon_after <- as.POSIXct("2026-03-08 16:00:00", tz = "UTC")

format(noon_before, tz = "America/New_York", format = "%Y-%m-%d %H:%M %Z")
```

    ## [1] "2026-03-07 12:00 EST"

``` r
format(noon_after, tz = "America/New_York", format = "%Y-%m-%d %H:%M %Z")
```

    ## [1] "2026-03-08 12:00 EDT"

``` r
as.numeric(difftime(noon_after, noon_before, units = "hours"))
```

    ## [1] 23

Both local readings are noon, but only **23 hours** elapsed. The exact
time-zone rules depend on the time-zone database installed on the
system.

### Ambiguous and nonexistent local times

During clock changes, some local times may occur twice, and others may
not occur at all. Parsing these local readings without additional
information can be ambiguous or platform-dependent.

For event logs, storing a UTC instant and the original time-zone context
is often safer than storing local clock text alone.

------------------------------------------------------------------------

## 20.15 Measuring elapsed time with `difftime()`

``` r
check_in <- as.POSIXct("2026-10-23 09:15:00", tz = "UTC")
check_out <- as.POSIXct("2026-10-23 11:45:00", tz = "UTC")

difftime(check_out, check_in, units = "mins")
```

    ## Time difference of 150 mins

``` r
difftime(check_out, check_in, units = "hours")
```

    ## Time difference of 2.5 hours

We can convert the result to a numeric value:

``` r
elapsed_hours <- as.numeric(difftime(check_out, check_in, units = "hours"))
elapsed_hours
```

    ## [1] 2.5

``` r
stopifnot(isTRUE(all.equal(elapsed_hours, 2.5)))
```

### Units and interpretation

`difftime()` supports units including seconds, minutes, hours, days, and
weeks. Its `days` represent elapsed 24-hour periods, not necessarily the
count of distinct local calendar dates crossed.

For billing, attendance, and booking systems, we must decide whether the
requirement is based on elapsed time, local clock time, or calendar
dates.

------------------------------------------------------------------------

## 20.16 Working with seconds, minutes, and hours

Adding a number to a `POSIXct` object adds that many seconds.

``` r
start_time <- as.POSIXct("2026-10-23 09:00:00", tz = "UTC")
start_time + 60       # one minute
```

    ## [1] "2026-10-23 09:01:00 UTC"

``` r
start_time + 60 * 60  # one hour
```

    ## [1] "2026-10-23 10:00:00 UTC"

``` r
start_time + 90 * 60  # ninety minutes
```

    ## [1] "2026-10-23 10:30:00 UTC"

This is **elapsed-time arithmetic**. It is not necessarily equivalent to
advancing a local clock by one hour across a daylight saving transition.

### A reusable meeting-end function

``` r
meeting_end <- function(start, minutes) {
  if (!inherits(start, "POSIXct")) {
    stop("start must be a POSIXct object")
  }
  if (!is.numeric(minutes) || length(minutes) != 1L ||
      is.na(minutes) || minutes < 0) {
    stop("minutes must be one nonnegative number")
  }
  start + minutes * 60
}

meeting_end(start_time, 75)
```

    ## [1] "2026-10-23 10:15:00 UTC"

------------------------------------------------------------------------

## 20.17 Extracting date-time components

``` r
example_instant <- as.POSIXct("2026-10-23 14:35:09", tz = "UTC")
format(example_instant, "%Y", tz = "UTC")
```

    ## [1] "2026"

``` r
format(example_instant, "%m", tz = "UTC")
```

    ## [1] "10"

``` r
format(example_instant, "%d", tz = "UTC")
```

    ## [1] "23"

``` r
format(example_instant, "%H", tz = "UTC")
```

    ## [1] "14"

``` r
format(example_instant, "%M", tz = "UTC")
```

    ## [1] "35"

``` r
format(example_instant, "%S", tz = "UTC")
```

    ## [1] "09"

We can use `as.POSIXlt()` when several components are needed:

``` r
components <- as.POSIXlt(example_instant, tz = "UTC")
components$hour
```

    ## [1] 14

``` r
components$min
```

    ## [1] 35

``` r
components$sec
```

    ## [1] 9

Remember that some internal POSIXlt components use conventions different
from printed calendar values. For example, the `mon` field is zero-based
(January is 0), and `year` is counted from 1900. Prefer `format()` when
clarity matters.

------------------------------------------------------------------------

## 20.18 Converting between Date and POSIXct

A date-time can be reduced to a calendar date in a specified time zone:

``` r
late_utc <- as.POSIXct("2026-10-23 23:30:00", tz = "UTC")
as.Date(late_utc, tz = "UTC")
```

    ## [1] "2026-10-23"

``` r
as.Date(late_utc, tz = "Asia/Kolkata")
```

    ## [1] "2026-10-24"

These dates can differ because the same instant falls on different local
calendar days.

### Date to date-time

``` r
day <- as.Date("2026-10-23")
as.POSIXct(day, tz = "UTC")
```

    ## [1] "2026-10-23 UTC"

A date alone does not specify a unique instant until a time of day and
time-zone interpretation are chosen. For business applications, we
should make these assumptions explicit.

------------------------------------------------------------------------

## 20.19 Parsing timestamps from text

Logs often contain text such as `2026-10-23 14:35:09`.

``` r
log_text <- c(
  "2026-10-23 14:35:09",
  "2026-10-23 14:42:10",
  "2026-10-23 15:01:00"
)

log_times <- as.POSIXct(
  log_text,
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)
log_times
```

    ## [1] "2026-10-23 14:35:09 UTC" "2026-10-23 14:42:10 UTC"
    ## [3] "2026-10-23 15:01:00 UTC"

### Parsing timestamps with numeric offsets

A timestamp containing an offset, such as `+0530`, identifies an instant
more precisely than a local clock reading alone.

For reliable cross-platform import, one strategy is to normalize
timestamp strings into a consistent UTC representation before further
processing. Base R support for `%z` parsing and its exact behavior can
vary by platform, so production pipelines should include tests with
representative offset-bearing inputs.

### Epoch timestamps

Many APIs store instants as Unix seconds:

``` r
epoch_seconds <- c(0, 3600, 86400)
as.POSIXct(epoch_seconds, origin = "1970-01-01", tz = "UTC")
```

    ## [1] "1970-01-01 00:00:00 UTC" "1970-01-01 01:00:00 UTC"
    ## [3] "1970-01-02 00:00:00 UTC"

The unit must be known: an API might provide seconds, milliseconds, or
microseconds. Mistaking milliseconds for seconds can produce wildly
incorrect dates.

------------------------------------------------------------------------

## 20.20 Current date and current time

R provides:

``` r
Sys.Date()
```

    ## [1] "2026-10-24"

``` r
Sys.time()
```

    ## [1] "2026-10-24 15:26:25 IST"

``` r
Sys.timezone()
```

    ## [1] "Asia/Calcutta"

The output changes depending on when and where the script runs. These
functions are useful in logging, reports, and automation, but we should
avoid making fixed-value assertions about their outputs.

### Recording run time

``` r
run_timestamp <- Sys.time()
format(run_timestamp, "%Y-%m-%d %H:%M:%S %Z")
```

    ## [1] "2026-10-24 15:26:25 IST"

For reproducible data transformations, a fixed reference date or an
explicit run-date parameter is often better than an implicit call to
`Sys.Date()`.

------------------------------------------------------------------------

## 20.21 Working with dates in data frames

Consider a fictional event-registration table:

``` r
registrations <- data.frame(
  attendee = c("A01", "A02", "A03", "A04", "A05"),
  registered = as.Date(c("2026-06-01", "2026-06-04", "2026-06-07", "2026-06-08", "2026-06-10")),
  event_date = as.Date(rep("2026-06-15", 5)),
  stringsAsFactors = FALSE
)

registrations$lead_days <- as.integer(
  registrations$event_date - registrations$registered
)
registrations
```

    ##   attendee registered event_date lead_days
    ## 1      A01 2026-06-01 2026-06-15        14
    ## 2      A02 2026-06-04 2026-06-15        11
    ## 3      A03 2026-06-07 2026-06-15         8
    ## 4      A04 2026-06-08 2026-06-15         7
    ## 5      A05 2026-06-10 2026-06-15         5

Sort by registration date:

``` r
registrations[order(registrations$registered), ]
```

    ##   attendee registered event_date lead_days
    ## 1      A01 2026-06-01 2026-06-15        14
    ## 2      A02 2026-06-04 2026-06-15        11
    ## 3      A03 2026-06-07 2026-06-15         8
    ## 4      A04 2026-06-08 2026-06-15         7
    ## 5      A05 2026-06-10 2026-06-15         5

Filter registrations made within seven days of the event:

``` r
registrations[registrations$lead_days <= 7, , drop = FALSE]
```

    ##   attendee registered event_date lead_days
    ## 4      A04 2026-06-08 2026-06-15         7
    ## 5      A05 2026-06-10 2026-06-15         5

### Handling missing dates

``` r
registrations$registered[3] <- as.Date(NA)
registrations$lead_days <- as.integer(
  registrations$event_date - registrations$registered
)

registrations
```

    ##   attendee registered event_date lead_days
    ## 1      A01 2026-06-01 2026-06-15        14
    ## 2      A02 2026-06-04 2026-06-15        11
    ## 3      A03       <NA> 2026-06-15        NA
    ## 4      A04 2026-06-08 2026-06-15         7
    ## 5      A05 2026-06-10 2026-06-15         5

``` r
sum(is.na(registrations$registered))
```

    ## [1] 1

Missing dates propagate into differences. This is preferable to silently
replacing missing dates with arbitrary values.

------------------------------------------------------------------------

## 20.22 Reading and writing date columns in CSV

CSV files store text, not R’s date class metadata. After import, we
should explicitly parse date columns.

``` r
practice_dir <- file.path(tempdir(), "r_for_everyone_ch20")
dir.create(practice_dir, recursive = TRUE, showWarnings = FALSE)

csv_path <- file.path(practice_dir, "registrations.csv")
write.csv(registrations, csv_path, row.names = FALSE, na = "")

imported <- read.csv(csv_path, stringsAsFactors = FALSE)
str(imported)
```

    ## 'data.frame':    5 obs. of  4 variables:
    ##  $ attendee  : chr  "A01" "A02" "A03" "A04" ...
    ##  $ registered: chr  "2026-06-01" "2026-06-04" "" "2026-06-08" ...
    ##  $ event_date: chr  "2026-06-15" "2026-06-15" "2026-06-15" "2026-06-15" ...
    ##  $ lead_days : int  14 11 NA 7 5

Convert the date columns:

``` r
imported$registered <- as.Date(imported$registered, format = "%Y-%m-%d")
imported$event_date <- as.Date(imported$event_date, format = "%Y-%m-%d")
str(imported)
```

    ## 'data.frame':    5 obs. of  4 variables:
    ##  $ attendee  : chr  "A01" "A02" "A03" "A04" ...
    ##  $ registered: Date, format: "2026-06-01" "2026-06-04" ...
    ##  $ event_date: Date, format: "2026-06-15" "2026-06-15" ...
    ##  $ lead_days : int  14 11 NA 7 5

### Round-trip verification

``` r
stopifnot(
  inherits(imported$registered, "Date"),
  inherits(imported$event_date, "Date"),
  identical(imported$registered, registrations$registered)
)
```

### Saving R classes with RDS

When we want to preserve R object classes, RDS is often convenient:

``` r
rds_path <- file.path(practice_dir, "registrations.rds")
saveRDS(registrations, rds_path)
restored <- readRDS(rds_path)
stopifnot(identical(restored, registrations))
```

------------------------------------------------------------------------

## 20.23 Date-time columns and time-zone-aware exports

CSV does not automatically preserve the time-zone attribute of a
`POSIXct` column. We should specify a consistent export convention, such
as UTC with a clearly documented format.

``` r
activity <- data.frame(
  event_id = c("E1", "E2"),
  event_time = as.POSIXct(
    c("2026-10-23 09:00:00", "2026-10-23 10:30:00"),
    tz = "UTC"
  )
)

activity$event_time_utc <- format(
  activity$event_time,
  format = "%Y-%m-%dT%H:%M:%SZ",
  tz = "UTC"
)
activity
```

    ##   event_id          event_time       event_time_utc
    ## 1       E1 2026-10-23 09:00:00 2026-10-23T09:00:00Z
    ## 2       E2 2026-10-23 10:30:00 2026-10-23T10:30:00Z

The final `Z` in this explicitly UTC-formatted text indicates UTC. We
should only append it when the value has actually been converted or
formatted in UTC.

``` r
activity_path <- file.path(practice_dir, "activity_utc.csv")
write.csv(activity[c("event_id", "event_time_utc")],
          activity_path, row.names = FALSE)

activity_read <- read.csv(activity_path, stringsAsFactors = FALSE)
activity_read$parsed_utc <- as.POSIXct(
  activity_read$event_time_utc,
  format = "%Y-%m-%dT%H:%M:%SZ",
  tz = "UTC"
)
activity_read
```

    ##   event_id       event_time_utc          parsed_utc
    ## 1       E1 2026-10-23T09:00:00Z 2026-10-23 09:00:00
    ## 2       E2 2026-10-23T10:30:00Z 2026-10-23 10:30:00

Verify that the original instants were preserved:

``` r
stopifnot(isTRUE(all.equal(
  as.numeric(activity_read$parsed_utc),
  as.numeric(activity$event_time)
)))
```

------------------------------------------------------------------------

## 20.24 Working with incomplete dates

Sometimes a dataset records only a year or a year and month:

``` r
month_label <- c("2026-01", "2026-02", "2026-03")
```

These are **not complete dates**. If we need a representative date for
monthly grouping, we can explicitly choose the first day of each month:

``` r
month_start <- as.Date(paste0(month_label, "-01"))
month_start
```

    ## [1] "2026-01-01" "2026-02-01" "2026-03-01"

This is a convention, not evidence that an event happened on the first
day. Keep the original month-level information when its precision
matters.

### Partial dates should not imply false precision

If a source provides only `2026`, converting it to `2026-01-01` may be
convenient for plotting, but it does not establish an actual event date.
Document such conversions.

------------------------------------------------------------------------

## 20.25 Business days and weekends

We may need to identify weekdays, weekends, or work schedules.

``` r
week_dates <- seq(as.Date("2026-10-19"), by = "day", length.out = 7)
weekday_number <- as.integer(format(week_dates, "%u"))
weekend <- weekday_number %in% c(6L, 7L)

data.frame(date = week_dates, weekday_number, weekend)
```

    ##         date weekday_number weekend
    ## 1 2026-10-19              1   FALSE
    ## 2 2026-10-20              2   FALSE
    ## 3 2026-10-21              3   FALSE
    ## 4 2026-10-22              4   FALSE
    ## 5 2026-10-23              5   FALSE
    ## 6 2026-10-24              6    TRUE
    ## 7 2026-10-25              7    TRUE

This example uses the `%u` convention and assumes Saturday/Sunday
weekends. Workweek rules vary across countries and organizations, and
holidays require a separate calendar.

### Count weekdays in a date range

``` r
all_days <- seq(as.Date("2026-10-19"), as.Date("2026-10-30"), by = "day")
weekday_numbers <- as.integer(format(all_days, "%u"))
sum(weekday_numbers <= 5L)
```

    ## [1] 10

This counts Monday through Friday but **does not exclude public
holidays**.

------------------------------------------------------------------------

## 20.26 The optional `lubridate` package

The `lubridate` package provides readable helpers for parsing,
extracting components, and doing calendar-aware arithmetic.

Install it once, when permitted by the computer’s package policies:

``` r
install.packages("lubridate")
```

Installation is not performed when knitting this chapter. We first check
whether the package is available:

``` r
has_lubridate <- requireNamespace("lubridate", quietly = TRUE)
has_lubridate
```

    ## [1] TRUE

The remaining package examples use `requireNamespace()` and are skipped
when the package is unavailable. All earlier base-R material remains
fully usable without it.

------------------------------------------------------------------------

## 20.27 Parsing with `ymd()`, `dmy()`, and `mdy()`

The function names indicate the component order:

``` r
if (has_lubridate) {
  lubridate::ymd("2026-10-23")
  lubridate::dmy("23/10/2026")
  lubridate::mdy("10/23/2026")
} else {
  message("Skipping lubridate parsing examples: package not installed.")
}
```

    ## [1] "2026-10-23"

These helpers can recognize several common delimiters. Nevertheless,
ambiguous inputs still require a known source convention.

### Parsing date-times

``` r
if (has_lubridate) {
  lubridate::ymd_hms("2026-10-23 09:15:30", tz = "UTC")
  lubridate::dmy_hm("23/10/2026 14:30", tz = "Asia/Kolkata")
}
```

    ## [1] "2026-10-23 14:30:00 IST"

We should provide a time zone explicitly when interpreting local clock
readings.

------------------------------------------------------------------------

## 20.28 Extracting components with lubridate

``` r
if (has_lubridate) {
  d <- as.Date("2026-10-23")
  lubridate::year(d)
  lubridate::month(d)
  lubridate::day(d)
  lubridate::wday(d, week_start = 1)
  lubridate::yday(d)
  lubridate::quarter(d)
}
```

    ## [1] 4

The `week_start` argument controls which weekday is considered the
beginning of the week. This matters when comparing numeric weekday
values across codebases.

### Month and year labels

``` r
if (has_lubridate) {
  d <- as.Date(c("2026-01-15", "2026-02-15"))
  lubridate::month(d, label = TRUE, abbr = TRUE)
}
```

    ## [1] Jan Feb
    ## 12 Levels: Jan < Feb < Mar < Apr < May < Jun < Jul < Aug < Sep < ... < Dec

Names can still depend on locale settings.

------------------------------------------------------------------------

## 20.29 Durations, periods, and intervals

One of the most important `lubridate` distinctions is between **elapsed
time** and **calendar time**.

- A **duration** is an exact elapsed number of seconds.
- A **period** expresses calendar components such as months, days, or
  years.
- An **interval** has a start and end instant.

``` r
if (has_lubridate) {
  origin <- lubridate::ymd_hms("2026-03-07 12:00:00", tz = "UTC")
  origin + lubridate::dhours(24)
  origin + lubridate::days(1)
}
```

    ## [1] "2026-03-08 12:00:00 UTC"

These may look identical in UTC, but calendar arithmetic and elapsed
arithmetic can differ around daylight saving transitions.

### Calendar months

``` r
if (has_lubridate) {
  jan31 <- lubridate::ymd("2026-01-31")
  jan31 + lubridate::period(months = 1)
  lubridate::`%m+%`(jan31, lubridate::period(months = 1))
}
```

    ## [1] "2026-02-28"

Ordinary calendar-month addition can produce an invalid date when the
destination month lacks the original day number. The special `%m+%`
operator uses rollback behavior, giving a practical end-of-month
convention.

**Important:** We must select the correct rule for the task.
Subscription billing, payroll, and appointment recurrence can have
different policies for month-end dates.

------------------------------------------------------------------------

## 20.30 `with_tz()` versus `force_tz()`

These functions address different questions.

- `with_tz()` displays the **same instant** in another time zone.
- `force_tz()` reinterprets the existing clock reading as belonging to
  another time zone, potentially changing the instant.

``` r
if (has_lubridate) {
  x <- lubridate::ymd_hms("2026-10-23 09:00:00", tz = "UTC")
  lubridate::with_tz(x, "Asia/Kolkata")
  lubridate::force_tz(x, "Asia/Kolkata")
}
```

    ## [1] "2026-10-23 09:00:00 IST"

Confusing these operations can shift recorded events by hours. In a
log-processing pipeline, we should document whether timestamps represent
UTC instants or local clock readings.

------------------------------------------------------------------------

## 20.31 Rounding and grouping timestamps

We may want to group events into hours or days.

``` r
if (has_lubridate) {
  events <- lubridate::ymd_hms(
    c("2026-10-23 09:10:00", "2026-10-23 09:55:00", "2026-10-23 10:05:00"),
    tz = "UTC"
  )
  lubridate::floor_date(events, unit = "hour")
  lubridate::ceiling_date(events, unit = "hour")
  lubridate::round_date(events, unit = "hour")
}
```

    ## [1] "2026-10-23 09:00:00 UTC" "2026-10-23 10:00:00 UTC"
    ## [3] "2026-10-23 10:00:00 UTC"

Rounding, flooring, and ceiling are not interchangeable. For
aggregation, `floor_date()` is often useful because each event is
assigned to the start of its time bucket.

### Base-R alternative

``` r
events_base <- as.POSIXct(
  c("2026-10-23 09:10:00", "2026-10-23 09:55:00", "2026-10-23 10:05:00"),
  tz = "UTC"
)
format(events_base, "%Y-%m-%d %H:00", tz = "UTC")
```

    ## [1] "2026-10-23 09:00" "2026-10-23 09:00" "2026-10-23 10:00"

This base-R example creates hour labels for grouping. It returns
character strings rather than `POSIXct` bucket boundaries.

------------------------------------------------------------------------

## 20.32 Common errors and how to fix them

### Error 1: comparing strings instead of dates

``` r
text_values <- c("9/1/2026", "10/1/2026")
sort(text_values)
```

    ## [1] "10/1/2026" "9/1/2026"

Convert using the documented format before sorting:

``` r
sort(as.Date(text_values, format = "%m/%d/%Y"))
```

    ## [1] "2026-09-01" "2026-10-01"

### Error 2: forgetting the input format

A value such as `03/04/2026` cannot be interpreted safely without
knowing whether the source uses day/month/year or month/day/year.

### Error 3: treating months as 30 days

Calendar months have different lengths. Use explicit calendar rules for
monthly schedules.

### Error 4: assuming every day has 24 elapsed hours

Daylight saving transitions can make local calendar days shorter or
longer.

### Error 5: losing time-zone information during export

CSV does not preserve the full `POSIXct` class metadata. Export an
explicitly documented timestamp convention, preferably UTC with an
offset or UTC marker.

### Error 6: treating malformed input as genuinely missing

Keep separate indicators for empty source values and values that fail
parsing.

### Error 7: interpreting epoch milliseconds as seconds

Check the unit documented by the API. Convert milliseconds to seconds
before using `as.POSIXct(..., origin = "1970-01-01")`.

### Error 8: changing the display time zone when we intended to reinterpret the clock

Use conversion and reinterpretation operations deliberately; they are
not equivalent.

### Error 9: assuming imported CSV date columns retain the Date class

Reparse them explicitly after import and verify their classes.

### Error 10: using the current date in reproducibility tests

Use fixed test inputs and make the reference date an explicit parameter.

------------------------------------------------------------------------

## 20.33 Guided project: event booking and attendance

We will build a small event-management workflow. It demonstrates
parsing, date arithmetic, timestamp handling, sorting, validation, and
file export.

### Step 1: create fictional source data

``` r
bookings_raw <- data.frame(
  booking_id = c("B001", "B002", "B003", "B004", "B005"),
  booked_on = c("01/10/2026", "05/10/2026", "08/10/2026", "", "12/10/2026"),
  event_date = c("23/10/2026", "23/10/2026", "24/10/2026", "24/10/2026", "25/10/2026"),
  check_in_utc = c("2026-10-23 08:55:00", "2026-10-23 09:10:00",
                   "2026-10-24 10:05:00", NA, "2026-10-25 12:30:00"),
  stringsAsFactors = FALSE
)
bookings_raw
```

    ##   booking_id  booked_on event_date        check_in_utc
    ## 1       B001 01/10/2026 23/10/2026 2026-10-23 08:55:00
    ## 2       B002 05/10/2026 23/10/2026 2026-10-23 09:10:00
    ## 3       B003 08/10/2026 24/10/2026 2026-10-24 10:05:00
    ## 4       B004            24/10/2026                <NA>
    ## 5       B005 12/10/2026 25/10/2026 2026-10-25 12:30:00

### Step 2: parse the date fields

``` r
bookings <- bookings_raw
bookings$booked_on <- as.Date(bookings$booked_on, format = "%d/%m/%Y")
bookings$event_date <- as.Date(bookings$event_date, format = "%d/%m/%Y")
bookings$check_in_utc <- as.POSIXct(
  bookings$check_in_utc,
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)
str(bookings)
```

    ## 'data.frame':    5 obs. of  4 variables:
    ##  $ booking_id  : chr  "B001" "B002" "B003" "B004" ...
    ##  $ booked_on   : Date, format: "2026-10-01" "2026-10-05" ...
    ##  $ event_date  : Date, format: "2026-10-23" "2026-10-23" ...
    ##  $ check_in_utc: POSIXct, format: "2026-10-23 08:55:00" "2026-10-23 09:10:00" ...

### Step 3: validate identifiers and dates

``` r
stopifnot(
  !anyDuplicated(bookings$booking_id),
  all(!is.na(bookings$event_date)),
  inherits(bookings$booked_on, "Date"),
  inherits(bookings$check_in_utc, "POSIXct")
)
```

### Step 4: calculate booking lead time

``` r
bookings$lead_days <- as.integer(
  bookings$event_date - bookings$booked_on
)
bookings$lead_days
```

    ## [1] 22 18 16 NA 13

### Step 5: flag records for review

``` r
bookings$needs_review <- is.na(bookings$booked_on) |
  (!is.na(bookings$lead_days) & bookings$lead_days < 0)
bookings[c("booking_id", "lead_days", "needs_review")]
```

    ##   booking_id lead_days needs_review
    ## 1       B001        22        FALSE
    ## 2       B002        18        FALSE
    ## 3       B003        16        FALSE
    ## 4       B004        NA         TRUE
    ## 5       B005        13        FALSE

### Step 6: derive local check-in dates

``` r
bookings$check_in_india_date <- as.Date(
  bookings$check_in_utc,
  tz = "Asia/Kolkata"
)
bookings[c("booking_id", "check_in_utc", "check_in_india_date")]
```

    ##   booking_id        check_in_utc check_in_india_date
    ## 1       B001 2026-10-23 08:55:00          2026-10-23
    ## 2       B002 2026-10-23 09:10:00          2026-10-23
    ## 3       B003 2026-10-24 10:05:00          2026-10-24
    ## 4       B004                <NA>                <NA>
    ## 5       B005 2026-10-25 12:30:00          2026-10-25

### Step 7: summarize bookings by event day

``` r
bookings_per_day <- aggregate(
  booking_id ~ event_date,
  data = bookings,
  FUN = length
)
names(bookings_per_day)[2] <- "n_bookings"
bookings_per_day
```

    ##   event_date n_bookings
    ## 1 2026-10-23          2
    ## 2 2026-10-24          2
    ## 3 2026-10-25          1

### Step 8: save outputs

``` r
bookings_rds <- file.path(practice_dir, "bookings_processed.rds")
bookings_summary_csv <- file.path(practice_dir, "bookings_per_day.csv")

saveRDS(bookings, bookings_rds)
write.csv(bookings_per_day, bookings_summary_csv, row.names = FALSE)

stopifnot(file.exists(bookings_rds), file.exists(bookings_summary_csv))
```

### Step 9: verify the saved object

``` r
bookings_restored <- readRDS(bookings_rds)
stopifnot(identical(bookings, bookings_restored))
```

### Interpretation

We have built a repeatable workflow:

**Text input → Explicit parsing → Validation → Calendar calculations →
Time-zone conversion → Summary → Export.**

The same structure is useful for appointments, project milestones,
attendance, delivery tracking, and activity logs.

------------------------------------------------------------------------

## 20.34 Reusable functions for date processing

### Function 1: validate ISO dates

``` r
is_valid_iso_date <- function(x) {
  stopifnot(is.character(x))
  parsed <- parse_iso_date(x)
  !is.na(parsed)
}

is_valid_iso_date(c("2026-12-31", "2026-02-30", "not a date", NA))
```

    ## [1]  TRUE FALSE FALSE FALSE

### Function 2: calculate elapsed days

``` r
days_between <- function(start, end) {
  if (!inherits(start, "Date") || !inherits(end, "Date")) {
    stop("start and end must be Date objects")
  }
  as.numeric(difftime(end, start, units = "days"))
}

days_between(as.Date("2026-01-01"), as.Date("2026-01-11"))
```

    ## [1] 10

### Function 3: classify deadlines

``` r
deadline_status <- function(deadline, reference_date) {
  if (!inherits(deadline, "Date") ||
      !inherits(reference_date, "Date") ||
      length(reference_date) != 1L || is.na(reference_date)) {
    stop("Expected Date deadlines and one nonmissing Date reference")
  }

  result <- ifelse(
    is.na(deadline), "Missing",
    ifelse(deadline < reference_date, "Overdue",
           ifelse(deadline == reference_date, "Due today", "Upcoming"))
  )
  result
}

deadline_status(
  as.Date(c("2026-10-20", "2026-10-23", "2026-10-25", NA)),
  as.Date("2026-10-23")
)
```

    ## [1] "Overdue"   "Due today" "Upcoming"  "Missing"

### Why parameterizing the reference date matters

Passing the reference date into a function makes it easier to test and
reproduce. The same input values then produce the same output,
regardless of when the script runs.

------------------------------------------------------------------------

## 20.35 Exercises: beginner level

1.  Create a `Date` object representing 15 August 2026.
2.  Convert the string `"23/10/2026"` into a `Date` using an explicit
    format.
3.  Display a date as `"October 2026"`.
4.  Explain the difference between `Date` and character strings.
5.  Find the number of elapsed days between 1 January and 15 January
    2026.
6.  Create seven consecutive dates beginning on 1 November 2026.
7.  Extract year, month, and day from a vector of dates.
8.  Sort a vector of unsorted dates.
9.  Identify missing values in a date vector.
10. Explain why `"02/03/2026"` is ambiguous without documentation.
11. Determine whether 2000, 1900, 2024, and 2026 are leap years.
12. Explain the difference between a calendar date and an instant in
    time.

## 20.36 Exercises: intermediate level

1.  Create a data frame with five order dates and delivery dates.
2.  Calculate delivery delays in days.
3.  Flag orders delivered more than seven days after placement.
4.  Group order amounts by year and month.
5.  Generate the first day of each month in 2026.
6.  Identify weekends in a sequence of dates.
7.  Import a CSV containing dates as character text and parse them.
8.  Export the parsed data as RDS and verify restoration.
9.  Parse a UTC timestamp and display it in `Asia/Kolkata`.
10. Calculate elapsed minutes between two timestamps.
11. Create a function that accepts a deadline and a fixed reference
    date.
12. Compare an empty source date with a malformed source date.

## 20.37 Exercises: advanced level

1.  Write a strict ISO-date parser that flags malformed inputs.
2.  Create a time-zone-aware event-log data frame with timestamps in
    UTC.
3.  Export timestamps in an unambiguous UTC text format and import them
    again.
4.  Verify that imported instants match original epoch seconds.
5.  Design a monthly billing-date rule for subscriptions starting on the
    31st.
6.  Explain why adding 30 days does not always mean adding one month.
7.  Demonstrate a daylight saving transition using a time zone that
    observes it.
8.  Compare calendar dates across UTC and `Asia/Kolkata` for an event
    near midnight UTC.
9.  Write tests for missing timestamps, duplicate event IDs, and
    negative durations.
10. If `lubridate` is installed, compare `with_tz()` and `force_tz()`.
11. If `lubridate` is installed, compare duration and period arithmetic.
12. Build an hourly event-count table using base R.

------------------------------------------------------------------------

## 20.38 Challenge project: employee attendance system

Design a small attendance-processing script that:

1.  Creates a fictional employee table with IDs, departments, and shift
    start times.
2.  Imports a CSV of clock-in and clock-out timestamps.
3.  Parses timestamps using an explicit time zone.
4.  Validates that each clock-out is after its clock-in.
5.  Calculates elapsed hours for each shift.
6.  Flags missing or malformed timestamps.
7.  Identifies shifts longer than a configurable threshold.
8.  Groups total elapsed hours by employee.
9.  Exports a clean summary table.
10. Saves a class-preserving RDS version.
11. Includes a reproducible test using fixed example timestamps.
12. Documents how overnight shifts and daylight saving transitions
    should be handled.

The objective is to practice R programming, not payroll or labor-law
calculations. Real attendance systems require additional business rules.

------------------------------------------------------------------------

## 20.39 Complete standalone practice script

The following script demonstrates the main concepts in one place. It is
not executed during knitting because the chapter has already run the
individual examples.

``` r
# ============================================================
# R for Everyone — Chapter 20
# Working with Dates and Times in R
# Base R only; fictional example data
# ============================================================

# 1. Create dates
orders <- data.frame(
  order_id = c("O001", "O002", "O003", "O004"),
  ordered_text = c("01/10/2026", "03/10/2026", "05/10/2026", ""),
  delivered_text = c("05/10/2026", "07/10/2026", "11/10/2026", "12/10/2026"),
  stringsAsFactors = FALSE
)

# 2. Parse dates explicitly
orders$ordered <- as.Date(orders$ordered_text, format = "%d/%m/%Y")
orders$delivered <- as.Date(orders$delivered_text, format = "%d/%m/%Y")

# 3. Calculate elapsed days
orders$delivery_days <- as.integer(orders$delivered - orders$ordered)

# 4. Create review flags
orders$missing_order_date <- is.na(orders$ordered)
orders$long_delivery <- !is.na(orders$delivery_days) &
  orders$delivery_days > 5

# 5. Validate
stopifnot(
  !anyDuplicated(orders$order_id),
  all(!is.na(orders$delivered)),
  inherits(orders$ordered, "Date")
)

# 6. Work with UTC instants
started <- as.POSIXct("2026-10-23 09:00:00", tz = "UTC")
finished <- as.POSIXct("2026-10-23 10:30:00", tz = "UTC")
elapsed_minutes <- as.numeric(difftime(finished, started, units = "mins"))
stopifnot(elapsed_minutes == 90)

# 7. Display the same instant in another time zone
india_time <- format(started, tz = "Asia/Kolkata",
                     format = "%Y-%m-%d %H:%M:%S %Z")

# 8. Save outputs to a disposable directory
out_dir <- file.path(tempdir(), "r_for_everyone_ch20_standalone")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

csv_path <- file.path(out_dir, "orders.csv")
rds_path <- file.path(out_dir, "orders.rds")
write.csv(orders, csv_path, row.names = FALSE, na = "")
saveRDS(orders, rds_path)

# 9. Verify saved R object
restored <- readRDS(rds_path)
stopifnot(identical(orders, restored))

# 10. Inspect results
print(orders)
print(elapsed_minutes)
print(india_time)
print(list.files(out_dir))
```

------------------------------------------------------------------------

## 20.40 Essential functions reference

| Function                  | Main purpose                             |
|---------------------------|------------------------------------------|
| `as.Date()`               | Parse or convert calendar dates          |
| `format()`                | Format dates and date-times as text      |
| `strptime()`              | Parse text into date-time components     |
| `as.POSIXct()`            | Create or convert date-time instants     |
| `as.POSIXlt()`            | Access date-time components              |
| `difftime()`              | Calculate elapsed time                   |
| `seq()`                   | Create sequences of dates or times       |
| `weekdays()`              | Obtain weekday names                     |
| `months()`                | Obtain month names                       |
| `quarters()`              | Obtain quarter labels                    |
| `Sys.Date()`              | Obtain current system date               |
| `Sys.time()`              | Obtain current system date-time          |
| `Sys.timezone()`          | Inspect system time-zone setting         |
| `is.na()`                 | Detect missing values                    |
| `sort()`                  | Sort dates or times                      |
| `order()`                 | Obtain sorting indices                   |
| `lubridate::ymd()`        | Parse year-month-day text                |
| `lubridate::dmy()`        | Parse day-month-year text                |
| `lubridate::mdy()`        | Parse month-day-year text                |
| `lubridate::ymd_hms()`    | Parse timestamps                         |
| `lubridate::year()`       | Extract year                             |
| `lubridate::month()`      | Extract month                            |
| `lubridate::day()`        | Extract day                              |
| `lubridate::with_tz()`    | Display the same instant in another zone |
| `lubridate::force_tz()`   | Reinterpret a local clock reading        |
| `lubridate::floor_date()` | Round down to a calendar boundary        |
| `lubridate::`%m+%\`\`     | Add calendar months with rollback        |

------------------------------------------------------------------------

## 20.41 Chapter review questions

1.  What is the difference between a character date and a `Date` object?
2.  Why should we specify an input format for non-ISO dates?
3.  What does `%Y` represent? What does `%m` represent?
4.  What class does `format()` return?
5.  How does R internally represent a `Date`?
6.  What does subtracting two `Date` objects produce?
7.  How do elapsed days differ from inclusive calendar-day counts?
8.  Why is adding 30 days not equivalent to adding one month?
9.  What is the difference between `POSIXct` and `POSIXlt`?
10. Why is a time zone necessary when parsing local clock readings?
11. What is the difference between changing a timestamp’s display zone
    and changing its interpreted instant?
12. Why can a local day contain 23 or 25 elapsed hours?
13. How do we calculate elapsed minutes between two timestamps?
14. Why should timestamp export formats include a time-zone convention?
15. How can a date-time correspond to different calendar dates in
    different zones?
16. What is the difference between an invalid date and a missing source
    value?
17. Why should CSV-imported date columns be checked and parsed
    explicitly?
18. What is the difference between `lubridate` durations and periods?
19. Why should tests use fixed reference dates instead of `Sys.Date()`?
20. How can we make a date-processing function reusable and testable?

## 20.42 Key takeaways

- A date-looking string is not necessarily a date object.
- `Date` is designed for calendar days; `POSIXct` is designed for
  instants.
- Parsing and formatting are separate operations.
- Ambiguous source formats require documentation rather than guessing.
- Calendar arithmetic and elapsed-time arithmetic answer different
  questions.
- Time zones are essential for correctly interpreting timestamps.
- Daylight saving changes can alter elapsed hours between local clock
  readings.
- CSV does not preserve all R date-time class information; RDS does.
- Base R provides a complete foundation for common date and time tasks.
- `lubridate` adds convenient parsing, calendar operations, and
  time-zone helpers.
- Reliable date-processing code should validate inputs, preserve
  missingness, and use explicit assumptions.

## 20.43 Looking ahead: Chapter 21 — Advanced Functions and Functional Programming

In Chapter 21 we will deepen our understanding of functions, lexical
scoping, closures, function factories, higher-order functions, and
functional programming patterns. We will revisit the apply family and
introduce `purrr` as an optional modern interface for iteration.
