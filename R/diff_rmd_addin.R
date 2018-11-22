#' Rstudio addin to render the differences between two rmarkdown files
#'
#' This addin is a small wrapper for \code{diff_rmd} 
#'
#' @return Viewable html of the diff
#'
#' @export
diff_rmd_addin <- function() {
  content <- rstudioapi::getActiveDocumentContext()
  x <- diff_rmd(content$path)
  rstudioapi::viewer(x$rendered) 
}
