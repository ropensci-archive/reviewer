#' Render the differences between two rmarkdown files
#'
#' @param file_before string: path to file before changes
#' @param file_after string: path to file after changes
#' @param output_format string: format of the output file (currently only \code{"html"}) 
#' @param keep_intermediate logical: keep the intermediate rmarkdown file (which contains the marked-up differences)
#' @param quiet logical: if \code{TRUE}, suppress pandoc output during \code{rmarkdown::render} call
#'
#' @return A list containing elements \code{rendered} (the path to the rendered diff file) and (if \code{keep_intermediate = TRUE}) \code{intermediate} (the path to the intermediate file)
#'
#' @examples
#' \dontrun{
#'   result <- diff_rmd(my_file_before, my_file_after)
#'   browseURL(result$rendered)
#' }
#'
#' @export
diff_rmd <- function(file_before = "HEAD", file_after, output_format = "html_document", keep_intermediate = FALSE, quiet = TRUE) {
    output_format <- match.arg(tolower(output_format), c("html_document"))#, "pdf_document"))
    ## or get default document format from rmarkdown::default_output_format(file_before)$name

    debug <- FALSE ## just for internal debugging use

    ## TODO: test that we can find the git executable

    ## construct the git diff call
    ## we always expect file_after to be an actual file
    if (!file.exists(file_after)) {
        stop("file_after does not exist: ", file_after)
    }
    ## if we are comparing two actual files, we need to include --no-index in the command-line args
    index_str <- NULL
    if (!nzchar(file_before)) {
        ## empty string, which we will treat as the current version of the file in the HEAD
        ## leave index_str as NULL
    } else {
        if (file.exists(file_before)) {
            index_str <- "--no-index"
        }
    }
    ## rather than suppressWarnings, should capture warnings and then just screen out the one we want to ignore
    args <- c("diff", "-U2000", "--word-diff", "--minimal", index_str, file_before, file_after)
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

    if (output_format == "html_document") {
        ## mark up the insert/deletes as HTML markup
        diffout <- gsub("[-", "<del class=\"del\">", diffout, fixed = TRUE)
        diffout <- gsub("-]", "</del>", diffout, fixed = TRUE)
        diffout <- gsub("{+", "<ins class=\"ins\">", diffout, fixed = TRUE)
        diffout <- gsub("+}", "</ins>", diffout, fixed = TRUE)
        ## and append stylesheet
        diffout <- c(diffout, "<style>.del,.ins { display: inline-block; margin-left: 0.5ex; } .del { background-color: #fcc; } .ins{ background-color: #cfc; }")
    } else if (output_format == "pdf_document") {
        stop("not yet eh")
    } else {
        stop("unsupported output_format: ", output_format)
    }

    ## write diffout to file
    intfile <- tempfile()
    con <- file(intfile, "wt")
    writeLines(diffout, con = con)
    close(con)

    out <- list(rendered = rmarkdown::render(intfile, output_format = output_format, quiet = quiet))
    if (keep_intermediate) {
        out <- c(out, list(intermediate = intfile))
    } else {
        unlink(intfile)
    }
    out
}
