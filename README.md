
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reviewer

Improving the track changes and reviewing experience in R markdown

## Installation

You can install the development version of `reviewer` from
[GitHub](https://github.com/ropenscilabs/reviewer) with:

``` r
remotes::install_github("ropenscilabs/reviewer")
```

## Annotating web pages

### Important note

In order to use the annotation functionality it is needed to sign-up at
[the Hypothe.is website](https://hypothes.is/signup)

-----

## Differences between rmarkdown files

The `diff_rmd` function can be used to produce a nicely-formatted
document showing the differences between two rmarkdown files. For the
purposes of demonstration, we’ll use the example files bundled with the
package. We’ll compare `modified_file` to its earlier version
`reference_file`:

``` r
modified_file <- system.file("extdata/CheatSheet-modified.Rmd", package = "reviewer")
reference_file <- system.file("extdata/CheatSheet.Rmd", package = "reviewer")
```

\[Placeholder: output to go here\]

Compare:

``` r
library(reviewer)
result <- diff_rmd(modified_file, reference_file)
```

We can also compare the current version of a document to a previous
version in stored in a git repository. (These examples are not run
here).

If a `reference_file` argument is not provided, by default the
`modified_file` will be compared to the most recent copy in the git
repo:

``` r
result <- diff_rmd(modified_file)
```

Or we can compare it to how it appeared in the git repository after a
particular commit (here, the commit with reference 750ab4):

``` r
result <- diff_rmd(modified_file, "750ab4")
```
