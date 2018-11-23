
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
document showing the differences between two rmarkdown files. This
function can be used to compare two files, or a file with previous
versions of itself (within a git repository).

See the [package
vignette](https://ropenscilabs.github.io/reviewer/articles/reviewer.html)
for a demonstration.

## Related packages

  - [trackmd](https://github.com/ropenscilabs/trackmd) is similar to
    `reviewer`, but:
    
      - is an RStudio-specific addin, whereas `reviewer` can be used
        outside of the RStudio environment (e.g. with your preferred
        text editor)
      - shows changes only in the *rendered* rmarkdown file (i.e. once
        it has been converted to its HTML document format). `reviewer`
        can show changes in either the raw rmarkdown document or its
        rendered output.

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
