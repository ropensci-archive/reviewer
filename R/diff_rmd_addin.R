#' Rstudio addin to display the raw (unrendered) differences between two
#' rmarkdown files
#'
#' This addin is a small wrapper for \code{diff_rmd()}.  
#'
#' @return Displays viewable html of the diff in the RStudio Viewer pane. If
#'   file is identical to previous version a message is provided. This may occur
#'   if changes since the last commit haven't been saved.
#'
#' @export
diff_rmd_addin <- function() {
  content <- rstudioapi::getActiveDocumentContext()
  x <- diff_rmd(content$path)
  if (!is.null(x$raw)) {
    rstudioapi::viewer(x$raw) 
  }
}
