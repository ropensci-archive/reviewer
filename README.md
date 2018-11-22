
<!-- README.md is generated from README.Rmd. Please edit that file -->

# reviewer

Improving the track changes and reviewing experience in R markdown.
`reviewer` provides two main functions:

  - an RStudio addin that adds the required JavaScript code to an
    rmarkdown document, so that when rendered to HTML it can be
    annotated using the Hypothes.is service
  - the capability to compare two versions of an rmarkdown document and
    display their differences in a nicely-formatted manner.

## Installation

You can install the development version of `reviewer` from
[GitHub](https://github.com/ropenscilabs/reviewer) with:

``` r
remotes::install_github("ropenscilabs/reviewer")
```

## Annotating web pages

### Important note

In order to use the annotation functionality it is needed to sign-up at
[the Hypothes.is website](https://hypothes.is/signup)

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

Compare:

``` r
library(reviewer)
result <- diff_rmd(modified_file, reference_file)
```

And our output (note that the styling is different in the GitHub README
to the output you will see in a standalone HTML document output):

<!--html_preserve-->

<pre id = "diffcontent">
---
title: "Git Cheat Sheet"
author: "Amy Stringer"
date: "06/01/2018"
output: pdf_document
---

<ins class="ins">&lt;!-- this file has been edited just for demonstration purposes within the reviewer package --&gt;</ins>

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = <del class="del">TRUE)</del><ins class="ins">TRUE, warning = FALSE)</ins>
```

Git is a type of version control software that stores the history of changes made to files in a particular repository. <del class="del">Contained within is</del><ins class="ins">This document contains</ins> a brief rundown of the main commands used within the terminal to run git from your personal computer. Towards the end there will be details on how to use git to collaborate with <del class="del">others on files by</del><ins class="ins">other people</ins> using GitHub.
</pre>

<!--/html_preserve-->

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

## Related packages

  - [trackmd](https://github.com/ropenscilabs/trackmd) is similar to
    `reviewer`, but:
    
      - is an RStudio-specific addin, whereas `reviewer` can be used
        outside of the RStudio environment (e.g. with your preferred
        text editor)
      - shows changes in the *rendered* rmarkdown file (i.e. once it has
        been converted to its HTML document format). `reviewer` shows
        changes in the raw rmarkdown document.

  - [latexdiffr](https://github.com/hughjonesd/latexdiffr) similarly
    shows differences in the *rendered* document, but uses the
    `latexdiff` utility to do so (you need `latexdiff` installed on your
    system to use it). It can also be used outside of RStudio.

  - [diffobj](https://github.com/brodieG/diffobj) provides a colourized
    depiction of the differences between arbitrary R objects. This could
    be used to compare two rmarkdown documents by e.g. reading their
    contents into character vectors and applying the `diffChr` function.

  - [rmdrive](https://github.com/ekothe/rmdrive) allows easy
    round-tripping of an rmarkdown document to Google Drive, where it
    can be edited by non-R-using collaborators, and back again. The
    edited changes could then be viewed using `reviewer`.

  - [markdrive](https://github.com/MilesMcBain/markdrive) is similar to
    `rmdrive`, but pushes the *rendered* rmarkdown document to and from
    Google.
