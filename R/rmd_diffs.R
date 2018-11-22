#' Render the differences between two rmarkdown files
#'
#' @param current_file string: path to file after changes
#' @param reference_file string: path to file before changes
#' @param output_format string: format of the output file (currently only \code{"html_document"})
#'
#' @return The path to the rendered file showing the differences
#'
#' @examples
#' \dontrun{
#'   result <- diff_rmd(my_current_file, my_reference_file)
#'   browseURL(result)
#' }
#'
#' @export
diff_rmd <- function(current_file, reference_file = "HEAD", output_format = "html_document") {
    output_format <- match.arg(tolower(output_format), c("html_document"))##, "pdf_document"))
    ## or get default document format from rmarkdown::default_output_format(current_file)$name

    debug <- FALSE ## just for internal debugging use

    ## test that we can find the git executable
    tryCatch(system2("git", "--version", stderr = TRUE, stdout = TRUE), error = function(e)
        stop("Cannot find the git executable: is it on your system path?"))

    ## check that we are in a git repository
    in_git_repo <- tryCatch({git2r::status(); TRUE}, error = function(e) FALSE)

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

    if (output_format %in% c("html_document")) {
        ## mark up the insert/deletes as HTML markup
        diffout <- gsub("[-", "<del class=\"del\">", diffout, fixed = TRUE)
        diffout <- gsub("-]", "</del>", diffout, fixed = TRUE)
        diffout <- gsub("{+", "<ins class=\"ins\">", diffout, fixed = TRUE)
        diffout <- gsub("+}", "</ins>", diffout, fixed = TRUE)
    } else if (output_format == "pdf_document") {
        stop("pdf_document format not supported yet")
        ## needs xcolor package available within LaTeX
        diffout <- gsub("[-", "\\textcolor{red}{", diffout, fixed = TRUE)
        diffout <- gsub("-]", "}", diffout, fixed = TRUE)
        diffout <- gsub("{+", "\\textcolor{green}{", diffout, fixed = TRUE)
        diffout <- gsub("+}", "}", diffout, fixed = TRUE)
    } else {
        stop("unsupported output_format: ", output_format)
    }

    ## write diffout to file along with suitable HTML scaffolding
    intfile <- tempfile(fileext = ".html")
    con <- file(intfile, "wt")
    on.exit(close(con))
    ## TODO make this nicer and don't write html tags manually like this
    cat("<html>\n<body>\n", file = con)
    ## styles for changes
    cat("<style>.del { background-color: SandyBrown; } .ins{ background-color: PaleGreen; }</style>\n", file = con, append = TRUE)
    ## styles to make <pre> tags line-wrap
    cat("<style>pre { white-space: pre-wrap;       /* css-3 */\n", file = con, append = TRUE)
    cat("white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */\n", file = con, append = TRUE)
    cat("white-space: -pre-wrap;      /* Opera 4-6 */\n", file = con, append = TRUE)
    cat("white-space: -o-pre-wrap;    /* Opera 7 */\n", file = con, append = TRUE)
    cat("word-wrap: break-word;       /* Internet Explorer 5.5+ */\n", file = con, append = TRUE)
    cat("</style>\n", file = con, append = TRUE)
    cat("<pre id = \"diffcontent\">\n", file = con, append = TRUE)
    ## TODO: need to escape all HTML content in diffout, else it will be interpreted as HTML
    cat(diffout, file = con, sep = "\n", append = TRUE)
    cat("</pre>\n", file = con, append = TRUE)
    cat("</body>\n</html>\n", file = con, append = TRUE)
    intfile
}
