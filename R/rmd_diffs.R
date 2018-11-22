#' Render the differences between two rmarkdown files
#'
#' @param current_file string: path to file after changes
#' @param reference_file string: path to file before changes
#' @param show string: \code{"raw"} (show differences in the raw rmarkdown file) or \code{"rendered"} (show differences in the rendered output)
#' @param output_format string: format of the output file (currently only \code{"html_document"})
#' @param keep_intermediate logical: keep the intermediate rmarkdown file?
#' @param quiet logical: if \code{TRUE}, suppress pandoc output (Only applicable if \code{show="rendered"})
#' @param css character vector: css specification to apply to changed sections. Defaults to \code{diff_rmd_css()}; specify \code{NULL} to not include a \code{<style>} section in the output
# @param escape_code_chunks logical: escape three-backtick code chunks?
#'
#' @return A list containing one or more elements \code{rendered} (the path to the rendered diff file, if \code{show="rendered"}), \code{intermediate} (the path to the intermediate file, if \code{keep_intermediate = TRUE}), and \code{raw} (if \code{show="raw"})
#'
#' The path to the rendered file showing the differences
#'
#' @examples
#' \dontrun{
#'   result <- diff_rmd(my_current_file, my_reference_file)
#'   browseURL(result)
#' }
#'
#' @export
diff_rmd <- function(current_file, reference_file = "HEAD", show = "raw", output_format = "html_document", keep_intermediate = FALSE, quiet = TRUE, css = diff_rmd_css()) {
    ## , escape_code_chunks = FALSE
    assert_that(is.string(output_format))
    output_format <- match.arg(tolower(output_format), c("html_document"))
    ## or get default document format from rmarkdown::default_output_format(current_file)$name
    assert_that(is.string(show))
    show <- match.arg(tolower(show), c("raw", "rendered"))
    assert_that(is.flag(keep_intermediate), !is.na(keep_intermediate))
    assert_that(is.flag(quiet), !is.na(quiet))

    debug <- FALSE ## just for internal debugging use

    ## test that we can find the git executable
    tryCatch(system2("git", "--version", stderr = TRUE, stdout = TRUE), error = function(e)
        stop("Cannot find the git executable: is it on your system path?"))

    ## are we in a git repository?
    in_git_repo <- tryCatch({
        suppressWarnings(res <- system2("git", "status", stderr = TRUE, stdout = TRUE))
        status <- attr(res, "status")
        if (is.null(status) || status == 0L) TRUE else FALSE
    }, error = function(e) FALSE)

    ## construct the git diff call
    ## we always expect current_file to be an actual file
    if (!file.exists(current_file)) {
        stop("current_file does not exist: ", current_file)
    }
    ## if we are comparing two actual files, we need to include --no-index in the command-line args
    index_str <- NULL
    if (!nzchar(reference_file)) {
        ## empty string, which we will treat as the current version of the file in the HEAD
        ## leave index_str as NULL
    } else {
        if (file.exists(reference_file)) {
            index_str <- "--no-index"
        }
    }
    if (is.null(index_str)) {
        ## we think that the reference_file argument is a git reference
        ## are we in a git repo?
        if (!in_git_repo) stop("The 'reference_file' parameter appears to be a git reference, but your working directory does not seem to be a git repository")
    }
    ## rather than suppressWarnings, should capture warnings and then just screen out the one we want to ignore
    args <- c("diff", "-U2000", "--word-diff", "--minimal", index_str, reference_file, current_file)
    if (debug) cat("args: ", args, "\n")
    suppressWarnings(diffout <- system2("git", args, stdout = TRUE))
    status <- attr(diffout, "status")
    ## -U2000 specifies how much context is included around each individual change
    ## we want the whole document here so it needs to be large (could count lines in file?)

    ## check what we got
    if ((is.null(status) || identical(status, 0L)) && length(diffout) < 1) {
        ## no output but status was OK, so there are no differences between the files
        message("Files are identical")
        return(NULL)
    }
    ## status of 1 means that it ran successfully but there were differences
    ## it seems that status can also be NULL here on a successful run
    ## status 2 means there was an error
    if (!is.null(status) && !identical(status, 1L)) {
        stop("error generating file differences (1)")
    }

    if (length(diffout) < 6) {
        ## no output
        stop("error generating file differences (2)")
    }

    ## strip the headers, which are the first 5 lines
    diffout <- diffout[seq(from = 6, to = length(diffout), by = 1)]

    if (show == "raw") {
        ## escape HTML content now, so that in the final document it won't be interpreted as actual HTML
        ## do this before adding our HTML markup on changes, otherwise those wouldn't be interpreted as HTML either
        diffout <- htmltools::htmlEscape(diffout)
        ##if (escape_code_chunks) diffout <- gsub("^```", "\\\\`\\\\`\\\\`", diffout)
    }

    if (output_format %in% c("html_document")) {
        ## mark up the insert/deletes as HTML markup
        diffout <- gsub("[-", "<del class=\"del\">", diffout, fixed = TRUE)
        diffout <- gsub("-]", "</del>", diffout, fixed = TRUE)
        diffout <- gsub("{+", "<ins class=\"ins\">", diffout, fixed = TRUE)
        diffout <- gsub("+}", "</ins>", diffout, fixed = TRUE)
    } else if (output_format %in% c("pdf", "pdf_document")) {
        stop("pdf format not supported yet")
        ## needs xcolor package available within LaTeX
        diffout <- gsub("[-", "\\textcolor{red}{", diffout, fixed = TRUE)
        diffout <- gsub("-]", "}", diffout, fixed = TRUE)
        diffout <- gsub("{+", "\\textcolor{green}{", diffout, fixed = TRUE)
        diffout <- gsub("+}", "}", diffout, fixed = TRUE)
    } else {
        stop("unsupported output_format: ", output_format)
    }

    intfile <- tempfile()
    con <- file(intfile, "wt")
    if (show == "raw") {
        ## build markdown template
        diffs_html_file <- tempfile(fileext = ".html")
        con2 <- file(diffs_html_file, "wt")
        cat("<pre id = \"diffcontent\">\n", file = con2)
        cat(diffout, sep = "\n", file = con2, append = TRUE)
        cat("</pre>\n", file = con2, append = TRUE)
        close(con2)
        cat(c("---", "output:", "  html_document:", "    includes:", paste0("      before_body: ", diffs_html_file), "---"), sep = "\n", file = con)
        if (!is.null(css) && !all(!nzchar(css))) {
            cat(c("\n<style>", css, "</style>"), sep = "\n", file = con, append = TRUE)
        }
        close(con)
        out <- list(raw = rmarkdown::render(intfile, output_format = output_format, quiet = quiet))
        if (keep_intermediate) {
            out <- c(out, list(intermediate = intfile))
        } else {
            unlink(intfile)
        }
    } else {
        ## rendered output
        writeLines(diffout, con = con)
        close(con)
        out <- list(rendered = rmarkdown::render(intfile, output_format = output_format, quiet = quiet))
        if (keep_intermediate) {
            out <- c(out, list(intermediate = intfile))
        } else {
            unlink(intfile)
        }
    }
    out
}

#' @rdname diff_rmd
#' @export
diff_rmd_css <- function() {
    c(".del { background-color: SandyBrown; } .ins{ background-color: PaleGreen; }",
      ## styles to make <pre> tags line-wrap
      "#diffcontent { white-space: pre-wrap;       /* css-3 */",
      "white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */",
      "white-space: -pre-wrap;      /* Opera 4-6 */",
      "white-space: -o-pre-wrap;    /* Opera 7 */",
      "word-wrap: break-word; }       /* Internet Explorer 5.5+ */")
}
