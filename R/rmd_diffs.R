#' Render the differences between two rmarkdown files
#'
#' @param file_before string: path to file before changes
#' @param file_after string: path to file after changes
#' @param output_format string: format of the output file (currently only \code{"html"}) 
#' @param keep_intermediate logical: keep the intermediate rmarkdown file (which contains the marked-up differences)
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
diff_rmd <- function(file_before, file_after, output_format = "html_document", keep_intermediate = FALSE) {
    output_format <- match.arg(tolower(output_format), c("html_document"))#, "pdf_document"))
    ## or get default document format from rmarkdown::default_output_format(file_before)$name

    ## rather than suppressWarnings, should capture warnings and then just screen out the one we want to ignore
    suppressWarnings(diffout <- system2("git", c("diff", "-U2000", "--word-diff", "--minimal", "--no-index", file_before, file_after), stdout = TRUE, stderr = TRUE))
    ## -U2000 specifies how much context is included around each individual change
    ## we want the whole document here so it needs to be large (could count lines in file?)

    ## check what we got
    if ((is.null(attr(diffout, "status")) || identical(attr(diffout, "status"), 0L)) && length(diffout) < 1) {
        ## no output but status was OK, so there are no differences between the files
        message("Files are identical")
        return(NULL)
    }
    ## status of 1 means that it ran successfully but there were no differences
    ## status 2 means there was an error 
    if (!identical(attr(diffout, "status"), 1L)) {
        stop("error generating file differences")
    }

    if (length(diffout) < 6) {
        ## no output
        stop("error generating file differences")
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

    quiet <- FALSE
    out <- list(rendered = rmarkdown::render(intfile, output_format = output_format, quiet = quiet))
    if (keep_intermediate) {
        out <- c(out, list(intermediate = intfile))
    } else {
        unlink(intfile)
    }
    out
}
