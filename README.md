
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
